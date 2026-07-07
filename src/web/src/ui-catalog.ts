// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 3, §6.6 "app-aware assistant"). Built into src/web/app.js by
// scripts/build-web.ts.
//
// The frontend half of the app-aware assistant's route/spotlight catalog.
// Mirrors PortfolioManager's ui-catalog.json pattern (client/src/lib/
// ui-catalog.ts + server/src/agent/ui-catalog.ts, read together with
// server/src/agent/portfolio-tools.ts as the reference implementation) but
// inlined as a TS module (not a shared JSON file) since mlx-bun's server and
// browser bundles are separate build outputs (scripts/build-web.ts vs bun's
// own TS execution) with no shared-JSON-import convention today — pi-web.ts
// mirrors ROUTE_IDS/SPOTLIGHT_TARGETS as plain string arrays for its own
// server-side validation (navigate_app/spotlight_ui reject anything not in
// that list BEFORE touching the browser) so route validity is checked at
// both ends without a build-time shared asset.
//
// Keep this list's ROUTE_IDS in sync with shell.ts's ROUTES tuple (chat,
// quantize, finetune, dataset, status) plus the Developer-only overlays that
// aren't hash-routes (memory panel, hub panel, settings) — those are
// `view`s, not `route`s (see UiContext.view below), reached by opening an
// overlay rather than changing the URL hash.

/** A hash-routed page (shell.ts's Route union, minus "routes" — the DAG
 *  diagram tab isn't a useful assistant destination and is itself
 *  feature-detected/hidden when unavailable). */
export const ROUTE_IDS = ["chat", "quantize", "finetune", "dataset", "status"] as const;
export type RouteId = (typeof ROUTE_IDS)[number];

/** A non-route overlay/panel the assistant can navigate to or spotlight
 *  within. Opening one of these does not change location.hash. */
export const VIEW_IDS = ["memory-panel", "hub-panel", "settings", "adapters-panel"] as const;
export type ViewId = (typeof VIEW_IDS)[number];

export function isRouteId(v: string): v is RouteId {
  return (ROUTE_IDS as readonly string[]).includes(v);
}
export function isViewId(v: string): v is ViewId {
  return (VIEW_IDS as readonly string[]).includes(v);
}

/** Human labels for routes, used in the "unknown route" tool-error message
 *  and nowhere else — kept tiny on purpose. */
export const ROUTE_LABELS: Record<RouteId, string> = {
  chat: "Chat",
  quantize: "Quantize",
  finetune: "Fine-tune",
  dataset: "Build Dataset",
  status: "Status",
};

/** A curated spotlight target: a stable id -> the selector to highlight +
 *  a human label for the popover title, plus which route/view it lives on
 *  (spotlight_ui navigates there first if the browser isn't already on it).
 *  This is the "catalog target" resolution path in resolve-spotlight.ts's
 *  terms — the fallback when ref/label/selector don't resolve from the live
 *  DOM or the last uiSnapshot. Anchors added to app.html via data-spotlight
 *  in this same wave; ids are stable and boring (element id minus "chat-"
 *  prefix noise where it reads fine either way). */
export interface SpotlightTarget {
  selector: string;
  label: string;
  route?: RouteId;
  view?: ViewId;
}

export const SPOTLIGHT_TARGETS: Record<string, SpotlightTarget> = {
  composer: { selector: "#chat-box", label: "Message box", route: "chat" },
  send: { selector: "#chat-send", label: "Send", route: "chat" },
  "new-chat": { selector: "#chat-new", label: "New chat", route: "chat" },
  "session-search": { selector: "#chat-sess-search", label: "Search chats", route: "chat" },
  "sampling-pill": { selector: "#chat-sampling", label: "Sampling", route: "chat" },
  "prompt-pill": { selector: "#chat-sysprompt", label: "System prompt", route: "chat" },
  "adapter-select": { selector: "#chat-adapter", label: "LoRA adapter", route: "chat" },
  "memory-entry": { selector: "#chat-memory-entry", label: "Memory", route: "chat" },
  "developer-toggle": { selector: "#nav-developer", label: "Developer toggle" },
  "model-picker": { selector: "#nav-model", label: "Active model" },
  "hub-browse": { selector: "#model-pop-browse", label: "Browse models", view: "hub-panel" },
  "quantize-source": { selector: "#q-model", label: "Source model", route: "quantize" },
  "finetune-base": { selector: "#f-model", label: "Base model", route: "finetune" },
};

export function getSpotlightTarget(id: string): SpotlightTarget | null {
  return SPOTLIGHT_TARGETS[id] ?? null;
}

/** Resolve a free-form route/page string (either a bare route id or a
 *  "#/route" hash) the way navigate_app's tool param is described to the
 *  model. Returns null for anything not in ROUTE_IDS. */
export function resolveRouteId(routeOrPage: string): RouteId | null {
  const bare = routeOrPage.trim().replace(/^#\/?/, "");
  return isRouteId(bare) ? bare : null;
}
