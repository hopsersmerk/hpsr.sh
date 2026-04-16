# Política de seguridad

Gracias por ayudar a que `hpsr.sh` sea más seguro.

## Cómo reportar una vulnerabilidad

Si detectas una vulnerabilidad o un problema serio de seguridad, por favor repórtalo por correo a:

`contacto@hpsr.sh`

Incluye, si es posible:

1. Descripción del problema
2. Impacto esperado
3. Pasos para reproducirlo
4. Distro afectada
5. Versión o commit aproximado
6. Logs o evidencia relevante

## Qué no hacer

Por favor no publiques en un issue público:

1. Llaves privadas
2. Tokens de API
3. Contraseñas
4. Hosts reales con acceso comprometido
5. Datos sensibles de producción

## Qué tipo de problemas consideramos de seguridad

Ejemplos:

1. Exposición involuntaria de secretos
2. Configuraciones SSH inseguras aplicadas por el script
3. Limpieza incorrecta de artefactos sensibles
4. Exposición de puertos no esperados
5. Errores que dejen al servidor en un estado inseguro sin avisarlo claramente
6. Manejo inseguro de credenciales en Resend o archivos temporales

## Tiempo de respuesta

No se garantiza un SLA formal, pero los reportes de seguridad se revisarán con prioridad razonable.

## Alcance

Esta política aplica al código y comportamiento de `hpsr.sh` como proyecto. No cubre configuraciones externas del usuario, proveedores cloud ni entornos modificados por terceros fuera del alcance del script.
