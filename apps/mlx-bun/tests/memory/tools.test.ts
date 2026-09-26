import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createMemoryTools, memoryIndexHint, MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../../src/memory/tools";
import { createMemorySurface } from "../../src/memory/surface";
import { articlesInCategory, buildMemoryIndex, neighbors, resetMemoryIndexCache, resolveName, serializeMemoryIndex } from "../../src/memory/query";

const roots: string[] = [];
afterEach(() => { roots.splice(0).forEach(root => rmSync(root, { recursive: true, force: true })); resetMemoryIndexCache(); });
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-memory-tools-")); roots.push(root); return root; }
function vault() {
  const root = temporary();
  mkdirSync(join(root, "articles")); mkdirSync(join(root, "Reference"));
  writeFileSync(join(root, "articles", "Orion_Camera.md"), `# Orion Camera

\`\`\`info
type: camera
kind: thing
aliases: Orion X
mount: [[L-Mount]]
\`\`\`

Categories: [[Category:Cameras]]

Orion is my travel camera.

## Verdict

Keep the Orion for travel; the battery lasts all day.

## See also

[[L-Mount]]
`);
  writeFileSync(join(root, "articles", "L-Mount.md"), "# L-Mount\n\nA lens mount used by [[Orion Camera]].\n\n## Lenses\n\nUse the compact prime.\n");
  writeFileSync(join(root, "Reference", "Guide.md"), "# Guide\n\nOrion reference instructions.\n");
  return root;
}
async function call(root: string, name: string, args: Record<string, unknown> = {}) {
  const tool = createMemoryTools(root).find(tool => tool.name === name)!;
  const result = await tool.execute("test", args, undefined, undefined, undefined as never);
  return result.content.map(part => "text" in part ? part.text : "").join("");
}

test("memory lookup, small reads, graph traversal and references stay bound to the supplied vault", async () => {
  const root = vault();
  expect(createMemoryTools(root).map(tool => tool.name)).toEqual([...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]);
  expect(await call(root, "memory_resolve", { surface: "Orion X" })).toContain("stem: Orion_Camera");
  expect(await call(root, "memory_infobox", { stem: "Orion_Camera" })).toContain("mount: [[L-Mount]]");
  expect(await call(root, "memory_category", { category: "Cameras" })).toContain("Orion_Camera");
  const toc = await call(root, "memory_read", { stem: "Orion_Camera" });
  expect(toc).toContain("#verdict"); expect(toc).not.toContain("battery lasts");
  expect(await call(root, "memory_section", { stem: "Orion_Camera", anchor: "verdict" })).toContain("battery lasts all day");
  expect(await call(root, "memory_read", { stem: "Orion_Camera", force: true })).toContain("battery lasts all day");
  expect(await call(root, "memory_links", { stem: "Orion_Camera" })).toContain("L-Mount");
  expect(await call(root, "memory_search", { query: "Orion" })).toContain("Orion_Camera");
  expect(await call(root, "memory_search", { query: "Orion" })).not.toContain("Reference/Guide");
  expect(await call(root, "reference_search", { query: "Orion" })).toContain("Reference/Guide");
  expect(await call(root, "reference_read", { article: "Guide" })).toContain("reference instructions");
  expect(await call(root, "reference_list")).toContain("Reference/Guide");
  expect(await call(root, "memory_read", { stem: "Reference/Guide" })).toContain("Use reference_read");
  expect(await call(root, "memory_read", { stem: "../outside" })).not.toContain("battery lasts");
  const other = temporary(); mkdirSync(join(other, "articles"));
  expect(await call(other, "memory_list")).toContain("no personal articles");
  expect(await call(root, "memory_list")).toContain("Orion_Camera");
});

test("memory status advertises on-demand synthesis and reports the injected nightly schedule state", async () => {
  const root = vault();
  const plistPath = join(root, "com.mlx-bun.memory.plist"), note = "the job runs mlx-bun memory synthesize and needs a serving mlx-bun (mlx-bun serve) at that time";
  const states = [
    { installed: false, plistPath, loaded: false, at: null, note },
    { installed: true, plistPath, loaded: true, at: { hour: 3, minute: 0 }, note },
    { installed: true, plistPath, loaded: false, at: { hour: 22, minute: 5 }, note },
    { installed: true, plistPath, loaded: true, at: null, note },
  ];
  let probes = 0;
  const tool = createMemoryTools(root, { schedule: async () => { probes++; return states[Math.min(probes, states.length) - 1]!; } }).find(tool => tool.name === "memory_status")!;
  expect(tool.description).toContain("nightly schedule state");
  const status = async () => (await tool.execute("test", {}, undefined, undefined, undefined as never)).content.map(part => "text" in part ? part.text : "").join("");
  const first = await status();
  expect(first).toContain(`- vault: ${root}`);
  expect(first).toContain("- articles: 2");
  expect(first).toContain("- synthesis: available — `mlx-bun memory synthesize` runs the full local pipeline (conversations → articles) through a serving mlx-bun");
  expect(first).toContain("- nightly: not scheduled — `mlx-bun memory schedule` installs the launchd job");
  expect(first).not.toContain("unavailable during migration");
  expect(await status()).toContain(`- nightly: scheduled at 03:00 — ${note}`);
  expect(await status()).toContain(`- nightly: installed but not loaded at 22:05 — ${note}`);
  expect(await status()).toContain(`- nightly: scheduled — ${note}`);
  expect(probes).toBe(4);
  expect(await memoryIndexHint(root)).toContain("2 articles plus 1 read-only");
});

test("missing memory exposes nothing and enabled memory materializes only into each injected skill directory", async () => {
  const root = temporary(), missing = join(root, "missing"), skills = join(root, "skills");
  expect(await createMemorySurface(missing, skills)).toBeUndefined();
  expect(existsSync(missing)).toBe(false); expect(existsSync(skills)).toBe(false);
  const actual = vault();
  const surface = (await createMemorySurface(actual, skills))!;
  expect(surface.customTools.map(tool => tool.name)).toEqual(surface.toolNames);
  expect(surface.skillPaths).toEqual([join(skills, "memory")]);
  const content = readFileSync(join(skills, "memory", "SKILL.md"), "utf8");
  expect(content).toContain("name: memory"); expect(content).not.toContain("mlx-bun memory init");
  const other = join(root, "other-skills");
  expect((await createMemorySurface(actual, other))!.skillPaths).toEqual([join(other, "memory")]);
  expect(readFileSync(join(other, "memory", "SKILL.md"), "utf8")).toBe(content);
});

test("deterministic name and link index is equivalent warm and cold without a database", () => {
  const root = vault();
  const first = buildMemoryIndex(root), warm = buildMemoryIndex(root);
  expect(serializeMemoryIndex(warm)).toBe(serializeMemoryIndex(first)); expect(warm.parsed).toEqual([]);
  expect(resolveName(first, "the Orion Camera")).toBe("Orion_Camera");
  expect(resolveName(first, "Camera")).toBe("Orion_Camera");
  expect(resolveName(first, "Theory")).toBeNull();
  expect(articlesInCategory(first, "Cameras")).toContain("Orion_Camera");
  expect(neighbors(first, "L-Mount").inbound).toContain("Orion_Camera");
});
