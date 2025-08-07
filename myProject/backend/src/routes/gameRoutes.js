const express = require('express');
const router = express.Router();
const GameController = require('../controllers/gameController');
const authMiddleware = require('../middleware/authMiddleware');

// Create instance of GameController
const gameController = new GameController();

// All game routes require authentication
router.use(authMiddleware);

// Random Character Game (once per day)
router.post('/random-character', gameController.playRandomCharacterGame.bind(gameController));
router.get('/can-play-random', gameController.canPlayRandomGame.bind(gameController));

// Memory Card Game
router.post('/memory-game/start', gameController.playMemoryGame.bind(gameController));
router.post('/memory-game/guess', gameController.submitMemoryGameGuess.bind(gameController));

// Get user's unlocked characters
router.get('/characters', gameController.getUserCharacters.bind(gameController));

// Claim daily bonus
router.post('/daily-bonus', gameController.getDailyBonus.bind(gameController));

// Get user stats
router.get('/stats', gameController.getUserStats.bind(gameController));

// Legacy route (keep for compatibility)
router.post('/unlock-character', gameController.playRandomCharacterGame.bind(gameController));

module.exports = router;
