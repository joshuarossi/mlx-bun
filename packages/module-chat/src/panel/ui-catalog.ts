// Part of the chat panel (`@mlx-bun/module-chat`): the app-aware assistant's catalog of the host page's routes,
// overlays and spotlight targets (ids of the host page's own controls).
//
// Shared route IDs keep browser navigation and server validation in agreement.
// Spotlight selectors and overlay IDs belong to the browser.

/** A hash-routed page (shell.ts's Route union, minus "routes" — the DAG
 *  diagram tab isn't a useful assistant destination and is itself
 *  feature-detected/hidden when unavailable). */
import { APP_ROUTE_IDS as ROUTE_IDS } from "../protocol";
export { ROUTE_IDS };
export type RouteId = (typeof ROUTE_IDS)[number];

/** A non-route overlay/panel the assistant can navigate to or spotlight
 *  within. Opening one of these does not change location.hash. */
export const VIEW_IDS = ["memory-panel", "settings", "adapters-panel"] as const;
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

/** Resolve a free-form route/page string (either a bare route id or a
 *  "#/route" hash) the way navigate_app's tool param is described to the
 *  model. Returns null for anything not in ROUTE_IDS. */
export function resolveRouteId(routeOrPage: string): RouteId | null {
  const bare = routeOrPage.trim().replace(/^#\/?/, "");
  return isRouteId(bare) ? bare : null;
}
