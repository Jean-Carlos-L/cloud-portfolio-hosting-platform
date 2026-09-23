# Reto 1 — Plataforma de Portafolios Estudiantiles

> **Nivel:** Básico · **Programa:** AWS Cloud Practitioner Challenge · **AWS SBG Univalle**

Diseña y despliega una plataforma cloud **estática** para portafolios estudiantiles usando **AWS CDK**, combinando almacenamiento de objetos, CDN global y base de datos serverless.

---

## 🎯 Objetivo

Diseñar y desplegar mediante **AWS CDK** una plataforma cloud que permita a estudiantes publicar sus portafolios de forma estática, con distribución global y almacenamiento seguro.

La historia completa del problema y los requisitos funcionales están en **[`requirements.md`](./requirements.md)**.

---

## 🧰 Prerrequisitos

Antes de empezar, asegúrate de tener:

- [ ] **Node.js** 18+ (necesario para el CLI de CDK, sin importar el lenguaje que elijas)
- [ ] **AWS CLI** configurado con credenciales válidas (`aws configure`)
- [ ] **AWS CDK CLI** instalado globalmente:
  ```bash
  npm install -g aws-cdk
  cdk --version
  ```
- [ ] Runtime del lenguaje que vayas a usar (uno de):
  - **TypeScript / JavaScript** → Node.js 18+
  - **Python** → Python 3.9+ y `pip`
  - **Java** → JDK 11+ y Maven
  - **Go** → Go 1.18+
  - **C#** → .NET 6+

---

## 🚀 Inicio Rápido

Este Starter Kit **no incluye el proyecto CDK ya inicializado**: tú eliges el lenguaje.

### 1. Inicializa tu proyecto CDK en la carpeta `cdk/`

```bash
cd cdk
```

Elige **uno** de los siguientes lenguajes y ejecútalo dentro de `cdk/`:

```bash
# TypeScript
cdk init app --language typescript

# Python
cdk init app --language python

# Java
cdk init app --language java

# Go
cdk init app --language go

# C#
cdk init app --language csharp
```

> 💡 `cdk init` requiere que la carpeta esté vacía. La carpeta `cdk/` viene vacía a propósito para que puedas inicializar en tu lenguaje preferido.

### 2. Bootstrap del entorno (solo una vez por cuenta/región)

```bash
cdk bootstrap
```

### 3. Sintetiza, despliega y destruye

```bash
cdk synth      # Genera la plantilla de CloudFormation (valida tu código)
cdk deploy     # Despliega la infraestructura en AWS
cdk destroy    # Elimina TODOS los recursos (¡obligatorio al terminar!)
```

---

## 📁 Estructura del repositorio

```
challenge-01-student/
├── README.md              # Este archivo (inicio rápido)
├── requirements.md        # Historia del problema y requisitos funcionales
├── cdk/                   # 👉 Inicializa aquí tu proyecto CDK (viene vacía)
├── application/           # Portafolio estático de EJEMPLO (puedes reemplazarlo)
│   ├── index.html
│   ├── styles.css
│   └── assets/
├── data/                  # Datos de prueba (metadatos de portafolio)
│   └── portfolios.json
└── docs/
    └── architecture.md    # Plantilla para que documentes tu arquitectura
```

---

## 🗂️ ¿Qué hay en cada carpeta?

| Carpeta / Archivo | Para qué sirve |
|---|---|
| `cdk/` | Aquí construyes tu infraestructura como código. Empieza vacía. |
| `application/` | Un portafolio estático de ejemplo listo para subir a S3. **Puedes usarlo tal cual o construir el tuyo propio.** |
| `data/` | Un JSON de ejemplo con metadatos que puedes cargar en DynamoDB como ítem de prueba. |
| `docs/architecture.md` | Plantilla para que documentes tu diseño de arquitectura. |
| `requirements.md` | Lo que tu solución debe cumplir. |

---

## ✅ Lo que debes construir (resumen)

1. **Bucket S3** privado para los archivos del portafolio (acceso público bloqueado).
2. **Distribución CloudFront** apuntando al bucket como origen.
3. **Tabla DynamoDB** para metadatos (estudiante, fecha, URL).
4. **Roles IAM** con mínimo privilegio, **definidos en el stack** (no manualmente).
5. Todo desplegable con **un solo `cdk deploy`**.

Consulta **[`requirements.md`](./requirements.md)** para el detalle y los criterios de éxito.

---

## 🧹 Cleanup (¡importante!)

Al terminar el reto, elimina todos los recursos para evitar costos:

```bash
cd cdk
cdk destroy
```

> ⚠️ **S3 no elimina buckets con contenido.** Vacía el bucket manualmente antes de `cdk destroy`, o configura `autoDeleteObjects: true` en tu construct de bucket.

---

## 📚 Recursos útiles

- [AWS CDK — Documentación oficial](https://docs.aws.amazon.com/cdk/v2/guide/home.html)
- [AWS CDK API Reference](https://docs.aws.amazon.com/cdk/api/v2/)
- [Amazon S3](https://docs.aws.amazon.com/s3/) · [CloudFront](https://docs.aws.amazon.com/cloudfront/) · [DynamoDB](https://docs.aws.amazon.com/dynamodb/) · [IAM](https://docs.aws.amazon.com/iam/)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

_AWS Student Builder Group — Universidad del Valle_
