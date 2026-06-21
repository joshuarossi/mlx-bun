#!/usr/bin/env bun
// Static + optional live eval for the pi memory relevance policy.
//
// Default mode is static: it verifies the shared pi surface does not expose
// memory when disabled and that enabled-memory wording names the negative
// cases (weather/current facts/generic coding). Live mode can be layered on
// later against a running server; this file is intentionally safe to run in CI.

import { readFileSync } from "node:fs";
import { join } from "node:path";
import { buildPiAgentSurface } from "../src/pi-session";
import { buildTerminalSystemPrompt } from "../src/pi-terminal";
import { buildWebChatSystemPrompt } from "../src/pi-web";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/memory/tools";

interface Check { name: string; ok: boolean; detail?: string }
const checks: Check[] = [];
const check = (name: string, ok: boolean, detail?: string) => checks.push({ name, ok, detail });

const off = await buildPiAgentSurface({ memory: "off" });
check("memory-off: no memory tools", !MEMORY_TOOL_NAMES.some((t) => off.tools.includes(t)));
check("memory-off: no reference tools", !REFERENCE_TOOL_NAMES.some((t) => off.tools.includes(t)));
check("memory-off: no memory skill", !off.skillPaths.some((p) => p.endsWith("/memory")));

const on = await buildPiAgentSurface({ memory: "on" });
check("memory-on: memory tools present", MEMORY_TOOL_NAMES.every((t) => on.tools.includes(t)));
check("memory-on: reference tools present", REFERENCE_TOOL_NAMES.every((t) => on.tools.includes(t)));
check("memory-on: memory skill present", on.skillPaths.some((p) => p.endsWith("/memory")));

const skill = readFileSync(join(import.meta.dir, "..", "src", "web", "skills", "memory", "SKILL.md"), "utf8");
for (const phrase of ["weather", "current public facts", "generic web research", "ordinary coding/file tasks", "performative recall"]) {
  check(`memory skill names non-memory case: ${phrase}`, skill.includes(phrase));
}

const terminal = buildTerminalSystemPrompt("test-model") + on.memoryHint;
const web = buildWebChatSystemPrompt(false) + on.memoryHint;
for (const [name, prompt] of [["terminal", terminal], ["web", web]] as const) {
  check(`${name}: base prompt does not mention personal memory`, !/personal memory is on/i.test(prompt));
  check(`${name}: ordinary social conversation is answered naturally`, /ordinary social conversation/i.test(prompt) && /answer naturally yourself/i.test(prompt));
  check(`${name}: real-world questions are tool-first`, /real-world facts|current events|recommendations/i.test(prompt) && /web_search\/web_fetch|weather/i.test(prompt));
}
if (on.memoryHint) {
  check("memory hint says memory is scoped", /user-specific continuity|personal context/.test(on.memoryHint));
  check("memory hint excludes weather", /weather/.test(on.memoryHint));
}

const failures = checks.filter((c) => !c.ok);
for (const c of checks) console.log(`${c.ok ? "PASS" : "FAIL"} ${c.name}${c.detail ? ` — ${c.detail}` : ""}`);
if (failures.length) {
  console.error(`\n${failures.length} memory-fixation check(s) failed.`);
  process.exit(1);
}
console.log("\nAll memory-fixation checks passed.");
