#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------
# Lectura desde archivo de configuración si existe
ENV_FILE="./.env"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

# ------------------------------------------------------
# Argumentos opcionales
while [[ $# -gt 0 ]]; do
  case $1 in
    --root-folder) ROOT_FOLDER="$2"; shift ;;
    --static-repo) STATIC_WEBSITE_REPO="$2"; shift ;;
    --manifests-repo) K8S_MANIFESTS_REPO="$2"; shift ;;
    --mount-path) MOUNT_PATH="$2"; shift ;;
    --app-label) APP_LABEL="$2"; shift ;;
    --service-name) SERVICE_NAME="$2"; shift ;;
    *) echo "Opción no reconocida: $1"; exit 1 ;;
  esac
  shift
done

# ------------------------------------------------------
# Detecta el sistema operativo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Corriendo en Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Corriendo en macOS"
elif [[ "$OSTYPE" == "cygwin" ]]; then
  echo "Corriendo en Cygwin (Git Bash en Windows)"
elif [[ "$OSTYPE" == "msys" ]]; then
  echo "Corriendo en MinGW (Git Bash en Windows)"
elif [[ "$OSTYPE" == "win32" ]]; then
  echo "Corriendo en Windows"
else
  echo "Sistema operativo desconocido: $OSTYPE"
  exit 1
fi

# ------------------------------------------------------
# Configuración por defecto
ROOT_FOLDER="${ROOT_FOLDER:-$HOME/Desktop/taller-k8s-web}"
STATIC_WEBSITE_REPO="${STATIC_WEBSITE_REPO:-https://github.com/helheim01/static-website}"
K8S_MANIFESTS_REPO="${K8S_MANIFESTS_REPO:-https://github.com/helheim01/k8s-manifests}"
MOUNT_PATH="${MOUNT_PATH:-/mnt/web}"
APP_LABEL="${APP_LABEL:-app=web}"
SERVICE_NAME="${SERVICE_NAME:-web-service}"

# ------------------------------------------------------
# Funciones utilitarias
log() { echo -e "\033[1;32m[INFO]\033[0m  $*"; }
fail() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }
check_dep() { command -v "$1" >/dev/null 2>&1 || fail "Falta dependencia: $1"; }

# ------------------------------------------------------
# Verifica dependencias
for dep in git minikube kubectl cygpath; do
  check_dep "$dep"
done

# ------------------------------------------------------
# Crea carpeta raíz y clona los repositorios
log "Creando carpeta raíz: $ROOT_FOLDER"
mkdir -p "$ROOT_FOLDER"
cd "$ROOT_FOLDER"

log "Limpiando clonaciones anteriores..."
rm -rf static-website k8s-manifests

log "Clonando $STATIC_WEBSITE_REPO"
git clone "$STATIC_WEBSITE_REPO"

log "Clonando $K8S_MANIFESTS_REPO"
git clone "$K8S_MANIFESTS_REPO"

# ------------------------------------------------------
# Inicia Minikube
log "Iniciando Minikube..."
minikube start

# ------------------------------------------------------
# Monta carpeta en la VM antes de aplicar los manifiestos
HOST_PATH_WIN=$(cygpath -w "$ROOT_FOLDER/static-website")
log "Montando $HOST_PATH_WIN → $MOUNT_PATH en VM..."
minikube mount "${HOST_PATH_WIN}:${MOUNT_PATH}" >/dev/null 2>&1 &
MOUNT_PID=$!

# Espera al montaje
until minikube ssh -- "[ -d $MOUNT_PATH ]"; do
  echo -n "."; sleep 2
done
log "Carpeta montada con éxito."

# ------------------------------------------------------
# Aplica manifiestos de Kubernetes
log "Aplicando manifiestos de Kubernetes..."
cd "$ROOT_FOLDER/k8s-manifests"
kubectl apply -f volume/pv.yaml
kubectl apply -f volume/pvc.yaml
kubectl apply -f deployment/web-deployment.yaml
kubectl apply -f deployment/web-deployment-direct.yaml
kubectl apply -f service/web-service.yaml

# ------------------------------------------------------
# Espera a que el pod esté en Running
log "Esperando a que el pod con etiqueta '$APP_LABEL' esté en Running..."
until kubectl get pods -l "$APP_LABEL" -o 'jsonpath={.items[0].status.phase}' 2>/dev/null | grep -q Running; do
  echo -n "."; sleep 3
done
log "Pod en estado Running."

# ------------------------------------------------------
# Expone el servicio
URL=$(minikube service "$SERVICE_NAME" --url)
log "Servicio disponible en: $URL"

# Intentar abrir navegador automáticamente
display_cmd="xdg-open '$URL' || open '$URL' || bash -lc 'start $URL'"
eval "$display_cmd" >/dev/null 2>&1 || echo "Abrí manualmente: $URL"

# ------------------------------------------------------
# Reporte final
echo "--------------------------------------"
log "Recursos desplegados:"
kubectl get all
echo ""
echo "Para detener el entorno más tarde:"
echo "  minikube stop"
echo "  minikube delete"
echo "Para desmontar el mount (si es necesario):"
echo "  kill $MOUNT_PID"
echo "--------------------------------------"
