SHELL := /bin/bash

.PHONY: up down prune seed export-workflow

up:
	@echo "Starting stack (build + up -d)..."
	docker compose up --build -d

down:
	@echo "Stopping stack and removing volumes..."
	docker compose down -v

prune:
	@echo "Pruning unused Docker resources (images, containers, networks)..."
	docker system prune -a

seed:
	@echo "Exporting Postgres seed to db/seed-n8n.sql..."
	bash scripts/export-n8n-seed.sh

export-workflow:
	@echo "Exporting workflow to workflows/workflow.json..."
	@if [ -z "$$WORKFLOW_ID" ]; then \
		echo "ERROR: Set WORKFLOW_ID=<id> (e.g. make export-workflow WORKFLOW_ID=123)"; \
		exit 1; \
	fi
	docker compose exec n8n-app n8n export:workflow --id="$$WORKFLOW_ID" --output=/workflows/workflow.json

