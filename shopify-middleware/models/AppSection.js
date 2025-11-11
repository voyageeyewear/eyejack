const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AppSection = sequelize.define('AppSection', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    section_id: {
        type: DataTypes.STRING(100),
        unique: true,
        allowNull: false,
        comment: 'Unique identifier like "circular-categories", "hero-slider"'
    },
    section_type: {
        type: DataTypes.STRING(50),
        allowNull: false,
        comment: 'Section type like "circular_categories", "hero_slider"'
    },
    settings: {
        type: DataTypes.JSONB,
        allowNull: false,
        defaultValue: {},
        comment: 'All section settings stored as JSON'
    },
    display_order: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        comment: 'Order in which sections appear in the app'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
        comment: 'Whether this section is visible in the app'
    }
}, {
    tableName: 'app_sections',
    timestamps: true,
    underscored: true, // Use snake_case: created_at, updated_at
    indexes: [
        {
            fields: ['section_id']
        },
        {
            fields: ['display_order']
        },
        {
            fields: ['is_active']
        }
    ]
});

module.exports = AppSection;

