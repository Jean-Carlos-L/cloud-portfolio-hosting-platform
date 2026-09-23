#!/usr/bin/env bash

# Salir inmediatamente si un comando falla
set -e

# ============================================================================
# CARGAR VARIABLES DESDE EL ARCHIVO .env
# ============================================================================
ENV_FILE="$(dirname "$0")/../.env"

if [ -f "$ENV_FILE" ]; then
  # Cargar variables del .env ignorando líneas comentadas (#)
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "❌ Error: No se encontró el archivo '$ENV_FILE'."
  echo "Crea un archivo .env con BUCKET_NAME, CLOUDFRONT_DOMAIN, TABLE_NAME y REGION."
  exit 1
fi

# Validar que las variables del .env no estén vacías
if [ -z "${BUCKET_NAME}" ] || [ -z "${CLOUDFRONT_DOMAIN}" ] || [ -z "${TABLE_NAME}" ] || [ -z "${REGION}" ]; then
  echo "❌ Error: El archivo .env debe contener BUCKET_NAME, CLOUDFRONT_DOMAIN, TABLE_NAME y REGION."
  exit 1
fi

# ============================================================================
# VALORES POR DEFECTO PARA PARÁMETROS OPCIONALES
# ============================================================================
VISIBILITY="public"
ASSETS_DIR="./application"

usage() {
  echo "Uso: $0 -i <studentId> -n <studentName> -p <program> [-v <visibility>] [-d <assetsDir>]"
  echo ""
  echo "Opciones:"
  echo "  -i  ID o nombre de carpeta del estudiante (Obligatorio)"
  echo "  -n  Nombre del estudiante (Obligatorio)"
  echo "  -p  Programa académico (Obligatorio)"
  echo "  -v  Visibilidad global del portafolio: public o private (Opcional, defecto: public)"
  echo "  -d  Ruta a la carpeta de assets (Opcional, defecto: ./application)"
  exit 1
}

# Leer banderas
while getopts "i:n:p:v:d:h" opt; do
  case ${opt} in
    i) STUDENT_ID="$OPTARG" ;;
    n) STUDENT_NAME="$OPTARG" ;;
    p) PROGRAM="$OPTARG" ;;
    v) VISIBILITY="$OPTARG" ;;
    d) ASSETS_DIR="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [ -z "${STUDENT_ID}" ] || [ -z "${STUDENT_NAME}" ] || [ -z "${PROGRAM}" ]; then
  echo "❌ Error: Los parámetros -i, -n y -p son obligatorios."
  usage
fi

if [ ! -d "${ASSETS_DIR}" ]; then
  echo "❌ Error: La carpeta de origen '${ASSETS_DIR}' no existe."
  exit 1
fi

PUBLISHED_AT=$(date -u +"%Y-%m-%d%TH:%M:%SZ")
S3_PREFIX="portfolios/${STUDENT_ID}"
PUBLIC_URL="https://${CLOUDFRONT_DOMAIN}/${S3_PREFIX}/index.html"

# Verificar si hay contenido privado local
HAS_PRIVATE_FILES=false
if [ -d "${ASSETS_DIR}/private" ]; then
  HAS_PRIVATE_FILES=true
fi

# ============================================================================
# RESUMEN DE EJECUCIÓN
# ============================================================================
echo "===================================================================="
echo "                📋 RESUMEN DE LA PUBLICACIÓN"
echo "===================================================================="
echo " 👤 Estudiante:         ${STUDENT_NAME} (${STUDENT_ID})"
echo " 🎓 Programa:           ${PROGRAM}"
echo " 🔒 Visibilidad Tabla:  ${VISIBILITY}"
echo " 📂 Carpeta Origen:     ${ASSETS_DIR}"
echo " 🪣 Destino S3:         s3://${BUCKET_NAME}/${S3_PREFIX}/"
echo " 🌐 URL Pública:        ${PUBLIC_URL}"
if [ "$HAS_PRIVATE_FILES" = true ]; then
  echo " 🔐 Archivos Privados:  Detectados en '${ASSETS_DIR}/private/'"
  echo " 🛡️ Ruta Protegida S3:   s3://${BUCKET_NAME}/${S3_PREFIX}/private/"
fi
echo "===================================================================="
echo ""

read -p "¿Deseas continuar con la publicación? (s/N): " CONFIRMATION

case "${CONFIRMATION}" in
  [sS][eE][sS]|[sS])
    echo -e "\n⏳ Confirmación recibida. Iniciando proceso...\n"
    ;;
  *)
    echo -e "\n❌ Operación cancelada por el usuario.\n"
    exit 0
    ;;
esac

# ============================================================================
# LÓGICA DE PUBLICACIÓN
# ============================================================================

# 1. Subir archivos públicos (excluyendo la carpeta private si existe)
echo "📤 Subiendo archivos públicos a S3..."
if [ "$HAS_PRIVATE_FILES" = true ]; then
  aws s3 sync "${ASSETS_DIR}" "s3://${BUCKET_NAME}/${S3_PREFIX}/" \
    --exclude "private/*" \
    --region "${REGION}"
else
  aws s3 sync "${ASSETS_DIR}" "s3://${BUCKET_NAME}/${S3_PREFIX}/" \
    --region "${REGION}"
fi

# 2. Subir carpeta privada de forma independiente
if [ "$HAS_PRIVATE_FILES" = true ]; then
  echo "🔐 Subiendo archivos privados a la ruta protegida '/private'..."
  aws s3 sync "${ASSETS_DIR}/private" "s3://${BUCKET_NAME}/${S3_PREFIX}/private/" \
    --region "${REGION}"
fi

# 3. Registrar en DynamoDB
echo "📝 Guardando metadatos en DynamoDB..."
aws dynamodb put-item \
  --table-name "${TABLE_NAME}" \
  --region "${REGION}" \
  --item '{
    "studentId": {"S": "'"${STUDENT_ID}"'"},
    "studentName": {"S": "'"${STUDENT_NAME}"'"},
    "program": {"S": "'"${PROGRAM}"'"},
    "publishedAt": {"S": "'"${PUBLISHED_AT}"'"},
    "url": {"S": "'"${PUBLIC_URL}"'"},
    "visibility": {"S": "'"${VISIBILITY}"'"}
  }'

echo -e "\n✅ ¡Proceso completado con éxito!"
echo "🔗 URL del Portafolio Público: ${PUBLIC_URL}"
if [ "$HAS_PRIVATE_FILES" = true ]; then
  echo "🔒 Los archivos en '/${S3_PREFIX}/private/' requerirán Signed URLs para ser abiertos."
fi