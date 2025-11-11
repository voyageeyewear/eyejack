require('dotenv').config();
const { sequelize, AppSection, AppTheme } = require('../models');

async function seedDatabase() {
    try {
        console.log('🌱 Starting database seed...\n');

        // Step 1: Sync database (create tables)
        console.log('📊 Creating database tables...');
        await sequelize.sync({ force: true }); // CAUTION: This drops existing tables!
        console.log('✅ Tables created successfully\n');

        // Step 2: Seed app sections
        console.log('📦 Seeding app sections...');

        const sections = [
            // Announcement Bars
            {
                section_id: 'announcement-bars',
                section_type: 'announcement_bars',
                display_order: 0,
                settings: {
                    bars: [
                        { text: 'BUY 2 AT FLAT 1299/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' },
                        { text: 'BUY 2 AT FLAT 999/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' },
                        { text: 'BUY 2 AT FLAT 799/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' }
                    ]
                }
            },

            // App Header
            {
                section_id: 'app-header',
                section_type: 'app_header',
                display_order: 1,
                settings: {
                    logo: 'https://eyejack.in/cdn/shop/files/colored-logo.png',
                    storeName: 'Eyejack Eyewear',
                    showSearch: true,
                    showCart: true
                }
            },

            // USP Moving Strip
            {
                section_id: 'usp-moving-strip',
                section_type: 'moving_usp_strip',
                display_order: 2,
                settings: {
                    backgroundColor: '#52b1e2',
                    textColor: '#ffffff',
                    animationDuration: 20,
                    items: [
                        { icon: 'local_shipping', text: 'Cash On Delivery Available' },
                        { icon: 'payment', text: 'Easy EMI Options' },
                        { icon: 'swap_horiz', text: 'Easy Return Exchange' },
                        { icon: 'support_agent', text: 'Dedicated Customer Support' }
                    ]
                }
            },

            // Circular Categories
            {
                section_id: 'circular-categories',
                section_type: 'circular_categories',
                display_order: 3,
                settings: {
                    categories: [
                        {
                            name: 'Sunglasses',
                            handle: 'sunglasses',
                            type: 'image',
                            image: 'https://eyejack.in/cdn/shop/files/female.png?v=1761800301&width=200'
                        },
                        {
                            name: 'Eyeglasses',
                            handle: 'eyeglasses',
                            type: 'image',
                            image: 'https://eyejack.in/cdn/shop/files/male-04.png?v=1761800323&width=200'
                        },
                        {
                            name: 'New Arrivals',
                            handle: 'new-arrivals',
                            type: 'video',
                            video: 'https://eyejack.in/cdn/shop/videos/c/vp/4adbfe1a16244dbbb0d89805a901bfdc/4adbfe1a16244dbbb0d89805a901bfdc.HD-1080p-7.2Mbps-61208466.mp4?v=0',
                            image: 'https://eyejack.in/cdn/shop/files/new_arrival-03.png?v=1761800347&width=200'
                        },
                        {
                            name: 'View all',
                            handle: 'all',
                            type: 'image',
                            image: 'https://eyejack.in/cdn/shop/files/view_all-02.png?v=1761800398&width=200'
                        },
                        {
                            name: 'BOGO',
                            handle: 'bogo-sale',
                            type: 'video',
                            video: 'https://eyejack.in/cdn/shop/videos/c/vp/4f471d46b36f41388dad48760935d743/4f471d46b36f41388dad48760935d743.HD-1080p-7.2Mbps-61208515.mp4?v=0',
                            image: 'https://eyejack.in/cdn/shop/files/bogo-01.png?v=1761800260&width=200',
                            badge: 'SALE LIVE'
                        }
                    ]
                }
            },

            // Hero Slider
            {
                section_id: 'hero-slider',
                section_type: 'hero_slider',
                display_order: 4,
                settings: {
                    autoplay: true,
                    autoplaySpeed: 5000,
                    showDots: true,
                    slides: [
                        {
                            type: 'image',
                            heading: '',
                            subheading: '',
                            desktopImage: 'https://eyejack.in/cdn/shop/files/diwali_eyejack_copy_2.jpg',
                            mobileImage: 'https://eyejack.in/cdn/shop/files/Artboard_2_copy_4.png',
                            ctaText: '',
                            link: 'https://eyejack.in/collections/all'
                        },
                        {
                            type: 'video',
                            heading: '',
                            subheading: '',
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/7efdcf899c844767b8731446460d3bca.mp4',
                            ctaText: '',
                            link: 'https://eyejack.in/collections/sunglasses'
                        },
                        {
                            type: 'video',
                            heading: '',
                            subheading: '',
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/3f15c9a81cd04925874a15cff12c3dc1.mp4',
                            ctaText: '',
                            link: 'https://eyejack.in/collections/eyeglasses'
                        }
                    ]
                }
            },

            // Gender Categories - Eyeglasses
            {
                section_id: 'gender-categories-eyeglasses',
                section_type: 'gender_categories',
                display_order: 5,
                settings: {
                    title: 'Eyeglasses',
                    categories: [
                        {
                            name: 'Men Eyeglasses',
                            label: 'Men',
                            handle: 'eyeglasses',
                            image: 'https://eyejack.in/cdn/shop/files/im-01.jpg?v=1759574084'
                        },
                        {
                            name: 'Women Eyeglasses',
                            label: 'Women',
                            handle: 'eyeglasses',
                            image: 'https://eyejack.in/cdn/shop/files/im-02.jpg?v=1759574105'
                        },
                        {
                            name: 'Sale Eyeglasses',
                            label: 'Sale',
                            handle: 'sale',
                            image: 'https://eyejack.in/cdn/shop/files/wolf.webp?v=1759572749'
                        },
                        {
                            name: 'Unisex Eyeglasses',
                            label: 'Unisex',
                            handle: 'eyeglasses',
                            image: 'https://eyejack.in/cdn/shop/files/View_all_New_Launch_Unisex_icon-03.png?v=1759574329'
                        }
                    ]
                }
            },

            // Gender Categories - Sunglasses
            {
                section_id: 'gender-categories-sunglasses',
                section_type: 'gender_categories',
                display_order: 6,
                settings: {
                    title: 'Sunglasses',
                    categories: [
                        {
                            name: 'Men Sunglasses',
                            label: 'Men',
                            handle: 'sunglasses',
                            image: 'https://eyejack.in/cdn/shop/files/2502PCL1474-men_3.jpg?v=1748241296'
                        },
                        {
                            name: 'Women Sunglasses',
                            label: 'Women',
                            handle: 'sunglasses',
                            image: 'https://eyejack.in/cdn/shop/files/2502PCL1474-women_2.jpg?v=1748241296'
                        },
                        {
                            name: 'Sale Sunglasses',
                            label: 'Sale',
                            handle: 'sale',
                            image: 'https://eyejack.in/cdn/shop/files/im-07.jpg?v=1759574222'
                        },
                        {
                            name: 'Unisex Sunglasses',
                            label: 'Unisex',
                            handle: 'sunglasses',
                            image: 'https://eyejack.in/cdn/shop/files/View_all_New_Launch_Unisex_icon-03.png?v=1759574329'
                        }
                    ]
                }
            },

            // Video Slider
            {
                section_id: 'video-slider',
                section_type: 'video_slider',
                display_order: 7,
                settings: {
                    title: 'SHOP BY VIDEO',
                    autoplay: true,
                    loop: true,
                    autoScroll: true,
                    scrollDuration: 5000,
                    videos: [
                        {
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/e0e1269320dc42e099e89020cfe0d789.mp4',
                            thumbnail: 'https://eyejack.in/cdn/shop/files/2502PCL1474-women_2.jpg?v=1748241296',
                            title: 'Eyewear Collection',
                            link: 'https://eyejack.in/collections/all'
                        },
                        {
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/6bab26bb066640ee88e75fbdcde5d938.mp4',
                            thumbnail: 'https://eyejack.in/cdn/shop/files/im-02.jpg?v=1759574105',
                            title: 'Featured Styles',
                            link: 'https://eyejack.in/collections/sunglasses'
                        },
                        {
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/1e69a10818ff424cace3b25ead46d028.mp4',
                            thumbnail: 'https://eyejack.in/cdn/shop/files/im-01.jpg?v=1759574084',
                            title: 'New Arrivals',
                            link: 'https://eyejack.in/collections/new-arrivals'
                        },
                        {
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/93372000dd3043eebccffffc21930874.mp4',
                            thumbnail: 'https://eyejack.in/cdn/shop/files/wolf.webp?v=1759572749',
                            title: 'Premium Collection',
                            link: 'https://eyejack.in/collections/eyeglasses'
                        },
                        {
                            videoUrl: 'https://cdn.shopify.com/videos/c/o/v/a47919d1f45942d8b0a517811908ae37.mp4',
                            thumbnail: 'https://eyejack.in/cdn/shop/files/im-07.jpg?v=1759574222',
                            title: 'Trending Now',
                            link: 'https://eyejack.in/collections/sale'
                        }
                    ]
                }
            },

            // Eyewear Collection Cards
            {
                section_id: 'exclusive-eyewear',
                section_type: 'eyewear_collection_cards',
                display_order: 8,
                settings: {
                    title: 'Exclusive Eyewear Collection',
                    collections: [
                        {
                            name: 'Work Essentials',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'work-essentials',
                            backgroundType: 'video',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/videos/c/vp/c0b3c15c6b1c4275b745e3c1c6df6ae2/c0b3c15c6b1c4275b745e3c1c6df6ae2.HD-720p-4.5Mbps-61053410.mp4?v=0'
                        },
                        {
                            name: 'Student Styles',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'student-styles',
                            backgroundType: 'video',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/videos/c/vp/c0b3c15c6b1c4275b745e3c1c6df6ae2/c0b3c15c6b1c4275b745e3c1c6df6ae2.HD-720p-4.5Mbps-61053410.mp4?v=0'
                        },
                        {
                            name: 'Premium Collection',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'premium-collection',
                            backgroundType: 'image',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/files/homepage-banner-min.jpg?v=1731068527&width=600'
                        },
                        {
                            name: 'Minimal Classics',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'minimal-classics',
                            backgroundType: 'image',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/files/CherryShotAi-gallery-0d197933-ddd5-43db-9c78-54e89e427d3e.png?v=1759579707&width=600'
                        },
                        {
                            name: 'Fashion Forward',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'fashion-forward',
                            backgroundType: 'image',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/files/CherryShotAi-generated-1759579501634.jpg?v=1759579705&width=600'
                        },
                        {
                            name: 'Reading Glasses',
                            subtitle: 'Buy 1 Get 1 Free',
                            handle: 'reading-glasses',
                            backgroundType: 'image',
                            backgroundUrl: 'https://eyejack.in/cdn/shop/files/homepage-banner-2-min.jpg?v=1731068527&width=600'
                        }
                    ]
                }
            }
        ];

        // Bulk create sections
        await AppSection.bulkCreate(sections);
        console.log(`✅ Created ${sections.length} sections\n`);

        // Step 3: Seed theme settings
        console.log('🎨 Seeding theme settings...');

        const themeSettings = [
            {
                theme_key: 'primary_color',
                theme_value: '#52b1e2',
                theme_type: 'color',
                description: 'Primary brand color'
            },
            {
                theme_key: 'background_color',
                theme_value: '#FFFFFF',
                theme_type: 'color',
                description: 'Main background color'
            },
            {
                theme_key: 'text_color',
                theme_value: '#000000',
                theme_type: 'color',
                description: 'Primary text color'
            }
        ];

        await AppTheme.bulkCreate(themeSettings);
        console.log(`✅ Created ${themeSettings.length} theme settings\n`);

        // Step 4: Verify data
        const sectionCount = await AppSection.count();
        const themeCount = await AppTheme.count();

        console.log('📊 Database Status:');
        console.log(`   - Sections: ${sectionCount}`);
        console.log(`   - Theme settings: ${themeCount}`);
        console.log('\n✅ Database seeded successfully!\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ Seed failed:', error);
        console.error('Error details:', error.message);
        process.exit(1);
    }
}

// Run seed
seedDatabase();

