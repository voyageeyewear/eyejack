const sequelize = require('../config/database');
const AppSection = require('./AppSection');
const AppTheme = require('./AppTheme');

// Export all models
module.exports = {
    sequelize,
    AppSection,
    AppTheme
};

