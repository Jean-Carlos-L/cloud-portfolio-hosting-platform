# Datos de prueba

`portfolios.json` contiene metadatos de ejemplo de portafolios estudiantiles.

Usa **al menos uno** de estos ítems para cargarlo en tu tabla DynamoDB como
**ítem de prueba** (uno de los entregables del reto).

## Estructura de cada ítem

| Campo | Tipo | Descripción |
|---|---|---|
| `studentId` | String | **Clave de partición** sugerida para DynamoDB |
| `studentName` | String | Nombre del estudiante |
| `program` | String | Programa académico |
| `publishedAt` | String (ISO 8601) | Fecha de publicación |
| `url` | String | URL de CloudFront del portafolio |
| `visibility` | String | `public` o `private` (útil para el Boss Fight) |

## Cargar un ítem con AWS CLI (ejemplo)

```bash
aws dynamodb put-item \
  --table-name <NOMBRE_DE_TU_TABLA> \
  --item '{
    "studentId": {"S": "univalle-2026-001"},
    "studentName": {"S": "Ana Estudiante"},
    "publishedAt": {"S": "2026-09-19T10:00:00Z"},
    "url": {"S": "https://<tu-distribucion>.cloudfront.net/index.html"},
    "visibility": {"S": "public"}
  }'
```

> 💡 También puedes cargar el ítem de prueba desde tu propio código CDK (por ejemplo,
> con un `AwsCustomResource`) si quieres que quede todo en un solo `cdk deploy`.
