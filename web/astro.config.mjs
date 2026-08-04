import { defineConfig } from 'astro/config'
import sitemap from '@astrojs/sitemap'

export default defineConfig({
  site: 'https://sh.hpsr.dev',
  integrations: [sitemap()]
})
