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
	{ src: 'server-api.md', dest: 'reference/server-api.md', title: 'Server API', description: 'OpenAI, Anthropic, and Responses HTTP endpoints, with full request/response schemas.' },
	{ src: 'server-config.md', dest: 'reference/server-config.md', title: 'Server configuration', description: 'serve flags, environment variables, and the --batch compatibility matrix.' },
	{ src: 'training.md', dest: 'reference/training.md', title: 'Training & fine-tuning', description: 'LoRA / SFT fine-tuning on Apple Silicon — recipes, flags, and the segmented backward pass.' },
	{ src: 'cli.md', dest: 'reference/cli.md', title: 'CLI reference', description: 'Every mlx-bun verb — serve, get, ls, fit, train, memory, pi, and the rest.' },
	{ src: 'library-api.md', dest: 'guides/library.md', title: 'Using the library', description: 'Embed MLX generation directly in a Bun process via loadContext / generate.' },
	{ src: 'embedding.md', dest: 'guides/embedding.md', title: 'Embedding in a Mac app', description: 'Ship local inference as a single signed, notarized binary sidecar.' },
	{ src: 'memory.md', dest: 'guides/memory.md', title: 'Personal memory', description: 'A local, git-tracked Markdown wiki the built-in agents read as durable user context.' },
	{ src: 'models.md', dest: 'guides/model-management.md', title: 'Model management', description: 'Downloading, indexing, listing, and reclaiming models — get, scan, ls, gc, and the HF cache layout.' },
	{ src: 'orpo-quickstart.md', dest: 'guides/fine-tuning-quickstart.md', title: 'Fine-tuning quickstart', description: 'ORPO / DPO / SFT LoRA fine-tuning with the full preconfigured stack — one command.' },
];

function rewriteLinks(s) {
	return s
		.replaceAll('](../../', `](${GH}/`)
		.replaceAll('](../design/', `](${GH}/docs/design/`)
		.replaceAll('](../investigations/', `](${GH}/docs/investigations/`)
		.replace(/\]\((?:\.\/)?server-api\.md\)/g, '](/reference/server-api/)')
		.replace(/\]\((?:\.\/)?server-config\.md\)/g, '](/reference/server-config/)')
		.replace(/\]\((?:\.\/)?training\.md\)/g, '](/reference/training/)')
		.replace(/\]\((?:\.\/)?cli\.md\)/g, '](/reference/cli/)')
		.replace(/\]\((?:\.\/)?library-api\.md\)/g, '](/guides/library/)')
		.replace(/\]\((?:\.\/)?embedding\.md\)/g, '](/guides/embedding/)')
		.replace(/\]\((?:\.\/)?memory\.md\)/g, '](/guides/memory/)')
		.replace(/\]\((?:\.\/)?models\.md\)/g, '](/guides/model-management/)')
		.replace(/\]\((?:\.\/)?orpo-quickstart\.md\)/g, '](/guides/fine-tuning-quickstart/)')
		.replace(/\]\((?:\.\/)?distribution\.md\)/g, `](${GH}/docs/reference/distribution.md)`);
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
