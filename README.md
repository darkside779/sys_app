# Delivery System App

A comprehensive Flutter-based delivery management system with AI-powered analytics, bilingual support, and intelligent order tracking capabilities.

## 📱 Project Overview

This is a full-featured delivery system application built with Flutter that serves both administrators and end users. The app provides real-time order tracking, AI-powered insights, intelligent notifications, and comprehensive analytics for delivery operations.

## ✨ Key Features

### 🔧 Admin Features
- **Comprehensive Dashboard**: Real-time overview of orders, drivers, and delivery performance
- **Order Management**: Full CRUD operations for orders with status tracking
- **Driver Management**: Track driver performance and availability
- **Analytics & Reports**: Detailed reporting with export capabilities (PDF, Excel, JSON, CSV)
- **AI-Powered Insights**: Intelligent analytics with anomaly detection and recommendations
- **Stale Order Alerts**: Automatic detection and notification of orders stale for 3+ days
- **Company Management**: Multi-company support with hierarchical data management

### 👤 User Features
- **Order Tracking**: Real-time order status updates with detailed information
- **Order History**: Complete order history with filtering and search capabilities
- **Stale Order Notifications**: Visual indicators for orders requiring attention
- **User Profile Management**: Personal information and preferences
- **Bilingual Support**: Full Arabic and English localization

### 🤖 AI & Analytics
- **AI Interactive Dashboard**: Comprehensive analytics with multiple visualization types
- **Smart Notifications**: AI-powered alerts for unusual patterns and performance issues
- **Data Export & Sharing**: Multi-format export with social sharing capabilities
- **Real-time Auto-refresh**: Configurable refresh intervals for live data
- **Predictive Analytics**: AI recommendations for operational improvements

### 🌐 Cross-Platform Support
- **Web Application**: PWA-ready web deployment with Firebase Hosting
- **iOS Application**: Native iOS app with platform-specific optimizations
- **Android Application**: Native Android app with Material Design
- **Desktop Support**: Windows, macOS, and Linux desktop applications

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter 3.x with Dart
- **State Management**: Provider pattern for reactive state management
- **Navigation**: Flutter's built-in navigation system
- **UI/UX**: Custom theme with Material Design and Cupertino components
- **Localization**: Built-in Flutter internationalization (i18n) support

### Backend & Services
- **Database**: Firebase Firestore for real-time data synchronization
- **Authentication**: Firebase Authentication with secure user management
- **Cloud Functions**: Serverless backend logic for complex operations
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **File Storage**: Firebase Storage for document and image management

### AI & Analytics
- **AI Services**: Custom AI data service for analytics and insights
- **Notification Engine**: Intelligent notification system with anomaly detection
- **Export Services**: Multi-format data export with professional reporting
- **Sharing Integration**: Social media and email sharing capabilities

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase project setup
- Android Studio / Xcode for mobile development
- VS Code or IntelliJ IDEA (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sys_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Set up Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase Hosting for web deployment

4. **Generate Localization Files**
   ```bash
   flutter gen-l10n
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production

**Web**
```bash
flutter build web --release
firebase deploy --only hosting
```

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

## 🌍 Localization

The app supports full bilingual functionality:
- **English (en)**: Primary language with complete feature coverage
- **Arabic (ar)**: Full RTL support with culturally appropriate translations
- **Dynamic Language Switching**: Users can change language without app restart

Localization files are located in:
- `assets/localization/app_en.arb` (English)
- `assets/localization/app_ar.arb` (Arabic)

## 📊 Key Components

### Order Management
- **Order Model**: Comprehensive order tracking with state management
- **Stale Detection**: Automatic identification of orders requiring attention
- **Status Tracking**: Real-time status updates with visual indicators
- **Notification System**: Intelligent alerts for order status changes

### AI Dashboard
- **Interactive Analytics**: Multiple chart types with real-time data
- **Export Capabilities**: Professional reports in multiple formats
- **Sharing Features**: Social media and email integration
- **Performance Metrics**: KPI tracking and trend analysis

### User Interface
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Accessibility**: Full accessibility support with screen readers
- **Theme System**: Consistent design language across platforms
- **Dark Mode**: Complete dark theme support

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Firestore, Authentication, and Cloud Messaging
3. Add platform-specific configuration files
4. Set up security rules for Firestore

### Environment Variables
Configure the following in your Firebase project:
- API keys for external services
- Notification settings
- AI service endpoints

## 📈 Performance Features

- **Lazy Loading**: Efficient data loading for large datasets
- **Caching**: Intelligent caching for offline functionality
- **Optimization**: Image compression and asset optimization
- **Real-time Sync**: Efficient Firebase real-time listeners

## 🔐 Security

- **Firebase Security Rules**: Proper data access controls
- **Authentication**: Secure user authentication and authorization
- **Data Validation**: Client and server-side data validation
- **Privacy**: GDPR-compliant data handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation in the `docs/` folder

---

**Built with ❤️ using Flutter and Firebase**
