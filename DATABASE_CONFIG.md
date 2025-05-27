# Configuração do Banco de Dados Render

## Dados do Banco Criado

- **Hostname**: `dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com`
- **Porta**: `5432`
- **Database**: `demo_render_zrrc`
- **Username**: `demo_render_zrrc_user`
- **Password**: `e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw`

## URLs de Conexão

### Internal (para serviços dentro do Render)
```
postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a/demo_render_zrrc
```

### External (para conexões externas)
```
postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc
```

## Configuração no Render Dashboard

Se preferir configurar manualmente no dashboard em vez de usar o render.yaml:

1. **Vá para seu Web Service no Render Dashboard**
2. **Clique em "Environment"**
3. **Configure as seguintes variáveis:**

| Variable Name | Value |
|---------------|-------|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `SPRING_DATASOURCE_URL` | `postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc` |
| `JAVA_TOOL_OPTIONS` | `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC` |

4. **Clique em "Save Changes"**
5. **Faça o deploy manual ou aguarde o auto-deploy**

## Verificação após Deploy

1. **Health Check**: `https://seu-app.onrender.com/actuator/health`
2. **Página Inicial**: `https://seu-app.onrender.com/`
3. **Gerenciar Pessoas**: `https://seu-app.onrender.com/persons`

## Troubleshooting

Se ainda houver problemas:

1. **Verifique os logs do deploy**
2. **Confirme que o Flyway conseguiu criar as tabelas**
3. **Teste a conexão com o banco separadamente**

## Comando SQL para Verificar Tabelas

Você pode conectar ao banco e verificar se as tabelas foram criadas:

```sql
-- Conectar ao banco
psql postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com/demo_render_zrrc

-- Listar tabelas
\dt

-- Ver estrutura da tabela person
\d person

-- Ver dados da tabela flyway_schema_history
SELECT * FROM flyway_schema_history;
```
