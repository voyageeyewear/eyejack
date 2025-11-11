require('dotenv').config();
const { sequelize, CollectionBanner } = require('../models');

async function createBannerTable() {
    try {
        console.log('🔌 Connecting to PostgreSQL...');
        await sequelize.authenticate();
        console.log('✅ Database connected!');
        
        console.log('📊 Creating collection_banners table...');
        
        // Create the table
        await CollectionBanner.sync({ force: false }); // force: false won't drop existing table
        
        console.log('✅ collection_banners table created successfully!');
        
        // Add some sample data
        console.log('📝 Adding sample banners...');
        
        const sampleBanners = [
            {
                collection_handle: 'sunglasses',
                banner_position: 'top',
                banner_type: 'image',
                banner_url: 'https://cdn.shopify.com/s/files/1/0085/9885/7203/files/banner-sunglasses.jpg?v=1730000000',
                click_url: '/collection/summer-sale',
                title: 'Summer Sale',
                subtitle: 'Up to 50% OFF on Sunglasses',
                is_active: true,
                display_order: 1
            },
            {
                collection_handle: 'sunglasses',
                banner_position: 'after_6',
                banner_type: 'image',
                banner_url: 'https://cdn.shopify.com/s/files/1/0085/9885/7203/files/banner-premium.jpg?v=1730000000',
                click_url: '/collection/premium',
                title: 'Premium Collection',
                subtitle: 'Exclusive Designer Sunglasses',
                is_active: true,
                display_order: 1
            },
            {
                collection_handle: 'eyeglasses',
                banner_position: 'top',
                banner_type: 'image',
                banner_url: 'https://cdn.shopify.com/s/files/1/0085/9885/7203/files/banner-eyeglasses.jpg?v=1730000000',
                click_url: '/collection/new-arrivals',
                title: 'New Arrivals',
                subtitle: 'Latest Eyeglass Trends',
                is_active: true,
                display_order: 1
            }
        ];
        
        for (const banner of sampleBanners) {
            await CollectionBanner.create(banner);
            console.log(`  ✓ Created banner for ${banner.collection_handle} at ${banner.banner_position}`);
        }
        
        console.log('✅ Sample banners added successfully!');
        console.log('');
        console.log('🎉 Database setup complete!');
        console.log('');
        console.log('📝 Next steps:');
        console.log('1. Update banner URLs in dashboard');
        console.log('2. Add more banners as needed');
        console.log('3. Test collection pages in the app');
        
        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    }
}

createBannerTable();

