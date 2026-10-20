// The app-aware assistant's side of the panel. It pushes the page's UI context (`context` frames) whenever the host says
// its route, overlay or wizard step changed (`host.app.onChange`) and whenever the chat's own adapters sheet opens or
// closes, never on a timer, so the server's ambient line and `get_current_app_context` always describe a state the user
// caused; and it carries out the agent's `ui_navigate` and `ui_spotlight` requests through the host's `navigate`. The
// host owns its pages: without `host.app` the chat is the only page and its adapters sheet the only view, and the
// assistant cannot navigate. `assistant.ts` captures the snapshot and resolves spotlight targets; `ui-catalog.ts` names
// the routes and targets.
import type { Disposer } from "@mlx-bun/web-kit";
import type { ClientMessage, ServerMessage } from "../protocol";
import { adaptersPanelOpen } from "./adapters-panel";
import { buildAppContext, resolveSpotlightTarget, showSpotlight, type UiSnapshot } from "./assistant";
import { toast, type ChatHostApp } from "./host";
import { isRouteId } from "./ui-catalog";

const CANNOT_NAVIGATE = "This host cannot navigate.";

export interface AppContext {
  /** Sends the current context (on every `ready` too: a fresh server session starts without one). */
  push(): void;
  /** Carries out `ui_navigate` and `ui_spotlight`. */
  handle(frame: Extract<ServerMessage, { type: "ui_navigate" | "ui_spotlight" }>): void;
}

export function createAppContext(send: (frame: ClientMessage) => boolean, app: ChatHostApp | undefined, disposer: Disposer): AppContext {
  // The snapshot last sent, so a spotlight `ref` resolves without a round trip.
  let lastSnapshot: UiSnapshot | null = null;
  const currentRoute = (): string => app?.currentRoute() ?? "chat";

  function push(): void {
    const route = currentRoute();
    if (!isRouteId(route)) return; // the routes map is not an assistant destination
    // The host's overlay sits over the chat's own sheet.
    const view = app?.currentView() ?? (adaptersPanelOpen() ? "adapters-panel" : null);
    const context = buildAppContext(route, view, app?.wizardStep() ?? null);
    lastSnapshot = context.snapshot;
    send({ type: "context", context });
  }

  if (app) disposer.add(app.onChange(push));

  function spotlight(frame: Extract<ServerMessage, { type: "ui_spotlight" }>): void {
    const point = () => {
      const resolved = resolveSpotlightTarget({ ref: frame.ref, label: frame.label, selector: frame.selector, target: frame.target, message: frame.message }, lastSnapshot);
      if (!resolved || !showSpotlight(resolved)) toast("Couldn't find that on screen to point at.", "err");
    };
    const route = frame.route;
    if (!route) { point(); return; }
    if (!app) { if (route === currentRoute()) point(); else toast(CANNOT_NAVIGATE, "err"); return; }
    // The host mounts a page's panel as it navigates: resolve once that change has attached its controls, after
    // layout. A preceding ui_navigate may already have asked for this page with its change still queued; the next
    // task follows it.
    const afterNavigation = () => requestAnimationFrame(point);
    if (app.currentRoute() === route) { setTimeout(afterNavigation, 0); return; }
    // Once: a newly mounted wizard reports its first step while the host is still handling the navigation.
    let done = false;
    const stop = app.onChange(() => { if (done) return; done = true; stop(); afterNavigation(); });
    app.navigate(route);
  }

  return {
    push,
    handle(frame) {
      if (frame.type === "ui_spotlight") spotlight(frame);
      else if (app) app.navigate(frame.route);
      else toast(CANNOT_NAVIGATE, "err");
    },
  };
}
