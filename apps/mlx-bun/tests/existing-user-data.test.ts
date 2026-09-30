// Existing-user data acceptance: the app opens data a prior version left under
// HOME (web chat sessions, Pi settings, tool approvals, the saved HF token,
// the memory vault with its Reference links, adapter stores, the nightly
// schedule) without losing or rewriting user content. The app's jobs, memory
// and registry databases live under MLX_BUN_HOME/db; an earlier version's
// ~/.cache/mlx-bun databases are not carried over and must stay untouched,
// while its adapter stores are listed read-only. The data is never used in place:
// `acceptUserData` fingerprints the supplied directory, clones it (APFS clone,
// symlinks kept as links), runs tests/support/user-data-probe.ts and two
// read-only CLI verbs with HOME set to the clone and native MLX blocked, then
// requires the supplied directory and every symlink target outside it to be
// unchanged, no file deleted from the clone, the vault byte-identical, and
// every other rewrite limited to the app's own databases (.mlx-bun/db), its bundled memory
// skill, and session files whose messages survive the Pi SDK's version
// migration.
//
// The first test builds main's formats in-test under a temporary HOME and runs
// on CPU in the default suite. The second is opt-in acceptance on real data:
//   MLX_BUN_APP_TEST_USER_DATA=<an isolated copy laid out as a HOME directory> \
//     bun test tests/existing-user-data.test.ts
// The copy must hold .mlx-bun and/or .cache/mlx-bun (and Library/LaunchAgents
// for the schedule); make it with `cp -c -R -P -p`. A copy holding, at any
// depth, a link into a live store or a directory link out of the copy is
// refused. Nothing outside the copy is read except the targets of its
// symlinks, which are only fingerprinted. It needs no weights or GPU and
// prints a summary: counts, sidebar and per-cwd listings, broken and external
// Reference links (the targets to preserve before deleting an old checkout),
// the adapter catalog, the stores not carried over, and the schedule's command.
import { expect, test } from "bun:test";
import { Database } from "bun:sqlite";
import { chmodSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, readlinkSync, realpathSync, rmSync,
  statSync, symlinkSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join, relative, sep } from "node:path";
import { sessionEntries } from "@mlx-bun/module-chat";
import type { UserDataReport } from "./support/user-data-probe";

const APP = join(import.meta.dir, "..");
const PROBE = join(import.meta.dir, "support", "user-data-probe.ts");
const LAUNCHER = join(APP, "bin", "mlx-bun.mjs");
/** Directories the probe owns inside the clone. */
const PROBE_OWNED = [".tmp", ".probe-cwd"];

const inside = (path: string, root: string) => path === root || path.startsWith(root + sep);

interface Node { type: "file" | "dir" | "symlink" | "other"; size: number; mtimeMs: number; mode: number; target?: string }
/** lstat of every entry, never following symlinks. */
function fingerprint(root: string): Map<string, Node> {
  const out = new Map<string, Node>();
  const walk = (dir: string) => {
    for (const name of readdirSync(dir).sort()) {
      const path = join(dir, name), stat = lstatSync(path);
      const type = stat.isSymbolicLink() ? "symlink" : stat.isDirectory() ? "dir" : stat.isFile() ? "file" : "other";
      out.set(relative(root, path), { type, size: type === "dir" ? 0 : stat.size, mtimeMs: type === "dir" ? 0 : stat.mtimeMs,
        mode: stat.mode, ...(type === "symlink" ? { target: readlinkSync(path) } : {}) });
      if (type === "dir") walk(path);
    }
  };
  walk(root);
  return out;
}

/** stat (following the link) of every symlink target outside the tree; null when dangling. */
function externalTargets(root: string, tree: Map<string, Node>) {
  const out: Record<string, { target: string; size: number; mtimeMs: number } | null> = {};
  for (const [path, node] of tree) {
    if (node.type !== "symlink") continue;
    let resolved: string;
    try { resolved = realpathSync(join(root, path)); } catch { out[path] = null; continue; }
    if (inside(resolved, root)) continue;
    const stat = statSync(resolved);
    out[path] = { target: resolved, size: stat.isDirectory() ? 0 : stat.size, mtimeMs: stat.mtimeMs };
  }
  return out;
}

/** The live HOME's stores, which the probe must never reach: mlx-bun's data (and
 * MLX_BUN_HOME when set), the caches, Pi's directory, and Library. */
function liveStores(realHome: string, env: Record<string, string | undefined> = process.env): string[] {
  return [join(realHome, ".mlx-bun"), join(realHome, ".cache"), join(realHome, ".pi"), join(realHome, "Library"),
    ...(env.MLX_BUN_HOME ? [env.MLX_BUN_HOME] : [])].map(path => existsSync(path) ? realpathSync(path) : path);
}

/** Symlinks anywhere in `copy` the probe could read or write through into a live
 * store: any link resolving into one, and any directory link leaving the copy
 * (whose contents may link onward). Dangling links and file links elsewhere
 * (Reference docs in an old checkout) are allowed; they are only fingerprinted. */
function unsafeLinks(copy: string, live: string[]): string[] {
  const unsafe: string[] = [];
  for (const [path, node] of fingerprint(copy)) {
    if (node.type !== "symlink") continue;
    let resolved: string;
    try { resolved = realpathSync(join(copy, path)); } catch { continue; }
    if (inside(resolved, copy)) continue;
    if (live.some(store => inside(resolved, store)) || statSync(resolved).isDirectory()) unsafe.push(`${path} -> ${resolved}`);
  }
  return unsafe;
}

async function sha(path: string) {
  const hasher = new Bun.CryptoHasher("sha256");
  for await (const chunk of Bun.file(path).stream()) hasher.update(chunk);
  return hasher.digest("hex");
}

const messages = (path: string) => sessionEntries(readFileSync(path, "utf8"))
  .filter(entry => (entry as { type?: string }).type === "message")
  .map(entry => JSON.stringify((entry as { message?: { content?: unknown } }).message?.content ?? null));

/** How the app may change a file on first use; null marks a violation. Opening a
 * chat appends the SDK's session entries; opening a pre-v3 chat rewrites it in
 * the current version with the same messages. */
function rewriteKind(path: string, source: string, work: string): "database" | "bundled skill" | "session append" | "session migration" | null {
  if (/^\.mlx-bun\/db\/[^/]+\.sqlite(-wal|-shm)?$/.test(path)) return "database";
  if (path === ".mlx-bun/skills/memory/SKILL.md") return "bundled skill";
  if (/^\.mlx-bun\/sessions\/[^/]+\.jsonl$/.test(path)) {
    if (readFileSync(join(work, path), "utf8").startsWith(readFileSync(join(source, path), "utf8"))) return "session append";
    const before = messages(join(source, path)), after = messages(join(work, path));
    return JSON.stringify(after.slice(0, before.length)) === JSON.stringify(before) ? "session migration" : null;
  }
  return null;
}

async function run(command: string[], env: Record<string, string>, cwd: string) {
  const child = Bun.spawn(command, { cwd, env, stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
  return { code, stdout, stderr };
}

export interface Acceptance {
  report: UserDataReport;
  deleted: string[]; rewritten: Record<string, string>; violations: string[]; added: string[];
  cli: Record<string, { code: number; stdout: string; stderr: string }>;
}

/** Clone `source`, open it through the app with HOME set to the clone, and verify nothing was lost. */
async function acceptUserData(source: string): Promise<Acceptance> {
  const before = fingerprint(source), targets = externalTargets(source, before);
  const scratch = realpathSync(mkdtempSync(join(tmpdir(), "mlx-user-data-"))), work = join(scratch, "home");
  try {
    mkdirSync(work);
    let clone = await run(["/bin/cp", "-c", "-R", "-P", "-p", `${source}/.`, work], { PATH: process.env.PATH ?? "" }, scratch);
    if (clone.code !== 0) clone = await run(["/bin/cp", "-R", "-P", "-p", `${source}/.`, work], { PATH: process.env.PATH ?? "" }, scratch);
    expect(clone.code, clone.stderr).toBe(0);
    for (const dir of PROBE_OWNED) mkdirSync(join(work, dir), { recursive: true });
    const env = { PATH: process.env.PATH ?? "", HOME: work, TMPDIR: join(work, ".tmp"),
      MLX_BUN_LIBMLXC: join(scratch, "native-blocked", "libmlxc.dylib") };
    const reportFile = join(scratch, "report.json");
    const probe = await run([process.execPath, "--no-env-file", PROBE, "--report", reportFile], env, APP);
    expect(probe.code, probe.stderr).toBe(0);
    const report = JSON.parse(readFileSync(reportFile, "utf8")) as UserDataReport;
    const cli: Acceptance["cli"] = {};
    for (const verb of [["memory", "list"], ["ls"]])
      cli[verb.join(" ")] = await run([process.execPath, "--no-env-file", LAUNCHER, ...verb], env, join(work, ".probe-cwd"));

    // The supplied data and everything its links reach are untouched.
    expect(fingerprint(source)).toEqual(before);
    expect(externalTargets(source, before)).toEqual(targets);

    const after = fingerprint(work), deleted: string[] = [], rewritten: Record<string, string> = {}, violations: string[] = [];
    for (const [path, node] of before) {
      const now = after.get(path);
      if (!now || now.type !== node.type) { deleted.push(path); continue; }
      if (node.type === "symlink" && now.target !== node.target) violations.push(path);
      if (node.type !== "file" || (now.size === node.size && now.mtimeMs === node.mtimeMs)) continue;
      if (await sha(join(source, path)) === await sha(join(work, path))) continue;
      const kind = rewriteKind(path, source, work);
      if (kind) rewritten[path] = kind; else violations.push(path);
    }
    const added = [...after.keys()].filter(path => !before.has(path) && !PROBE_OWNED.some(dir => inside(path, dir)));
    return { report, deleted, rewritten, violations, added, cli };
  } finally { rmSync(scratch, { recursive: true, force: true }); }
}

/** Every section opened, every chat and job record read, and nothing lost or rewritten beyond migration. */
function expectAccepted(result: Acceptance) {
  const { report } = result;
  for (const [name, section] of Object.entries({ sessions: report.sessions, jobs: report.jobs, vault: report.vault, settings: report.settings }))
    expect(section && "error" in section ? `${name}: ${section.error}` : null).toBeNull();
  expect(result.deleted).toEqual([]);
  expect(result.violations).toEqual([]);
  for (const [verb, outcome] of Object.entries(result.cli)) expect(outcome.code, `${verb}: ${outcome.stderr}`).toBe(0);
  const sessions = report.sessions as Exclude<UserDataReport["sessions"], { error: string }>;
  expect(sessions.failures).toEqual({});
  expect(sessions.webChat).toEqual({ ready: true, startErrors: [] });
  expect(Object.keys(sessions.opened).length).toBe(sessions.files);
  for (const count of Object.values(sessions.exported)) expect(count).toBeGreaterThanOrEqual(0);
  for (const count of Object.values(sessions.history)) expect(count).toBeGreaterThanOrEqual(0);
  if (!("error" in report.jobs)) expect(report.jobs.listed).toBe(report.jobs.rows);
  const vault = report.vault as Exclude<UserDataReport["vault"], { error: string }>;
  if (vault.enabled) {
    // Only Reference documents whose link is already dangling may be unreadable.
    const broken = new Set(vault.symlinks.filter(link => link.state === "broken").map(link => link.path.replace(/\.md$/, "")));
    for (const name of vault.unreadable ?? []) expect(broken).toContain(name);
    expect(vault.linkFailures).toBe(0);
    if (vault.memoryDb?.before) expect(vault.memoryDb.after).toEqual(vault.memoryDb.before);
  }
}

// ---- main's formats, generated here --------------------------------------
const ORIGINAL_HOME = "/Users/prior-user";

function safetensors(tensors: Record<string, { shape: number[]; values: number[] }>): Uint8Array {
  const header: Record<string, unknown> = {};
  let offset = 0;
  for (const [name, { shape, values }] of Object.entries(tensors)) {
    header[name] = { dtype: "F32", shape, data_offsets: [offset, offset + values.length * 4] };
    offset += values.length * 4;
  }
  const json = Buffer.from(JSON.stringify(header));
  const out = Buffer.alloc(8 + json.length + offset);
  out.writeBigUInt64LE(BigInt(json.length), 0); json.copy(out, 8);
  let at = 8 + json.length;
  for (const { values } of Object.values(tensors)) for (const value of values) { out.writeFloatLE(value, at); at += 4; }
  return out;
}

async function priorHome(root: string) {
  const home = join(root, "home"), checkout = join(root, "old-checkout");
  const write = (path: string, text: string | Uint8Array) => { mkdirSync(dirname(join(home, path)), { recursive: true }); writeFileSync(join(home, path), text); };
  mkdirSync(join(checkout, "docs"), { recursive: true });
  writeFileSync(join(checkout, "docs", "architecture.md"), "# Architecture\n\nThe engine owns scheduling.\n");

  // Web chat sessions: main wrote them with the same Pi SDK (0.80.3, session v3).
  const { SessionManager } = await import("@earendil-works/pi-coding-agent");
  const sessionDir = join(home, ".mlx-bun", "sessions");
  const usage = { input: 3, output: 2, cacheRead: 0, cacheWrite: 0, totalTokens: 5, cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } };
  const assistant = (text: string) => ({ role: "assistant" as const, content: [{ type: "text" as const, text }], api: "openai-completions" as const,
    provider: "mlx-bun", model: "local", usage, stopReason: "stop" as const, timestamp: 1_790_000_000_000 });
  for (const [cwd, turns] of [[join(root, "projectA"), ["What is MLX?", "Name one Apple chip."]], [join(root, "projectB"), ["Summarize the vault."]]] as const) {
    const manager = SessionManager.create(cwd, sessionDir);
    let first: string | undefined;
    for (const turn of turns) {
      const id = manager.appendMessage({ role: "user", content: turn, timestamp: 1_790_000_000_000 });
      first ??= id;
      manager.appendMessage(assistant(`About: ${turn}`));
    }
    manager.appendLabelChange(first!, "kept");
    manager.appendCustomEntry("mlx-bun.sampling", { temperature: 0.2 });
  }
  // An interrupted append leaves a partial last line in the first chat.
  const first = readdirSync(sessionDir).sort()[0]!;
  writeFileSync(join(sessionDir, first), readFileSync(join(sessionDir, first), "utf8") + "{\"type\":\"message\",\"id\":\"trunc");
  // A version-1 chat (no ids): the SDK migrates it to v3 when opened.
  write(".mlx-bun/sessions/2026-01-02T03-04-05-000Z_legacy.jsonl", [
    { type: "session", id: "legacy", timestamp: "2026-01-02T03:04:05.000Z", cwd: join(root, "projectA") },
    { type: "message", timestamp: "2026-01-02T03:04:06.000Z", message: { role: "user", content: "Old question", timestamp: 1 } },
    { type: "message", timestamp: "2026-01-02T03:04:07.000Z", message: assistant("Old answer") },
  ].map(entry => JSON.stringify(entry)).join("\n") + "\n");

  write(".mlx-bun/pi-sessions/settings.json", "{}\n");
  write(".mlx-bun/tool-approvals.json", JSON.stringify({ version: 1, allows: { bash: true } }) + "\n");
  write(".mlx-bun/hf.json", JSON.stringify({ token: "hf_synthetic", savedAt: "2026-09-01T00:00:00.000Z" }, null, 2) + "\n");
  chmodSync(join(home, ".mlx-bun", "hf.json"), 0o600);
  write(".mlx-bun/skills/memory/SKILL.md", "An older bundled memory skill.\n");

  // The vault: articles, Talk, and Reference links main seeded into its checkout (one already dangling).
  write(".mlx-bun/wiki/articles/Apple Silicon.md", "# Apple Silicon\n\nUnified memory runs [[MLX]].\n");
  write(".mlx-bun/wiki/articles/MLX.md", "# MLX\n\nAn array framework for [[Apple Silicon]].\n");
  write(".mlx-bun/wiki/Talk/MLX.md", "Discussion.\n");
  mkdirSync(join(home, ".mlx-bun", "wiki", "Reference"), { recursive: true });
  symlinkSync(join(checkout, "docs", "architecture.md"), join(home, ".mlx-bun", "wiki", "Reference", "architecture.md"));
  symlinkSync(join(checkout, "docs", "deleted.md"), join(home, ".mlx-bun", "wiki", "Reference", "deleted.md"));

  // Jobs in main's frozen schema, with logs recorded under the original HOME and one elsewhere.
  write(".cache/mlx-bun/jobs/.keep", "");
  const jobs = new Database(join(home, ".cache", "mlx-bun", "jobs.sqlite"));
  try {
    jobs.exec(`CREATE TABLE jobs (
      id TEXT PRIMARY KEY, kind TEXT NOT NULL, status TEXT NOT NULL,
      config_json TEXT NOT NULL, progress REAL NOT NULL DEFAULT 0, message TEXT,
      log_path TEXT NOT NULL, output_path TEXT, error TEXT,
      started_at TEXT NOT NULL DEFAULT (datetime('now')), ended_at TEXT
    ); CREATE INDEX idx_jobs_status_started ON jobs(status, started_at DESC);`);
    const insert = jobs.prepare("INSERT INTO jobs VALUES (?, 'finetune', ?, ?, ?, NULL, ?, ?, ?, '2026-09-24 12:00:00', NULL)");
    const log = (id: string) => `${ORIGINAL_HOME}/.cache/mlx-bun/jobs/${id}.log`;
    const adapter = `${ORIGINAL_HOME}/.cache/mlx-bun/adapters/prior-lora`;
    for (const [id, status, error] of [["job_0000000000000001", "done", null], ["job_0000000000000002", "failed", "old failure"],
      ["job_0000000000000003", "queued", null], ["job_0000000000000004", "running", null]] as const) {
      insert.run(id, status, JSON.stringify({ model_dir: "/old/model", method: "sft" }), status === "done" ? 1 : 0, log(id), adapter, error);
      write(`.cache/mlx-bun/jobs/${id}.log`, [{ type: "metric", kind: "train", step: 1, loss: 2.5 },
        ...(status === "done" ? [{ type: "done", ts: 1_790_000_000_000, output_dir: adapter }] : [])].map(e => JSON.stringify(e)).join("\n") + "\n");
    }
    insert.run("job_0000000000000005", "done", "{}", 1, "/Volumes/elsewhere/job_5.log", null, null);
    // An unfinalized statement would defer the close, and its checkpoint, past the fingerprint.
    insert.finalize();
  } finally { jobs.close(true); }

  // The memory database (schema unchanged from main) with one conversation.
  const { MemoryStore } = await import("@mlx-bun/module-memory/db");
  const memory = new MemoryStore(join(home, ".cache", "mlx-bun", "memory.sqlite"));
  try { memory.db.run("INSERT INTO conversations (conv, source, updated_at) VALUES (?, ?, ?)", ["conv:1", "pi", 1]); }
  finally { memory.close(); }

  // Adapters: one in the chat picker's store, one at train's default output root.
  const tensors = safetensors({ "model.layers.0.self_attn.q_proj.lora_a": { shape: [2, 2], values: [1, 0, 0, 1] },
    "model.layers.0.self_attn.q_proj.lora_b": { shape: [2, 2], values: [0, 0, 0, 0] } });
  for (const dir of [".cache/mlx-bun/adapters/prior-lora", ".cache/mlx-bun/mlx-bun-finetunes/orpo-cpm5"]) {
    write(`${dir}/adapters.safetensors`, tensors);
    write(`${dir}/optiq_lora_config.json`, JSON.stringify({ rank: 2, scale: 1, lora_parameters: { rank: 2, scale: 1 },
      source_model: `${ORIGINAL_HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/abc` }) + "\n");
  }

  // Main's nightly job, pointing into the old checkout.
  write("Library/LaunchAgents/com.mlx-bun.memory.plist", `<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mlx-bun.memory</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-lc</string>
        <string>exec &apos;bun&apos; &apos;${checkout}/src/cli.ts&apos; memory synthesize</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
`);
  return { home, checkout };
}

test("main's user data under HOME opens through the app without loss", async () => {
  const root = realpathSync(mkdtempSync(join(tmpdir(), "mlx-prior-home-")));
  try {
    const { home, checkout } = await priorHome(root);
    const git = Bun.which("git");
    if (git) {
      const vault = join(home, ".mlx-bun", "wiki");
      // No detached auto-maintenance: it writes .git/objects/maintenance.lock after
      // the commit returns, racing the check that the supplied data is untouched.
      const quiet = ["-c", "maintenance.auto=false", "-c", "gc.auto=0"];
      for (const args of [["init", "-q"], ["add", "-A"], ["-c", "user.name=prior", "-c", "user.email=prior@example.invalid", "commit", "-q", "-m", "prior vault"]])
        expect((await run([git, ...quiet, ...args], { PATH: process.env.PATH ?? "", HOME: root }, vault)).code).toBe(0);
    }
    const result = await acceptUserData(home);
    expectAccepted(result);
    const { report } = result;

    const sessions = report.sessions as Exclude<UserDataReport["sessions"], { error: string }>;
    expect(sessions.files).toBe(3);
    expect(sessions.listed).toBe(3);
    // The probe's server runs from neither recorded directory; the sidebar still lists every chat.
    expect(sessions.sidebar).toBe(3);
    expect(sessions.byCwd).toEqual({ [join(root, "projectA")]: 2, [join(root, "projectB")]: 1 });
    expect(Object.values(sessions.versions).map(v => v.version).sort()).toEqual([1, 3, 3]);
    expect(Object.values(sessions.opened).map(o => o.messages).sort()).toEqual([2, 2, 4]);
    expect(Object.values(sessions.history).every(count => count > 0)).toBe(true);
    // Only the version-1 chat is rewritten, by the SDK's migration, with its messages intact; the others only grow.
    const sessionChanges = Object.entries(result.rewritten).filter(([path]) => path.startsWith(".mlx-bun/sessions/"));
    expect(sessionChanges.filter(([, kind]) => kind === "session migration").map(([path]) => path))
      .toEqual([".mlx-bun/sessions/2026-01-02T03-04-05-000Z_legacy.jsonl"]);
    expect(sessionChanges.every(([, kind]) => kind === "session append" || kind === "session migration")).toBe(true);
    expect(result.rewritten[".mlx-bun/skills/memory/SKILL.md"]).toBe("bundled skill");
    expect(Object.keys(result.rewritten).some(path => path.startsWith(".mlx-bun/wiki/"))).toBe(false);
    expect(result.added.filter(path => path.startsWith(".mlx-bun/sessions/") || path.startsWith(".mlx-bun/wiki/"))).toEqual([]);

    // main's jobs, memory and registry databases are not carried over: the app opens its own
    // under .mlx-bun/db and leaves the old files (and job logs) byte-identical.
    expect(report.jobs).toEqual({ db: ".mlx-bun/db/jobs.sqlite", rows: 0, listed: 0, legacy: [".cache/mlx-bun/jobs.sqlite", ".cache/mlx-bun/jobs"] });
    expect(Object.keys(result.rewritten).filter(path => path.startsWith(".cache/"))).toEqual([]);
    expect(Object.entries(result.rewritten).filter(([path]) => path.startsWith(".mlx-bun/db/")).every(([, kind]) => kind === "database")).toBe(true);

    const vault = report.vault as Extract<UserDataReport["vault"], { articles: number }>;
    expect(vault).toMatchObject({ enabled: true, articles: 2, reference: 2, git: !!git, unreadable: ["Reference/deleted"], linkFailures: 0 });
    expect(vault.symlinks).toEqual([
      { path: "Reference/architecture.md", target: join(checkout, "docs", "architecture.md"), state: "external" },
      { path: "Reference/deleted.md", target: join(checkout, "docs", "deleted.md"), state: "broken" },
    ]);
    expect(vault.memoryDb).toMatchObject({ path: ".mlx-bun/db/memory.sqlite", before: null, after: { conversations: 0 }, legacy: true });

    const settings = report.settings as Exclude<UserDataReport["settings"], { error: string }>;
    expect(settings.credentials).toEqual({ saved: true, mode: "600" });
    expect(settings.toolApprovals).toEqual({ version: 1, allowed: 1 });
    expect(settings.schedule).toMatchObject({ installed: true, at: { hour: 3, minute: 0 } });
    expect(settings.schedule.command).toBe(`exec 'bun' '${checkout}/src/cli.ts' memory synthesize`);
    // The picker lists main's adapter stores read-only.
    expect(settings.adapters.map(a => [a.store, a.id, a.config])).toEqual([
      [".cache/mlx-bun/adapters", "prior-lora", "ok"], [".cache/mlx-bun/mlx-bun-finetunes", "orpo-cpm5", "ok"]]);
    expect(result.cli["memory list"]!.stdout).toContain("Apple Silicon");
    expect(JSON.stringify(report)).not.toContain("hf_synthetic");
  } finally { rmSync(root, { recursive: true, force: true }); }
}, 120_000);

test("the copy guard refuses links into a live store at any depth and directory links out of the copy", () => {
  const root = realpathSync(mkdtempSync(join(tmpdir(), "mlx-copy-guard-")));
  try {
    const realHome = join(root, "home"), copy = join(root, "copy"), checkout = join(root, "checkout");
    for (const dir of [join(realHome, ".mlx-bun", "sessions"), join(realHome, ".cache", "mlx-bun"), join(checkout, "docs"),
      join(copy, ".mlx-bun", "sessions"), join(copy, ".mlx-bun", "wiki", "Reference"), join(copy, ".cache")]) mkdirSync(dir, { recursive: true });
    writeFileSync(join(realHome, ".mlx-bun", "sessions", "live.jsonl"), "{}\n");
    writeFileSync(join(checkout, "docs", "architecture.md"), "# doc\n");
    const live = liveStores(realHome, { MLX_BUN_HOME: join(root, "elsewhere") });
    expect(live).toContain(join(root, "elsewhere"));
    // Allowed: a file link to an old checkout, a dangling link, a link inside the copy.
    symlinkSync(join(checkout, "docs", "architecture.md"), join(copy, ".mlx-bun", "wiki", "Reference", "architecture.md"));
    symlinkSync(join(checkout, "docs", "deleted.md"), join(copy, ".mlx-bun", "wiki", "Reference", "deleted.md"));
    symlinkSync(join(copy, ".mlx-bun", "sessions"), join(copy, ".mlx-bun", "sessions-link"));
    expect(unsafeLinks(copy, live)).toEqual([]);
    // Refused: a nested file link into the live store, a nested directory link into it, and a directory link out of the copy.
    symlinkSync(join(realHome, ".mlx-bun", "sessions", "live.jsonl"), join(copy, ".mlx-bun", "sessions", "live.jsonl"));
    symlinkSync(join(realHome, ".cache", "mlx-bun"), join(copy, ".cache", "mlx-bun"));
    symlinkSync(join(checkout, "docs"), join(copy, ".mlx-bun", "wiki", "Reference", "docs"));
    expect(unsafeLinks(copy, live).sort()).toEqual([
      `.cache/mlx-bun -> ${join(realHome, ".cache", "mlx-bun")}`,
      `.mlx-bun/sessions/live.jsonl -> ${join(realHome, ".mlx-bun", "sessions", "live.jsonl")}`,
      `.mlx-bun/wiki/Reference/docs -> ${join(checkout, "docs")}`,
    ]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

const supplied = process.env.MLX_BUN_APP_TEST_USER_DATA;
test.skipIf(!supplied)("an isolated copy of real user data opens through the app without loss", async () => {
  const copy = realpathSync(supplied!), realHome = realpathSync(homedir()), live = liveStores(realHome);
  if (copy === realHome || inside(realHome, copy) || live.some(store => inside(copy, store) || inside(store, copy)))
    throw new Error(`MLX_BUN_APP_TEST_USER_DATA must be an isolated copy, not the live HOME or its stores: ${copy}`);
  const roots = [".mlx-bun", ".cache/mlx-bun"].filter(dir => existsSync(join(copy, dir)));
  if (!roots.length) throw new Error(`MLX_BUN_APP_TEST_USER_DATA has neither .mlx-bun nor .cache/mlx-bun: ${copy}`);
  const unsafe = unsafeLinks(copy, live);
  if (unsafe.length) throw new Error(`MLX_BUN_APP_TEST_USER_DATA links into a live store or out of the copy by directory:\n${unsafe.join("\n")}`);
  const result = await acceptUserData(copy);
  const { report } = result;
  const vault = report.vault as { symlinks?: { path: string; target: string; state: string }[] };
  console.log(JSON.stringify({
    sessions: "error" in report.sessions ? report.sessions : { files: report.sessions.files, listed: report.sessions.listed, sidebar: report.sessions.sidebar,
      versions: Object.values(report.sessions.versions).reduce<Record<number, number>>((out, v) => ({ ...out, [v.version]: (out[v.version] ?? 0) + 1 }), {}),
      byCwd: report.sessions.byCwd, failures: report.sessions.failures, agentFiles: report.sessions.agentFiles },
    jobs: report.jobs, vault: { ...report.vault, symlinks: undefined },
    referenceLinks: { broken: vault.symlinks?.filter(link => link.state === "broken"), external: vault.symlinks?.filter(link => link.state === "external") },
    settings: report.settings, rewritten: result.rewritten, added: result.added.length, violations: result.violations, deleted: result.deleted,
    cli: Object.fromEntries(Object.entries(result.cli).map(([verb, outcome]) => [verb, outcome.code])),
  }, null, 2));
  expectAccepted(result);
}, 1_800_000);
