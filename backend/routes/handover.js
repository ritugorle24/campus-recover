const express = require('express');
const { v4: uuidv4 } = require('uuid');
const auth = require('../middleware/auth');
const Handover = require('../models/Handover');
const Match = require('../models/Match');
const Item = require('../models/Item');
const User = require('../models/User');
const Notification = require('../models/Notification');

const router = express.Router();

// POST /api/handover/generate - Generate QR code (Called by Owner)
router.post('/generate', auth, async (req, res) => {
  try {
    const { matchId } = req.body;
    const match = await Match.findById(matchId);
    if (!match) return res.status(404).json({ message: 'Match not found' });

    const qrToken = uuidv4();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    const handover = new Handover({
      match: matchId,
      qrToken,
      generatedBy: req.userId,
      expiresAt,
    });

    await handover.save();
    res.status(201).json({ handover });
  } catch (error) {
    res.status(500).json({ message: 'Error generating QR' });
  }
});

// POST /api/handover/verify - Scan QR (Called by Finder)
router.post('/verify', auth, async (req, res) => {
  try {
    const { token } = req.body;
    const handover = await Handover.findOne({ qrToken: token }).populate({
      path: 'match',
      populate: ['lostItem', 'foundItem']
    });

    if (!handover || handover.isExpired()) {
      return res.status(404).json({ message: 'Invalid or expired QR token' });
    }

    if (handover.status === 'completed') {
      return res.status(400).json({ message: 'Handover already completed' });
    }

    handover.status = 'completed';
    handover.scannedBy = req.userId;
    handover.completedAt = new Date();
    await handover.save();

    const match = handover.match;
    const ownerId = match.lostItem.postedBy;
    const finderId = match.foundItem.postedBy;

    // Resolve items
    await Item.findByIdAndUpdate(match.lostItem._id, { status: 'resolved' });
    await Item.findByIdAndUpdate(match.foundItem._id, { status: 'resolved' });

    // Award 25 points to finder
    const finder = await User.findById(finderId);
    if (finder) {
      finder.points += 25;
      finder.itemsReturned += 1;
      finder.checkBadges();
      await finder.save();
    }

    // Notify both users
    await Notification.create({
      userId: ownerId,
      type: 'HANDOVER',
      title: 'Item Successfully Returned!',
      body: 'Your item has been marked as resolved. Thank you for using FindIt Campus.',
      read: false
    });

    await Notification.create({
      userId: finderId,
      type: 'HANDOVER',
      title: 'Points Awarded!',
      body: 'You successfully returned an item and earned 25 points! Keep up the good work.',
      read: false
    });

    res.json({ message: 'Handover verified and completed successfully', handover });
  } catch (error) {
    console.error('Verify handover error:', error);
    res.status(500).json({ message: 'Error verifying handover' });
  }
});

module.exports = router;
