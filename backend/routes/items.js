const express = require('express');
const mongoose = require('mongoose');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const Item = require('../models/Item');
const User = require('../models/User');
const Match = require('../models/Match');
const Notification = require('../models/Notification');
const { findMatches } = require('../services/matchingService');

const router = express.Router();

// GET /api/items - List all active items with filters
router.get('/', auth, async (req, res) => {
  try {
    const { type, category, status, page = 1, limit = 20 } = req.query;
    const filter = {};

    if (type) filter.type = type;
    if (category) filter.category = category;
    if (status) {
      filter.status = status;
    } else {
      filter.status = 'active';
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const items = await Item.find(filter)
      .populate('postedBy', 'name prn rollNumber avatar college')
      .select('-securityQuestion -securityAnswer')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Item.countDocuments(filter);

    res.json({
      items,
      pagination: {
        current: parseInt(page),
        pages: Math.ceil(total / parseInt(limit)),
        total,
      },
    });
  } catch (error) {
    console.error('Get items error:', error);
    res.status(500).json({ message: 'Error fetching items' });
  }
});

// GET /api/items/my - Get current user's items
router.get('/my', auth, async (req, res) => {
  try {
    const items = await Item.find({ postedBy: req.userId })
      .populate('postedBy', 'name prn rollNumber avatar college')
      .populate('matchedWith')
      .select('-securityQuestion -securityAnswer')
      .sort({ createdAt: -1 });

    res.json({ items });
  } catch (error) {
    console.error('Get my items error:', error);
    res.status(500).json({ message: 'Error fetching your items' });
  }
});

// GET /api/items/:id/security-question - Get ONLY the question
router.get('/:id/security-question', auth, async (req, res) => {
  try {
    const item = await Item.findById(req.params.id).select('+securityQuestion');
    if (!item) return res.status(404).json({ message: 'Item not found' });
    res.json({ question: item.securityQuestion });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching security question' });
  }
});

// GET /api/items/search - Full-text search
router.get('/search', auth, async (req, res) => {
  try {
    const { q, type, category } = req.query;

    if (!q || q.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const filter = {
      $text: { $search: q },
      status: 'active',
    };

    if (type) filter.type = type;
    if (category) filter.category = category;

    const items = await Item.find(filter, { score: { $meta: 'textScore' } })
      .populate('postedBy', 'name prn rollNumber avatar college')
      .select('-securityQuestion -securityAnswer')
      .sort({ score: { $meta: 'textScore' } })
      .limit(50);

    res.json({ items, query: q });
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ message: 'Error searching items' });
  }
});

// GET /api/items/:id - Get item detail (WITH DESCRIPTION MASKING)
router.get('/:id', auth, async (req, res) => {
  try {
    const item = await Item.findById(req.params.id)
      .populate('postedBy', 'name prn rollNumber avatar college department')
      .select('-securityQuestion -securityAnswer');

    if (!item) {
      return res.status(404).json({ message: 'Item not found' });
    }

    // Security: Hide description if not owner or if claim not approved
    const isOwner = item.postedBy._id.toString() === req.userId;
    
    // Check for approved match involving this item
    const approvedMatch = await Match.findOne({
      $and: [
        { claimStatus: 'approved' },
        { $or: [{ lostItem: item._id }, { foundItem: item._id }] }
      ]
    });

    const isAuthorized = isOwner || (approvedMatch && 
      (approvedMatch.lostItem.toString() === item._id.toString() || 
       approvedMatch.foundItem.toString() === item._id.toString()));

    if (!isAuthorized) {
      item.description = 'PRIVATE: Submit a claim and describe a unique feature to see full details.';
    }

    res.json({ item });
  } catch (error) {
    console.error('Get item error:', error);
    res.status(500).json({ message: 'Error fetching item' });
  }
});


// POST /api/items/match/:matchId/claim - Submit a claim
router.post('/match/:matchId/claim', auth, async (req, res) => {
  try {
    const { matchId } = req.params;
    const { description } = req.body;

    if (!description) return res.status(400).json({ message: 'Description is required' });

    // 1. Daily Limit Check (2 per 24 hours)
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    // Find all matches where this user is the lost party and has submitted a claim in last 24h
    const matchesWithClaims = await Match.find({ 
      claimSubmittedAt: { $gte: twentyFourHoursAgo },
      claimStatus: { $in: ['submitted', 'approved', 'rejected'] }
    }).populate('lostItem');

    const userClaimsIn24h = matchesWithClaims.filter(m => 
      m.lostItem && m.lostItem.postedBy.toString() === req.userId
    );

    if (userClaimsIn24h.length >= 2) {
      return res.status(429).json({ message: 'You have reached your daily claim limit' });
    }

    const match = await Match.findById(matchId).populate('foundItem');
    if (!match) return res.status(404).json({ message: 'Match not found' });

    match.claimDescription = description;
    match.claimStatus = 'submitted';
    match.claimSubmittedAt = new Date();
    await match.save();

    // Notify Finder
    await Notification.create({
      userId: match.foundItem.postedBy,
      type: 'CLAIM',
      title: 'New Claim Request',
      body: 'Someone has submitted a claim for your found item. Review it now.',
      relatedId: match.foundItem._id,
      read: false
    });

    res.json({ message: 'Claim submitted successfully', match });
  } catch (error) {
    console.error('Claim error:', error);
    res.status(500).json({ message: 'Error submitting claim' });
  }
});

// PUT /api/items/match/:matchId/verify-claim - Approve/Reject
router.put('/match/:matchId/verify-claim', auth, async (req, res) => {
  try {
    const { matchId } = req.params;
    const { action } = req.body; // 'approve' or 'reject'

    const match = await Match.findById(matchId).populate('foundItem').populate('lostItem');
    if (!match) return res.status(404).json({ message: 'Match not found' });

    // Verify requester is the finder
    if (match.foundItem.postedBy.toString() !== req.userId) {
      return res.status(403).json({ message: 'Only the finder can verify this claim' });
    }

    if (action === 'approve') {
      match.claimStatus = 'approved';
      match.status = 'confirmed';
      // Notify owner
      await Notification.create({
        userId: match.lostItem.postedBy,
        type: 'CLAIM',
        title: 'Claim Accepted!',
        body: 'Your claim has been approved. Arrange a meetup with the finder.',
        relatedId: match._id,
        read: false
      });
    } else {
      match.claimStatus = 'rejected';
      // Notify Owner
      await Notification.create({
        userId: match.lostItem.postedBy,
        type: 'CLAIM',
        title: 'Claim Rejected ❌',
        body: 'The finder did not find your description accurate. Try again.',
        relatedId: match.lostItem._id,
        read: false
      });
    }

    await match.save();
    res.json({ message: `Claim ${action}d successfully`, match });
  } catch (error) {
    res.status(500).json({ message: 'Error verifying claim' });
  }
});

// GET /api/items/:id/matches - Get suggested matches for an item
router.get('/:id/matches', auth, async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ message: 'Item not found' });
    }

    // Generate new matches if any score >= 40
    await findMatches(item);

    // Fetch all existing matches for this item from DB
    const matches = await Match.find({
      $or: [{ lostItem: item._id }, { foundItem: item._id }]
    })
    .populate({
      path: 'lostItem',
      populate: { path: 'postedBy', select: 'name avatar' }
    })
    .populate({
      path: 'foundItem',
      populate: { path: 'postedBy', select: 'name avatar' }
    })
    .sort({ score: -1 });

    res.json({ matches });
  } catch (error) {
    console.error('Get matches error:', error);
    res.status(500).json({ message: 'Error finding matches' });
  }
});

// POST /api/items - Report a lost/found item
router.post('/', auth, upload.array('images', 3), async (req, res) => {
  try {
    const { title, description, category, type, date, location, securityQuestion, securityAnswer } = req.body;

    const images = req.files ? req.files.map(f => `/uploads/${f.filename}`) : [];

    const item = new Item({
      title,
      description,
      category,
      type,
      images,
      location: typeof location === 'string' ? JSON.parse(location) : location,
      date: date || new Date(),
      postedBy: req.userId,
      securityQuestion: type === 'found' ? securityQuestion : null,
      securityAnswer: type === 'found' ? securityAnswer : null,
    });

    await item.save();

    // Update user stats
    const user = await User.findById(req.userId);
    if (type === 'found') {
      user.itemsFound += 1;
      user.points += 5; 
      user.checkBadges();
    } else {
      user.itemsLost += 1;
    }
    await user.save();

    await item.populate('postedBy', 'name prn rollNumber avatar college');

    // Run matching in background
    findMatches(item).catch(err => console.error('Background matching error:', err));

    res.status(201).json({
      message: `${type === 'lost' ? 'Lost' : 'Found'} item reported successfully`,
      item,
    });
  } catch (error) {
    console.error('Create item error:', error);
    res.status(500).json({ message: 'Error creating item' });
  }
});

// PUT /api/items/:id - Update item
router.put('/:id', auth, async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item || item.postedBy.toString() !== req.userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    const updatedItem = await Item.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    ).populate('postedBy', 'name prn rollNumber avatar college');

    res.json({ message: 'Item updated successfully', item: updatedItem });
  } catch (error) {
    res.status(500).json({ message: 'Error updating item' });
  }
});

// DELETE /api/items/:id - Delete item
router.delete('/:id', auth, async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item || item.postedBy.toString() !== req.userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }
    await Item.findByIdAndDelete(req.params.id);
    res.json({ message: 'Item deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting item' });
  }
});

module.exports = router;
