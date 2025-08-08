import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { query } from './connection.js';

// Get __dirname equivalent for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const checkIfTableExist = async () => {
  try {
    const result = await query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'users'
      );
    `);
    return result.rows[0].exists;
  } catch (error) {
    return false;
  }
};

let setupExecuted = false;

const setupDB = async () => {
  if (setupExecuted) {
    console.log('✅ Database setup already completed, skipping');
    return;
  }

  try {
    console.log('🔧 Setting up database...');

    const tableExist = await checkIfTableExist();
    if (tableExist) {
      console.log('✅ Database tables already exist, skipping');
      setupExecuted = true;
      return;
    }

    const schemaPath = join(__dirname, 'sql', 'schema.sql');
    const schemaSql = readFileSync(schemaPath, 'utf-8');

    await query(schemaSql);
    console.log('✅ Database schema created successfully');

    console.log('📊 Tables created:');
    console.log('   - users');
    console.log('   - unlocked_characters');
    console.log('   - daily_bonuses');
    console.log('   - coin_transactions');
    console.log('   - user_sessions');
    console.log('   - daily_logins');

    // Test with user count
    const result = await query('SELECT COUNT(*) FROM users');
    console.log(`👥 Sample users created: ${result.rows[0].count}`);

    setupExecuted = true;
  } catch (error) {
    console.error('❌ Database setup error: ', error);

    if (error instanceof Error && error.message.includes('already exists')) {
      console.log('✅ Tables already exist, continuing...');
      setupExecuted = true;
      return;
    }
    throw error;
  }
};

const testConnection = async () => {
  try {
    const result = await query('SELECT NOW()');
    console.log('✅ Database connection test successful');
    return true;
  } catch (error) {
    console.error('❌ Database connection test failed:', error.message);
    return false;
  }
};

// Auto-setup when run as main module
if (import.meta.url === `file://${process.argv[1]}`) {
  (async () => {
    try {
      const connected = await testConnection();
      if (!connected) {
        console.error('💥 Cannot connect to database');
        process.exit(1);
      }

      await setupDB();
      console.log('🎉 Database setup completed!');
      process.exit(0);
    } catch (error) {
      console.error('💥 Setup failed:', error);
      process.exit(1);
    }
  })();
}

export { setupDB, testConnection, checkIfTableExist };
export default { setupDB, testConnection, checkIfTableExist };
