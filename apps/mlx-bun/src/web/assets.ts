/** Owns the browser's static files. The application mounts this alongside
 * HTTP and WebSocket handlers; creating it neither opens a socket nor imports
 * an inference engine. The package's prepack builds the generated JS. */
export async function createWebHandler() {
  const publicFile = (name: string) => Bun.file(new URL(`./public/${name}`, import.meta.url)).text();
  const script = Bun.file(new URL("../../dist/web/app.js", import.meta.url));
  if (!await script.exists()) throw new Error("Web bundle missing; run bun run --filter mlx-bun build:web");
  const [html, app, highlight, theme, manifest, icon, worker] = await Promise.all([
    publicFile("app.html"), script.text(), publicFile("vendor/hljs.js"), publicFile("vendor/hljs-theme.css"),
    publicFile("manifest.webmanifest"), publicFile("icon.svg"), publicFile("sw.js"),
  ]);
  const cache = "public, max-age=3600";
  const files: Record<string, { body: string; type: string; cache?: string }> = {
    "/": { body: html, type: "text/html; charset=utf-8" },
    "/assets/app.js": { body: app, type: "text/javascript; charset=utf-8", cache },
    "/assets/hljs.js": { body: highlight, type: "text/javascript; charset=utf-8", cache },
    "/assets/hljs.css": { body: theme, type: "text/css; charset=utf-8", cache },
    "/manifest.webmanifest": { body: manifest, type: "application/manifest+json; charset=utf-8", cache },
    "/assets/icon.svg": { body: icon, type: "image/svg+xml; charset=utf-8", cache },
    "/sw.js": { body: worker, type: "text/javascript; charset=utf-8", cache: "no-store" },
  };
  const legacy = new Set(["/status", "/chat", "/quantize", "/finetune", "/dataset"]);
  return (request: Request): Response | null => {
    if (request.method !== "GET") return null;
    const path = new URL(request.url).pathname, file = files[path];
    if (file) return new Response(file.body, { headers: {
      "content-type": file.type, ...(file.cache ? { "cache-control": file.cache } : {}),
    } });
    return legacy.has(path) ? Response.redirect(`/#${path}`, 302) : null;
  };
}
