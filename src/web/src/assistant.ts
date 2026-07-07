// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §6.6 "the app-aware assistant", §9 Phase 3, beat matrix Axis 12). Built
// into src/web/app.js by scripts/build-web.ts.
//
// Three pieces, mirroring the proven PortfolioManager reference
// (client/src/lib/{ui-snapshot,spotlight,resolve-spotlight}.ts, read in
// full before writing this file):
//
//  1. captureUiSnapshot() — a structured DOM snapshot (visible interactive
//     elements + labeled regions), capped at ~120, agent chrome excluded.
//     Sent to the server as a `context` ClientMessage on route/step change
//     (see chat.ts) and returned by the `get_current_app_context` tool.
//  2. resolveSpotlightTarget() — turns a spotlight_ui tool's loose
//     {ref|label|selector|target} request into a concrete element, in
//     exactly PortfolioManager's resolution order (ref from the last
//     snapshot -> live selector -> label fuzzy-match -> catalog target).
//  3. showSpotlight()/dismissSpotlight() — the hand-rolled, NEVER-HIJACK
//     overlay (§6.6 hard constraint, verbatim): traps no focus, blocks no
//     clicks (pointer-events: none on the whole overlay — the highlighted
//     control stays clickable THROUGH it), auto-dismisses ~3s, and ANY user
//     input (keydown/mousedown/wheel) dismisses it instantly. transform/
//     opacity animations only, prefers-reduced-motion honored. This is
//     deliberately NOT wired into shell.ts's closeTopOverlay/trapFocus
//     machinery — those are for real modals; this overlay must never behave
//     like one.

import { getSpotlightTarget, isViewId, ROUTE_LABELS, type RouteId, type ViewId } from "./ui-catalog";

/* ────────────────────────────────────────────────────────────────────
   1. SEE — the structured DOM snapshot
   ──────────────────────────────────────────────────────────────────── */

export interface UiSnapshotElement {
  ref: string;
  tag: string;
  label: string;
  kind: "interactive" | "region";
  role?: string;
  selector: string;
  spotlightId?: string;
}

export interface UiSnapshot {
  route: string;
  capturedAt: string;
  elements: UiSnapshotElement[];
}

/** Process-state fields layered onto the snapshot (§6.6 "the snapshot
 *  carries process state, not just elements") — wizard step for the
 *  quantize/finetune/dataset wizards, when the current route has one.
 *  Derived by reading the DOM the step indicator already renders
 *  (markdown.ts's renderSteps into #q-steps/#f-steps/#d-steps + the
 *  [data-qstep]/[data-fstep]/[data-dstep] visibility toggle quantize.ts/
 *  finetune.ts/dataset.ts already do) rather than adding a callback hook to
 *  those three controllers — zero behavior change to files outside this
 *  wave's scope, and the DOM IS the source of truth those controllers
 *  already write to. */
export interface WizardStep {
  index: number;
  count: number;
  label: string;
}

const STEP_CONTAINER_BY_ROUTE: Partial<Record<RouteId, string>> = {
  quantize: "q-steps",
  finetune: "f-steps",
  dataset: "d-steps",
};

export function currentWizardStep(route: string): WizardStep | null {
  const containerId = STEP_CONTAINER_BY_ROUTE[route as RouteId];
  if (!containerId) return null;
  const container = document.getElementById(containerId);
  if (!container) return null;
  const spans = [...container.querySelectorAll(".s")];
  if (spans.length === 0) return null;
  const curIdx = spans.findIndex((s) => s.classList.contains("cur"));
  const cur = spans[curIdx] ?? spans[0]!;
  const label = cur.querySelector(".n")
    ? (cur.textContent || "").replace(/^\d+/, "").trim()
    : (cur.textContent || "").trim();
  return { index: curIdx < 0 ? 0 : curIdx, count: spans.length, label };
}

const INTERACTIVE_SELECTOR = [
  "button:not([disabled])",
  "a[href]",
  'input:not([type="hidden"]):not([disabled])',
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[role="button"]',
  "[data-spotlight]",
].join(", ");

const MAX_ELEMENTS = 120;

/** Chrome/content the snapshot must never include: toasts, the assistant's
 *  own spotlight overlay (`data-ui-chrome="assistant"`), rendered
 *  conversation content (`data-ui-chrome="content"` — chat-thread and the
 *  memory/adapters/hub panel bodies, see the marker sites in chat.ts/
 *  memory-panel.ts/adapters-panel.ts/hub.ts), and any overlay currently
 *  closed (display:none via its .open class gate — see isVisible's
 *  ancestor walk below).
 *
 *  The `data-ui-chrome="content"` exclusion matters beyond tidiness: a
 *  rendered assistant/user message can contain a real `<a href>` (a
 *  citation link, a markdown link from RAG'd/tool/web content, or just an
 *  ordinary reply). INTERACTIVE_SELECTOR matches `a[href]`, and this
 *  snapshot's whole point is to be re-served to the model verbatim as
 *  trusted "current UI state" via get_current_app_context — without this
 *  exclusion, an attacker-influenced link's visible text becomes a second,
 *  less-obvious prompt-injection channel alongside the visible transcript
 *  the model already sees. Any element inside a `data-ui-chrome="content"`
 *  root is excluded regardless of nesting depth (`.closest`), matching how
 *  the "assistant" chrome exclusion already works. */
function isAgentChrome(el: Element): boolean {
  return !!el.closest("[data-ui-chrome]") || !!el.closest("#toasts");
}

/** True when `el` itself is hidden by inline style or the `hidden`
 *  attribute — deliberately NOT full computed-style resolution (a real
 *  browser's CSS-class-driven `display:none` — e.g. `#mem-overlay{display:
 *  none} .open{display:flex}` — only resolves through getComputedStyle,
 *  which happy-dom's test environment can't lay out or cascade through
 *  <style> rules). Real browsers get the accurate signal from
 *  offsetParent below; this inline-only check is the fallback that also
 *  makes the ancestor walk deterministically testable with plain
 *  `style="display:none"` fixtures. */
function isHiddenSelf(el: Element): boolean {
  const html = el as HTMLElement;
  if (html.hidden) return true;
  const inline = html.style?.display;
  if (inline === "none") return true;
  const inlineVis = html.style?.visibility;
  if (inlineVis === "hidden" || inlineVis === "collapse") return true;
  return false;
}

function isVisible(el: Element): boolean {
  const html = el as HTMLElement;
  // offsetParent is the accurate, layout-derived signal in a real browser
  // (null for display:none, including via a CSS class rule) — the same
  // test shell.ts's trapFocus already uses elsewhere in this codebase. Only
  // trust it when it's null: some engines (and fixed-position elements)
  // report null even when visible, and test environments without real
  // layout (happy-dom) report `undefined` for every element regardless of
  // visibility — in both of those cases fall through to the ancestor walk
  // below rather than either false-negative or false-positive on
  // offsetParent alone.
  if (html.offsetParent === null) {
    const style = (globalThis as { getComputedStyle?: (e: Element) => CSSStyleDeclaration }).getComputedStyle?.(html);
    if (style && style.position === "fixed") return true;
  }
  // Ancestor walk: catches inline/attribute hidden state on `el` itself or
  // any ancestor (a closed overlay's contents, a display:none wrapper),
  // independent of whether offsetParent resolved anything above.
  for (let node: Element | null = el; node; node = node.parentElement) {
    if (isHiddenSelf(node)) return false;
  }
  return true;
}

function elementLabel(el: Element): string {
  const html = el as HTMLElement;

  const uiLabel = html.getAttribute("data-ui-label")?.trim();
  if (uiLabel) return uiLabel;

  const aria = html.getAttribute("aria-label")?.trim();
  if (aria) return aria;

  const labelledBy = html.getAttribute("aria-labelledby");
  if (labelledBy) {
    const labelEl = document.getElementById(labelledBy);
    if (labelEl?.textContent?.trim()) return labelEl.textContent.trim();
  }

  const spotlight = html.getAttribute("data-spotlight")?.trim();
  const text = html.textContent?.replace(/\s+/g, " ").trim() ?? "";
  if (spotlight) return text.length > 0 && text.length <= 100 ? text : spotlight;

  if (text.length > 0 && text.length <= 80) return text;

  const placeholder = (html as HTMLInputElement).placeholder?.trim();
  if (placeholder) return placeholder;

  const title = html.getAttribute("title")?.trim();
  if (title) return title;

  const name = html.getAttribute("name")?.trim();
  if (name) return name;

  return "";
}

/** Build the ~120-cap snapshot of the CURRENT DOM. `route` is whatever
 *  chat.ts's currentRoute()/overlay-name is at capture time — stamped onto
 *  the snapshot and used to derive stable per-route refs. */
export function captureUiSnapshot(route: string): UiSnapshot {
  const nodes = [...document.querySelectorAll(INTERACTIVE_SELECTOR)];
  const elements: UiSnapshotElement[] = [];
  const seenRefs = new Set<string>();
  let index = 0;

  for (const el of nodes) {
    if (isAgentChrome(el) || !isVisible(el)) continue;
    const label = elementLabel(el);
    if (!label) continue;

    const html = el as HTMLElement;
    const spotlightId = html.getAttribute("data-spotlight")?.trim() || undefined;
    const existingRef = html.getAttribute("data-ui-ref");
    const ref = existingRef ?? `ui-${route.replace(/[^a-zA-Z0-9]/g, "_") || "root"}-${index}`;
    if (!existingRef) html.setAttribute("data-ui-ref", ref);
    if (seenRefs.has(ref)) continue;
    seenRefs.add(ref);

    elements.push({
      ref,
      tag: html.tagName.toLowerCase(),
      label,
      kind: spotlightId ? "region" : "interactive",
      role: html.getAttribute("role") ?? undefined,
      selector: `[data-ui-ref="${ref}"]`,
      spotlightId,
    });
    index += 1;
    if (elements.length >= MAX_ELEMENTS) break;
  }

  return { route, capturedAt: new Date().toISOString(), elements };
}

/* ────────────────────────────────────────────────────────────────────
   2. POINT — resolving a spotlight_ui request to a concrete element
   ──────────────────────────────────────────────────────────────────── */

export interface SpotlightRequest {
  ref?: string;
  label?: string;
  selector?: string;
  target?: string;
  message?: string;
  route?: string;
}

export interface ResolvedSpotlight {
  selector: string;
  title: string;
  message?: string;
}

function matchScore(haystack: string, query: string): number {
  const h = haystack.toLowerCase();
  const q = query.toLowerCase().trim();
  if (!q) return 0;
  if (h === q) return 100;
  if (h.includes(q)) return 85;
  const tokens = q.split(/\s+/).filter(Boolean);
  if (tokens.length === 0) return 0;
  const matched = tokens.filter((t) => h.includes(t)).length;
  return matched === 0 ? 0 : 50 + (matched / tokens.length) * 35;
}

/** Fuzzy label match against the last-captured snapshot's elements — same
 *  scoring PortfolioManager's ui-snapshot.ts findElementByLabel uses. */
function findByLabel(snapshot: UiSnapshot | null, label: string): UiSnapshotElement | undefined {
  if (!snapshot) return undefined;
  let best: UiSnapshotElement | undefined;
  let bestScore = 0;
  for (const el of snapshot.elements) {
    const hay = [el.label, el.spotlightId].filter(Boolean).join(" ");
    const score = matchScore(hay, label);
    if (score > bestScore) { bestScore = score; best = el; }
  }
  return bestScore >= 50 ? best : undefined;
}

/** Resolve a spotlight request in PortfolioManager's exact precedence: ref
 *  from the last snapshot -> live selector -> label fuzzy-match (against
 *  the snapshot, falling back to any live data-ui-label/data-spotlight in
 *  the DOM) -> curated catalog target. Returns null when nothing resolves
 *  (unknown ref/label/selector/target — spotlight_ui's tool handler turns
 *  that into an error result, never a silent no-op overlay). Pure —
 *  `snapshot` is passed in rather than re-captured, so tests exercise it
 *  without a live route. */
export function resolveSpotlightTarget(
  request: SpotlightRequest,
  snapshot: UiSnapshot | null,
): ResolvedSpotlight | null {
  if (request.ref) {
    const el = snapshot?.elements.find((e) => e.ref === request.ref);
    if (el) return { selector: el.selector, title: el.label, message: request.message };
    const selector = `[data-ui-ref="${request.ref}"]`;
    if (document.querySelector(selector)) {
      return { selector, title: request.label ?? request.ref, message: request.message };
    }
  }

  if (request.selector && document.querySelector(request.selector)) {
    return { selector: request.selector, title: request.label ?? "Here", message: request.message };
  }

  if (request.label) {
    const el = findByLabel(snapshot, request.label);
    if (el) return { selector: el.selector, title: el.label, message: request.message };

    let bestEl: Element | null = null;
    let bestScore = 0;
    for (const node of document.querySelectorAll("[data-ui-label]")) {
      const score = matchScore(node.getAttribute("data-ui-label") ?? "", request.label);
      if (score > bestScore) { bestScore = score; bestEl = node; }
    }
    if (bestEl && bestScore >= 50) {
      const ref = bestEl.getAttribute("data-ui-ref");
      return {
        selector: ref ? `[data-ui-ref="${ref}"]` : `[data-ui-label="${bestEl.getAttribute("data-ui-label")}"]`,
        title: bestEl.getAttribute("data-ui-label") ?? request.label,
        message: request.message,
      };
    }
  }

  if (request.target) {
    const meta = getSpotlightTarget(request.target);
    if (meta && document.querySelector(meta.selector)) {
      return { selector: meta.selector, title: meta.label, message: request.message };
    }
    const bySpotlightAttr = document.querySelector(`[data-spotlight="${request.target}"]`);
    if (bySpotlightAttr) {
      const ref = bySpotlightAttr.getAttribute("data-ui-ref");
      return {
        selector: ref ? `[data-ui-ref="${ref}"]` : `[data-spotlight="${request.target}"]`,
        title: bySpotlightAttr.getAttribute("data-ui-label") ?? request.label ?? request.target,
        message: request.message,
      };
    }
  }

  return null;
}

/* ────────────────────────────────────────────────────────────────────
   3. THE OVERLAY — never-hijack, verbatim from §6.6
   ──────────────────────────────────────────────────────────────────── */

const AUTO_DISMISS_MS = 3000;
let dismissTimer: ReturnType<typeof setTimeout> | null = null;
let dismissListeners: (() => void) | null = null;

function ensureOverlayEl(): HTMLElement {
  let el = document.getElementById("assistant-spotlight");
  if (!el) {
    el = document.createElement("div");
    el.id = "assistant-spotlight";
    // data-ui-chrome="assistant" — excluded from the DOM snapshot (the
    // assistant must never spotlight or narrate its own spotlight).
    el.setAttribute("data-ui-chrome", "assistant");
    el.innerHTML = '<div class="asr-ring"></div><div class="asr-pop"><div class="asr-pop-text"></div></div>';
    document.body.appendChild(el);
  }
  return el;
}

/** Tear down the overlay: clear the timer, remove the dismiss-on-any-input
 *  listeners, and hide it. Safe to call when nothing is showing. */
export function dismissSpotlight(): void {
  if (dismissTimer) { clearTimeout(dismissTimer); dismissTimer = null; }
  if (dismissListeners) { dismissListeners(); dismissListeners = null; }
  const el = document.getElementById("assistant-spotlight");
  if (el) el.classList.remove("show");
}

/** Show the spotlight overlay around `selector` with a short popover
 *  message. Returns false (no-op) if the element doesn't exist — the
 *  caller (chat.ts's ui_spotlight handler) can toast a quiet failure
 *  instead of showing a ring around nothing.
 *
 *  NEVER-HIJACK, verbatim from §6.6: this overlay traps no focus (never
 *  added to shell.ts's trapFocus/closeTopOverlay set), blocks no clicks
 *  (pointer-events:none in CSS — the highlighted control stays clickable
 *  through it), auto-dismisses after ~3s, and ANY user input — keydown,
 *  mousedown, or wheel, anywhere on the page — dismisses it instantly.
 *  transform/opacity are the only animated properties, and the CSS
 *  respects prefers-reduced-motion (app.html). */
export function showSpotlight(resolved: ResolvedSpotlight): boolean {
  const target = document.querySelector(resolved.selector) as HTMLElement | null;
  if (!target) return false;

  dismissSpotlight();
  const overlay = ensureOverlayEl();
  const rect = target.getBoundingClientRect();
  const ring = overlay.querySelector(".asr-ring") as HTMLElement;
  const pop = overlay.querySelector(".asr-pop") as HTMLElement;
  const popText = overlay.querySelector(".asr-pop-text") as HTMLElement;

  const pad = 6;
  ring.style.left = `${rect.left - pad}px`;
  ring.style.top = `${rect.top - pad}px`;
  ring.style.width = `${rect.width + pad * 2}px`;
  ring.style.height = `${rect.height + pad * 2}px`;

  popText.textContent = resolved.message ? `${resolved.title} — ${resolved.message}` : resolved.title;
  const popTop = rect.bottom + 12;
  pop.style.left = `${Math.max(8, rect.left)}px`;
  pop.style.top = `${popTop}px`;

  overlay.classList.add("show");

  const onDismiss = () => dismissSpotlight();
  document.addEventListener("keydown", onDismiss, { capture: true });
  document.addEventListener("mousedown", onDismiss, { capture: true });
  document.addEventListener("wheel", onDismiss, { capture: true, passive: true });
  dismissListeners = () => {
    document.removeEventListener("keydown", onDismiss, { capture: true });
    document.removeEventListener("mousedown", onDismiss, { capture: true });
    document.removeEventListener("wheel", onDismiss, { capture: true });
  };
  dismissTimer = setTimeout(dismissSpotlight, AUTO_DISMISS_MS);
  return true;
}

/* ────────────────────────────────────────────────────────────────────
   Ambient context frame builder (chat.ts calls this on route/step change)
   ──────────────────────────────────────────────────────────────────── */

export interface AppContext {
  route: string;
  view?: ViewId;
  step?: WizardStep;
  snapshot: UiSnapshot;
}

/** Build the full context payload chat.ts pushes as a `context` frame.
 *  `viewOverride` names an open overlay (memory/hub/adapters panel) when one
 *  is open on top of the current route — routes and views are otherwise
 *  the same "where is the user" concept from the tool's point of view. */
export function buildAppContext(route: string, viewOverride?: string | null): AppContext {
  const view = viewOverride && isViewId(viewOverride) ? viewOverride : undefined;
  const step = currentWizardStep(route) ?? undefined;
  return {
    route,
    ...(view ? { view } : {}),
    ...(step ? { step } : {}),
    snapshot: captureUiSnapshot(route),
  };
}

/** The compact one-line ambient context PortfolioManager-style "never
 *  answer blind" auto-prepend — NOT a snapshot dump. Mirrors the shape in
 *  the task brief's example: "[user is on: Quantize · step 2/4]". Pure
 *  string builder so pi-web.ts's tests can exercise the exact wire text
 *  the assistant would see; the browser never calls this directly (the
 *  server derives its own copy from the stored context — see pi-web.ts's
 *  ambientContextLine). Exported for symmetry/documentation even though
 *  chat.ts doesn't call it (kept here so the format has one home). */
export function ambientLine(ctx: { route: string; view?: string; step?: WizardStep }): string {
  const place = ctx.view ? ctx.view : (ROUTE_LABELS as Record<string, string>)[ctx.route] ?? ctx.route;
  const stepPart = ctx.step ? ` · step ${ctx.step.index + 1}/${ctx.step.count}` : "";
  return `[user is on: ${place}${stepPart}]`;
}
