#!/bin/bash

WORKFLOW_DIR="/opt/n8n/workflows"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Borra los backups antiguos, deja solo los últimos 10
ls -tp $WORKFLOW_DIR/export_*.json | grep -v '/$' | tail -n +11 | xargs -I {} rm -- {}

# Exporta todos los workflows en un único archivo dentro del contenedor
docker exec n8n-main n8n export:workflow --all --output="/home/node/exported_workflows/export_${TIMESTAMP}.json"

# Copia el backup desde el contenedor al host (por si acaso)
docker cp n8n-main:/home/node/exported_workflows/. "$WORKFLOW_DIR/"

# Commit local a git
cd /opt/n8n
git add workflows
git commit -m "Backup workflows $TIMESTAMP"
