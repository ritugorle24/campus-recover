const mongoose = require('mongoose');
const User = require('./models/User');
const Item = require('./models/Item');
const Match = require('./models/Match');
require('dotenv').config();

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to DB');

    // 1. Find or create users
    let owner = await User.findOne({ email: 'owner@example.com' });
    if (!owner) {
      owner = await User.create({
        name: 'Item Owner',
        email: 'owner@example.com',
        password: 'password123',
        prn: '11111111',
        rollNumber: '101',
        college: 'Test College'
      });
    }

    let finder = await User.findOne({ email: 'finder@example.com' });
    if (!finder) {
      finder = await User.create({
        name: 'Item Finder',
        email: 'finder@example.com',
        password: 'password123',
        prn: '22222222',
        rollNumber: '102',
        college: 'Test College'
      });
    }

    // 2. Create items
    const lostItem = await Item.create({
      title: 'Lost iPhone 13',
      description: 'Blue iPhone with a cracked screen',
      category: 'Electronics',
      type: 'lost',
      postedBy: owner._id,
      posterName: owner.name,
      location: { type: 'Point', coordinates: [0, 0], displayString: 'Main Library' },
      date: new Date(),
    });

    const foundItem = await Item.create({
      title: 'Found iPhone',
      description: 'Found a blue iPhone near library',
      category: 'Electronics',
      type: 'found',
      postedBy: finder._id,
      posterName: finder.name,
      location: { type: 'Point', coordinates: [0, 0], displayString: 'Main Library' },
      date: new Date(),
      securityQuestion: 'What is the lock screen wallpaper?',
    });

    // 3. Create a match with a submitted claim
    const match = await Match.create({
      lostItem: lostItem._id,
      foundItem: foundItem._id,
      score: 95,
      status: 'pending',
      claimStatus: 'submitted',
      claimDescription: 'The wallpaper is a picture of my dog.',
    });

    console.log('Seed successful!');
    console.log('Finder PRN:', finder.prn);
    console.log('Found Item ID:', foundItem._id);
    
    process.exit(0);
  } catch (error) {
    console.error('Seed failed:', error);
    process.exit(1);
  }
};

seed();
