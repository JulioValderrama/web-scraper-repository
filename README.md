
# n8n Auto-Hosted + Backup Automático + Versionado en Git

Repositorio para desplegar y mantener una instancia de **n8n** autoalojada en Docker, con backups automáticos y versionado de todos los workflows en Git.

---

## 🚀 ¿Qué hace este proyecto?

- **Despliega n8n en Docker Compose** de manera segura y escalable.
- **Realiza backups automáticos** de todos los workflows (en formato `.json`), cada día o según cron.
- **Versiona los backups** automáticamente usando Git: tendrás historial, seguridad y posibilidad de rollback.
- Permite restaurar cualquier backup fácilmente en una nueva instancia.
- Todo el proceso es reproducible por cualquier persona que siga el README.

---

## ⚡ Estructura de carpetas

```
/opt/n8n/
│
├── docker-compose.yml          # Orquestación de contenedores
├── workflows/                  # Carpeta donde se guardan los backups de workflows (.json)
├── scripts/
│   └── export_workflows.sh     # Script de backup y versionado
├── .gitignore                  # Configuración para Git
└── ...
```

---

## 🛠️ Requisitos previos

- Un servidor (VPS, máquina virtual o local)
- Docker y Docker Compose instalados
- Git instalado y acceso a GitHub

---

## 1️⃣ Clona el repositorio

```bash
git clone https://github.com/tuusuario/tu-repo-n8n.git
cd tu-repo-n8n
```

---

## 2️⃣ Configura tus variables de entorno

Crea los archivos `.env` a partir de los ejemplos si hace falta:

```bash
cp .env.example .env

# Edita y añade tus credenciales (por ejemplo la API de OpenAI, dominio, etc)
```

---

## 3️⃣ Levanta los servicios con Docker Compose

```bash
docker compose up -d
```

Esto arrancará n8n y todos los servicios definidos (PostgreSQL, Traefik, etc.).

---

## 4️⃣ Prepara la carpeta de backups y permisos

**IMPORTANTE:** La carpeta de backups `workflows/` debe tener permisos de escritura para el usuario del contenedor (`UID 1000`, normalmente `node`):

```bash
mkdir -p /opt/n8n/workflows
chown -R 1000:1000 /opt/n8n/workflows
chmod -R 775 /opt/n8n/workflows
```

---

## 5️⃣ Añade el script de backup y versión

El script `scripts/export_workflows.sh` realiza automáticamente el backup, lo copia del contenedor al host, y lo versiona con Git.

> **Revisa que el contenido del script sea igual a este (actualizado):**

```bash
#!/bin/bash

WORKFLOW_DIR="/opt/n8n/workflows"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Mantiene SOLO los últimos 10 backups
ls -tp $WORKFLOW_DIR/export_*.json 2>/dev/null | grep -v '/$' | tail -n +11 | xargs -r rm --

# Exporta todos los workflows dentro del contenedor
docker exec n8n-main n8n export:workflow --all --output="/home/node/exported_workflows/export_${TIMESTAMP}.json"

# Copia todos los backups del contenedor al host
docker cp n8n-main:/home/node/exported_workflows/. "$WORKFLOW_DIR/"

# Cambia permisos y propietario ANTES de git add (fundamental)
chown -R 1000:1000 "$WORKFLOW_DIR"
chmod -R 775 "$WORKFLOW_DIR"

# Borra caché de git para asegurar que ve los cambios
cd /opt/n8n
git update-index --really-refresh

# Añade y commitea
git add workflows
git commit -m "Backup workflows $TIMESTAMP"

echo "✅ Backup de workflows exportado, copiado y versionado en Git correctamente: $WORKFLOW_DIR/export_${TIMESTAMP}.json"
```

---

## 6️⃣ Programa la tarea automática con cron

Edita el cron para que se ejecute automáticamente (por ejemplo, cada día a las 3 AM):

```bash
crontab -e
```

Y añade la línea (ajusta la ruta si tu script está en otro sitio):

```
0 3 * * * /opt/n8n/scripts/export_workflows.sh
```

---

## 7️⃣ Sube los cambios a GitHub

Haz push de tu backup y toda la repo:

```bash
git add .
git commit -m "Initial commit: infra, script y backup automático"
git push origin main
```

---

## 8️⃣ Restaurar workflows (Importar)

Para restaurar un backup en una nueva instancia de n8n:

1. Accede a la interfaz de n8n.
2. Crea un nuevo workflow → "Import from File…" y selecciona el `.json` deseado desde `/opt/n8n/workflows/`.

---

## 🔒 Buenas prácticas

- **No subas nunca archivos con credenciales** (usa `.gitignore` para `.env` y otros secretos).
- **Haz `pull` antes de cada cambio** y resuelve conflictos antes de hacer `push`.
- **Verifica siempre los permisos** de la carpeta `workflows` antes de correr el script de backup.
- Si añades workers, Qdrant, o Traefik, documenta sus puertos/volúmenes en este README.

---

## 🤝 Colaboración

Pull Requests y sugerencias bienvenidas.  
Si tienes dudas o quieres aportar, crea un Issue o abre un PR.

---

