import { verify } from 'jsonwebtoken';
import { query } from '../database/connection';

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      error: 'Access token required',
      message: 'You must be logged in to access this feature.',
    });
  }

  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'rick_morty_secret_key');

    const sessionQuery = `
      SELECT s.*, u.id as user_id, u.name, u.email, u.coins 
      FROM user_sessions s 
      JOIN users u ON s.user_id = u.id 
      WHERE s.session_token = $1 AND s.expires_at > NOW()
    `;

    const sessionResult = await query(sessionQuery, [token]);

    if (sessionResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Session expired or invalid',
        message: 'Please log in again',
      });
    }

    req.user = {
      id: sessionResult.rows[0].user_id,
      name: sessionResult.rows[0].name,
      email: sessionResult.rows[0].email,
      coins: sessionResult.rows[0].coins,
    };

    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(403).json({
      error: 'Invalid token',
      message: 'Invalid or corrupted access token',
    });
  }
};

const optionalAuth = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = verify(token, process.env.JWT_SECRET || 'rick_morty_secret_key');

    const sessionQuery = `
      SELECT s.*, u.id as user_id, u.name, u.email, u.coins 
      FROM user_sessions s 
      JOIN users u ON s.user_id = u.id 
      WHERE s.session_token = $1 AND s.expires_at > NOW()
    `;

    const sessionResult = await query(sessionQuery, [token]);

    if (sessionResult.rows.length > 0) {
      req.user = {
        id: sessionResult.rows[0].user_id,
        name: sessionResult.rows[0].name,
        email: sessionResult.rows[0].email,
        coins: sessionResult.rows[0].coins,
      };
    } else {
      req.user = null;
    }
  } catch (error) {
    req.user = null;
  }

  next();
};

export default {
  authenticateToken,
  optionalAuth,
};
