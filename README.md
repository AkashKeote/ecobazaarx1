# EcoBazaarX - Carbon Footprint Aware Shopping Assistant

A comprehensive Flutter web application that promotes sustainable shopping by helping users make eco-friendly choices while tracking their carbon footprint impact.

## 🌱 Features

### 🔐 Authentication System
- **Multi-role Login/Signup**: Support for Customers, Shopkeepers, and Admins
- **Secure Authentication**: Local storage with role-based access control
- **Beautiful UI**: Modern, responsive design with eco-friendly color schemes

### 👤 Customer Experience
- **Carbon Footprint Tracking**: Monitor your environmental impact while shopping
- **Eco-friendly Product Discovery**: Find sustainable alternatives to everyday items
- **Shopping Assistant**: Get recommendations based on sustainability criteria

### 🏪 Shopkeeper Dashboard
- **Store Management**: Complete store overview with key metrics
- **Product Management**: Add, edit, and manage eco-friendly products
- **Order Management**: Track orders and manage inventory
- **Sustainability Analytics**: Monitor your store's environmental impact
- **Sales Analytics**: Track performance and growth metrics

### 👨‍💼 Admin Dashboard
- **Platform Overview**: Comprehensive platform statistics and metrics
- **User Management**: Monitor and manage all platform users
- **Carbon Footprint Analytics**: Track overall platform sustainability impact
- **System Settings**: Configure platform parameters and thresholds
- **Sustainability Monitoring**: Ensure eco-friendly practices across the platform

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.27.0 or higher)
- Dart SDK (3.9.0 or higher)

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd ecobazaarx
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d chrome
```

### Building for Web
```bash
flutter build web --release --base-href=/EcoBazaarX/
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Main application entry point
├── providers/
│   └── auth_provider.dart   # Authentication and user management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart      # User login interface
│   │   └── signup_screen.dart     # User registration interface
│   ├── home/
│   │   └── home_screen.dart       # Main home screen
│   ├── admin/
│   │   └── admin_dashboard_screen.dart    # Admin dashboard
│   └── shopkeeper/
│       └── shopkeeper_dashboard_screen.dart # Shopkeeper dashboard
```

## 🎨 Design Features

- **Eco-friendly Color Scheme**: Green and blue tones representing sustainability
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Modern UI Components**: Cards, gradients, and smooth animations
- **Accessibility**: High contrast and readable typography
- **Material Design**: Following Flutter's Material Design guidelines

## 🔧 Technology Stack

- **Frontend**: Flutter Web
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences for user data
- **UI Framework**: Material Design components
- **Build Tool**: Flutter Web compiler

## 📱 User Roles

### Customer
- Browse eco-friendly products
- Track personal carbon footprint
- Make sustainable shopping decisions
- View environmental impact of purchases

### Shopkeeper
- Manage store and products
- Track sales and analytics
- Monitor sustainability metrics
- Handle customer orders

### Admin
- Oversee entire platform
- Manage users and shops
- Monitor platform sustainability
- Configure system settings

## 🌍 Sustainability Features

- **Carbon Footprint Calculation**: Track environmental impact
- **Eco-friendly Product Categories**: Organized sustainable shopping
- **Sustainability Scoring**: Rate products and stores
- **Environmental Impact Reports**: Detailed analytics and insights

## 🚀 Future Enhancements

- [ ] Real-time carbon footprint calculations
- [ ] Integration with sustainability databases
- [ ] Advanced analytics and reporting
- [ ] Mobile app development
- [ ] API integration for external data
- [ ] Machine learning recommendations

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support and questions, please open an issue in the repository.

---

**EcoBazaarX** - Making sustainable shopping accessible and engaging for everyone! 🌱♻️
