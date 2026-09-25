import { defineTool, type ToolDefinition } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { APP_ROUTE_IDS, type AppRouteId, type AppUiContext, type ServerMessage } from "./protocol";
import { resolveAppRoute } from "./policy";

function appAwareTextResult(text: string, details: unknown = {}): { content: [{ type: "text"; text: string }]; details: unknown } {
  return { content: [{ type: "text", text }], details };
}

/** Build the three app-aware tools for one connection. `getContext` reads
 *  the connection's currentAppContext (last `context` ClientMessage, or
 *  null before the first one arrives); `notify` sends a ServerMessage
 *  (ui_navigate/ui_spotlight) to that same browser tab. Pure enough to
 *  unit test the tool -> frame mapping via a fake notify collecting sent
 *  frames (tests/chat-policy.test.ts). */
export function createAppAwareTools(
  getContext: () => AppUiContext | null,
  notify: (msg: ServerMessage) => void,
): ToolDefinition[] {
  const getCurrentAppContext = defineTool({
    name: "get_current_app_context",
    label: "Get Current App Context",
    description:
      "Returns the current web-app UI context: route, view, wizard step (if on one), and a uiSnapshot of visible interactive elements (ref, label, selector, spotlightId). Call this before spotlight_ui to pick the correct ref, label, or target — do not guess selectors blind.",
    parameters: Type.Object({}),
    execute: async () => {
      const ctx = getContext();
      if (!ctx) {
        return appAwareTextResult(
          "No app context received yet — the browser hasn't reported its current view. Ask the user what page they're on, or proceed without UI tools.",
        );
      }
      return appAwareTextResult(JSON.stringify(ctx, null, 2), { context: ctx });
    },
  });

  const navigateApp = defineTool({
    name: "navigate_app",
    label: "Navigate App",
    description:
      "Navigate the user's browser to a different page in the app. Use when they ask to be taken somewhere (e.g. \"take me to Quantize\", \"open the fine-tune wizard\"). Pass route or page as one of: chat, quantize, finetune, dataset, status (or \"#/quantize\"-style). Reversible and never needs approval. Does not highlight a specific control — use spotlight_ui separately for that.",
    parameters: Type.Object({
      route: Type.Optional(Type.String({ description: "chat | quantize | finetune | dataset | status (or #/quantize)" })),
      page: Type.Optional(Type.String({ description: "Same as route — alternate param name" })),
    }),
    execute: async (_id, params) => {
      const resolved = resolveAppRoute(params.route ?? params.page ?? "");
      if (!resolved) {
        return {
          ...appAwareTextResult(`Unknown route. Valid routes: ${APP_ROUTE_IDS.join(", ")}.`),
          isError: true,
        };
      }
      notify({ type: "ui_navigate", route: resolved });
      return appAwareTextResult(
        `Navigating the user to ${resolved}. They can see the page now — use spotlight_ui if you need to point at a specific control.`,
        { route: resolved },
      );
    },
  });

  const spotlightUi = defineTool({
    name: "spotlight_ui",
    label: "Spotlight UI",
    description:
      "Highlight a visible UI control with a brief, auto-dismissing spotlight (never blocks the user — they can keep working through it). Call get_current_app_context first and prefer ref from its uiSnapshot.elements; or pass label (visible text, e.g. \"Source model\"); or selector; or target (a curated catalog id, e.g. hub-browse, quantize-source). Optional route navigates there first. Optional message is a short hint shown in the popover.",
    parameters: Type.Object({
      ref: Type.Optional(Type.String({ description: "Element ref from uiSnapshot.elements[].ref (preferred)" })),
      label: Type.Optional(Type.String({ description: "Visible label/text to match, e.g. Source model, New chat" })),
      selector: Type.Optional(Type.String({ description: "CSS selector, when ref/label are unknown" })),
      target: Type.Optional(Type.String({ description: "Curated catalog id, e.g. hub-browse, quantize-source, sampling-pill" })),
      route: Type.Optional(Type.String({ description: "Navigate to this route first (chat, quantize, finetune, dataset, status)" })),
      message: Type.Optional(Type.String({ description: "Short hint shown in the spotlight popover" })),
    }),
    execute: async (_id, params) => {
      const hasLocator = !!params.ref?.trim() || !!params.label?.trim() || !!params.selector?.trim() || !!params.target?.trim();
      if (!hasLocator) {
        return { ...appAwareTextResult("Provide at least one of: ref (from uiSnapshot), label, selector, or target."), isError: true };
      }
      let route: AppRouteId | undefined;
      if (params.route) {
        route = resolveAppRoute(params.route) ?? undefined;
        if (!route) {
          return { ...appAwareTextResult(`Unknown route "${params.route}". Valid routes: ${APP_ROUTE_IDS.join(", ")}.`), isError: true };
        }
      }
      notify({
        type: "ui_spotlight",
        ref: params.ref, label: params.label, selector: params.selector, target: params.target,
        route, message: params.message,
      });
      const desc = params.ref ?? params.label ?? params.selector ?? params.target ?? "element";
      return appAwareTextResult(
        `Highlighting ${desc}${params.message ? `: ${params.message}` : ""}. The spotlight fades on its own in a few seconds.`,
        { ...params, route },
      );
    },
  });

  return [getCurrentAppContext, navigateApp, spotlightUi];
}
