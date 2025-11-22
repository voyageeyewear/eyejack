const axios = require('axios');
require('dotenv').config();

const SHOPIFY_DOMAIN = process.env.SHOPIFY_STORE_DOMAIN;
const ADMIN_TOKEN = process.env.SHOPIFY_ADMIN_ACCESS_TOKEN;
const API_VERSION = process.env.SHOPIFY_API_VERSION;

// Admin API GraphQL client
const adminGraphQLClient = axios.create({
  baseURL: `https://${SHOPIFY_DOMAIN}/admin/api/${API_VERSION}/graphql.json`,
  headers: {
    'X-Shopify-Access-Token': ADMIN_TOKEN,
    'Content-Type': 'application/json',
  },
});

async function parseLooxReviews() {
  try {
    console.log('🔍 Parsing Loox reviews structure...\n');

    // Get a product with reviews
    const query = `
      query getProductWithLooxReviews($first: Int!) {
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
                  }
                }
              }
            }
          }
        }
      }
    `;

    const response = await adminGraphQLClient.post('', {
      query,
      variables: { first: 20 }
    });

    const products = response.data.data.products.edges.map(edge => edge.node);
    
    // Find product with reviews
    let productWithReviews = null;
    for (const product of products) {
      if (product.metafields && product.metafields.edges) {
        const reviewsField = product.metafields.edges
          .map(edge => edge.node)
          .find(mf => mf.key === 'reviews' && mf.namespace === 'loox');
        
        if (reviewsField && reviewsField.value) {
          productWithReviews = product;
          console.log(`📦 Found product with reviews: ${product.title}\n`);
          console.log(`   Product ID: ${product.id}`);
          console.log(`   Handle: ${product.handle}\n`);
          
          // Get all Loox metafields
          const looxMetafields = product.metafields.edges.map(edge => edge.node);
          
          looxMetafields.forEach(mf => {
            console.log(`   ${mf.key}:`);
            if (mf.key === 'reviews') {
              // Parse HTML to extract review data
              const html = mf.value;
              console.log(`      Type: ${mf.type}`);
              console.log(`      HTML Length: ${html.length} characters\n`);
              
              // Try to extract review data from HTML
              console.log(`      Raw HTML sample (first 500 chars):`);
              console.log(`      ${html.substring(0, 500)}...\n`);
              
              // Look for data attributes
              const dataLooxHash = html.match(/data-loox-hash="([^"]+)"/);
              if (dataLooxHash) {
                console.log(`      Found Loox hash: ${dataLooxHash[1]}\n`);
              }
              
              // Try to extract individual reviews
              const reviewMatches = html.matchAll(/<div class="review">(.*?)<\/div>\s*(?=<div class="review">|<\/div>)/gs);
              const reviews = Array.from(reviewMatches);
              
              if (reviews.length > 0) {
                console.log(`      Found ${reviews.length} reviews in HTML\n`);
                
                // Parse first review in detail
                const firstReview = reviews[0][1];
                console.log(`      First review HTML:`);
                console.log(`      ${firstReview.substring(0, 300)}...\n`);
                
                // Try to extract name, rating, text, date
                const nameMatch = firstReview.match(/<div class="name">(.*?)<\/div>/);
                const textMatch = firstReview.match(/<div class="review_text">(.*?)<\/div>/);
                const ratingMatch = firstReview.match(/data-rating="(\d+)"/);
                const dateMatch = firstReview.match(/<div class="date">(.*?)<\/div>/);
                const photoMatch = firstReview.match(/<img[^>]*src="([^"]+)"/);
                
                console.log(`      Extracted review data:`);
                if (nameMatch) console.log(`        Name: ${nameMatch[1]}`);
                if (ratingMatch) console.log(`        Rating: ${ratingMatch[1]} stars`);
                if (textMatch) console.log(`        Text: ${textMatch[1].substring(0, 100)}...`);
                if (dateMatch) console.log(`        Date: ${dateMatch[1]}`);
                if (photoMatch) console.log(`        Photo: ${photoMatch[1]}`);
              }
              
              // Check if there's JSON embedded
              const jsonMatch = html.match(/<script[^>]*>(.*?)<\/script>/s);
              if (jsonMatch) {
                console.log(`\n      Found script tag, checking for JSON...`);
                try {
                  const jsonData = JSON.parse(jsonMatch[1]);
                  console.log(`      JSON data structure:`);
                  console.log(JSON.stringify(jsonData, null, 6).substring(0, 1000));
                } catch (e) {
                  console.log(`      Script content doesn't appear to be JSON`);
                }
              }
            } else {
              console.log(`      Value: ${mf.value}\n`);
            }
          });
          
          break;
        }
      }
    }

    if (!productWithReviews) {
      console.log('⚠️  No product with Loox reviews found');
      return;
    }

    // Also check if Loox stores reviews via REST API endpoint
    console.log('\n\n🔍 Checking for alternative Loox data sources...\n');
    console.log('ℹ️  Loox may also expose reviews via:');
    console.log('   - Direct Loox API (requires Loox API key)');
    console.log('   - Product reviews in separate Shopify metafield');
    console.log('   - External Loox widget that loads via JavaScript\n');

    console.log('✅ Analysis complete!\n');
    console.log('📝 Summary:');
    console.log('   - Loox stores reviews in `loox.reviews` metafield as HTML');
    console.log('   - Each review is in a `<div class="review">` tag');
    console.log('   - Review data includes: name, rating, text, date, photos');
    console.log('   - Can be parsed from HTML structure\n');

  } catch (error) {
    console.error('❌ Error parsing Loox reviews:', error.message);
    if (error.response) {
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    }
    console.error('Stack:', error.stack);
  }
}

parseLooxReviews();

