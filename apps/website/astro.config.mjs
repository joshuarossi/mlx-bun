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
    '/reference/server-api/': '/getting-started/quickstart/',
    '/reference/server-config/': '/reference/cli/#serve',
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
    description: 'Local AI on Apple Silicon: applications to run and libraries to import.',
    social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/joshuarossi/mlx-bun' }],
    customCss: ['./src/styles/custom.css'],
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
        { label: 'Correctness', slug: 'about/correctness' },
      ] },
    ],
  })],
});
