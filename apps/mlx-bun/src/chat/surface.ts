import type { ToolDefinition } from "@earendil-works/pi-coding-agent";
import { createWebTools } from "./web-tools";

/** Optional read-only memory capabilities supplied by the application's memory owner. */
export interface MemorySurface {
  /** The memory owner attests that every advertised tool only reads state. */
  readOnly: true;
  toolNames: readonly string[];
  customTools: readonly ToolDefinition[];
  skillPaths: readonly string[];
  hint: string;
}

/** Assemble definitions without discovering stores, materializing skills, or widening access. */
export function buildPiAgentSurface(memory?: MemorySurface) {
  if (memory && memory.readOnly !== true) throw new Error("Memory tools must be explicitly read-only");
  return {
    memoryEnabled: memory !== undefined,
    memoryToolNames: [...(memory?.toolNames ?? [])],
    readOnlyToolNames: [...(memory?.toolNames ?? [])],
    customTools: [...createWebTools(), ...(memory?.customTools ?? [])],
    skillPaths: [...(memory?.skillPaths ?? [])],
    memoryHint: memory?.hint ?? "",
  };
}
