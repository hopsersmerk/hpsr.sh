export type Language = 'es' | 'en'

export type Highlight = {
  title: string
  description: string
}

export type SecurityLayer = {
  id: string
  tag: string
  title: string
  description: string
  impact: string
}

export type ComparisonRow = {
  feature: string
  manual: string
  hpsr: string
  ansible: string
}

export type VerificationCommand = {
  title: string
  cmd: string
  desc: string
}

export type FaqItem = {
  q: string
  a: string
}

export type FooterLink = {
  label: string
  href: string
}

export type StatItem = {
  value: string
  label: string
}

export type Content = {
  meta: {
    title: string
    description: string
    keywords: string
  }
  nav: {
    blueprint: string
    comparison: string
    terminal: string
    verification: string
    faq: string
    github: string
    language: string
    otherLangLabel: string
    otherLangUrl: string
    copyCommand: string
  }
  hero: {
    eyebrow: string
    title: string
    titleAccent: string
    description: string
    note: string
    primaryCta: string
    secondaryCta: string
    stats: StatItem[]
    platformsTitle: string
    platforms: string[]
    commandHint: string
  }
  blueprint: {
    badge: string
    title: string
    description: string
    layers: SecurityLayer[]
  }
  comparison: {
    badge: string
    title: string
    description: string
    headers: [string, string, string, string]
    rows: ComparisonRow[]
  }
  terminal: {
    badge: string
    title: string
    description: string
    replay: string
    copied: string
    copyOutput: string
  }
  verification: {
    badge: string
    title: string
    description: string
    items: VerificationCommand[]
  }
  faq: {
    badge: string
    title: string
    description: string
    items: FaqItem[]
  }
  ctaBanner: {
    title: string
    description: string
    primaryCta: string
    githubCta: string
  }
  footer: {
    tagline: string
    copyright: string
    authorText: string
    status: string
    links: FooterLink[]
  }
  actions: {
    copy: string
    copied: string
  }
}

export const installCommands = {
  curl: 'curl -fsSL https://sh.hpsr.dev/setup.sh | bash',
  wget: 'wget -qO- https://sh.hpsr.dev/setup.sh | bash',
  git: 'git clone https://github.com/hopsersmerk/hpsr.sh.git && cd hpsr.sh && sudo ./setup.sh',
  inspect: 'curl -fsSL https://sh.hpsr.dev/setup.sh | less'
}

export const installCommand = installCommands.curl

export const content: Record<Language, Content> = {
  es: {
    meta: {
      title: 'hpsr.sh — De VPS en blanco a servidor blindado en 60 segundos',
      description:
        'Script Bash interactivo para bootstrap y hardening inicial de servidores Debian y Ubuntu. Configura acceso SSH sin root, firewall UFW estricto, Fail2ban, unattended-upgrades y reportes cifrados con 0 dependencias externas.',
      keywords:
        'hardening debian, hardening ubuntu, setup vps linux, script bash vps, fail2ban debian, ufw firewall, asegurar servidor linux, ssh hardening script'
    },
    nav: {
      blueprint: 'Blueprint',
      comparison: 'Comparativa',
      terminal: 'Terminal',
      verification: 'Verificación',
      faq: 'FAQ',
      github: 'GitHub',
      language: 'Idioma',
      otherLangLabel: 'EN',
      otherLangUrl: '/en',
      copyCommand: 'Copiar script'
    },
    hero: {
      eyebrow: 'v0.2.0 • Script Bash Open Source para Debian & Ubuntu',
      title: 'De VPS en blanco a servidor blindado',
      titleAccent: 'en 60 segundos.',
      description:
        'hpsr.sh es el asistente interactivo en Bash que aplica un bootstrap técnico sólido en servidores recién creados: usuario administrativo no-root, SSH por llave criptográfica, firewall UFW default-deny, Fail2ban y parches automáticos sin la fricción pesada de Ansible ni los descuidos del setup manual.',
      note: '0 dependencias fuera de Bash estándar. No se aplican cambios hasta tu confirmación explícita.',
      primaryCta: 'Copiar comando',
      secondaryCta: 'Ver en GitHub',
      stats: [
        { value: '< 60s', label: 'Puesta a punto guiada' },
        { value: '0 deps', label: 'Solo Bash nativo y apt' },
        { value: '6 capas', label: 'Hardening automatizado' },
        { value: '100% Audit', label: 'Logs, backups y reporte' }
      ],
      platformsTitle: 'Listo para proveedores cloud y hardware bare-metal:',
      platforms: [
        'Debian 11 & 12',
        'Ubuntu 20, 22 & 24 LTS',
        'DigitalOcean',
        'Hetzner Cloud',
        'AWS EC2',
        'Vultr',
        'Linode / Akamai',
        'Proxmox VE'
      ],
      commandHint: 'Pega este comando en tu terminal como root para iniciar el asistente interactivo:'
    },
    blueprint: {
      badge: 'HARDENING BLUEPRINT',
      title: 'Las 6 capas de seguridad que hpsr.sh aplica en tu máquina',
      description:
        'Cada decisión está calculada para neutralizar los vectores de ataque más comunes en servidores expuestos a Internet sin romper la ergonomía de desarrollo.',
      layers: [
        {
          id: 'admin',
          tag: 'CAPA 01 · IDENTIDAD',
          title: 'Usuario administrativo & sudo aislado',
          description:
            'Crea un nuevo usuario administrativo dedicado con shell limpia, membresía en sudoers y directorio ~/.ssh configurado con permisos estrictos (700 en carpeta, 600 en llaves).',
          impact: 'Elimina el uso diario de root y establece un principio de mínimo privilegio desde el minuto cero.'
        },
        {
          id: 'ssh',
          tag: 'CAPA 02 · ACCESO',
          title: 'Hardening SSH asimétrico & puerto custom',
          description:
            'Deshabilita PermitRootLogin y PasswordAuthentication. Instala llaves Ed25519 con comentarios administrados por hpsr.sh, valida sshd_config con sshd -t antes de recargar y mueve el puerto estándar a 666 (o el que tú elijas).',
          impact: 'Elimina el 99% del ruido generado por escáneres masivos al puerto 22 y bloquea ataques de contraseña.'
        },
        {
          id: 'ufw',
          tag: 'CAPA 03 · RED',
          title: 'Firewall UFW con política Default Deny',
          description:
            'Activa el firewall del kernel con política default deny incoming y allow outgoing. Abre de forma estricta únicamente tu nuevo puerto SSH y los puertos web estándar (80/tcp y 443/tcp), permitiendo añadir puertos adicionales en el asistente.',
          impact: 'Cierra cualquier puerto residual o servicio interno que pudiera quedar expuesto a la red pública.'
        },
        {
          id: 'fail2ban',
          tag: 'CAPA 04 · DEFENSA',
          title: 'Fail2ban Anti-Fuerza Bruta para SSH',
          description:
            'Instala y aprovisiona Fail2ban con una cárcel SSH ajustada a parámetros pragmáticos: 1 hora de ban tras 5 intentos fallidos dentro de una ventana de 10 minutos (findtime: 10m, bantime: 1h, maxretry: 5).',
          impact: 'Neutraliza ataques de diccionario continuos y bots que intenten adivinar llaves o nombres de usuario.'
        },
        {
          id: 'updates',
          tag: 'CAPA 05 · MANTENIMIENTO',
          title: 'Parches automáticos con Unattended-Upgrades',
          description:
            'Configura unattended-upgrades para que Debian o Ubuntu descargue e instale parches de seguridad críticos del kernel y librerías base de forma desatendida y segura sin reinicios destructivos.',
          impact: 'Protección continua frente a CVEs de día cero sin requerir que entres por SSH a correr apt upgrade a diario.'
        },
        {
          id: 'audit',
          tag: 'CAPA 06 · AUDITORÍA',
          title: 'Trazabilidad total, backup de sshd y reporte Resend',
          description:
            'Genera backup timestamped de sshd_config antes de editarlo, un log detallado de cada comando ejecutado, un reporte final en Markdown, paquete cifrado de credenciales y envío opcional por correo vía Resend.',
          impact: 'Sabes con exactitud quirúrgica qué cambió, tienes backup para rollback y conservas tus credenciales a salvo.'
        }
      ]
    },
    comparison: {
      badge: 'TABLA COMPARATIVA',
      title: '¿Por qué hpsr.sh frente a otras alternativas?',
      description:
        'Ni la fragilidad del trabajo manual a ciegas, ni el sobrecoste operacional de orquestadores corporativos para servidores individuales.',
      headers: ['Criterio', 'Setup manual a mano', 'hpsr.sh', 'Ansible / CIS Benchmark'],
      rows: [
        {
          feature: 'Tiempo promedio de setup',
          manual: '30 a 60 minutos',
          hpsr: '< 60 segundos',
          ansible: '2 a 4 horas (crear/ajustar playbooks)'
        },
        {
          feature: 'Dependencias requeridas',
          manual: 'Ninguna (comandos sueltos)',
          hpsr: '0 dependencias (Solo Bash nativo y apt)',
          ansible: 'Python, Ansible, nodo de control, SSH Agent'
        },
        {
          feature: 'Curva de aprendizaje',
          manual: 'Media (recordar flags y sintaxis)',
          hpsr: 'Cero (asistente interactivo guiado)',
          ansible: 'Alta (YAML, roles, inventarios, vault)'
        },
        {
          feature: 'Prevención de bloqueo SSH',
          manual: 'Nula (fácil cometer typo y perder acceso)',
          hpsr: 'Validación sintáctica previa con sshd -t',
          ansible: 'Requiere pruebas en staging previo'
        },
        {
          feature: 'Firewall + Fail2ban integrados',
          manual: 'Paso manual frecuentemente olvidado',
          hpsr: 'Configurados y activos de serie',
          ansible: 'Requiere escribir tareas y handlers'
        },
        {
          feature: 'Backups y auditoría de cambios',
          manual: 'Inexistente en la mayoría de casos',
          hpsr: 'Backup de sshd_config + log + reporte MD',
          ansible: 'Depende de la calidad del playbook'
        }
      ]
    },
    terminal: {
      badge: 'SIMULACIÓN INTERACTIVA',
      title: 'Un flujo en consola claro, interactivo y predecible',
      description:
        'Sin magia negra ni archivos ocultos. hpsr.sh te muestra un snapshot del sistema, te permite seleccionar tus opciones paso a paso y te pide confirmación explícita antes de ejecutar ningún cambio.',
      replay: 'Reiniciar simulación',
      copied: 'Copiado al portapapeles',
      copyOutput: 'Copiar comando'
    },
    verification: {
      badge: 'POST-SETUP CHEATSHEET',
      title: 'Comandos para auditar tu servidor recién blindado',
      description:
        'Una vez completada la ejecución, puedes verificar en 10 segundos el estado del firewall, las cárceles de Fail2ban y tu nueva sesión SSH:',
      items: [
        {
          title: '1. Verificar estado y reglas del firewall UFW',
          cmd: 'sudo ufw status verbose',
          desc: 'Comprueba que el estado sea "active", default deny incoming y solo los puertos autorizados (SSH custom, 80, 443).'
        },
        {
          title: '2. Verificar la cárcel activa de Fail2ban en SSH',
          cmd: 'sudo fail2ban-client status sshd',
          desc: 'Revisa cuántas IPs han sido bloqueadas y el estado del filtro en tiempo real.'
        },
        {
          title: '3. Probar conexión en una nueva terminal antes de salir',
          cmd: 'ssh -p 666 -i ~/.ssh/tu_llave adminops@TU_IP',
          desc: 'Verifica el acceso con tu nuevo usuario y puerto antes de cerrar la sesión original de root.'
        },
        {
          title: '4. Comprobar servicio de parches automáticos',
          cmd: 'sudo systemctl status unattended-upgrades',
          desc: 'Confirma que el servicio de seguridad desatendida esté corriendo activamente en segundo plano.'
        }
      ]
    },
    faq: {
      badge: 'PREGUNTAS FRECUENTES',
      title: 'Todo lo que necesitas saber antes de ejecutarlo',
      description:
        'Respuestas técnicas y transparentes a las dudas más comunes sobre el funcionamiento interno de hpsr.sh.',
      items: [
        {
          q: '¿Qué pasa si cometo un error y pierdo acceso al servidor?',
          a: 'hpsr.sh valida la sintaxis completa de la configuración de OpenSSH con el comando `sshd -t` antes de reiniciar o recargar cualquier servicio. Además, el script insiste en que abras una nueva pestaña de terminal para probar la conexión con tu nuevo usuario y llave antes de cerrar la sesión root activa. Si algo no conecta, tu sesión actual sigue abierta.'
        },
        {
          q: '¿Por qué sugiere cambiar el puerto SSH al 666 por defecto?',
          a: 'Cambiar el puerto estándar no es una medida criptográfica, pero es una excelente técnica de reducción de ruido: elimina más del 98% de los escaneos automatizados y bots que bombardean el puerto 22 continuamente en Internet. Si prefieres otro puerto o mantener el 22, el asistente te permite escribir cualquier valor que desees.'
        },
        {
          q: '¿Funciona en servidores que ya tienen Docker o aplicaciones corriendo?',
          a: 'hpsr.sh está pensado y optimizado principalmente para servidores nuevos o recién restaurados (entornos Greenfield). Si ya tienes Docker instalado, UFW puede interferir con las cadenas de iptables que Docker manipula automáticamente. Recomendamos ejecutar hpsr.sh como primer paso en un servidor limpio antes de desplegar tus contenedores.'
        },
        {
          q: '¿Dónde se guardan las llaves SSH y cómo se transfieren?',
          a: 'Si eliges que hpsr.sh genere un par de llaves Ed25519 en el servidor, la llave pública se agrega a authorized_keys dentro de un bloque claramente administrado por el script. La llave privada se imprime en consola con aviso de confirmación y puede empaquetarse en un zip encriptado o enviarse a tu correo con Resend. Los temporales sensibles se eliminan al finalizar.'
        },
        {
          q: '¿Requiere conexión permanente o instalar agentes en segundo plano?',
          a: 'No. hpsr.sh no instala demonios propietarios, agentes de telemetría ni software de terceros. Solo instala paquetes oficiales de los repositorios de Debian/Ubuntu mediante apt (ufw, fail2ban, unattended-upgrades, curl, zip). Una vez terminado, el script no queda corriendo en memoria.'
        },
        {
          q: '¿Cómo puedo inspeccionar el código antes de ejecutarlo?',
          a: 'El código de hpsr.sh es 100% abierto, transparente y auditable. Puedes ver el archivo completo ejecutando `curl -fsSL https://sh.hpsr.dev/setup.sh | less` o revisando el repositorio en GitHub en https://github.com/hopsersmerk/hpsr.sh.'
        }
      ]
    },
    ctaBanner: {
      title: 'Deja de improvisar el setup de tus servidores.',
      description:
        'Un solo comando te separa de un servidor Debian o Ubuntu con acceso seguro, firewall activo y parches automáticos desde el minuto uno.',
      primaryCta: 'Copiar comando de instalación',
      githubCta: 'Explorar repositorio en GitHub'
    },
    footer: {
      tagline:
        'hpsr.sh es un script Bash open source para bootstrap y hardening inicial de servidores Debian y Ubuntu.',
      copyright: '© 2026 hpsr.sh • Licencia MIT',
      authorText: 'Desarrollado con criterio técnico por',
      status: 'Sistemas operativos: 100% Open Source',
      links: [
        { label: 'GitHub', href: 'https://github.com/hopsersmerk/hpsr.sh' },
        { label: 'Blog', href: 'https://hopsersmerk.com' },
        { label: 'Servicios freelance', href: 'https://hpsr.mx' },
        { label: 'Licencia MIT', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/LICENSE' },
        { label: 'Seguridad', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/SECURITY.md' },
        { label: 'Changelog', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/CHANGELOG.md' }
      ]
    },
    actions: {
      copy: 'Copiar',
      copied: '¡Copiado!'
    }
  },
  en: {
    meta: {
      title: 'hpsr.sh — From fresh VPS to hardened server in 60 seconds',
      description:
        'Interactive Bash script for initial bootstrap and hardening of Debian and Ubuntu servers. Configures non-root SSH access, strict UFW firewall, Fail2ban, unattended-upgrades, and encrypted audit reports with zero external dependencies.',
      keywords:
        'debian hardening, ubuntu hardening, linux vps setup, bash vps script, fail2ban debian, ufw firewall, secure linux server, ssh hardening script'
    },
    nav: {
      blueprint: 'Blueprint',
      comparison: 'Comparison',
      terminal: 'Terminal',
      verification: 'Verification',
      faq: 'FAQ',
      github: 'GitHub',
      language: 'Language',
      otherLangLabel: 'ES',
      otherLangUrl: '/',
      copyCommand: 'Copy script'
    },
    hero: {
      eyebrow: 'v0.2.0 • Open Source Bash Script for Debian & Ubuntu',
      title: 'From fresh VPS to hardened server',
      titleAccent: 'in 60 seconds.',
      description:
        'hpsr.sh is the interactive Bash assistant that applies a rock-solid technical baseline on brand-new servers: non-root admin user, cryptographic SSH keys, default-deny UFW firewall, Fail2ban, and automatic security patches without Ansible bloat or manual oversights.',
      note: '0 dependencies outside standard Bash. No changes are applied until your explicit confirmation.',
      primaryCta: 'Copy command',
      secondaryCta: 'View on GitHub',
      stats: [
        { value: '< 60s', label: 'Guided setup time' },
        { value: '0 deps', label: 'Native Bash and apt only' },
        { value: '6 layers', label: 'Automated hardening' },
        { value: '100% Audit', label: 'Logs, backups & report' }
      ],
      platformsTitle: 'Battle-tested on cloud providers and bare-metal hardware:',
      platforms: [
        'Debian 11 & 12',
        'Ubuntu 20, 22 & 24 LTS',
        'DigitalOcean',
        'Hetzner Cloud',
        'AWS EC2',
        'Vultr',
        'Linode / Akamai',
        'Proxmox VE'
      ],
      commandHint: 'Paste this command into your terminal as root to launch the interactive wizard:'
    },
    blueprint: {
      badge: 'HARDENING BLUEPRINT',
      title: 'The 6 security layers hpsr.sh applies to your machine',
      description:
        'Every technical decision is calculated to eliminate common attack vectors on internet-facing servers without hurting developer ergonomics.',
      layers: [
        {
          id: 'admin',
          tag: 'LAYER 01 · IDENTITY',
          title: 'Isolated admin user & clean sudo',
          description:
            'Provisions a dedicated administrative user with clean sudoers membership and ~/.ssh directory restricted to strict permissions (700 for directories, 600 for authorized keys).',
          impact: 'Stops day-to-day root usage and enforces the principle of least privilege from minute zero.'
        },
        {
          id: 'ssh',
          tag: 'LAYER 02 · ACCESS',
          title: 'Asymmetric SSH hardening & custom port',
          description:
            'Disables PermitRootLogin and PasswordAuthentication. Installs managed Ed25519 key pairs, validates sshd_config with sshd -t before reloading, and moves the listening port to 666 (or your custom choice).',
          impact: 'Cuts out 99% of botnet scanner noise on port 22 and renders password brute-forcing obsolete.'
        },
        {
          id: 'ufw',
          tag: 'LAYER 03 · NETWORK',
          title: 'UFW Firewall with Default-Deny Policy',
          description:
            'Enables kernel firewalling with default deny incoming and allow outgoing. Strictly allows only your configured SSH port and essential web traffic (80/tcp and 443/tcp), with prompts for custom extra ports.',
          impact: 'Locks down any stray or internal services from unwanted public network exposure.'
        },
        {
          id: 'fail2ban',
          tag: 'LAYER 04 · DEFENSE',
          title: 'Fail2ban Anti-Bruteforce for SSH',
          description:
            'Installs and provisions Fail2ban with a sane SSH jail: 1-hour ban after 5 failed authentication attempts inside a 10-minute window (findtime: 10m, bantime: 1h, maxretry: 5).',
          impact: 'Mitigates aggressive dictionary attacks and automated bot sweeps.'
        },
        {
          id: 'updates',
          tag: 'LAYER 05 · MAINTENANCE',
          title: 'Automatic Security Patches (Unattended)',
          description:
            'Configures unattended-upgrades so Debian or Ubuntu silently fetches and applies critical security patches for kernel and core packages in the background without destructive restarts.',
          impact: 'Continuous protection against zero-day CVEs without requiring manual daily apt runs.'
        },
        {
          id: 'audit',
          tag: 'LAYER 06 · AUDITABILITY',
          title: 'Full traceability, sshd backup & Resend report',
          description:
            'Generates a timestamped backup of sshd_config prior to edits, logs every executed command, compiles a detailed Markdown report, encrypts key bundles, and optionally delivers alerts via Resend.',
          impact: 'Provides complete visibility over changes, safe rollback capabilities, and secure key backups.'
        }
      ]
    },
    comparison: {
      badge: 'COMPARISON MATRIX',
      title: 'Why hpsr.sh compared to alternatives?',
      description:
        'Neither the fragility of improvised manual setups nor the heavy operational overhead of enterprise orchestrators for single servers.',
      headers: ['Criteria', 'Manual setup by hand', 'hpsr.sh', 'Ansible / CIS Benchmark'],
      rows: [
        {
          feature: 'Average setup time',
          manual: '30 to 60 minutes',
          hpsr: '< 60 seconds',
          ansible: '2 to 4 hours (crafting playbooks)'
        },
        {
          feature: 'Required dependencies',
          manual: 'None (ad-hoc commands)',
          hpsr: '0 dependencies (Standard Bash & apt)',
          ansible: 'Python, Ansible, control node, SSH agent'
        },
        {
          feature: 'Learning curve',
          manual: 'Medium (remembering flags & syntax)',
          hpsr: 'Zero (guided interactive wizard)',
          ansible: 'High (YAML, roles, inventories, vault)'
        },
        {
          feature: 'SSH lockout protection',
          manual: 'None (easy to break sshd syntax)',
          hpsr: 'Protected (syntax checked with sshd -t)',
          ansible: 'Requires extensive staging tests'
        },
        {
          feature: 'Firewall + Fail2ban included',
          manual: 'Manual step frequently forgotten',
          hpsr: 'Configured and active out of the box',
          ansible: 'Requires dedicated roles and tasks'
        },
        {
          feature: 'Backups & change logs',
          manual: 'Rarely documented',
          hpsr: 'Automatic sshd backup + log + MD report',
          ansible: 'Depends on custom playbook design'
        }
      ]
    },
    terminal: {
      badge: 'LIVE SIMULATION',
      title: 'A clean, interactive, and predictable console flow',
      description:
        'No hidden black magic. hpsr.sh presents a system snapshot, allows step-by-step configuration, and requires your explicit confirmation before applying a single change.',
      replay: 'Replay simulation',
      copied: 'Copied to clipboard',
      copyOutput: 'Copy command'
    },
    verification: {
      badge: 'POST-SETUP CHEATSHEET',
      title: 'Commands to verify your newly hardened server',
      description:
        'Once execution finishes, verify the firewall state, Fail2ban jails, and your new SSH connection in just 10 seconds:',
      items: [
        {
          title: '1. Verify UFW firewall status & rules',
          cmd: 'sudo ufw status verbose',
          desc: 'Ensures the firewall is "active", defaults to deny incoming, and only exposes authorized ports.'
        },
        {
          title: '2. Check active Fail2ban SSH jail',
          cmd: 'sudo fail2ban-client status sshd',
          desc: 'Displays currently banned IPs and active jail filters in real-time.'
        },
        {
          title: '3. Test SSH connection in a new terminal',
          cmd: 'ssh -p 666 -i ~/.ssh/your_key adminops@YOUR_IP',
          desc: 'Verify connectivity with your new user and port before exiting the active root session.'
        },
        {
          title: '4. Check unattended security upgrades service',
          cmd: 'sudo systemctl status unattended-upgrades',
          desc: 'Confirms background automatic patching is active and healthy.'
        }
      ]
    },
    faq: {
      badge: 'FREQUENTLY ASKED QUESTIONS',
      title: 'Everything you need to know before running it',
      description:
        'Transparent technical answers to the most common questions regarding hpsr.sh internals.',
      items: [
        {
          q: 'What happens if I make a mistake and get locked out of my server?',
          a: 'hpsr.sh rigorously validates the syntax of your OpenSSH configuration using `sshd -t` before restarting or reloading any daemon. Additionally, the wizard explicitly asks you to open a separate terminal window and test logging in with your new user and key before closing your root session. If anything fails, your current session stays intact.'
        },
        {
          q: 'Why does it suggest changing the SSH port to 666 by default?',
          a: 'Moving SSH off port 22 is not encryption, but it is outstanding noise reduction: it cuts out over 98% of automated port scanners and brute-force bots on the public internet. If you prefer another port or want to keep port 22, the wizard allows you to input any port number.'
        },
        {
          q: 'Does it work on servers already running Docker or web applications?',
          a: 'hpsr.sh is specifically designed and optimized for fresh or newly restored VPS servers (Greenfield environments). If Docker is already installed, UFW rules can interfere with iptables chains managed by Docker. We strongly recommend running hpsr.sh as step one on a clean machine before installing Docker or production stacks.'
        },
        {
          q: 'Where are SSH keys stored and how are they transferred?',
          a: 'If you opt to have hpsr.sh generate an Ed25519 key pair, the public key is appended to authorized_keys inside a clearly marked managed block. The private key is output to the console and can be bundled into a password-encrypted zip or dispatched via Resend email. Sensitive temporary files are scrubbed right after.'
        },
        {
          q: 'Does it require a permanent connection or background agents?',
          a: 'No. hpsr.sh installs zero proprietary daemons, telemetry agents, or background processes. It only installs standard packages from official Debian/Ubuntu repositories via apt (ufw, fail2ban, unattended-upgrades, curl, zip). Once finished, nothing remains running in memory.'
        },
        {
          q: 'How can I inspect the code before running it?',
          a: 'The source code of hpsr.sh is 100% open, readable, and auditable. You can inspect it directly in your terminal using `curl -fsSL https://sh.hpsr.dev/setup.sh | less` or by checking the GitHub repository at https://github.com/hopsersmerk/hpsr.sh.'
        }
      ]
    },
    ctaBanner: {
      title: 'Stop improvising your server setup.',
      description:
        'One single command separates you from a hardened Debian or Ubuntu server with secure SSH, active firewall, and automated security patches from minute one.',
      primaryCta: 'Copy install command',
      githubCta: 'Explore GitHub repository'
    },
    footer: {
      tagline:
        'hpsr.sh is an open-source Bash script for initial bootstrap and hardening on Debian and Ubuntu servers.',
      copyright: '© 2026 hpsr.sh • MIT License',
      authorText: 'Engineered with technical rigor by',
      status: 'Systems operational: 100% Open Source',
      links: [
        { label: 'GitHub', href: 'https://github.com/hopsersmerk/hpsr.sh' },
        { label: 'Blog', href: 'https://hopsersmerk.com' },
        { label: 'Freelance services', href: 'https://hpsr.mx' },
        { label: 'MIT License', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/LICENSE' },
        { label: 'Security policy', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/SECURITY.md' },
        { label: 'Changelog', href: 'https://github.com/hopsersmerk/hpsr.sh/blob/main/CHANGELOG.md' }
      ]
    },
    actions: {
      copy: 'Copy',
      copied: 'Copied!'
    }
  }
}
