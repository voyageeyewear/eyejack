const axios = require('axios');
require('dotenv').config();

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

async function inspectLooxMetafields() {
  try {
    console.log('🔍 Inspecting Loox metafields in Shopify store...\n');

    // Step 1: Fetch some products to find ones with Loox reviews
    console.log('📦 Fetching products with Loox data...');
    
    const storefrontQuery = `
      query getProductsWithLoox {
        products(first: 10) {
          edges {
            node {
              id
              title
              handle
              metafields(identifiers: [
                { namespace: "loox", key: "num_reviews" },
                { namespace: "loox", key: "avg_rating" },
                { namespace: "loox", key: "reviews" },
                { namespace: "loox", key: "reviews_json" },
                { namespace: "loox", key: "review_data" },
                { namespace: "loox", key: "all_reviews" },
                { namespace: "loox", key: "reviews_data" }
              ]) {
                namespace
                key
                value
                type
              }
            }
          }
        }
      }
    `;

    const storefrontResponse = await storefrontClient.post('', {
      query: storefrontQuery
    });

    const products = storefrontResponse.data.data.products.edges.map(edge => edge.node);
    
    console.log(`\n✅ Found ${products.length} products\n`);

    // Analyze each product's Loox metafields
    let foundReviews = false;
    
    for (const product of products) {
      if (product.metafields && product.metafields.length > 0) {
        const looxMetafields = product.metafields.filter(mf => mf && mf.namespace === 'loox');
        
        if (looxMetafields.length > 0) {
          console.log(`\n📦 Product: ${product.title}`);
          console.log(`   Handle: ${product.handle}`);
          console.log(`   Product ID: ${product.id}`);
          console.log(`   Loox Metafields found: ${looxMetafields.length}\n`);
          
          looxMetafields.forEach(mf => {
            console.log(`   └─ ${mf.key} (${mf.type}):`);
            
            // Try to parse JSON if it's a complex type
            if (mf.value && (mf.type === 'json' || mf.value.startsWith('{'))) {
              try {
                const parsed = JSON.parse(mf.value);
                console.log(`      Type: ${typeof parsed}`);
                if (Array.isArray(parsed)) {
                  console.log(`      Array length: ${parsed.length}`);
                  if (parsed.length > 0) {
                    console.log(`      First item keys: ${Object.keys(parsed[0]).join(', ')}`);
                    console.log(`      Sample: ${JSON.stringify(parsed[0], null, 6).substring(0, 200)}...`);
                  }
                } else if (typeof parsed === 'object') {
                  console.log(`      Object keys: ${Object.keys(parsed).join(', ')}`);
                  console.log(`      Sample: ${JSON.stringify(parsed, null, 6).substring(0, 300)}...`);
                } else {
                  console.log(`      Value: ${mf.value.substring(0, 100)}...`);
                }
              } catch (e) {
                console.log(`      Value: ${mf.value.substring(0, 100)}...`);
              }
            } else {
              console.log(`      Value: ${mf.value}`);
            }
            console.log('');
          });
          
          foundReviews = true;
          
          // Stop after finding first product with reviews for detailed inspection
          break;
        }
      }
    }

    // Step 2: Use Admin API to get ALL metafields for a product (more comprehensive)
    console.log('\n\n🔍 Using Admin API to get all Loox metafields for a product...\n');
    
    const adminQuery = `
      query getProductMetafields($first: Int!) {
        products(first: $first) {
          edges {
            node {
              id
              title
              handle
              metafields(first: 50, namespace: "loox") {
                edges {
                  node {
                    namespace
                    key
                    value
                    type
                    description
                  }
                }
              }
            }
          }
        }
      }
    `;

    // Admin API uses GraphQL endpoint
    const adminGraphQLClient = axios.create({
      baseURL: `https://${SHOPIFY_DOMAIN}/admin/api/${API_VERSION}/graphql.json`,
      headers: {
        'X-Shopify-Access-Token': ADMIN_TOKEN,
        'Content-Type': 'application/json',
      },
    });

    const adminResponse = await adminGraphQLClient.post('', {
      query: adminQuery,
      variables: { first: 20 }
    });

    const adminProducts = adminResponse.data.data.products.edges.map(edge => edge.node);
    
    console.log(`✅ Admin API found ${adminProducts.length} products\n`);

    // Find products with Loox metafields
    for (const product of adminProducts) {
      if (product.metafields && product.metafields.edges && product.metafields.edges.length > 0) {
        const looxMetafields = product.metafields.edges
          .map(edge => edge.node)
          .filter(mf => mf.namespace === 'loox');
        
        if (looxMetafields.length > 0) {
          console.log(`\n📦 Product: ${product.title}`);
          console.log(`   Handle: ${product.handle}`);
          console.log(`   Product ID: ${product.id}`);
          console.log(`   Loox Metafields (Admin API): ${looxMetafields.length}\n`);
          
          looxMetafields.forEach(mf => {
            console.log(`   └─ ${mf.key}`);
            console.log(`      Type: ${mf.type}`);
            if (mf.description) {
              console.log(`      Description: ${mf.description}`);
            }
            
            // Try to parse and display structure
            if (mf.value) {
              try {
                const parsed = JSON.parse(mf.value);
                console.log(`      Parsed structure:`);
                console.log(`      ${JSON.stringify(parsed, null, 8).substring(0, 500)}...`);
              } catch (e) {
                console.log(`      Value: ${mf.value.substring(0, 200)}...`);
              }
            }
            console.log('');
          });
          
          // Stop after first detailed product
          break;
        }
      }
    }

    // Step 3: Check if there's a specific Loox API endpoint or collection
    console.log('\n\n🔍 Checking for Loox-specific collections or resources...\n');
    
    const collectionsQuery = `
      query getCollections {
        collections(first: 20) {
          edges {
            node {
              id
              title
              handle
            }
          }
        }
      }
    `;

    const collectionsResponse = await storefrontClient.post('', {
      query: collectionsQuery
    });

    const collections = collectionsResponse.data.data.collections.edges.map(edge => edge.node);
    const looxCollection = collections.find(c => 
      c.handle.toLowerCase().includes('loox') || 
      c.title.toLowerCase().includes('loox') ||
      c.title.toLowerCase().includes('review')
    );
    
    if (looxCollection) {
      console.log(`✅ Found potential Loox collection: ${looxCollection.title} (${looxCollection.handle})`);
    } else {
      console.log('ℹ️  No obvious Loox-specific collection found');
    }

    console.log('\n\n✅ Inspection complete!\n');

  } catch (error) {
    console.error('❌ Error inspecting Loox metafields:', error.message);
    if (error.response) {
      console.error('Response data:', JSON.stringify(error.response.data, null, 2));
    }
    console.error('Stack:', error.stack);
  }
}

// Run the inspection
inspectLooxMetafields();

