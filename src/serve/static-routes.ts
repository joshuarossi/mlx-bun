import { readFileSync } from "node:fs";

export interface StaticRouteAssets {
  appPage: string;
  appJs: string;
  hljsJs: string;
  hljsCss: string;
  manifest: string;
  iconSvg: string;
  serviceWorker: string;
  curvePage: string;
}

const ASSET_HEADERS = { "cache-control": "public, max-age=3600" } as const;
const LEGACY_PATHS = new Set(["/status", "/chat", "/quantize", "/finetune", "/dataset"]);

/** Serve the web shell and its static companion pages. Returns null when the
 * request belongs to another route family. */
export function handleStaticRoute(
  url: URL,
  request: Request,
  assets: StaticRouteAssets,
): Response | null {
  if (request.method !== "GET") return null;

  switch (url.pathname) {
    case "/":
      return new Response(assets.appPage, {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    case "/assets/hljs.js":
      return new Response(assets.hljsJs, {
        headers: { "content-type": "text/javascript; charset=utf-8", ...ASSET_HEADERS },
      });
    case "/assets/hljs.css":
      return new Response(assets.hljsCss, {
        headers: { "content-type": "text/css; charset=utf-8", ...ASSET_HEADERS },
      });
    case "/assets/app.js":
      return new Response(assets.appJs, {
        headers: { "content-type": "text/javascript; charset=utf-8", ...ASSET_HEADERS },
      });
    case "/manifest.webmanifest":
      return new Response(assets.manifest, {
        headers: { "content-type": "application/manifest+json; charset=utf-8", ...ASSET_HEADERS },
      });
    case "/assets/icon.svg":
      return new Response(assets.iconSvg, {
        headers: { "content-type": "image/svg+xml; charset=utf-8", ...ASSET_HEADERS },
      });
    case "/sw.js":
      return new Response(assets.serviceWorker, {
        headers: { "content-type": "text/javascript; charset=utf-8", "cache-control": "no-store" },
      });
    case "/curves": {
      let html = assets.curvePage;
      try {
        html = readFileSync(new URL("../assets/curve-designer.html", import.meta.url), "utf8");
      } catch {
        // Compiled binaries use the embedded copy.
      }
      return new Response(html, {
        headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" },
      });
    }
    case "/dag":
      try {
        const html = readFileSync(
          new URL("./assets/training-inference-map.html", import.meta.url),
          "utf8",
        );
        return new Response(html, {
          headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" },
        });
      } catch {
        return new Response(
          "DAG map artifact not found",
          { status: 404 },
        );
      }
    case "/curve-terrain":
      try {
        const html = readFileSync(
          new URL("./assets/curve-terrain.html", import.meta.url),
          "utf8",
        );
        return new Response(html, {
          headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" },
        });
      } catch {
        return new Response(
          "curve terrain artifact not found",
          { status: 404 },
        );
      }
  }

  return LEGACY_PATHS.has(url.pathname)
    ? Response.redirect(`/#${url.pathname}`, 302)
    : null;
}
