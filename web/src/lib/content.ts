export type Language = 'es' | 'en'

type Highlight = {
  title: string
  description: string
}

type FooterLink = {
  label: string
  href: string
}

type Content = {
  meta: {
    title: string
    description: string
  }
  nav: {
    github: string
    language: string
  }
  hero: {
    eyebrow: string
    title: string
    description: string
    note: string
    primary: string
    secondary: string
    commandHint: string
  }
  highlights: {
    title: string
    items: Highlight[]
  }
  overview: {
    items: Highlight[]
  }
  terminal: {
    title: string
    description: string
    badge: string
  }
  footer: {
    tagline: string
    links: FooterLink[]
  }
  actions: {
    copy: string
    copied: string
  }
}

export const installCommand = 'curl -fsSL https://hpsr.sh/setup.sh | bash'

export const content: Record<Language, Content> = {
  es: {
    meta: {
      title: 'hpsr.sh | Setup inicial y hardening para Debian y Ubuntu',
      description:
        'Setup inicial y hardening para VPS Debian y Ubuntu con SSH, UFW, Fail2ban, actualizaciones automáticas, reportes y una base más segura desde el minuto uno.'
    },
    nav: {
      github: 'GitHub',
      language: 'Idioma'
    },
    hero: {
      eyebrow: 'Bootstrap inicial para servidores Debian y Ubuntu',
      title: 'La forma simple de preparar un servidor nuevo.',
      description:
        'hpsr.sh te guía por el setup inicial de un VPS con una interfaz simple en Bash y una base técnica razonable desde el minuto uno.',
      note:
        'No reemplaza Ansible, Terraform ni un benchmark CIS. Sirve cuando solo quieres una base mejor que el setup improvisado de siempre.',
      primary: 'Ver en GitHub',
      secondary: 'Descargar script',
      commandHint: 'Pégalo en tu terminal para iniciar la instalación.'
    },
    highlights: {
      title: 'Hecho para resolver el setup inicial sin convertirlo en un ritual innecesario',
      items: [
        {
          title: 'Rápido de ejecutar',
          description: 'Te guía por el setup inicial sin convertir el proceso en una cadena larga de pasos manuales.'
        },
        {
          title: 'Práctico de entender',
          description: 'El flujo es interactivo, legible y lo bastante claro para gente que está empezando y para quien solo quiere resolverlo rápido.'
        },
        {
          title: 'Mejor que un setup improvisado',
          description: 'Ajusta acceso SSH, firewall, Fail2ban y actualizaciones automáticas con una base más ordenada que hacerlo a mano y deprisa.'
        }
      ]
    },
    overview: {
      items: [
        {
          title: 'Acceso administrativo más seguro',
          description: 'Crea un usuario administrativo, configura sudo y prepara el acceso SSH con permisos correctos.'
        },
        {
          title: 'Hardening SSH básico y razonable',
          description: 'Deshabilita root por SSH, fuerza autenticación por llave y valida la configuración antes de recargar cuando el entorno lo permite.'
        },
        {
          title: 'Firewall, Fail2ban y updates automáticos',
          description: 'Activa UFW, añade protección base para SSH y habilita unattended-upgrades para una primera capa de mantenimiento.'
        },
        {
          title: 'Trazabilidad del cambio',
          description: 'Genera logs, backups y reportes para revisar qué cambió y qué quedó aplicado.'
        }
      ]
    },
    terminal: {
      title: 'Vista previa del flujo',
      description: 'Una simulación breve del tipo de salida que verás durante la ejecución del asistente.',
      badge: 'Simulación'
    },
    footer: {
      tagline: 'hpsr.sh es un script Bash open source para bootstrap y hardening inicial de servidores Debian y Ubuntu.',
      links: [
        { label: 'GitHub', href: 'https://github.com/hopsersmerk/hpsr.sh' },
        { label: 'Blog', href: 'https://hopsersmerk.com' },
        { label: 'Servicios freelance', href: 'https://hpsr.mx' }
      ]
    },
    actions: {
      copy: 'Copiar',
      copied: 'Copiado'
    }
  },
  en: {
    meta: {
      title: 'hpsr.sh | Initial setup and hardening for Debian and Ubuntu',
      description:
        'Initial VPS setup and hardening for Debian and Ubuntu with SSH, UFW, Fail2ban, automatic security updates, logs, reports, and a cleaner baseline from day one.'
    },
    nav: {
      github: 'GitHub',
      language: 'Language'
    },
    hero: {
      eyebrow: 'Initial bootstrap for Debian and Ubuntu servers',
      title: 'The simple way to prepare a fresh server.',
      description:
        'hpsr.sh walks you through the initial VPS setup with a simple Bash interface and a sane technical baseline from minute one.',
      note:
        'It does not replace Ansible, Terraform, or a full CIS benchmark. It helps when you just want something better than the usual improvised setup.',
      primary: 'View on GitHub',
      secondary: 'Download script',
      commandHint: 'Paste it into your terminal to start the installation.'
    },
    highlights: {
      title: 'Built to handle the initial setup without turning it into an unnecessary ritual',
      items: [
        {
          title: 'Fast to run',
          description: 'It guides the initial setup without turning the process into a long chain of manual steps.'
        },
        {
          title: 'Practical to understand',
          description: 'The flow is interactive, readable, and clear enough for newcomers and for people who simply want to get it done quickly.'
        },
        {
          title: 'Better than an improvised setup',
          description: 'It covers SSH access, firewall, Fail2ban, and automatic updates with a more consistent baseline than doing it by hand in a rush.'
        }
      ]
    },
    overview: {
      items: [
        {
          title: 'Safer administrative access',
          description: 'Creates an admin user, configures sudo, and prepares SSH access with the right permissions.'
        },
        {
          title: 'Reasonable SSH hardening',
          description: 'Disables SSH root login, enforces key-based auth, and validates the configuration before reloading when the environment allows it.'
        },
        {
          title: 'Firewall, Fail2ban, and automatic updates',
          description: 'Enables UFW, applies baseline SSH protection, and turns on unattended-upgrades for a first maintenance layer.'
        },
        {
          title: 'Traceable changes',
          description: 'Generates logs, backups, and reports so you can review what changed and what was applied.'
        }
      ]
    },
    terminal: {
      title: 'Preview the flow',
      description: 'A short simulation of the kind of output you will see while running the assistant.',
      badge: 'Simulation'
    },
    footer: {
      tagline: 'hpsr.sh is an open source Bash script for initial bootstrap and hardening on Debian and Ubuntu servers.',
      links: [
        { label: 'GitHub', href: 'https://github.com/hopsersmerk/hpsr.sh' },
        { label: 'Blog', href: 'https://hopsersmerk.com' },
        { label: 'Freelance services', href: 'https://hpsr.mx' }
      ]
    },
    actions: {
      copy: 'Copy',
      copied: 'Copied'
    }
  }
}
