# PetConnect

A social networking application designed for pet owners and their pets. Built with Flutter and Firebase, the app enables users to share pet content, connect with other pet owners, discover nearby veterinary services, buy and sell pet products, and receive AI-powered pet care advice.

## Overview

PetConnect combines social networking features with practical pet care utilities. Users can create profiles for themselves and their pets, share posts and stories, interact through direct messaging, browse a marketplace for pet products, post lost pet alerts, and locate nearby veterinary clinics using Google Maps integration.

## Features

### Core Social Features

**User Authentication**
- Email and password-based registration and login
- Password reset functionality via email
- Onboarding flow for new users
- Session persistence with Firebase Auth

**Profile Management**
- User profile with customizable bio and avatar
- Dedicated pet profile section with pet name, type, breed, age, weight, and bio
- Pet image upload and display
- Edit profile functionality for both user and pet details
- Follow/unfollow other users
- Follower/following counts with navigation to user lists
- Confetti animation on follow action

**Posts and Feed**
- Create posts with images and captions
- AI-powered caption generation using Google Gemini
- Like posts with double-tap or button
- Save posts for later viewing
- Share posts to other users via direct message
- Comment on posts
- Home feed excluding own posts
- Post grid view on profile
- Delete own posts

**Stories**
- Upload 24-hour stories
- View stories with auto-progress animation
- React to stories with emoji reactions
- Story reactions trigger direct message to story owner
- Story view count display for own stories

**Direct Messaging**
- Real-time chat between users
- Send text messages and images
- Share posts within conversations
- Unread message count badges
- Recent chats list
- Mark messages as read on open
- Message notifications via FCM

**Search**
- Search users by username
- Pet type search (dog, cat, bird, rabbit, fish, hamster, turtle, parrot, guinea pig, other)
- Recent searches saved locally
- Animated search results
- Pet type indicator chips

**Notifications**
- In-app notification center
- Type-specific icons and colors (likes, follows, comments, messages, marketplace, story reactions)
- Mark all as read functionality
- Real-time notification badges
- Firebase Cloud Messaging integration
- Local notification banners for foreground messages

### Marketplace

**Browse Listings**
- Category filtering (All, Food, Accessories, Adoption, Services)
- Grid view of product listings
- Product images, titles, prices, and seller information
- Navigate to listing details

**My Listings**
- View own marketplace listings
- Delete own listings
- Create new listings with images

**Create Listings**
- Upload product images
- Set title, price, category, and description
- Seller information automatically populated

### Pet Alerts

**Lost Pet Alerts**
- Post alerts with pet photo, description, color, size, location, and phone number
- Animated dialog for creating alerts
- View all alerts in feed
- Contact alert owner via direct message
- Delete own alerts
- Time-ago display for alert timestamps

### Location Services

**Vet Locator**
- Google Maps integration for displaying user location
- Search for nearby veterinary clinics and pet stores
- Place markers on map
- Bottom sheet with place details (name, rating, address, hours)
- Open/closed status indicator
- Get directions functionality
- Location permission handling

### AI Features

**Pet AI Assistant**
- AI chatbot for pet care questions
- Powered by Google Gemini (gemini-2.5-flash)
- Typing indicator during AI response
- Context-aware responses focused on veterinary and pet topics

**AI Caption Generation**
- Generate captions for pet photos using AI vision
- One-tap caption generation in post creation
- Emoji-rich captions

### UI/UX Features

**Dark Mode**
- System-wide theme toggle
- Light and dark theme definitions
- Theme persistence with SharedPreferences
- Theme-aware colors across all screens

**Navigation**
- Bottom navigation bar with 4 main tabs (Home, Marketplace, Create Post, Profile)
- Animated tab indicators
- Center floating action button for post creation
- Swipe navigation between tabs (PageView)

**Design System**
- Custom color palette with coral primary and lavender secondary
- Gradient backgrounds and buttons
- Rounded corners and soft shadows
- Fredoka font family
- Material 3 design principles

**Animations**
- Confetti effects on follow
- Smooth page transitions
- Animated story progress bars
- Typing indicator for AI chat
- Banner auto-rotation on home screen
- Elastic dialog animations

## Architecture

### State Management
- Provider pattern for theme management (ThemeProvider)
- StreamBuilder for real-time Firestore data
- StatefulWidget for local component state

### Data Storage
- Firebase Firestore for all persistent data
- Collections: users, posts, stories, chats, marketplace, alerts
- Subcollections: notifications, likes, saved, recent_chats, reactions, messages
- Base64 encoding for image storage

### Authentication
- Firebase Authentication for user accounts
- Email/password sign-in and sign-up
- Password reset via email

### Notifications
- Firebase Cloud Messaging (FCM) for push notifications
- Flutter Local Notifications for in-app banners
- Firestore listener for real-time notification display
- Background message handling

### Location Services
- Geolocator for current location
- Google Maps Flutter for map display
- Google Places API for nearby vet search

### AI Integration
- Google Generative AI (Gemini 2.5 Flash)
- Text-only and vision models
- API key stored in constants

## Tech Stack

### Core Framework
- Flutter (SDK >=3.0.0 <4.0.0)
- Dart

### Firebase Services
- firebase_core ^3.15.2
- firebase_auth ^5.3.1
- cloud_firestore ^5.4.4
- firebase_messaging ^15.2.10

### UI and Design
- google_fonts ^6.1.0
- confetti ^0.8.0
- provider ^6.1.2

### Utilities
- shared_preferences ^2.3.3
- flutter_local_notifications ^17.2.4
- image_picker ^1.1.2

### Maps and Location
- google_maps_flutter ^2.5.3
- geolocator ^11.0.0
- geocoding ^3.0.0

### AI
- google_generative_ai ^0.4.7

### Networking
- http ^1.2.0

## File Structure

```
lib/
├── main.dart                    # App entry point, Firebase initialization
├── models/
│   ├── message_model.dart       # Chat message data model
│   ├── post_model.dart          # Post data model
│   └── user_model.dart          # User data model
├── providers/
│   └── theme_provider.dart      # Dark mode state management
├── screens/
│   ├── ai_chat_screen.dart      # AI pet assistant chat
│   ├── alerts_screen.dart       # Lost pet alerts
│   ├── chat_list_screen.dart    # List of recent chats
│   ├── chat_screen.dart         # Direct messaging
│   ├── comments_screen.dart     # Post comments
│   ├── create_listing_screen.dart # Marketplace listing creation
│   ├── create_post_screen.dart  # Post creation with AI caption
│   ├── home_screen.dart         # Main feed with stories and posts
│   ├── listing_detail_screen.dart # Marketplace listing details
│   ├── login_screen.dart        # User authentication
│   ├── marketplace_screen.dart  # Marketplace browse and listings
│   ├── messaging_screen.dart    # Messaging hub
│   ├── notifications_screen.dart # Notification center
│   ├── onboarding_screen.dart   # First-time user onboarding
│   ├── pet_health_screen.dart   # Pet health diary
│   ├── pet_profile_screen.dart  # Dedicated pet profile
│   ├── post_card.dart           # Reusable post card widget
│   ├── post_detail_screen.dart  # Full post view
│   ├── profile_screen.dart      # User profile with tabs
│   ├── search_screen.dart       # User and pet search
│   ├── signup_screen.dart       # User registration with pet details
│   ├── splash_screen.dart       # App loading animation
│   ├── story_view_screen.dart   # Story viewer with reactions
│   ├── user_list_screen.dart    # Followers/following list
│   └── vet_locator_screen.dart  # Google Maps vet finder
├── services/
│   └── notification_service.dart # FCM and local notifications
├── utils/
│   ├── constants.dart           # App-wide constants and colors
│   └── themes.dart              # Light and dark theme definitions
└── widgets/
    ├── bottom_nav_bar.dart      # Main navigation bar
    ├── post_widget.dart         # Post display widget
    ├── story_widget.dart        # Story display widget
    └── theme_switcher.dart      # Theme toggle widget
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode for mobile development
- Firebase project with enabled services

### Firebase Configuration
1. Create a Firebase project at console.firebase.google.com
2. Add Android app with package name
3. Download google-services.json and place in android/app/
4. Enable Authentication (Email/Password)
5. Enable Cloud Firestore
6. Enable Cloud Messaging
7. Enable Google Places API and Maps SDK in Google Cloud Console

### API Keys Required
Update the following in `lib/utils/constants.dart`:
- `geminiApiKey`: Google Generative AI API key for AI features

Update the following in `lib/screens/vet_locator_screen.dart`:
- `_placesApiKey`: Google Places API key for vet locator

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase as described above
4. Add API keys
5. Run `flutter run` on emulator or physical device

## Firestore Database Structure

### users collection
- username, email, uid, profileImage, bio
- followers, following, posts (counters)
- petName, petType, breed, petAge, petWeight, petBio, petGender, petImage
- fcmToken (for push notifications)
- lastAlertChecked (timestamp for alert badge)

### posts collection
- userId, username, userProfileImage
- postImage (base64), caption, likes (counter)
- timestamp

### stories collection
- uid, username, profileImage, storyImage (base64)
- timestamp

### chats collection (document: chatId)
- messages subcollection
  - senderId, receiverId, type (text/image), content, timestamp

### marketplace collection
- sellerId, sellerName, title, price, category, description
- image (base64), timestamp

### alerts collection
- uid, username, userImage
- text, color, height, location, phone, image (base64)
- timestamp

### users/{uid}/notifications subcollection
- type, fromId, username, userImage, message, timestamp, isRead

### users/{uid}/recent_chats subcollection
- chatWithId, username, profileImage, lastMessage, timestamp, unreadCount

## Known Limitations

- Image storage uses Base64 encoding in Firestore (not scalable for production)
- Google Maps API key requires Places API and Maps SDK enabled
- No pagination implemented for feeds (loads all at once)
- No offline support
- Story expiry not automated (24-hour expiration not enforced)

## Future Enhancements

- Implement Firebase Storage for image handling
- Add pagination for feeds and search results
- Implement story auto-expiry with Cloud Functions
- Add offline support with local caching
- Implement video posts and stories
- Add group chat functionality
- Implement post reporting and moderation
- Add analytics tracking
- Implement deep linking for notifications
- Add in-app purchase for marketplace
- Implement pet vaccination reminders
- Add pet weight tracking charts
