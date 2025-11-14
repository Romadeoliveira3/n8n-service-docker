# n8n + Postgres com importação automática de workflows

Este repositório contém uma stack Docker que sobe o n8n conectado a um banco Postgres e executa um script de bootstrap que importa automaticamente seus workflows exportados (`.json`) toda vez que o container é iniciado.

## Pré-requisitos

- Docker + Docker Compose Plugin instalados
- Workflow(s) exportados do n8n no formato JSON (Menu *Workflows* → *Export*)

## Configuração básica

1. **Variáveis de ambiente**
   - Edite o arquivo `.env` e ajuste:
     - `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
     - `N8N_ENCRYPTION_KEY` (32 caracteres)
     - `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD` (Basic Auth do editor, padrão `admin` / `admin`)
2. **Workflows iniciais**
   - Copie seus arquivos `.json` para o diretório `workflows/`.
   - Por padrão, o exemplo usa `workflows/workflow.json`, mas você pode ter vários arquivos.

## Subir / parar o ambiente (Makefile)

Os comandos principais estão no `Makefile`:

- `make up`  
  Sobe a stack com build: `docker compose up --build -d`.

- `make down`  
  Derruba tudo e remove volumes: `docker compose down -v`.

- `make prune`  
  Limpa recursos Docker não usados: `docker system prune -a`.

Durante o start, o script `scripts/start-n8n-with-workflow.sh`:
- aguarda o Postgres ficar disponível;
- importa os workflows de `/workflows` (respeitando `N8N_IMPORT_OVERWRITE`);
- inicia o n8n.

O editor fica acessível em `http://localhost:5678` (ou na porta definida em `N8N_PORT`) e protegido por Basic Auth com o usuário/senha definidos em `.env`.

## Seed do banco (postgres_data)

Você pode “fixar” um estado inicial do banco (usuário + configurações + workflows) usando um seed Postgres:

1. Suba normalmente com `make up`, faça o setup que quiser no n8n (criando o usuário owner, etc.).
2. Gere o seed:
   ```bash
   make seed
   # gera db/seed-n8n.sql via pg_dump
   ```
3. O `docker-compose.yml` já monta esse arquivo em:
   ```yaml
   - ./db/seed-n8n.sql:/docker-entrypoint-initdb.d/seed-n8n.sql:ro
   ```
   Em ambientes novos (volume `postgres_data` vazio), o Postgres inicializa usando esse seed e o wizard inicial do n8n não aparece.

## Exportar workflows via CLI

- Exportar um workflow específico do banco para `workflows/workflow.json`:
  ```bash
  make export-workflow WORKFLOW_ID=<id>
  # internamente: n8n export:workflow --id=<id> --output=/workflows/workflow.json
  ```

## Estrutura

- `Dockerfile`: estende a imagem oficial `n8nio/n8n` adicionando bash e o novo entrypoint.
- `docker-compose.yml`: define os serviços `n8n` e `postgres`, volumes persistentes e variáveis da aplicação.
- `scripts/start-n8n-with-workflow.sh`: script de inicialização executado dentro do container n8n (aguarda o banco, importa os workflows e inicia o servidor).
- `scripts/export-n8n-seed.sh`: script para gerar o seed do banco (`db/seed-n8n.sql`) a partir do Postgres atual.
- `workflows/`: exports `.json` dos workflows. Montado como somente leitura no container.
- `db/seed-n8n.sql`: dump opcional do banco, usado para inicializar novos ambientes.

## Comandos Docker úteis (sem Makefile)

```bash
# Acompanhar logs
docker compose logs -f n8n

# Reimportar workflows após alterar algum arquivo .json
docker compose restart n8n

# Encerrar serviços
docker compose down
```

## Observações

- Utilize uma chave de 32 caracteres em `N8N_ENCRYPTION_KEY`, caso contrário o n8n não iniciará.
- Com `N8N_IMPORT_OVERWRITE=true`, o script sempre substitui versões existentes dos workflows pelo conteúdo exportado. Ajuste para `false` se quiser evitar sobrescritas automáticas.
- Credenciais/senhas das nodes não são incluídas no JSON exportado do workflow; continue gerenciando-as pelo próprio n8n.

## Contato / Portfólio

- Portfólio: https://romadeoliveira3.github.io/portifolio/
- LinkedIn: https://www.linkedin.com/in/romario-jonas-veloso-427373175
- E-mail: romariojonas@outlook.com.br
