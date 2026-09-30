import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const materialized = new Set<string>();

/** Pi reads skills from disk. Materialize only the bundled memory skill under
 * the composition-owned directory; return its exact path, not a discovery root. */
export function materializeMemorySkill(skillsRoot: string): string {
  const directory = resolve(skillsRoot, "memory");
  if (!materialized.has(directory)) {
    mkdirSync(directory, { recursive: true });
    writeFileSync(join(directory, "SKILL.md"), readFileSync(new URL("./skills/memory/SKILL.md", import.meta.url), "utf8"));
    materialized.add(directory);
  }
  return directory;
}
