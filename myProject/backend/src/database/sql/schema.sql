CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL, 
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  coins INTEGER NOT NULL DEFAULT 50, 
  total_coins_earned INTEGER NOT NULL DEFAULT 50, 
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS unlocked_characters (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  character_id INTEGER NOT NULL,
  character_name VARCHAR(100) NOT NULL,
  character_image VARCHAR(500) NOT NULL,
  character_status VARCHAR(20) NOT NULL,
  character_species VARCHAR(50) NOT NULL,
  character_location VARCHAR(200),
  rarity VARCHAR(20) NOT NULL DEFAULT 'common',
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, character_id) 
);

CREATE TABLE IF NOT EXISTS daily_bonuses (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  coins_received INTEGER NOT NULL DEFAULT 5,
  claimed_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, claimed_date)
);

CREATE TABLE IF NOT EXISTS coin_transactions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  transaction_type VARCHAR(20) NOT NULL, 
  amount INTEGER NOT NULL,
  reason VARCHAR(100) NOT NULL, 
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  session_token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS daily_logins (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  login_date DATE NOT NULL,
  coins_earned INTEGER NOT NULL DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, login_date) 
);

CREATE TABLE IF NOT EXISTS daily_character_games (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  game_date DATE NOT NULL,
  character_id INTEGER NOT NULL,
  already_owned BOOLEAN NOT NULL DEFAULT FALSE,
  coins_spent INTEGER DEFAULT 10,
  bonus_coins INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, game_date) 
);

CREATE TABLE IF NOT EXISTS memory_game_results (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  character_id INTEGER NOT NULL,
  correct_guess BOOLEAN NOT NULL,
  coins_earned INTEGER NOT NULL DEFAULT 0,
  game_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO users (username, email, password_hash, coins, total_coins_earned) VALUES
('Alex', 'alexmind@gmail.com', '$2b$10$o3Lx9SXG2xPq7pYLzaUq/uVWxioqy4mI/Q9BWMxJRTwE6CJGbBvzy', 200, 200),
('Val', 'vanbanding@gmail.com','$2b$10$6E07uTkNqMJtfMwmkRE1EuAK38BFxCmihM7Tuf3MVuCJgiN8dMPOK', 150, 150),
('Mario', 'mariobros@gmail.com','$2b$10$3MQb43.Blm.Ypl2TviJMzu7O87J5Lk2QieT8fsGsrCOf4RXunu67G', 300, 300)
ON CONFLICT (email) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_unlocked_characters_user_id ON unlocked_characters(user_id);
CREATE INDEX IF NOT EXISTS idx_coin_transactions_user_id ON coin_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_logins_user_date ON daily_logins(user_id, login_date);
CREATE INDEX IF NOT EXISTS idx_daily_bonuses_user_date ON daily_bonuses(user_id, claimed_date);
CREATE INDEX IF NOT EXISTS idx_daily_character_games_user_date ON daily_character_games(user_id, game_date);
CREATE INDEX IF NOT EXISTS idx_memory_game_results_user_id ON memory_game_results(user_id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';


CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 