const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  body: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['MATCH', 'CLAIM', 'SYSTEM', 'EXPIRED', 'HANDOVER'],
    required: true,
  },
  relatedId: {
    type: mongoose.Schema.Types.ObjectId,
    required: false, // Could be MatchId, ItemId, or HandoverId
  },
  actions: {
    type: [String],
    default: [],
  },
  read: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 60 * 60 * 24 * 30, // Auto-delete after 30 days
  },
});

module.exports = mongoose.model('Notification', notificationSchema);
