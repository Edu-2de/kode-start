import jwt from 'jsonwebtoken';
import { query } from '../config/database.js';

const { verify } = jwt;

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'No token provided',
      });
    }

    // Verify JWT token
    const decoded = verify(token, process.env.JWT_SECRET);

    // Check if session exists in database
    const sessionResult = await query('SELECT user_id, expires_at FROM user_sessions WHERE session_token = $1', [
      token,
    ]);

    if (sessionResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Invalid session',
      });
    }

    const session = sessionResult.rows[0];

    // Check if session is expired
    if (new Date() > new Date(session.expires_at)) {
      // Remove expired session
      await query('DELETE FROM user_sessions WHERE session_token = $1', [token]);
      return res.status(401).json({
        error: 'Access denied',
        message: 'Session expired',
      });
    }

    // Get user data
    const userResult = await query('SELECT id, username, email FROM users WHERE id = $1', [decoded.userId]);

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'User not found',
      });
    }

    req.user = userResult.rows[0];
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Invalid token',
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Token expired',
      });
    }

    return res.status(500).json({
      error: 'Internal server error',
      message: 'Authentication failed',
    });
  }
};

export default authMiddleware;
