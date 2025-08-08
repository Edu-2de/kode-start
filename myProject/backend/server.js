// Load environment variables
import dotenv from 'dotenv';
dotenv.config();

import app from './src/app.js';
import { setupDB, testConnection } from './src/database/setupDB.js';

// Check if required environment variables are set
const requiredEnvVars = ['DATABASE_URL', 'JWT_SECRET'];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
  console.error('❌ Required environment variables not found:');
  missingVars.forEach(varName => {
    console.error(`   - ${varName}`);
  });
  console.error('\n📝 Create a .env file in the project root with these variables.');
  console.error('Example:');
  console.error('DATABASE_URL=postgresql://username:password@localhost:5432/rickmorty_db');
  console.error('JWT_SECRET=your_very_secure_jwt_secret_here');
  process.exit(1);
}

// Log configuration (without showing sensitive data)
console.log('⚙️  Loaded configuration:');
console.log(`   📊 NODE_ENV: ${process.env.NODE_ENV || 'development'}`);
console.log(`   🚀 PORT: ${process.env.PORT || 3000}`);
console.log(`   🗄️  DATABASE: ${process.env.DATABASE_URL ? '✅ Set' : '❌ Not set'}`);
console.log(`   🔐 JWT_SECRET: ${process.env.JWT_SECRET ? '✅ Set' : '❌ Not set'}`);
console.log('');

// Initialize database and start server
async function startServer() {
  try {
    // Test database connection
    const connected = await testConnection();
    if (!connected) {
      console.error('💥 Cannot connect to database');
      process.exit(1);
    }

    // Setup database (create tables if they don't exist)
    await setupDB();

    // Start server
    const PORT = process.env.PORT || 3000;

    const server = app.listen(PORT, () => {
      console.log('🎮 Rick & Morty Game API');
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`🌐 Health check: http://localhost:${PORT}/health`);
      console.log(`📱 API Base URL: http://localhost:${PORT}/api`);
      console.log('');
      console.log('Available endpoints:');
      console.log('📝 POST /api/auth/register - Register account');
      console.log('🔐 POST /api/auth/login - Login');
      console.log('👤 GET /api/auth/profile - User profile');
      console.log('🎯 POST /api/game/unlock-character - Unlock character');
      console.log('👥 GET /api/game/characters - List characters');
      console.log('🎁 POST /api/game/daily-bonus - Daily bonus');
      console.log('📊 GET /api/game/stats - Statistics');
      console.log('');
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      console.log('🛑 SIGTERM received. Shutting down server...');
      server.close(() => {
        console.log('✅ Server shut down successfully.');
        process.exit(0);
      });
    });

    process.on('SIGINT', () => {
      console.log('🛑 SIGINT received. Shutting down server...');
      server.close(() => {
        console.log('✅ Server shut down successfully.');
        process.exit(0);
      });
    });

    return server;
  } catch (error) {
    console.error('💥 Failed to start server:', error);
    process.exit(1);
  }
}

// Start the server
startServer();
