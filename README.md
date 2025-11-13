# n8n + Postgres com importação automática de workflows

Este repositório contém uma stack Docker que sobe o n8n conectado a um banco Postgres e executa um script de bootstrap que importa automaticamente seus workflows exportados (
`.json`) toda vez que o container é iniciado.

## Pré-requisitos

- Docker + Docker Compose Plugin instalados
- Workflow(s) exportados do n8n no formato JSON (Menu *Workflows* → *Export*)

## Como usar

1. **Configurar variáveis de ambiente**
   ```bash
   cp .env.example .env
   # edite o arquivo com senhas/usuário/chaves desejados
   ```
2. **Adicionar workflows exportados**
   - Copie os arquivos `.json` para o diretório `workflows/` (pode manter vários arquivos).
3. **Subir os containers**
   ```bash
   docker compose up -d --build
   ```
4. Acesse o n8n em `http://localhost:5678` (ou a porta que configurou em `N8N_PORT`).

O script `scripts/start-n8n-with-workflow.sh` aguarda o Postgres ficar disponível, confere os arquivos em `workflows/` e executa `n8n import:workflow --overwrite` para garantir que os workflows estejam sempre atualizados dentro do banco do n8n.

## Estrutura

- `Dockerfile`: estende a imagem oficial `n8nio/n8n` adicionando o novo entrypoint.
- `docker-compose.yml`: define os serviços `n8n` e `postgres`, volumes persistentes e variáveis da aplicação.
- `scripts/start-n8n-with-workflow.sh`: script de inicialização executado dentro do container n8n (aguarda o banco, importa os workflows e inicia o servidor).
- `workflows/`: coloque aqui seus exports `.json`. O diretório é montado como somente leitura no container.

## Comandos úteis

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
