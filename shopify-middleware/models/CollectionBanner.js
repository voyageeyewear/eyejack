const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CollectionBanner = sequelize.define('CollectionBanner', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  collection_handle: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Collection handle (e.g., "sunglasses", "eyeglasses")'
  },
  banner_position: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'top',
    comment: 'Position: "top", "after_6", "after_12", etc.'
  },
  banner_type: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'image',
    comment: 'Type: "image" or "video"'
  },
  banner_url: {
    type: DataTypes.TEXT,
    allowNull: false,
    comment: 'URL of banner image or video'
  },
  click_url: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Where to navigate when banner is clicked'
  },
  title: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Banner title/alt text'
  },
  subtitle: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Banner subtitle'
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  display_order: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Order within same position'
  }
}, {
  tableName: 'collection_banners',
  timestamps: true,
  indexes: [
    {
      fields: ['collection_handle']
    },
    {
      fields: ['is_active']
    }
  ]
});

module.exports = CollectionBanner;

