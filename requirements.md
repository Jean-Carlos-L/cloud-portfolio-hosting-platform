# Requisitos — Plataforma de Portafolios Estudiantiles

## 📖 Contexto (historia del problema)

La **Universidad del Valle** necesita una plataforma económica y escalable donde los estudiantes puedan subir sus portafolios (HTML, CSS, imágenes, PDFs). El sitio debe:

- Cargar **rápido desde cualquier país**.
- Mantener **privados** los archivos sensibles de algunos estudiantes.
- Ser **barata de operar** (serverless, pago por uso).
- Poder **crearse y destruirse** fácilmente mediante infraestructura como código.

Tu misión como builder es diseñar y desplegar esta plataforma usando **AWS CDK**, eligiendo el lenguaje de programación que prefieras.

---

## 📋 Requisitos funcionales

| # | Requisito |
|---|---|
| R1 | **Bucket S3** para almacenar los archivos estáticos del portafolio. |
| R2 | **Distribución CloudFront** para servir el contenido con baja latencia globalmente. |
| R3 | **Tabla DynamoDB** para registrar metadatos de cada portafolio (estudiante, fecha, URL). |
| R4 | **Roles IAM con mínimo privilegio**: el stack de CDK debe definir quién puede escribir en S3 y leer en DynamoDB. |
| R5 | Todo el stack debe desplegarse con un **solo `cdk deploy`**. |

---

## 🧩 Servicios AWS

| Servicio | Rol en el reto |
|---|---|
| **S3** | Almacena archivos estáticos del portafolio |
| **CloudFront** | CDN global que sirve los archivos con caché |
| **DynamoDB** | Guarda metadatos de cada portafolio |
| **IAM** | Controla los permisos de acceso |

**Conceptos clave:** Object Storage · Serverless · Infrastructure as Code (IaC)

---

## 📦 Entregables

- [ ] Stack CDK desplegado exitosamente (`cdk deploy` sin errores).
- [ ] Bucket S3 creado con **acceso público bloqueado**.
- [ ] Distribución CloudFront apuntando al bucket **como origen**.
- [ ] Tabla DynamoDB con **al menos un ítem de prueba**.
- [ ] Roles IAM **definidos en el stack** (no creados manualmente).
- [ ] **URL de CloudFront funcional** que sirve un archivo de prueba.

---

## 🏁 Criterios de éxito

1. Acceder al portafolio desde la **URL de CloudFront** devuelve el contenido correcto.
2. Intentar acceder **directamente al bucket S3** devuelve un error **403** (acceso denegado).
3. `cdk synth` genera el template **sin errores**.
4. La tabla DynamoDB existe con la **clave de partición correcta**.

---

## 🐉 Boss Fight (cambio de requisitos en vivo)

> ⚠️ **¡Alerta de requerimiento nuevo!**

El cliente decide que:

- Algunos archivos del portafolio deben ser **privados** (solo accesibles con un **enlace firmado**).
- El tráfico debe **optimizarse para usuarios en América Latina, Europa y Asia** simultáneamente.

**¿Qué cambia?**

- Configurar **S3 Signed URLs** o **CloudFront Signed URLs** para los archivos privados.
- Ajustar la distribución de CloudFront para usar **Price Class 200** (América + Europa + Asia).
- El stack CDK debe soportar **ambos tipos de archivo** (público y privado) sin romper lo existente.

---

## 🧹 Cleanup obligatorio

Al terminar:

```bash
cd cdk
cdk destroy
```

> ⚠️ S3 no elimina buckets con contenido. Vacía el bucket manualmente antes de `cdk destroy`, o configura `autoDeleteObjects: true`.
