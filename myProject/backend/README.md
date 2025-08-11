# Rick & Morty Game Backend API

A Node.js/Express.js RESTful API for a Rick & Morty character collection game with authentication, game mechanics, and coin economy.

<img src="./images/readme/architecture-diagram.png" alt="System Architecture" width="500">

## 🚀 Quick Start

### Prerequisites
- Node.js 16+
- PostgreSQL 13+

### Installation & Setup

```bash
cd myProject/backend
npm install
```

Create `.env` file:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/rickmorty_db
JWT_SECRET=your_very_secure_jwt_secret_here_min_32_chars
PORT=3001
CORS_ORIGIN=http://localhost:3000,http://10.0.2.2:3001
```

<img src="./images/readme/env-setup.png" alt="Environment Setup" width="500">

### Run
```bash
npm run dev    
npm start      
```

<img src="./images/readme/startup-demo.gif" alt="Backend Startup Demo" width="900">

## 🎯 Core Features

- **JWT Authentication** with secure password hashing
- **Daily Character Game** - Unlock random Rick & Morty characters (10 coins)
- **Memory Card Game** - Match character pairs for rewards (5 coins entry)
- **Daily Bonus System** - Free coins every 24 hours
- **Character Collection** with rarity system (Common → Rare → Epic → Legendary)
- **Coin Economy** with transaction tracking

<img src="./images/readme/game-flow.png" alt="Game Flow Diagram" width="500">

## 📡 API Endpoints

### Authentication
```
POST /api/auth/register    # Register new user
POST /api/auth/login       # User login
GET  /api/auth/profile     # Get user profile (protected)
```

### Game Routes (All Protected)
```
POST /api/game/random-character    # Play daily character unlock
POST /api/game/memory-game/start   # Start memory game session
POST /api/game/memory-game/guess   # Submit memory game guess
GET  /api/game/characters          # Get user's character collection
GET  /api/game/stats              # User game statistics
POST /api/game/daily-bonus        # Claim daily bonus coins
```

<img src="./images/readme/api-testing.png" alt="API Testing Example" width="300">

## 🗄️ Database Schema

**8 main tables** handling users, characters, games, and transactions:

- `users` - Authentication & coin balance
- `unlocked_characters` - User's character collection
- `daily_character_games` - Daily game sessions
- `memory_game_results` - Memory game statistics
- `coin_transactions` - All coin movements
- `daily_bonuses` - Daily bonus claims
- `daily_logins` - Login tracking
- `user_sessions` - Session management

<img src="./images/readme/database-schema.png" alt="Database ER Diagram" width="700">

## 🎮 Game Mechanics

### Character Unlock (Daily)
1. **Cost**: 10 coins per day
2. **Source**: Rick & Morty API (826+ characters)
3. **Rarity Distribution**: 60% Common, 25% Rare, 10% Epic, 5% Legendary
4. **Duplicates**: Returns coins if character already owned

### Memory Game
1. **Cost**: 5 coins per session
2. **Format**: 8 character pairs (16 cards)
3. **Time Limit**: 60 seconds
4. **Rewards**: Performance-based coin rewards

## 🔒 Security

- **JWT tokens** (1-hour expiration)
- **bcrypt hashing** (10 salt rounds)
- **SQL injection protection** (parameterized queries)
- **Input validation** on all endpoints
- **CORS configured** for Flutter frontend

## 📁 Project Structure

```
backend/
├── src/
│   ├── controllers/     # Route handlers & business logic
│   ├── database/        # DB connection & SQL schema
│   ├── middleware/      # JWT authentication middleware
│   ├── routes/          # API route definitions
│   └── app.js          # Express app configuration
├── server.js           # Entry point
├── package.json        # Dependencies & scripts
└── .env               # Environment variables
```

## 🧪 Quick Test

```bash
# Health check
curl http://localhost:3001/health

# Test registration
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'
```

<img src="./images/readme/curl-testing.png" alt="cURL Testing Example" width="700">

## 🚀 Production Setup

```env
NODE_ENV=production
DATABASE_URL=your_production_database_url
JWT_SECRET=your_production_secret_key
PORT=3001
```

Database tables auto-create on first startup.

## 🔧 Common Issues

- **DB Connection Failed**: Check PostgreSQL running & DATABASE_URL format
- **JWT Invalid**: Verify JWT_SECRET set & token not expired  
- **CORS Blocked**: Add your frontend URL to CORS_ORIGIN

<img src="./images/readme/troubleshooting.png" alt="Common Error Solutions" width="650">

---

**Tech Stack**: Express.js • PostgreSQL • JWT • bcrypt • Rick & Morty API