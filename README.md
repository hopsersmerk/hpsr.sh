# hpsr.sh

<p align="center">
  <img src="https://hopsersmerk.com/content/images/2025/08/hpsr.mx-1.png" alt="hpsr.sh logo" width="180" />
</p>

<p align="center">
  <strong>Script Bash para bootstrap y hardening inicial de servidores Debian y Ubuntu.</strong>
</p>

<p align="center">
  <strong>hpsr.sh</strong> ayuda a configurar un VPS nuevo o recién restaurado con una base segura, rápida y entendible: usuario administrativo, llaves SSH, hardening básico, UFW, Fail2ban, actualizaciones automáticas, reportes y envío opcional por correo con Resend.
</p>

`hpsr.sh` está pensado para dos perfiles principales:

1. Ingenieros o desarrolladores que están empezando a administrar servidores Linux y quieren una base segura sin pelearse con muchos pasos manuales.
2. Profesionales que buscan una solución básica, práctica y rápida para dejar un servidor Debian o Ubuntu listo en minutos.

## ¿Qué es hpsr.sh?

`hpsr.sh` es un asistente interactivo en Bash para el setup inicial de servidores Debian y Ubuntu. Su objetivo es convertir una tarea repetitiva y propensa a errores en un flujo guiado, reproducible y más seguro.

En vez de configurar todo a mano cada vez que levantas un VPS, reinstalas un servidor o despliegas una máquina nueva, `hpsr.sh` te guía paso a paso para aplicar un bootstrap técnico razonable y útil desde el minuto uno.

No intenta reemplazar herramientas más grandes como Ansible, Terraform o sistemas de hardening corporativo. Su valor está en ser:

1. Simple de usar.
2. Fácil de entender.
3. Rápido de ejecutar.
4. Suficientemente técnico para un entorno real básico.

## Casos de uso

`hpsr.sh` encaja especialmente bien en estos escenarios:

1. Un VPS nuevo en DigitalOcean, Hetzner, Vultr, Oracle Cloud, Linode o proveedores similares.
2. Un servidor Debian o Ubuntu recién reinstalado.
3. Laboratorios, entornos de pruebas o infraestructura efímera.
4. Servidores personales, side projects, MVPs o stacks pequeños/medianos.
5. Base inicial antes de aplicar automatización más avanzada.

## Qué hace exactamente

`hpsr.sh` aplica un bootstrap inicial de servidor con foco en acceso seguro, endurecimiento básico y trazabilidad.

### 1. Flujo interactivo guiado

El script funciona como un asistente de consola interactivo y soporta dos idiomas:

1. Español por defecto.
2. English opcional.

Todo el flujo cambia de idioma según la selección:

1. Interfaz en consola.
2. Prompts y confirmaciones.
3. Correos de Resend.
4. Reporte final en Markdown.

### 2. Crea un usuario administrativo nuevo

El script solicita un nuevo usuario administrativo y:

1. Lo crea si no existe.
2. Lo agrega al grupo `sudo`.
3. Configura su contraseña.
4. Prepara `~/.ssh` con permisos correctos.

Esto permite dejar de depender de `root` como usuario de acceso operativo.

### 3. Configura acceso SSH con llave pública

`hpsr.sh` soporta varios métodos de acceso SSH para el nuevo usuario:

1. Generar un nuevo par de llaves en el servidor.
2. Pegar una llave pública existente.
3. Usar un archivo de llave pública ya presente en el servidor.

Por defecto, el flujo está orientado a generar un nuevo par de llaves para el usuario administrativo.

Cuando la llave es generada por el script, `hpsr.sh` ahora la gestiona como una llave administrada por el propio proyecto.

Esto significa que:

1. El nombre del archivo usa prefijo `hpsr-`.
2. La llave pública incluye un comentario estructurado identificable.
3. La llave se instala dentro de un bloque administrado en `authorized_keys`.
4. En re-ejecuciones, el script reemplaza solo llaves previas de `hpsr.sh`.
5. Las llaves externas o agregadas manualmente se conservan.
6. La llave generada se verifica contra `authorized_keys` antes de continuar.

### 4. Endurece SSH

El script aplica decisiones de hardening básicas y razonables para un servidor nuevo:

1. Deshabilita el login SSH de `root`.
2. Deshabilita la autenticación SSH por contraseña.
3. Fuerza el uso de autenticación por llave pública.
4. Permite configurar un puerto SSH personalizado, con `666` como sugerencia por defecto.
5. Valida la configuración de `sshd` antes de recargar el servicio cuando el entorno lo permite.
6. Genera backup de `sshd_config` antes de modificarlo.

### 5. Configura firewall con UFW

`hpsr.sh` configura `ufw` con una política básica de entrada segura:

1. Deny incoming.
2. Allow outgoing.
3. Abre el puerto SSH configurado.
4. Abre `80/tcp`.
5. Abre `443/tcp`.
6. Permite agregar puertos adicionales si el usuario lo necesita.

### 6. Activa Fail2ban

El script instala y configura `fail2ban` para proteger SSH contra intentos repetidos de acceso no autorizado.

Configuración base actual:

1. `bantime = 1h`
2. `findtime = 10m`
3. `maxretry = 5`

### 7. Habilita actualizaciones automáticas de seguridad

`hpsr.sh` instala y habilita `unattended-upgrades` para facilitar la aplicación automática de parches de seguridad.

### 8. Configura identidad del servidor

El asistente permite ajustar:

1. `hostname`
2. `timezone`

Además, intenta sugerir zona horaria automáticamente por IP cuando es posible, pero permite mantener la actual o seleccionar manualmente una distinta.

### 9. Instala paquetes base útiles

El script instala automáticamente un conjunto de paquetes base pensados para administración y diagnóstico inicial:

1. `curl`
2. `git`
3. `openssl`
4. `nano`
5. `telnet`
6. `glances`

También instala dependencias internas que necesita para funcionar correctamente, como:

1. `openssh-client`
2. `openssh-server`
3. `ca-certificates`
4. `ufw`
5. `zip`

### 10. Genera logs, backups y reportes

Todo el flujo genera artefactos útiles en una ruta de trabajo dedicada:

`/root/.server-setup/`

Estructura principal:

1. `/root/.server-setup/reports/`
2. `/root/.server-setup/backups/`
3. `/root/.server-setup/generated/`
4. `/root/.server-setup/logs/`

Esto permite:

1. Auditar lo que cambió.
2. Ver errores si algo falla.
3. Revisar backups de configuraciones sensibles.
4. Consultar el reporte final en Markdown.

### 11. Integración opcional con Resend

El script puede integrarse opcionalmente con Resend para:

1. Enviar un correo de prueba y validar la integración.
2. Enviar el reporte de configuración directamente en el cuerpo del correo.
3. Enviar opcionalmente un paquete cifrado de credenciales.

El correo de reporte incluye versión `HTML` y `text`, y está pensado para ser legible apenas abres el email.

### 12. Manejo de credenciales sensibles

Si el flujo genera llaves o archivos temporales sensibles, `hpsr.sh`:

1. Los ubica en una ruta temporal controlada.
2. Puede empaquetarlos en un `.zip` cifrado si se van a enviar por correo.
3. Imprime la contraseña del archivo cifrado solo en consola.
4. Pide confirmación antes de eliminar la llave privada generada.
5. Si el usuario no confirma que ya la guardó correctamente, la puede conservar temporalmente en el servidor.
6. Limpia automáticamente los artefactos sensibles temporales que sí deben eliminarse al terminar.

## Qué no hace

Para evitar malentendidos, `hpsr.sh` no pretende ser:

1. Un reemplazo de Ansible, Salt, Puppet o Terraform.
2. Un benchmark CIS completo.
3. Una solución de compliance corporativo.
4. Un instalador de stacks complejos por defecto.
5. Un framework de automatización multi-servidor.

Es una base rápida, práctica y razonable para dejar un servidor mejor configurado que un setup manual improvisado.

## Público objetivo

Este proyecto está orientado a:

1. Nuevos ingenieros que quieren aprender una base correcta de setup inicial en Linux.
2. Desarrolladores que normalmente no administran infraestructura, pero necesitan dejar un VPS funcional y seguro.
3. Freelancers y pequeños equipos que quieren una base rápida sin montar una cadena completa de automatización.
4. Profesionales que buscan un script Bash entendible y fácil de adaptar.

## Compatibilidad

Entornos objetivo:

1. Debian
2. Ubuntu

Entornos recomendados:

1. VPS reales
2. Máquinas virtuales
3. Servidores con `systemd`

También puede ejecutarse en contenedores para pruebas parciales, pero hay limitaciones naturales en:

1. `hostnamectl`
2. `timedatectl`
3. recarga de servicios
4. validación completa de algunos componentes del sistema

## Uso rápido

### Opción 1: ejecutar directamente

```bash
curl -fsSL https://raw.githubusercontent.com/hopsersmerk/hpsr.sh/main/setup.sh | bash
```

### Opción 2: descargar y ejecutar

```bash
curl -fsSL https://raw.githubusercontent.com/hopsersmerk/hpsr.sh/main/setup.sh -o setup.sh
bash setup.sh
```

### Opción 3: verificar una configuración existente

Puedes auditar el estado actual del servidor sin reaplicar cambios con:

```bash
bash setup.sh --verify
```

Opcionalmente puedes forzar idioma:

```bash
bash setup.sh --verify --lang es
bash setup.sh --verify --lang en
```

## Flujo del asistente

El flujo actual del script incluye, de forma resumida:

1. Selección de idioma.
2. Verificaciones iniciales.
3. Integración opcional con Resend.
4. Identidad del servidor.
5. Usuario administrativo.
6. Configuración de acceso SSH.
7. Hardening SSH.
8. Firewall.
9. Fail2ban.
10. Actualizaciones automáticas.
11. Revisión final.
12. Aplicación de cambios.
13. Acciones posteriores, reporte y limpieza de temporales sensibles.

## Re-ejecución segura del script

Sí, `hpsr.sh` puede volver a ejecutarse sobre el mismo servidor en varios escenarios normales.

### Casos donde sí conviene re-ejecutarlo

1. La primera ejecución se interrumpió antes de terminar.
2. `authorized_keys` quedó vacío o incompleto.
3. La llave privada generada no se guardó correctamente.
4. Quieres regenerar la llave administrada por `hpsr.sh`.
5. Quieres repetir el flujo de Resend o rehacer el reporte final.
6. Estás corrigiendo una configuración incompleta sin reinstalar el servidor.

### Qué hace el script cuando lo vuelves a ejecutar

1. Reutiliza el usuario administrativo si ya existe.
2. Conserva llaves SSH externas o agregadas manualmente.
3. Reemplaza solo los bloques de llaves previamente gestionados por `hpsr.sh`.
4. Mantiene una sola llave activa administrada por `hpsr.sh` por usuario.
5. Intenta reparar el acceso gestionado por el script sin tocar llaves ajenas.

### Cuándo hay que tener más cuidado

Antes de re-ejecutarlo, conviene revisar logs y configuración si:

1. Editaste `sshd_config` manualmente fuera del flujo del script.
2. Añadiste muchas llaves manuales y no sabes cuáles están activas.
3. Estás trabajando en contenedores en vez de un VPS o VM real.
4. El servidor ya tiene una configuración muy personalizada ajena al bootstrap inicial.

## Modo de verificación

`hpsr.sh` incluye un modo de auditoría de solo lectura:

```bash
bash setup.sh --verify
```

Este modo revisa, entre otras cosas:

1. Puerto SSH efectivo.
2. `PermitRootLogin`.
3. `PasswordAuthentication`.
4. `PubkeyAuthentication`.
5. Estado de `authorized_keys`.
6. Llaves administradas por `hpsr.sh`.
7. Llaves externas válidas.
8. Líneas inválidas dentro de `authorized_keys`.
9. Estado de `ufw`.
10. Estado de `fail2ban`.
11. Presencia de `unattended-upgrades`.

El objetivo es reducir la incertidumbre después del setup y facilitar el diagnóstico sin reaplicar cambios.

## Cómo maneja la seguridad

`hpsr.sh` toma una postura práctica de seguridad base:

1. Evita el acceso SSH como `root`.
2. Deshabilita autenticación SSH por contraseña.
3. Privilegia autenticación por llave pública.
4. Restringe puertos de entrada con UFW.
5. Activa Fail2ban.
6. Genera backups antes de tocar configuraciones críticas.
7. Genera logs y reportes para trazabilidad.
8. Limpia automáticamente artefactos sensibles temporales.

Esto no sustituye un hardening profundo, pero sí reduce errores comunes y mejora mucho el estado inicial de un servidor nuevo.

## Logs, backups y reportes

Después de cada ejecución puedes consultar:

1. Logs en `/root/.server-setup/logs/`
2. Reportes en `/root/.server-setup/reports/`
3. Backups en `/root/.server-setup/backups/`

Ejemplo:

```bash
ls -lah /root/.server-setup/logs/
less /root/.server-setup/logs/hpsr-setup-YYYYMMDD-HHMMSS.log
```

Y para el reporte:

```bash
less /root/.server-setup/reports/hpsr-report-YYYYMMDD-HHMMSS.md
```

## Resend: qué hace y por qué sirve

La integración opcional con Resend sirve para que el setup no se quede solo en la consola del servidor.

Permite:

1. Validar el servicio con un correo de prueba.
2. Enviar el reporte final directo en el cuerpo del email.
3. Enviar un paquete cifrado de credenciales si el usuario lo autoriza.

Si eliges enviar credenciales:

1. El paquete se comprime y cifra.
2. La contraseña no se manda por correo.
3. La contraseña solo se imprime en consola.
4. Si la entrega falla, conviene no asumir que la privada fue entregada y revisar el estado local antes de cerrar la sesión actual.

## Preguntas frecuentes

### ¿Funciona en Debian y Ubuntu?

Sí. Ese es el foco principal del proyecto.

### ¿Funciona en contenedores Docker?

Sirve para pruebas parciales, pero no es el entorno ideal para validar completamente cosas como recarga de servicios, hostname persistente o comportamiento real de SSH/UFW/Fail2ban.

### ¿El acceso por contraseña SSH queda habilitado?

No. El flujo está orientado a dejar autenticación SSH por llave pública y deshabilitar login por contraseña.

### ¿Se puede usar `root` por SSH después del setup?

No. `PermitRootLogin` queda en `no`.

### ¿Se borran archivos sensibles temporales?

Sí, pero con una excepción importante: si el script generó una nueva llave privada y el usuario no confirma que ya la guardó correctamente, puede conservarla temporalmente en el servidor para evitar pérdida de acceso.

### ¿Puedo reutilizarlo muchas veces?

Sí. Está pensado para setups repetitivos de VPS o reinstalaciones rápidas. En re-ejecuciones conserva llaves externas y reemplaza solo llaves gestionadas por `hpsr.sh`. Aun así, conviene revisar el log y probar una nueva sesión SSH antes de cerrar la sesión actual.

### ¿El script borra mis otras llaves SSH?

No debería. `hpsr.sh` está diseñado para reemplazar únicamente las llaves que él mismo administra y conservar las llaves externas válidas encontradas en `authorized_keys`.

### ¿Qué hago si no puedo entrar por SSH después del setup?

Pasos recomendados:

1. No cierres la sesión actual si todavía tienes acceso local o por consola.
2. Ejecuta `bash setup.sh --verify` para auditar el estado real.
3. Revisa `/home/<usuario>/.ssh/authorized_keys`.
4. Si la llave gestionada no quedó bien o no guardaste la privada, vuelve a ejecutar el script completo.
5. Prueba una nueva sesión SSH antes de cerrar la anterior.

### ¿Cuándo debo ejecutar de nuevo el script y cuándo usar `--verify`?

Usa `bash setup.sh --verify` cuando quieras comprobar el estado actual sin modificar nada.

Vuelve a ejecutar el script completo cuando:

1. La primera ejecución falló.
2. `authorized_keys` quedó vacío o inconsistente.
3. Necesitas regenerar la llave gestionada por `hpsr.sh`.
4. No guardaste correctamente la llave privada generada.

## Comunidad y contribuciones

Si `hpsr.sh` te sirve, quieres mejorarlo o detectas un caso de uso no cubierto, las contribuciones, issues y sugerencias son bienvenidas.

Este tipo de herramienta mejora mucho con feedback real de:

1. Nuevos ingenieros.
2. Administradores de sistemas.
3. DevOps.
4. Freelancers que despliegan servidores con frecuencia.

## Roadmap sugerido

Algunas mejoras naturales para el proyecto podrían incluir:

1. Más refinamiento visual de la interfaz.
2. Mejor filtrado para selección de zona horaria.
3. Mayor idempotencia en re-ejecuciones.
4. Más perfiles de configuración.
5. Integraciones opcionales adicionales.

## Branding y derechos de marca

El código fuente de este proyecto se distribuye bajo licencia `MIT`, pero eso **no transfiere ni licencia** los derechos sobre:

1. La marca `hpsr.sh`
2. Los logos
3. La identidad visual
4. Los activos gráficos y de branding asociados a:
   - `hpsr.mx`
   - `hopsersmerk.com`
   - `hopsersmerk.dev`

El uso de la marca, logos y activos visuales requiere autorización expresa del titular.

## Licencia

Este proyecto distribuye su **código fuente** bajo licencia `MIT`.

Consulta el archivo [`LICENSE`](./LICENSE) para el texto completo.

## Ecosistema

1. `hpsr.sh`
2. `hpsr.mx`
3. `hopsersmerk.com`
4. `hopsersmerk.dev`
