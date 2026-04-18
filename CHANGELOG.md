# Changelog

Todos los cambios relevantes de `hpsr.sh` se documentarán aquí.

El formato está inspirado en Keep a Changelog y el proyecto usa una estrategia simple de versionado semántico.

## [0.2.0] - 2026-04-17

### Added

1. Modo `--verify` para auditoría de solo lectura
2. Gestión de llaves SSH administradas por `hpsr.sh`
3. Documentación de re-ejecución segura y troubleshooting SSH

### Changed

1. Re-ejecuciones ahora reemplazan solo llaves gestionadas por `hpsr.sh`
2. La llave privada puede conservarse temporalmente si el usuario no confirma que ya la guardó
3. El README ahora documenta cuándo usar el setup completo y cuándo usar `--verify`

### Fixed

1. Verificación de llave SSH ignorando comentarios en `authorized_keys`
2. Limpieza de líneas inválidas dentro de `authorized_keys` durante la rotación de llaves gestionadas
3. Recuperación más confiable cuando una primera ejecución no deja acceso operativo inmediato

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
