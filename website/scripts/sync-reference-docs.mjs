// Generate the site's reference/guide pages from the repo's docs/reference/*.md
// so they CANNOT drift from the source. Runs automatically on every dev/build
// (wired into astro.config.mjs). The generated files are gitignored — edit the
// source docs in docs/reference/, never the generated copies.
//
// Transform per doc: strip the leading H1, inject Starlight frontmatter
// (including an editUrl pointing at the real source, so "Edit page" doesn't
// 404 on the gitignored copy), and rewrite the source's relative links
// (repo files → GitHub; cross-doc → site routes).
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url)); // website/scripts
const SRC = resolve(HERE, '../../docs/reference'); // repo/docs/reference
const DEST = resolve(HERE, '../src/content/docs'); // website content root
const GH = 'https://github.com/joshuarossi/mlx-bun/blob/main';
const GH_EDIT = 'https://github.com/joshuarossi/mlx-bun/edit/main';

// source file → { dest (under DEST), title, description }
const MAP = [
	{ src: 'server-api.md', dest: 'reference/server-api.md', title: 'Server API', description: 'Every HTTP route — OpenAI, Anthropic, Responses, jobs, memory, admin — with request/response schemas.' },
	{ src: 'server-config.md', dest: 'reference/server-config.md', title: 'Server configuration', description: 'Every serve flag, environment variable, default, and the feature/fidelity matrix.' },
	{ src: 'cli.md', dest: 'reference/cli.md', title: 'CLI reference', description: 'Every mlx-bun verb — serve, get, ls, fit, train, memory, pi, and the rest — plus the mlx-lm compatibility map.' },
	{ src: 'models.md', dest: 'reference/models.md', title: 'Supported models', description: 'The one supported-model roster: families, modalities, draft sources, KV schemes, and model management.' },
	{ src: 'benchmarks.md', dest: 'reference/benchmarks.md', title: 'Benchmarks', description: 'Curated parity / performance / quality numbers, labeled by host, and how to run the benchmark.' },
	{ src: 'training.md', dest: 'reference/training.md', title: 'Training & fine-tuning', description: 'LoRA / ORPO / SFT fine-tuning on Apple Silicon — flags, flash-CCE, segmented backward, prefix sharing.' },
	{ src: 'library-api.md', dest: 'guides/library.md', title: 'Using the library', description: 'Embed MLX generation and embeddings directly in a Bun process — the full export surface.' },
	{ src: 'distribution.md', dest: 'guides/distribution.md', title: 'Distribution', description: 'Signed, notarized binaries, the Homebrew tap, npm, and the native runtime pack.' },
	{ src: 'memory.md', dest: 'guides/memory.md', title: 'Personal memory', description: 'A local, git-tracked Markdown wiki the built-in agents read as durable user context.' },
	{ src: 'troubleshooting.md', dest: 'guides/troubleshooting.md', title: 'Troubleshooting', description: 'Symptom → cause → fix for install, download, memory-fit, and Gatekeeper issues.' },
	{ src: 'glossary.md', dest: 'reference/glossary.md', title: 'Glossary', description: 'Serving vocabulary and the synonyms we deliberately do not use.' },
];

function rewriteLinks(s) {
	return s
		.replaceAll('](../../', `](${GH}/`)
		.replaceAll('](../design/', `](${GH}/docs/design/`)
		.replaceAll('](../archive/', `](${GH}/docs/archive/`)
		.replace(/\]\((?:\.\/)?server-api\.md\)/g, '](/reference/server-api/)')
		.replace(/\]\((?:\.\/)?server-config\.md\)/g, '](/reference/server-config/)')
		.replace(/\]\((?:\.\/)?training\.md\)/g, '](/reference/training/)')
		.replace(/\]\((?:\.\/)?cli\.md\)/g, '](/reference/cli/)')
		.replace(/\]\((?:\.\/)?library-api\.md\)/g, '](/guides/library/)')
		.replace(/\]\((?:\.\/)?distribution\.md\)/g, '](/guides/distribution/)')
		.replace(/\]\((?:\.\/)?troubleshooting\.md\)/g, '](/guides/troubleshooting/)')
		.replace(/\]\((?:\.\/)?benchmarks\.md\)/g, '](/reference/benchmarks/)')
		// environment.md is the maintainer's oracle/machine setup (local paths, pins) — not a site page; link to the source.
		.replace(/\]\((?:\.\/)?environment\.md\)/g, `](${GH}/docs/reference/environment.md)`)
		.replace(/\]\((?:\.\/)?glossary\.md\)/g, '](/reference/glossary/)')
		.replace(/\]\((?:\.\/)?memory\.md\)/g, '](/guides/memory/)')
		.replace(/\]\((?:\.\/)?models\.md\)/g, '](/reference/models/)');
}

export function syncReferenceDocs() {
	for (const { src, dest, title, description } of MAP) {
		const raw = readFileSync(resolve(SRC, src), 'utf8');
		const body = raw.replace(/^#[^\n]*\n+/, ''); // drop leading H1 + blank lines
		const editUrl = `${GH_EDIT}/docs/reference/${src}`;
		const out = `---\ntitle: ${JSON.stringify(title)}\ndescription: ${JSON.stringify(description)}\neditUrl: ${JSON.stringify(editUrl)}\n---\n\n${rewriteLinks(body)}`;
		const target = resolve(DEST, dest);
		mkdirSync(dirname(target), { recursive: true });
		writeFileSync(target, out);
	}
	console.log(`[sync-reference-docs] generated ${MAP.length} pages from docs/reference/`);
}

// Allow `node scripts/sync-reference-docs.mjs` for manual runs.
if (process.argv[1] === fileURLToPath(import.meta.url)) syncReferenceDocs();
