// Load environment variables FIRST before any other requires
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const shopifyRoutes = require('./routes/shopify');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/shopify', shopifyRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Shopify Middleware API is running',
    store: process.env.SHOPIFY_STORE_DOMAIN
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Shopify Middleware API running on http://0.0.0.0:${PORT}`);
  console.log(`📦 Store: ${process.env.SHOPIFY_STORE_DOMAIN}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV}`);
});

