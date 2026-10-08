// App host adapter for the installed memory panel. Its controller, markup and article renderer belong to the module.
import { setMemPanelClose } from "./shell";
type MemChipHandle = { wrap: HTMLElement; setResult(result: unknown): void };
type MemoryPanel = HTMLElement & { attachChat(): void; open(article?: string): Promise<void>; close(): void; isOpen(): boolean; toolCard(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null };
const panel = () => document.querySelector<MemoryPanel>("mlx-memory-panel");
export function registerMemoryOverlay(): void { setMemPanelClose(() => panel()?.close()); }
export function initMemoryPanel(): void { panel()?.attachChat(); registerMemoryOverlay(); }
export function openMemPanel(article?: string): Promise<void> { return panel()?.open(article) ?? Promise.resolve(); }
export function memoryToolChip(parent: HTMLElement, tool: string, args: unknown): MemChipHandle | null { return panel()?.toolCard(parent, tool, args) ?? null; }
