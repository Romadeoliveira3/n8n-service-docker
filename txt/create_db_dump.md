Ideia geral

Você sobe o stack uma vez, faz o setup inicial (cria o usuário que quiser, etc.).
Depois gera um dump desse banco.
Em novos ambientes, o Postgres já inicializa com esse dump, então o wizard nunca aparece.
Passos

Fazer o setup que você quer

Suba com docker compose up -d.
Acesse http://localhost:5678, passe pelo wizard e crie o usuário do jeito que você quer (email, senha, etc.).
Exportar o seed do banco atual

No diretório do projeto:

mkdir -p db
docker exec -e PGPASSWORD=changeme n8n-postgres \
 pg_dump -U n8n -d n8n > db/seed-n8n.sql
Ajuste n8n/changeme se você mudar POSTGRES_USER/POSTGRES_PASSWORD.

Usar o seed em novos ambientes

No serviço postgres do docker-compose.yml, adicione o volume do seed:

services:
postgres:
image: postgres:15-alpine
container_name: n8n-postgres
restart: unless-stopped
environment:
POSTGRES_DB: ${POSTGRES_DB}
POSTGRES_USER: ${POSTGRES_USER}
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
volumes: - postgres_data:/var/lib/postgresql/data - ./db/seed-n8n.sql:/docker-entrypoint-initdb.d/seed-n8n.sql:ro
O Postgres só executa os scripts em /docker-entrypoint-initdb.d/ quando o volume postgres_data está vazio.
Ou seja, em um ambiente novo o banco já nasce com o usuário e tudo configurado; em ambientes já existentes nada muda.
Se quiser, posso criar o script scripts/export-n8n-seed.sh para automatizar o pg_dump e deixar isso pronto no repo.
