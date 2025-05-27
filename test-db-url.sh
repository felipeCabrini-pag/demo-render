#!/bin/bash

# Script para testar e corrigir a URL do banco PostgreSQL
echo "🔍 Analisando URL do banco PostgreSQL..."
echo "=================================================="

# URL original
ORIGINAL_URL="postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc"

echo "📊 URL Original:"
echo "$ORIGINAL_URL"
echo ""

# Componentes da URL
USERNAME="demo_render_zrrc_user"
PASSWORD="e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw"
HOST="dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com"
PORT="5432"
DATABASE="demo_render_zrrc"

echo "🔧 Componentes da URL:"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "Host: $HOST"
echo "Port: $PORT"
echo "Database: $DATABASE"
echo ""

# URL com porta explícita
URL_WITH_PORT="postgresql://$USERNAME:$PASSWORD@$HOST:$PORT/$DATABASE"
echo "🔗 URL com porta explícita:"
echo "$URL_WITH_PORT"
echo ""

# URL com parâmetros SSL
URL_WITH_SSL="postgresql://$USERNAME:$PASSWORD@$HOST:$PORT/$DATABASE?sslmode=require"
echo "🔒 URL com SSL obrigatório:"
echo "$URL_WITH_SSL"
echo ""

# URL com timeout
URL_WITH_TIMEOUT="postgresql://$USERNAME:$PASSWORD@$HOST:$PORT/$DATABASE?sslmode=require&connectTimeout=30"
echo "⏱️  URL com timeout:"
echo "$URL_WITH_TIMEOUT"
echo ""

# Teste de conexão se psql estiver disponível
if command -v psql &> /dev/null; then
    echo "🧪 Testando conexões..."
    
    echo "Testando URL original..."
    if timeout 10 psql "$ORIGINAL_URL" -c "SELECT 1;" &> /dev/null; then
        echo "✅ URL original funcionou!"
    else
        echo "❌ URL original falhou"
    fi
    
    echo "Testando URL com porta..."
    if timeout 10 psql "$URL_WITH_PORT" -c "SELECT 1;" &> /dev/null; then
        echo "✅ URL com porta funcionou!"
    else
        echo "❌ URL com porta falhou"
    fi
    
    echo "Testando URL com SSL..."
    if timeout 10 psql "$URL_WITH_SSL" -c "SELECT 1;" &> /dev/null; then
        echo "✅ URL com SSL funcionou!"
        echo "👍 Use esta URL no render.yaml"
    else
        echo "❌ URL com SSL falhou"
    fi
else
    echo "⚠️  psql não encontrado. Instale com: brew install postgresql"
fi

echo ""
echo "=================================================="
echo "📝 URLs para testar no render.yaml:"
echo "1. $URL_WITH_PORT"
echo "2. $URL_WITH_SSL"
echo "3. $URL_WITH_TIMEOUT"
