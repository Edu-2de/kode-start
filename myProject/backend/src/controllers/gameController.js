import { query } from '../config/database.js';
import axios from 'axios';

const { get } = axios;

class GameController {
  constructor() {
    // Initialize the activeMemoryGames Map in the constructor
    this.activeMemoryGames = new Map();
  }

  // Random Character Game - Only once per day
  async playRandomCharacterGame(req, res) {
    const userId = req.user.id;
    const UNLOCK_COST = 10; // Cost in coins to unlock a character

    try {
      // Check if user already played today
      const today = new Date().toISOString().split('T')[0];
      const todayGame = await query('SELECT * FROM daily_character_games WHERE user_id = $1 AND game_date = $2', [
        userId,
        today,
      ]);

      if (todayGame.rows.length > 0) {
        const nextGameTime = new Date();
        nextGameTime.setDate(nextGameTime.getDate() + 1);
        nextGameTime.setHours(0, 0, 0, 0);

        return res.status(400).json({
          error: 'Daily character game already played',
          message: 'You can only unlock one random character per day',
          nextGameAvailable: nextGameTime.toISOString(),
          timeRemaining: this.getTimeRemaining(nextGameTime),
        });
      }

      // Check if user has enough coins
      const userResult = await query('SELECT coins FROM users WHERE id = $1', [userId]);

      if (userResult.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      const userCoins = userResult.rows[0].coins;

      if (userCoins < UNLOCK_COST) {
        return res.status(400).json({
          error: 'Not enough coins',
          required: UNLOCK_COST,
          current: userCoins,
        });
      }

      // Get a random character from Rick and Morty API
      const randomId = Math.floor(Math.random() * 826) + 1; // Rick and Morty has 826+ characters
      const response = await get(`https://rickandmortyapi.com/api/character/${randomId}`);
      const character = response.data;

      // Check if user already has this character
      const existingCharacter = await query(
        'SELECT * FROM unlocked_characters WHERE user_id = $1 AND character_id = $2',
        [userId, character.id]
      );

      if (existingCharacter.rows.length > 0) {
        // If already unlocked, give bonus coins instead
        const bonusCoins = 5;
        await query('UPDATE users SET coins = coins + $1 WHERE id = $2', [bonusCoins, userId]);

        // Record the game as played today
        await query(
          'INSERT INTO daily_character_games (user_id, game_date, character_id, already_owned, bonus_coins) VALUES ($1, $2, $3, $4, $5)',
          [userId, today, character.id, true, bonusCoins]
        );

        return res.json({
          success: true,
          message: 'Character already unlocked! Bonus coins received.',
          character,
          bonusCoins,
          alreadyUnlocked: true,
        });
      }

      // Deduct coins from user
      await query('UPDATE users SET coins = coins - $1 WHERE id = $2', [UNLOCK_COST, userId]);

      // Determine rarity based on character status
      let rarity = 'common';
      if (character.status === 'Dead') {
        rarity = 'rare';
      } else if (character.status === 'unknown') {
        rarity = 'epic';
      } else if (character.name.toLowerCase().includes('rick') || character.name.toLowerCase().includes('morty')) {
        rarity = 'legendary';
      }

      // Save unlocked character
      await query(
        'INSERT INTO unlocked_characters (user_id, character_id, character_name, character_image, character_status, character_species, character_location, rarity, unlocked_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())',
        [
          userId,
          character.id,
          character.name,
          character.image,
          character.status,
          character.species,
          character.location.name,
          rarity,
        ]
      );

      // Record the game as played today
      await query(
        'INSERT INTO daily_character_games (user_id, game_date, character_id, already_owned, coins_spent) VALUES ($1, $2, $3, $4, $5)',
        [userId, today, character.id, false, UNLOCK_COST]
      );

      // Record coin transaction
      await query('INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)', [
        userId,
        'spend',
        UNLOCK_COST,
        'random_character_game',
      ]);

      // Get updated user coins
      const updatedUserResult = await query('SELECT coins FROM users WHERE id = $1', [userId]);

      res.json({
        success: true,
        message: 'Character unlocked successfully!',
        character: {
          ...character,
          rarity,
        },
        coinsSpent: UNLOCK_COST,
        remainingCoins: updatedUserResult.rows[0].coins,
      });
    } catch (error) {
      console.error('Error in random character game:', error);
      if (error.response && error.response.status === 404) {
        // If character not found, try another random ID
        return this.playRandomCharacterGame(req, res);
      }
      res.status(500).json({ error: 'Failed to play random character game' });
    }
  }

  // Memory Card Game - 3 cards, find the character
  async playMemoryGame(req, res) {
    const userId = req.user.id;
    const GAME_COST = 5;

    try {
      // Check if user has enough coins
      const userResult = await query('SELECT coins FROM users WHERE id = $1', [userId]);
      if (userResult.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      const userCoins = userResult.rows[0].coins;
      if (userCoins < GAME_COST) {
        return res.status(400).json({
          error: 'Not enough coins',
          required: GAME_COST,
          current: userCoins,
        });
      }

      // Get a random character
      const randomId = Math.floor(Math.random() * 826) + 1;
      const response = await get(`https://rickandmortyapi.com/api/character/${randomId}`);
      const character = response.data;

      // Create game session
      const gameSession = {
        id: Date.now().toString(),
        userId: userId,
        character: character,
        correctPosition: Math.floor(Math.random() * 3), // 0, 1, or 2
        cards: [
          { id: 0, hasCharacter: false },
          { id: 1, hasCharacter: false },
          { id: 2, hasCharacter: false },
        ],
        revealed: true, // Initially cards are revealed for memorization
        gameStartTime: new Date(),
        coinsSpent: GAME_COST,
      };

      // Set which card has the character
      gameSession.cards[gameSession.correctPosition].hasCharacter = true;

      // Deduct coins
      await query('UPDATE users SET coins = coins - $1 WHERE id = $2', [GAME_COST, userId]);

      // Store game session temporarily (in a real app, you'd use Redis or similar)
      this.activeMemoryGames.set(gameSession.id, gameSession);

      // Clean up old games (older than 5 minutes)
      this.cleanupOldGames();

      res.json({
        success: true,
        gameId: gameSession.id,
        character: {
          name: character.name,
          image: character.image,
          species: character.species,
        },
        cards: gameSession.cards,
        message: 'Memorize the character position! Cards will be shuffled.',
        timeToMemorize: 3000, // 3 seconds to memorize
        coinsSpent: GAME_COST,
      });
    } catch (error) {
      console.error('Error starting memory game:', error);
      res.status(500).json({ error: 'Failed to start memory game' });
    }
  }

  // Submit memory game guess
  async submitMemoryGameGuess(req, res) {
    const { gameId, selectedPosition } = req.body;
    const userId = req.user.id;

    try {
      if (!this.activeMemoryGames.has(gameId)) {
        return res.status(400).json({
          error: 'Game not found or expired',
          message: 'Please start a new game',
        });
      }

      const gameSession = this.activeMemoryGames.get(gameId);

      if (gameSession.userId !== userId) {
        return res.status(403).json({ error: 'Not your game' });
      }

      const isCorrect = selectedPosition === gameSession.correctPosition;
      let reward = 0;

      if (isCorrect) {
        // Check if user already has this character
        const existingCharacter = await query(
          'SELECT * FROM unlocked_characters WHERE user_id = $1 AND character_id = $2',
          [userId, gameSession.character.id]
        );

        if (existingCharacter.rows.length === 0) {
          // Unlock the character
          let rarity = 'common';
          if (gameSession.character.status === 'Dead') {
            rarity = 'rare';
          } else if (gameSession.character.status === 'unknown') {
            rarity = 'epic';
          } else if (
            gameSession.character.name.toLowerCase().includes('rick') ||
            gameSession.character.name.toLowerCase().includes('morty')
          ) {
            rarity = 'legendary';
          }

          await query(
            'INSERT INTO unlocked_characters (user_id, character_id, character_name, character_image, character_status, character_species, character_location, rarity, unlocked_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())',
            [
              userId,
              gameSession.character.id,
              gameSession.character.name,
              gameSession.character.image,
              gameSession.character.status,
              gameSession.character.species,
              gameSession.character.location.name,
              rarity,
            ]
          );

          reward = 15; // Character unlock reward
        } else {
          reward = 8; // Already have character, smaller reward
        }

        // Give reward coins
        await query('UPDATE users SET coins = coins + $1 WHERE id = $2', [reward, userId]);

        // Record coin transaction
        await query(
          'INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)',
          [userId, 'earn', reward, 'memory_game_win']
        );
      }

      // Record game result
      await query(
        'INSERT INTO memory_game_results (user_id, character_id, correct_guess, coins_earned, game_date) VALUES ($1, $2, $3, $4, NOW())',
        [userId, gameSession.character.id, isCorrect, reward]
      );

      // Clean up game session
      this.activeMemoryGames.delete(gameId);

      // Get updated coins
      const userResult = await query('SELECT coins FROM users WHERE id = $1', [userId]);

      res.json({
        success: true,
        correct: isCorrect,
        correctPosition: gameSession.correctPosition,
        character: gameSession.character,
        coinsEarned: reward,
        totalCoins: userResult.rows[0].coins,
        message: isCorrect ? 'Correct! Well done!' : 'Wrong choice! Better luck next time.',
      });
    } catch (error) {
      console.error('Error submitting memory game guess:', error);
      res.status(500).json({ error: 'Failed to submit guess' });
    }
  }

  // Helper method to calculate time remaining
  getTimeRemaining(nextTime) {
    const now = new Date();
    const diff = nextTime - now;

    if (diff <= 0) return null;

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

    return {
      hours,
      minutes,
      total: diff,
    };
  }

  // Helper method to clean up old game sessions
  cleanupOldGames() {
    const now = new Date();
    const maxAge = 5 * 60 * 1000; // 5 minutes

    for (const [gameId, session] of this.activeMemoryGames.entries()) {
      if (now - session.gameStartTime > maxAge) {
        this.activeMemoryGames.delete(gameId);
      }
    }
  }

  // Check if user can play random character game today
  async canPlayRandomGame(req, res) {
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];

    try {
      const todayGame = await query('SELECT * FROM daily_character_games WHERE user_id = $1 AND game_date = $2', [
        userId,
        today,
      ]);

      if (todayGame.rows.length > 0) {
        const nextGameTime = new Date();
        nextGameTime.setDate(nextGameTime.getDate() + 1);
        nextGameTime.setHours(0, 0, 0, 0);

        return res.json({
          canPlay: false,
          nextGameAvailable: nextGameTime.toISOString(),
          timeRemaining: this.getTimeRemaining(nextGameTime),
          message: 'You can only play once per day',
        });
      }

      res.json({
        canPlay: true,
        message: 'You can play the random character game!',
      });
    } catch (error) {
      console.error('Error checking game availability:', error);
      res.status(500).json({ error: 'Failed to check game availability' });
    }
  }

  // Get user's unlocked characters
  async getUserCharacters(req, res) {
    const userId = req.user.id;

    try {
      const result = await query('SELECT * FROM unlocked_characters WHERE user_id = $1 ORDER BY unlocked_at DESC', [
        userId,
      ]);

      res.json({
        characters: result.rows,
        totalUnlocked: result.rows.length,
      });
    } catch (error) {
      console.error('Error fetching user characters:', error);
      res.status(500).json({ error: 'Failed to fetch characters' });
    }
  }

  // Get daily login bonus
  async getDailyBonus(req, res) {
    const userId = req.user.id;
    const DAILY_BONUS = 5;

    try {
      // Check if user already claimed today's bonus
      const today = new Date().toISOString().split('T')[0];
      const bonusResult = await query('SELECT * FROM daily_bonuses WHERE user_id = $1 AND claimed_date = $2', [
        userId,
        today,
      ]);

      if (bonusResult.rows.length > 0) {
        return res.status(400).json({
          error: 'Daily bonus already claimed today',
          nextClaim: 'tomorrow',
        });
      }

      // Give daily bonus
      await query('UPDATE users SET coins = coins + $1 WHERE id = $2', [DAILY_BONUS, userId]);

      // Record the bonus claim
      await query('INSERT INTO daily_bonuses (user_id, coins_received, claimed_date) VALUES ($1, $2, $3)', [
        userId,
        DAILY_BONUS,
        today,
      ]);

      // Get updated user coins
      const userResult = await query('SELECT coins FROM users WHERE id = $1', [userId]);

      res.json({
        message: 'Daily bonus claimed!',
        coinsReceived: DAILY_BONUS,
        totalCoins: userResult.rows[0].coins,
      });
    } catch (error) {
      console.error('Error claiming daily bonus:', error);
      res.status(500).json({ error: 'Failed to claim daily bonus' });
    }
  }

  // Get user stats
  async getUserStats(req, res) {
    const userId = req.user.id;

    try {
      // Get user info
      const userResult = await query('SELECT username, coins, created_at FROM users WHERE id = $1', [userId]);

      if (userResult.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      // Get character stats
      const statsResult = await query(
        `
        SELECT 
          COUNT(*) as total_characters,
          COUNT(CASE WHEN rarity = 'common' THEN 1 END) as common_count,
          COUNT(CASE WHEN rarity = 'rare' THEN 1 END) as rare_count,
          COUNT(CASE WHEN rarity = 'epic' THEN 1 END) as epic_count,
          COUNT(CASE WHEN rarity = 'legendary' THEN 1 END) as legendary_count
        FROM unlocked_characters 
        WHERE user_id = $1
      `,
        [userId]
      );

      // Get login streak
      const bonusResult = await query(
        `
        SELECT COUNT(*) as login_days
        FROM daily_bonuses 
        WHERE user_id = $1
      `,
        [userId]
      );

      const user = userResult.rows[0];
      const stats = statsResult.rows[0];
      const loginStats = bonusResult.rows[0];

      res.json({
        user: {
          username: user.username,
          coins: user.coins,
          memberSince: user.created_at,
        },
        characters: {
          total: parseInt(stats.total_characters),
          common: parseInt(stats.common_count),
          rare: parseInt(stats.rare_count),
          epic: parseInt(stats.epic_count),
          legendary: parseInt(stats.legendary_count),
        },
        loginDays: parseInt(loginStats.login_days),
      });
    } catch (error) {
      console.error('Error fetching user stats:', error);
      res.status(500).json({ error: 'Failed to fetch user stats' });
    }
  }
}

export default GameController;
