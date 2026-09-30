// Memory's contribution to chat, until memory becomes a module of its own (PLAN, "Split the app into
// modules"): its read-only tools (`chat.tool`) and the prompt hint and skill that go with them
// (`chat.guidance`), registered through the registry so the chat module never imports memory. Both
// are offered only while the vault exists, checked when each chat session is built, so a vault
// created after startup is seen by the next chat.
import type { AppModule, ChatToolContribution } from "@mlx-bun/app-core";
import { materializeMemorySkill } from "./skills";
import { createMemoryTools, isMemoryEnabled, memoryIndexHint, type MemoryToolOptions } from "./tools";

export interface MemoryChatPaths {
  /** The vault root. */
  vault: string;
  /** Where the bundled memory skill is materialized for Pi (its exact directory is returned to the session). */
  skills: string;
}

/** The vault's tools as chat contributions: the same names, schemas and text results, each run with the turn's abort signal. */
export function memoryChatTools(paths: MemoryChatPaths, options: MemoryToolOptions = {}): ChatToolContribution[] {
  const enabled = () => isMemoryEnabled(paths.vault);
  return createMemoryTools(paths.vault, options).map(tool => ({
    name: tool.name, label: tool.label, description: tool.description,
    parameters: tool.parameters as unknown as Readonly<Record<string, unknown>>, readOnly: true as const, available: enabled,
    async run(args, signal) {
      const result = await tool.execute(`memory-${tool.name}`, args as never, signal, undefined, undefined as never);
      return result.content.map(part => part.type === "text" ? part.text : "").join("");
    },
  }));
}

export function createMemoryChatModule(paths: MemoryChatPaths, options: MemoryToolOptions = {}): AppModule<"registry"> {
  return {
    id: "memory", title: "Memory", summary: "The memory vault's read-only tools, prompt hint and skill for chat.",
    requires: ["registry"], contributes: ["chat.tool", "chat.guidance"],
    activate({ services }) {
      for (const tool of memoryChatTools(paths, options)) services.registry.register("chat.tool", tool);
      services.registry.register("chat.guidance", {
        available: () => isMemoryEnabled(paths.vault),
        hint: () => memoryIndexHint(paths.vault),
        skillPath: () => materializeMemorySkill(paths.skills),
      });
      return {};
    },
  };
}
