const jwt = require('jsonwebtoken');
const pool = require('../database/connection');

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      error: 'Token de acesso requerido',
      message: 'Você precisa estar logado para acessar este recurso',
    });
  }

  try {
    // Verificar se o token é válido
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'rick_morty_secret_key');

    // Verificar se a sessão ainda é válida no banco
    const sessionQuery = `
      SELECT s.*, u.id as user_id, u.name, u.email, u.coins 
      FROM user_sessions s 
      JOIN users u ON s.user_id = u.id 
      WHERE s.session_token = $1 AND s.expires_at > NOW()
    `;

    const sessionResult = await pool.query(sessionQuery, [token]);

    if (sessionResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Sessão expirada ou inválida',
        message: 'Por favor, faça login novamente',
      });
    }

    // Adicionar informações do usuário ao request
    req.user = {
      id: sessionResult.rows[0].user_id,
      name: sessionResult.rows[0].name,
      email: sessionResult.rows[0].email,
      coins: sessionResult.rows[0].coins,
    };

    next();
  } catch (error) {
    console.error('Erro na autenticação:', error);
    return res.status(403).json({
      error: 'Token inválido',
      message: 'Token de acesso inválido ou corrompido',
    });
  }
};

// Middleware opcional - não falha se não houver token
const optionalAuth = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'rick_morty_secret_key');

    const sessionQuery = `
      SELECT s.*, u.id as user_id, u.name, u.email, u.coins 
      FROM user_sessions s 
      JOIN users u ON s.user_id = u.id 
      WHERE s.session_token = $1 AND s.expires_at > NOW()
    `;

    const sessionResult = await pool.query(sessionQuery, [token]);

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

module.exports = {
  authenticateToken,
  optionalAuth,
};
