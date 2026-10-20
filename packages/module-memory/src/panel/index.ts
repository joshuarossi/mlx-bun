// `<mlx-memory-panel>`: the memory overlay as a companion panel. The shell mounts it at boot without a route or tab, and
// it stays attached beside the chat. It renders into the light DOM (the chat's sidebar entry, consent card and tool
// chips live in the chat panel's markup), injects its stylesheet into the page once, and reaches the module's routes
// through `connection.apiBase`. The host calls `attachChat()` once the chat's markup exists, `open(article)`, `close()`,
// `isOpen()`, and `toolCard(parent, tool, args)` to draw a memory tool call.
import { injectStyles } from "@mlx-bun/web-kit";
import type { PanelConnection } from "../protocol";
import { initMemoryPanel, attachChat, openMemPanel, closeMemPanel, isMemPanelOpen, isMemoryToolName, memoryToolChip, setApiBase, type MemChipHandle } from "./memory";
import { STYLE, TEMPLATE } from "./template";
export * from "./memory";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const BaseElement = (typeof HTMLElement === "undefined" ? class {} : HTMLElement) as typeof HTMLElement;

export class MemoryPanel extends BaseElement {
  connection?: PanelConnection;
  connectedCallback(): void {
    injectStyles("mlx-memory-panel-style", STYLE);
    if (!this.querySelector("#mem-overlay")) this.innerHTML = TEMPLATE;
    setApiBase(this.connection?.apiBase ?? "/api/memory");
    initMemoryPanel();
  }
  attachChat(): void { attachChat(); }
  open(article?: string): Promise<void> { return openMemPanel(article); }
  close(): void { closeMemPanel(); }
  isOpen(): boolean { return isMemPanelOpen(); }
  toolCard(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null {
    return isMemoryToolName(tool) ? memoryToolChip(parent, tool, args) : null;
  }
}
if (typeof customElements !== "undefined" && !customElements.get("mlx-memory-panel")) customElements.define("mlx-memory-panel", MemoryPanel);
