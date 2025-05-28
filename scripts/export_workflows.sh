#!/bin/bash

WORKFLOW_DIR="/opt/n8n/workflows"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Mantiene SOLO los últimos 10
ls -tp $WORKFLOW_DIR/export_*.json 2>/dev/null | grep -v '/$' | tail -n +11 | xargs -r rm --

# Exporta los workflows dentro del contenedor
docker exec n8n-main n8n export:workflow --all --output="/home/node/exported_workflows/export_${TIMESTAMP}.json"

# Copia todos los backups del contenedor al host
docker cp n8n-main:/home/node/exported_workflows/. "$WORKFLOW_DIR/"

# Cambia permisos y propietario ANTES de git add (fundamental)
chown -R 1000:1000 "$WORKFLOW_DIR"
chmod -R 775 "$WORKFLOW_DIR"

# Borra caché de git para asegurar que ve los cambios
cd /opt/n8n
git update-index --really-refresh
