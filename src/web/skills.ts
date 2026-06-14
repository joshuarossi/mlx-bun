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
// To add a skill: drop a folder under ./skills/<name>/SKILL.md, add a text
// import for it, and append it to BUNDLED_SKILLS.

import { mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import webResearchMd from "./skills/web-research/SKILL.md" with { type: "text" };

interface BundledSkill {
  /** Directory name under the skills root; should match the SKILL.md `name`. */
  name: string;
  /** Raw SKILL.md contents, embedded at build time. */
  md: string;
}

const BUNDLED_SKILLS: readonly BundledSkill[] = [
  { name: "web-research", md: webResearchMd },
];

/** Where the bundled skills are written; also pi's per-session scratch root. */
export function bundledSkillsRoot(): string {
  return join(homedir(), ".mlx-bun", "skills");
}

/** Memoize: the embedded content can't change within a process run. */
let materialized = false;

/**
 * Write the embedded skills to disk (overwriting, so updates propagate) and
 * return the root directory to pass as a single additionalSkillPaths entry.
 * pi scans it for per-skill SKILL.md files. Runs its disk writes once per
 * process even when called per browser connection.
 */
export function materializeBundledSkills(): string {
  const root = bundledSkillsRoot();
  if (materialized) return root;
  for (const skill of BUNDLED_SKILLS) {
    const dir = join(root, skill.name);
    mkdirSync(dir, { recursive: true });
    writeFileSync(join(dir, "SKILL.md"), skill.md);
  }
  materialized = true;
  return root;
}
