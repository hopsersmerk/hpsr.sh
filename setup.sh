#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    if [ -r "$0" ] && [ "$0" != "sh" ]; then
      exec bash "$0" "$@"
    fi
    exec bash -s -- "$@"
  fi
  printf '%s\n' 'This script requires bash. Run it with: curl -fsSL <url> | bash' >&2
  exit 1
fi

set -u

SCRIPT_NAME="hpsr.sh"
SCRIPT_VERSION="0.2.0"
SCRIPT_BRAND_PRIMARY="hpsr.sh"
SCRIPT_BRAND_SECONDARY="hpsr.mx | hopsersmerk.com | hopsersmerk.dev"
SCRIPT_BASE_DIR="/root/.server-setup"
REPORTS_DIR="$SCRIPT_BASE_DIR/reports"
BACKUPS_DIR="$SCRIPT_BASE_DIR/backups"
GENERATED_DIR="$SCRIPT_BASE_DIR/generated"
LOGS_DIR="$SCRIPT_BASE_DIR/logs"
SSH_GENERATED_DIR="$GENERATED_DIR/ssh"
ARCHIVE_DIR="$GENERATED_DIR/archives"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOGS_DIR/hpsr-setup-$TIMESTAMP.log"
REPORT_FILE="$REPORTS_DIR/hpsr-report-$TIMESTAMP.md"
SSH_BACKUP_DIR="$BACKUPS_DIR/ssh"
ACCENT_HEX="#f2dfffff"

TRUECOLOR_ACCENT="\033[38;2;242;223;255m"
ANSI_ACCENT="\033[95m"
ANSI_GREEN="\033[32m"
ANSI_YELLOW="\033[33m"
ANSI_RED="\033[31m"
ANSI_DIM="\033[2m"
ANSI_BOLD="\033[1m"
ANSI_RESET="\033[0m"
TTY_IN=""
TTY_OUT=""

if [[ -t 1 ]] && [[ "${COLORTERM:-}" == *truecolor* || "${TERM:-}" == *direct* ]]; then
  COLOR_ACCENT="$TRUECOLOR_ACCENT"
else
  COLOR_ACCENT="$ANSI_ACCENT"
fi

CURRENT_HOSTNAME=""
CURRENT_TIMEZONE="UTC"
CURRENT_SSH_PORT="22"
PUBLIC_IP=""
RESEND_ENABLED="no"
RESEND_API_KEY=""
RESEND_FROM=""
RESEND_TO=""
RESEND_TEST_STATUS="not-configured"
RESEND_TEST_MESSAGE=""
RESEND_SENT_REPORT="no"
RESEND_SENT_CREDENTIALS="no"
HOSTNAME_VALUE=""
TIMEZONE_VALUE=""
ADMIN_USER=""
SSH_PORT="666"
DISABLE_ROOT_SSH="yes"
DISABLE_PASSWORD_AUTH="yes"
SSH_KEY_MODE="generate"
SSH_KEY_TYPE="ed25519"
SSH_KEY_COMMENT=""
SSH_PRIVATE_KEY_PATH=""
SSH_PUBLIC_KEY_PATH=""
SSH_PUBLIC_KEY_CONTENT=""
SSH_PUBLIC_KEY_BASE=""
SSH_DERIVED_PUBLIC_KEY_BASE=""
SSH_KEY_FINGERPRINT=""
PRINTED_PRIVATE_KEY="no"
DELETE_SENSITIVE_FILES="no"
GENERATED_ARCHIVE_PATH=""
GENERATED_ARCHIVE_PASSWORD=""
UFW_EXTRA_PORTS=""
ENABLE_FAIL2BAN="yes"
ENABLE_UNATTENDED="yes"
TIMEZONE_IP_SUGGESTION=""
ADMIN_PASSWORD=""
ENV_IS_CONTAINER="no"
HOSTNAME_APPLY_STATUS="pending"
TIMEZONE_APPLY_STATUS="pending"
FAIL2BAN_APPLY_STATUS="pending"
SSH_APPLY_STATUS="pending"
TIME_SYNC_STATUS="pending"
SSHD_VALIDATION_STATUS="pending"
OPTIONAL_DOCKER="no"
OPTIONAL_TAILSCALE="no"
OPTIONAL_DOKPLOY="no"
OPTIONAL_SWAP="no"
SWAP_SIZE=""
SUGGESTED_PACKAGES_SELECTED=()
INSTALLED_PACKAGES=()
SSH_SERVICE_NAME="ssh"
OS_ID=""
OS_VERSION=""
SSH_CONFIG_PATH="/etc/ssh/sshd_config"
REPORT_NOTE=""
SENSITIVE_PATHS=()
REPORT_WRITTEN="no"
UI_LANG="es"
LANG_EXPLICIT="no"
HPSR_MANAGED_KEY_REPLACED_COUNT="0"
HPSR_EXTERNAL_KEY_COUNT="0"
HPSR_MANAGED_KEY_INSTALLED="no"
PRIVATE_KEY_SAVE_CONFIRMED="no"
KEEP_PRIVATE_KEY_AFTER_RUN="no"
HPSR_INVALID_AUTHORIZED_KEYS_LINES="0"
RUN_MODE="setup"
VERIFY_RESULT="READY"

BASE_PACKAGES=(curl git openssl nano telnet glances)
INSTALLER_DEPENDENCIES=(curl openssl openssh-client openssh-server ca-certificates ufw zip)
SUGGESTED_PACKAGES=(dnsutils net-tools htop ncdu rsync jq zip unzip)

log() {
  if [[ -n "${LOG_FILE:-}" && -d "$(dirname "$LOG_FILE")" ]]; then
    printf '%s\n' "$*" >> "$LOG_FILE"
  fi
}

lang_is_en() {
  [[ "$UI_LANG" == "en" ]]
}

msg() {
  local key="$1"
  case "$UI_LANG:$key" in
    es:language) printf 'Idioma / Language' ;;
    en:language) printf 'Language / Idioma' ;;
    es:language_prompt) printf 'Selecciona idioma' ;;
    en:language_prompt) printf 'Select language' ;;
    es:language_es) printf 'Español (predeterminado)' ;;
    en:language_es) printf 'Spanish (default)' ;;
    es:language_en) printf 'English' ;;
    en:language_en) printf 'English' ;;
    es:subtitle) printf 'Bootstrap seguro para Debian/Ubuntu' ;;
    en:subtitle) printf 'Secure Debian/Ubuntu Bootstrap' ;;
    es:intro_title) printf 'Este asistente te ayudara a asegurar y preparar este servidor.' ;;
    en:intro_title) printf 'This wizard will help you secure and prepare this server.' ;;
    es:intro_note) printf 'No se aplican cambios hasta la confirmacion final.' ;;
    en:intro_note) printf 'No changes are applied until the final confirmation.' ;;
    es:press_enter) printf 'Presiona ENTER para continuar...' ;;
    en:press_enter) printf 'Press ENTER to continue...' ;;
    es:continue) printf '¿Continuar?' ;;
    en:continue) printf 'Continue?' ;;
    es:precheck) printf 'VERIFICACIONES [1/9]' ;;
    en:precheck) printf 'PRECHECK [1/9]' ;;
    es:package_metadata) printf 'METADATOS DE PAQUETES' ;;
    en:package_metadata) printf 'PACKAGE METADATA' ;;
    es:min_dependencies) printf 'DEPENDENCIAS MINIMAS' ;;
    en:min_dependencies) printf 'MINIMUM DEPENDENCIES' ;;
    es:resend_section) printf 'INTEGRACION CON RESEND [2/9]' ;;
    en:resend_section) printf 'RESEND INTEGRATION [2/9]' ;;
    es:identity_section) printf 'IDENTIDAD DEL SERVIDOR [3/9]' ;;
    en:identity_section) printf 'SERVER IDENTITY [3/9]' ;;
    es:admin_section) printf 'USUARIO ADMINISTRATIVO [4/9]' ;;
    en:admin_section) printf 'ADMINISTRATIVE USER [4/9]' ;;
    es:ssh_access_section) printf 'CONFIGURACION DE ACCESO SSH [5/9]' ;;
    en:ssh_access_section) printf 'SSH ACCESS SETUP [5/9]' ;;
    es:ssh_hardening_section) printf 'ENDURECIMIENTO SSH [6/9]' ;;
    en:ssh_hardening_section) printf 'SSH HARDENING [6/9]' ;;
    es:firewall_section) printf 'FIREWALL [7/9]' ;;
    en:firewall_section) printf 'FIREWALL [7/9]' ;;
    es:fail2ban_section) printf 'FAIL2BAN [8/9]' ;;
    en:fail2ban_section) printf 'FAIL2BAN [8/9]' ;;
    es:updates_section) printf 'ACTUALIZACIONES AUTOMATICAS [9/9]' ;;
    en:updates_section) printf 'AUTOMATIC UPDATES [9/9]' ;;
    es:review_section) printf 'REVISION FINAL' ;;
    en:review_section) printf 'FINAL REVIEW' ;;
    es:post_actions) printf 'ACCIONES POSTERIORES' ;;
    en:post_actions) printf 'POST ACTIONS' ;;
    es:applying) printf 'APLICANDO CAMBIOS' ;;
    en:applying) printf 'APPLYING CHANGES' ;;
    es:system_snapshot) printf 'Resumen del sistema' ;;
    en:system_snapshot) printf 'System Snapshot' ;;
    es:hostname) printf 'Hostname' ;;
    en:hostname) printf 'Hostname' ;;
    es:timezone) printf 'Zona horaria' ;;
    en:timezone) printf 'Timezone' ;;
    es:ssh_port) printf 'Puerto SSH' ;;
    en:ssh_port) printf 'SSH Port' ;;
    es:public_ip) printf 'IP publica' ;;
    en:public_ip) printf 'Public IP' ;;
    es:current) printf 'Actual' ;;
    en:current) printf 'Current' ;;
    es:suggested) printf 'Sugerido' ;;
    en:suggested) printf 'Suggested' ;;
    es:hostname_title) printf 'Hostname' ;;
    en:hostname_title) printf 'Hostname' ;;
    es:timezone_title) printf 'Zona horaria' ;;
    en:timezone_title) printf 'Timezone' ;;
    es:keep_hostname) printf '¿Mantener el hostname actual?' ;;
    en:keep_hostname) printf 'Keep current hostname?' ;;
    es:new_hostname) printf 'Nuevo hostname' ;;
    en:new_hostname) printf 'New hostname' ;;
    es:try_tz_suggestion) printf '¿Intentar sugerencia automatica de zona horaria por IP?' ;;
    en:try_tz_suggestion) printf 'Try automatic timezone suggestion by IP?' ;;
    es:use_timezone) printf '¿Usar esta zona horaria?' ;;
    en:use_timezone) printf 'Use this timezone?' ;;
    es:keep_timezone) printf '¿Mantener la zona horaria actual?' ;;
    en:keep_timezone) printf 'Keep current timezone?' ;;
    es:tz_region) printf 'Selecciona una region de zona horaria' ;;
    en:tz_region) printf 'Select a timezone region' ;;
    es:select_timezone) printf 'Selecciona la zona horaria' ;;
    en:select_timezone) printf 'Select timezone' ;;
    es:admin_username) printf 'Nuevo usuario administrador' ;;
    en:admin_username) printf 'New admin username' ;;
    es:admin_password) printf 'Contrasena para el usuario' ;;
    en:admin_password) printf 'Password for user' ;;
    es:confirm_password) printf 'Confirmar contrasena' ;;
    en:confirm_password) printf 'Confirm password' ;;
    es:ssh_access_title) printf 'Selecciona como configurar el acceso SSH' ;;
    en:ssh_access_title) printf 'Choose how to configure SSH access' ;;
    es:ssh_access_generate) printf 'Generar un nuevo par de llaves en este servidor (recomendado)' ;;
    en:ssh_access_generate) printf 'Generate a new key pair on this server (recommended)' ;;
    es:ssh_access_paste) printf 'Pegar una llave publica existente' ;;
    en:ssh_access_paste) printf 'Paste an existing public key' ;;
    es:ssh_access_file) printf 'Usar un archivo de llave publica existente en este servidor' ;;
    en:ssh_access_file) printf 'Use an existing public key file on this server' ;;
    es:key_type_title) printf 'Selecciona el tipo de llave' ;;
    en:key_type_title) printf 'Select key type' ;;
    es:key_comment) printf 'Comentario de la llave' ;;
    en:key_comment) printf 'Key comment' ;;
    es:security_policy) printf 'Politica de seguridad' ;;
    en:security_policy) printf 'Security Policy' ;;
    es:new_ssh_port) printf 'Nuevo puerto SSH' ;;
    en:new_ssh_port) printf 'New SSH port' ;;
    es:root_ssh_disabled) printf 'El acceso SSH de root sera deshabilitado' ;;
    en:root_ssh_disabled) printf 'Root SSH login will be disabled' ;;
    es:password_ssh_disabled) printf 'La autenticacion SSH por contrasena sera deshabilitada' ;;
    en:password_ssh_disabled) printf 'Password authentication will be disabled' ;;
    es:allowed_ports) printf 'Puertos de entrada permitidos' ;;
    en:allowed_ports) printf 'Allowed inbound ports' ;;
    es:add_extra_ports) printf '¿Agregar puertos extra?' ;;
    en:add_extra_ports) printf 'Add extra ports?' ;;
    es:enter_ports) printf 'Ingresa puertos separados por comas' ;;
    en:enter_ports) printf 'Enter ports separated by commas' ;;
    es:fail2ban_help) printf 'Fail2ban protege SSH bloqueando IPs tras multiples intentos fallidos.' ;;
    en:fail2ban_help) printf 'Fail2ban protects SSH by banning IPs after repeated failed login attempts.' ;;
    es:ssh_jail) printf 'Jaula SSH' ;;
    en:ssh_jail) printf 'SSH jail' ;;
    es:fail2ban_enabled) printf 'Fail2ban sera habilitado' ;;
    en:fail2ban_enabled) printf 'Fail2ban will be enabled' ;;
    es:enable_updates) printf '¿Habilitar unattended-upgrades para parches de seguridad?' ;;
    en:enable_updates) printf 'Enable unattended-upgrades for security patches?' ;;
    es:enable_resend) printf '¿Habilitar integracion con Resend?' ;;
    en:enable_resend) printf 'Enable Resend integration?' ;;
    es:resend_api_key) printf 'API key de Resend' ;;
    en:resend_api_key) printf 'Resend API key' ;;
    es:from_address) printf 'Direccion remitente' ;;
    en:from_address) printf 'From address' ;;
    es:to_address) printf 'Direccion destinataria' ;;
    en:to_address) printf 'To address' ;;
    es:running_test) printf 'Ejecutando envio de prueba...' ;;
    en:running_test) printf 'Running test delivery...' ;;
    es:resend_test_passed) printf 'La prueba de Resend fue exitosa' ;;
    en:resend_test_passed) printf 'Resend test passed' ;;
    es:resend_test_failed) printf 'La prueba de Resend fallo' ;;
    en:resend_test_failed) printf 'Resend test failed' ;;
    es:review_http) printf 'Revisa el codigo HTTP y la respuesta mostrados arriba.' ;;
    en:review_http) printf 'Review the HTTP status and response above.' ;;
    es:choose_option) printf 'Elige una opcion:' ;;
    en:choose_option) printf 'Choose an option:' ;;
    es:reconfigure_resend) printf 'Reconfigurar Resend' ;;
    en:reconfigure_resend) printf 'Reconfigure Resend' ;;
    es:continue_without_resend) printf 'Continuar sin Resend' ;;
    en:continue_without_resend) printf 'Continue without Resend' ;;
    es:final_apply) printf "Aplica todos los cambios ahora. Escribe 'apply' o 'yes' para continuar" ;;
    en:final_apply) printf "Apply all changes now? Type 'apply' or 'yes' to continue" ;;
    es:aborted) printf 'Se aborto antes de aplicar los cambios.' ;;
    en:aborted) printf 'Aborted before applying changes.' ;;
    es:email_sent) printf 'Correo enviado por Resend' ;;
    en:email_sent) printf 'Email sent via Resend' ;;
    es:resend_failed) printf 'El envio con Resend fallo' ;;
    en:resend_failed) printf 'Resend delivery failed' ;;
    es:markdown_report) printf 'Reporte Markdown generado en' ;;
    en:markdown_report) printf 'Markdown report generated at' ;;
    es:send_report) printf '¿Enviar reporte de configuracion por Resend?' ;;
    en:send_report) printf 'Send setup report by Resend?' ;;
    es:send_credentials) printf '¿Enviar paquete cifrado de credenciales por Resend?' ;;
    en:send_credentials) printf 'Send encrypted credentials package by Resend?' ;;
    es:archive_password) printf 'Contrasena del archivo' ;;
    en:archive_password) printf 'Archive password' ;;
    es:private_key) printf 'Llave privada' ;;
    en:private_key) printf 'Private Key' ;;
    es:print_private_key) printf '¿Imprimir ahora la llave privada en consola?' ;;
    en:print_private_key) printf 'Print private key in console now?' ;;
    es:sensitive_removed) printf 'Los archivos temporales sensibles fueron eliminados automaticamente' ;;
    en:sensitive_removed) printf 'Sensitive temporary files were removed automatically' ;;
    es:setup_completed) printf 'Configuracion completada correctamente.' ;;
    en:setup_completed) printf 'Setup completed successfully.' ;;
    es:important) printf 'Importante' ;;
    en:important) printf 'Important' ;;
    es:test_ssh_note) printf 'Prueba el acceso SSH en una nueva terminal antes de cerrar esta sesion.' ;;
    en:test_ssh_note) printf 'Open a new terminal and test SSH access before closing this session.' ;;
    es:private_removed_note) printf 'Los artefactos temporales de la llave privada fueron eliminados automaticamente despues de su uso.' ;;
    en:private_removed_note) printf 'Temporary private key artifacts were removed automatically after use.' ;;
    es:ssh_target) printf 'Destino SSH' ;;
    en:ssh_target) printf 'SSH target' ;;
    es:report) printf 'Reporte' ;;
    en:report) printf 'Report' ;;
    es:log) printf 'Log' ;;
    en:log) printf 'Log' ;;
    es:report_title) printf 'Reporte de configuracion del servidor' ;;
    en:report_title) printf 'Server Setup Report' ;;
    es:credentials_title) printf 'Paquete seguro de credenciales' ;;
    en:credentials_title) printf 'Secure Credentials Package' ;;
    es:key_replace_summary) printf 'Resumen de llaves SSH administradas' ;;
    en:key_replace_summary) printf 'Managed SSH key summary' ;;
    es:managed_keys_replaced) printf 'Llaves previas de hpsr.sh reemplazadas' ;;
    en:managed_keys_replaced) printf 'Previous hpsr.sh keys replaced' ;;
    es:external_keys_kept) printf 'Llaves externas conservadas' ;;
    en:external_keys_kept) printf 'External keys preserved' ;;
    es:managed_key_installed) printf 'Nueva llave hpsr.sh instalada' ;;
    en:managed_key_installed) printf 'New hpsr.sh key installed' ;;
    es:key_fingerprint) printf 'Fingerprint de la llave' ;;
    en:key_fingerprint) printf 'Key fingerprint' ;;
    es:key_verified) printf 'La llave SSH generada fue verificada contra authorized_keys' ;;
    en:key_verified) printf 'Generated SSH key was verified against authorized_keys' ;;
    es:key_verify_failed) printf 'No fue posible verificar la llave SSH instalada' ;;
    en:key_verify_failed) printf 'Failed to verify installed SSH key' ;;
    es:confirm_private_saved) printf '¿Confirmas que ya guardaste correctamente la llave privada?' ;;
    en:confirm_private_saved) printf 'Confirm that you have safely saved the private key' ;;
    es:private_key_kept) printf 'La llave privada temporal se conservara en el servidor hasta que la guardes correctamente' ;;
    en:private_key_kept) printf 'Temporary private key will remain on the server until you save it correctly' ;;
    es:private_key_removed) printf 'La llave privada temporal sera eliminada al terminar esta ejecucion' ;;
    en:private_key_removed) printf 'Temporary private key will be removed at the end of this run' ;;
    es:invalid_authorized_keys_lines) printf 'Lineas invalidas eliminadas de authorized_keys' ;;
    en:invalid_authorized_keys_lines) printf 'Invalid lines removed from authorized_keys' ;;
    es:verify_section) printf 'VERIFICACION [solo lectura]' ;;
    en:verify_section) printf 'VERIFY [read-only]' ;;
    es:verify_result) printf 'Resultado final' ;;
    en:verify_result) printf 'Final result' ;;
    es:verify_ready) printf 'READY' ;;
    en:verify_ready) printf 'READY' ;;
    es:verify_warning) printf 'WARNING' ;;
    en:verify_warning) printf 'WARNING' ;;
    es:verify_fail) printf 'FAIL' ;;
    en:verify_fail) printf 'FAIL' ;;
    es:effective_ssh) printf 'Estado efectivo de SSH' ;;
    en:effective_ssh) printf 'Effective SSH status' ;;
    es:listening_port) printf 'Puerto en escucha' ;;
    en:listening_port) printf 'Listening port' ;;
    es:authorized_keys_status) printf 'Estado de authorized_keys' ;;
    en:authorized_keys_status) printf 'authorized_keys status' ;;
    es:managed_key_blocks) printf 'Bloques hpsr.sh detectados' ;;
    en:managed_key_blocks) printf 'hpsr.sh managed blocks' ;;
    es:external_valid_keys) printf 'Llaves externas validas' ;;
    en:external_valid_keys) printf 'Valid external keys' ;;
    es:invalid_lines) printf 'Lineas invalidas' ;;
    en:invalid_lines) printf 'Invalid lines' ;;
    es:detected_admin_user) printf 'Usuario admin detectado' ;;
    en:detected_admin_user) printf 'Detected admin user' ;;
    es:verify_hint_fix) printf 'Si falta acceso SSH, vuelve a ejecutar el script completo para reparar la llave gestionada por hpsr.sh.' ;;
    en:verify_hint_fix) printf 'If SSH access is missing, rerun the full script to repair the hpsr.sh managed key.' ;;
    es:usage) printf 'Uso: bash setup.sh [--verify] [--lang es|en]' ;;
    en:usage) printf 'Usage: bash setup.sh [--verify] [--lang es|en]' ;;
    *) printf '%s' "$key" ;;
  esac
}

init_workspace() {
  mkdir -p "$REPORTS_DIR" "$SSH_BACKUP_DIR" "$SSH_GENERATED_DIR" "$ARCHIVE_DIR" "$LOGS_DIR" || die "Failed to initialize $SCRIPT_BASE_DIR"
  touch "$LOG_FILE" || die "Failed to create log file at $LOG_FILE"
}

run_cmd() {
  log "+ $*"
  "$@" >> "$LOG_FILE" 2>&1
}

register_sensitive_path() {
  local path="$1"
  [[ -n "$path" ]] || return 0
  SENSITIVE_PATHS+=("$path")
}

unregister_sensitive_path() {
  local path="$1"
  local kept=()
  local entry
  for entry in "${SENSITIVE_PATHS[@]}"; do
    [[ "$entry" == "$path" ]] && continue
    kept+=("$entry")
  done
  SENSITIVE_PATHS=("${kept[@]}")
}

set_verify_result() {
  local level="$1"
  case "$level" in
    FAIL)
      VERIFY_RESULT="FAIL"
      ;;
    WARNING)
      [[ "$VERIFY_RESULT" == "FAIL" ]] || VERIFY_RESULT="WARNING"
      ;;
    *) ;;
  esac
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verify)
        RUN_MODE="verify"
        ;;
      --lang)
        shift
        [[ $# -gt 0 ]] || die "$(msg usage)"
      if [[ "$1" == "en" || "$1" == "es" ]]; then
        UI_LANG="$1"
        LANG_EXPLICIT="yes"
      else
        die "$(msg usage)"
      fi
        ;;
      --help|-h)
        printf '%s\n' "$(msg usage)"
        exit 0
        ;;
      *)
        die "$(msg usage)"
        ;;
    esac
    shift
  done
}

cleanup_sensitive_artifacts() {
  local path
  local deleted_any="no"
  for path in "${SENSITIVE_PATHS[@]}"; do
    [[ -n "$path" ]] || continue
    if [[ -d "$path" ]]; then
      rm -rf "$path" >> "$LOG_FILE" 2>&1 || true
      deleted_any="yes"
    elif [[ -e "$path" ]]; then
      rm -f "$path" >> "$LOG_FILE" 2>&1 || true
      deleted_any="yes"
    fi
  done
  if [[ "$deleted_any" == "yes" ]]; then
    DELETE_SENSITIVE_FILES="yes"
    log "Sensitive temporary artifacts cleaned up"
  fi
}

on_exit() {
  [[ "$RUN_MODE" == "verify" ]] && return 0
  cleanup_sensitive_artifacts
  if [[ "$REPORT_WRITTEN" == "no" && -n "$REPORT_FILE" ]]; then
    write_report >/dev/null 2>&1 || true
  fi
}

print_line() {
  printf '%b%s%b\n' "$COLOR_ACCENT" "$1" "$ANSI_RESET"
}

print_bold() {
  printf '%b%s%b\n' "$ANSI_BOLD" "$1" "$ANSI_RESET"
}

divider() {
  printf '%b%s%b\n' "$COLOR_ACCENT" '──────────────────────────────────────────────────────────────' "$ANSI_RESET"
}

section() {
  printf '\n'
  divider
  printf '%b> %s%b\n' "$COLOR_ACCENT$ANSI_BOLD" "$1" "$ANSI_RESET"
  divider
}

subsection() {
  printf '\n%b%s%b\n' "$ANSI_BOLD" "$1" "$ANSI_RESET"
}

key_value() {
  printf '  %-16s %s\n' "$1" "$2"
}

print_ok() {
  printf '%b[ OK ]%b %s\n' "$ANSI_GREEN" "$ANSI_RESET" "$1"
}

print_warn() {
  printf '%b[WARN]%b %s\n' "$ANSI_YELLOW" "$ANSI_RESET" "$1"
}

print_fail() {
  printf '%b[FAIL]%b %s\n' "$ANSI_RED" "$ANSI_RESET" "$1"
}

die() {
  print_fail "$1"
  log "ERROR: $1"
  exit 1
}

pause() {
  printf '%s' "$(msg press_enter)" > "$TTY_OUT"
  read -r -u 3 _
  printf '\n' > "$TTY_OUT"
}

prompt() {
  local label="$1"
  local default="${2:-}"
  local value=""
  if [[ -n "$default" ]]; then
    printf '%s [%s]: ' "$label" "$default" > "$TTY_OUT"
    read -r -u 3 value
    if [[ -z "$value" ]]; then
      value="$default"
    fi
  else
    printf '%s: ' "$label" > "$TTY_OUT"
    read -r -u 3 value
  fi
  printf '%s' "$value"
}

prompt_secret() {
  local label="$1"
  local value=""
  printf '%s: ' "$label" > "$TTY_OUT"
  read -r -s -u 3 value
  printf '\n' > "$TTY_OUT"
  printf '%s' "$value"
}

confirm() {
  local label="$1"
  local default="${2:-yes}"
  local answer=""
  local prompt_text="[Y/n]"
  if [[ "$default" == "no" ]]; then
    prompt_text="[y/N]"
  fi
  printf '%s %s: ' "$label" "$prompt_text" > "$TTY_OUT"
  read -r -u 3 answer
  answer="${answer,,}"
  if [[ -z "$answer" ]]; then
    [[ "$default" == "yes" ]]
    return
  fi
  [[ "$answer" == "y" || "$answer" == "yes" ]]
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-'
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

init_tty() {
  if [[ -r /dev/tty && -w /dev/tty ]]; then
    exec 3</dev/tty
    exec 4>/dev/tty
    TTY_IN="/dev/fd/3"
    TTY_OUT="/dev/fd/4"
    return 0
  fi
  die "This script requires an interactive terminal. Download it and run with bash if /dev/tty is unavailable."
}

select_language() {
  local option
  section "$(msg language_prompt)"
  option="$(select_from_list "$(msg language)" "$(msg language_es)" "$(msg language_en)")"
  if [[ "$option" == "$(msg language_en)" ]]; then
    UI_LANG="en"
  else
    UI_LANG="es"
  fi
}

detect_os() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_VERSION="${VERSION_ID:-}"
  fi
}

detect_hostname() {
  CURRENT_HOSTNAME="$(hostname 2>/dev/null || true)"
  HOSTNAME_VALUE="$CURRENT_HOSTNAME"
}

detect_timezone() {
  if command_exists timedatectl; then
    CURRENT_TIMEZONE="$(timedatectl show --property=Timezone --value 2>/dev/null || true)"
  fi
  if [[ -z "$CURRENT_TIMEZONE" || "$CURRENT_TIMEZONE" == "n/a" ]]; then
    if [[ -L /etc/localtime ]]; then
      CURRENT_TIMEZONE="$(readlink /etc/localtime | sed 's#.*/zoneinfo/##')"
    elif [[ -r /etc/timezone ]]; then
      CURRENT_TIMEZONE="$(tr -d '[:space:]' < /etc/timezone)"
    else
      CURRENT_TIMEZONE="UTC"
    fi
  fi
  TIMEZONE_VALUE="$CURRENT_TIMEZONE"
}

detect_ssh_port() {
  local port
  port="$(awk '$1 == "Port" {print $2; exit}' "$SSH_CONFIG_PATH" 2>/dev/null || true)"
  if [[ -n "$port" ]]; then
    CURRENT_SSH_PORT="$port"
  fi
}

detect_ssh_service_name() {
  if systemctl list-unit-files 2>/dev/null | grep -q '^sshd\.service'; then
    SSH_SERVICE_NAME="sshd"
  else
    SSH_SERVICE_NAME="ssh"
  fi
}

detect_public_ip() {
  PUBLIC_IP="$(curl -fsS --max-time 5 https://api.ipify.org 2>>"$LOG_FILE" || true)"
}

detect_container() {
  if [[ -f /.dockerenv ]] || grep -qaE '(docker|containerd|lxc|kubepods)' /proc/1/cgroup 2>/dev/null; then
    ENV_IS_CONTAINER="yes"
  elif command_exists systemd-detect-virt && systemd-detect-virt --quiet --container 2>>"$LOG_FILE"; then
    ENV_IS_CONTAINER="yes"
  fi
}

print_banner() {
  printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "$COLOR_ACCENT" "$ANSI_RESET"
  printf '%b║ %-60s ║%b\n' "$COLOR_ACCENT" "$SCRIPT_BRAND_PRIMARY" "$ANSI_RESET"
  printf '%b║ %-60s ║%b\n' "$COLOR_ACCENT" "$(msg subtitle)" "$ANSI_RESET"
  printf '%b║ %-60s ║%b\n' "$COLOR_ACCENT" "$SCRIPT_BRAND_SECONDARY" "$ANSI_RESET"
  printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "$COLOR_ACCENT" "$ANSI_RESET"
  key_value "Version" "$SCRIPT_VERSION"
  key_value "Accent" "$ACCENT_HEX"
  key_value "Report" "$REPORT_FILE"
  key_value "Log" "$LOG_FILE"
}

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "Run this script as root."
}

prechecks() {
  section "$(msg precheck)"
  require_root
  init_workspace
  detect_os
  detect_hostname
  detect_timezone
  detect_ssh_port
  detect_ssh_service_name
  detect_public_ip
  detect_container

  [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]] || die "Supported distros: Debian or Ubuntu."
  command_exists apt-get || die "apt-get not found."

  print_ok "Running as root"
  print_ok "Supported distro detected: ${OS_ID:-unknown} ${OS_VERSION:-}"
  print_ok "apt available"
  if [[ -n "$PUBLIC_IP" ]]; then
    print_ok "Network connectivity detected"
  else
    print_warn "Public IP lookup failed; internet connectivity may still work"
  fi
  if [[ -f "$SSH_CONFIG_PATH" ]]; then
    print_ok "SSH server configuration detected"
  else
    print_warn "SSH configuration file not found yet; openssh-server will be installed if needed"
  fi
  print_ok "Writable workspace: $SCRIPT_BASE_DIR"
  if [[ "$ENV_IS_CONTAINER" == "yes" ]]; then
    print_warn "Container environment detected; some system-level changes may be skipped"
  fi

  subsection "$(msg system_snapshot)"
  key_value "$(msg hostname)" "$CURRENT_HOSTNAME"
  key_value "$(msg timezone)" "$CURRENT_TIMEZONE"
  key_value "$(msg ssh_port)" "$CURRENT_SSH_PORT"
  if [[ -n "$PUBLIC_IP" ]]; then
    key_value "$(msg public_ip)" "$PUBLIC_IP"
  fi

  confirm "$(msg continue)" yes || exit 0
}

apt_update_once() {
  section "$(msg package_metadata)"
  run_cmd apt-get update || die "apt-get update failed. Check $LOG_FILE"
  print_ok "Package metadata updated"
}

install_packages() {
  local packages=()
  packages=("$@")
  if [[ "${#packages[@]}" -eq 0 ]]; then
    return 0
  fi
  DEBIAN_FRONTEND=noninteractive run_cmd apt-get install -y "${packages[@]}" || return 1
  INSTALLED_PACKAGES+=("${packages[@]}")
}

ensure_installer_dependencies() {
  section "$(msg min_dependencies)"
  local missing=()
  local pkg
  for pkg in "${INSTALLER_DEPENDENCIES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ "${#missing[@]}" -eq 0 ]]; then
    print_ok "Installer dependencies already present"
  else
    install_packages "${missing[@]}" || die "Failed to install required dependencies. Check $LOG_FILE"
    print_ok "Installed installer dependencies: ${missing[*]}"
  fi
}

resend_test_request() {
  local payload_file="$GENERATED_DIR/resend-test-$TIMESTAMP.json"
  local response_file="$GENERATED_DIR/resend-test-response-$TIMESTAMP.json"
  local http_code=""
  register_sensitive_path "$payload_file"
  register_sensitive_path "$response_file"
  cat > "$payload_file" <<EOF
{"from":"$RESEND_FROM","to":["$RESEND_TO"],"subject":"$SCRIPT_NAME test delivery","text":"$SCRIPT_NAME test delivery from $CURRENT_HOSTNAME at $TIMESTAMP"}
EOF
  http_code="$(curl -sS -o "$response_file" -w '%{http_code}' \
    -X POST https://api.resend.com/emails \
    -H "Authorization: Bearer $RESEND_API_KEY" \
    -H 'Content-Type: application/json' \
    --data-binary "@$payload_file" 2>>"$LOG_FILE" || true)"
  RESEND_TEST_MESSAGE="$(tr -d '\r' < "$response_file" 2>/dev/null || true)"
  if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
    RESEND_TEST_STATUS="passed"
    return 0
  fi
  RESEND_TEST_STATUS="failed"
  log "Resend test failed: HTTP $http_code; body: $RESEND_TEST_MESSAGE"
  printf 'HTTP status : %s\n' "${http_code:-unknown}"
  printf 'Response    : %s\n' "${RESEND_TEST_MESSAGE:-<empty>}"
  return 1
}

configure_resend() {
  section "$(msg resend_section)"
  if lang_is_en; then
    printf 'Use Resend to:\n'
    printf -- '- send a setup summary\n'
    printf -- '- render the setup report directly in the email body\n'
    printf -- '- optionally send credentials/keys as encrypted attachments\n\n'
  else
    printf 'Usa Resend para:\n'
    printf -- '- enviar un resumen de la configuracion\n'
    printf -- '- mostrar el reporte directamente en el cuerpo del correo\n'
    printf -- '- enviar opcionalmente credenciales/llaves como adjuntos cifrados\n\n'
  fi

  if ! confirm "$(msg enable_resend)" no; then
    RESEND_ENABLED="no"
    return 0
  fi

  while true; do
    RESEND_API_KEY="$(prompt_secret "$(msg resend_api_key)")"
    RESEND_FROM="$(prompt "$(msg from_address)")"
    RESEND_TO="$(prompt "$(msg to_address)")"

    printf '\n%s\n\n' "$(msg running_test)"
    if resend_test_request; then
      print_ok "$(msg resend_test_passed)"
      RESEND_ENABLED="yes"
      return 0
    fi

    print_fail "$(msg resend_test_failed)"
    print_warn "$(msg review_http)"
    printf '%s\n' "$(msg choose_option)"
    printf '1. %s\n' "$(msg reconfigure_resend)"
    printf '2. %s\n' "$(msg continue_without_resend)"
    local option
    option="$(prompt 'Select' '1')"
    if [[ "$option" == "2" ]]; then
      RESEND_ENABLED="no"
      return 0
    fi
  done
}

load_timezones() {
  if command_exists timedatectl; then
    timedatectl list-timezones 2>/dev/null
  elif [[ -d /usr/share/zoneinfo ]]; then
    find /usr/share/zoneinfo -type f \
      ! -path '*/posix/*' ! -path '*/right/*' ! -path '*/SystemV/*' ! -name 'zone.tab' ! -name 'iso3166.tab' \
      | sed 's#/usr/share/zoneinfo/##' | sort
  fi
}

timezone_ip_suggestion() {
  local guess=""
  local response
  response="$(curl -fsS --max-time 5 https://ipapi.co/timezone 2>>"$LOG_FILE" || true)"
  if [[ -n "$response" && "$response" == */* ]]; then
    guess="$response"
  fi
  printf '%s' "$guess"
}

select_from_list() {
  local title="$1"
  shift
  local options=("$@")
  local selected=""
  local index=1
  local option

  printf '\n%b%s%b\n' "$ANSI_BOLD" "$title" "$ANSI_RESET" > "$TTY_OUT"
  for option in "${options[@]}"; do
    printf '  [%d] %s\n' "$index" "$option" > "$TTY_OUT"
    index=$((index + 1))
  done
  selected="$(prompt 'Selection' '1')"
  if [[ "$selected" =~ ^[0-9]+$ ]] && (( selected >= 1 && selected <= ${#options[@]} )); then
    printf '%s' "${options[$((selected - 1))]}"
  fi
}

select_multiple_from_list() {
  local title="$1"
  shift
  local options=("$@")
  local selected=()
  local option
  local answer

  if [[ "${#options[@]}" -eq 0 ]]; then
    return 0
  fi

  printf '\n%b%s%b\n' "$ANSI_BOLD" "$title" "$ANSI_RESET" > "$TTY_OUT"
  local index=1
  for option in "${options[@]}"; do
    printf '  [%d] %s\n' "$index" "$option" > "$TTY_OUT"
    index=$((index + 1))
  done
  answer="$(prompt 'Select numbers separated by commas, or leave empty for none' '')"
  if [[ -z "$answer" ]]; then
    return 0
  fi
  IFS=',' read -r -a selected <<< "$answer"
  for option in "${selected[@]}"; do
    option="${option// /}"
    if [[ "$option" =~ ^[0-9]+$ ]] && (( option >= 1 && option <= ${#options[@]} )); then
      printf '%s\n' "${options[$((option - 1))]}"
    fi
  done
}

configure_identity() {
  section "$(msg identity_section)"
  subsection "$(msg hostname_title)"
  key_value "$(msg current)" "$CURRENT_HOSTNAME"
  if ! confirm "$(msg keep_hostname)" yes; then
    HOSTNAME_VALUE="$(prompt "$(msg new_hostname)")"
  fi

  subsection "$(msg timezone_title)"
  key_value "$(msg current)" "$CURRENT_TIMEZONE"
  if confirm "$(msg try_tz_suggestion)" yes; then
    TIMEZONE_IP_SUGGESTION="$(timezone_ip_suggestion)"
    if [[ -n "$TIMEZONE_IP_SUGGESTION" ]]; then
      key_value "$(msg suggested)" "$TIMEZONE_IP_SUGGESTION"
      if confirm "$(msg use_timezone)" yes; then
        TIMEZONE_VALUE="$TIMEZONE_IP_SUGGESTION"
        return 0
      fi
    else
      print_warn "Automatic timezone suggestion was not available"
    fi
  fi

  if confirm "$(msg keep_timezone)" yes; then
    TIMEZONE_VALUE="$CURRENT_TIMEZONE"
    return 0
  fi

  local region
  region="$(select_from_list "$(msg tz_region)" America Europe Asia Africa Pacific Etc)"
  [[ -n "$region" ]] || region="America"
  mapfile -t tz_matches < <(load_timezones | grep "^${region}/" | head -n 200)
  if [[ "${#tz_matches[@]}" -eq 0 ]]; then
    TIMEZONE_VALUE="$CURRENT_TIMEZONE"
    print_warn "No timezones found for region $region; keeping current timezone"
    return 0
  fi
  TIMEZONE_VALUE="$(select_from_list "$(msg select_timezone)" "${tz_matches[@]}")"
  [[ -n "$TIMEZONE_VALUE" ]] || TIMEZONE_VALUE="$CURRENT_TIMEZONE"
}

configure_admin_user() {
  section "$(msg admin_section)"
  while true; do
    ADMIN_USER="$(prompt "$(msg admin_username)")"
    if [[ -n "$ADMIN_USER" && "$ADMIN_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
      break
    fi
    print_warn "Use a valid Linux username."
  done
  while true; do
    ADMIN_PASSWORD="$(prompt_secret "$(msg admin_password) '$ADMIN_USER'")"
    [[ -n "$ADMIN_PASSWORD" ]] || {
      print_warn "Password cannot be empty."
      continue
    }
    local confirm_password
    confirm_password="$(prompt_secret "$(msg confirm_password)")"
    if [[ "$ADMIN_PASSWORD" == "$confirm_password" ]]; then
      break
    fi
    print_warn "Passwords do not match."
  done
}

validate_port() {
  [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 ))
}

collect_ssh_key_setup() {
  section "$(msg ssh_access_section)"
  subsection "$(msg ssh_access_title)"
  local option
  option="$(select_from_list "$(msg ssh_access_title)" "$(msg ssh_access_generate)" "$(msg ssh_access_paste)" "$(msg ssh_access_file)")"
  case "$option" in
    "$(msg ssh_access_paste)") SSH_KEY_MODE="paste" ;;
    "$(msg ssh_access_file)") SSH_KEY_MODE="file" ;;
    *) SSH_KEY_MODE="generate" ;;
  esac

  if [[ "$SSH_KEY_MODE" == "generate" ]]; then
    subsection "$(msg key_type_title)"
    option="$(select_from_list "$(msg key_type_title)" 'ed25519 (recommended)' 'rsa')"
    if [[ "$option" == "rsa" ]]; then
      SSH_KEY_TYPE="rsa"
    fi
    SSH_KEY_COMMENT="hpsr.sh|host=$(slugify "$HOSTNAME_VALUE")|user=$ADMIN_USER|ts=$TIMESTAMP"
    SSH_PRIVATE_KEY_PATH="$SSH_GENERATED_DIR/hpsr-${TIMESTAMP}-$(slugify "$HOSTNAME_VALUE")-${ADMIN_USER}_${SSH_KEY_TYPE}"
    SSH_PUBLIC_KEY_PATH="$SSH_PRIVATE_KEY_PATH.pub"
    register_sensitive_path "$SSH_PRIVATE_KEY_PATH"
    register_sensitive_path "$SSH_PUBLIC_KEY_PATH"
  elif [[ "$SSH_KEY_MODE" == "paste" ]]; then
    SSH_PUBLIC_KEY_CONTENT="$(prompt 'Paste public key')"
  else
    SSH_PUBLIC_KEY_PATH="$(prompt 'Public key file path')"
  fi
}

configure_ssh_hardening_inputs() {
  section "$(msg ssh_hardening_section)"
  subsection "$(msg security_policy)"
  key_value "$(msg current)" "$CURRENT_SSH_PORT"
  key_value "$(msg suggested)" "666"
  printf '\n'

  while true; do
    SSH_PORT="$(prompt "$(msg new_ssh_port)" '666')"
    if validate_port "$SSH_PORT"; then
      break
    fi
    print_warn "Enter a valid TCP port between 1 and 65535."
  done
  DISABLE_ROOT_SSH="yes"
  DISABLE_PASSWORD_AUTH="yes"
  print_ok "$(msg root_ssh_disabled)"
  print_ok "$(msg password_ssh_disabled)"
}

collect_firewall_inputs() {
  section "$(msg firewall_section)"
  subsection "$(msg allowed_ports)"
  key_value "SSH" "$SSH_PORT/tcp"
  key_value "HTTP" "80/tcp"
  key_value "HTTPS" "443/tcp"
  printf '\n'
  if confirm "$(msg add_extra_ports)" no; then
    UFW_EXTRA_PORTS="$(prompt "$(msg enter_ports)")"
  fi
}

collect_fail2ban_inputs() {
  section "$(msg fail2ban_section)"
  printf '%s\n' "$(msg fail2ban_help)"
  subsection "$(msg ssh_jail)"
  printf -- '- bantime  : 1h\n'
  printf -- '- findtime : 10m\n'
  printf -- '- maxretry : 5\n\n'
  ENABLE_FAIL2BAN="yes"
  print_ok "$(msg fail2ban_enabled)"
}

collect_unattended_inputs() {
  section "$(msg updates_section)"
  if confirm "$(msg enable_updates)" yes; then
    ENABLE_UNATTENDED="yes"
  else
    ENABLE_UNATTENDED="no"
  fi
}

generate_password() {
  openssl rand -hex 16
}

ssh_public_key_base() {
  local key_line="$1"
  printf '%s\n' "$key_line" | awk '{print $1" "$2}'
}

count_non_managed_keys() {
  local auth_file="$1"
  [[ -f "$auth_file" ]] || {
    printf '0'
    return 0
  }
  awk '
    /^# BEGIN hpsr\.sh managed key$/ {managed=1; next}
    /^# END hpsr\.sh managed key$/ {managed=0; next}
    managed {next}
    /^[[:space:]]*$/ {next}
    /^#/ {next}
    /^(ssh-(ed25519|rsa)|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh.com|sk-ecdsa-sha2-nistp256@openssh.com)[[:space:]]+[A-Za-z0-9+/=]+([[:space:]].*)?$/ {count++}
    END {print count+0}
  ' "$auth_file"
}

count_invalid_authorized_keys_lines() {
  local auth_file="$1"
  [[ -f "$auth_file" ]] || {
    printf '0'
    return 0
  }
  awk '
    /^# BEGIN hpsr\.sh managed key$/ {managed=1; next}
    /^# END hpsr\.sh managed key$/ {managed=0; next}
    managed {next}
    /^[[:space:]]*$/ {next}
    /^#/ {next}
    /^(ssh-(ed25519|rsa)|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh.com|sk-ecdsa-sha2-nistp256@openssh.com)[[:space:]]+[A-Za-z0-9+/=]+([[:space:]].*)?$/ {next}
    {count++}
    END {print count+0}
  ' "$auth_file"
}

count_managed_key_blocks() {
  local auth_file="$1"
  [[ -f "$auth_file" ]] || {
    printf '0'
    return 0
  }
  grep -c '^# BEGIN hpsr\.sh managed key$' "$auth_file" 2>/dev/null || printf '0'
}

remove_managed_keys_from_authorized_keys() {
  local auth_file="$1"
  local temp_file="$GENERATED_DIR/authorized_keys-clean-$TIMESTAMP"
  register_sensitive_path "$temp_file"
  if [[ ! -f "$auth_file" ]]; then
    HPSR_MANAGED_KEY_REPLACED_COUNT="0"
    HPSR_EXTERNAL_KEY_COUNT="0"
    HPSR_INVALID_AUTHORIZED_KEYS_LINES="0"
    return 0
  fi
  HPSR_MANAGED_KEY_REPLACED_COUNT="$(count_managed_key_blocks "$auth_file")"
  HPSR_EXTERNAL_KEY_COUNT="$(count_non_managed_keys "$auth_file")"
  HPSR_INVALID_AUTHORIZED_KEYS_LINES="$(count_invalid_authorized_keys_lines "$auth_file")"
  awk '
    /^# BEGIN hpsr\.sh managed key$/ {managed=1; next}
    /^# END hpsr\.sh managed key$/ {managed=0; next}
    managed {next}
    /^[[:space:]]*$/ {next}
    /^#/ {print; next}
    /^(ssh-(ed25519|rsa)|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh.com|sk-ecdsa-sha2-nistp256@openssh.com)[[:space:]]+[A-Za-z0-9+/=]+([[:space:]].*)?$/ {print; next}
  ' "$auth_file" > "$temp_file" || return 1
  mv "$temp_file" "$auth_file" || return 1
  unregister_sensitive_path "$temp_file"
  return 0
}

authorized_keys_contains_key_base() {
  local auth_file="$1"
  local key_base="$2"
  [[ -f "$auth_file" ]] || return 1
  awk '/^ssh-|^ecdsa-sha2-|^sk-/{print $1" "$2}' "$auth_file" | grep -Fqx "$key_base"
}

verify_generated_key_installation() {
  local auth_file="$1"
  local derived_line=""
  [[ "$SSH_KEY_MODE" == "generate" ]] || return 0
  [[ -f "$SSH_PRIVATE_KEY_PATH" ]] || return 1
  derived_line="$(ssh-keygen -y -f "$SSH_PRIVATE_KEY_PATH" 2>>"$LOG_FILE" || true)"
  [[ -n "$derived_line" ]] || return 1
  SSH_DERIVED_PUBLIC_KEY_BASE="$(ssh_public_key_base "$derived_line")"
  SSH_KEY_FINGERPRINT="$(ssh-keygen -lf "$SSH_PRIVATE_KEY_PATH" 2>>"$LOG_FILE" | awk '{print $2}' || true)"
  [[ -n "$SSH_DERIVED_PUBLIC_KEY_BASE" ]] || return 1
  authorized_keys_contains_key_base "$auth_file" "$SSH_DERIVED_PUBLIC_KEY_BASE"
}

validate_public_key() {
  local key="$1"
  [[ "$key" =~ ^ssh-(ed25519|rsa)\ [A-Za-z0-9+/=]+([[:space:]].*)?$ ]]
}

ensure_user_exists() {
  if id "$ADMIN_USER" >/dev/null 2>&1; then
    print_warn "User '$ADMIN_USER' already exists; it will be reused"
  else
    run_cmd useradd -m -s /bin/bash "$ADMIN_USER" || die "Failed to create user '$ADMIN_USER'"
    print_ok "Created user '$ADMIN_USER'"
  fi
  run_cmd usermod -aG sudo "$ADMIN_USER" || die "Failed to add '$ADMIN_USER' to sudo group"
  printf '%s:%s\n' "$ADMIN_USER" "$ADMIN_PASSWORD" | chpasswd >> "$LOG_FILE" 2>&1 || die "Failed to set password for '$ADMIN_USER'"
  run_cmd install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "/home/$ADMIN_USER/.ssh" || die "Failed to create .ssh directory"
}

service_action() {
  local action="$1"
  local service_name="$2"
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then
    run_cmd systemctl "$action" "$service_name" && return 0
  fi
  if command_exists service; then
    run_cmd service "$service_name" "$action" && return 0
  fi
  return 1
}

service_is_active() {
  local service_name="$1"
  if command_exists systemctl && systemctl list-unit-files >/dev/null 2>&1; then
    systemctl is-active --quiet "$service_name" >> "$LOG_FILE" 2>&1
    return $?
  fi
  if command_exists service; then
    service "$service_name" status >> "$LOG_FILE" 2>&1
    return $?
  fi
  return 1
}

detect_admin_user_for_verify() {
  local sudo_members=""
  sudo_members="$(getent group sudo 2>/dev/null | cut -d: -f4 || true)"
  if [[ -n "$sudo_members" ]]; then
    ADMIN_USER="${sudo_members%%,*}"
  fi
}

verify_setup() {
  local ssh_config_dump=""
  local port_effective=""
  local permit_root_login=""
  local password_auth=""
  local pubkey_auth=""
  local auth_file=""
  local auth_mode_text=""
  local managed_blocks="0"
  local external_keys="0"
  local invalid_lines="0"
  local auth_perms="missing"
  local ufw_status=""

  require_root
  init_workspace
  detect_os
  detect_hostname
  detect_timezone
  detect_ssh_port
  detect_public_ip
  detect_container
  detect_ssh_service_name
  detect_admin_user_for_verify

  section "$(msg verify_section)"
  subsection "$(msg system_snapshot)"
  key_value "$(msg hostname)" "$CURRENT_HOSTNAME"
  key_value "$(msg timezone)" "$CURRENT_TIMEZONE"
  key_value "$(msg ssh_port)" "$CURRENT_SSH_PORT"
  if [[ -n "$PUBLIC_IP" ]]; then
    key_value "$(msg public_ip)" "$PUBLIC_IP"
  fi

  ssh_config_dump="$(sshd -T 2>>"$LOG_FILE" || true)"
  if [[ -z "$ssh_config_dump" ]]; then
    print_fail "Unable to read effective sshd configuration"
    set_verify_result FAIL
  else
    port_effective="$(printf '%s\n' "$ssh_config_dump" | awk '$1=="port"{print $2; exit}')"
    permit_root_login="$(printf '%s\n' "$ssh_config_dump" | awk '$1=="permitrootlogin"{print $2; exit}')"
    password_auth="$(printf '%s\n' "$ssh_config_dump" | awk '$1=="passwordauthentication"{print $2; exit}')"
    pubkey_auth="$(printf '%s\n' "$ssh_config_dump" | awk '$1=="pubkeyauthentication"{print $2; exit}')"
  fi

  subsection "$(msg effective_ssh)"
  key_value "$(msg ssh_port)" "${port_effective:-unknown}"
  key_value "PermitRootLogin" "${permit_root_login:-unknown}"
  key_value "PasswordAuthentication" "${password_auth:-unknown}"
  key_value "PubkeyAuthentication" "${pubkey_auth:-unknown}"

  if [[ -n "$port_effective" ]] && ss -tln 2>>"$LOG_FILE" | awk '{print $4}' | grep -Eq "(^|[.:])${port_effective}$"; then
    print_ok "$(msg listening_port): $port_effective"
  else
    print_fail "$(msg listening_port): ${port_effective:-unknown}"
    set_verify_result FAIL
  fi

  [[ "$permit_root_login" == "no" ]] || set_verify_result FAIL
  [[ "$password_auth" == "no" ]] || set_verify_result FAIL
  [[ "$pubkey_auth" == "yes" ]] || set_verify_result FAIL

  subsection "$(lang_is_en && printf 'Administrative user' || printf 'Usuario administrativo')"
  if [[ -n "$ADMIN_USER" ]] && id "$ADMIN_USER" >/dev/null 2>&1; then
    key_value "$(msg detected_admin_user)" "$ADMIN_USER"
    auth_file="/home/$ADMIN_USER/.ssh/authorized_keys"
  else
    key_value "$(msg detected_admin_user)" "not-found"
    set_verify_result WARNING
  fi

  subsection "$(msg authorized_keys_status)"
  if [[ -n "$auth_file" && -f "$auth_file" ]]; then
    managed_blocks="$(count_managed_key_blocks "$auth_file")"
    external_keys="$(count_non_managed_keys "$auth_file")"
    invalid_lines="$(count_invalid_authorized_keys_lines "$auth_file")"
    auth_perms="$(stat -c '%a' "$auth_file" 2>>"$LOG_FILE" || printf 'unknown')"
    key_value "$(msg managed_key_blocks)" "$managed_blocks"
    key_value "$(msg external_valid_keys)" "$external_keys"
    key_value "$(msg invalid_lines)" "$invalid_lines"
    key_value "Permissions" "$auth_perms"
    if (( managed_blocks + external_keys == 0 )); then
      print_fail "No valid SSH keys found in authorized_keys"
      set_verify_result FAIL
    fi
    if [[ "$invalid_lines" != "0" ]]; then
      print_warn "$(msg invalid_authorized_keys_lines): $invalid_lines"
      set_verify_result WARNING
    fi
    if [[ "$auth_perms" != "600" ]]; then
      print_warn "authorized_keys permissions should be 600"
      set_verify_result WARNING
    fi
  else
    print_fail "authorized_keys not found for ${ADMIN_USER:-unknown-user}"
    set_verify_result FAIL
  fi

  subsection "Firewall"
  if command_exists ufw; then
    ufw_status="$(ufw status 2>>"$LOG_FILE" || true)"
    if printf '%s\n' "$ufw_status" | grep -q '^Status: active'; then
      print_ok "UFW active"
      if [[ -n "$port_effective" ]] && printf '%s\n' "$ufw_status" | grep -Fq "$port_effective/tcp"; then
        print_ok "UFW rule present for SSH port $port_effective"
      else
        print_warn "UFW rule for SSH port ${port_effective:-unknown} was not found"
        set_verify_result WARNING
      fi
    else
      print_warn "UFW is not active"
      set_verify_result WARNING
    fi
  else
    print_warn "UFW is not installed"
    set_verify_result WARNING
  fi

  subsection "Services"
  if service_is_active fail2ban; then
    print_ok "Fail2ban active"
  else
    print_warn "Fail2ban inactive"
    set_verify_result WARNING
  fi

  if dpkg -s unattended-upgrades >/dev/null 2>&1; then
    print_ok "unattended-upgrades installed"
  else
    print_warn "unattended-upgrades not installed"
    set_verify_result WARNING
  fi

  subsection "$(msg verify_result)"
  key_value "$(msg verify_result)" "$(msg verify_${VERIFY_RESULT,,})"
  if [[ "$VERIFY_RESULT" != "READY" ]]; then
    print_warn "$(msg verify_hint_fix)"
  fi
}

prepare_sshd_runtime() {
  if [[ ! -d /run/sshd ]]; then
    mkdir -p /run/sshd >> "$LOG_FILE" 2>&1 || return 1
  fi
  chmod 755 /run/sshd >> "$LOG_FILE" 2>&1 || return 1
  return 0
}

apply_hostname() {
  if [[ "$HOSTNAME_VALUE" != "$CURRENT_HOSTNAME" && -n "$HOSTNAME_VALUE" ]]; then
    if command_exists hostnamectl && run_cmd hostnamectl set-hostname "$HOSTNAME_VALUE"; then
      HOSTNAME_APPLY_STATUS="updated"
      print_ok "Hostname updated to $HOSTNAME_VALUE"
    else
      printf '%s\n' "$HOSTNAME_VALUE" > /etc/hostname 2>>"$LOG_FILE" || true
      if run_cmd hostname "$HOSTNAME_VALUE"; then
        HOSTNAME_APPLY_STATUS="updated"
        print_ok "Hostname updated to $HOSTNAME_VALUE"
      else
        HOSTNAME_APPLY_STATUS="skipped"
        print_warn "Hostname change could not be applied in this environment; continuing"
      fi
    fi
  else
    HOSTNAME_APPLY_STATUS="unchanged"
    print_ok "Hostname kept as $HOSTNAME_VALUE"
  fi
}

apply_timezone() {
  if [[ -n "$TIMEZONE_VALUE" ]]; then
    if command_exists timedatectl && run_cmd timedatectl set-timezone "$TIMEZONE_VALUE"; then
      TIMEZONE_APPLY_STATUS="updated"
      print_ok "Timezone set to $TIMEZONE_VALUE"
      return 0
    fi
    printf '%s\n' "$TIMEZONE_VALUE" > /etc/timezone 2>>"$LOG_FILE" || true
    if run_cmd ln -sf "/usr/share/zoneinfo/$TIMEZONE_VALUE" /etc/localtime; then
      if command_exists dpkg-reconfigure; then
        run_cmd dpkg-reconfigure -f noninteractive tzdata || true
      fi
      TIMEZONE_APPLY_STATUS="updated"
      print_ok "Timezone set to $TIMEZONE_VALUE"
    else
      TIMEZONE_APPLY_STATUS="skipped"
      print_warn "Timezone could not be fully applied in this environment; continuing"
    fi
  fi
}

generate_ssh_keys() {
  local key_args=()
  if [[ "$SSH_KEY_TYPE" == "rsa" ]]; then
    key_args=(-t rsa -b 4096)
  else
    key_args=(-t ed25519)
  fi
  rm -f "$SSH_PRIVATE_KEY_PATH" "$SSH_PUBLIC_KEY_PATH" >> "$LOG_FILE" 2>&1 || true
  run_cmd ssh-keygen "${key_args[@]}" -C "$SSH_KEY_COMMENT" -f "$SSH_PRIVATE_KEY_PATH" -N '' || die "Failed to generate SSH key pair"
  SSH_PUBLIC_KEY_CONTENT="$(tr -d '\r\n' < "$SSH_PUBLIC_KEY_PATH")"
  SSH_PUBLIC_KEY_BASE="$(ssh_public_key_base "$SSH_PUBLIC_KEY_CONTENT")"
  print_ok "Generated SSH key pair at $SSH_PRIVATE_KEY_PATH"
}

load_public_key_content() {
  if [[ "$SSH_KEY_MODE" == "generate" ]]; then
    generate_ssh_keys
  elif [[ "$SSH_KEY_MODE" == "paste" ]]; then
    if ! validate_public_key "$SSH_PUBLIC_KEY_CONTENT"; then
      die "The pasted public key is not valid."
    fi
    SSH_PUBLIC_KEY_BASE="$(ssh_public_key_base "$SSH_PUBLIC_KEY_CONTENT")"
  else
    [[ -r "$SSH_PUBLIC_KEY_PATH" ]] || die "Public key file not found: $SSH_PUBLIC_KEY_PATH"
    SSH_PUBLIC_KEY_CONTENT="$(tr -d '\r\n' < "$SSH_PUBLIC_KEY_PATH")"
    validate_public_key "$SSH_PUBLIC_KEY_CONTENT" || die "The public key file content is not valid."
    SSH_PUBLIC_KEY_BASE="$(ssh_public_key_base "$SSH_PUBLIC_KEY_CONTENT")"
  fi
}

install_public_key_for_user() {
  local auth_file="/home/$ADMIN_USER/.ssh/authorized_keys"
  touch "$auth_file"
  chmod 600 "$auth_file"
  chown "$ADMIN_USER:$ADMIN_USER" "$auth_file"
  remove_managed_keys_from_authorized_keys "$auth_file" || die "Failed to rotate managed SSH keys in authorized_keys"
  if [[ "$HPSR_INVALID_AUTHORIZED_KEYS_LINES" != "0" ]]; then
    print_warn "$(msg invalid_authorized_keys_lines): $HPSR_INVALID_AUTHORIZED_KEYS_LINES"
  fi
  printf '# BEGIN hpsr.sh managed key\n' >> "$auth_file"
  printf '%s\n' "$SSH_PUBLIC_KEY_CONTENT" >> "$auth_file"
  printf '# END hpsr.sh managed key\n' >> "$auth_file"
  chown "$ADMIN_USER:$ADMIN_USER" "$auth_file"
  if verify_generated_key_installation "$auth_file"; then
    HPSR_MANAGED_KEY_INSTALLED="yes"
    print_ok "Installed public key for $ADMIN_USER"
    if [[ "$SSH_KEY_MODE" == "generate" ]]; then
      print_ok "$(msg key_verified)"
    fi
  else
    HPSR_MANAGED_KEY_INSTALLED="no"
    die "$(msg key_verify_failed)"
  fi
}

backup_ssh_config() {
  [[ -f "$SSH_CONFIG_PATH" ]] || touch "$SSH_CONFIG_PATH"
  local backup="$SSH_BACKUP_DIR/sshd_config-$TIMESTAMP.bak"
  cp "$SSH_CONFIG_PATH" "$backup" || die "Failed to back up sshd_config"
  print_ok "Backed up sshd_config to $backup"
}

set_sshd_option() {
  local key="$1"
  local value="$2"
  if grep -Eq "^[#[:space:]]*${key}[[:space:]]+" "$SSH_CONFIG_PATH"; then
    sed -i.bak -E "s|^[#[:space:]]*${key}[[:space:]]+.*|${key} ${value}|" "$SSH_CONFIG_PATH"
  else
    printf '%s %s\n' "$key" "$value" >> "$SSH_CONFIG_PATH"
  fi
  rm -f "$SSH_CONFIG_PATH.bak"
}

apply_ssh_config() {
  command_exists sshd || die "sshd binary not found after installing openssh-server"
  backup_ssh_config
  set_sshd_option Port "$SSH_PORT"
  set_sshd_option PermitRootLogin no
  set_sshd_option PubkeyAuthentication yes
  set_sshd_option PasswordAuthentication "$([[ "$DISABLE_PASSWORD_AUTH" == "yes" ]] && printf no || printf yes)"
  set_sshd_option ChallengeResponseAuthentication no
  set_sshd_option KbdInteractiveAuthentication no

  if ! prepare_sshd_runtime; then
    if [[ "$ENV_IS_CONTAINER" == "yes" ]]; then
      SSHD_VALIDATION_STATUS="skipped-runtime-dir"
      SSH_APPLY_STATUS="configured-not-validated"
      print_warn "Could not prepare /run/sshd in this container; SSH config was written but not validated"
      return 0
    fi
    die "Failed to prepare /run/sshd for SSH validation"
  fi

  if sshd -t -f "$SSH_CONFIG_PATH" >> "$LOG_FILE" 2>&1; then
    SSHD_VALIDATION_STATUS="passed"
  else
    if [[ "$ENV_IS_CONTAINER" == "yes" ]]; then
      SSHD_VALIDATION_STATUS="failed-in-container"
      SSH_APPLY_STATUS="configured-not-validated"
      print_warn "sshd validation failed in this container environment; SSH config was written but not reloaded"
      return 0
    fi
    die "sshd configuration validation failed. Check $LOG_FILE"
  fi

  if service_action reload "$SSH_SERVICE_NAME" || service_action restart "$SSH_SERVICE_NAME"; then
    SSH_APPLY_STATUS="reloaded"
    print_ok "SSH configuration applied and validated"
  else
    SSH_APPLY_STATUS="configured-not-reloaded"
    if [[ "$ENV_IS_CONTAINER" == "yes" ]]; then
      print_warn "SSH config validated, but service reload was not available in this container"
    else
      print_warn "SSH config updated but service reload was not available in this environment"
    fi
  fi
}

apply_ufw() {
  run_cmd ufw default deny incoming || die "Failed to configure UFW incoming policy"
  run_cmd ufw default allow outgoing || die "Failed to configure UFW outgoing policy"
  run_cmd ufw allow "$SSH_PORT/tcp" || die "Failed to allow SSH port in UFW"
  run_cmd ufw allow 80/tcp || die "Failed to allow HTTP in UFW"
  run_cmd ufw allow 443/tcp || die "Failed to allow HTTPS in UFW"
  if [[ -n "$UFW_EXTRA_PORTS" ]]; then
    local port
    IFS=',' read -r -a extra_ports <<< "$UFW_EXTRA_PORTS"
    for port in "${extra_ports[@]}"; do
      port="${port// /}"
      [[ -z "$port" ]] && continue
      validate_port "$port" || die "Invalid extra UFW port: $port"
      run_cmd ufw allow "$port/tcp" || die "Failed to allow UFW port $port"
    done
  fi
  printf 'y\n' | ufw enable >> "$LOG_FILE" 2>&1 || die "Failed to enable UFW"
  print_ok "UFW configured"
}

apply_fail2ban() {
  [[ "$ENABLE_FAIL2BAN" == "yes" ]] || return 0
  install_packages fail2ban || die "Failed to install fail2ban"
  cat > /etc/fail2ban/jail.d/hpsr-sshd.local <<EOF
[sshd]
enabled = true
port = $SSH_PORT
bantime = 1h
findtime = 10m
maxretry = 5
EOF
  service_action enable fail2ban || true
  if service_action restart fail2ban || service_action start fail2ban; then
    FAIL2BAN_APPLY_STATUS="enabled"
    print_ok "Fail2ban enabled for SSH"
  else
    FAIL2BAN_APPLY_STATUS="configured-not-started"
    print_warn "Fail2ban installed and configured, but could not be started in this environment"
  fi
}

apply_unattended_upgrades() {
  [[ "$ENABLE_UNATTENDED" == "yes" ]] || return 0
  install_packages unattended-upgrades apt-listchanges || die "Failed to install unattended-upgrades"
  printf 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true\n' | debconf-set-selections
  run_cmd dpkg-reconfigure -f noninteractive unattended-upgrades || die "Failed to enable unattended-upgrades"
  print_ok "Unattended upgrades enabled"
}

apply_time_sync() {
  if systemctl list-unit-files 2>/dev/null | grep -q '^systemd-timesyncd\.service'; then
    if run_cmd systemctl enable systemd-timesyncd && run_cmd systemctl restart systemd-timesyncd; then
      TIME_SYNC_STATUS="enabled"
      print_ok "Time synchronization enabled with systemd-timesyncd"
    else
      TIME_SYNC_STATUS="skipped"
      print_warn "Time synchronization could not be fully managed in this environment"
    fi
  else
    install_packages systemd-timesyncd || true
    TIME_SYNC_STATUS="skipped"
    print_warn "systemd-timesyncd is not available or not manageable in this environment"
  fi
}

apply_base_and_suggested_packages() {
  install_packages "${BASE_PACKAGES[@]}" || die "Failed to install base packages"
  print_ok "Installed base packages"
}

install_docker() {
  install_packages docker.io || die "Failed to install Docker"
  run_cmd systemctl enable docker || die "Failed to enable Docker"
  run_cmd systemctl restart docker || die "Failed to restart Docker"
  run_cmd usermod -aG docker "$ADMIN_USER" || print_warn "Could not add $ADMIN_USER to docker group"
  print_ok "Docker installed"
}

install_tailscale() {
  install_packages tailscale || die "Failed to install Tailscale"
  run_cmd systemctl enable tailscaled || die "Failed to enable tailscaled"
  run_cmd systemctl restart tailscaled || die "Failed to restart tailscaled"
  print_ok "Tailscale installed"
}

install_dokploy() {
  if command_exists curl; then
    run_cmd sh -c 'curl -fsSL https://dokploy.com/install.sh | sh' || die "Failed to install Dokploy"
    print_ok "Dokploy installation command completed"
  else
    die "curl is required to install Dokploy"
  fi
}

create_swap() {
  [[ "$OPTIONAL_SWAP" == "yes" ]] || return 0
  [[ -n "$SWAP_SIZE" ]] || die "Swap size was not provided"
  if swapon --show | grep -q '^'; then
    print_warn "Swap already exists; skipping swap creation"
    return 0
  fi
  run_cmd fallocate -l "$SWAP_SIZE" /swapfile || die "Failed to allocate swapfile"
  run_cmd chmod 600 /swapfile || die "Failed to protect swapfile"
  run_cmd mkswap /swapfile || die "Failed to format swapfile"
  run_cmd swapon /swapfile || die "Failed to enable swapfile"
  if ! grep -q '^/swapfile ' /etc/fstab; then
    printf '/swapfile none swap sw 0 0\n' >> /etc/fstab
  fi
  print_ok "Swap file created ($SWAP_SIZE)"
}

show_review() {
  section "$(msg review_section)"
  subsection "$(lang_is_en && printf 'Identity' || printf 'Identidad')"
  key_value "$(msg hostname)" "$HOSTNAME_VALUE"
  key_value "$(msg timezone)" "$TIMEZONE_VALUE"

  subsection "$(lang_is_en && printf 'Admin Access' || printf 'Acceso administrativo')"
  key_value "$(lang_is_en && printf 'User' || printf 'Usuario')" "$ADMIN_USER"
  key_value "$(lang_is_en && printf 'Password' || printf 'Contrasena')" "$(lang_is_en && printf 'configured' || printf 'configurada')"
  key_value "Sudo" "enabled"

  subsection "SSH"
  key_value "$(lang_is_en && printf 'Port' || printf 'Puerto')" "$SSH_PORT"
  key_value "$(lang_is_en && printf 'Root Login' || printf 'Login root')" "$(lang_is_en && printf 'disabled' || printf 'deshabilitado')"
  key_value "$(lang_is_en && printf 'Password SSH' || printf 'SSH por contrasena')" "$(lang_is_en && printf 'disabled' || printf 'deshabilitado')"
  key_value "$(lang_is_en && printf 'Key Mode' || printf 'Modo de llave')" "$SSH_KEY_MODE"

  subsection "Firewall"
  key_value "UFW" "enabled"
  key_value "$(lang_is_en && printf 'Allowed' || printf 'Permitidos')" "$SSH_PORT, 80, 443${UFW_EXTRA_PORTS:+, $UFW_EXTRA_PORTS}"

  subsection "$(lang_is_en && printf 'Security' || printf 'Seguridad')"
  key_value "Fail2ban" "enabled"
  key_value "$(lang_is_en && printf 'Updates' || printf 'Actualizaciones')" "$ENABLE_UNATTENDED"
  if [[ "$ENV_IS_CONTAINER" == "yes" ]]; then
    key_value "$(lang_is_en && printf 'Environment' || printf 'Entorno')" "container"
    key_value "$(lang_is_en && printf 'Note' || printf 'Nota')" "$(lang_is_en && printf 'SSH reload may be skipped in containers' || printf 'La recarga de SSH puede omitirse en contenedores')"
  fi

  subsection "Resend"
  key_value "$(lang_is_en && printf 'Enabled' || printf 'Habilitado')" "$RESEND_ENABLED"
  key_value "$(lang_is_en && printf 'Status' || printf 'Estado')" "$RESEND_TEST_STATUS"

  local apply_input
  apply_input="$(prompt "$(msg final_apply)" '')"
  apply_input="${apply_input,,}"
  [[ "$apply_input" == "apply" || "$apply_input" == "yes" || "$apply_input" == "y" || "$apply_input" == "si" || "$apply_input" == "sí" ]] || die "$(msg aborted)"
}

build_credentials_archive() {
  local staging_dir="$GENERATED_DIR/credentials-$TIMESTAMP"
  mkdir -p "$staging_dir"
  register_sensitive_path "$staging_dir"
  if [[ -n "$SSH_PRIVATE_KEY_PATH" && -f "$SSH_PRIVATE_KEY_PATH" ]]; then
    cp "$SSH_PRIVATE_KEY_PATH" "$staging_dir/"
  fi
  if [[ -n "$SSH_PUBLIC_KEY_PATH" && -f "$SSH_PUBLIC_KEY_PATH" ]]; then
    cp "$SSH_PUBLIC_KEY_PATH" "$staging_dir/"
  else
    printf '%s\n' "$SSH_PUBLIC_KEY_CONTENT" > "$staging_dir/${ADMIN_USER}.pub"
  fi
  printf 'User: %s\nSSH Port: %s\nHostname: %s\nTimezone: %s\n' "$ADMIN_USER" "$SSH_PORT" "$HOSTNAME_VALUE" "$TIMEZONE_VALUE" > "$staging_dir/README.txt"
  GENERATED_ARCHIVE_PASSWORD="$(generate_password)"
  [[ -n "$GENERATED_ARCHIVE_PASSWORD" ]] || die "Failed to generate archive password"
  GENERATED_ARCHIVE_PATH="$ARCHIVE_DIR/hpsr-credentials-$TIMESTAMP.zip"
  register_sensitive_path "$GENERATED_ARCHIVE_PATH"
  run_cmd zip -j -P "$GENERATED_ARCHIVE_PASSWORD" "$GENERATED_ARCHIVE_PATH" "$staging_dir"/* || die "Failed to create encrypted credentials archive"
}

send_resend_email() {
  local subject="$1"
  local text_body="$2"
  local html_body="${3:-}"
  local attachment_path="${4:-}"
  local payload_file="$GENERATED_DIR/resend-send-$TIMESTAMP.json"
  local response_file="$GENERATED_DIR/resend-send-response-$TIMESTAMP.json"
  local attachment_json=""
  local http_code=""
  local text_json
  local html_json
  local subject_json
  local from_json
  local to_json
  register_sensitive_path "$payload_file"
  register_sensitive_path "$response_file"
  text_json="$(json_escape "$text_body")"
  html_json="$(json_escape "$html_body")"
  subject_json="$(json_escape "$subject")"
  from_json="$(json_escape "$RESEND_FROM")"
  to_json="$(json_escape "$RESEND_TO")"
  if [[ -n "$attachment_path" ]]; then
    local base64_content
    base64_content="$(base64 < "$attachment_path" | tr -d '\n')"
    attachment_json=",\"attachments\":[{\"filename\":\"$(basename "$attachment_path")\",\"content\":\"$base64_content\"}]"
  fi
  cat > "$payload_file" <<EOF
{"from":"$from_json","to":["$to_json"],"subject":"$subject_json","text":"$text_json","html":"$html_json"$attachment_json}
EOF
  http_code="$(curl -sS -o "$response_file" -w '%{http_code}' \
    -X POST https://api.resend.com/emails \
    -H "Authorization: Bearer $RESEND_API_KEY" \
    -H 'Content-Type: application/json' \
    --data-binary "@$payload_file" 2>>"$LOG_FILE" || true)"
  if [[ "$http_code" != "200" && "$http_code" != "201" ]]; then
    print_fail "$(msg resend_failed)"
    printf 'HTTP status : %s\n' "$http_code"
    printf 'Response    : %s\n' "$(tr -d '\r' < "$response_file" 2>/dev/null || true)"
    return 1
  fi
  print_ok "$(msg email_sent)"
  return 0
}

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

report_email_text() {
  if lang_is_en; then
    cat <<EOF
hpsr.sh Server Setup Report

Hostname: $HOSTNAME_VALUE
Timezone: $TIMEZONE_VALUE
Public IP: ${PUBLIC_IP:-unknown}

Admin Access
- User: $ADMIN_USER
- Password: configured
- Sudo: enabled

SSH
- Port: $SSH_PORT
- Root login: disabled
- Password SSH: disabled
- Key mode: $SSH_KEY_MODE

Security
- UFW: enabled
- Fail2ban: enabled
- Automatic updates: $ENABLE_UNATTENDED

Files
- Report: $REPORT_FILE
- Log: $LOG_FILE

Important
- Test SSH access in a new terminal before closing the current session.
EOF
  else
    cat <<EOF
Reporte de configuracion del servidor hpsr.sh

Hostname: $HOSTNAME_VALUE
Zona horaria: $TIMEZONE_VALUE
IP publica: ${PUBLIC_IP:-unknown}

Acceso administrativo
- Usuario: $ADMIN_USER
- Contrasena: configurada
- Sudo: habilitado

SSH
- Puerto: $SSH_PORT
- Login root: deshabilitado
- SSH por contrasena: deshabilitado
- Modo de llave: $SSH_KEY_MODE

Seguridad
- UFW: habilitado
- Fail2ban: habilitado
- Actualizaciones automaticas: $ENABLE_UNATTENDED

Archivos
- Reporte: $REPORT_FILE
- Log: $LOG_FILE

Importante
- Prueba el acceso SSH en una nueva terminal antes de cerrar la sesion actual.
EOF
  fi
}

report_email_html() {
  if lang_is_en; then cat <<EOF
<html><body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0f0f12;color:#f7f4fb;padding:24px;line-height:1.5;">
<div style="max-width:720px;margin:0 auto;">
<h1 style="margin:0 0 8px;color:#f2dfff;">hpsr.sh Server Setup Report</h1>
<p style="margin:0 0 20px;color:#d8cce6;">$SCRIPT_BRAND_SECONDARY</p>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">System</h2>
<p style="margin:4px 0;"><strong>Hostname:</strong> $HOSTNAME_VALUE</p>
<p style="margin:4px 0;"><strong>Timezone:</strong> $TIMEZONE_VALUE</p>
<p style="margin:4px 0;"><strong>Public IP:</strong> ${PUBLIC_IP:-unknown}</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Admin Access</h2>
<p style="margin:4px 0;"><strong>User:</strong> $ADMIN_USER</p>
<p style="margin:4px 0;"><strong>Password:</strong> configured</p>
<p style="margin:4px 0;"><strong>Sudo:</strong> enabled</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">SSH</h2>
<p style="margin:4px 0;"><strong>Port:</strong> $SSH_PORT</p>
<p style="margin:4px 0;"><strong>Root login:</strong> disabled</p>
<p style="margin:4px 0;"><strong>Password SSH:</strong> disabled</p>
<p style="margin:4px 0;"><strong>Key mode:</strong> $SSH_KEY_MODE</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Security</h2>
<p style="margin:4px 0;"><strong>UFW:</strong> enabled</p>
<p style="margin:4px 0;"><strong>Fail2ban:</strong> enabled</p>
<p style="margin:4px 0;"><strong>Automatic updates:</strong> $ENABLE_UNATTENDED</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Files</h2>
<p style="margin:4px 0;"><strong>Report:</strong> $REPORT_FILE</p>
<p style="margin:4px 0;"><strong>Log:</strong> $LOG_FILE</p>
</div>
<p style="color:#d8cce6;"><strong>Important:</strong> Test SSH access in a new terminal before closing the current session.</p>
</div></body></html>
EOF
  else cat <<EOF
<html><body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0f0f12;color:#f7f4fb;padding:24px;line-height:1.5;">
<div style="max-width:720px;margin:0 auto;">
<h1 style="margin:0 0 8px;color:#f2dfff;">Reporte de configuracion del servidor</h1>
<p style="margin:0 0 20px;color:#d8cce6;">$SCRIPT_BRAND_SECONDARY</p>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Sistema</h2>
<p style="margin:4px 0;"><strong>Hostname:</strong> $HOSTNAME_VALUE</p>
<p style="margin:4px 0;"><strong>Zona horaria:</strong> $TIMEZONE_VALUE</p>
<p style="margin:4px 0;"><strong>IP publica:</strong> ${PUBLIC_IP:-unknown}</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Acceso administrativo</h2>
<p style="margin:4px 0;"><strong>Usuario:</strong> $ADMIN_USER</p>
<p style="margin:4px 0;"><strong>Contrasena:</strong> configurada</p>
<p style="margin:4px 0;"><strong>Sudo:</strong> habilitado</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">SSH</h2>
<p style="margin:4px 0;"><strong>Puerto:</strong> $SSH_PORT</p>
<p style="margin:4px 0;"><strong>Login root:</strong> deshabilitado</p>
<p style="margin:4px 0;"><strong>SSH por contrasena:</strong> deshabilitado</p>
<p style="margin:4px 0;"><strong>Modo de llave:</strong> $SSH_KEY_MODE</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Seguridad</h2>
<p style="margin:4px 0;"><strong>UFW:</strong> habilitado</p>
<p style="margin:4px 0;"><strong>Fail2ban:</strong> habilitado</p>
<p style="margin:4px 0;"><strong>Actualizaciones automaticas:</strong> $ENABLE_UNATTENDED</p>
</div>
<div style="background:#17171d;border:1px solid #3c3345;border-radius:14px;padding:18px 20px;margin-bottom:16px;">
<h2 style="margin:0 0 12px;color:#f2dfff;font-size:18px;">Archivos</h2>
<p style="margin:4px 0;"><strong>Reporte:</strong> $REPORT_FILE</p>
<p style="margin:4px 0;"><strong>Log:</strong> $LOG_FILE</p>
</div>
<p style="color:#d8cce6;"><strong>Importante:</strong> Prueba el acceso SSH en una nueva terminal antes de cerrar la sesion actual.</p>
</div></body></html>
EOF
  fi
}

write_report() {
  local report_private_key_path="not-generated"
  local report_public_key_path="not-generated"
  if [[ "$SSH_KEY_MODE" == "generate" ]]; then
    if [[ "$KEEP_PRIVATE_KEY_AFTER_RUN" == "yes" ]]; then
      report_private_key_path="$SSH_PRIVATE_KEY_PATH"
      report_public_key_path="$SSH_PUBLIC_KEY_PATH"
    else
      report_private_key_path="temporary-generated-and-removed"
      report_public_key_path="temporary-generated-and-removed"
    fi
  elif [[ -n "$SSH_PUBLIC_KEY_PATH" ]]; then
    report_public_key_path="$SSH_PUBLIC_KEY_PATH"
  fi
  cat > "$REPORT_FILE" <<EOF
$(lang_is_en && printf '# hpsr.sh Server Setup Report' || printf '# Reporte de configuracion del servidor hpsr.sh')

- $(lang_is_en && printf 'Version' || printf 'Version'): $SCRIPT_VERSION
- $(lang_is_en && printf 'Generated' || printf 'Generado'): $(date -Is)
- Brand: $SCRIPT_BRAND_PRIMARY
- $(lang_is_en && printf 'Attribution' || printf 'Atribucion'): $SCRIPT_BRAND_SECONDARY

## $(lang_is_en && printf 'System' || printf 'Sistema')

- Hostname: $HOSTNAME_VALUE
- $(lang_is_en && printf 'Timezone' || printf 'Zona horaria'): $TIMEZONE_VALUE
- $(lang_is_en && printf 'Distro' || printf 'Distribucion'): $OS_ID $OS_VERSION
- $(lang_is_en && printf 'Public IP' || printf 'IP publica'): ${PUBLIC_IP:-unknown}

## $(lang_is_en && printf 'Admin Access' || printf 'Acceso administrativo')

- $(lang_is_en && printf 'User' || printf 'Usuario'): $ADMIN_USER
- $(lang_is_en && printf 'Password' || printf 'Contrasena'): $(lang_is_en && printf 'configured' || printf 'configurada')
- Sudo: $(lang_is_en && printf 'enabled' || printf 'habilitado')

## SSH

- $(lang_is_en && printf 'Port' || printf 'Puerto'): $SSH_PORT
- $(lang_is_en && printf 'Root login' || printf 'Login root'): $(lang_is_en && printf 'disabled' || printf 'deshabilitado')
- $(lang_is_en && printf 'Password authentication' || printf 'Autenticacion por contrasena'): $(lang_is_en && printf 'disabled' || printf 'deshabilitada')
- $(lang_is_en && printf 'Public key mode' || printf 'Modo de llave publica'): $SSH_KEY_MODE
- $(msg managed_key_installed): $HPSR_MANAGED_KEY_INSTALLED
- $(msg managed_keys_replaced): $HPSR_MANAGED_KEY_REPLACED_COUNT
- $(msg external_keys_kept): $HPSR_EXTERNAL_KEY_COUNT
- $(msg key_fingerprint): ${SSH_KEY_FINGERPRINT:-not-available}
- $(lang_is_en && printf 'Private key path' || printf 'Ruta de la llave privada'): $report_private_key_path
- $(lang_is_en && printf 'Public key path' || printf 'Ruta de la llave publica'): $report_public_key_path

## Firewall

- UFW $(lang_is_en && printf 'enabled' || printf 'habilitado'): yes
- $(lang_is_en && printf 'Allowed ports' || printf 'Puertos permitidos'): $SSH_PORT, 80, 443${UFW_EXTRA_PORTS:+, $UFW_EXTRA_PORTS}

## $(lang_is_en && printf 'Security Services' || printf 'Servicios de seguridad')

- Fail2ban: $(lang_is_en && printf 'enabled' || printf 'habilitado')
- $(lang_is_en && printf 'Unattended upgrades' || printf 'Actualizaciones automaticas'): $ENABLE_UNATTENDED
- $(lang_is_en && printf 'Environment' || printf 'Entorno'): $ENV_IS_CONTAINER
- $(lang_is_en && printf 'Hostname apply status' || printf 'Estado de aplicacion del hostname'): $HOSTNAME_APPLY_STATUS
- $(lang_is_en && printf 'Timezone apply status' || printf 'Estado de aplicacion de la zona horaria'): $TIMEZONE_APPLY_STATUS
- $(lang_is_en && printf 'SSH service apply status' || printf 'Estado de aplicacion del servicio SSH'): $SSH_APPLY_STATUS
- $(lang_is_en && printf 'SSH validation status' || printf 'Estado de validacion SSH'): $SSHD_VALIDATION_STATUS
- $(lang_is_en && printf 'Fail2ban apply status' || printf 'Estado de aplicacion de Fail2ban'): $FAIL2BAN_APPLY_STATUS
- $(lang_is_en && printf 'Time sync status' || printf 'Estado de sincronizacion horaria'): $TIME_SYNC_STATUS

## $(lang_is_en && printf 'Packages' || printf 'Paquetes')

- $(lang_is_en && printf 'Base packages' || printf 'Paquetes base'): ${BASE_PACKAGES[*]}

## Resend

- $(lang_is_en && printf 'Enabled' || printf 'Habilitado'): $RESEND_ENABLED
- $(lang_is_en && printf 'Test status' || printf 'Estado de la prueba'): $RESEND_TEST_STATUS
- $(lang_is_en && printf 'Report sent' || printf 'Reporte enviado'): $RESEND_SENT_REPORT
- $(lang_is_en && printf 'Credentials sent' || printf 'Credenciales enviadas'): $RESEND_SENT_CREDENTIALS

## $(lang_is_en && printf 'Sensitive Artifacts' || printf 'Artefactos sensibles')

- $(lang_is_en && printf 'Private key printed in console' || printf 'Llave privada impresa en consola'): $PRINTED_PRIVATE_KEY
- $(lang_is_en && printf 'Credentials archive' || printf 'Archivo de credenciales'): ${GENERATED_ARCHIVE_PATH:-not-created}
- $(lang_is_en && printf 'Temporary sensitive files deleted' || printf 'Archivos sensibles temporales eliminados'): $DELETE_SENSITIVE_FILES

## $(lang_is_en && printf 'Files' || printf 'Archivos')

- $(msg report): $REPORT_FILE
- Log: $LOG_FILE
- $(lang_is_en && printf 'Base directory' || printf 'Directorio base'): $SCRIPT_BASE_DIR

## $(lang_is_en && printf 'Notes' || printf 'Notas')

- $(lang_is_en && printf 'Root SSH login is disabled.' || printf 'El acceso SSH de root esta deshabilitado.')
- $(lang_is_en && printf 'Test a new SSH session before closing the current one.' || printf 'Prueba una nueva sesion SSH antes de cerrar la actual.')
$REPORT_NOTE
EOF
  REPORT_WRITTEN="yes"
  print_ok "$(msg markdown_report) $REPORT_FILE"
}

post_actions() {
  section "$(msg post_actions)"
  subsection "$(msg key_replace_summary)"
  key_value "$(msg managed_keys_replaced)" "$HPSR_MANAGED_KEY_REPLACED_COUNT"
  key_value "$(msg external_keys_kept)" "$HPSR_EXTERNAL_KEY_COUNT"
  key_value "$(msg managed_key_installed)" "$HPSR_MANAGED_KEY_INSTALLED"
  if [[ -n "$SSH_KEY_FINGERPRINT" ]]; then
    key_value "$(msg key_fingerprint)" "$SSH_KEY_FINGERPRINT"
  fi

  if [[ -n "$SSH_PRIVATE_KEY_PATH" && -f "$SSH_PRIVATE_KEY_PATH" ]]; then
    subsection "$(msg private_key)"
    key_value "Path" "$SSH_PRIVATE_KEY_PATH"
    if [[ -n "$SSH_KEY_FINGERPRINT" ]]; then
      key_value "$(msg key_fingerprint)" "$SSH_KEY_FINGERPRINT"
    fi
    if confirm "$(msg print_private_key)" no; then
      PRINTED_PRIVATE_KEY="yes"
      printf '\n%b' "$COLOR_ACCENT"
      cat "$SSH_PRIVATE_KEY_PATH"
      printf '%b\n' "$ANSI_RESET"
    fi
    if confirm "$(msg confirm_private_saved)" no; then
      PRIVATE_KEY_SAVE_CONFIRMED="yes"
      print_ok "$(msg private_key_removed)"
    else
      KEEP_PRIVATE_KEY_AFTER_RUN="yes"
      unregister_sensitive_path "$SSH_PRIVATE_KEY_PATH"
      unregister_sensitive_path "$SSH_PUBLIC_KEY_PATH"
      print_warn "$(msg private_key_kept)"
    fi
  fi

  if [[ "$RESEND_ENABLED" == "yes" ]]; then
    if confirm "$(msg send_report)" yes; then
      send_resend_email "$SCRIPT_NAME - $(msg report_title) - $HOSTNAME_VALUE" "$(report_email_text)" "$(report_email_html)" || true
      RESEND_SENT_REPORT="yes"
    fi
    if confirm "$(msg send_credentials)" no; then
      build_credentials_archive
      printf '\n%s:\n%s\n' "$(msg archive_password)" "$GENERATED_ARCHIVE_PASSWORD"
      if lang_is_en; then
        send_resend_email "$SCRIPT_NAME - $(msg credentials_title) - $HOSTNAME_VALUE" "Encrypted credentials package attached. The password was only printed in the console." "<p>Encrypted credentials package attached. The password was only printed in the console.</p>" "$GENERATED_ARCHIVE_PATH" || true
      else
        send_resend_email "$SCRIPT_NAME - $(msg credentials_title) - $HOSTNAME_VALUE" "Se adjunto un paquete cifrado de credenciales. La contrasena solo se imprimio en la consola." "<p>Se adjunto un paquete cifrado de credenciales. La contrasena solo se imprimio en la consola.</p>" "$GENERATED_ARCHIVE_PATH" || true
      fi
      RESEND_SENT_CREDENTIALS="yes"
    fi
  fi

  cleanup_sensitive_artifacts
  write_report
  print_ok "$(msg sensitive_removed)"

  printf '\n%s\n\n' "$(msg setup_completed)"
  printf '%s:\n' "$(msg important)"
  printf -- '- %s\n' "$(msg test_ssh_note)"
  if [[ -n "$PUBLIC_IP" && "$SSH_KEY_MODE" == "generate" ]]; then
    if [[ "$KEEP_PRIVATE_KEY_AFTER_RUN" == "yes" ]]; then
      printf -- '- %s: %s\n' "$(msg private_key)" "$SSH_PRIVATE_KEY_PATH"
    else
      printf -- '- %s\n' "$(msg private_removed_note)"
    fi
    printf -- '- %s: %s@%s (%s %s)\n' "$(msg ssh_target)" "$ADMIN_USER" "$PUBLIC_IP" "$(lang_is_en && printf 'port' || printf 'puerto')" "$SSH_PORT"
  fi
  printf -- '- %s: %s\n' "$(msg report)" "$REPORT_FILE"
  printf -- '- %s: %s\n' "$(msg log)" "$LOG_FILE"
}

apply_all_changes() {
  section "$(msg applying)"
  apply_hostname
  apply_timezone
  ensure_user_exists
  load_public_key_content
  install_public_key_for_user
  if [[ "$DISABLE_PASSWORD_AUTH" == "yes" && -z "$SSH_PUBLIC_KEY_CONTENT" ]]; then
    die "Password authentication cannot be disabled without a valid SSH public key"
  fi
  apply_ssh_config
  apply_ufw
  apply_fail2ban
  apply_unattended_upgrades
  apply_time_sync
  apply_base_and_suggested_packages
}

main() {
  parse_args "$@"
  trap on_exit EXIT
  if [[ "$RUN_MODE" == "verify" ]]; then
    print_banner
    printf '\n'
    verify_setup
    return 0
  fi

  init_tty
  if [[ "$LANG_EXPLICIT" != "yes" ]]; then
    select_language
  fi
  print_banner
  printf '\n'
  print_bold "$(msg intro_title)"
  printf '%s\n\n' "$(msg intro_note)"
  pause
  prechecks
  apt_update_once
  ensure_installer_dependencies
  configure_resend
  configure_identity
  configure_admin_user
  collect_ssh_key_setup
  configure_ssh_hardening_inputs
  collect_firewall_inputs
  collect_fail2ban_inputs
  collect_unattended_inputs
  show_review
  apply_all_changes
  post_actions
}

main "$@"
