# Rick & Morty Flutter App

A modern Flutter application for collecting Rick & Morty characters through interactive games. Features a sleek dark UI, real-time game mechanics, and comprehensive character management.

## 🎮 Features

### 🎯 Core Gameplay

- **Daily Character Game**: Unlock random Rick & Morty characters once per day
- **Memory Card Game**: Timed memory challenges with character cards
- **Character Collection**: Browse and manage your unlocked characters
- **Rarity System**: Common, Rare, Epic, and Legendary character tiers

### 👤 User Experience

- **Secure Authentication**: Login/register with email and password
- **Profile Management**: View stats, achievements, and account settings
- **Real-time Updates**: Live coin balance and character synchronization
- **Responsive Design**: Optimized for various screen sizes

### 🎨 Modern UI/UX

- **Dark Theme**: Eye-friendly dark mode with accent colors
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Custom Components**: Specialized widgets for character cards and game elements
- **Navigation**: Intuitive drawer navigation and profile dropdown menus

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider pattern
- **HTTP Client**: Built-in http package
- **Local Storage**: SharedPreferences for secure token storage
- **Image Handling**: NetworkImage with error fallbacks
- **Platform**: Android & iOS support

## 📦 Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android device/emulator or iOS simulator

### Setup Steps

1. **Flutter Setup**

   ```bash
   # Verify Flutter installation
   flutter doctor

   # Navigate to app directory
   cd myProject/my_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **API Configuration**
   The app is configured to work with the backend API:

   - **Development**: `http://10.0.2.2:3001` (Android emulator)
   - **iOS Simulator**: `http://localhost:3001`
   - **Physical Device**: Update IP address in services

4. **Run the Application**

   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release

   # Specific platform
   flutter run -d android
   flutter run -d ios
   ```

## 📱 App Structure

### 🏗️ Architecture

```
lib/
├── main.dart                     # App entry point and routing
├── models/
│   └── character.dart           # Character data models
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   └── theme_provider.dart      # Theme and UI state
├── screens/
│   ├── home_screen.dart         # Main dashboard
│   ├── login_screen.dart        # User authentication
│   ├── sign_up_screen.dart      # User registration
│   ├── games_screen.dart        # Game selection hub
│   ├── memory_game_screen.dart  # Memory card game
│   ├── my_characters_screen.dart # Character collection
│   ├── profile_screen.dart      # User profile and stats
│   ├── game_stats_screen.dart   # Detailed game statistics
│   ├── settings_screen.dart     # App preferences
│   ├── search_screen.dart       # Character search
│   └── filter_screen.dart       # Character filtering
├── services/
│   ├── auth_service.dart        # Authentication API calls
│   ├── game_service.dart        # Game-related API calls
│   └── rick_and_morty_service.dart # External API integration
└── widgets/
    ├── custom_drawer.dart       # Navigation drawer
    ├── profile_menu_new.dart    # Profile dropdown menu
    ├── character_card_modern.dart # Character display cards
    └── character_card_classic.dart # Alternative card style
```

### 🎮 Key Screens

#### Home Screen

- Dashboard with quick access to games
- User coin balance display
- Recent activity and achievements
- Navigation to all app sections

#### Games Screen

- Available games with cost display
- Daily game timers and availability status
- Game performance statistics
- Quick access to game modes

#### Character Collection

- Grid view of unlocked characters
- Rarity-based filtering and sorting
- Character details and information
- Collection statistics and progress

#### Profile & Stats

- User account information
- Detailed game statistics
- Achievement tracking
- Settings and preferences

## 🎯 Game Mechanics

### Random Character Game

```dart
// Daily character unlock mechanics
- Cost: 10 coins per play
- Frequency: Once per 24 hours
- Rewards: Random character with rarity chances
- Timer: Countdown to next availability
```

### Memory Card Game

```dart
// Memory challenge mechanics
- Cost: 5 coins per session
- Time Limit: 60 seconds
- Objective: Memorize and match character pairs
- Rewards: Performance-based coin rewards (5-20 coins)
- Bonus: Time completion bonuses
```

### Coin System

```dart
// In-app economy
- Starting Balance: 50 coins
- Daily Bonus: 5 coins (once per day)
- Game Costs: 5-10 coins per game
- Rewards: Variable based on performance
- Persistence: Synchronized with backend
```

## 🔧 Configuration

### API Endpoints

Update the base URLs in service files based on your backend deployment:

```dart
// services/auth_service.dart
class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3001/api';
  // Change to your backend URL
}
```

### Theme Customization

Modify the theme in `providers/theme_provider.dart`:

```dart
class ThemeProvider extends ChangeNotifier {
  // Customize colors, typography, and component styles
  static const Color primaryColor = Colors.green;
  static const Color backgroundColor = Colors.black;
}
```

## 📊 State Management

### Provider Pattern

The app uses Provider for state management:

```dart
// Authentication state
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    // Login logic with state updates
  }
}

// Theme state
class ThemeProvider extends ChangeNotifier {
  AppStyle _currentStyle = AppStyle.modern;

  void toggleStyle() {
    _currentStyle = _currentStyle == AppStyle.modern
        ? AppStyle.classic
        : AppStyle.modern;
    notifyListeners();
  }
}
```

## 🎨 UI Components

### Custom Widgets

#### Character Cards

```dart
// Modern card design with rarity indicators
CharacterCardModern(
  character: character,
  onTap: () => navigateToDetail(character),
  showRarity: true,
)
```

#### Navigation Components

```dart
// Drawer navigation
CustomDrawer(
  currentRoute: '/home',
  onItemSelected: (route) => Navigator.pushNamed(context, route),
)

// Profile menu with dropdown
ProfileMenu(
  user: currentUser,
  onLogout: () => logout(),
)
```

## 🔒 Security Features

### Token Management

```dart
// Secure token storage using SharedPreferences
class AuthService {
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
```

### API Security

- JWT token authentication
- Automatic token refresh handling
- Secure HTTP headers
- Error handling for authentication failures

## 🧪 Testing

### Unit Tests

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

### Widget Tests

```bash
# Test individual widgets
flutter test test/widgets/
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/
```

## 📱 Platform-Specific Features

### Android

- Material Design 3 components
- Adaptive layouts for different screen sizes
- Back gesture handling
- Notification support (future enhancement)

### iOS

- Cupertino design elements where appropriate
- Safe area handling
- iOS-specific navigation patterns
- Native iOS animations

## 🚀 Performance Optimization

### Image Loading

- NetworkImage with caching
- Error fallback images
- Progressive loading indicators
- Memory-efficient image rendering

### State Management

- Efficient Provider usage
- Selective widget rebuilding
- Lazy loading for large lists
- Proper disposal of resources

### Animation Performance

- Optimized animation controllers
- GPU-accelerated transitions
- Reduced overdraw in complex layouts
- Efficient gesture recognition

## 🔧 Troubleshooting

### Common Issues

1. **API Connection Errors**

   ```bash
   # Check backend server is running
   # Verify API URLs in service files
   # Test network connectivity
   ```

2. **Authentication Issues**

   ```bash
   # Clear app storage: flutter clean
   # Check token expiration
   # Verify login credentials
   ```

3. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

### Debug Mode

- Enable detailed logging in development
- Use Flutter Inspector for UI debugging
- Network traffic monitoring with proxy tools
- Performance profiling with Flutter DevTools

## 📈 Future Enhancements

### Planned Features

- [ ] Push notifications for daily bonuses
- [ ] Social features (friends, leaderboards)
- [ ] Additional game modes
- [ ] Character trading system
- [ ] Offline mode support
- [ ] Achievement system expansion

### Technical Improvements

- [ ] Unit test coverage expansion
- [ ] Integration test suite
- [ ] Performance monitoring
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Flutter style guidelines
4. Add tests for new features
5. Ensure all tests pass
6. Submit a pull request

### Code Style

- Follow official Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License.

---

**Flutter Frontend for Rick & Morty Character Collector Game**
