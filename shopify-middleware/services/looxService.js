const axios = require('axios');

const SHOPIFY_DOMAIN = process.env.SHOPIFY_STORE_DOMAIN;
const ADMIN_TOKEN = process.env.SHOPIFY_ADMIN_ACCESS_TOKEN;
const STOREFRONT_TOKEN = process.env.SHOPIFY_STOREFRONT_ACCESS_TOKEN;
const API_VERSION = process.env.SHOPIFY_API_VERSION;

// Admin API GraphQL client for fetching metafields
const adminGraphQLClient = axios.create({
  baseURL: `https://${SHOPIFY_DOMAIN}/admin/api/${API_VERSION}/graphql.json`,
  headers: {
    'X-Shopify-Access-Token': ADMIN_TOKEN,
    'Content-Type': 'application/json',
  },
});

// Storefront API GraphQL client
const storefrontClient = axios.create({
  baseURL: `https://${SHOPIFY_DOMAIN}/api/${API_VERSION}/graphql.json`,
  headers: {
    'X-Shopify-Storefront-Access-Token': STOREFRONT_TOKEN,
    'Content-Type': 'application/json',
  },
});

/**
 * Parse HTML reviews from Loox metafield
 * @param {string} html - HTML string containing reviews
 * @returns {Array} Array of parsed review objects
 */
function parseLooxReviews(html) {
  if (!html || typeof html !== 'string' || html.trim().length === 0) {
    console.log('⚠️ No HTML content to parse');
    return [];
  }

  console.log(`📄 Parsing Loox reviews HTML (length: ${html.length})`);
  console.log(`📄 HTML preview: ${html.substring(0, 500)}...`);

  const reviews = [];
  
  try {
    // Loox stores reviews in a structured format - try multiple parsing strategies
    
    // Strategy 1: Look for JSON-like structure (common in Loox)
    try {
      const jsonMatch = html.match(/\{.*"reviews".*\}/s);
      if (jsonMatch) {
        const jsonData = JSON.parse(jsonMatch[0]);
        if (jsonData.reviews && Array.isArray(jsonData.reviews)) {
          console.log(`✅ Found JSON structure with ${jsonData.reviews.length} reviews`);
          return jsonData.reviews.map((review, index) => ({
            id: review.id || `review-${index}`,
            name: review.name || review.customer_name || 'Anonymous',
            text: review.text || review.review_text || review.comment || '',
            rating: review.rating || review.stars || null,
            date: review.date || review.created_at || null,
            photos: review.photos || review.images || [],
            isVerified: review.verified || review.is_verified || false,
          }));
        }
      }
    } catch (e) {
      console.log('⚠️ JSON parsing failed, trying HTML parsing...');
    }
    
    // Strategy 2: Extract review blocks with flexible class names
    // Loox uses various class names like "loox-review", "review-item", etc.
    const reviewPatterns = [
      /<div[^>]*class="[^"]*review[^"]*"[^>]*>(.*?)<\/div>/gis,
      /<div[^>]*class="[^"]*loox-review[^"]*"[^>]*>(.*?)<\/div>/gis,
      /<article[^>]*class="[^"]*review[^"]*"[^>]*>(.*?)<\/article>/gis,
    ];
    
    let reviewMatches = [];
    for (const pattern of reviewPatterns) {
      const matches = Array.from(html.matchAll(pattern));
      if (matches.length > 0) {
        reviewMatches = matches;
        console.log(`✅ Found ${matches.length} reviews using pattern`);
        break;
      }
    }
    
    // Strategy 3: If no matches, try to find any structured data
    if (reviewMatches.length === 0) {
      // Look for any divs that might contain review data
      const allDivs = html.match(/<div[^>]*>(.*?)<\/div>/gis);
      if (allDivs && allDivs.length > 0) {
        console.log(`⚠️ Found ${allDivs.length} divs, attempting to parse as reviews`);
        reviewMatches = allDivs.map((m, i) => [m, m]);
      }
    }
    
    reviewMatches.forEach((match, index) => {
      const reviewHtml = match[1] || match[0];
      
      // Extract name - try multiple patterns
      const namePatterns = [
        /<div[^>]*class="[^"]*name[^"]*"[^>]*>(.*?)<\/div>/i,
        /<span[^>]*class="[^"]*customer-name[^"]*"[^>]*>(.*?)<\/span>/i,
        /<h[1-6][^>]*>(.*?)<\/h[1-6]>/i,
        /"name"\s*:\s*"([^"]+)"/i,
        /"customer_name"\s*:\s*"([^"]+)"/i,
      ];
      
      let name = 'Anonymous';
      for (const pattern of namePatterns) {
        const nameMatch = reviewHtml.match(pattern);
        if (nameMatch && nameMatch[1]) {
          name = nameMatch[1].trim().replace(/<[^>]+>/g, '');
          if (name) break;
        }
      }
      
      // Extract review text - try multiple patterns
      const textPatterns = [
        /<div[^>]*class="[^"]*review[^"]*text[^"]*"[^>]*>(.*?)<\/div>/i,
        /<div[^>]*class="[^"]*comment[^"]*"[^>]*>(.*?)<\/div>/i,
        /<p[^>]*>(.*?)<\/p>/i,
        /"text"\s*:\s*"([^"]+)"/i,
        /"comment"\s*:\s*"([^"]+)"/i,
        /"review_text"\s*:\s*"([^"]+)"/i,
      ];
      
      let text = '';
      for (const pattern of textPatterns) {
        const textMatch = reviewHtml.match(pattern);
        if (textMatch && textMatch[1]) {
          text = textMatch[1].trim().replace(/<[^>]+>/g, '').replace(/\\n/g, ' ');
          if (text) break;
        }
      }
      
      // Extract rating
      const ratingPatterns = [
        /data-rating="(\d+)"/i,
        /rating[^>]*>(\d+)/i,
        /"rating"\s*:\s*(\d+)/i,
        /"stars"\s*:\s*(\d+)/i,
        /★{(\d+)}/,
        /(\d+)\s*stars?/i,
      ];
      
      let rating = null;
      for (const pattern of ratingPatterns) {
        const ratingMatch = reviewHtml.match(pattern);
        if (ratingMatch) {
          rating = parseInt(ratingMatch[1]);
          if (rating >= 1 && rating <= 5) break;
        }
      }
      
      // Extract date
      const datePatterns = [
        /<div[^>]*class="[^"]*date[^"]*"[^>]*>(.*?)<\/div>/i,
        /"date"\s*:\s*"([^"]+)"/i,
        /"created_at"\s*:\s*"([^"]+)"/i,
        /(\d{4}-\d{2}-\d{2})/,
      ];
      
      let date = null;
      for (const pattern of datePatterns) {
        const dateMatch = reviewHtml.match(pattern);
        if (dateMatch && dateMatch[1]) {
          date = dateMatch[1].trim().replace(/<[^>]+>/g, '');
          if (date) break;
        }
      }
      
      // Extract photos
      const photoMatches = Array.from(reviewHtml.matchAll(/<img[^>]*src="([^"]+)"[^>]*>/gi));
      const photos = photoMatches.map(m => m[1]).filter(url => url && !url.includes('placeholder'));
      
      // Extract verified badge
      const isVerified = /verified|verified.*purchase/i.test(reviewHtml);
      
      // Only add review if we have at least name or text
      if (name || text) {
        reviews.push({
          id: `review-${index}`,
          name: name || 'Anonymous',
          text: text || 'No review text available',
          rating: rating || null,
          date: date || null,
          photos: photos || [],
          isVerified: isVerified
        });
        console.log(`✅ Parsed review ${index + 1}: ${name}, text length: ${text.length}, rating: ${rating}`);
      }
    });
    
    console.log(`✅ Successfully parsed ${reviews.length} reviews from HTML`);
  
  // If no reviews were parsed but we have HTML, log it for debugging
  if (reviews.length === 0 && html && html.length > 0) {
    console.log(`⚠️ WARNING: No reviews parsed from HTML. HTML length: ${html.length}`);
    console.log(`⚠️ HTML structure sample: ${html.substring(0, 1000)}`);
  }
  } catch (error) {
    console.error('❌ Error parsing Loox reviews HTML:', error);
    console.error('❌ Stack trace:', error.stack);
  }
  
  return reviews;
}

/**
 * Fetch Loox reviews for a product
 * @param {string} productId - Shopify product ID (without gid:// prefix)
 * @returns {Promise<Object>} Reviews data with count, rating, and reviews array
 */
exports.getProductReviews = async (productId) => {
  try {
    console.log(`🔍 Fetching Loox reviews for product: ${productId}`);
    
    // Clean product ID
    let cleanProductId = productId;
    if (cleanProductId.includes('gid://shopify/Product/')) {
      cleanProductId = cleanProductId.replace('gid://shopify/Product/', '');
    }
    
    const query = `
      query getProductLooxReviews($id: ID!) {
        product(id: $id) {
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
    `;

    const response = await adminGraphQLClient.post('', {
      query,
      variables: { id: `gid://shopify/Product/${cleanProductId}` }
    });

    if (!response.data || !response.data.data || !response.data.data.product) {
      throw new Error('Product not found');
    }

    const product = response.data.data.product;
    const metafields = product.metafields.edges.map(edge => edge.node);
    
    console.log(`📦 Found ${metafields.length} Loox metafields for product ${product.title}`);
    console.log(`📦 Metafield keys: ${metafields.map(mf => mf.key).join(', ')}`);
    
    // Extract Loox metafields - try multiple possible keys
    const numReviewsField = metafields.find(mf => mf.key === 'num_reviews');
    const avgRatingField = metafields.find(mf => mf.key === 'avg_rating');
    
    // Try multiple possible keys for reviews data
    const reviewsField = metafields.find(mf => 
      mf.key === 'reviews' || 
      mf.key === 'reviews_json' || 
      mf.key === 'review_data' ||
      mf.key === 'all_reviews' ||
      mf.key === 'reviews_data' ||
      mf.key === 'loox_reviews'
    );
    
    const numReviews = numReviewsField ? parseInt(numReviewsField.value) || 0 : 0;
    const avgRating = avgRatingField ? parseFloat(avgRatingField.value) || 0 : 0;
    
    console.log(`📊 Review stats - Count: ${numReviews}, Rating: ${avgRating}`);
    
    let reviewsHtml = '';
    let reviewsData = null;
    
    if (reviewsField) {
      console.log(`✅ Found reviews field: ${reviewsField.key} (type: ${reviewsField.type})`);
      console.log(`📄 Reviews field value length: ${reviewsField.value?.length || 0}`);
      console.log(`📄 Reviews field preview: ${reviewsField.value?.substring(0, 200) || 'empty'}...`);
      
      // Check if it's JSON
      if (reviewsField.type === 'json' || reviewsField.value?.trim().startsWith('{') || reviewsField.value?.trim().startsWith('[')) {
        try {
          reviewsData = JSON.parse(reviewsField.value);
          console.log(`✅ Parsed reviews as JSON - Type: ${Array.isArray(reviewsData) ? 'Array' : typeof reviewsData}`);
          if (Array.isArray(reviewsData)) {
            console.log(`✅ Found ${reviewsData.length} reviews in JSON array`);
          } else if (reviewsData.reviews && Array.isArray(reviewsData.reviews)) {
            console.log(`✅ Found ${reviewsData.reviews.length} reviews in JSON object`);
          }
        } catch (e) {
          console.log(`⚠️ Failed to parse as JSON, treating as HTML: ${e.message}`);
          reviewsHtml = reviewsField.value;
        }
      } else {
        reviewsHtml = reviewsField.value;
      }
    } else {
      console.log(`⚠️ No reviews metafield found. Available keys: ${metafields.map(mf => mf.key).join(', ')}`);
    }
    
    let reviews = [];
    
    // If we have JSON data, use it directly
    if (reviewsData) {
      if (Array.isArray(reviewsData)) {
        reviews = reviewsData.map((review, index) => ({
          id: review.id || review.review_id || `review-${index}`,
          name: review.name || review.customer_name || review.customer?.name || 'Anonymous',
          text: review.text || review.review_text || review.comment || review.message || '',
          rating: review.rating || review.stars || review.score || null,
          date: review.date || review.created_at || review.review_date || null,
          photos: review.photos || review.images || review.photo_urls || [],
          isVerified: review.verified || review.is_verified || review.verified_purchase || false,
        }));
      } else if (reviewsData.reviews && Array.isArray(reviewsData.reviews)) {
        reviews = reviewsData.reviews.map((review, index) => ({
          id: review.id || review.review_id || `review-${index}`,
          name: review.name || review.customer_name || review.customer?.name || 'Anonymous',
          text: review.text || review.review_text || review.comment || review.message || '',
          rating: review.rating || review.stars || review.score || null,
          date: review.date || review.created_at || review.review_date || null,
          photos: review.photos || review.images || review.photo_urls || [],
          isVerified: review.verified || review.is_verified || review.verified_purchase || false,
        }));
      }
    }
    
    // If no reviews from JSON, try parsing HTML
    if (reviews.length === 0 && reviewsHtml) {
      reviews = parseLooxReviews(reviewsHtml);
    }
    
    console.log(`✅ Final result - Parsed ${reviews.length} reviews from ${numReviews} total`);
    
    return {
      productId: cleanProductId,
      productTitle: product.title,
      productHandle: product.handle,
      count: numReviews,
      averageRating: avgRating,
      reviews: reviews
    };
  } catch (error) {
    console.error('Error fetching Loox reviews:', error.message);
    throw error;
  }
};

/**
 * Get review counts for multiple products (for collection screen)
 * @param {Array<string>} productIds - Array of Shopify product IDs
 * @returns {Promise<Object>} Map of productId -> review count and rating
 */
exports.getBulkReviewCounts = async (productIds) => {
  try {
    console.log(`🔍 Fetching review counts for ${productIds.length} products`);
    
    // Clean product IDs
    const cleanIds = productIds.map(id => {
      if (id.includes('gid://shopify/Product/')) {
        return id.replace('gid://shopify/Product/', '');
      }
      return id;
    });
    
    // Fetch in batches (Shopify GraphQL has limits)
    const batchSize = 10;
    const results = {};
    
    for (let i = 0; i < cleanIds.length; i += batchSize) {
      const batch = cleanIds.slice(i, i + batchSize);
      
      const query = `
        query getBulkLooxReviews($ids: [ID!]!) {
          nodes(ids: $ids) {
            ... on Product {
              id
              metafields(first: 10, namespace: "loox") {
                edges {
                  node {
                    key
                    value
                  }
                }
              }
            }
          }
        }
      `;

      const ids = batch.map(id => `gid://shopify/Product/${id}`);
      
      const response = await adminGraphQLClient.post('', {
        query,
        variables: { ids }
      });

      if (response.data && response.data.data && response.data.data.nodes) {
        response.data.data.nodes.forEach((node, index) => {
          if (node && node.metafields) {
            const metafields = node.metafields.edges.map(edge => edge.node);
            const numReviewsField = metafields.find(mf => mf.key === 'num_reviews');
            const avgRatingField = metafields.find(mf => mf.key === 'avg_rating');
            
            const productId = batch[index];
            results[productId] = {
              count: numReviewsField ? parseInt(numReviewsField.value) || 0 : 0,
              rating: avgRatingField ? parseFloat(avgRatingField.value) || 0 : 0
            };
          }
        });
      }
    }
    
    console.log(`✅ Fetched review counts for ${Object.keys(results).length} products`);
    return results;
  } catch (error) {
    console.error('Error fetching bulk review counts:', error.message);
    // Return empty results instead of throwing
    return {};
  }
};

/**
 * Get review count for a single product (lightweight)
 * @param {string} productId - Shopify product ID
 * @returns {Promise<Object>} Review count and rating
 */
exports.getProductReviewCount = async (productId) => {
  try {
    let cleanProductId = productId;
    if (cleanProductId.includes('gid://shopify/Product/')) {
      cleanProductId = cleanProductId.replace('gid://shopify/Product/', '');
    }
    
    const query = `
      query getProductReviewCount($id: ID!) {
        product(id: $id) {
          id
          metafields(first: 10, namespace: "loox") {
            edges {
              node {
                key
                value
              }
            }
          }
        }
      }
    `;

    const response = await adminGraphQLClient.post('', {
      query,
      variables: { id: `gid://shopify/Product/${cleanProductId}` }
    });

    if (!response.data || !response.data.data || !response.data.data.product) {
      return { count: 0, rating: 0 };
    }

    const product = response.data.data.product;
    const metafields = product.metafields.edges.map(edge => edge.node);
    
    const numReviewsField = metafields.find(mf => mf.key === 'num_reviews');
    const avgRatingField = metafields.find(mf => mf.key === 'avg_rating');
    
    return {
      count: numReviewsField ? parseInt(numReviewsField.value) || 0 : 0,
      rating: avgRatingField ? parseFloat(avgRatingField.value) || 0 : 0
    };
  } catch (error) {
    console.error('Error fetching review count:', error.message);
    return { count: 0, rating: 0 };
  }
};

