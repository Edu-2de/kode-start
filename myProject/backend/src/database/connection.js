import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

console.log('🔧 Database config: ', {
  connectionString: process.env.DATABASE_URL ? 'Configured via DATABASE_URL' : 'Not configured',
  host: process.env.DATABASE_URL ? 'Via DATABASE_URL' : 'localhost',
  database: process.env.DATABASE_URL ? 'Via DATABASE_URL' : 'rick_morty_db',
});

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: Number(process.env.DB_POOL_MAX) || 20,
  idleTimeoutMillis: Number(process.env.DB_POOL_IDLE_TIMEOUT) || 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', err => {
  console.error('❌ Error connecting to database:', err);
  process.exit(-1);
});

// Export query function
export const query = (text, params) => pool.query(text, params);
export default pool;
