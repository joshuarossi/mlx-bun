// Export the browser app as one self-contained HTML file that runs with no server: the page, the stylesheet, the
// highlighter and the bundle are inlined, and the fake backend (`tests/web/fake-backend.ts`) runs inside the page
// through `tests/web/browser-mock.ts`, which stands in for fetch, WebSocket and EventSource. The file opens from disk
// or any static host, for a design review or a hosted preview; a control in its corner switches the scenario, and
// `?scenario=empty|failing` in its address does the same. Nothing here loads a model.
//
//   bun apps/mlx-bun/scripts/web-static.ts [out.html] [--scenario default|empty|failing] [--pace 24] [--fragment]
//
// `--fragment` writes the document without its html, head and body tags (title and styles first), for a host that
// wraps pages in its own skeleton.
import { mkdir } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { webStylesheet } from "../src/web/assets";
import { buildWebBundle } from "../src/web/build";

const argv = process.argv.slice(2);
if (argv.includes("--help") || argv.includes("-h")) {
  console.log("Usage: bun apps/mlx-bun/scripts/web-static.ts [out.html] [--scenario default|empty|failing] [--pace 24] [--fragment]\n\n" +
    "Writes the browser app as one HTML file over an in-page fake backend. No model loads.");
  process.exit(0);
}
const opt = (name: string) => { const i = argv.indexOf(name); return i >= 0 ? argv[i + 1] : undefined; };
const positional = argv.filter((a, i) => !a.startsWith("--") && !(i > 0 && ["--scenario", "--pace"].includes(argv[i - 1]!)));
const out = resolve(positional[0] ?? resolve(import.meta.dir, "../dist/web-static/index.html"));
const scenario = opt("--scenario") ?? "default";
if (!["default", "empty", "failing"].includes(scenario)) throw new Error(`Unknown scenario ${scenario}`);
const paceMs = Number(opt("--pace") ?? 24);
const fragment = argv.includes("--fragment");

const publicDir = resolve(import.meta.dir, "../src/web/public");
const read = (name: string) => Bun.file(resolve(publicDir, name)).text();

/** The mock, bundled for the browser with the scenario baked in as its fallback. */
async function buildMock(): Promise<string> {
  const entry = resolve(import.meta.dir, "../tests/web/mock-entry.ts");
  const result = await Bun.build({
    entrypoints: [entry], target: "browser", minify: false,
    files: { [entry]: `import { installBrowserMock } from "./browser-mock";\ninstallBrowserMock({ scenario: ${JSON.stringify(scenario)}, paceMs: ${paceMs} });\n` },
  });
  if (!result.success) throw new Error(result.logs.map((log) => log.message).join("\n"));
  return result.outputs[0]!.text();
}

/** Inline script text must not end the script element early. */
const inline = (js: string) => js.replace(/<\/script/gi, "<\\/script").replace(/<!--/g, "<\\!--");

const [html, css, highlightCss, highlight, mock, app] = await Promise.all([read("app.html"), webStylesheet(), read("vendor/hljs-theme.css"), read("vendor/hljs.js"), buildMock(), buildWebBundle()]);
const head = html.slice(html.indexOf("<head>") + 6, html.indexOf("</head>"));
const body = html.slice(html.indexOf("<body>") + 6, html.lastIndexOf("</body>"));
// The page's own head, minus what the static file carries inline or does not need: stylesheet links, the manifest and
// icons (a host supplies its own), the title (replaced).
const headRest = head
  .replace(/<link[^>]*rel="(stylesheet|manifest|icon|apple-touch-icon)"[^>]*>\s*/g, "")
  .replace(/<title>[^<]*<\/title>\s*/, "")
  .replace(/<!--[\s\S]*?-->\s*/g, "");
const bodyRest = body.replace(/<script[^>]*src="\/assets\/(hljs|app)\.js"[^>]*><\/script>\s*/g, "").replace(/<!--[\s\S]*?-->\s*/g, "");
const metas = fragment ? headRest.replace(/<meta[^>]*(charset|viewport)[^>]*>\s*/g, "") : headRest;
const styles = `<style>${css}</style>\n<style>${highlightCss}</style>\n`;
// The highlighter is a classic script (it defines the `hljs` global); the mock and the app run as module scripts, so
// their top-level names stay in their own scopes and neither can shadow the other's.
const scripts = `<script>${inline(highlight)}</script>\n<script type="module">${inline(mock)}</script>\n<script type="module">${inline(app)}</script>\n`;
const title = "<title>mlx-bun preview</title>\n";
const document = fragment
  ? `${title}${styles}${metas}${bodyRest}\n${scripts}`
  : `<!doctype html>\n<html lang="en">\n<head>\n${title}${headRest}${styles}</head>\n<body>${bodyRest}\n${scripts}</body>\n</html>\n`;
await mkdir(dirname(out), { recursive: true });
await Bun.write(out, document);
console.log(`${out} (${(document.length / 1024).toFixed(0)} KB, ${scenario} scenario, ${fragment ? "fragment" : "document"})`);
