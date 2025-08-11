# Rick & Morty Game Backend API

A Node.js/Express.js RESTful API for a Rick & Morty character collection game with authentication, game mechanics, and coin economy.

<img src="./images/readme/diagram1.png" alt="Architecture Diagram" width="600">
<img src="./images/readme/diagram2.png" alt="Architecture Diagram" width="600">

## 🚀 Quick Start

### Prerequisites
- Node.js 16+
- PostgreSQL 13+

### Installation

```bash
cd myProject/backend
npm install
```

### Environment Setup
Create `.env` file:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/rickmorty_db
JWT_SECRET=your_very_secure_jwt_secret_here_min_32_chars
PORT=3001
CORS_ORIGIN=http://localhost:3000,http://10.0.2.2:3001
```

<img src="./images/readme/env.png" alt="Architecture Diagram" width="600">

### Run
```bash
npm run dev  # Development
npm start    # Production
```

<!-- ADD VIDEO: Quick demo of backend startup process and health check endpoint -->

## 🎯 Core Features

### Authentication System
- JWT-based auth with secure password hashing
- User registration and login

### Game Mechanics
- **Daily Character Game**: Unlock random characters (10 coins/day)
- **Memory Card Game**: Match character pairs (5 coins/session)
- **Daily Bonus**: Free coins every 24 hours

<!-- ADD IMAGE: Game flow diagram showing coin system and character unlock process -->

### Character Collection
- Rick & Morty API integration
- Rarity system (Common → Rare → Epic → Legendary)
- Duplicate prevention

<!-- ADD IMAGE: Character rarity distribution chart or example character cards with rarities -->

## 📡 API Endpoints

### Authentication
```
POST /api/auth/register    # User registration
POST /api/auth/login       # User login
GET  /api/auth/profile     # Get user profile
```

### Game Routes (Protected)
```
POST /api/game/random-character    # Play daily character game
POST /api/game/memory-game/start   # Start memory game
POST /api/game/memory-game/guess   # Submit memory guess
GET  /api/game/characters          # Get user's characters
GET  /api/game/stats              # User statistics
POST /api/game/daily-bonus        # Claim daily bonus
```

<!-- ADD IMAGE: API endpoint testing in Postman showing request/response examples -->

## 🗄️ Database Schema

### Key Tables
- **users**: Authentication, coins, profile data
- **unlocked_characters**: User's character collection
- **daily_character_games**: Daily game tracking
- **memory_game_results**: Memory game statistics
- **coin_transactions**: Complete transaction history

<!-- ADD IMAGE: Database ER diagram showing table relationships -->

## 🎮 Game Logic

### Character Unlock Game
1. Costs 10 coins (once per day)
2. Fetches random character from Rick & Morty API
3. Assigns rarity: 5% Legendary, 10% Epic, 25% Rare, 60% Common
4. Adds to collection or notifies if owned

<!-- ADD VIDEO: Screen recording of character unlock game flow -->

### Memory Card Game
1. Costs 5 coins per session
2. 8 character pairs (16 cards total)
3. 60-second time limit
4. Performance-based coin rewards

<!-- ADD VIDEO: Memory game gameplay demonstration -->

## 🔒 Security

- JWT tokens with 1-hour expiration
- bcrypt password hashing (10 salt rounds)
- SQL injection protection
- Input validation and sanitization
- CORS configuration

<!-- ADD IMAGE: Security flow diagram showing JWT validation process -->

## 📁 Project Structure

```
backend/
├── src/
│   ├── controllers/     # Business logic
│   ├── database/        # DB connection & schema
│   ├── middleware/      # Auth middleware
│   ├── routes/          # API endpoints
│   └── app.js          # Express setup
├── server.js           # Entry point
└── .env               # Environment variables
```

## 🧪 Testing

### Quick API Test
```bash
# Health check
curl http://localhost:3001/health

# Register user
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","email":"test@example.com","password":"password123"}'
```

<!-- ADD VIDEO: API testing demonstration using curl or Postman -->

## 🚀 Deployment

For production:
```env
NODE_ENV=production
DATABASE_URL=your_production_database_url
JWT_SECRET=your_production_secret
```

Database tables are auto-created on startup.

<!-- ADD IMAGE: Deployment architecture diagram or production environment setup -->

## 🔧 Troubleshooting

### Common Issues
- **Database Connection**: Check PostgreSQL is running and DATABASE_URL is correct
- **JWT Errors**: Verify JWT_SECRET is set and tokens aren't expired
- **CORS Issues**: Configure CORS_ORIGIN for your frontend URL

<!-- ADD IMAGE: Common error messages and their solutions -->

---

**Built with Express.js, PostgreSQL, and JWT Authentication**