// Carregar variáveis de ambiente
require('dotenv').config();

const app = require('./src/app');
const { setupDB, testConnection } = require('./src/database/setupDB');

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

// Initialize database and start server
async function startServer() {
  try {
    // Test database connection
    const connected = await testConnection();
    if (!connected) {
      console.error('💥 Cannot connect to database');
      process.exit(1);
    }

    // Setup database (create tables if they don't exist)
    await setupDB();

    // Iniciar servidor
    const PORT = process.env.PORT || 3000;

    const server = app.listen(PORT, () => {
      console.log('🎮 Rick & Morty Game API');
      console.log(`🚀 Servidor rodando na porta ${PORT}`);
      console.log(`🌐 Health check: http://localhost:${PORT}/health`);
      console.log(`📱 API Base URL: http://localhost:${PORT}/api`);
      console.log('');
      console.log('Endpoints disponíveis:');
      console.log('📝 POST /api/auth/register - Criar conta');
      console.log('🔐 POST /api/auth/login - Fazer login');
      console.log('👤 GET /api/auth/profile - Perfil do usuário');
      console.log('🎯 POST /api/game/unlock-character - Desbloquear personagem');
      console.log('👥 GET /api/game/characters - Listar personagens');
      console.log('🎁 POST /api/game/daily-bonus - Bônus diário');
      console.log('📊 GET /api/game/stats - Estatísticas');
      console.log('');
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      console.log('🛑 SIGTERM recebido. Encerrando servidor...');
      server.close(() => {
        console.log('✅ Servidor encerrado com sucesso.');
        process.exit(0);
      });
    });

    process.on('SIGINT', () => {
      console.log('🛑 SIGINT recebido. Encerrando servidor...');
      server.close(() => {
        console.log('✅ Servidor encerrado com sucesso.');
        process.exit(0);
      });
    });

    return server;
  } catch (error) {
    console.error('💥 Falha ao iniciar servidor:', error);
    process.exit(1);
  }
}

// Start the server
startServer();
