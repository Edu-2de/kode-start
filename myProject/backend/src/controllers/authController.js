const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const pool = require('../database/connection');

const authController = {
  // Registro de novo usuário
  register: async (req, res) => {
    const { name, email, password } = req.body;

    try {
      // Validações
      if (!name || !email || !password) {
        return res.status(400).json({
          error: 'Dados obrigatórios',
          message: 'Nome, email e senha são obrigatórios',
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          error: 'Senha muito curta',
          message: 'A senha deve ter pelo menos 6 caracteres',
        });
      }

      // Verificar se email já existe
      const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
      if (existingUser.rows.length > 0) {
        return res.status(409).json({
          error: 'Email já cadastrado',
          message: 'Este email já está em uso',
        });
      }

      // Hash da senha
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Criar usuário
      const newUser = await pool.query(
        'INSERT INTO users (name, email, password_hash, coins, total_coins_earned) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, email, coins',
        [name, email, hashedPassword, 50, 50] // 50 moedas iniciais
      );

      // Registrar transação de moedas iniciais
      await pool.query(
        'INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)',
        [newUser.rows[0].id, 'earn', 50, 'signup_bonus']
      );

      res.status(201).json({
        message: 'Usuário cadastrado com sucesso!',
        user: {
          id: newUser.rows[0].id,
          name: newUser.rows[0].name,
          email: newUser.rows[0].email,
          coins: newUser.rows[0].coins,
        },
      });
    } catch (error) {
      console.error('Erro no registro:', error);
      res.status(500).json({
        error: 'Erro interno do servidor',
        message: 'Erro ao criar conta',
      });
    }
  },

  // Login do usuário
  login: async (req, res) => {
    const { email, password } = req.body;

    try {
      // Validações
      if (!email || !password) {
        return res.status(400).json({
          error: 'Dados obrigatórios',
          message: 'Email e senha são obrigatórios',
        });
      }

      // Buscar usuário
      const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      if (userResult.rows.length === 0) {
        return res.status(401).json({
          error: 'Credenciais inválidas',
          message: 'Email ou senha incorretos',
        });
      }

      const user = userResult.rows[0];

      // Verificar senha
      const validPassword = await bcrypt.compare(password, user.password_hash);
      if (!validPassword) {
        return res.status(401).json({
          error: 'Credenciais inválidas',
          message: 'Email ou senha incorretos',
        });
      }

      // Processar login diário (dar moedas)
      const today = new Date().toISOString().split('T')[0];
      let dailyBonus = false;

      try {
        await pool.query('INSERT INTO daily_logins (user_id, login_date, coins_earned) VALUES ($1, $2, $3)', [
          user.id,
          today,
          10,
        ]);

        // Dar as moedas ao usuário
        await pool.query(
          'UPDATE users SET coins = coins + 10, total_coins_earned = total_coins_earned + 10 WHERE id = $1',
          [user.id]
        );

        // Registrar transação
        await pool.query(
          'INSERT INTO coin_transactions (user_id, transaction_type, amount, reason) VALUES ($1, $2, $3, $4)',
          [user.id, 'earn', 10, 'daily_login']
        );

        user.coins += 10; // Atualizar para resposta
        dailyBonus = true;
      } catch (dailyLoginError) {
        // Se der erro, provavelmente já fez login hoje
        console.log('Login diário já processado hoje para user:', user.id);
      }

      // Criar token JWT
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        process.env.JWT_SECRET || 'rick_morty_secret_key',
        { expiresIn: '7d' }
      );

      // Salvar sessão no banco
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7); // 7 dias

      await pool.query('INSERT INTO user_sessions (user_id, session_token, expires_at) VALUES ($1, $2, $3)', [
        user.id,
        token,
        expiresAt,
      ]);

      res.json({
        message: 'Login realizado com sucesso!',
        token,
        dailyBonus,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          coins: user.coins,
        },
      });
    } catch (error) {
      console.error('Erro no login:', error);
      res.status(500).json({
        error: 'Erro interno do servidor',
        message: 'Erro ao fazer login',
      });
    }
  },

  // Logout
  logout: async (req, res) => {
    try {
      const authHeader = req.headers['authorization'];
      const token = authHeader && authHeader.split(' ')[1];

      if (token) {
        // Remover sessão do banco
        await pool.query('DELETE FROM user_sessions WHERE session_token = $1', [token]);
      }

      res.json({ message: 'Logout realizado com sucesso!' });
    } catch (error) {
      console.error('Erro no logout:', error);
      res.status(500).json({
        error: 'Erro interno do servidor',
        message: 'Erro ao fazer logout',
      });
    }
  },

  // Verificar se token é válido
  verifyToken: async (req, res) => {
    res.json({
      message: 'Token válido',
      user: req.user,
    });
  },

  // Obter perfil do usuário
  getProfile: async (req, res) => {
    try {
      // Buscar dados atualizados do usuário
      const userResult = await pool.query(
        'SELECT id, name, email, coins, total_coins_earned, created_at FROM users WHERE id = $1',
        [req.user.id]
      );

      if (userResult.rows.length === 0) {
        return res.status(404).json({
          error: 'Usuário não encontrado',
        });
      }

      // Buscar estatísticas
      const unlockedCount = await pool.query(
        'SELECT COUNT(*) as count FROM user_unlocked_characters WHERE user_id = $1',
        [req.user.id]
      );

      const totalCharacters = await pool.query('SELECT COUNT(*) as count FROM characters');

      res.json({
        user: userResult.rows[0],
        stats: {
          unlockedCharacters: parseInt(unlockedCount.rows[0].count),
          totalCharacters: parseInt(totalCharacters.rows[0].count),
        },
      });
    } catch (error) {
      console.error('Erro ao buscar perfil:', error);
      res.status(500).json({
        error: 'Erro interno do servidor',
      });
    }
  },
};

module.exports = authController;
