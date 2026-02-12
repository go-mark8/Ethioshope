# EthioShop - Ethiopian Marketplace App

A full-featured mobile marketplace application built with Flutter and Firebase, designed specifically for the Ethiopian market with local payment methods, currency, and delivery options.

## 🌟 Features

### Core Features
- **Multi-Role System**: Buyers, Sellers, and Admin roles
- **Product Management**: Create, list, search, and filter products
- **Secure Payments**: Integration with Telebirr and CBE Birr (mock)
- **Real-time Chat**: In-app messaging between buyers and sellers
- **Order Tracking**: Track orders with delivery confirmation
- **Reviews & Ratings**: Product and seller reviews
- **Push Notifications**: Real-time notifications for orders and messages
- **Admin Dashboard**: Complete admin panel for platform management

### Ethiopian-Specific Features
- **ETB Currency**: Ethiopian Birr as default currency
- **Local Payment Methods**: Telebirr and CBE Birr integration
- **Ethiopian Addresses**: Local address format and locations
- **Phone Validation**: +251 phone number validation
- **Multilingual Support**: English and Amharic (RTL ready)
- **Local Delivery Options**: City-based delivery across Ethiopia

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.16+
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging, Functions)
- **Payment**: Telebirr, CBE Birr (Mock Integration)
- **State Management**: Provider
- **CI/CD**: GitHub Actions

### Project Structure
```
ethioshop/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── order_model.dart
│   │   ├── message_model.dart
│   │   ├── review_model.dart
│   │   └── notification_model.dart
│   ├── screens/                  # UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── product_list_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── order_tracking_screen.dart
│   │   ├── chat_screen.dart
│   │   └── admin_dashboard.dart
│   ├── services/                 # Firebase services
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   └── payment_service.dart
│   └── widgets/                  # Reusable widgets
│       ├── custom_button.dart
│       ├── product_card.dart
│       ├── chat_bubble.dart
│       └── notification_tile.dart
├── functions/                    # Cloud Functions
│   ├── index.js                 # Main functions file
│   └── package.json
├── android/                      # Android configuration
│   └── app/
│       ├── google-services.json  # Firebase configuration
│       └── build.gradle
├── test/                         # Test files
│   ├── widget_tests.dart
│   ├── integration_tests.dart
│   └── firestore_mock_tests.dart
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # CI/CD pipeline
├── pubspec.yaml                  # Dependencies
├── firebase.json                 # Firebase configuration
├── firestore.rules               # Firestore security rules
├── storage.rules                 # Storage security rules
└── firestore.indexes.json        # Firestore indexes
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16 or higher
- Android Studio / VS Code
- Firebase account
- Node.js 18+ (for Cloud Functions)

### Installation

1. **Clone the repository**
```bash
git clone [https://github.com/go-mark8/Ethioshope.git]
cd ethioshop
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

   a. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

   b. Add an Android app with package name `com.ethio.shop`

   c. Download `google-services.json` and place it in `android/app/`

   d. Enable the following Firebase services:
      - Authentication
      - Firestore Database
      - Storage
      - Cloud Messaging
      - Cloud Functions

4. **Set up Firestore Security Rules**
```bash
firebase deploy --only firestore:rules
```

5. **Deploy Cloud Functions**
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

6. **Seed Firestore with sample data**
```bash
# Call the Cloud Functions endpoint or use Firebase Console
# The seed data function is available at:
# https://your-region-ethio-shop-01525861.cloudfunctions.net/seedFirestoreData
```

7. **Run the app**
```bash
flutter run
```

## 📱 Available Screens

### User Screens
1. **Login Screen**: Email/Password and Google authentication
2. **Register Screen**: User registration with role selection
3. **Product List Screen**: Browse products with filters
4. **Product Detail Screen**: View product details and purchase
5. **Cart Screen**: Shopping cart management
6. **Order Tracking Screen**: Track order status
7. **Chat Screen**: Real-time messaging
8. **Admin Dashboard**: Platform management

### Key Features by Screen

#### Product List Screen
- Search products by title and description
- Filter by category (8 categories)
- Filter by location (5 Ethiopian cities)
- Grid view with product cards
- Real-time updates from Firestore

#### Product Detail Screen
- Product image gallery
- Detailed product information
- Seller profile and verification status
- Contact seller button
- Buy now functionality

#### Order Tracking Screen
- Real-time order status
- Timeline view of order progress
- Delivery information
- Escrow payment status
- Confirm delivery functionality

#### Chat Screen
- Real-time messaging
- Product attachments
- Read receipts
- Typing indicators
- Report and block user options

## 🔐 Firebase Security

### Firestore Rules
- Public read access for products and reviews
- Authenticated users can create orders and messages
- Sellers can only manage their own products
- Admins have full access to all collections

### Storage Rules
- Public read access for all images
- Authenticated write access
- User-specific profile image management

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/widget_tests.dart
```

### Run Integration Tests
```bash
flutter test test/integration_tests.dart
```

### Run Mock Firestore Tests
```bash
flutter test test/firestore_mock_tests.dart
```

## 🔄 CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

### Pipeline Stages
1. **Build and Test**: Code analysis and unit tests
2. **Build Android**: Compile APK and App Bundle
3. **Firebase Deploy**: Deploy to Firebase Hosting
4. **App Distribution**: Distribute to testers via Firebase App Distribution
5. **Crashlytics**: Upload crash reports

### Setup GitHub Secrets
Add these secrets to your GitHub repository:
- `FIREBASE_TOKEN`: Firebase CLI token
- `FIREBASE_APP_ID`: Firebase App ID
- `FIREBASE_SERVICE_CREDENTIALS`: Firebase service account JSON

## 📊 Firebase Collections

### Users
```javascript
{
  id: string,
  name: string,
  email: string,
  phone: string,
  role: 'buyer' | 'seller' | 'admin',
  verified: boolean,
  created_at: timestamp,
  fcm_token: string?,
  profile_image: string?,
  location: string?,
  address: string?
}
```

### Products
```javascript
{
  id: string,
  seller_id: string,
  title: string,
  description: string,
  images: string[],
  category: string,
  price: number,
  currency: string,
  condition: 'new' | 'like_new' | 'used',
  status: 'available' | 'sold' | 'pending',
  location: string,
  created_at: timestamp,
  views: number?,
  rating: number?,
  review_count: number?
}
```

### Orders
```javascript
{
  id: string,
  buyer_id: string,
  seller_id: string,
  items: OrderItem[],
  total_amount: number,
  currency: string,
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled',
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded',
  payment_method: 'telebirr' | 'cbe_birr' | 'cash',
  shipping_address: string,
  created_at: timestamp,
  escrow_released: boolean,
  tracking_number: string?
}
```

### Messages
```javascript
{
  id: string,
  sender_id: string,
  receiver_id: string,
  text: string,
  type: 'text' | 'image' | 'product' | 'system',
  timestamp: timestamp,
  is_read: boolean,
  product_id: string?
}
```

### Reviews
```javascript
{
  id: string,
  order_id: string,
  reviewer_id: string,
  reviewer_name: string,
  rating: number (1-5),
  comment: string,
  verified_purchase: boolean,
  created_at: timestamp
}
```

## 💳 Payment Integration

### Telebirr (Mock)
- Ethiopian mobile payment service
- Phone number validation (+251 format)
- Mock payment processing with 90% success rate
- Payment status tracking

### CBE Birr (Mock)
- Commercial Bank of Ethiopia mobile banking
- Account number validation (13 digits)
- Mock payment processing with 85% success rate
- Payment confirmation notifications

### Escrow System
- Payments held in escrow until delivery confirmation
- Automatic release after buyer confirms delivery
- Seller notifications on payment release

## 🌍 Localization

The app supports:
- English (default)
- Amharic (with RTL support)

To switch languages, modify the `locale` parameter in `main.dart`:
```dart
locale: const Locale('am', ''),
```

## 📱 Device Support

- Minimum SDK: Android 5.0 (API 21)
- Target SDK: Android 14 (API 34)
- Optimized for low-end devices
- Works offline with cached data

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_PROJECT_ID=ethio-shop-01525861
TELEBIRR_API_KEY=your_telebirr_api_key
CBE_BIRR_API_KEY=your_cbe_birr_api_key
```

### Firebase Configuration
Ensure `google-services.json` is correctly placed in `android/app/`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- **Developed by**: EthioShop Team
- **Project Type**: Ethiopian Marketplace Application
- **Version**: 1.0.0

## 📞 Support

For support, email support@ethioshop.com or join our Telegram channel.

## 🙏 Acknowledgments

- Firebase for the backend infrastructure
- Flutter team for the amazing framework
- Ethiopian tech community for support

## 🗺️ Roadmap

### Phase 1 (Completed)
- ✅ Basic marketplace functionality
- ✅ User authentication
- ✅ Product management
- ✅ Order tracking
- ✅ Real-time chat

### Phase 2 (In Progress)
- 🔄 Payment integration with actual APIs
- 🔄 Advanced search with filters
- 🔄 Product recommendations
- 🔄 Push notification enhancements

### Phase 3 (Planned)
- 📋 Vendor analytics dashboard
- 📋 Multi-language support expansion
- 📋 Delivery service integration
- 📋 AI-powered product matching

---

Built with ❤️ for Ethiopia 🇪🇹
