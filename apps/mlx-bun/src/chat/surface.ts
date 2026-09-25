import type { ToolDefinition } from "@earendil-works/pi-coding-agent";
import { createWebTools } from "./web-tools";

/** Optional read-only memory capabilities supplied by the application's memory owner. */
export interface MemorySurface {
  toolNames: readonly string[];
  customTools: readonly ToolDefinition[];
  skillPaths: readonly string[];
  hint: string;
}

/** Assemble definitions without discovering stores, materializing skills, or widening access. */
export function buildPiAgentSurface(memory?: MemorySurface) {
  return {
    memoryEnabled: memory !== undefined,
    memoryToolNames: [...(memory?.toolNames ?? [])],
    customTools: [...createWebTools(), ...(memory?.customTools ?? [])],
    skillPaths: [...(memory?.skillPaths ?? [])],
    memoryHint: memory?.hint ?? "",
  };
}
