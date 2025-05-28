#!/bin/bash

WORKFLOW_DIR="/opt/n8n/workflows"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Crea la carpeta si no existe
mkdir -p "$WORKFLOW_DIR"

# Borra los backups antiguos, deja solo los últimos 10
ls -tp $WORKFLOW_DIR/export_*.json | grep -v '/$' | tail -n +11 | xargs -I {} rm -- {}

# Exporta todos los workflows en un único archivo
docker exec n8n-main n8n export:workflow --all --output="/home/node/exported_workflows/export_${TIMESTAMP}.json"

# Commit local a git
cd /opt/n8n
git add workflows
git commit -m "Backup workflows $TIMESTAMP"
