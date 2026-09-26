import { afterEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

// `mlx-bun memory`: main's verb over a temporary vault and HOME. Read
// subcommands touch only the vault; synthesis reaches the model through a
// serving mlx-bun, so a run that needs the model fails clearly without one.

const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(import.meta.dir, "../src/cli/main.ts");
const homes: string[] = [];
afterEach(() => { for (const home of homes.splice(0)) rmSync(home, { recursive: true, force: true }); });

function home(seed = true): { home: string; vault: string } {
  const root = mkdtempSync(join(tmpdir(), "mlx-memory-cli-"));
  homes.push(root);
  const vault = join(root, "vault");
  if (seed) {
    mkdirSync(join(vault, "articles"), { recursive: true });
    mkdirSync(join(vault, "Reference"), { recursive: true });
    writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\n\nAlpha is a test article about lenses.\n\n## Verdict\n\nKeep it. See [[Beta]].\n");
    writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\n\nBeta links to [[Alpha]].\n");
    writeFileSync(join(vault, "Reference", "Guide.md"), "# Guide\n\nReference text.\n");
  }
  return { home: root, vault };
}
async function cli(paths: { home: string; vault: string }, ...args: string[]) {
  const proc = Bun.spawn([process.execPath, "--no-env-file", entry, "memory", ...args], {
    env: { ...process.env, HOME: paths.home, MLX_BUN_WIKI: paths.vault, NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib", HF_HUB_OFFLINE: "1" },
    stdout: "pipe", stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
  return { out, err, code };
}

test("status is the default subcommand and reports the vault or its absence", async () => {
  const paths = home();
  const status = await cli(paths);
  expect(status.code).toBe(0);
  expect(status.out).toContain(`memory · ${paths.vault}`);
  expect(status.out).toContain("articles   2");
  expect(status.out).toContain("reference  1 read-only docs");
  expect(status.out).toContain("git        not a git repo");
  expect(status.out).toContain("synthesis  available · mlx-bun memory synthesize");
  // No plist under the temporary HOME: not scheduled, and launchctl is never consulted.
  expect(status.out).toContain("nightly    not scheduled · mlx-bun memory schedule");
  expect(status.out).toMatch(/recent    (Alpha, Beta|Beta, Alpha)/);
  const missing = await cli(home(false), "status");
  expect(missing.code).toBe(0);
  expect(missing.out).toContain("no memory wiki yet at");
  expect(missing.out).toContain("set one up:  mlx-bun memory init");
});

test("list, search, toc, section, links, and read work from the terminal", async () => {
  const paths = home();
  const list = await cli(paths, "list");
  expect(list.code).toBe(0);
  expect(list.out).toContain("  Alpha\n  Beta\n  Reference/Guide\n");
  expect(list.out).toContain("2 article(s), 1 read-only reference doc(s)");
  const search = await cli(paths, "search", "lenses");
  expect(search.code).toBe(0);
  expect(search.out).toContain("Alpha · 1 hit(s)");
  expect(search.out).toContain("Alpha#alpha:3  Alpha is a test article about lenses.");
  expect(search.out).toContain("read one:  mlx-bun memory read Alpha");
  expect((await cli(paths, "search", "zzz")).out).toContain('no articles match "zzz"');
  const toc = await cli(paths, "toc", "Alpha");
  expect(toc.out).toBe("- Alpha  #alpha\n  - Verdict  #verdict\n");
  const section = await cli(paths, "section", "Alpha", "#verdict");
  expect(section.code).toBe(0);
  expect(section.out).toContain("## Verdict\n\nKeep it. See [[Beta]].");
  const noSection = await cli(paths, "section", "Alpha", "nope");
  expect(noSection.code).toBe(1);
  expect(noSection.err).toContain("no section #nope in Alpha");
  expect(noSection.err).toContain("try:  mlx-bun memory toc Alpha");
  const links = await cli(paths, "links", "Alpha");
  expect(links.out).toBe("outbound:\n  Beta\n\ninbound:\n  Beta\n");
  const read = await cli(paths, "read", "Beta");
  expect(read.code).toBe(0);
  expect(read.out).toBe("# Beta\n\nBeta links to [[Alpha]].\n\n");
});

test("a missing article, a missing query, and an unknown subcommand fail with main's guidance", async () => {
  const paths = home();
  const missing = await cli(paths, "read", "Nope");
  expect(missing.code).toBe(1);
  expect(missing.err).toContain("Article not found: Nope.md");
  expect(missing.err).toContain("try:  mlx-bun memory search Nope");
  for (const [sub, usage] of [["search", "usage: mlx-bun memory search <query>"], ["toc", "usage: mlx-bun memory toc <article>"],
    ["links", "usage: mlx-bun memory links <article>"], ["read", "usage: mlx-bun memory read <article>"],
    ["section", "usage: mlx-bun memory section <article> <anchor>"]] as const) {
    const result = await cli(paths, sub);
    expect(result.code).toBe(1);
    expect(result.err).toContain(usage);
  }
  const unknown = await cli(paths, "bogus");
  expect(unknown.code).toBe(1);
  expect(unknown.err).toContain("unknown: mlx-bun memory bogus");
  expect(unknown.out).toContain("Subcommands:");
  expect(unknown.out).toContain("  synthesize ");
  const helped = await cli(paths, "--help");
  expect(helped.code).toBe(0);
  expect(helped.out).toContain("segment | extract | route | synthesize-stage");
  expect(helped.out).toContain("--dry-run");
  expect(helped.out).toContain("  init, setup        Create the wiki + walk through setup (idempotent);");
  expect(helped.out).toContain("  unschedule         Remove the nightly launchd job");
  expect(helped.out).toContain("--at <value>");
});

test("synthesize --dry-run plans every stage without a server; a bad --port is a usage error", async () => {
  const paths = home();
  const dry = await cli(paths, "synthesize", "--dry-run");
  expect(dry.code).toBe(0);
  expect(dry.out).toContain("dry-run — no model calls, nothing will be written.");
  for (const stage of ["ingest", "segment", "extract", "route", "create", "section-route", "patch", "link", "wikify", "commit"])
    expect(dry.out).toContain(`· ${stage}: planned (dry-run)`);
  expect(dry.out).toContain("dry-run complete — no articles written.");
  expect(dry.out).toContain("dry-run: DAG wired; no model calls made.");
  const bad = await cli(paths, "synthesize", "--port", "70000");
  expect(bad.code).toBe(1);
  expect(bad.err).toContain("--port must be an integer in 1..65535, got 70000");
});

test("the deterministic link stage runs without a model and persists its store under HOME", async () => {
  const paths = home();
  const linked = await cli(paths, "link");
  expect(linked.code).toBe(0);
  expect(linked.out).toContain("link: cross-linking 2 article(s)");
  expect(linked.out).toContain("linked Alpha (+1 mention(s), 1 See also)");
  expect(linked.out).toContain("link: 2 article(s) linked · 2 mention edge(s) · 0 gated");
  expect(await Bun.file(join(paths.home, ".cache", "mlx-bun", "memory.sqlite")).exists()).toBe(true);
  const again = await cli(paths, "link", "--limit", "5");
  expect(again.out).toContain("link: 0 article(s) linked · 0 mention edge(s) · 0 gated");
});

test("a stage that needs the model fails clearly when no server answers at --host/--port", async () => {
  const paths = home();
  // SEGMENT inlines the vault's Meta policy pages into its prompt (a vault without them is an error, as in main).
  mkdirSync(join(paths.vault, "Meta"), { recursive: true });
  writeFileSync(join(paths.vault, "Meta", "Chunking.md"), "# Chunking\n\nOne chunk per topic.\n");
  writeFileSync(join(paths.vault, "Meta", "Topics_to_Ignore.md"), "# Topics to Ignore\n\nNothing.\n");
  const { MemoryStore } = await import("../src/memory/db");
  const store = new MemoryStore(join(paths.home, ".cache", "mlx-bun", "memory.sqlite"));
  store.db.run("INSERT INTO conversations (conv, source, title, updated_at, chunked_at) VALUES (?,?,?,?,?)", ["c1", "pi", "t", 1000, null]);
  store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", ["c1", 0, "user", "u0", "which lens for reach?"]);
  store.db.run("INSERT INTO messages (conv, position, role, uuid, text) VALUES (?,?,?,?,?)", ["c1", 1, "assistant", "u1", "the 150-600"]);
  store.close();
  const segment = await cli(paths, "segment", "--limit", "1", "--port", "1");
  expect(segment.code).toBe(0);
  expect(segment.out).toContain("[1/1] c1: model error: Error: memory: no mlx-bun server answered at http://127.0.0.1:1");
  expect(segment.out).toContain("segment: 0 segmented, 0 chunks, 0 skipped, 1 errored");
  const full = await cli(paths, "synthesize", "--port", "1");
  expect(full.code).toBe(0);
  expect(full.out).toContain("start `mlx-bun serve` first");
  // Segmentation failed, so no chunk entered the run scope: main counts conversations from the routed chunks.
  expect(full.out).toContain("segment done: 1 attempted, 0 valid, 0 skipped, 1 errored, 0 chunks");
  expect(full.out).toContain("synthesis wired — 0 created, 0 patched, 0 wikified from 0 conversations.");
});
