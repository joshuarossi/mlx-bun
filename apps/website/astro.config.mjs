import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://mlx-bun.dev',
  // Keep inbound links useful without copying obsolete reference prose. These
  // destinations explain the present scope until their generated guides land.
  redirects: {
    '/guides/embedding/': '/guides/library/',
    '/guides/model-management/': '/reference/cli/',
    '/guides/fine-tuning-quickstart/': '/reference/cli/#train',
    '/guides/distribution/': '/getting-started/installation/',
    '/guides/troubleshooting/': '/getting-started/installation/',
    '/guides/memory/': '/getting-started/quickstart/',
    '/reference/training/': '/reference/cli/#train',
    '/reference/models/': '/getting-started/quickstart/',
    '/reference/benchmarks/': '/about/correctness/',
    '/reference/glossary/': '/about/correctness/',
    '/about/why/': '/getting-started/introduction/',
    '/about/comparison/': '/about/correctness/',
    '/about/benchmarks/': '/about/correctness/',
    '/about/lab/': '/about/correctness/',
  },
  integrations: [starlight({
    title: 'mlx-bun',
    description: 'Local AI on Apple Silicon: an MLX inference engine, an OpenAI, Anthropic and Responses compatible server, a browser app, and TypeScript libraries for Bun.',
    logo: { src: './src/assets/mark.svg', alt: '' },
    social: [
      { icon: 'github', label: 'GitHub', href: 'https://github.com/joshuarossi/mlx-bun' },
      { icon: 'npm', label: 'npm', href: 'https://www.npmjs.com/package/mlx-bun' },
    ],
    head: [{ tag: 'meta', attrs: { name: 'theme-color', content: '#0a0a0c' } }],
    // The site's one typeface, self-hosted, with its optical-size axis.
    customCss: ['@fontsource-variable/bricolage-grotesque/opsz.css', './src/styles/custom.css'],
    // The landing page's hero and the project footer; Starlight owns the rest.
    components: { Hero: './src/components/Hero.astro', Footer: './src/components/Footer.astro' },
    expressiveCode: {
      styleOverrides: {
        borderRadius: '0.375rem',
        codeFontSize: '0.84rem',
        codeLineHeight: '1.65',
        frames: { shadowColor: 'transparent', frameBoxShadowCssValue: 'none' },
      },
    },
    sidebar: [
      { label: 'Getting started', items: [
        { label: 'Introduction', slug: 'getting-started/introduction' },
        { label: 'Installation', slug: 'getting-started/installation' },
        { label: 'Quickstart', slug: 'getting-started/quickstart' },
      ] },
      { label: 'Developers', items: [
        { label: 'Using the libraries', slug: 'guides/library' },
        { label: 'Library API', link: '/api/' },
        { label: 'CLI reference', slug: 'reference/cli' },
        { label: 'HTTP API reference', slug: 'reference/server-api' },
        { label: 'Configuration reference', slug: 'reference/server-config' },
        { label: 'Correctness', slug: 'about/correctness' },
      ] },
    ],
  })],
});
