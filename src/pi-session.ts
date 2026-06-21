// Shared pi front-door assembly for mlx-bun's embedded web + terminal agents.
//
// This is the single place that decides which custom tools and bundled skills
// are visible to pi. Keeping that policy here prevents the browser and TUI from
// drifting — especially for personal memory, whose prompt surface must be
// relevant-but-not-dominant.

import type { ToolDefinition } from "@earendil-works/pi-coding-agent";
import { createWebTools, WEB_TOOL_NAMES } from "./web-tools";
import { materializeBundledSkillPaths } from "./web/skills";
import {
  createMemoryTools,
  MEMORY_TOOL_NAMES,
  memoryIndexHint,
  isMemoryEnabled,
  createReferenceTools,
  REFERENCE_TOOL_NAMES,
} from "./memory/tools";

/** Built-in pi coding tools plus mlx-bun's non-mutating web tools. */
export const PI_BASE_TOOL_NAMES = ["read", "bash", "edit", "write", "grep", "find", "ls", ...WEB_TOOL_NAMES] as const;

export interface PiAgentSurfaceOptions {
  /** Force memory on/off for tests. Default: auto-detect vault existence. */
  memory?: "auto" | "on" | "off";
  /** Include web_search/web_fetch/weather. Default true. */
  webTools?: boolean;
  /** Include read/bash/edit/write/grep/find/ls. Default true. */
  codingTools?: boolean;
}

export interface PiAgentSurface {
  memoryEnabled: boolean;
  /** Tool allowlist to pass to createAgentSession/createAgentSessionFromServices. */
  tools: string[];
  /** Custom tools to pass to pi. Built-ins are selected by name in `tools`. */
  customTools: ToolDefinition[];
  /** Skill paths for DefaultResourceLoader.additionalSkillPaths. */
  skillPaths: string[];
  /** Short prompt addendum. Empty unless memory is enabled. */
  memoryHint: string;
}

async function resolveMemoryEnabled(mode: PiAgentSurfaceOptions["memory"]): Promise<boolean> {
  if (mode === "on") return true;
  if (mode === "off") return false;
  return isMemoryEnabled();
}

/**
 * Build the shared tool + skill surface for both pi front doors.
 *
 * Memory policy: if the user enabled memory (vault exists), memory is available.
 * It is still a scoped retrieval capability, not a default first step for every
 * prompt. If memory is absent, no memory skill/tool schemas are exposed at all.
 */
export async function buildPiAgentSurface(opts: PiAgentSurfaceOptions = {}): Promise<PiAgentSurface> {
  const memoryEnabled = await resolveMemoryEnabled(opts.memory ?? "auto");
  const includeWeb = opts.webTools ?? true;
  const includeCoding = opts.codingTools ?? true;

  const tools: string[] = [];
  if (includeCoding) tools.push("read", "bash", "edit", "write", "grep", "find", "ls");
  const customTools: ToolDefinition[] = [];
  if (includeWeb) {
    tools.push(...WEB_TOOL_NAMES);
    customTools.push(...createWebTools());
  }
  if (memoryEnabled) {
    tools.push(...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES);
    customTools.push(...createMemoryTools(), ...createReferenceTools());
  }

  return {
    memoryEnabled,
    tools,
    customTools,
    skillPaths: materializeBundledSkillPaths({ includeMemory: memoryEnabled }),
    memoryHint: memoryEnabled ? await memoryIndexHint() : "",
  };
}
