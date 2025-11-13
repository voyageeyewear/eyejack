const express = require('express');
const router = express.Router();
const { CollectionPageSettings } = require('../models');

// Migration endpoint to create tables
router.post('/create-tables', async (req, res) => {
  try {
    console.log('🔄 Creating collection_page_settings table...');
    
    // Force sync will drop and recreate the table
    // Use { force: false } in production to avoid data loss
    await CollectionPageSettings.sync({ alter: true });
    
    console.log('✅ Table created successfully');
    
    // Create default settings if they don't exist
    const existingSettings = await CollectionPageSettings.findOne();
    if (!existingSettings) {
      console.log('📝 Creating default settings...');
      await CollectionPageSettings.create({});
      console.log('✅ Default settings created');
    }
    
    res.json({
      success: true,
      message: 'Migration completed successfully',
      tableCreated: true,
      defaultsCreated: !existingSettings
    });
  } catch (error) {
    console.error('❌ Migration error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check for migrations
router.get('/status', async (req, res) => {
  try {
    const settings = await CollectionPageSettings.findOne();
    res.json({
      success: true,
      tableExists: true,
      hasDefaultSettings: !!settings
    });
  } catch (error) {
    res.json({
      success: false,
      tableExists: false,
      error: error.message
    });
  }
});

module.exports = router;

