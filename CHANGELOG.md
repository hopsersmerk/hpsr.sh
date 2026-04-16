# Changelog

Todos los cambios relevantes de `hpsr.sh` se documentarán aquí.

El formato está inspirado en Keep a Changelog y el proyecto usa una estrategia simple de versionado semántico.

## [0.1.0] - 2026-04-16

### Added

1. Script interactivo de bootstrap para Debian y Ubuntu
2. Creación de usuario administrativo con `sudo`
3. Configuración de acceso SSH por llave pública
4. Hardening básico de SSH
5. Configuración de `ufw`
6. Activación de `fail2ban`
7. Activación de `unattended-upgrades`
8. Configuración de hostname y timezone
9. Reportes Markdown, logs y backups en `/root/.server-setup/`
10. Integración opcional con Resend
11. Envío de reporte por email en `HTML` y `text`
12. Soporte bilingüe en español e inglés
13. Limpieza automática de artefactos sensibles temporales

### Changed

1. Flujo simplificado para enfocarse en bootstrap básico y seguro
2. Interfaz de consola refinada para mejor legibilidad

### Fixed

1. Compatibilidad con ejecución vía `curl | bash`
2. Manejo más seguro de validación SSH en contenedores
3. Re-ejecución más segura con artefactos temporales únicos

### Security

1. `PermitRootLogin no`
2. `PasswordAuthentication no`
3. Limpieza automática de llaves y archivos temporales sensibles
