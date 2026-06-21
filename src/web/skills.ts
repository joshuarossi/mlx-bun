// mlx-bun bundled skills — curated pi skills the web chat ships with.
//
// Why materialize to disk? pi loads skills by reading SKILL.md from a
// filesystem path, but mlx-bun also ships as a single `bun build --compile`
// binary where source files don't exist on disk. So each SKILL.md is
// embedded into the bundle as a text import (the same trick app.html uses)
// and written to ~/.mlx-bun/skills/<name>/SKILL.md at startup. One source of
// truth that resolves identically when run from source and from the binary —
// no build-script changes, no sidecar files.
//
// These load via DefaultResourceLoader.additionalSkillPaths even though the
// web session keeps noSkills:true: that flag only disables auto-discovery of
// the user's personal ~/.pi and project .pi skills, so the chat stays
// isolated while still getting our curated set (resource-loader.js:277).
//
// Memory is deliberately gated by vault existence. If memory is not enabled,
// we do not expose its skill at all; otherwise small local models can fixate on
// the skill description even when the user asks unrelated things like weather.
//
// To add a skill: drop a folder under ./skills/<name>/SKILL.md, add a text
// import for it, and append it to BUNDLED_SKILLS.

import { mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import webResearchMd from "./skills/web-research/SKILL.md" with { type: "text" };
import memoryMd from "./skills/memory/SKILL.md" with { type: "text" };

interface BundledSkill {
  /** Directory name under the skills root; should match the SKILL.md `name`. */
  name: string;
  /** Raw SKILL.md contents, embedded at build time. */
  md: string;
}

const BUNDLED_SKILLS: readonly BundledSkill[] = [
  { name: "web-research", md: webResearchMd },
  { name: "memory", md: memoryMd },
];

export interface BundledSkillOptions {
  /** Include the web-research workflow skill. Default false: tool schemas are enough, and small local models can over-apply workflow skills. */
  includeWebResearch?: boolean;
  /** Include the personal-memory skill. Default true for backward compatibility. */
  includeMemory?: boolean;
}

/** Where the bundled skills are written; also pi's per-session scratch root. */
export function bundledSkillsRoot(): string {
  return join(homedir(), ".mlx-bun", "skills");
}

/** Memoize: the embedded content can't change within a process run. */
const materialized = new Set<string>();

/**
 * Write the embedded skills to disk (overwriting, so updates propagate) and
 * return the root directory to pass as a single additionalSkillPaths entry.
 * pi scans it for per-skill SKILL.md files. Runs its disk writes once per
 * process even when called per browser connection.
 */
function selectedSkills(opts: BundledSkillOptions = {}): readonly BundledSkill[] {
  const includeMemory = opts.includeMemory ?? true;
  const includeWebResearch = opts.includeWebResearch ?? false;
  return BUNDLED_SKILLS.filter((skill) => {
    if (!includeMemory && skill.name === "memory") return false;
    if (!includeWebResearch && skill.name === "web-research") return false;
    return true;
  });
}

/**
 * Materialize selected bundled skills and return exact skill directories. Use
 * these paths in DefaultResourceLoader.additionalSkillPaths. Returning exact
 * directories (rather than the shared root) prevents an old on-disk memory
 * skill from being discovered when memory is disabled for the current session.
 */
export function materializeBundledSkillPaths(opts: BundledSkillOptions = {}): string[] {
  const root = bundledSkillsRoot();
  const paths: string[] = [];
  for (const skill of selectedSkills(opts)) {
    const dir = join(root, skill.name);
    if (!materialized.has(skill.name)) {
      mkdirSync(dir, { recursive: true });
      writeFileSync(join(dir, "SKILL.md"), skill.md);
      materialized.add(skill.name);
    }
    paths.push(dir);
  }
  return paths;
}

/** Backward-compatible root materializer for older call sites. Prefer materializeBundledSkillPaths(). */
export function materializeBundledSkills(): string {
  materializeBundledSkillPaths({ includeMemory: true, includeWebResearch: true });
  return bundledSkillsRoot();
}
