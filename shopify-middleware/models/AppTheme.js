const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AppTheme = sequelize.define('AppTheme', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    theme_key: {
        type: DataTypes.STRING(100),
        unique: true,
        allowNull: false,
        comment: 'Theme setting key like "primary_color", "background_color"'
    },
    theme_value: {
        type: DataTypes.TEXT,
        allowNull: false,
        comment: 'Theme setting value'
    },
    theme_type: {
        type: DataTypes.STRING(50),
        comment: 'Data type: color, number, boolean, string'
    },
    description: {
        type: DataTypes.TEXT,
        comment: 'Human-readable description for dashboard'
    }
}, {
    tableName: 'app_theme',
    timestamps: true,
    underscored: true,
    indexes: [
        {
            fields: ['theme_key']
        }
    ]
});

module.exports = AppTheme;

