const axios = require('axios');

const SHOPIFY_DOMAIN = process.env.SHOPIFY_STORE_DOMAIN;
const ADMIN_TOKEN = process.env.SHOPIFY_ADMIN_ACCESS_TOKEN;
const STOREFRONT_TOKEN = process.env.SHOPIFY_STOREFRONT_ACCESS_TOKEN;
const API_VERSION = process.env.SHOPIFY_API_VERSION;

// Storefront API GraphQL client
const storefrontClient = axios.create({
  baseURL: `https://${SHOPIFY_DOMAIN}/api/${API_VERSION}/graphql.json`,
  headers: {
    'X-Shopify-Storefront-Access-Token': STOREFRONT_TOKEN,
    'Content-Type': 'application/json',
  },
});

// Admin API REST client
const adminClient = axios.create({
  baseURL: `https://${SHOPIFY_DOMAIN}/admin/api/${API_VERSION}`,
  headers: {
    'X-Shopify-Access-Token': ADMIN_TOKEN,
    'Content-Type': 'application/json',
  },
});

// Fetch theme sections (matching eyejack.in homepage)
exports.fetchThemeSections = async () => {
  try {
    // Fetch data needed for homepage sections
    const [collections, allProducts, shopInfo] = await Promise.all([
      this.fetchCollections(),
      this.fetchProducts(50),
      this.fetchShopInfo()
    ]);

    // Filter products by collection for specific sections
    const diwaliProducts = allProducts.slice(0, 20); // Featured products for Diwali section

    // Create homepage layout matching eyejack.in (New BOGO Theme)
    // Order: Announcement bars → Header → USP Strip → Slideshow → Rest
    const sections = [
      {
        id: 'announcement-bars',
        type: 'announcement_bars',
        settings: {
          bars: [
            { text: 'BUY 2 AT FLAT 1299/-', backgroundColor: '#FF6B6B', textColor: '#FFFFFF' },
            { text: 'BUY 2 AT FLAT 999/-', backgroundColor: '#4ECDC4', textColor: '#FFFFFF' },
            { text: 'BUY 2 AT FLAT 799/-', backgroundColor: '#45B7D1', textColor: '#FFFFFF' }
          ]
        }
      },
      {
        id: 'app-header',
        type: 'app_header',
        settings: {
          logo: 'https://eyejack.in/cdn/shop/files/colored-logo.png',
          storeName: 'Eyejack Eyewear',
          showSearch: true,
          showCart: true
        }
      },
      {
        id: 'usp-moving-strip',
        type: 'moving_usp_strip',
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
      {
        id: 'hero-slider',
        type: 'hero_slider',
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
              ctaLink: '/collections/all'
            },
            {
              type: 'video',
              heading: '',
              subheading: '',
              // Video 2 - MP4 direct URL
              videoUrl: 'https://eyejack.in/cdn/shop/videos/c/vp/9b52c2e2c4a5484f83e48e0f225d227a/9b52c2e2c4a5484f83e48e0f225d227a.HD-720p-4.5Mbps-60870469.mp4',
              posterImage: 'https://eyejack.in/cdn/shop/files/preview_images/9b52c2e2c4a5484f83e48e0f225d227a.thumbnail.0000000000_1800x.jpg',
              ctaText: '',
              ctaLink: '/collections/sunglasses'
            },
            {
              type: 'video',
              heading: '',
              subheading: '',
              // Video 3 - MP4 direct URL
              videoUrl: 'https://eyejack.in/cdn/shop/videos/c/vp/9b0d6c8890234236b35903c5a2bfc1b9/9b0d6c8890234236b35903c5a2bfc1b9.SD-480p-1.5Mbps-60864834.mp4',
              posterImage: 'https://eyejack.in/cdn/shop/files/preview_images/9b0d6c8890234236b35903c5a2bfc1b9.thumbnail.0000000000_1800x.jpg',
              ctaText: '',
              ctaLink: '/collections/eyeglasses'
            }
          ]
        }
      },
      {
        id: 'category-grid',
        type: 'category_grid',
        settings: {
          title: '',
          categories: [
            { name: 'Sunglasses', handle: 'sunglasses', image: allProducts.find(p => p.tags.includes('Sunglasses'))?.images[0]?.src || '' },
            { name: 'Eyeglasses', handle: 'eyeglasses', image: allProducts.find(p => p.tags.includes('Eyeglasses'))?.images[0]?.src || '' },
            { name: 'New Arrivals', handle: 'new-arrivals', image: allProducts[1]?.images[0]?.src || '' },
            { name: 'View all', handle: 'all', image: allProducts[2]?.images[0]?.src || '' }
          ]
        }
      },
      {
        id: 'gender-categories-eyeglasses',
        type: 'gender_categories',
        settings: {
          title: 'Eyeglasses',
          categories: [
            { name: 'Men Eyeglasses', label: 'Men', handle: 'men-eyeglasses' },
            { name: 'Women Eyeglasses', label: 'Women', handle: 'women-eyeglasses' },
            { name: 'Sale Eyeglasses', label: 'Sale', handle: 'sale-eyeglasses' },
            { name: 'Unisex Eyeglasses', label: 'Unisex', handle: 'unisex-eyeglasses' }
          ]
        }
      },
      {
        id: 'gender-categories-sunglasses',
        type: 'gender_categories',
        settings: {
          title: 'Sunglasses',
          categories: [
            { name: 'Men Eyeglasses', label: 'Men', handle: 'men-sunglasses' },
            { name: 'Women Eyeglasses', label: 'Women', handle: 'women-sunglasses' },
            { name: 'Sale Eyeglasses', label: 'Sale', handle: 'sale-sunglasses' },
            { name: 'Unisex Eyeglasses', label: 'Unisex', handle: 'unisex-sunglasses' }
          ]
        }
      },
      {
        id: 'diwali-collection',
        type: 'special_collection',
        settings: {
          title: 'Diwali Special Collection',
          subtitle: 'Celebrate the festival of lights with our exclusive collection',
          products: diwaliProducts,
          backgroundColor: '#FFF5E6'
        }
      },
      {
        id: 'exclusive-eyewear',
        type: 'eyewear_collection_cards',
        settings: {
          title: 'Exclusive Eyewear Collection',
          collections: [
            { name: 'Work Essentials', subtitle: 'Buy 1 Get 1 Free', handle: 'work-essentials' },
            { name: 'Student Styles', subtitle: 'Buy 1 Get 1 Free', handle: 'student-styles' },
            { name: 'Premium Collection', subtitle: 'Buy 1 Get 1 Free', handle: 'premium-collection' },
            { name: 'Minimal Classics', subtitle: 'Buy 1 Get 1 Free', handle: 'minimal-classics' },
            { name: 'Fashion Forward', subtitle: 'Buy 1 Get 1 Free', handle: 'fashion-forward' },
            { name: 'Reading Glasses', subtitle: 'Buy 1 Get 1 Free', handle: 'reading-glasses' }
          ]
        }
      },
      {
        id: 'offers-section',
        type: 'offers_grid',
        settings: {
          title: 'Offer',
          offers: [
            { title: 'Buy 2 @ ₹800', subtitle: 'On your purchase above ₹399', ctaText: 'Shop Now', backgroundColor: '#FFE5B4' },
            { title: 'Buy 2 @ ₹999', subtitle: 'On your purchase above ₹699', ctaText: 'Shop Now', backgroundColor: '#E6F3FF' },
            { title: 'Buy 2 @ ₹1,299', subtitle: 'On your purchase above ₹999', ctaText: 'Shop Now', backgroundColor: '#FFE5E5' },
            { title: 'Buy 2 @ ₹1,499', subtitle: 'On your purchase above ₹1,299', ctaText: 'Shop Now', backgroundColor: '#E5FFE5' }
          ]
        }
      },
      {
        id: 'trust-badges',
        type: 'trust_badges',
        settings: {
          badges: [
            { icon: 'shipping', text: 'Fast shipping' },
            { icon: 'return', text: 'Easy returns' },
            { icon: 'rating', text: 'Highly-rated' },
            { icon: 'secure', text: 'Secure payments' }
          ]
        }
      }
    ];

    return {
      layout: sections,
      shop: shopInfo
    };
  } catch (error) {
    console.error('Error fetching theme sections:', error.message);
    throw error;
  }
};

// Fetch products using Storefront API
exports.fetchProducts = async (limit = 50) => {
  const query = `
    query getProducts($first: Int!) {
      products(first: $first) {
        edges {
          node {
            id
            title
            description
            handle
            vendor
            productType
            tags
            availableForSale
            images(first: 5) {
              edges {
                node {
                  src: url
                  altText
                }
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
              maxVariantPrice {
                amount
                currencyCode
              }
            }
            compareAtPriceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  availableForSale
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { first: limit }
  });

  return response.data.data.products.edges.map(edge => formatProduct(edge.node));
};

// Fetch product by ID
exports.fetchProductById = async (id) => {
  const query = `
    query getProduct($id: ID!) {
      product(id: $id) {
        id
        title
        description
        descriptionHtml
        handle
        vendor
        productType
        tags
        availableForSale
        images(first: 10) {
          edges {
            node {
              src: url
              altText
            }
          }
        }
        priceRange {
          minVariantPrice {
            amount
            currencyCode
          }
          maxVariantPrice {
            amount
            currencyCode
          }
        }
        variants(first: 20) {
          edges {
            node {
              id
              title
              availableForSale
              quantityAvailable
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
              selectedOptions {
                name
                value
              }
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { id: `gid://shopify/Product/${id}` }
  });

  return formatProduct(response.data.data.product);
};

// Fetch products by collection
exports.fetchProductsByCollection = async (handle, limit = 50) => {
  const query = `
    query getCollection($handle: String!, $first: Int!) {
      collection(handle: $handle) {
        id
        title
        description
        handle
        image {
          src: url
          altText
        }
        products(first: $first) {
          edges {
            node {
              id
              title
              description
              handle
              vendor
              availableForSale
              images(first: 3) {
                edges {
                  node {
                    src: url
                    altText
                  }
                }
              }
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { handle, first: limit }
  });

  const collection = response.data.data.collection;
  return {
    ...collection,
    products: collection.products.edges.map(edge => formatProduct(edge.node))
  };
};

// Fetch collections
exports.fetchCollections = async () => {
  const query = `
    query getCollections {
      collections(first: 50) {
        edges {
          node {
            id
            title
            description
            handle
            image {
              src: url
              altText
            }
            productsCount: products(first: 0) {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', { query });
  return response.data.data.collections.edges.map(edge => ({
    id: edge.node.id,
    title: edge.node.title,
    description: edge.node.description,
    handle: edge.node.handle,
    image: edge.node.image
  }));
};

// Fetch collection by handle
exports.fetchCollectionByHandle = async (handle) => {
  const query = `
    query getCollection($handle: String!) {
      collection(handle: $handle) {
        id
        title
        description
        handle
        image {
          src: url
          altText
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { handle }
  });

  return response.data.data.collection;
};

// Fetch shop information
exports.fetchShopInfo = async () => {
  const query = `
    query getShop {
      shop {
        name
        description
        primaryDomain {
          url
          host
        }
        paymentSettings {
          currencyCode
        }
      }
    }
  `;

  const response = await storefrontClient.post('', { query });
  return response.data.data.shop;
};

// Search products
exports.searchProducts = async (searchQuery) => {
  const query = `
    query searchProducts($query: String!) {
      products(first: 50, query: $query) {
        edges {
          node {
            id
            title
            description
            handle
            vendor
            availableForSale
            images(first: 2) {
              edges {
                node {
                  src: url
                  altText
                }
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { query: searchQuery }
  });

  return response.data.data.products.edges.map(edge => formatProduct(edge.node));
};

// Helper function to format product data
function formatProduct(product) {
  return {
    id: product.id,
    title: product.title,
    description: product.description,
    descriptionHtml: product.descriptionHtml,
    handle: product.handle,
    vendor: product.vendor,
    productType: product.productType,
    tags: product.tags,
    availableForSale: product.availableForSale,
    images: product.images?.edges?.map(edge => edge.node) || [],
    priceRange: product.priceRange,
    compareAtPriceRange: product.compareAtPriceRange,
    variants: product.variants?.edges?.map(edge => edge.node) || []
  };
}

