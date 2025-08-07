const { Pool } = require('pg');
require('dotenv').config();

console.log('🔧 Database config: ', {
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'rick_morty_db',
  port: process.env.DB_PORT || '5432',
});

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'rick_morty_db',
  password: process.env.DB_PASSWORD || 'password',
  port: Number(process.env.DB_PORT) || 5432,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('connect', () => {
  console.log('✅ Conectado ao banco de dados PostgreSQL');
});

pool.on('error', err => {
  console.error('❌ Erro na conexão com o banco de dados:', err);
  process.exit(-1);
});

module.exports = pool;
