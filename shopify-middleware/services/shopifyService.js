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
    // Order: Announcement bars → Header (Flutter AppBar) → USP Strip → Instagram → Slideshow → Rest
    const sections = [
      {
        id: 'announcement-bars',
        type: 'announcement_bars',
        settings: {
          bars: [
            { text: 'BUY 2 AT FLAT 1299/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' },
            { text: 'BUY 2 AT FLAT 999/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' },
            { text: 'BUY 2 AT FLAT 799/-', backgroundColor: '#52b1e2', textColor: '#FFFFFF' }
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
      {
        id: 'gender-categories-sunglasses',
        type: 'gender_categories',
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

// Fetch active theme and its assets
exports.fetchThemeFiles = async () => {
  try {
    // Get the active theme
    const themesResponse = await adminClient.get('/themes.json');
    const activeTheme = themesResponse.data.themes.find(theme => theme.role === 'main');
    
    if (!activeTheme) {
      throw new Error('No active theme found');
    }

    console.log('Active theme:', activeTheme.name, 'ID:', activeTheme.id);

    // Fetch specific assets we need for product page
    const assetKeys = [
      'sections/main-product.liquid',
      'sections/main-product--default.liquid',
      'sections/main-product--defult.liquid',
      'snippets/product-card.liquid',
      'snippets/product-form.liquid',
      'snippets/product-variant-picker.liquid',
      'snippets/sticky-cart.liquid',
      'snippets/lens-selector.liquid'
    ];

    const assets = {};
    
    for (const key of assetKeys) {
      try {
        const assetResponse = await adminClient.get(`/themes/${activeTheme.id}/assets.json`, {
          params: { 'asset[key]': key }
        });
        if (assetResponse.data.asset) {
          assets[key] = assetResponse.data.asset.value;
          console.log(`✓ Fetched: ${key}`);
        }
      } catch (err) {
        console.log(`✗ Not found: ${key}`);
      }
    }

    return {
      themeName: activeTheme.name,
      themeId: activeTheme.id,
      assets
    };
  } catch (error) {
    console.error('Error fetching theme files:', error.message);
    throw error;
  }
};

// Fetch all assets for a theme (useful for finding all snippets)
exports.fetchAllThemeAssets = async () => {
  try {
    const themesResponse = await adminClient.get('/themes.json');
    const activeTheme = themesResponse.data.themes.find(theme => theme.role === 'main');
    
    if (!activeTheme) {
      throw new Error('No active theme found');
    }

    const assetsResponse = await adminClient.get(`/themes/${activeTheme.id}/assets.json`);
    
    return {
      themeName: activeTheme.name,
      themeId: activeTheme.id,
      assetList: assetsResponse.data.assets.map(asset => asset.key)
    };
  } catch (error) {
    console.error('Error fetching theme assets:', error.message);
    throw error;
  }
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

// Cart operations using Storefront API
let currentCartId = null;

exports.addToCart = async (variantId, quantity, properties) => {
  try {
    // Create cart if doesn't exist
    if (!currentCartId) {
      const createCartMutation = `
        mutation cartCreate($input: CartInput!) {
          cartCreate(input: $input) {
            cart {
              id
              checkoutUrl
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        price {
                          amount
                          currencyCode
                        }
                        product {
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                                altText
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              cost {
                totalAmount {
                  amount
                  currencyCode
                }
                subtotalAmount {
                  amount
                  currencyCode
                }
              }
            }
          }
        }
      `;

      // Clean up variantId - remove gid:// prefix if present, then add it back
      let cleanId = variantId;
      if (cleanId.includes('gid://shopify/ProductVariant/')) {
        cleanId = cleanId.replace('gid://shopify/ProductVariant/', '');
      }
      const merchandiseId = `gid://shopify/ProductVariant/${cleanId}`;
      
      console.log('🔍 CART: Variant ID conversion (create cart):', { original: variantId, clean: cleanId, final: merchandiseId });
      
      const lineItem = {
        merchandiseId: merchandiseId,
        quantity: parseInt(quantity)
      };
      
      // Only add attributes if properties exist
      if (properties && Object.keys(properties).length > 0) {
        lineItem.attributes = Object.entries(properties).map(([key, value]) => ({ 
          key, 
          value: String(value) 
        }));
      }

      const response = await storefrontClient.post('', {
        query: createCartMutation,
        variables: {
          input: {
            lines: [lineItem]
          }
        }
      });

      if (!response.data || !response.data.data || !response.data.data.cartCreate) {
        throw new Error('Invalid response from Shopify: ' + JSON.stringify(response.data));
      }

      currentCartId = response.data.data.cartCreate.cart.id;
      return formatCart(response.data.data.cartCreate.cart);
    } else {
      // Add to existing cart
      const addLinesMutation = `
        mutation cartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: $cartId, lines: $lines) {
            cart {
              id
              checkoutUrl
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        price {
                          amount
                          currencyCode
                        }
                        product {
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                                altText
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              cost {
                totalAmount {
                  amount
                  currencyCode
                }
                subtotalAmount {
                  amount
                  currencyCode
                }
              }
            }
          }
        }
      `;

      // Clean up variantId - remove gid:// prefix if present, then add it back
      let cleanId = variantId;
      if (cleanId.includes('gid://shopify/ProductVariant/')) {
        cleanId = cleanId.replace('gid://shopify/ProductVariant/', '');
      }
      const merchandiseId = `gid://shopify/ProductVariant/${cleanId}`;
      
      console.log('🔍 CART: Variant ID conversion (add to existing):', { original: variantId, clean: cleanId, final: merchandiseId });
      
      const lineItem = {
        merchandiseId: merchandiseId,
        quantity: parseInt(quantity)
      };
      
      // Only add attributes if properties exist
      if (properties && Object.keys(properties).length > 0) {
        lineItem.attributes = Object.entries(properties).map(([key, value]) => ({ 
          key, 
          value: String(value) 
        }));
      }

      const response = await storefrontClient.post('', {
        query: addLinesMutation,
        variables: {
          cartId: currentCartId,
          lines: [lineItem]
        }
      });

      if (!response.data || !response.data.data || !response.data.data.cartLinesAdd) {
        throw new Error('Invalid response from Shopify: ' + JSON.stringify(response.data));
      }

      return formatCart(response.data.data.cartLinesAdd.cart);
    }
  } catch (error) {
    console.error('Error adding to cart:', error);
    throw error;
  }
};

// Add multiple items to cart (for lens + frame together)
exports.addMultipleToCart = async (items) => {
  try {
    console.log('🛒 Adding multiple items to cart:', JSON.stringify(items, null, 2));
    
    // Prepare line items
    const lineItems = items.map(item => {
      // Clean up variantId
      let cleanId = item.variantId;
      if (cleanId.includes('gid://shopify/ProductVariant/')) {
        cleanId = cleanId.replace('gid://shopify/ProductVariant/', '');
      }
      const merchandiseId = `gid://shopify/ProductVariant/${cleanId}`;
      
      const lineItem = {
        merchandiseId: merchandiseId,
        quantity: parseInt(item.quantity)
      };
      
      // Add attributes if properties exist
      if (item.properties && Object.keys(item.properties).length > 0) {
        lineItem.attributes = Object.entries(item.properties).map(([key, value]) => ({
          key,
          value: String(value)
        }));
      }
      
      return lineItem;
    });
    
    console.log('🔍 Prepared line items:', JSON.stringify(lineItems, null, 2));
    
    // Create cart if doesn't exist
    if (!currentCartId) {
      const createCartMutation = `
        mutation cartCreate($input: CartInput!) {
          cartCreate(input: $input) {
            cart {
              id
              checkoutUrl
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    attributes {
                      key
                      value
                    }
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        price {
                          amount
                          currencyCode
                        }
                        product {
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                                altText
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              cost {
                totalAmount {
                  amount
                  currencyCode
                }
                subtotalAmount {
                  amount
                  currencyCode
                }
              }
            }
            userErrors {
              field
              message
            }
          }
        }
      `;

      const response = await storefrontClient.post('', {
        query: createCartMutation,
        variables: {
          input: {
            lines: lineItems
          }
        }
      });

      if (!response.data || !response.data.data || !response.data.data.cartCreate) {
        throw new Error('Invalid response from Shopify: ' + JSON.stringify(response.data));
      }

      const { cart, userErrors } = response.data.data.cartCreate;

      if (userErrors && userErrors.length > 0) {
        console.error('❌ Shopify userErrors (create):', JSON.stringify(userErrors, null, 2));
        throw new Error(`Shopify error: ${userErrors.map(e => e.message).join(', ')}`);
      }

      if (!cart) {
        throw new Error('Cart creation failed - cart is null');
      }

      currentCartId = cart.id;
      console.log('✅ Cart created with multiple items:', currentCartId);
      return formatCart(cart);
    } else {
      // Add to existing cart
      const addLinesMutation = `
        mutation cartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
          cartLinesAdd(cartId: $cartId, lines: $lines) {
            cart {
              id
              checkoutUrl
              lines(first: 100) {
                edges {
                  node {
                    id
                    quantity
                    attributes {
                      key
                      value
                    }
                    merchandise {
                      ... on ProductVariant {
                        id
                        title
                        price {
                          amount
                          currencyCode
                        }
                        product {
                          title
                          images(first: 1) {
                            edges {
                              node {
                                url
                                altText
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
              cost {
                totalAmount {
                  amount
                  currencyCode
                }
                subtotalAmount {
                  amount
                  currencyCode
                }
              }
            }
            userErrors {
              field
              message
            }
          }
        }
      `;

      const response = await storefrontClient.post('', {
        query: addLinesMutation,
        variables: {
          cartId: currentCartId,
          lines: lineItems
        }
      });

      if (!response.data || !response.data.data || !response.data.data.cartLinesAdd) {
        throw new Error('Invalid response from Shopify: ' + JSON.stringify(response.data));
      }

      const { cart, userErrors } = response.data.data.cartLinesAdd;

      if (userErrors && userErrors.length > 0) {
        console.error('❌ Shopify userErrors (add lines):', JSON.stringify(userErrors, null, 2));
        throw new Error(`Shopify error: ${userErrors.map(e => e.message).join(', ')}`);
      }

      if (!cart) {
        throw new Error('Adding items failed - cart is null');
      }

      console.log('✅ Added multiple items to existing cart');
      return formatCart(cart);
    }
  } catch (error) {
    console.error('Error adding multiple items to cart:', error);
    throw error;
  }
};

exports.updateCart = async (lineItemId, quantity) => {
  const mutation = `
    mutation cartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart {
          id
          checkoutUrl
          lines(first: 100) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                    product {
                      title
                      images(first: 1) {
                        edges {
                          node {
                            url
                            altText
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          cost {
            totalAmount {
              amount
              currencyCode
            }
            subtotalAmount {
              amount
              currencyCode
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query: mutation,
    variables: {
      cartId: currentCartId,
      lines: [{ id: lineItemId, quantity: parseInt(quantity) }]
    }
  });

  return formatCart(response.data.data.cartLinesUpdate.cart);
};

exports.removeFromCart = async (lineItemId) => {
  const mutation = `
    mutation cartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart {
          id
          checkoutUrl
          lines(first: 100) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                    product {
                      title
                      images(first: 1) {
                        edges {
                          node {
                            url
                            altText
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          cost {
            totalAmount {
              amount
              currencyCode
            }
            subtotalAmount {
              amount
              currencyCode
            }
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query: mutation,
    variables: {
      cartId: currentCartId,
      lineIds: [lineItemId]
    }
  });

  return formatCart(response.data.data.cartLinesRemove.cart);
};

exports.getCart = async () => {
  if (!currentCartId) {
    return { items: [], total: '0.00', subtotal: '0.00', itemCount: 0 };
  }

  const query = `
    query getCart($cartId: ID!) {
      cart(id: $cartId) {
        id
        checkoutUrl
        lines(first: 100) {
          edges {
            node {
              id
              quantity
              attributes {
                key
                value
              }
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                  product {
                    title
                    images(first: 1) {
                      edges {
                        node {
                          url
                          altText
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        cost {
          totalAmount {
            amount
            currencyCode
          }
          subtotalAmount {
            amount
            currencyCode
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query,
    variables: { cartId: currentCartId }
  });

  return formatCart(response.data.data.cart);
};

exports.clearCart = async () => {
  currentCartId = null;
  return { items: [], total: '0.00', subtotal: '0.00', itemCount: 0 };
};

exports.createCheckout = async (lineItems) => {
  const mutation = `
    mutation checkoutCreate($input: CheckoutCreateInput!) {
      checkoutCreate(input: $input) {
        checkout {
          id
          webUrl
          lineItems(first: 100) {
            edges {
              node {
                title
                quantity
                variant {
                  price {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
          totalPrice {
            amount
            currencyCode
          }
        }
      }
    }
  `;

  const response = await storefrontClient.post('', {
    query: mutation,
    variables: {
      input: {
        lineItems: lineItems.map(item => ({
          variantId: `gid://shopify/ProductVariant/${item.variantId}`,
          quantity: item.quantity
        }))
      }
    }
  });

  return response.data.data.checkoutCreate.checkout;
};

// Fetch lens options from Shopify (from products tagged with 'lens-option')
exports.fetchLensOptions = async () => {
  try {
    const query = `
      query getLensProducts {
        products(first: 50, query: "vendor:LensAdvizor OR title:upto") {
          edges {
            node {
              id
              title
              tags
              description
              vendor
              priceRange {
                minVariantPrice {
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
                    price {
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

    const response = await storefrontClient.post('', { query });
    const lensProducts = response.data.data.products.edges.map(edge => edge.node);

    // Organize lens options by type
    const lensOptions = {
      types: [],
      powerTypes: ['Single Vision', 'Progressive', 'Bifocal'],
      antiGlareLenses: [],
      blueBlockLenses: [],
      colourLenses: [],
      lenses: []
    };

    console.log(`Processing ${lensProducts.length} lens products...`);
    
    // Color keywords for identifying colored lenses
    const colorKeywords = ['LIGHT', 'DARK', 'BLACK', 'GREY', 'GRAY', 'BLUE', 'YELLOW', 'BROWN', 'GREEN', 'PINK', 'RED'];
    
    lensProducts.forEach(product => {
      // Extract features from description
      const features = product.description
        ?.split(/[-'\n]/)
        .map(f => f.trim())
        .filter(f => f && f.length > 3 && f.length < 100 && !f.includes('Index:'))
        .slice(0, 5) || [];

      // Extract variants data
      const variants = product.variants?.edges?.map(edge => ({
        id: edge.node.id.replace('gid://shopify/ProductVariant/', ''),
        title: edge.node.title,
        price: edge.node.price.amount,
        available: edge.node.availableForSale
      })) || [];

      // Use first variant ID if product has variants, otherwise use product ID as fallback
      const defaultVariant = variants[0] || { id: product.id.replace('gid://shopify/Product/', '') };

      const lensData = {
        id: defaultVariant.id, // NOW USING VARIANT ID!
        productId: product.id.replace('gid://shopify/Product/', ''),
        name: product.title,
        description: product.description || '',
        price: product.priceRange.minVariantPrice.amount,
        currency: product.priceRange.minVariantPrice.currencyCode,
        features: features,
        vendor: product.vendor || '',
        tags: product.tags || [],
        variants: variants // Include all variants for power range selection
      };

      // Categorize the lens based on features and name
      const nameUpper = product.title.toUpperCase();
      const featuresText = features.join(' ').toLowerCase();
      const isColorLens = colorKeywords.some(keyword => nameUpper.includes(keyword));

      if (isColorLens) {
        // Colour/Tinted lenses (LIGHT BLACK, DARK GREY, etc.)
        lensData.category = 'colour';
        lensOptions.colourLenses.push(lensData);
      } else if (featuresText.includes('blue light')) {
        // Blue block lenses (have "Blue light protection" in features)
        lensData.category = 'blue-block';
        lensOptions.blueBlockLenses.push(lensData);
      } else if (featuresText.includes('anti reflection') || featuresText.includes('uv protect')) {
        // Anti-glare lenses (have "Anti reflection" or basic UV protection)
        lensData.category = 'anti-glare';
        lensOptions.antiGlareLenses.push(lensData);
      } else {
        // Default to anti-glare if uncertain
        lensData.category = 'anti-glare';
        lensOptions.antiGlareLenses.push(lensData);
      }

      lensOptions.lenses.push(lensData);
    });

    console.log(`Successfully organized lenses: ${lensOptions.antiGlareLenses.length} anti-glare, ${lensOptions.blueBlockLenses.length} blue-block, ${lensOptions.colourLenses.length} colour`);
    return lensOptions;
  } catch (error) {
    console.error('Error fetching lens options:', error);
    // Return default lens options if fetch fails
    return {
      types: [
        { id: '1', name: 'Anti-Glare', price: '0', currency: 'INR', features: ['Reduces eye strain', 'Better clarity'] },
        { id: '2', name: 'Blue Cut', price: '300', currency: 'INR', features: ['Blocks blue light', 'Protects eyes'] },
        { id: '3', name: 'Photochromatic', price: '800', currency: 'INR', features: ['Auto-tinting', 'UV protection'] }
      ],
      powerTypes: ['Single Vision', 'Progressive', 'Bifocal'],
      lenses: []
    };
  }
};

function formatCart(cart) {
  if (!cart) {
    return { items: [], total: '0.00', subtotal: '0.00', itemCount: 0 };
  }

  const items = cart.lines?.edges?.map(edge => ({
    id: edge.node.id,
    variantId: edge.node.merchandise.id.replace('gid://shopify/ProductVariant/', ''),
    title: edge.node.merchandise.product.title,
    variantTitle: edge.node.merchandise.title,
    quantity: edge.node.quantity,
    price: edge.node.merchandise.price.amount,
    currency: edge.node.merchandise.price.currencyCode,
    image: edge.node.merchandise.product.images?.edges?.[0]?.node?.url || '',
    properties: edge.node.attributes || []
  })) || [];

  return {
    id: cart.id,
    items,
    total: cart.cost?.totalAmount?.amount || '0.00',
    subtotal: cart.cost?.subtotalAmount?.amount || '0.00',
    currency: cart.cost?.totalAmount?.currencyCode || 'INR',
    itemCount: items.reduce((sum, item) => sum + item.quantity, 0),
    checkoutUrl: cart.checkoutUrl
  };
}

// Gokwik Checkout Integration
exports.createGokwikCheckout = async () => {
  try {
    console.log('🛒 Creating Gokwik checkout...');
    console.log('Current cart ID:', currentCartId);
    
    // Check if cart exists
    if (!currentCartId) {
      console.error('❌ No cart ID found');
      throw new Error('No cart found. Please add items to cart first.');
    }

    // Get current cart
    const cart = await exports.getCart();
    
    console.log('Cart retrieved:', {
      id: cart.id,
      itemCount: cart.itemCount,
      total: cart.total,
      hasCheckoutUrl: !!cart.checkoutUrl
    });
    
    if (!cart || !cart.items || cart.items.length === 0) {
      console.error('❌ Cart is empty');
      throw new Error('Cart is empty. Please add items to cart first.');
    }

    console.log('✅ Cart has', cart.items.length, 'items');

    // Build Gokwik checkout URL
    const GOKWIK_MERCHANT_ID = '19g6iluwldmy4';
    const GOKWIK_ENV = 'prod'; // or 'staging'
    
    // IMPORTANT: Use Shopify's checkout URL directly in WebView
    // This URL has all cart data embedded and Gokwik will intercept it
    const shopifyCheckoutUrl = cart.checkoutUrl;
    
    if (!shopifyCheckoutUrl) {
      console.error('❌ Checkout URL not available in cart');
      throw new Error('Checkout URL not available. Please try again.');
    }
    
    console.log('✅ Using Shopify checkout URL (Gokwik will intercept):', shopifyCheckoutUrl);

    return {
      checkoutUrl: shopifyCheckoutUrl, // Direct Shopify checkout URL with cart data
      merchantId: GOKWIK_MERCHANT_ID,
      environment: GOKWIK_ENV,
      cartId: cart.id,
      totalAmount: cart.total,
      currency: cart.currency,
      itemCount: cart.itemCount
    };
  } catch (error) {
    console.error('❌ Error creating Gokwik checkout:', error.message);
    console.error('Stack:', error.stack);
    throw error;
  }
};

