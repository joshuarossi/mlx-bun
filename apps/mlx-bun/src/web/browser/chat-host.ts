// The app's side of the chat panel (`@mlx-bun/module-chat`'s `<mlx-chat-panel>`): what lives beside the chat on this
// page and is wired through the panel's `host` property. Memory's provenance chips replace the default tool card for
// memory tools; the memory entry and consent card in the sidebar are attached once the panel's markup exists; the
// agent-tools settings render in the settings dialog. The panel knows none of this: a host without a memory panel or a
// settings dialog leaves the properties out.
import { initMemoryPanel, isMemoryToolName, memoryToolChip } from "./memory-panel";
import { renderCodingToolsState, renderToolApprovals, storedCodingToolsPreference } from "./shell";

export const chatHost = {
  mounted() { initMemoryPanel(); },
  toolCard(parent: HTMLElement, tool: string, args: unknown) { return isMemoryToolName(tool || "") ? memoryToolChip(parent, tool, args) : null; },
  settings: {
    codingToolsPreference: storedCodingToolsPreference,
    codingTools: renderCodingToolsState,
    approvals: renderToolApprovals,
  },
};
