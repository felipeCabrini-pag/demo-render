#!/bin/bash

# Script para verificar a conexão com o banco Render PostgreSQL
# Execute: chmod +x verify-db.sh && ./verify-db.sh

echo "🔍 Verificando conexão com banco Render PostgreSQL..."
echo "=================================================="

DATABASE_URL="postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc"

# Verificar se psql está instalado
if ! command -v psql &> /dev/null; then
    echo "❌ psql não está instalado. Para instalar:"
    echo "   macOS: brew install postgresql"
    echo "   Ubuntu: sudo apt-get install postgresql-client"
    exit 1
fi

echo "✅ psql encontrado"

# Testar conexão básica
echo "🔌 Testando conexão básica..."
if psql "$DATABASE_URL" -c "SELECT version();" &> /dev/null; then
    echo "✅ Conexão com banco bem-sucedida!"
else
    echo "❌ Falha na conexão com banco"
    exit 1
fi

# Verificar se as tabelas existem
echo "📋 Verificando tabelas..."
TABLES=$(psql "$DATABASE_URL" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

if echo "$TABLES" | grep -q "person"; then
    echo "✅ Tabela 'person' encontrada"
else
    echo "⚠️  Tabela 'person' não encontrada - Flyway ainda não executou"
fi

if echo "$TABLES" | grep -q "flyway_schema_history"; then
    echo "✅ Tabela 'flyway_schema_history' encontrada"
    
    # Mostrar histórico de migrações
    echo "📜 Histórico de migrações:"
    psql "$DATABASE_URL" -c "SELECT installed_rank, version, description, success FROM flyway_schema_history ORDER BY installed_rank;"
else
    echo "⚠️  Tabela 'flyway_schema_history' não encontrada"
fi

# Mostrar todas as tabelas
echo "📊 Todas as tabelas no banco:"
psql "$DATABASE_URL" -c "\dt"

echo "=================================================="
echo "✅ Verificação concluída!"

# Informações úteis
echo ""
echo "🔗 Para conectar manualmente:"
echo "psql $DATABASE_URL"
echo ""
echo "🌐 URLs da aplicação (após deploy):"
echo "- Home: https://seu-app.onrender.com/"
echo "- Pessoas: https://seu-app.onrender.com/persons"
echo "- Health: https://seu-app.onrender.com/actuator/health"
