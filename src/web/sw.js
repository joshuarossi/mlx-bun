// mlx-bun service worker — SHELL ONLY, not offline chat.
//
// Scope (plan §9 Phase 3, beat-matrix Axis 10 "PWA installability"):
// installability + instant shell load. The app is useless without the
// local inference server actually running (every chat turn is a live
// WebSocket to this same origin's model process), so caching API/WS
// traffic would be actively misleading — a "successful" cached response
// with no model behind it. This worker therefore caches exactly the
// static shell files needed to paint the UI instantly on repeat visits,
// and explicitly does NOT intercept /api/*, /v1/*, /ws/*, /downloads, or
// any other dynamic route — those always go straight to the network,
// cache-worker or not.
//
// Strategy: cache-first for the shell assets below (instant paint from
// cache, revalidate in the background), network-first fallthrough for
// everything else (a cache miss or a non-shell request just fetches
// normally, same as if this worker didn't exist).
//
// Versioned by CACHE_NAME so a deploy invalidates old shells; bump the
// suffix here if the shell file set changes.
const CACHE_NAME = "mlxbun-shell-v1";
const SHELL_FILES = [
  "/",
  "/assets/app.js",
  "/assets/hljs.js",
  "/assets/hljs.css",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL_FILES)).then(() => self.skipWaiting()),
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((names) => Promise.all(names.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  // Only ever handle GET; never intercept the WebSocket upgrade or any
  // mutating request.
  if (req.method !== "GET") return;

  const url = new URL(req.url);
  // Same-origin only, and only the exact shell files — everything else
  // (including /api/*, /v1/*, /downloads, /curves, /dag, and any future
  // route) falls through to the network untouched. This is the load-
  // bearing line: it's what keeps "offline chat" from silently
  // half-working with stale data instead of failing honestly.
  if (url.origin !== self.location.origin || !SHELL_FILES.includes(url.pathname)) return;

  event.respondWith(
    caches.match(req).then((cached) => {
      const network = fetch(req)
        .then((res) => {
          if (res && res.ok) caches.open(CACHE_NAME).then((cache) => cache.put(req, res.clone()));
          return res;
        })
        .catch(() => cached); // offline and nothing cached yet — let it reject naturally
      // Cache-first: serve the cached shell instantly if we have it, and
      // still revalidate in the background so the next load picks up a
      // rebuilt app.js. No cache yet (first visit) -> wait on the network.
      return cached || network;
    }),
  );
});
