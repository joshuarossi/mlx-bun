// The app's side of the chat panel (`@mlx-bun/module-chat`'s `<mlx-chat-panel>`): what lives beside the chat on this
// page and is wired through the panel's `host` property. Memory's provenance chips replace the default tool card for
// memory tools; memory takes the chat's companion slots (the sidebar entry, the consent card, the greeting chips) once
// the panel's markup exists; the agent-tools settings render in the settings dialog; notices are the shell's toasts;
// and `app` tells the assistant this page's routes, the memory drawer as its view, and the wizards' steps. The panel
// knows none of this: a host without a memory panel, a settings dialog or pages leaves the properties out.
import { HOST_EVENTS, listen, onHostEvent } from "@mlx-bun/web-kit";
import { toast } from "@mlx-bun/web-shell";
import type { ChatPanelApi } from "./app-shell/chat-panel";
import { renderCodingToolsState, renderToolApprovals, storedCodingToolsPreference } from "./app-shell/settings";
import { currentRoute } from "./app-shell/shell";
import { initMemoryPanel, isMemoryOpen, memoryToolChip, onMemoryToggle } from "./memory-panel";

/** The wizard each route mounts; the element reads its own step rail. */
const WIZARDS: Readonly<Record<string, string>> = { quantize: "mlx-quantize-panel", finetune: "mlx-train-panel", dataset: "mlx-datasets-panel" };
type WizardStep = { index: number; count: number; label: string };
type Wizard = HTMLElement & { currentStep?(): WizardStep | null };

export const chatHost = {
  mounted(panel: ChatPanelApi) { initMemoryPanel(panel.companionSlots()); },
  toolCard(parent: HTMLElement, tool: string, args: unknown) { return memoryToolChip(parent, tool || "", args); },
  notify: toast,
  drawerChanged(open: boolean) { document.getElementById("chat-hamburger")?.setAttribute("aria-expanded", String(open)); },
  app: {
    currentRoute,
    navigate(route: string) { location.hash = "#/" + route; },
    currentView: (): string | null => isMemoryOpen() ? "memory-panel" : null,
    wizardStep(): WizardStep | null {
      const tag = WIZARDS[currentRoute()];
      return (tag ? document.querySelector<Wizard>(tag)?.currentStep?.() : null) ?? null;
    },
    /** The route (the address), a panel's visible state (a wizard's step) and the memory drawer. */
    onChange(listener: () => void): () => void {
      const removers = [listen(window, "hashchange", listener), onHostEvent(HOST_EVENTS.panelChanged, listener, document), onMemoryToggle(listener)];
      return () => { for (const remove of removers) remove(); };
    },
  },
  settings: {
    codingToolsPreference: storedCodingToolsPreference,
    codingTools: renderCodingToolsState,
    approvals: renderToolApprovals,
  },
};
