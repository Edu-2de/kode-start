# Rick & Morty Character Collector

A full-stack mobile application built with Flutter and Node.js that allows users to collect Rick & Morty characters through interactive games.

## 🎮 Features

- **User Authentication**: Secure login and registration system
- **Character Collection**: Unlock and collect Rick & Morty characters
- **Daily Games**: 
  - Random Character Game (once per day)
  - Memory Card Game with timed challenges
- **Coin System**: Earn and spend coins to play games
- **Rarity System**: Characters have different rarity levels (Common, Rare, Epic, Legendary)
- **Statistics Tracking**: Detailed game statistics and progress tracking
- **Profile Management**: User profiles with achievements and settings
- **Responsive Design**: Modern dark theme with smooth animations

## 🏗️ Architecture

### Frontend (Flutter)
- **Language**: Dart
- **State Management**: Provider pattern
- **HTTP Client**: Built-in http package
- **Local Storage**: SharedPreferences for tokens
- **UI**: Custom Material Design with dark theme

### Backend (Node.js)
- **Framework**: Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT tokens with bcrypt
- **External API**: Rick and Morty API integration
- **Architecture**: RESTful API with MVC pattern

## 📁 Project Structure

```
rickmorty-game/
├── myProject/
│   ├── my_app/                 # Flutter frontend application
│   └── backend/                # Node.js backend API
├── docs/                       # Documentation files
└── README.md                   # Main project documentation
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Node.js (16.0.0 or higher)
- PostgreSQL (13.0 or higher)
- Android Studio / VS Code

### Backend Setup
1. Navigate to backend directory
2. Install dependencies: `npm install`
3. Create `.env` file with required environment variables
4. Run database migrations
5. Start server: `npm run dev`

### Frontend Setup
1. Navigate to Flutter app directory
2. Install dependencies: `flutter pub get`
3. Configure API endpoints
4. Run the app: `flutter run`

For detailed setup instructions, see the individual README files in the backend and frontend directories.

## 🎯 Game Mechanics

### Random Character Game
- Cost: 10 coins
- Frequency: Once per day
- Reward: Random Rick & Morty character with rarity-based chances

### Memory Game
- Cost: 5 coins
- Challenge: Memorize and match character cards within 60 seconds
- Reward: Coins based on performance (up to 20 coins with time bonus)

### Coin System
- Starting coins: 50
- Daily bonus: 5 coins
- Game rewards vary by performance
- Spend coins to unlock new games and characters

## 🏆 Achievements & Statistics

- Total characters collected
- Legendary characters unlocked
- Games played and won
- Win rate percentage
- Best completion times
- Total coins earned

## 🔧 Technical Details

### API Integration
- Rick and Morty API for character data
- Custom backend APIs for game logic
- Real-time coin and character synchronization

### Security Features
- JWT-based authentication
- Password hashing with bcrypt
- Protected API routes
- Input validation and sanitization

### Database Schema
- Users with authentication data
- Character collections with rarity
- Game session tracking
- Coin transaction history
- Daily game limitations

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Acknowledgments

- Rick and Morty API for character data
- Flutter team for the amazing framework
- Node.js and Express.js communities

## 📞 Support

For support, email support@rickmortyapp.com or create an issue in the GitHub repository.

---

**Developed with ❤️ by the Rick & Morty Game Team**
