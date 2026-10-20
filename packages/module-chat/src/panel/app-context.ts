// The app-aware assistant's side of the panel. It pushes the page's UI context (`context` frames) on every route change,
// every wizard-step change and every overlay opening or closing, never on a timer, so the server's ambient line and
// `get_current_app_context` always describe a state the user caused; and it carries out the agent's `ui_navigate` and
// `ui_spotlight` requests. Navigation goes through `location.hash`, the same path a tab click takes. `assistant.ts`
// captures the snapshot and resolves spotlight targets; `ui-catalog.ts` names the host's routes and targets.
import { listen, type Disposer } from "@mlx-bun/web-kit";
import type { ClientMessage, ServerMessage } from "../protocol";
import { buildAppContext, queryUiElements, resolveSpotlightTarget, showSpotlight, type UiSnapshot } from "./assistant";
import { toast } from "./host";
import { isRouteId } from "./ui-catalog";

/** Overlays the assistant reports as the current view, by element id. */
const VIEWS: readonly [id: string, view: string][] = [["mem-overlay", "memory-panel"], ["adapters-overlay", "adapters-panel"]];
const WIZARD_STEPS = ["q-steps", "f-steps", "d-steps"];

/** The page the address names among the host's mounted sections; an empty or unknown address is the chat. */
export function currentRoute(): string {
  const route = (location.hash || "").replace(/^#\/?/, "").split("?")[0] || "";
  return [...document.querySelectorAll<HTMLElement>("section[data-route]")].some((section) => section.dataset.route === route) ? route : "chat";
}

/** The overlay open on top of the route, if any. */
function currentView(): string | null {
  for (const [id, view] of VIEWS) if (document.getElementById(id)?.classList.contains("open")) return view;
  return null;
}

export interface AppContext {
  /** Sends the current context (on every `ready` too: a fresh server session starts without one). */
  push(): void;
  /** Carries out `ui_navigate` and `ui_spotlight`. */
  handle(frame: Extract<ServerMessage, { type: "ui_navigate" | "ui_spotlight" }>): void;
}

export function createAppContext(send: (frame: ClientMessage) => boolean, disposer: Disposer): AppContext {
  // The snapshot last sent, so a spotlight `ref` resolves without a round trip.
  let lastSnapshot: UiSnapshot | null = null;

  function push(): void {
    const route = currentRoute();
    if (!isRouteId(route)) return; // the routes map is not an assistant destination
    const context = buildAppContext(route, currentView());
    lastSnapshot = context.snapshot;
    send({ type: "context", context });
  }

  // Wizard steps live in job panels the shell creates on their first visit, inside shadow roots: rebind on navigation.
  const steps = new MutationObserver(() => push());
  function watchWizardSteps(): void {
    steps.disconnect();
    for (const id of WIZARD_STEPS) {
      const element = queryUiElements(`[id="${id}"]`)[0];
      if (element) steps.observe(element, { childList: true, subtree: true });
    }
  }
  const overlays = new MutationObserver(() => push());
  for (const [id] of VIEWS) {
    const element = document.getElementById(id);
    if (element) overlays.observe(element, { attributes: true, attributeFilter: ["class"] });
  }
  watchWizardSteps();
  disposer.add(listen(window, "hashchange", () => { watchWizardSteps(); push(); }));
  disposer.add(() => { steps.disconnect(); overlays.disconnect(); });

  function spotlight(frame: Extract<ServerMessage, { type: "ui_spotlight" }>): void {
    const point = () => {
      const resolved = resolveSpotlightTarget({ ref: frame.ref, label: frame.label, selector: frame.selector, target: frame.target, message: frame.message }, lastSnapshot);
      if (!resolved || !showSpotlight(resolved)) toast("Couldn't find that on screen to point at.", "err");
    };
    if (!frame.route) { point(); return; }
    // The shell mounts a page's panel on hashchange: resolve once that navigation has attached its controls. A
    // preceding ui_navigate may already have set this hash with its event still queued; the next task follows it.
    const hash = `#/${frame.route}`;
    const afterNavigation = () => requestAnimationFrame(point);
    if (location.hash === hash) setTimeout(afterNavigation, 0);
    else {
      window.addEventListener("hashchange", afterNavigation, { once: true });
      location.hash = hash;
    }
  }

  return {
    push,
    handle(frame) {
      if (frame.type === "ui_navigate") location.hash = `#/${frame.route}`;
      else spotlight(frame);
    },
  };
}
