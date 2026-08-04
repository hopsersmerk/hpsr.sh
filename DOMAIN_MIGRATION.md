# Migración de dominio

## Estado actual

El proyecto mantiene `hpsr.sh` como nombre del producto y del script. El dominio web y de distribución canónico es:

```text
https://sh.hpsr.dev
```

El endpoint de instalación se mantiene:

```text
https://sh.hpsr.dev/setup.sh
```

Este es un corte único, no una migración gradual del producto. El dominio anterior solo funcionará como redirección de compatibilidad mientras siga registrado y bajo control del proyecto.

## Política de redirección

Configura el proxy perimetral para redirigir estos hosts:

```text
https://hpsr.sh/*      -> https://sh.hpsr.dev/*
https://www.hpsr.sh/*  -> https://sh.hpsr.dev/*
```

La redirección debe conservar la ruta y la query string. Una respuesta permanente `301` o `308` es apropiada. El repositorio también incluye un fallback de Nginx para las peticiones que lleguen directamente al origen de la aplicación.

Los registros DNS por sí solos no producen una redirección HTTP. El dominio anterior debe conservar su registro, DNS, certificado y configuración de proxy para que la redirección funcione. Cuando `hpsr.sh` expire, este proyecto ya no podrá detectar ni redirigir sus URLs antiguas.

## Orden del corte

1. Construir y validar la versión del repositorio que contiene el nuevo dominio canónico.
2. Desplegar el contenedor final y asociar `sh.hpsr.dev` con el servicio.
3. Verificar la landing nueva, `/setup.sh`, `robots.txt` y el sitemap.
4. Configurar la redirección del host antiguo en el proxy perimetral.
5. Purgar el HTML, sitemap y assets sociales almacenados en caché.
6. Verificar la redirección y confirmar que no exista un bucle a través del host nuevo.

## Verificación

El despliegue final debe cumplir estas comprobaciones:

```text
https://sh.hpsr.dev/                  -> 200
https://sh.hpsr.dev/setup.sh         -> 200 text/plain
https://sh.hpsr.dev/robots.txt       -> 200 with the new sitemap URL
https://sh.hpsr.dev/sitemap-index.xml -> 200 with the new host
https://hpsr.sh/                     -> 301 or 308 to the new host
https://hpsr.sh/setup.sh             -> 301 or 308 preserving /setup.sh
```

El contacto público de seguridad y conducta es `dante.clobato@hopsersmerk.com`.

La marca `hpsr.sh`, el nombre de archivo `setup.sh`, el workspace `/root/.server-setup` y los marcadores de llaves SSH administradas son contratos de compatibilidad. No deben renombrarse como parte del cambio de dominio.
