import { readFile, stat } from "node:fs/promises";
import { resolve } from "node:path";
import { INSTALLER_SOURCE } from "./generate-reference";

const root = resolve(import.meta.dir, "../../.."), dist = resolve(import.meta.dir, "../dist");
const pages = new Map<string, string>();
for await (const path of new Bun.Glob("**/*.html").scan(dist))
  pages.set(`/${path}`, await readFile(resolve(dist, path), "utf8"));
if (!pages.has("/index.html") || !pages.has("/reference/cli/index.html") || !pages.has("/api/index.html")) throw new Error("Missing site entry, CLI reference, or library API");
// Public URLs from the previous site remain navigable, even when their old
// prose is deliberately replaced by a redirect to the current explanation.
for (const path of ["getting-started/introduction", "getting-started/installation", "getting-started/quickstart",
  "guides/library", "guides/embedding", "guides/model-management", "guides/fine-tuning-quickstart",
  "guides/distribution", "guides/troubleshooting", "guides/memory", "reference/server-api",
  "reference/server-config", "reference/training", "reference/models", "reference/benchmarks", "reference/glossary",
  "about/why", "about/comparison", "about/benchmarks", "about/lab", "about/correctness"])
  if (!pages.has(`/${path}/index.html`)) throw new Error(`Missing public documentation URL: /${path}/`);
const installer = await readFile(resolve(dist, "install.sh"));
if (!installer.equals(await readFile(resolve(root, INSTALLER_SOURCE)))) throw new Error("Published installer differs from its canonical source");
if ((await readFile(resolve(dist, "CNAME"), "utf8")).trim() !== "mlx-bun.dev") throw new Error("Missing site domain");
if (!(await stat(resolve(dist, "pagefind/pagefind.js"))).isFile()) throw new Error("Search index was not built");

// Inspect navigable links, not Astro's synthetic canonical URL for 404.html.
for (const [page, html] of pages) for (const match of html.matchAll(/<a\b[^>]*\bhref="([^"]+)"/g)) {
  const url = new URL(match[1]!.replaceAll("&amp;", "&"), `https://mlx-bun.dev${page}`);
  if (url.origin !== "https://mlx-bun.dev") continue;
  const path = decodeURIComponent(url.pathname);
  const target = path.endsWith("/") ? `${path}index.html` : path;
  if (target.endsWith(".html")) {
    const content = pages.get(target);
    if (!content) throw new Error(`${page}: missing page ${target}`);
    const id = decodeURIComponent(url.hash.slice(1));
    if (id && !content.includes(`id="${id}"`)) throw new Error(`${page}: missing anchor ${url.pathname}#${id}`);
  } else if (!(await stat(resolve(dist, `.${target}`)).catch(() => null))?.isFile()) {
    throw new Error(`${page}: missing asset ${target}`);
  }
}
console.log(`Verified ${pages.size} static pages, local links, search, and the canonical installer.`);
