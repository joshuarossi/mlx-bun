import type { PanelConnection } from "../protocol";
import { initMemoryPanel, attachChat, openMemPanel, closeMemPanel, isMemPanelOpen, isMemoryToolName, memoryToolChip, type MemChipHandle } from "./memory";
import { setApiBase } from "./dom";
import { STYLE, TEMPLATE } from "./template";
export * from "./memory";
/** The existing Memory overlay; kept attached alongside chat, without a navigation page. */
const BaseElement = (typeof HTMLElement === "undefined" ? class {} : HTMLElement) as typeof HTMLElement;
export class MemoryPanel extends BaseElement {
  connection?: PanelConnection;
  connectedCallback(): void {
    if (!this.querySelector("#mem-overlay")) this.innerHTML = `<style>${STYLE}</style>${TEMPLATE}`;
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
