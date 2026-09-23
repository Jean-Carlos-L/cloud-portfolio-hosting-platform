# Portafolio estático de ejemplo

Este es un portafolio estático **de ejemplo** que puedes subir a tu bucket S3 para probar
que CloudFront sirve el contenido correctamente.

## ¿Qué incluye?

- `index.html` — página principal del portafolio
- `styles.css` — estilos
- `assets/avatar.svg` — imagen de perfil de ejemplo

## ¿Puedo usar mi propio portafolio?

¡Sí! Este ejemplo es solo para arrancar rápido. Puedes:

- **Usarlo tal cual** para validar tu despliegue, o
- **Reemplazarlo** por tu propio portafolio (HTML/CSS/imágenes/PDFs).

Solo asegúrate de que exista un `index.html` como documento raíz para que CloudFront
tenga un archivo por defecto que servir.

## Probarlo localmente

Puedes abrir `index.html` directamente en tu navegador, o levantar un servidor simple:

```bash
# Con Python
python3 -m http.server 8000
# luego abre http://localhost:8000
```
