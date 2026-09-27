import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { completionProbe, decodeStable, measureChatRequest, probeVerdict, runCell, scaledBudgetMs, ServerProcess, waitReady,
  workloadNonce, type CellResult, type ReqResult } from "./measure";
import { CANONICAL, checkOutputDirectory, describeModel, nativeFiles, planCells, profileProblems, sourceSnapshot, validatePlan,
  WORKLOAD, type Plan } from "./plan";
import { comparePair, qualification, type CellRecord, type RunRecord } from "./report";
import { run } from "../bench-serve";

const FAKE = resolve(import.meta.dir, "fixtures/fake-server.ts");
const scratch = realpathSync(mkdtempSync(join(tmpdir(), "bench-serve-test-")));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));
let counter = 0;
const fresh = (name: string) => { const dir = join(scratch, `${name}-${counter++}`); mkdirSync(dir, { recursive: true }); return dir; };

function repo(): string {
  const dir = fresh("tree");
  writeFileSync(join(dir, "serve.ts"), "// tree marker\n");
  for (const args of [["init", "-q"], ["add", "-A"], ["-c", "user.email=t@t", "-c", "user.name=t", "commit", "-qm", "init"]])
    expect(Bun.spawnSync(["git", "-C", dir, ...args]).exitCode).toBe(0);
  return dir;
}
function artifact(options: { kvConfig?: boolean; modelType?: string; trellis?: boolean } = {}): string {
  const dir = fresh("model");
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: options.modelType ?? "fake",
    ...(options.trellis ? { quantization: { mode: "trellis" } } : {}) }));
  writeFileSync(join(dir, "model.safetensors"), "weights-bytes");
  if (options.kvConfig) writeFileSync(join(dir, "kv_config.json"), "{}");
  return dir;
}
function library(): string {
  const dir = fresh("native");
  for (const name of ["libmlxc.dylib", "libmlx.dylib", "libjaccl.dylib", "mlx.metallib"]) writeFileSync(join(dir, name), `${name}-bytes`);
  return join(dir, "libmlxc.dylib");
}
const TEST_SPREAD_LIMIT = 2;
const serveCommand = (mode = "ok", extra: string[] = []) => [process.execPath, FAKE, "--fake-mode", mode, ...extra];
function testPlan(modes: { baseline?: string; candidate?: string } = {}, patch: Partial<Plan> = {}): Plan {
  const baseline = repo(), candidate = repo(), lib = library();
  const plan: Plan = { schema: 1, profile: "scoped", seed: "test-seed",
    // Short streams, and a test-only stability guard: fake timer jitter is not a server property.
    // Any override makes the run non-qualifying; profile all rejects it.
    workload: { ...WORKLOAD, decodeTokens: 8, contextTokens: 64, aggregateTokens: 8, spreadLimit: TEST_SPREAD_LIMIT, withContext: true },
    trees: { baseline: { root: baseline, commit: sourceSnapshot(baseline).head, command: serveCommand(modes.baseline) },
      candidate: { root: candidate, commit: sourceSnapshot(candidate).head, command: serveCommand(modes.candidate) } },
    references: [], configurations: ["default"], models: [describeModel("fake", artifact())],
    native: { library: lib, files: nativeFiles(lib) }, cells: [], ...patch };
  return { ...plan, cells: planCells(plan) };
}
const workload = { seed: "test-seed", ...WORKLOAD, decodeTokens: 8, contextTokens: 64, aggregateTokens: 8, withContext: true };
async function freePort() { const l = Bun.listen({ hostname: "127.0.0.1", port: 0, socket: { data() {} } }); const p = l.port; l.stop(true); return p; }
const cellSpec = async (mode: string, extra: string[] = []) => {
  const port = await freePort();
  return { key: `fake/${mode}`, model: { id: "fake", path: artifact() }, command: [...serveCommand(mode, extra), "--port", String(port)],
    env: { PATH: process.env.PATH ?? "" }, port, flushBeforeRestart: true, logPath: join(fresh("log"), "stderr.log") };
};
const writePlan = (plan: Plan) => { const path = join(fresh("plan"), "plan.json"); writeFileSync(path, JSON.stringify(plan)); return path; };
const runRecord = (out: string) => JSON.parse(readFileSync(join(out, "run.json"), "utf8")) as RunRecord;

// ---- plan and matrix -----------------------------------------------------------
test("profile all must be main's full matrix; scoped plans say so", () => {
  const plan = testPlan();
  expect(validatePlan(plan).profile).toBe("scoped");
  const all = { ...plan, profile: "all" as const };
  expect(profileProblems(all).join("; ")).toContain(`are not ${CANONICAL.models}`);
  expect(profileProblems(all).join("; ")).toContain("workload spreadLimit differs from main");
  expect(() => validatePlan(all)).toThrow("profile all is not main's full matrix");
  expect(() => validatePlan({ ...plan, cells: plan.cells.slice(1) })).toThrow("predeclared cells do not match");
  expect(() => validatePlan({ ...plan, trees: { ...plan.trees, candidate: plan.trees.baseline } })).toThrow("different trees");
});

test("applicability follows main: mixed needs kv_config, the stock reference cannot load packed trellis, register for gemma4_unified", () => {
  const reference = { label: "mlx-lm", command: ["python", "-m", "mlx_lm.server"] };
  const plan = testPlan({}, { configurations: ["default", "serial", "mixed"], references: [reference],
    models: [describeModel("plain", artifact()), describeModel("kv", artifact({ kvConfig: true })),
      describeModel("trellis", artifact({ trellis: true, kvConfig: true })), describeModel("unified", artifact({ modelType: "gemma4_unified" }))] });
  const na = Object.fromEntries(plan.cells.filter(cell => cell.skipped).map(cell => [cell.key, cell.skipped]));
  expect(Object.keys(na).sort()).toEqual(["plain/mixed/baseline", "plain/mixed/candidate", "trellis/mlx-lm", "unified/mixed/baseline",
    "unified/mixed/candidate", "unified/mlx-lm"].sort());
  expect(na["trellis/mlx-lm"]).toContain("packed trellis");
  // Every applicable tree cell has both trees; pairs alternate which tree goes first.
  const kv = plan.cells.filter(cell => cell.model === "kv" && cell.kind === "tree");
  expect(kv.map(cell => cell.tree)).toEqual(["candidate", "baseline", "baseline", "candidate", "candidate", "baseline"]);
  expect(profileProblems({ ...plan, profile: "all" }).join("; ")).toContain("mlx-lm has no register command for unified");
});

test("the pinned native library is the exact resolved file supplied plus its bundled runtime", () => {
  const lib = library(), link = join(fresh("link"), "chosen.dylib");
  symlinkSync(lib, link);
  const files = nativeFiles(link);
  expect(files[0]!.path).toBe(realpathSync(lib));
  expect(files.map(file => file.name)).toEqual(["libmlxc.dylib", "libjaccl.dylib", "libmlx.dylib", "mlx.metallib"]);
});

test("captures stay outside every measured tree and start empty", () => {
  const tree = repo();
  expect(() => checkOutputDirectory(join(tree, "reports"), [tree])).toThrow("inside source tree");
  const busy = fresh("busy"); writeFileSync(join(busy, "x"), "x");
  expect(() => checkOutputDirectory(busy, [tree])).toThrow("must be empty");
  expect(checkOutputDirectory(join(fresh("out"), "run"), [tree])).toContain("run");
});

test("deterministic workload identity, budgets and probe verdicts", () => {
  expect(workloadNonce("s", "decode", 0, 2)).toBe(workloadNonce("s", "decode", 0, 2));
  expect(workloadNonce("s", "decode", 1, 2)).not.toBe(workloadNonce("s", "decode", 0, 2));
  expect(scaledBudgetMs(1000, 0, 5000)).toBe(600_000);
  expect(scaledBudgetMs(1000, 100, 5000)).toBe(40_000);
  const probe = (text: string, promptTokens = 3, completionTokens = 2, finishReason = "length") => ({ text, promptTokens, completionTokens, finishReason });
  expect(probeVerdict("chat", "x", probe("a"), probe("a", 4)).ok).toBe(false);
  expect(probeVerdict("chat", "x", probe("ab"), probe("ab")).ok).toBe(true);
  expect(probeVerdict("chat", "x", probe("ab"), probe("ac")).line).toContain("diverged at char 1");
  // Empty output never establishes parity; equal text with different counts is not parity.
  expect(probeVerdict("completion", "x", probe(""), probe("")).ok).toBeNull();
  expect(probeVerdict("chat", "x", probe("ab", 3, 2), probe("ab", 3, 5)).ok).toBe(false);
  // Main's stability guard, exactly: max/min of one arm's decode samples at most 1.15.
  expect(WORKLOAD.spreadLimit).toBe(1.15);
  expect(decodeStable([100, 104, 115, 101, 110], WORKLOAD.spreadLimit)).toBe(true);
  expect(decodeStable([100, 104, 116, 101, 110], WORKLOAD.spreadLimit)).toBe(false);
  expect(decodeStable([], WORKLOAD.spreadLimit)).toBe(false);
  expect(decodeStable([100, 0], WORKLOAD.spreadLimit)).toBe(false);
});

// ---- supervision and cleanup ------------------------------------------------------
test("a server that exits during startup fails the cell after a confirmed join, with its stderr", async () => {
  const error = await runCell(await cellSpec("exit"), workload, [], { readyTimeoutMs: 10_000, settleMs: 0 }).catch(e => e);
  expect(String(error)).toContain("server exited before ready");
  expect(error.processes.every((p: { joined: boolean }) => p.joined)).toBe(true);
  expect(error.stderrTail.join("\n")).toContain("fake startup failure marker");
});

test("a server that never becomes ready times out and is joined", async () => {
  const error = await runCell(await cellSpec("never-ready"), workload, [], { readyTimeoutMs: 1500, settleMs: 0 }).catch(e => e);
  expect(String(error)).toContain("not ready after 1500 ms");
  expect(error.processes).toHaveLength(1);
  expect(error.processes[0]).toMatchObject({ joined: true, actions: ["SIGTERM"] });
});

test("a server ignoring TERM is killed and joined", async () => {
  const spec = await cellSpec("ignore-term");
  const server = new ServerProcess(spec.command, spec.env, [], spec.logPath);
  await waitReady(`http://127.0.0.1:${spec.port}`, undefined, 10_000);
  const stopped = await server.stop(300);
  expect(stopped).toMatchObject({ joined: true, actions: ["SIGTERM", "SIGKILL"], signal: "SIGKILL" });
  expect(ServerProcess.live.has(server)).toBe(false);
});

test("a descendant that outlives its exited leader is stopped before the server counts as joined", async () => {
  // The leader starts a child in its process group, reports it, and exits 0.
  const tail: string[] = [];
  const server = new ServerProcess([process.execPath, "-e",
    "const c = Bun.spawn(['sleep', '60']); console.error('child ' + c.pid); await Bun.sleep(200); process.exit(0);"],
    { PATH: process.env.PATH ?? "" }, tail, join(fresh("log"), "stderr.log"));
  await server.exited;
  const child = Number(tail.find(line => line.startsWith("child "))!.slice(6));
  const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };
  expect(alive(child)).toBe(true);
  expect(server.groupAlive).toBe(true);
  const stopped = await server.stop(500);
  expect(stopped).toMatchObject({ joined: true, actions: ["SIGTERM"], exitCode: 0 });
  expect(alive(child)).toBe(false);
  expect(server.groupAlive).toBe(false);
});

test("an aborted stream releases its connection", async () => {
  const log = join(fresh("drain"), "disconnects.log");
  const spec = await cellSpec("slow", ["--fake-disconnect-log", log]);
  const server = new ServerProcess(spec.command, spec.env, [], spec.logPath);
  try {
    const base = `http://127.0.0.1:${spec.port}`;
    await waitReady(base, undefined, 10_000);
    const started = performance.now();
    await expect(measureChatRequest(base, "hello", 32, { timeoutMs: 500 })).rejects.toThrow();
    expect(performance.now() - started).toBeLessThan(3000);
    for (let i = 0; i < 30 && !existsSync(log); i++) await Bun.sleep(100);
    expect(readFileSync(log, "utf8")).toContain("disconnect");
  } finally { expect((await server.stop()).joined).toBe(true); }
});

// ---- whole runs --------------------------------------------------------------------
const quick = { readyTimeoutMs: 10_000, settleMs: 0 };

test("a complete scoped run: every phase on both trees, matched samples, unreviewed performance", async () => {
  const out = join(fresh("run"), "out"), plan = testPlan();
  plan.trees.candidate.command = serveCommand("ok", ["--fake-touch", "relative-output.txt"]);
  expect(await run(writePlan(plan), out, quick)).toBe(0);
  const record = runRecord(out), q = qualification(record);
  expect(q).toMatchObject({ complete: true, fullQualification: false, profile: "scoped", performanceAcceptance: "unreviewed" });
  expect(q.notes.join("\n")).toContain(`spreadLimit ${TEST_SPREAD_LIMIT}`);
  // Servers start in their sandbox: a relative output lands there, never in a tree.
  expect(existsSync(join(out, "sandboxes", "fake-default-candidate", "relative-output.txt"))).toBe(true);
  expect(record.cells.map(cell => cell.result!.measured)).toEqual([0, 1].map(() => ["warmup", "parity", "decode", "ttft1k", "ctx", "restart", "agg"]));
  expect(record.cells.every(cell => cell.result!.loadedLibraries!.some(lib => lib.path === record.plan.native.files[0]!.path))).toBe(true);
  expect(record.pins.end).toEqual([]);
  const decode = comparePair(record, "fake", "default")!.find(metric => metric.metric === "decode")!;
  expect(decode.pairs).toHaveLength(5);
  expect(decode.observation).not.toBe("unpaired");
  const report = readFileSync(join(out, "report.md"), "utf8");
  expect(report).toContain("performance acceptance: **unreviewed**");
  // Context size is a nominal target; the report shows what each server actually counted.
  const [baselineCell, candidateCell] = (["baseline", "candidate"] as const).map(tree => record.cells.find(cell => cell.tree === tree)!.result!);
  expect(baselineCell!.ctx!.promptTokens).not.toBe(record.plan.workload.contextTokens);
  expect(report).toContain(`nominal context target ${record.plan.workload.contextTokens}`);
  expect(report).toContain(`| ctx | ${record.plan.workload.contextTokens} | ${baselineCell!.ctx!.promptTokens} | ${candidateCell!.ctx!.promptTokens} |`);
  // Sandboxed servers: nothing written into either tree.
  for (const tree of ["baseline", "candidate"] as const) expect(sourceSnapshot(record.plan.trees[tree].root).clean).toBe(true);
}, 120_000);

test("unstable decode, a missing phase, divergent or empty probes and a foreign runtime library each make the run incomplete", async () => {
  for (const [mode, expected] of [["unstable", "unstable decode"], ["no-flush", "required phases missing: restart"],
    ["diverge", "chat probe"], ["empty-probe", "required phases missing: parity"]] as const) {
    const out = join(fresh("run"), "out");
    expect(await run(writePlan(testPlan({ candidate: mode })), out, quick)).toBe(1);
    expect(qualification(runRecord(out)).problems.join("\n")).toContain(expected);
  }
  // A second MLX runtime file mapped from elsewhere fails provenance even though the chosen library matches.
  const foreign = join(fresh("foreign"), "libmlx.dylib");
  writeFileSync(foreign, "other-libmlx-bytes");
  const plan = testPlan();
  plan.trees.candidate.command = serveCommand("ok", ["--fake-open", foreign]);
  const out = join(fresh("run"), "out");
  expect(await run(writePlan(plan), out, quick)).toBe(1);
  expect(qualification(runRecord(out)).problems.join("\n")).toContain(`loaded ${foreign}`);
}, 300_000);

test("an aggregate failure settles every sibling before the retry; the retry never overlaps or reuses ids", async () => {
  const plan = testPlan({ candidate: "agg-fail" });
  plan.workload.aggregateStaggerMs = 150;
  const out = join(fresh("run"), "out");
  // Only the candidate retried, with new request identities: its aggregate cannot pair, so the run is incomplete.
  expect(await run(writePlan(plan), out, quick)).toBe(1);
  const record = runRecord(out);
  expect(qualification(record).problems.join("\n")).toContain("fake/default agg: final attempts do not pair");
  expect(record.cells.every(cell => cell.result!.processes.every(stop => stop.joined))).toBe(true);
  const agg = record.requests.filter(q => q.cell.endsWith("candidate") && q.phase === "agg");
  const first = agg.filter(q => q.attempt === 0), retry = agg.filter(q => q.attempt === 1);
  expect(first.some(q => q.error?.includes("injected aggregate failure"))).toBe(true);
  expect(retry.map(q => q.index).sort()).toEqual([0, 1, 2, 3]);
  expect(retry.every(q => q.result)).toBe(true);
  // Delayed starts of the failed attempt never began, and all of it settled before the retry sent anything.
  expect(first.every(q => q.index < 2)).toBe(true);
  expect(Math.max(...first.map(q => q.settledMs!))).toBeLessThanOrEqual(Math.min(...retry.map(q => q.startedMs!)));
  expect(qualification(record).notes.join("\n")).toContain("recovered on retry: agg");
  // The retried attempt has different request identities, so its aggregate cannot pair with the baseline.
  expect(comparePair(record, "fake", "default")!.find(m => m.metric === "aggregate stream decode")!.observation).toBe("unpaired");
}, 120_000);

test("a server that cannot be joined stops the whole campaign", async () => {
  const plan = testPlan(), out = join(fresh("run"), "out");
  const original = ServerProcess.prototype.stop;
  let reported = false;
  ServerProcess.prototype.stop = async function (this: ServerProcess, ...args: Parameters<typeof original>) {
    const result = await original.apply(this, args); // really stopped; reported as unjoined once
    if (!reported) { reported = true; return { ...result, joined: false }; }
    return result;
  };
  try { expect(await run(writePlan(plan), out, quick)).toBe(1); }
  finally { ServerProcess.prototype.stop = original; }
  const record = runRecord(out);
  expect(record.fatal).toContain("was not joined");
  expect(record.cells).toHaveLength(1);
  expect(qualification(record).problems.join("\n")).toContain("campaign stopped");
}, 60_000);

test("qualification reconciles the observed inventory with the recomputed matrix", async () => {
  const out = join(fresh("run"), "out");
  expect(await run(writePlan(testPlan()), out, quick)).toBe(0);
  const complete = runRecord(out);
  const variant = (change: (r: RunRecord) => void) => { const copy = structuredClone(complete); change(copy); return qualification(copy); };
  expect(variant(r => { r.cells = r.cells.filter(c => c.tree !== "candidate"); }).problems.join()).toContain("was never recorded");
  expect(variant(r => { r.cells.push(structuredClone(r.cells[0]!)); }).problems.join()).toContain("recorded 2 times");
  expect(variant(r => { r.cells[0]!.skipped = "invented reason"; }).problems.join()).toContain("applicability differs");
  expect(variant(r => { delete (r.cells[0] as Partial<CellRecord>).result; }).problems.join()).toContain("no result or failure");
  expect(variant(r => { r.plan.cells = r.plan.cells.slice(1); }).problems.join()).toContain("predeclared cells do not match");
  expect(variant(r => { r.tool.end = { ...r.tool.end!, sha256: "changed" }; }).problems.join()).toContain("tooling changed");
  // Every phase label kept, but samples or backing requests removed.
  expect(variant(r => { r.cells[0]!.result!.decodeTps = []; }).problems.join()).toContain("decode result is incomplete (0 of 5 samples)");
  expect(variant(r => { r.requests = r.requests.filter(q => !(q.cell === r.cells[0]!.key && q.phase === "agg")); }).problems.join())
    .toContain("agg has 0 successful of 0 final-attempt requests, expected 4");
  expect(variant(r => { r.requests = r.requests.filter(q => q.cell !== r.cells[1]!.key); }).problems.join())
    .toContain("warmup has 0 successful of 0 final-attempt requests, expected 1");
  expect(variant(r => { r.cells[1]!.result!.ttft!.coldMs.pop(); }).problems.join()).toContain("ttft1k result is incomplete");
  // The stability guard is recomputed from the samples against the plan's limit: 1.15 passes, 1.16 fails.
  const spread = (top: number) => variant(r => { r.plan.workload.spreadLimit = 1.15; r.cells[0]!.result!.decodeTps = [100, 104, top, 101, 110]; });
  expect(spread(115).problems.join()).not.toContain("unstable decode");
  expect(spread(116).problems.join()).toContain("unstable decode spread 1.16 exceeds the 1.15 stability guard");
  // A one-sided retry of a paired phase, or a differing finish reason, leaves the phase unpaired.
  expect(variant(r => { for (const q of r.requests) if (q.cell === r.cells[1]!.key && q.phase === "decode") q.attempt = 1; })
    .problems.join()).toContain("fake/default decode: final attempts do not pair");
  expect(variant(r => { const candidate = r.cells.find(c => c.tree === "candidate")!.key;
    const q = r.requests.find(q => q.cell === candidate && q.phase === "ttft1k")!; q.result!.finishReason = "stop"; })
    .problems.join()).toContain("finish length/stop");
  // The tooling tree must be clean for full qualification.
  expect(variant(r => { r.tool.start.clean = false; }).fullQualification).toBe(false);
}, 120_000);

test("the completion probe rejects a response without real output", async () => {
  const spec = await cellSpec("empty-probe");
  const server = new ServerProcess(spec.command, spec.env, [], spec.logPath);
  try {
    const base = `http://127.0.0.1:${spec.port}`;
    await waitReady(base, undefined, 10_000);
    await expect(completionProbe(base, "The first eight prime numbers are", {})).rejects.toThrow("invalid completion probe response");
  } finally { expect((await server.stop()).joined).toBe(true); }
});

test("a parent SIGTERM stops and joins the running server, saves the run and exits 130", async () => {
  const plan = testPlan({ baseline: "slow", candidate: "slow" }), out = join(fresh("run"), "out");
  const child = Bun.spawn([process.execPath, resolve(import.meta.dir, "../bench-serve.ts"), "run", "--plan", writePlan(plan),
    "--out", out, "--ready-timeout-ms", "10000"], { stdout: "pipe", stderr: "pipe" });
  for (let i = 0; i < 100; i++) {
    if (existsSync(join(out, "run.json")) && runRecord(out).cells.some(cell => cell.command)) break;
    await Bun.sleep(100);
  }
  await Bun.sleep(1500); // mid-request on the slow server
  child.kill("SIGTERM");
  expect(await child.exited).toBe(130);
  const record = runRecord(out);
  expect(record.interrupted).toBe("SIGTERM");
  expect(record.interruptCleanup!.every(stop => stop.joined)).toBe(true);
  expect(qualification(record).complete).toBe(false);
  const leftover = Bun.spawnSync(["pgrep", "-f", plan.models[0]!.path]);
  expect(leftover.stdout.toString().trim()).toBe("");
}, 60_000);

// ---- paired comparison --------------------------------------------------------------
const cellResult = (rss: number): CellResult => ({ key: "", readyMs: 100, idleRssMB: rss, parity: null, peakRssMB: rss,
  rssByLeg: [["decode", rss]], coldStartMs: 200, restart: null, decodeTps: [], decodeSpread: 1, decodeStable: true, ttft: null,
  ctx: null, agg: null, phaseFailures: [], measured: [], loadedLibraries: null, processes: [] });
const reqResult = (decodeTps: number, counts: Partial<ReqResult> = {}) =>
  ({ decodeTps, wallMs: 1000, ttftMs: 10, promptTokens: 20, genTokens: 8, cachedTokens: 0, finishReason: "length", ...counts }) as ReqResult;
function comparisonRecord(requests: Array<{ cell: "a" | "b"; attempt: number; index: number; sha: string; result: ReqResult }>, rss = [1000, 1000]) {
  const plan = testPlan();
  const cell = (key: string, tree: string, order: number, r: number) => ({ key, model: "fake", kind: "tree", tree, configuration: "default",
    order, command: [], intendedLibrary: null, result: cellResult(r) });
  return { plan, cells: [cell("a", "baseline", 0, rss[0]!), cell("b", "candidate", 1, rss[1]!)],
    requests: requests.map(q => ({ cell: q.cell, phase: "decode", attempt: q.attempt, index: q.index, requestSha256: q.sha,
      request: { content: "", maxTokens: 8, bodyExtra: {} }, result: q.result })) } as unknown as RunRecord;
}
const metric = (record: RunRecord, name: string) => comparePair(record, "fake", "default")!.find(m => m.metric === name)!;

test("the paired comparison flags any worse candidate median without a tolerance", () => {
  const requests = [0, 1, 2, 3, 4].flatMap(i => [{ cell: "a" as const, attempt: 0, index: i, sha: `h${i}`, result: reqResult(100) },
    { cell: "b" as const, attempt: 0, index: i, sha: `h${i}`, result: reqResult(99.9) }]);
  const record = comparisonRecord(requests, [1000, 1000.5]);
  expect(metric(record, "decode")).toMatchObject({ observation: "candidate worse", baselineMedian: 100, candidateMedian: 99.9 });
  expect(metric(record, "decode").pairs).toHaveLength(5);
  expect(metric(record, "decode").ratio).toBeCloseTo(0.999, 6);
  // Identical workloads: cell-level memory pairs too, and any increase is flagged.
  expect(metric(record, "peak RSS").observation).toBe("candidate worse");
  expect(metric(record, "ready").observation).toBe("equal");
});

test("unmatched workloads are raw evidence, never a paired ratio", () => {
  // Baseline attempt 0 (hash A) against candidate attempt 1 (hash B): nothing pairs.
  const record = comparisonRecord([{ cell: "a", attempt: 0, index: 0, sha: "hashA", result: reqResult(10) },
    { cell: "b", attempt: 1, index: 0, sha: "hashB", result: reqResult(20) }]);
  expect(metric(record, "decode")).toMatchObject({ observation: "unpaired", ratio: null, pairs: [],
    unpaired: { baseline: [10], candidate: [20] } });
  expect(metric(record, "peak RSS")).toMatchObject({ observation: "unpaired", ratio: null });
  // Same identity but different observed counts or cache state: excluded, with the reason.
  const mismatched = comparisonRecord([{ cell: "a", attempt: 0, index: 0, sha: "h", result: reqResult(10) },
    { cell: "b", attempt: 0, index: 0, sha: "h", result: reqResult(20, { genTokens: 5, cachedTokens: 4 }) }]);
  expect(metric(mismatched, "decode")).toMatchObject({ observation: "unpaired", ratio: null });
  expect(metric(mismatched, "decode").excluded.join()).toContain("output tokens 8/5; cached tokens 0/4");
  const finished = comparisonRecord([{ cell: "a", attempt: 0, index: 0, sha: "h", result: reqResult(10) },
    { cell: "b", attempt: 0, index: 0, sha: "h", result: reqResult(20, { finishReason: "stop" }) }]);
  expect(metric(finished, "decode").excluded.join()).toContain("finish length/stop");
});

test("only each phase's final attempt is compared; abandoned partial attempts stay raw", () => {
  // Both arms lost request 4 on attempt 0 and retried the phase; attempt 0's four successes must not pair.
  const abandoned = [0, 1, 2, 3].flatMap(i => [{ cell: "a" as const, attempt: 0, index: i, sha: `old${i}`, result: reqResult(105) },
    { cell: "b" as const, attempt: 0, index: i, sha: `old${i}`, result: reqResult(99) }]);
  const accepted = [0, 1, 2, 3, 4].flatMap(i => (["a", "b"] as const).map(cell => ({ cell, attempt: 1, index: i, sha: `new${i}`,
    result: reqResult(100 + i) })));
  const decode = metric(comparisonRecord([...abandoned, ...accepted]), "decode");
  expect(decode.pairs.map(p => p.id.split("|")[1])).toEqual(["1", "1", "1", "1", "1"]);
  expect(decode).toMatchObject({ baselineMedian: 102, candidateMedian: 102, observation: "equal" });
});
