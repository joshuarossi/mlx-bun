// Child process of tests/existing-user-data.test.ts. It runs with HOME set to
// a scratch clone of the data under test and the native MLX library blocked,
// so every default the app derives from HOME at import or call time resolves
// inside the clone and nothing reaches the GPU. It opens each store through
// the app's own modules, as the app would on first use, and writes one JSON
// report to the path given by --report. Absolute paths recorded in the data
// (job logs and outputs) are followed only inside HOME, or after replacing
// the --original-home prefix with HOME; nothing outside the clone is read.
//
//   bun tests/support/user-data-probe.ts --report <file> [--original-home <path>]
import { Database } from "bun:sqlite";
import { existsSync, mkdirSync, readdirSync, readFileSync, readlinkSync, realpathSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join, relative, resolve, sep } from "node:path";
import { parseArgs } from "node:util";

const { values } = parseArgs({ options: { report: { type: "string" }, "original-home": { type: "string" } } });
if (!values.report) throw new Error("--report <file> is required");
const home = realpathSync(process.env.HOME ?? "");
if (realpathSync(homedir()) !== home) throw new Error("the probe must run with HOME set to the scratch clone");
const originalHome = values["original-home"]?.replace(/\/+$/, "");

const inside = (path: string, root: string) => path === root || path.startsWith(root + sep);
const message = (error: unknown) => error instanceof Error ? error.message : String(error);
type Located = { kind: "inside" | "translated"; path: string } | { kind: "external"; path: string };
/** A recorded absolute path, readable only when it lies in the clone (directly or by the original-home prefix). */
function localPath(path: string | null | undefined): Located | null {
  if (!path) return null;
  if (inside(resolve(path), home)) return { kind: "inside", path: resolve(path) };
  if (originalHome && inside(path, originalHome)) return { kind: "translated", path: join(home, relative(originalHome, path)) };
  return { kind: "external", path };
}
/** Row counts per table, read before the app opens (and may migrate) a database. */
function tableCounts(path: string): Record<string, number> | null {
  if (!existsSync(path)) return null;
  const db = new Database(path, { readonly: true });
  try {
    const tables = db.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'").all() as { name: string }[];
    return Object.fromEntries(tables.map(({ name }) =>
      [name, (db.query(`SELECT count(*) AS n FROM "${name.replaceAll("\"", "\"\"")}"`).get() as { n: number }).n]));
  } finally { db.close(); }
}
const ndjson = (text: string) => text.split("\n").filter(line => line.trim()).map(line => JSON.parse(line) as Record<string, unknown>);

// ---- chat sessions (Pi SDK files) and the web chat backend ----------------
async function sessions() {
  const { SessionManager } = await import("@earendil-works/pi-coding-agent");
  const { defaultSessionDir, sessionEntries } = await import("../../src/chat/session-files");
  const { createSessionRoutes } = await import("../../src/server/session-routes");
  const { createPiBackend } = await import("../../src/chat/pi-backend");
  const { createMemorySurface } = await import("../../src/memory/surface");
  const { vaultRoot } = await import("../../src/memory/vault");
  const dir = defaultSessionDir();
  const files = existsSync(dir) ? readdirSync(dir).filter(name => name.endsWith(".jsonl")).sort() : [];
  const versions = Object.fromEntries(files.map(name => {
    const header = sessionEntries(readFileSync(join(dir, name), "utf8")).find(entry => (entry as { type?: string }).type === "session") as { version?: number; cwd?: string } | undefined;
    return [name, { version: header?.version ?? 1, cwd: header?.cwd ?? null }];
  }));
  const listed = await SessionManager.listAll(dir);
  const byCwd: Record<string, number> = {};
  for (const cwd of new Set(listed.map(info => info.cwd)))
    byCwd[cwd] = (await SessionManager.list(cwd || home, dir)).length;
  // The read-only HTTP export reads the raw file before any SDK migration rewrites it.
  const routes = createSessionRoutes(dir);
  const exported: Record<string, number> = {};
  for (const name of files) {
    const response = await routes.handle(new Request(`http://local/api/sessions/export?path=${encodeURIComponent(join(dir, name))}`));
    exported[name] = response?.status === 200 ? ((await response.json()) as { entries: unknown[] }).entries.length : -1;
  }
  const opened: Record<string, { messages: number; entries: number }> = {}, failures: Record<string, string> = {};
  for (const name of files) {
    try {
      const manager = SessionManager.open(join(dir, name), dir);
      opened[name] = { messages: manager.buildSessionContext().messages.length, entries: manager.getEntries().length };
    } catch (error) { failures[name] = message(error); }
  }
  // The web chat backend: start (new chat, sidebar list), then open every chat.
  const frames: { type: string; [key: string]: unknown }[] = [];
  const cwd = join(home, ".probe-cwd");
  mkdirSync(cwd, { recursive: true });
  const vault = vaultRoot(), skills = join(home, ".mlx-bun", "skills");
  const backend = createPiBackend({ port: 1, readOnly: true, paths: { cwd, sessionDir: dir },
    memory: async () => existsSync(vault) ? createMemorySurface(vault, skills) : undefined })(frame => { frames.push(frame as typeof frames[number]); });
  const history: Record<string, number> = {};
  try {
    await backend.start();
    for (const name of Object.keys(opened)) {
      const before = frames.length;
      // The chat socket turns a thrown frame handler into an error frame; record either.
      try { await backend.handle({ type: "open_session", path: join(dir, name) }); }
      catch (error) { failures[name] = `web chat: ${message(error)}`; }
      const reply = frames.slice(before);
      const error = reply.find(frame => frame.type === "error");
      if (error) failures[name] = `web chat: ${String(error.message)}`;
      history[name] = (reply.find(frame => frame.type === "history")?.items as unknown[] | undefined)?.length ?? -1;
    }
  } finally { await backend.dispose(); }
  const ready = frames.find(frame => frame.type === "ready");
  // The sidebar the web chat sent last: recorded chats it lists, from any directory.
  const sidebar = (frames.filter(frame => frame.type === "sessions").at(-1)?.items as { path: string }[] | undefined ?? [])
    .filter(item => files.includes(relative(dir, item.path))).length;
  return {
    dir: relative(home, dir), files: files.length, versions, listed: listed.length, sidebar, byCwd, exported, opened, history, failures,
    webChat: { ready: !!ready, startErrors: frames.filter(frame => frame.type === "error").map(frame => String(frame.message)) },
    agentFiles: existsSync(join(home, ".mlx-bun", "pi-sessions")) ? readdirSync(join(home, ".mlx-bun", "pi-sessions")).sort() : [],
  };
}

// ---- managed jobs ----------------------------------------------------------
async function jobs() {
  const { DEFAULT_JOBS_DB, DEFAULT_JOBS_DIR, JobStore } = await import("../../src/jobs/db");
  const { createJobHost } = await import("../../src/jobs/host");
  const { createJobRoutes } = await import("../../src/server/job-routes");
  if (!existsSync(DEFAULT_JOBS_DB)) return null;
  const before = new Database(DEFAULT_JOBS_DB, { readonly: true });
  let prior: { id: string; status: string }[];
  try { prior = before.query("SELECT id, status FROM jobs").all() as typeof prior; } finally { before.close(); }
  const host = createJobHost({ entry: "unused", acquire: async () => { throw new Error("the probe never runs jobs"); },
    createStore: () => new JobStore(DEFAULT_JOBS_DB, DEFAULT_JOBS_DIR) });
  const routes = createJobRoutes(host);
  try {
    const listing = await (await routes.handle(new Request(`http://local/api/jobs?limit=${prior.length + 1}`)))!.json() as { jobs: import("../../src/jobs/protocol").JobRow[] };
    const after = new Map(listing.jobs.map(job => [job.id, job]));
    const badConfig: string[] = [], logs = { inside: 0, translated: 0, external: [] as string[], missing: [] as string[], replayed: 0, unreadable: [] as string[] };
    const outputs = { inside: 0, translated: 0, external: [] as string[], missing: [] as string[] };
    const statusChanges: Record<string, number> = {};
    for (const { id, status } of prior) {
      const job = after.get(id);
      if (!job) { badConfig.push(`${id}: not listed`); continue; }
      if (job.status !== status) statusChanges[`${status}->${job.status}`] = (statusChanges[`${status}->${job.status}`] ?? 0) + 1;
      try { JSON.parse(job.config_json); } catch { badConfig.push(id); }
      const log = localPath(job.log_path);
      if (log?.kind === "external") logs.external.push(job.log_path);
      else if (log && !existsSync(log.path)) logs.missing.push(relative(home, log.path));
      else if (log) {
        logs[log.kind]++;
        try {
          const events = ndjson(readFileSync(log.path, "utf8"));
          // Terminal rows replay through the job stream route when the app can read the recorded path itself.
          if (log.kind === "inside" && (job.status === "done" || job.status === "failed")) {
            const stream = await routes.handle(new Request(`http://local/api/jobs/${id}/stream`, { signal: AbortSignal.timeout(10_000) }));
            const replay = (await stream!.text()).split("\n").filter(line => line.startsWith("data: "));
            if (replay.length >= events.filter(event => event.type !== "done" && event.type !== "failed").length) logs.replayed++;
            else logs.unreadable.push(id);
          }
        } catch (error) { logs.unreadable.push(`${id}: ${message(error)}`); }
      }
      const output = localPath(job.output_path);
      if (output?.kind === "external") outputs.external.push(job.output_path!);
      else if (output) (existsSync(output.path) ? outputs[output.kind]++ : outputs.missing.push(relative(home, output.path)));
    }
    return { rows: prior.length, listed: listing.jobs.length,
      byStatus: prior.reduce<Record<string, number>>((out, { status }) => ({ ...out, [status]: (out[status] ?? 0) + 1 }), {}),
      statusChanges, badConfig, logs, outputs };
  } finally { await host.close(); }
}

// ---- memory vault, its Reference links, and the memory database -------------
async function vault() {
  const { vaultRoot } = await import("../../src/memory/vault");
  const { createMemoryRoutes } = await import("../../src/server/memory-routes");
  const { scheduleStatus } = await import("../../src/memory/schedule");
  const root = vaultRoot();
  // launchd is the real system's: the probe answers "not loaded" rather than asking it.
  const routes = createMemoryRoutes({ root: () => root, schedule: () => scheduleStatus({ home, launchctl: async () => false }) });
  const get = async (path: string) => (await routes.handle(new Request(`http://local${path}`)))!;
  const status = await (await get("/api/memory/status")).json() as { enabled?: boolean; status?: { articleCount: number; referenceCount: number; isGitRepo: boolean } };
  const symlinks: { path: string; target: string; state: "internal" | "external" | "broken" }[] = [];
  const walk = (dir: string) => {
    for (const entry of readdirSync(dir, { withFileTypes: true }).sort((x, y) => x.name < y.name ? -1 : 1)) {
      const path = join(dir, entry.name);
      if (entry.name === ".git") continue;
      if (entry.isSymbolicLink()) {
        let state: "internal" | "external" | "broken" = "broken";
        try { state = inside(realpathSync(path), home) ? "internal" : "external"; } catch { /* dangling */ }
        symlinks.push({ path: relative(root, path), target: readlinkSync(path), state });
      } else if (entry.isDirectory()) walk(path);
    }
  };
  if (existsSync(root)) walk(root);
  if (!status.enabled) return { root: relative(home, root), enabled: false, symlinks };
  const list = await (await get("/api/memory/list")).json() as { articles: string[]; reference: string[] };
  const unreadable: string[] = [];
  for (const name of [...list.articles, ...list.reference]) {
    const response = await get(`/api/memory/article?name=${encodeURIComponent(name)}`);
    if (response.status !== 200) unreadable.push(name);
    else await response.body?.cancel();
  }
  let linkFailures = 0;
  for (const name of list.articles) if ((await get(`/api/memory/links?name=${encodeURIComponent(name)}`)).status !== 200) linkFailures++;
  const memoryDb = join(home, ".cache", "mlx-bun", "memory.sqlite");
  const dbBefore = tableCounts(memoryDb);
  let dbAfter: Record<string, number> | null = null;
  if (dbBefore) {
    const { MemoryStore } = await import("../../src/memory/db");
    new MemoryStore(memoryDb).close();
    dbAfter = tableCounts(memoryDb);
  }
  return { root: relative(home, root), enabled: true, articles: list.articles.length, reference: list.reference.length,
    git: status.status?.isGitRepo ?? false, unreadable, linkFailures, symlinks, memoryDb: { before: dbBefore, after: dbAfter } };
}

// ---- settings, credentials, registry, adapters, schedule -------------------
async function settings() {
  const { createHfCredentials } = await import("../../src/publishing/credentials");
  const { loadToolApprovals } = await import("../../src/chat/tool-approvals");
  const { scheduleStatus, plistPath } = await import("../../src/memory/schedule");
  const tokenFile = join(home, ".mlx-bun", "hf.json");
  // Presence only: the token itself never leaves this process.
  const saved = existsSync(tokenFile) &&
    createHfCredentials({ tokenFile, environment: { HOME: home }, cacheTokenPath: join(home, ".probe-no-token") }).get() !== null;
  const approvals = loadToolApprovals(join(home, ".mlx-bun", "tool-approvals.json"));
  const schedule = await scheduleStatus({ home, launchctl: async () => false });
  const plist = plistPath(home);
  const command = schedule.installed ? /<string>-lc<\/string>\s*<string>([^<]*)<\/string>/.exec(readFileSync(plist, "utf8"))?.[1]
    ?.replaceAll("&quot;", "\"").replaceAll("&apos;", "'").replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&") ?? null : null;
  const registryDb = join(home, ".cache", "mlx-bun", "registry.sqlite");
  const registryBefore = tableCounts(registryDb);
  let models: number | null = null;
  if (registryBefore) {
    const { Registry } = await import("@mlx-bun/hub/registry");
    const registry = new Registry(registryDb);
    try { models = registry.list().length; } finally { registry.close(); }
  }
  const registryAfter = tableCounts(registryDb);
  // The adapter stores the chat picker scans, plus `train`'s default output root.
  const adapters: { store: string; id: string; config: "ok" | "missing" | "unreadable"; baseModel: string | null }[] = [];
  for (const store of [".cache/mlx-bun-finetunes", ".cache/mlx-bun/adapters", ".cache/mlx-bun/mlx-bun-finetunes"]) {
    const root = join(home, store);
    if (!existsSync(root)) continue;
    for (const entry of readdirSync(root, { withFileTypes: true })) {
      const dir = join(root, entry.name);
      if (!entry.isDirectory() || !["adapters.safetensors", "adapter_model.safetensors"].some(name => existsSync(join(dir, name)))) continue;
      let config: "ok" | "missing" | "unreadable" = "missing", baseModel: string | null = null;
      for (const [name, key] of [["optiq_lora_config.json", "source_model"], ["adapter_config.json", "base_model_name_or_path"]] as const) {
        if (!existsSync(join(dir, name))) continue;
        try { baseModel ??= (JSON.parse(readFileSync(join(dir, name), "utf8")) as Record<string, unknown>)[key] as string ?? null; config = "ok"; }
        catch { config = "unreadable"; break; }
      }
      adapters.push({ store, id: entry.name, config, baseModel });
    }
  }
  return {
    credentials: { saved, mode: existsSync(tokenFile) ? (statSync(tokenFile).mode & 0o777).toString(8) : null },
    toolApprovals: { version: approvals.version, allowed: Object.keys(approvals.allows).length },
    schedule: { installed: schedule.installed, at: schedule.at, command },
    registry: { before: registryBefore, after: registryAfter, models },
    adapters,
  };
}

const section = async <T>(work: () => Promise<T>): Promise<T | { error: string }> => {
  try { return await work(); } catch (error) { return { error: message(error) }; }
};
const report = { home, originalHome: originalHome ?? null, sessions: await section(sessions), jobs: await section(jobs),
  vault: await section(vault), settings: await section(settings) };
await Bun.write(values.report, JSON.stringify(report, null, 2) + "\n");
// Unrelated handles (timers, SDK services) must not keep the probe alive.
process.exit(0);

export type UserDataReport = typeof report;
