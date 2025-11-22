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
            name: review.name || review.customer_name || review.customer?.name || 'Anonymous',
            text: review.text || review.review_text || review.comment || review.message || '',
            rating: review.rating || review.stars || review.score || null,
            date: review.date || review.created_at || review.review_date || null,
            photos: review.photos || review.images || review.photo_urls || [],
            isVerified: review.verified || review.is_verified || review.verified_purchase || false,
            profilePicture: review.profilePicture || review.profile_picture || review.avatar || review.customer?.avatar || null,
            videoUrl: review.videoUrl || review.video_url || review.video || null,
            productImage: review.productImage || review.product_image || review.product?.image || null,
            productName: review.productName || review.product_name || review.product?.name || null,
          }));
        }
      }
    } catch (e) {
      console.log('⚠️ JSON parsing failed, trying HTML parsing...');
    }
    
    // Strategy 2: Extract review blocks with Loox-specific class names
    // Use cleanHtml (without CSS/scripts) for parsing
    const reviewPatterns = [
      /<div[^>]*class="[^"]*loox-review-item[^"]*"[^>]*>([\s\S]*?)<\/div>/gi,
      /<div[^>]*class="[^"]*review-item[^"]*"[^>]*>([\s\S]*?)<\/div>/gi,
      /<article[^>]*class="[^"]*loox-review[^"]*"[^>]*>([\s\S]*?)<\/article>/gi,
      /<div[^>]*class="[^"]*review-card[^"]*"[^>]*>([\s\S]*?)<\/div>/gi,
      /<div[^>]*data-loox-review[^>]*>([\s\S]*?)<\/div>/gi,
      // Fallback: any div with review in class
      /<div[^>]*class="[^"]*review[^"]*"[^>]*>([\s\S]*?)<\/div>/gi,
    ];
    
    let reviewMatches = [];
    for (const pattern of reviewPatterns) {
      const matches = Array.from(cleanHtml.matchAll(pattern));
      if (matches.length > 0) {
        reviewMatches = matches;
        console.log(`✅ Found ${matches.length} reviews using pattern`);
        break;
      }
    }
    
    // Strategy 3: If no matches, the widget might be using a different structure
    // Check if there's an iframe or if reviews are loaded via JavaScript
    if (reviewMatches.length === 0) {
      console.log(`⚠️ No review blocks found. Widget might use iframe or dynamic loading.`);
      // Don't try to parse all divs - that would be too noisy
      // Return empty and let it fall back to metafields
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
      
      let name = '';
      for (const pattern of namePatterns) {
        const nameMatch = reviewHtml.match(pattern);
        if (nameMatch && nameMatch[1]) {
          const extractedName = nameMatch[1].trim().replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').replace(/\s+/g, ' ').trim();
          if (extractedName && extractedName.length > 0) {
            name = extractedName;
            break;
          }
        }
      }
      
      // Try to extract from any strong/bold tags (common in review names)
      if (!name) {
        const strongMatch = reviewHtml.match(/<strong[^>]*>(.*?)<\/strong>/i);
        if (strongMatch && strongMatch[1]) {
          name = strongMatch[1].trim().replace(/<[^>]+>/g, '').trim();
        }
      }
      
      // Try extracting from any text before first colon or dash (common pattern)
      if (!name) {
        const textContent = reviewHtml.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
        const colonMatch = textContent.match(/^([^:]+?):/);
        if (colonMatch && colonMatch[1] && colonMatch[1].trim().length > 0 && colonMatch[1].trim().length < 50) {
          name = colonMatch[1].trim();
        }
      }
      
      // Extract review text - try multiple patterns
      const textPatterns = [
        /<div[^>]*class="[^"]*review[^"]*text[^"]*"[^>]*>(.*?)<\/div>/i,
        /<div[^>]*class="[^"]*comment[^"]*"[^>]*>(.*?)<\/div>/i,
        /<p[^>]*class="[^"]*review[^"]*"[^>]*>(.*?)<\/p>/i,
        /<p[^>]*>(.*?)<\/p>/i,
        /"text"\s*:\s*"([^"]+)"/i,
        /"comment"\s*:\s*"([^"]+)"/i,
        /"review_text"\s*:\s*"([^"]+)"/i,
      ];
      
      let text = '';
      for (const pattern of textPatterns) {
        const textMatch = reviewHtml.match(pattern);
        if (textMatch && textMatch[1]) {
          let extractedText = textMatch[1].trim()
            .replace(/<[^>]+>/g, ' ') // Remove HTML tags
            .replace(/&nbsp;/g, ' ')
            .replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, '"')
            .replace(/\\n/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();
          
          // Filter out CSS code patterns
          if (extractedText.includes('cursor:') || 
              extractedText.includes('background-color:') || 
              extractedText.includes('@media') || 
              extractedText.includes('rgba(') ||
              extractedText.includes('border-radius:') ||
              extractedText.includes('pointer-events:') ||
              extractedText.match(/^[a-z-]+:\s*[^;]+;?\s*$/i)) { // CSS property pattern
            console.log(`⚠️ Skipping text - looks like CSS: ${extractedText.substring(0, 50)}`);
            continue; // Skip this match, try next pattern
          }
          
          if (extractedText && extractedText.length > 3) { // Reduced minimum length
            text = extractedText;
            break;
          }
        }
      }
      
      // If no text found, try extracting all text content from the HTML
      if (!text) {
        const textContent = reviewHtml.replace(/<[^>]+>/g, ' ')
          .replace(/&nbsp;/g, ' ')
          .replace(/&amp;/g, '&')
          .replace(/\s+/g, ' ')
          .trim();
        
        // Don't remove name from text - sometimes the text IS just a name like "Sandeep .."
        // This is valid review text (customer just wrote their name)
        text = textContent;
        
        // Filter out obvious non-review content
        if (text.length < 2 || 
            text === 'Anonymous' || 
            text.toLowerCase().includes('no review') ||
            text.match(/^review\s+\d+$/i)) {
          text = '';
        }
      }
      
      // Fix name/text confusion:
      // If text is very short (like "Sandeep .." or "Darshan D."), it might actually be the name
      // Only extract as name if we DON'T have a name yet and text is clearly a name pattern
      if (!name && text) {
        const namePattern = /^([A-Z][a-z]+(?:\s+[A-Z]\.?)?)\s*\.{0,2}\s*$/;
        const nameMatch = text.match(namePattern);
        if (nameMatch && nameMatch[1] && nameMatch[1].length < 30 && nameMatch[1].length > 2) {
          // Text is just a name, extract it
          name = nameMatch[1].trim();
          text = ''; // Clear text since it was just the name
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
      
      // Extract photos (user-submitted photos)
      const photoMatches = Array.from(reviewHtml.matchAll(/<img[^>]*src="([^"]+)"[^>]*>/gi));
      const photos = photoMatches.map(m => m[1]).filter(url => {
        if (!url) return false;
        // Filter out placeholders, avatars, and profile pictures
        const lowerUrl = url.toLowerCase();
        return !lowerUrl.includes('placeholder') && 
               !lowerUrl.includes('avatar') && 
               !lowerUrl.includes('profile') &&
               !lowerUrl.includes('default');
      });
      
      // Extract profile picture/avatar
      let profilePicture = null;
      const profilePatterns = [
        /<img[^>]*class="[^"]*avatar[^"]*"[^>]*src="([^"]+)"/i,
        /<img[^>]*class="[^"]*profile[^"]*"[^>]*src="([^"]+)"/i,
        /<img[^>]*class="[^"]*customer[^"]*"[^>]*src="([^"]+)"/i,
        /"avatar"\s*:\s*"([^"]+)"/i,
        /"profile_picture"\s*:\s*"([^"]+)"/i,
        /"profilePicture"\s*:\s*"([^"]+)"/i,
        /"customer_image"\s*:\s*"([^"]+)"/i,
      ];
      
      for (const pattern of profilePatterns) {
        const match = reviewHtml.match(pattern);
        if (match && match[1]) {
          profilePicture = match[1].trim();
          break;
        }
      }
      
      // If no profile picture found, try to get first image that's not in photos
      if (!profilePicture && photoMatches.length > 0) {
        const firstImage = photoMatches[0][1];
        if (firstImage && !photos.includes(firstImage)) {
          profilePicture = firstImage;
        }
      }
      
      // Extract video URL
      let videoUrl = null;
      const videoPatterns = [
        /<video[^>]*src="([^"]+)"/i,
        /<iframe[^>]*src="([^"]+)"[^>]*youtube/i,
        /<iframe[^>]*src="([^"]+)"[^>]*vimeo/i,
        /"video_url"\s*:\s*"([^"]+)"/i,
        /"videoUrl"\s*:\s*"([^"]+)"/i,
        /"video"\s*:\s*"([^"]+)"/i,
        /data-video="([^"]+)"/i,
      ];
      
      for (const pattern of videoPatterns) {
        const match = reviewHtml.match(pattern);
        if (match && match[1]) {
          videoUrl = match[1].trim();
          break;
        }
      }
      
      // Extract product image and name
      let productImage = null;
      let productName = null;
      
      const productImagePatterns = [
        /<img[^>]*class="[^"]*product[^"]*"[^>]*src="([^"]+)"/i,
        /"product_image"\s*:\s*"([^"]+)"/i,
        /"productImage"\s*:\s*"([^"]+)"/i,
      ];
      
      for (const pattern of productImagePatterns) {
        const match = reviewHtml.match(pattern);
        if (match && match[1]) {
          productImage = match[1].trim();
          break;
        }
      }
      
      const productNamePatterns = [
        /<div[^>]*class="[^"]*product[^"]*name[^"]*"[^>]*>(.*?)<\/div>/i,
        /"product_name"\s*:\s*"([^"]+)"/i,
        /"productName"\s*:\s*"([^"]+)"/i,
      ];
      
      for (const pattern of productNamePatterns) {
        const match = reviewHtml.match(pattern);
        if (match && match[1]) {
          productName = match[1].trim().replace(/<[^>]+>/g, '').trim();
          break;
        }
      }
      
      // Extract verified badge
      const isVerified = /verified|verified.*purchase/i.test(reviewHtml);
      
      // IMPORTANT: Don't extract name from text - this causes confusion
      // Names should come from proper name fields, not from review text
      // The text might start with a name like "Sandeep .." but that's part of the review text
      
      // Only add review if we have actual content (not just defaults)
      // Check if name is not 'Anonymous' and text is not empty/default
      const hasActualName = name && name !== 'Anonymous' && name.trim().length > 0;
      const hasActualText = text && text !== 'No review text available' && text.trim().length > 0;
      
      if (hasActualName || hasActualText || profilePicture || videoUrl || photos.length > 0) {
        reviews.push({
          id: `review-${index}`,
          name: name || 'Anonymous',
          text: text || '',
          rating: rating || null,
          date: date || null,
          photos: photos || [],
          isVerified: isVerified,
          profilePicture: profilePicture || null,
          videoUrl: videoUrl || null,
          productImage: productImage || null,
          productName: productName || null,
        });
        console.log(`✅ Parsed review ${index + 1}: ${name}, text: ${text.substring(0, 50)}..., rating: ${rating}, profilePic: ${!!profilePicture}, video: ${!!videoUrl}, photos: ${photos.length}`);
      } else {
        console.log(`⚠️ Skipping review ${index + 1} - no actual content found. HTML sample: ${reviewHtml.substring(0, 200)}`);
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
 * Fetch Loox reviews directly from Loox widget endpoint
 * Loox loads reviews in an iframe, so we need to fetch the widget HTML and parse it
 * @param {string} productId - Shopify product ID (without gid:// prefix)
 * @returns {Promise<Object>} Reviews data with count, rating, and reviews array
 */
async function fetchLooxReviewsFromWidget(productId) {
  try {
    const LOOX_MERCHANT_ID = 'PmGdDSBYpW'; // Your Loox merchant/widget ID from website
    const reviewsUrl = `https://loox.io/widget/${LOOX_MERCHANT_ID}/reviews/${productId}?limit=50`;
    
    console.log(`🌐 Fetching reviews from Loox widget: ${reviewsUrl}`);
    
    const response = await axios.get(reviewsUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://eyejack.in/',
      },
      timeout: 15000,
    });
    
    if (response.data) {
      console.log(`✅ Got response from Loox widget (length: ${response.data.length})`);
      
      // Try to extract JSON from script tags first
      const jsonPatterns = [
        /window\.looxReviews\s*=\s*({[\s\S]*?});/,
        /window\.looxData\s*=\s*({[\s\S]*?});/,
        /var\s+looxReviews\s*=\s*({[\s\S]*?});/,
        /<script[^>]*type="application\/json"[^>]*>([\s\S]*?)<\/script>/,
        /<script[^>]*id="loox-data"[^>]*>([\s\S]*?)<\/script>/,
      ];
      
      for (const pattern of jsonPatterns) {
        const match = response.data.match(pattern);
        if (match && match[1]) {
          try {
            const jsonData = JSON.parse(match[1]);
            console.log(`✅ Found JSON data in script tag`);
            return jsonData;
          } catch (e) {
            console.log(`⚠️ Failed to parse JSON: ${e.message}`);
          }
        }
      }
      
      // If no JSON found, parse HTML
      console.log(`📄 No JSON found, parsing HTML structure...`);
      console.log(`📄 HTML preview (first 1000 chars): ${response.data.substring(0, 1000)}`);
      
      // Check if response is actually HTML or if it's an error page
      if (response.data.includes('<!DOCTYPE') || response.data.includes('<html')) {
        console.log(`📄 This is an HTML page, extracting review data...`);
        const reviews = parseLooxReviews(response.data);
        
        if (reviews && reviews.length > 0) {
          console.log(`✅ Parsed ${reviews.length} reviews from HTML`);
          return {
            reviews: reviews,
            count: reviews.length,
            averageRating: reviews.reduce((sum, r) => sum + (r.rating || 0), 0) / reviews.length || 0
          };
        } else {
          console.log(`⚠️ No reviews parsed from HTML. HTML might be an iframe wrapper.`);
          // The widget might return an iframe wrapper - we need to extract the actual review data differently
          // Try to find review data in script tags or data attributes
          return null; // Fall back to metafields
        }
      } else {
        console.log(`⚠️ Response doesn't look like HTML, might be an error or redirect`);
        return null; // Fall back to metafields
      }
    }
    
    return null;
  } catch (error) {
    console.error(`❌ Error fetching from Loox widget: ${error.message}`);
    if (error.response) {
      console.error(`   Status: ${error.response.status}`);
      console.error(`   Headers: ${JSON.stringify(error.response.headers)}`);
    }
    return null;
  }
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
    
    // First, try to fetch directly from Loox widget endpoint
    // Loox reviews are NOT in Shopify metafields - they're loaded from Loox servers
    const looxWidgetData = await fetchLooxReviewsFromWidget(cleanProductId);
    if (looxWidgetData && (looxWidgetData.reviews || looxWidgetData.data)) {
      console.log(`✅ Got reviews from Loox widget directly`);
      const reviews = looxWidgetData.reviews || looxWidgetData.data?.reviews || [];
      
      // Transform reviews to our format if they're from widget
      const transformedReviews = Array.isArray(reviews) ? reviews.map((review, index) => ({
        id: review.id || `review-${index}`,
        name: review.name || review.customer_name || review.customer?.name || 'Anonymous',
        text: review.text || review.review_text || review.comment || review.message || '',
        rating: review.rating || review.stars || review.score || null,
        date: review.date || review.created_at || review.review_date || null,
        photos: review.photos || review.images || review.photo_urls || [],
        isVerified: review.verified || review.is_verified || review.verified_purchase || false,
        profilePicture: review.profilePicture || review.profile_picture || review.avatar || review.customer?.avatar || null,
        videoUrl: review.videoUrl || review.video_url || review.video || null,
        productImage: review.productImage || review.product_image || review.product?.image || null,
        productName: review.productName || review.product_name || review.product?.name || null,
      })) : [];
      
      return {
        productId: cleanProductId,
        productTitle: looxWidgetData.productTitle || '',
        productHandle: looxWidgetData.productHandle || '',
        count: looxWidgetData.count || looxWidgetData.total || transformedReviews.length,
        averageRating: looxWidgetData.averageRating || looxWidgetData.rating || 0,
        reviews: transformedReviews
      };
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

