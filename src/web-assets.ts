// Embedded web app — the unified SPA (chat / quantize / finetune /
// dataset / status). `with { type: "text" }` inlines the file in both
// `bun run` and the compiled single binary. bun-types types *.html
// imports as HTMLBundle (the html loader), but the text attribute makes
// the runtime value a string — hence the double cast.
import appHtml from "./web/app.html" with { type: "text" };
import curveDesignerHtml from "./lab/curve/curve-designer.html" with { type: "text" };
// Vendored, no-CDN static assets referenced by app.html (convention: any
// self-contained JS/CSS too big to inline gets `with { type: "text" }`
// imported here and served under /assets/<name>; see src/web/vendor/README
// for how hljs.js was built). Add new vendored assets the same way.
import hljsJs from "./web/vendor/hljs.js" with { type: "text" };
import hljsCss from "./web/vendor/hljs-theme.css" with { type: "text" };
// The frontend bundle (plan §7/§9 Phase 2 module split): GENERATED from
// src/web/src/*.ts by `bun scripts/build-web.ts` — see that file's header
// and tests/using/web-build.test.ts (the freshness gate). Same
// with { type: "text" } + /assets/<name> pattern as the vendored assets
// above; app.html's <script defer src="/assets/app.js"> loads it.
import appJs from "./web/app.js" with { type: "text" };
// PWA installability (plan §9 Phase 3, beat-matrix Axis 10): a manifest +
// a single inline SVG icon (no binary PNGs — the hygiene gate forbids
// tracked binary files; some browsers won't show an SVG app icon, which is
// an accepted tradeoff, see docs/reference/server-config.md) + a shell-
// only service worker. Same with { type: "text" } + /assets/<name>-shaped
// pattern as the vendored assets above; see src/web/sw.js's header for why
// it deliberately does NOT cache API/WS traffic.
import manifestWebmanifest from "./web/manifest.webmanifest" with { type: "text" };
import iconSvg from "./web/icon.svg" with { type: "text" };
import swJs from "./web/sw.js" with { type: "text" };
const APP_PAGE = appHtml as unknown as string;
const HLJS_JS = hljsJs as unknown as string;
const HLJS_CSS = hljsCss as unknown as string;
const APP_JS = appJs as unknown as string;
const MANIFEST_WEBMANIFEST = manifestWebmanifest as unknown as string;
const ICON_SVG = iconSvg as unknown as string;
const SW_JS = swJs as unknown as string;
const CURVE_PAGE = curveDesignerHtml as unknown as string;
export const STATIC_ROUTE_ASSETS = {
  appPage: APP_PAGE,
  appJs: APP_JS,
  hljsJs: HLJS_JS,
  hljsCss: HLJS_CSS,
  manifest: MANIFEST_WEBMANIFEST,
  iconSvg: ICON_SVG,
  serviceWorker: SW_JS,
  curvePage: CURVE_PAGE,
};
