# Firebase Integration for EcoBazaarX

## Overview
This project has been integrated with Firebase to provide real-time authentication, database, and analytics capabilities.

## Firebase Configuration

### Project Details
- **Project ID**: ecobazzarx
- **Project Name**: EcoBazaarX
- **Firebase Console**: https://console.firebase.google.com/project/ecobazzarx

### Configuration Files
1. **Web Configuration**: `web/firebase-config.js`
2. **HTML Integration**: `web/index.html` (includes Firebase SDK)
3. **Flutter Service**: `lib/services/firebase_service.dart`

## Features Implemented

### 🔐 Authentication
- **Email/Password Authentication**: Users can sign up and sign in
- **User Profiles**: User data stored in Firestore
- **Role-based Access**: Customer, Shopkeeper, Admin roles
- **Session Management**: Automatic login state persistence

### 📊 Database (Firestore)
- **Users Collection**: Store user profiles and roles
- **Stores Collection**: Store analytics and management
- **Products Collection**: Product catalog and details
- **Real-time Updates**: Live data synchronization

### 📈 Analytics
- **User Events**: Login, signup, logout tracking
- **Custom Events**: User actions and interactions
- **Performance Monitoring**: App performance metrics

### 🗄️ Storage
- **File Upload**: Product images and documents
- **Cloud Storage**: Scalable file storage solution

## Setup Instructions

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `ecobazzarx`
3. Enable Authentication (Email/Password)
4. Create Firestore database
5. Enable Storage
6. Configure Analytics

### 2. Flutter Dependencies
The following Firebase packages are included:
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.4.3
firebase_storage: ^12.3.3
firebase_analytics: ^11.3.3
```

### 3. Web Configuration
Firebase is configured for web platform with:
- Firebase SDK scripts in `web/index.html`
- Configuration in `web/firebase-config.js`
- Compatible with Flutter web builds

## Usage Examples

### Authentication
```dart
// Sign up
await FirebaseService.signUpWithEmailAndPassword(
  email, password, userName, role
);

// Sign in
await FirebaseService.signInWithEmailAndPassword(email, password);

// Sign out
await FirebaseService.signOut();
```

### Database Operations
```dart
// Get all users
List<Map<String, dynamic>> users = await FirebaseService.getAllUsers();

// Add user
await FirebaseService.addUser(userData);

// Update user
await FirebaseService.updateUser(userId, userData);

// Delete user
await FirebaseService.deleteUser(userId);
```

### Analytics
```dart
// Log custom events
await FirebaseService.logEvent('user_action', {
  'action_type': 'button_click',
  'screen': 'home'
});
```

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins can read all users
    match /users/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'Admin';
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing

### Local Development
1. Run `flutter pub get` to install dependencies
2. Start the app: `flutter run -d edge`
3. Test authentication flows
4. Verify real-time data updates

### Production Deployment
1. Build for web: `flutter build web`
2. Deploy to Firebase Hosting
3. Configure custom domain (optional)

## Troubleshooting

### Common Issues
1. **Firebase not initialized**: Ensure `FirebaseService.initializeFirebase()` is called in `main()`
2. **Authentication errors**: Check Firebase Console > Authentication settings
3. **Database permission errors**: Verify Firestore security rules
4. **Web build issues**: Ensure Firebase SDK scripts are loaded in `index.html`

### Debug Mode
Enable debug logging by checking console output for:
- Firebase initialization status
- Authentication state changes
- Database operation results
- Analytics event logging

## Next Steps

### Planned Features
- [ ] Push notifications
- [ ] Offline data sync
- [ ] Advanced analytics
- [ ] Multi-platform support (iOS/Android)
- [ ] Real-time chat
- [ ] Payment integration

### Performance Optimization
- [ ] Data caching strategies
- [ ] Lazy loading
- [ ] Image optimization
- [ ] Query optimization

## Support

For Firebase-related issues:
1. Check [Firebase Documentation](https://firebase.google.com/docs)
2. Review [Flutter Firebase Guide](https://firebase.flutter.dev)
3. Check Firebase Console for error logs
4. Verify configuration in `firebase-config.js`
