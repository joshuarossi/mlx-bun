// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { syncReferenceDocs } from './scripts/sync-reference-docs.mjs';

// Regenerate reference/guide pages from docs/reference/*.md before every
// dev/build, so the site is always in sync with the source docs.
const syncDocs = {
	name: 'sync-reference-docs',
	hooks: { 'astro:config:setup': () => syncReferenceDocs() },
};

// https://astro.build/config
export default defineConfig({
	site: 'https://mlx-bun.dev',
	integrations: [
		syncDocs,
		starlight({
			title: 'mlx-bun',
			description:
				'Native MLX inference for Bun on Apple Silicon — a local LLM server (OpenAI/Anthropic-compatible) and TypeScript library. No Python.',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/joshuarossi/mlx-bun' },
				{ icon: 'npm', label: 'npm', href: 'https://www.npmjs.com/package/mlx-bun' },
			],
			editLink: {
				baseUrl: 'https://github.com/joshuarossi/mlx-bun/edit/main/website/',
			},
			lastUpdated: true,
			customCss: ['./src/styles/custom.css'],
			sidebar: [
				{
					label: 'Getting started',
					items: [
						{ label: 'Introduction', slug: 'getting-started/introduction' },
						{ label: 'Installation', slug: 'getting-started/installation' },
						{ label: 'Quickstart', slug: 'getting-started/quickstart' },
					],
				},
				{
					label: 'Guides',
					items: [
						{ label: 'Personal memory', slug: 'guides/memory' },
						{ label: 'Using the library', slug: 'guides/library' },
						{ label: 'Distribution', slug: 'guides/distribution' },
						{ label: 'Troubleshooting', slug: 'guides/troubleshooting' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'CLI', slug: 'reference/cli' },
						{ label: 'Server API', slug: 'reference/server-api' },
						{ label: 'Server configuration', slug: 'reference/server-config' },
						{ label: 'Training & fine-tuning', slug: 'reference/training' },
						{ label: 'Supported models', slug: 'reference/models' },
						{ label: 'Benchmarks', slug: 'reference/benchmarks' },
						{ label: 'Reference environment', slug: 'reference/environment' },
						{ label: 'Glossary', slug: 'reference/glossary' },
					],
				},
				{
					label: 'About',
					items: [
						{ label: 'Why mlx-bun', slug: 'about/why' },
						{ label: 'How it compares', slug: 'about/comparison' },
						{ label: 'Benchmarks', slug: 'about/benchmarks' },
						{ label: 'Correctness', slug: 'about/correctness' },
						{ label: 'The lab', slug: 'about/lab' },
					],
				},
			],
		}),
	],
});
