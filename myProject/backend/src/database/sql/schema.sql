-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  coins INTEGER NOT NULL DEFAULT 50, -- Moedas iniciais ao criar conta
  total_coins_earned INTEGER NOT NULL DEFAULT 50, -- Total de moedas ganhas historicamente
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de personagens desbloqueados pelos usuários (salvamos dados da API aqui)
CREATE TABLE IF NOT EXISTS user_unlocked_characters (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  character_api_id INTEGER NOT NULL, -- ID do personagem na API Rick and Morty
  character_name VARCHAR(100) NOT NULL,
  character_status VARCHAR(20) NOT NULL,
  character_species VARCHAR(50) NOT NULL,
  character_gender VARCHAR(20) NOT NULL,
  character_image VARCHAR(500) NOT NULL,
  character_rarity VARCHAR(20) NOT NULL DEFAULT 'common', -- common, rare, epic, legendary
  character_origin VARCHAR(200),
  character_location VARCHAR(200),
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, character_api_id) -- Evita que o usuário desbloqueie o mesmo personagem duas vezes
);

-- Tabela de histórico de transações de moedas
CREATE TABLE IF NOT EXISTS coin_transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  transaction_type VARCHAR(20) NOT NULL, -- 'earn', 'spend'
  amount INTEGER NOT NULL,
  reason VARCHAR(100) NOT NULL, -- 'daily_login', 'character_unlock', 'bonus', etc.
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de sessões de usuários (para controle de login)
CREATE TABLE IF NOT EXISTS user_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  session_token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de histórico de login diário (para dar moedas)
CREATE TABLE IF NOT EXISTS daily_logins (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  login_date DATE NOT NULL,
  coins_earned INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, login_date) -- Um login por dia
);

-- Inserir usuários de exemplo
INSERT INTO users (name, email, password_hash, coins, total_coins_earned) VALUES
('Alex', 'alexmind@gmail.com', '$2b$10$o3Lx9SXG2xPq7pYLzaUq/uVWxioqy4mI/Q9BWMxJRTwE6CJGbBvzy', 200, 200),
('Val', 'vanbanding@gmail.com','$2b$10$6E07uTkNqMJtfMwmkRE1EuAK38BFxCmihM7Tuf3MVuCJgiN8dMPOK', 150, 150),
('Mario', 'mariobros@gmail.com','$2b$10$3MQb43.Blm.Ypl2TviJMzu7O87J5Lk2QieT8fsGsrCOf4RXunu67G', 300, 300)
ON CONFLICT (email) DO NOTHING;

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_unlocked_characters_user_id ON user_unlocked_characters(user_id);
CREATE INDEX IF NOT EXISTS idx_coin_transactions_user_id ON coin_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_logins_user_date ON daily_logins(user_id, login_date);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at na tabela users
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 