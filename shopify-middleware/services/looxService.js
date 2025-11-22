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
  if (!html || typeof html !== 'string') {
    return [];
  }

  const reviews = [];
  
  try {
    // Extract all review divs
    const reviewRegex = /<div class="review">(.*?)<\/div>\s*(?=<div class="review">|<\/div>)/gs;
    const reviewMatches = Array.from(html.matchAll(reviewRegex));
    
    reviewMatches.forEach((match, index) => {
      const reviewHtml = match[1];
      
      // Extract name
      const nameMatch = reviewHtml.match(/<div class="name">(.*?)<\/div>/);
      const name = nameMatch ? nameMatch[1].trim() : 'Anonymous';
      
      // Extract review text
      const textMatch = reviewHtml.match(/<div class="review_text">(.*?)<\/div>/);
      const text = textMatch ? textMatch[1].trim() : '';
      
      // Extract rating (if available)
      const ratingMatch = reviewHtml.match(/data-rating="(\d+)"/) || 
                          reviewHtml.match(/rating[^>]*>(\d+)/) ||
                          reviewHtml.match(/<div class="rating">(.*?)<\/div>/);
      let rating = null;
      if (ratingMatch) {
        const ratingValue = parseInt(ratingMatch[1]) || 
                           (ratingMatch[1].includes('★') ? ratingMatch[1].split('★').length - 1 : null);
        if (ratingValue && ratingValue >= 1 && ratingValue <= 5) {
          rating = ratingValue;
        }
      }
      
      // Extract date (if available)
      const dateMatch = reviewHtml.match(/<div class="date">(.*?)<\/div>/);
      const date = dateMatch ? dateMatch[1].trim() : null;
      
      // Extract photos (if available)
      const photoMatches = reviewHtml.matchAll(/<img[^>]*src="([^"]+)"[^>]*>/g);
      const photos = Array.from(photoMatches).map(m => m[1]);
      
      // Extract verified purchase badge (if available)
      const verifiedMatch = reviewHtml.match(/verified|verified.*purchase/i);
      const isVerified = !!verifiedMatch;
      
      if (name && text) {
        reviews.push({
          id: `review-${index}`,
          name,
          text,
          rating: rating || null,
          date: date || null,
          photos: photos.length > 0 ? photos : [],
          isVerified: isVerified
        });
      }
    });
  } catch (error) {
    console.error('Error parsing Loox reviews HTML:', error);
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
    
    // Extract Loox metafields
    const numReviewsField = metafields.find(mf => mf.key === 'num_reviews');
    const avgRatingField = metafields.find(mf => mf.key === 'avg_rating');
    const reviewsField = metafields.find(mf => mf.key === 'reviews');
    
    const numReviews = numReviewsField ? parseInt(numReviewsField.value) || 0 : 0;
    const avgRating = avgRatingField ? parseFloat(avgRatingField.value) || 0 : 0;
    const reviewsHtml = reviewsField ? reviewsField.value : '';
    
    // Parse reviews from HTML
    const reviews = parseLooxReviews(reviewsHtml);
    
    console.log(`✅ Found ${reviews.length} parsed reviews (${numReviews} total)`);
    
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

