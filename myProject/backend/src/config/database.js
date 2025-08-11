import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

pool.on('connect', () => {
  console.log('✅ Conectado ao banco de dados PostgreSQL');
});

pool.on('error', err => {
  console.error('❌ Erro na conexão com o banco de dados:', err);
  process.exit(-1);
});

// Export query function
export const query = (text, params) => pool.query(text, params);
export default pool;
