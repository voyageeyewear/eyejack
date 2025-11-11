const { Sequelize } = require('sequelize');

// Get database URL from environment variable
const DATABASE_URL = process.env.DATABASE_URL || 'postgresql://localhost:5432/eyejack_dev';

console.log('🔌 Connecting to PostgreSQL...');

const sequelize = new Sequelize(DATABASE_URL, {
    dialect: 'postgres',
    protocol: 'postgres',
    dialectOptions: {
        ssl: process.env.NODE_ENV === 'production' ? {
            require: true,
            rejectUnauthorized: false // Railway uses SSL
        } : false
    },
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
        max: 5,
        min: 0,
        acquire: 30000,
        idle: 10000
    }
});

// Test database connection
async function testConnection() {
    try {
        await sequelize.authenticate();
        console.log('✅ PostgreSQL connected successfully!');
        console.log('📍 Database:', sequelize.getDatabaseName());
        return true;
    } catch (error) {
        console.error('❌ Unable to connect to database:', error.message);
        return false;
    }
}

// Initialize connection on import
testConnection();

module.exports = sequelize;

