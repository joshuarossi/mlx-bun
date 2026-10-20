// `<mlx-memory-panel>`: the memory overlay as a companion panel. The shell mounts it at boot without a route or tab, and
// it stays attached beside the chat. It renders into the light DOM (the sidebar entry, consent card and greeting chips
// it fills are slots in the chat's markup, which the host hands it), injects its stylesheet into the page once, reaches
// the module's routes through `connection.apiBase` and notifies through `connection.ui.notify`. The host calls
// `attachChat(slots)` with the chat's slots once its markup exists, `open(article)`, `close()`, `isOpen()`, and
// `toolCard(parent, tool, args)` to draw a memory tool call.
import { injectStyles } from "@mlx-bun/web-kit";
import type { PanelConnection } from "../protocol";
import { initMemoryPanel, attachChat, openMemPanel, closeMemPanel, isMemPanelOpen, isMemoryToolName, memoryToolChip, setConnection, type ChatSlots, type MemChipHandle } from "./memory";
import { STYLE, TEMPLATE } from "./template";
export * from "./memory";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const BaseElement = (typeof HTMLElement === "undefined" ? class {} : HTMLElement) as typeof HTMLElement;

export class MemoryPanel extends BaseElement {
  connection?: PanelConnection;
  connectedCallback(): void {
    injectStyles("mlx-memory-panel-style", STYLE);
    if (!this.querySelector("#mem-overlay")) this.innerHTML = TEMPLATE;
    setConnection(this.connection ?? { apiBase: "/api/memory", eventsUrl: "" });
    initMemoryPanel();
  }
  attachChat(slots: ChatSlots): void { attachChat(slots); }
  open(article?: string): Promise<void> { return openMemPanel(article); }
  close(): void { closeMemPanel(); }
  isOpen(): boolean { return isMemPanelOpen(); }
  toolCard(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null {
    return isMemoryToolName(tool) ? memoryToolChip(parent, tool, args) : null;
  }
}
if (typeof customElements !== "undefined" && !customElements.get("mlx-memory-panel")) customElements.define("mlx-memory-panel", MemoryPanel);
