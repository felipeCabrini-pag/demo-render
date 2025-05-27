#!/bin/bash

echo "🚀 Testando aplicação Spring Boot com diferentes perfis"
echo "======================================================"

# Função para testar um perfil específico
test_profile() {
    local profile=$1
    local description=$2
    
    echo ""
    echo "🔍 Testando perfil: $profile ($description)"
    echo "----------------------------------------"
    
    # Definir variáveis de ambiente baseadas no perfil
    if [ "$profile" = "prod" ]; then
        export SPRING_PROFILES_ACTIVE=prod
        export SPRING_DATASOURCE_URL="postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc"
        echo "✅ Variáveis do Render configuradas"
    elif [ "$profile" = "test" ]; then
        export SPRING_PROFILES_ACTIVE=test
        unset SPRING_DATASOURCE_URL
        echo "✅ Perfil de teste (H2 in-memory)"
    else
        export SPRING_PROFILES_ACTIVE=dev
        unset SPRING_DATASOURCE_URL
        echo "⚠️  Perfil dev (requer PostgreSQL local)"
    fi
    
    echo "📋 Profile ativo: $SPRING_PROFILES_ACTIVE"
    echo "🔗 Database URL: ${SPRING_DATASOURCE_URL:-'configuração do application.yml'}"
    
    # Tentar iniciar a aplicação (apenas verificar se compila e conecta)
    echo "🏗️  Testando build e conexão..."
    timeout 30s ./gradlew bootRun --quiet &
    local pid=$!
    
    # Aguardar alguns segundos para a aplicação iniciar
    sleep 10
    
    # Verificar se a aplicação está rodando
    if curl -f http://localhost:8080/actuator/health &>/dev/null; then
        echo "✅ Aplicação iniciou com sucesso no perfil $profile!"
        echo "🌐 Health check: http://localhost:8080/actuator/health"
        echo "🏠 Home page: http://localhost:8080/"
    else
        echo "❌ Falha ao iniciar aplicação no perfil $profile"
    fi
    
    # Parar a aplicação
    kill $pid 2>/dev/null
    wait $pid 2>/dev/null
    
    # Limpar variáveis
    unset SPRING_PROFILES_ACTIVE
    unset SPRING_DATASOURCE_URL
}

# Menu interativo
echo ""
echo "Selecione o perfil para testar:"
echo "1) test   - H2 in-memory (sem dependências externas)"
echo "2) prod   - PostgreSQL do Render"
echo "3) dev    - PostgreSQL local (localhost:5432)"
echo "4) todos  - Testar todos os perfis"
echo ""
read -p "Escolha uma opção (1-4): " choice

case $choice in
    1)
        test_profile "test" "H2 in-memory database"
        ;;
    2)
        test_profile "prod" "Render PostgreSQL"
        ;;
    3)
        test_profile "dev" "PostgreSQL local"
        ;;
    4)
        test_profile "test" "H2 in-memory database"
        test_profile "prod" "Render PostgreSQL"
        test_profile "dev" "PostgreSQL local"
        ;;
    *)
        echo "❌ Opção inválida"
        exit 1
        ;;
esac

echo ""
echo "======================================================"
echo "✅ Teste concluído!"
echo ""
echo "💡 Para executar manualmente:"
echo "   Profile test: SPRING_PROFILES_ACTIVE=test ./gradlew bootRun"
echo "   Profile prod: SPRING_PROFILES_ACTIVE=prod SPRING_DATASOURCE_URL='postgresql://...' ./gradlew bootRun"
echo "   Profile dev:  SPRING_PROFILES_ACTIVE=dev ./gradlew bootRun"
