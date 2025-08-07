// Carregar variáveis de ambiente
require('dotenv').config();

const app = require('./src/app');

// Verificar se as variáveis de ambiente necessárias estão definidas
const requiredEnvVars = ['DATABASE_URL', 'JWT_SECRET'];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
  console.error('❌ Variáveis de ambiente obrigatórias não encontradas:');
  missingVars.forEach(varName => {
    console.error(`   - ${varName}`);
  });
  console.error('\n📝 Crie um arquivo .env na raiz do projeto com essas variáveis.');
  console.error('Exemplo:');
  console.error('DATABASE_URL=postgresql://username:password@localhost:5432/rickmorty_db');
  console.error('JWT_SECRET=seu_jwt_secret_muito_seguro_aqui');
  process.exit(1);
}

// Log das configurações (sem mostrar dados sensíveis)
console.log('⚙️  Configurações carregadas:');
console.log(`   📊 NODE_ENV: ${process.env.NODE_ENV || 'development'}`);
console.log(`   🚀 PORT: ${process.env.PORT || 3000}`);
console.log(`   🗄️  DATABASE: ${process.env.DATABASE_URL ? '✅ Configurado' : '❌ Não configurado'}`);
console.log(`   🔐 JWT_SECRET: ${process.env.JWT_SECRET ? '✅ Configurado' : '❌ Não configurado'}`);
console.log('');
