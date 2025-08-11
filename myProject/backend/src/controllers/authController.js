import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { query } from '../config/database.js';

const { hash, compare } = bcrypt;
const { sign } = jwt;

const authController = {
  register: async (req, res) => {
    const { username, email, password } = req.body;
    try {
      if (!username || !email || !password) {
        return res.status(400).json({
          error: 'Required fields missing',
          message: 'Username, email and password are required',
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          message: 'Please provide a valid email address',
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          error: 'Password too short',
          message: 'Password must be at least 6 characters long',
        });
      }

      // Check if email already exists
      const existingUser = await query('SELECT id FROM users WHERE email = $1', [email]);
      if (existingUser.rows.length > 0) {
        return res.status(409).json({
          error: 'Email already registered',
          message: 'This email is already in use',
        });
      }

      // Hash password
      const saltRounds = 10;
      const hashedPassword = await hash(password, saltRounds);

      // Create user
      const newUser = await query(
        'INSERT INTO users (username, email, password_hash, coins, total_coins_earned) VALUES ($1, $2, $3, $4, $5) RETURNING id, username, email, coins',
        [username, email, hashedPassword, 50, 50] // 50 initial coins
      );

      // Register initial coins transaction
      await query('INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)', [
        newUser.rows[0].id,
        'earn',
        50,
        'signup_bonus',
      ]);

      res.status(201).json({
        message: 'User registered successfully!',
        success: true,
        user: {
          id: newUser.rows[0].id,
          username: newUser.rows[0].username,
          email: newUser.rows[0].email,
          coins: newUser.rows[0].coins,
        },
      });
    } catch (error) {
      console.error('Registration error:', error.message);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: 'Error creating account',
      });
    }
  },

  // User login
  login: async (req, res) => {
    const { email, password } = req.body;

    try {
      // Validations
      if (!email || !password) {
        return res.status(400).json({
          error: 'Required fields missing',
          message: 'Email and password are required',
        });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          error: 'Invalid email format',
          message: 'Please provide a valid email address',
        });
      }

      // Find user
      const userResult = await query('SELECT * FROM users WHERE email = $1', [email]);
      if (userResult.rows.length === 0) {
        return res.status(401).json({
          error: 'Invalid credentials',
          message: 'Email or password incorrect',
        });
      }

      const user = userResult.rows[0];

      // Verify password
      const validPassword = await compare(password, user.password_hash);
      if (!validPassword) {
        return res.status(401).json({
          error: 'Invalid credentials',
          message: 'Email or password incorrect',
        });
      }

      // Process daily login (give coins)
      const today = new Date().toISOString().split('T')[0];
      let dailyBonus = false;

      try {
        await query('INSERT INTO daily_logins (user_id, login_date, coins_earned) VALUES ($1, $2, $3)', [
          user.id,
          today,
          10,
        ]);

        // Give coins to user
        await query('UPDATE users SET coins = coins + 10, total_coins_earned = total_coins_earned + 10 WHERE id = $1', [
          user.id,
        ]);

        // Register transaction
        await query(
          'INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)',
          [user.id, 'earn', 10, 'daily_login']
        );

        user.coins += 10; // Update for response
        dailyBonus = true;
      } catch (dailyLoginError) {
        // If error, probably already logged in today
        console.log('Daily login already processed today for user:', user.id);
      }

      // Create JWT token
      const token = sign({ userId: user.id, email: user.email }, process.env.JWT_SECRET || 'rick_morty_secret_key', {
        expiresIn: '7d',
      });

      // Save session in database
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

      await query('INSERT INTO user_sessions (user_id, session_token, expires_at) VALUES ($1, $2, $3)', [
        user.id,
        token,
        expiresAt,
      ]);

      res.json({
        message: 'Login successful!',
        success: true,
        token,
        dailyBonus,
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          coins: user.coins,
        },
      });
    } catch (error) {
      console.error('Login error:', error.message);
      res.status(500).json({
        error: 'Internal server error',
        message: 'Error during login',
      });
    }
  },

  // Logout
  logout: async (req, res) => {
    try {
      const authHeader = req.headers['authorization'];
      const token = authHeader && authHeader.split(' ')[1];

      if (token) {
        // Remove session from database
        await query('DELETE FROM user_sessions WHERE session_token = $1', [token]);
      }

      res.json({ message: 'Logout successful!' });
    } catch (error) {
      console.error('Logout error:', error.message);
      res.status(500).json({
        error: 'Internal server error',
        message: 'Error during logout',
      });
    }
  },

  // Verify if token is valid
  verifyToken: async (req, res) => {
    res.json({
      message: 'Valid token',
      user: req.user,
    });
  },

  // Get user profile
  getProfile: async (req, res) => {
    try {
      // Get updated user data
      const userResult = await query(
        'SELECT id, username, email, coins, total_coins_earned, created_at FROM users WHERE id = $1',
        [req.user.id]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({
          error: 'User not found',
        });
      }

      // Get statistics
      const unlockedCount = await query('SELECT COUNT(*) as count FROM unlocked_characters WHERE user_id = $1', [
        req.user.id,
      ]);

      // Since we don't have a characters table, we'll use the Rick & Morty API total (826 characters)
      // Or we could make an API call to get the current total, but for performance we'll use a fixed number
      const totalCharacters = 826; // Total characters in Rick & Morty API

      res.json({
        user: userResult.rows[0],
        stats: {
          unlockedCharacters: parseInt(unlockedCount.rows[0].count),
          totalCharacters: totalCharacters,
        },
      });
    } catch (error) {
      console.error('Error fetching profile:', error.message);
      res.status(500).json({
        error: 'Internal server error',
      });
    }
  },
};

export const { register, login, logout, verifyToken, getProfile } = authController;
export default authController;
