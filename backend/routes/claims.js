const express = require('express');
const auth = require('../middleware/auth');
const Item = require('../models/Item');
const Match = require('../models/Match');
const Notification = require('../models/Notification');

const router = express.Router();

// POST /api/claims - Submit a claim with security answer
router.post('/', auth, async (req, res) => {
  try {
    const { itemId, matchId, securityAnswer, uniqueDescription } = req.body;

    if (!securityAnswer) {
      return res.status(400).json({ message: 'Security answer is required' });
    }

    const item = await Item.findById(itemId).select('+securityAnswer +securityQuestion');
    if (!item) return res.status(404).json({ message: 'Item not found' });

    // Verify answer (case insensitive and trimmed)
    const isCorrect = item.securityAnswer && 
                     item.securityAnswer.toLowerCase().trim() === securityAnswer.toLowerCase().trim();
    
    if (!isCorrect) {
      return res.status(403).json({ message: 'Incorrect answer. Only the real owner would know this.' });
    }

    // Proceed to create/update claim in Match
    let match;
    if (matchId) {
      match = await Match.findById(matchId).populate('foundItem');
    } else {
      // Find user's best matching lost item
      const myLostItems = await Item.find({ postedBy: req.userId, type: 'lost', status: 'active' });
      if (myLostItems.length === 0) {
        return res.status(400).json({ message: 'You must report your item as "lost" first before claiming a found item.' });
      }

      const { calculateMatchScore } = require('../services/matchingService');
      let bestMatch = null;
      let highestScore = -1;

      for (const lostItem of myLostItems) {
        const { score } = calculateMatchScore(lostItem, item);
        if (score > highestScore) {
          highestScore = score;
          bestMatch = lostItem;
        }
      }

      if (!bestMatch) {
        return res.status(400).json({ message: 'Could not link this claim to any of your lost items.' });
      }

      // Create a manual match
      match = new Match({
        lostItem: bestMatch._id,
        foundItem: item._id,
        score: highestScore,
        suggestedBy: 'user',
        status: 'pending'
      });
      await match.save();
      match = await Match.findById(match._id).populate('foundItem');
    }

    if (!match) return res.status(404).json({ message: 'Match could not be established' });

    // 1. Daily Limit Check (2 per 24 hours) - Consistent with items.js
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
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

    match.claimDescription = uniqueDescription || 'Verified via security question';
    match.claimStatus = 'submitted';
    match.claimSubmittedAt = new Date();
    await match.save();

    // Notify Finder
    await Notification.create({
      userId: match.foundItem.postedBy,
      type: 'CLAIM',
      title: 'Someone claimed your item!',
      body: `A claim has been submitted for your ${item.title}.`,
      relatedId: match._id,
      read: false
    });

    res.json({ message: 'Claim submitted successfully', match });
  } catch (error) {
    console.error('Create claim error:', error);
    res.status(500).json({ message: 'Error submitting claim' });
  }
});

module.exports = router;
