import { createMemoryTools, isMemoryEnabled, memoryIndexHint, MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES, type MemoryToolOptions } from "./tools";
import { materializeMemorySkill } from "./skills";

/** Composition supplies both paths. Missing vaults expose no tools or skill and
 * create no files; each session checks again so explicit initialization is seen. */
export async function createMemorySurface(root: string, skillsRoot: string, options: MemoryToolOptions = {}) {
  if (!await isMemoryEnabled(root)) return undefined;
  return {
    readOnly: true as const,
    toolNames: [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES],
    customTools: createMemoryTools(root, options),
    skillPaths: [materializeMemorySkill(skillsRoot)],
    hint: await memoryIndexHint(root),
  };
}
