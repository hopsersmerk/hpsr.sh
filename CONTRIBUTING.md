# Contribuir a hpsr.sh

Gracias por tu interés en mejorar `hpsr.sh`.

Este proyecto busca ofrecer un bootstrap inicial práctico, rápido y entendible para servidores Debian y Ubuntu. Las contribuciones son bienvenidas, especialmente si ayudan a que el script sea más:

1. Seguro
2. Claro
3. Predecible
4. Fácil de mantener
5. Útil para principiantes y profesionales

## Antes de abrir un issue o pull request

Revisa primero:

1. El `README.md`
2. La `SECURITY.md`
3. Los issues abiertos
4. Las discusiones del repositorio

## Tipos de contribuciones útiles

1. Corrección de bugs
2. Mejoras de UX en consola
3. Mejoras de compatibilidad con Debian/Ubuntu
4. Mejoras de seguridad razonables para el alcance del proyecto
5. Mejoras de documentación
6. Mejoras de idempotencia y re-ejecución
7. Mejoras de reportes, logs y correo

## Qué tipo de cambios requieren más cuidado

Los cambios relacionados con estas áreas deben explicarse y probarse bien:

1. SSH y `sshd_config`
2. Gestión de llaves
3. UFW / puertos expuestos
4. Fail2ban
5. Limpieza de artefactos sensibles
6. Integración con Resend
7. Compatibilidad con contenedores

## Cómo reportar un bug

Cuando abras un bug report, intenta incluir:

1. Distro y versión
2. Proveedor o entorno
   - VPS real
   - VM
   - contenedor
3. Comando exacto usado para ejecutar el script
4. Paso del asistente donde falló
5. Log generado en `/root/.server-setup/logs/`
6. Comportamiento esperado
7. Comportamiento actual

## Cómo proponer una mejora

Una propuesta de mejora es más útil si responde estas preguntas:

1. ¿Qué problema real resuelve?
2. ¿A quién ayuda?
3. ¿Qué parte del flujo cambia?
4. ¿Introduce complejidad adicional?
5. ¿Se puede mantener simple?

## Cómo enviar un pull request

Si vas a enviar un PR:

1. Mantén el cambio lo más pequeño posible
2. Explica el porqué del cambio, no solo el qué
3. Describe cómo probaste el cambio
4. Indica si lo validaste en:
   - Debian
   - Ubuntu
   - VPS real
   - VM
   - contenedor
5. No mezcles muchos cambios distintos en un solo PR si pueden separarse

## Recomendaciones de prueba

Las pruebas más valiosas para este proyecto son:

1. VPS Debian real
2. VPS Ubuntu real
3. Re-ejecución del script sobre una máquina ya configurada
4. Pruebas de integración con Resend
5. Pruebas en contenedor para detectar degradaciones parciales

Recuerda que un contenedor no reemplaza una prueba real de:

1. SSH
2. hostname persistente
3. systemd
4. firewall
5. fail2ban

## Alcance del proyecto

`hpsr.sh` no intenta ser:

1. Un reemplazo de Ansible
2. Un hardening CIS completo
3. Un framework multi-host
4. Un instalador de todo tipo de stack de aplicación

El foco es: bootstrap inicial + hardening básico + experiencia simple.

## Seguridad y datos sensibles

Por favor:

1. No publiques llaves privadas
2. No publiques tokens ni API keys
3. No publiques contraseñas
4. No abras issues públicos con secretos reales

Si detectas una vulnerabilidad, consulta `SECURITY.md`.

## Comunicación

Si no estás seguro de si un cambio encaja o no, abre primero una discusión o issue corto con contexto.

## Branding

Las contribuciones al código están cubiertas por la licencia del proyecto, pero la marca `hpsr.sh`, logos e identidad visual siguen reservados según lo descrito en el `README.md`.
