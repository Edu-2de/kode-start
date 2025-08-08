# Rick & Morty Game Backend API

A Node.js/Express.js RESTful API that powers the Rick & Morty character collection game. This backend handles user authentication, game logic, character management, and coin transactions.

## 🚀 Features

- **User Authentication**: JWT-based authentication with secure password hashing
- **Game Management**: Daily character unlock games and memory card challenges
- **Character System**: Integration with Rick & Morty API and rarity-based character collection
- **Coin Economy**: Complete coin transaction system with daily bonuses
- **Statistics Tracking**: Comprehensive game statistics and user progress
- **Database Management**: PostgreSQL with automated schema setup
- **Security**: Input validation, SQL injection protection, and CORS configuration

## 🏗️ Tech Stack

- **Runtime**: Node.js 16+
- **Framework**: Express.js 4.x
- **Database**: PostgreSQL 13+
- **Authentication**: JSON Web Tokens (JWT)
- **Password Hashing**: bcryptjs
- **HTTP Client**: axios
- **Environment**: dotenv
- **Development**: nodemon

## 📦 Installation

### Prerequisites

- Node.js (16.0.0 or higher)
- PostgreSQL (13.0 or higher)
- npm or yarn package manager

### Setup Steps

1. **Clone and Navigate**

   ```bash
   cd myProject/backend
   ```

2. **Install Dependencies**

   ```bash
   npm install
   ```

3. **Environment Configuration**
   Create a `.env` file in the root directory:

   ```env
   # Database Configuration
   DATABASE_URL=postgresql://username:password@localhost:5432/rickmorty_db

   # Or individual database variables
   DB_USER=postgres
   DB_HOST=localhost
   DB_NAME=rickmorty_db
   DB_PASSWORD=your_password
   DB_PORT=5432

   # JWT Secret (use a strong, unique secret in production)
   JWT_SECRET=your_very_secure_jwt_secret_here_min_32_chars

   # Server Configuration
   PORT=3001
   NODE_ENV=development

   # CORS Origins (comma-separated)
   CORS_ORIGIN=http://localhost:3000,http://10.0.2.2:3001
   ```

4. **Database Setup**

   ```bash
   # Create database
   createdb rickmorty_db

   # The application will automatically create tables on first run
   npm start
   ```

5. **Start Development Server**
   ```bash
   npm run dev
   ```

## 🎯 API Endpoints

### Authentication Routes

```
POST /api/auth/register    # Create new user account
POST /api/auth/login       # User login
GET  /api/auth/profile     # Get user profile (protected)
```

### Game Routes (All Protected)

```
# Character Games
POST /api/game/random-character    # Play daily character unlock game
GET  /api/game/can-play-random     # Check if can play today

# Memory Game
POST /api/game/memory-game/start   # Start memory card game
POST /api/game/memory-game/guess   # Submit memory game guess

# User Data
GET  /api/game/characters          # Get user's unlocked characters
GET  /api/game/stats              # Get detailed user statistics
POST /api/game/daily-bonus        # Claim daily coin bonus
```

### Health Check

```
GET  /health                      # Server health status
```

## 📊 Database Schema

### Core Tables

**users**

- Authentication data (email, password hash)
- Coin balance and transaction history
- User profile information
- Account creation timestamps

**unlocked_characters**

- User's character collection
- Character details from Rick & Morty API
- Rarity assignments and unlock timestamps
- Prevents duplicate character unlocks

**daily_character_games**

- Daily game play tracking
- Prevents multiple games per day
- Tracks coins spent and characters unlocked

**memory_game_results**

- Memory game performance tracking
- Score, completion time, success rate
- Coin rewards and game statistics

**coin_transactions**

- Complete transaction history
- Game costs, rewards, and daily bonuses
- Audit trail for all coin movements

**daily_bonuses**

- Daily login bonus tracking
- Prevents multiple bonuses per day
- Automatic coin distribution

## 🎮 Game Logic

### Random Character Game

- **Cost**: 10 coins per play
- **Frequency**: Once per day per user
- **Logic**:
  1. Validate user has sufficient coins
  2. Check daily play limit
  3. Fetch random character from Rick & Morty API
  4. Assign rarity (5% legendary, 10% epic, 25% rare, 60% common)
  5. Add to user's collection or notify if already owned
  6. Deduct coins and record transaction

### Memory Card Game

- **Cost**: 5 coins per session
- **Time Limit**: 60 seconds
- **Logic**:
  1. Generate 8 character pairs (16 cards total)
  2. Start memorization timer (3 seconds reveal)
  3. Accept user guesses and validate matches
  4. Calculate performance-based rewards
  5. Award bonus coins for fast completion

### Coin System

- **Starting Balance**: 50 coins for new users
- **Daily Bonus**: 5 coins per day
- **Game Rewards**: Variable based on performance
- **Transaction Logging**: All movements tracked

## 🔒 Security Features

### Authentication

- JWT tokens with expiration (1 hour default)
- bcrypt password hashing (salt rounds: 10)
- Protected routes with middleware validation

### Input Validation

- Email format validation
- Password strength requirements (8+ characters)
- SQL injection protection via parameterized queries
- Request body validation and sanitization

### CORS Configuration

- Configurable allowed origins
- Credentials support for authentication
- Development and production environment handling

## 🏃‍♂️ Available Scripts

```bash
npm start        # Start production server
npm run dev      # Start development server with nodemon
npm test         # Run test suite (to be implemented)
```

## 📁 Project Structure

```
backend/
├── src/
│   ├── controllers/
│   │   ├── authController.js      # Authentication logic
│   │   └── gameController.js      # Game and character logic
│   ├── database/
│   │   ├── connection.js          # Database connection setup
│   │   ├── setupDB.js            # Database initialization
│   │   └── sql/
│   │       └── schema.sql        # Database schema
│   ├── middleware/
│   │   └── authMiddleware.js     # JWT validation middleware
│   ├── routes/
│   │   ├── authRoutes.js         # Authentication endpoints
│   │   └── gameRoutes.js         # Game-related endpoints
│   └── app.js                    # Express application setup
├── server.js                     # Server entry point
├── package.json                  # Dependencies and scripts
├── .env.example                 # Environment variables template
└── README.md                    # This file
```

## 🧪 Testing

### Manual Testing

Use tools like Postman or curl to test endpoints:

```bash
# Register new user
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"John","email":"john@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'

# Play random character game (replace TOKEN)
curl -X POST http://localhost:3001/api/game/random-character \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json"
```

## 🚀 Deployment

### Environment Variables for Production

```env
NODE_ENV=production
DATABASE_URL=your_production_database_url
JWT_SECRET=your_very_secure_production_secret
PORT=3001
CORS_ORIGIN=https://yourapp.com
```

### Database Migration

The application automatically creates all necessary tables and indexes on startup. For production deployments, consider running migrations manually:

```sql
-- Run the contents of src/database/sql/schema.sql
```

## 📈 Performance Considerations

- **Database Indexing**: Optimized indexes for user queries
- **Connection Pooling**: PostgreSQL connection pool management
- **Rate Limiting**: Consider implementing for production
- **Caching**: Redis integration recommended for high traffic
- **Monitoring**: Add application performance monitoring

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Errors**

   - Verify PostgreSQL is running
   - Check DATABASE_URL format
   - Ensure database exists

2. **JWT Token Issues**

   - Verify JWT_SECRET is set
   - Check token expiration
   - Validate Authorization header format

3. **CORS Errors**
   - Configure CORS_ORIGIN properly
   - Ensure credentials are included in requests

### Debug Mode

Set `NODE_ENV=development` for detailed error messages and stack traces.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Backend API for Rick & Morty Character Collector Game**
