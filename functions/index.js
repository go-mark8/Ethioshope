const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sharp = require('sharp');

// Initialize Firebase Admin
admin.initializeApp();

// Firestore references
const db = admin.firestore();
const storage = admin.storage();

// ===== PAYMENT HANDLERS =====

// Process Telebirr Payment (Mock)
exports.processTelebirrPayment = functions.https.onCall(async (data, context) => {
  const { order_id, amount, phone_number, user_id } = data;

  try {
    // Validate input
    if (!order_id || !amount || !phone_number || !user_id) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    // Mock Telebirr payment processing
    // In production, this would integrate with actual Telebirr API
    const paymentId = 'TB' + Date.now();
    
    // Simulate payment processing delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Mock successful payment (90% success rate for demo)
    const isSuccess = Math.random() > 0.1;

    if (!isSuccess) {
      throw new functions.https.HttpsError(
        'aborted',
        'Payment failed. Please try again.'
      );
    }

    // Update order with payment status
    await db.collection('orders').doc(order_id).update({
      payment_status: 'paid',
      payment_method: 'telebirr',
      payment_id: paymentId,
      payment_completed_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to seller
    const orderDoc = await db.collection('orders').doc(order_id).get();
    const orderData = orderDoc.data();
    
    await db.collection('notifications').add({
      recipient_id: orderData.seller_id,
      type: 'payment',
      title: 'Payment Received',
      body: `Payment of ETB ${amount} received via Telebirr`,
      status: 'unread',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      payment_id: paymentId,
      message: 'Payment successful'
    };

  } catch (error) {
    console.error('Telebirr payment error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Payment processing failed'
    );
  }
});

// Process CBE Birr Payment (Mock)
exports.processCBEBirrPayment = functions.https.onCall(async (data, context) => {
  const { order_id, amount, account_number, user_id } = data;

  try {
    // Validate input
    if (!order_id || !amount || !account_number || !user_id) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required parameters'
      );
    }

    // Mock CBE Birr payment processing
    // In production, this would integrate with actual CBE Birr API
    const paymentId = 'CBE' + Date.now();
    
    // Simulate payment processing delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Mock successful payment (85% success rate for demo)
    const isSuccess = Math.random() > 0.15;

    if (!isSuccess) {
      throw new functions.https.HttpsError(
        'aborted',
        'Payment failed. Insufficient funds or invalid account.'
      );
    }

    // Update order with payment status
    await db.collection('orders').doc(order_id).update({
      payment_status: 'paid',
      payment_method: 'cbe_birr',
      payment_id: paymentId,
      payment_completed_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to seller
    const orderDoc = await db.collection('orders').doc(order_id).get();
    const orderData = orderDoc.data();
    
    await db.collection('notifications').add({
      recipient_id: orderData.seller_id,
      type: 'payment',
      title: 'Payment Received',
      body: `Payment of ETB ${amount} received via CBE Birr`,
      status: 'unread',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      payment_id: paymentId,
      message: 'Payment successful'
    };

  } catch (error) {
    console.error('CBE Birr payment error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Payment processing failed'
    );
  }
});

// Verify Payment Status
exports.verifyPaymentStatus = functions.https.onCall(async (data, context) => {
  const { order_id, payment_method } = data;

  try {
    const orderDoc = await db.collection('orders').doc(order_id).get();
    
    if (!orderDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Order not found'
      );
    }

    const orderData = orderDoc.data();

    return {
      payment_status: orderData.payment_status,
      payment_method: orderData.payment_method,
      payment_id: orderData.payment_id,
      payment_completed_at: orderData.payment_completed_at,
    };

  } catch (error) {
    console.error('Payment verification error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Payment verification failed'
    );
  }
});

// Request Refund
exports.requestRefund = functions.https.onCall(async (data, context) => {
  const { order_id, reason } = data;

  try {
    const orderDoc = await db.collection('orders').doc(order_id).get();
    
    if (!orderDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Order not found'
      );
    }

    const orderData = orderDoc.data();

    if (orderData.payment_status !== 'paid') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Order payment not completed'
      );
    }

    // Update order with refund status
    await db.collection('orders').doc(order_id).update({
      payment_status: 'refunded',
      refund_reason: reason,
      refund_requested_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to buyer
    await db.collection('notifications').add({
      recipient_id: orderData.buyer_id,
      type: 'system',
      title: 'Refund Initiated',
      body: 'Your refund has been initiated. It will be processed within 5-7 business days.',
      status: 'unread',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: 'Refund request submitted successfully'
    };

  } catch (error) {
    console.error('Refund request error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Refund request failed'
    );
  }
});

// ===== IMAGE PROCESSING =====

// Process and Optimize Product Images
exports.processProductImage = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  const fileName = filePath.split('/').pop();

  // Only process product images
  if (!filePath.startsWith('products/')) {
    return null;
  }

  try {
    const bucket = storage.bucket(object.bucket);
    const file = bucket.file(filePath);
    
    // Download the image
    const [imageBuffer] = await file.download();

    // Process image with Sharp
    const processedImage = await sharp(imageBuffer)
      .resize(1920, 1080, { 
        fit: 'inside',
        withoutEnlargement: true 
      })
      .webp({ quality: 85 })
      .toBuffer();

    // Upload optimized image
    const optimizedFileName = `optimized_${fileName.replace(/\.[^/.]+$/, '')}.webp`;
    const optimizedPath = `products/${optimizedFileName}`;
    const optimizedFile = bucket.file(optimizedPath);

    await optimizedFile.save(processedImage, {
      contentType: 'image/webp',
    });

    console.log(`Image optimized and saved: ${optimizedPath}`);
    
    return { success: true, path: optimizedPath };

  } catch (error) {
    console.error('Image processing error:', error);
    return null;
  }
});

// ===== ESCROW PAYMENT RELEASE =====

// Release Escrow Payment After Delivery Confirmation
exports.releaseEscrowPayment = functions.https.onCall(async (data, context) => {
  const { order_id } = data;

  try {
    const orderDoc = await db.collection('orders').doc(order_id).get();
    
    if (!orderDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Order not found'
      );
    }

    const orderData = orderDoc.data();

    if (orderData.status !== 'delivered') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Order must be delivered to release escrow'
      );
    }

    if (orderData.escrow_released) {
      throw new functions.https.HttpsError(
        'already-exists',
        'Escrow payment already released'
      );
    }

    // Release escrow payment
    await db.collection('orders').doc(order_id).update({
      escrow_released: true,
      escrow_released_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to seller
    await db.collection('notifications').add({
      recipient_id: orderData.seller_id,
      type: 'payment',
      title: 'Payment Released',
      body: `Payment of ${orderData.total_amount} ETB has been released to your account`,
      status: 'unread',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to buyer
    await db.collection('notifications').add({
      recipient_id: orderData.buyer_id,
      type: 'system',
      title: 'Payment Released',
      body: 'Payment has been released to the seller',
      status: 'unread',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: 'Escrow payment released successfully'
    };

  } catch (error) {
    console.error('Escrow release error:', error);
    throw new functions.https.HttpsError(
      'internal',
      error.message || 'Escrow release failed'
    );
  }
});

// ===== SEED DATA SCRIPT =====

// Seed Firestore with Ethiopian Sample Data
exports.seedFirestoreData = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Starting Firestore data seeding...');

    // Seed Users
    await seedUsers();
    console.log('Users seeded successfully');

    // Seed Categories (already exist, skip)
    console.log('Categories skipped (use hardcoded categories)');

    // Seed Products
    await seedProducts();
    console.log('Products seeded successfully');

    // Seed Orders
    await seedOrders();
    console.log('Orders seeded successfully');

    // Seed Messages
    await seedMessages();
    console.log('Messages seeded successfully');

    // Seed Reviews
    await seedReviews();
    console.log('Reviews seeded successfully');

    res.json({ 
      success: true, 
      message: 'Firestore data seeded successfully' 
    });

  } catch (error) {
    console.error('Seeding error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Helper function to seed users
async function seedUsers() {
  const users = [
    // Buyers
    { id: 'buyer1', name: 'Abebe Tesfaye', email: 'abebe@example.com', phone: '+251911123456', role: 'buyer', verified: true, location: 'Addis Ababa' },
    { id: 'buyer2', name: 'Lidya Mekonnen', email: 'lidya@example.com', phone: '+251911234567', role: 'buyer', verified: true, location: 'Hawassa' },
    { id: 'buyer3', name: 'Samuel Bekele', email: 'samuel@example.com', phone: '+251911345678', role: 'buyer', verified: false, location: 'Bahir Dar' },
    { id: 'buyer4', name: 'Hana Alemu', email: 'hana@example.com', phone: '+251911456789', role: 'buyer', verified: true, location: 'Dire Dawa' },
    { id: 'buyer5', name: 'Yonas Tadesse', email: 'yonas@example.com', phone: '+251911567890', role: 'buyer', verified: true, location: 'Mekelle' },
    
    // Sellers
    { id: 'seller1', name: 'Addis Electronics', email: 'addiselec@example.com', phone: '+251922123456', role: 'seller', verified: true, location: 'Addis Ababa' },
    { id: 'seller2', name: 'Hawassa Fashion', email: 'hawassafash@example.com', phone: '+251922234567', role: 'seller', verified: true, location: 'Hawassa' },
    { id: 'seller3', name: 'Bahir Dar Furniture', email: 'bahirdarfurn@example.com', phone: '+251922345678', role: 'seller', verified: true, location: 'Bahir Dar' },
    { id: 'seller4', name: 'Mekelle Auto Parts', email: 'mekelleauto@example.com', phone: '+251922456789', role: 'seller', verified: true, location: 'Mekelle' },
    
    // Admin
    { id: 'admin1', name: 'Admin Ethioshop', email: 'admin@ethioshop.com', phone: '+251900000000', role: 'admin', verified: true, location: 'Addis Ababa' },
  ];

  const batch = db.batch();

  users.forEach(user => {
    const userRef = db.collection('users').doc(user.id);
    batch.set(userRef, {
      ...user,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      fcm_token: null,
      profile_image: null,
      address: null,
    });
  });

  await batch.commit();
}

// Helper function to seed products
async function seedProducts() {
  const products = [
    {
      id: 'prod1', title: 'Samsung Galaxy A12', description: 'Brand new Samsung Galaxy A12 with 4GB RAM and 64GB storage. Comes with charger and warranty.', category: 'Electronics', price: 12000, condition: 'new', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300', 'https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod2', title: 'Traditional Coffee Set', description: 'Beautiful Ethiopian traditional coffee set with Jebena and Sini cups. Handcrafted design.', category: 'Food & Beverages', price: 2500, condition: 'like_new', location: 'Hawassa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod3', title: 'Toyota Corolla Spare Parts', description: 'Genuine Toyota Corolla spare parts including brake pads, filters, and oil. Used but in good condition.', category: 'Automotive', price: 30000, condition: 'used', location: 'Mekelle', seller_id: 'seller4', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod4', title: 'Ethiopian Dress', description: 'Traditional Ethiopian Habesha Kemis made of high quality cotton. Beautiful embroidery work.', category: 'Fashion & Clothing', price: 4500, condition: 'new', location: 'Addis Ababa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod5', title: 'Wooden Dining Table', description: 'Solid wood dining table with 6 chairs. Handcrafted Ethiopian design. Minor scratches.', category: 'Home & Furniture', price: 18000, condition: 'used', location: 'Bahir Dar', seller_id: 'seller3', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    // Add 15 more products to reach 20 total
    {
      id: 'prod6', title: 'Laptop HP Pavilion', description: 'HP Pavilion laptop, 8GB RAM, 256GB SSD, Intel i5. Like new condition.', category: 'Electronics', price: 25000, condition: 'like_new', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod7', title: 'Sports Shoes Nike', description: 'Brand new Nike Air Max running shoes, size 42. Original packaging.', category: 'Sports & Outdoors', price: 3200, condition: 'new', location: 'Hawassa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod8', title: 'Ethiopian History Book', description: 'Comprehensive Ethiopian history book covering ancient to modern times. Hardcover edition.', category: 'Books & Stationery', price: 800, condition: 'new', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod9', title: 'Makeup Kit', description: 'Professional makeup kit with foundation, lipstick, eyeshadow, and brushes.', category: 'Beauty & Personal Care', price: 3500, condition: 'new', location: 'Dire Dawa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod10', title: 'Car Battery', description: 'Heavy-duty car battery suitable for most vehicles. 12V, 60Ah.', category: 'Automotive', price: 8500, condition: 'new', location: 'Mekelle', seller_id: 'seller4', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod11', title: 'Ethiopian Music Collection', description: 'Collection of traditional and modern Ethiopian music CDs. 50 albums.', category: 'Electronics', price: 1200, condition: 'used', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod12', title: 'Handwoven Scarf', description: 'Beautiful handwoven Ethiopian cotton scarf with traditional patterns.', category: 'Fashion & Clothing', price: 600, condition: 'new', location: 'Hawassa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod13', title: 'Office Chair', description: 'Ergonomic office chair with lumbar support. Adjustable height and armrests.', category: 'Home & Furniture', price: 4500, condition: 'like_new', location: 'Bahir Dar', seller_id: 'seller3', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod14', title: 'Soccer Ball', description: 'Professional size 5 soccer ball. FIFA approved.', category: 'Sports & Outdoors', price: 1200, condition: 'new', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod15', title: 'Ethiopian Spices Set', description: 'Set of authentic Ethiopian spices including Berbere, Mitmita, and Korerima.', category: 'Food & Beverages', price: 450, condition: 'new', location: 'Hawassa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod16', title: 'Headphones Sony', description: 'Sony wireless headphones with noise cancellation. Good battery life.', category: 'Electronics', price: 5500, condition: 'used', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod17', title: 'Men\'s Suit', description: 'Elegant men\'s business suit, size L. Italian fabric.', category: 'Fashion & Clothing', price: 8000, condition: 'like_new', location: 'Dire Dawa', seller_id: 'seller2', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod18', title: 'Study Desk', description: 'Wooden study desk with drawers and shelves. Perfect for students.', category: 'Home & Furniture', price: 3500, condition: 'used', location: 'Bahir Dar', seller_id: 'seller3', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod19', title: 'Fitness Dumbbells Set', description: 'Set of adjustable dumbbells from 5kg to 20kg. Includes rack.', category: 'Sports & Outdoors', price: 12000, condition: 'new', location: 'Addis Ababa', seller_id: 'seller1', images: ['https://via.placeholder.com/300'], status: 'available'
    },
    {
      id: 'prod20', title: 'Organic Honey', description: 'Pure organic honey from Tigray region. 2kg jar.', category: 'Food & Beverages', price: 850, condition: 'new', location: 'Mekelle', seller_id: 'seller4', images: ['https://via.placeholder.com/300'], status: 'available'
    },
  ];

  const batch = db.batch();

  products.forEach(product => {
    const productRef = db.collection('products').doc(product.id);
    batch.set(productRef, {
      ...product,
      currency: 'ETB',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
      views: Math.floor(Math.random() * 500) + 10,
      rating: (Math.random() * 2 + 3).toFixed(1), // 3.0 to 5.0
      review_count: Math.floor(Math.random() * 20) + 1,
    });
  });

  await batch.commit();
}

// Helper function to seed orders
async function seedOrders() {
  const statuses = ['pending', 'confirmed', 'shipped', 'delivered'];
  const paymentMethods = ['telebirr', 'cbe_birr', 'cash'];

  const batch = db.batch();

  for (let i = 1; i <= 15; i++) {
    const orderId = `order${i}`;
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    const buyerId = `buyer${(i % 5) + 1}`;
    const sellerId = `seller${(i % 4) + 1}`;
    const productId = `prod${(i % 20) + 1}`;
    
    // Get product details
    const productDoc = await db.collection('products').doc(productId).get();
    const productData = productDoc.data();

    const orderRef = db.collection('orders').doc(orderId);
    
    const orderData = {
      id: orderId,
      buyer_id: buyerId,
      seller_id: sellerId,
      items: [{
        product_id: productId,
        product_name: productData.title,
        price: productData.price,
        quantity: 1,
        product_image: productData.images[0],
      }],
      total_amount: productData.price,
      currency: 'ETB',
      status: status,
      payment_status: status === 'delivered' ? 'paid' : 'pending',
      payment_method: paymentMethods[Math.floor(Math.random() * paymentMethods.length)],
      shipping_address: `${['Bole', 'Kazanchis', 'Megenagna', 'Piassa'][i % 4]}, Addis Ababa`,
      created_at: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000), // Last 30 days
      escrow_released: status === 'delivered',
    };

    if (status === 'confirmed') {
      orderData.confirmed_at = new Date(Date.now() - Math.random() * 20 * 24 * 60 * 60 * 1000);
    }
    if (status === 'shipped') {
      orderData.confirmed_at = new Date(Date.now() - Math.random() * 15 * 24 * 60 * 60 * 1000);
      orderData.shipped_at = new Date(Date.now() - Math.random() * 10 * 24 * 60 * 60 * 1000);
      orderData.tracking_number = `TB${123456789 + i}`;
    }
    if (status === 'delivered') {
      orderData.confirmed_at = new Date(Date.now() - Math.random() * 25 * 24 * 60 * 60 * 1000);
      orderData.shipped_at = new Date(Date.now() - Math.random() * 20 * 24 * 60 * 60 * 1000);
      orderData.delivered_at = new Date(Date.now() - Math.random() * 10 * 24 * 60 * 60 * 1000);
      orderData.tracking_number = `TB${123456789 + i}`;
      orderData.escrow_released_at = new Date(Date.now() - Math.random() * 5 * 24 * 60 * 60 * 1000);
    }

    batch.set(orderRef, orderData);
  }

  await batch.commit();
}

// Helper function to seed messages
async function seedMessages() {
  const messages = [
    { id: 'msg1', sender_id: 'buyer1', receiver_id: 'seller1', text: 'Is the Samsung Galaxy A12 still available?', timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
    { id: 'msg2', sender_id: 'seller1', receiver_id: 'buyer1', text: 'Yes, it\'s available! Ready for delivery.', timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 3600000) },
    { id: 'msg3', sender_id: 'buyer2', receiver_id: 'seller2', text: 'Can you show more photos of the traditional coffee set?', timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) },
    { id: 'msg4', sender_id: 'seller2', receiver_id: 'buyer2', text: 'Sure! I\'ll send more photos shortly.', timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 + 7200000) },
    // Add more messages to reach 30 total
  ];

  const batch = db.batch();

  messages.forEach((msg, index) => {
    const msgRef = db.collection('messages').doc(msg.id);
    batch.set(msgRef, {
      ...msg,
      type: 'text',
      is_read: index % 2 === 1, // Every other message is read
    });
  });

  // Generate more messages programmatically
  for (let i = 5; i <= 30; i++) {
    const buyerId = `buyer${(i % 5) + 1}`;
    const sellerId = `seller${(i % 4) + 1}`;
    const isFromBuyer = i % 2 === 0;
    
    const msgRef = db.collection('messages').doc(`msg${i}`);
    batch.set(msgRef, {
      id: `msg${i}`,
      sender_id: isFromBuyer ? buyerId : sellerId,
      receiver_id: isFromBuyer ? sellerId : buyerId,
      text: _getRandomMessage(isFromBuyer),
      type: 'text',
      is_read: false,
      timestamp: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000),
    });
  }

  await batch.commit();
}

function _getRandomMessage(isFromBuyer) {
  const buyerMessages = [
    'Is this product still available?',
    'What is the lowest price?',
    'Can you deliver to my location?',
    'Is the price negotiable?',
    'How old is this item?',
    'Do you have warranty?',
    'Can I see more photos?',
    'When can you deliver?',
    'Is the description accurate?',
    'What payment methods do you accept?',
  ];
  
  const sellerMessages = [
    'Yes, it\'s still available!',
    'Sorry, it\'s already sold.',
    'Price is slightly negotiable.',
    'I can deliver tomorrow.',
    'The item is in excellent condition.',
    '1 year warranty included.',
    'I\'ll send more photos.',
    'Payment on delivery available.',
    'Yes, everything is accurate.',
    'I accept Telebirr and CBE Birr.',
  ];

  const messages = isFromBuyer ? buyerMessages : sellerMessages;
  return messages[Math.floor(Math.random() * messages.length)];
}

// Helper function to seed reviews
async function seedReviews() {
  const comments = [
    'Great quality, fast delivery!',
    'Product was good but delivery took longer.',
    'Excellent seller, highly recommended!',
    'Item exactly as described.',
    'Good value for money.',
    'Fast shipping, good communication.',
    'Quality product, will buy again.',
    'Slightly different from photos but still good.',
    'Professional seller, smooth transaction.',
    'Great experience overall.',
    'Product works perfectly.',
    'Reasonable price for the quality.',
    'Delivery was a bit slow but product is good.',
    'Very satisfied with my purchase.',
    'Highly recommend this seller!',
    'Good packaging, item arrived safely.',
    'A bit expensive but worth it.',
    'Quick response to inquiries.',
    'Product met all my expectations.',
    'Excellent customer service.',
    'Would definitely buy again.',
    'Fair price, good quality.',
    'Delivery could be faster.',
    'Happy with the purchase.',
    'Top-notch seller!',
  ];

  const batch = db.batch();

  for (let i = 1; i <= 25; i++) {
    const reviewRef = db.collection('reviews').doc(`review${i}`);
    const rating = Math.floor(Math.random() * 3) + 3; // 3 to 5 stars
    const orderId = `order${(i % 15) + 1}`;
    
    batch.set(reviewRef, {
      id: `review${i}`,
      order_id: orderId,
      reviewer_id: `buyer${(i % 5) + 1}`,
      reviewer_name: ['Abebe Tesfaye', 'Lidya Mekonnen', 'Samuel Bekele', 'Hana Alemu', 'Yonas Tadesse'][i % 5],
      rating: rating,
      comment: comments[Math.floor(Math.random() * comments.length)],
      verified_purchase: true,
      created_at: new Date(Date.now() - Math.random() * 25 * 24 * 60 * 60 * 1000),
    });
  }

  await batch.commit();
}