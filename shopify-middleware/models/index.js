const sequelize = require('../config/database');
const AppSection = require('./AppSection');
const AppTheme = require('./AppTheme');
const CollectionBanner = require('./CollectionBanner');

// Export all models
module.exports = {
    sequelize,
    AppSection,
    AppTheme,
    CollectionBanner
};

