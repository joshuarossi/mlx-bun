// Launching bench-serve and keeping its history: the runner drives the real
// script's command line, streams its output, and stores compact medians under
// the module's storage entries; nothing is written outside them.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { JobEvent } from "@mlx-bun/app-core";
import { benchDirectories, compactRun, createBenchRunner, listHistory, listProfiles, readHistory, resolvePlan } from "../src/bench";
import { fakeStorage } from "./support";

let home: string, storage: ReturnType<typeof fakeStorage>, script: string;
beforeEach(() => {
  home = mkdtempSync(join(tmpdir(), "metrics-bench-"));
  storage = fakeStorage(home);
  script = join(home, "checkout/scripts/bench-serve.ts");
  mkdirSync(join(home, "checkout/scripts"), { recursive: true });
  writeFileSync(script, "// stand-in\n");
  mkdirSync(benchDirectories(storage).plans, { recursive: true });
});
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

const plan = (cells: { skipped?: string }[] = [{}, {}, { skipped: "no kv config" }]) => JSON.stringify({ profile: "scoped", models: [{ id: "qwen" }], cells });
const RUN = {
  plan: { profile: "scoped" }, machine: { chip: "Apple M1 Max", memoryBytes: 34_359_738_368, host: "box", os: "27.0.0" },
  startedAt: "2026-09-29T12:00:00.000Z", finishedAt: "2026-09-29T12:20:00.000Z",
  cells: [
    { key: "qwen/baseline/default", model: "qwen", kind: "tree", tree: "baseline", configuration: "default",
      result: { coldStartMs: 900, peakRssMB: 1500, decodeTps: [200, 210, 190, 205, 195], ttft: { coldMs: [100, 120, 110], prefill1kTps: [3000, 3100, 2900] }, ctx: { prefillTps: 2500 }, agg: { tps: 480 } } },
    { key: "qwen/candidate/default", model: "qwen", kind: "tree", tree: "candidate", configuration: "default", failure: { error: "server exited before ready" } },
    { key: "qwen/candidate/mixed", model: "qwen", kind: "tree", tree: "candidate", configuration: "mixed", skipped: "no kv config" },
  ],
};

interface FakeRun { code?: number; lines?: string[]; record?: unknown; hang?: boolean }
/** A spawn that records its argv, prints lines, writes run.json into `--out`, and exits. */
function fakeSpawn(run: FakeRun, calls: { argv: string[]; signals: string[] }[]) {
  return ((argv: string[]) => {
    const call = { argv, signals: [] as string[] };
    calls.push(call);
    const out = argv[argv.indexOf("--out") + 1]!;
    const encode = (lines: string[]) => new ReadableStream<Uint8Array>({ start(controller) { controller.enqueue(new TextEncoder().encode(lines.join("\n") + "\n")); controller.close(); } });
    const exit = Promise.withResolvers<number>();
    const finish = () => {
      if (run.record) { mkdirSync(out, { recursive: true }); writeFileSync(join(out, "run.json"), JSON.stringify(run.record)); }
      exit.resolve(run.code ?? 0);
    };
    if (run.hang) { /* exits only when killed */ } else queueMicrotask(finish);
    return { stdout: encode(run.lines ?? []), stderr: encode([]), exited: exit.promise, pid: 1,
      kill(signal: string) { call.signals.push(signal); exit.resolve(130); } };
  }) as unknown as typeof Bun.spawn;
}

const collect = () => { const events: JobEvent[] = []; return { events, emit: (event: JobEvent) => { events.push(event); } }; };

test("a profile run starts bench-serve's own command line, reports per-cell progress and stores the compact medians", async () => {
  writeFileSync(join(benchDirectories(storage).plans, "quick.json"), plan());
  const calls: { argv: string[]; signals: string[] }[] = [];
  const runner = createBenchRunner({ storage, script, bun: "/usr/bin/bun", now: () => Date.parse("2026-09-29T12:00:00Z"),
    spawn: fakeSpawn({ lines: ["=== qwen/baseline/default ===", "  decode 200 tok/s", "=== qwen/candidate/default ===", "  FAILED: x", "COMPLETE (scoped)"], record: RUN }, calls) });
  const { events, emit } = collect();
  const result = await runner(emit, { profile: "quick" }, new AbortController().signal);

  const out = result && "outputPath" in result ? result.outputPath! : "";
  expect(calls[0]!.argv).toEqual(["/usr/bin/bun", script, "run", "--plan", join(benchDirectories(storage).plans, "quick.json"), "--out", out]);
  expect(out.startsWith(join(home, "metrics/bench/runs/"))).toBe(true);
  expect(events.filter(event => event.type === "stage").map(event => event.type === "stage" ? [event.stage, event.progress] : null)).toEqual([
    ["start", 0], ["qwen/baseline/default", 0], ["qwen/candidate/default", 0.5], ["done", 1]]);
  expect(events.filter(event => event.type === "log").map(event => event.type === "log" ? event.line : "")).toContain("  decode 200 tok/s");

  const [entry] = listHistory(storage);
  expect(entry).toMatchObject({ profile: "quick", scope: "scoped", complete: true, exitCode: 0, runDirectory: out,
    machine: { chip: "Apple M1 Max", memoryBytes: 34_359_738_368 } });
  expect(entry!.cells[0]).toEqual({ key: "qwen/baseline/default", model: "qwen", kind: "tree", tree: "baseline", configuration: "default", status: "measured",
    decodeTokensPerSecond: 200, ttftColdMs: 110, prefill1kTokensPerSecond: 3000, contextPrefillTokensPerSecond: 2500, aggregateTokensPerSecond: 480, coldStartMs: 900, peakRssMB: 1500 });
  expect(entry!.cells[1]).toMatchObject({ status: "failed", note: "server exited before ready", decodeTokensPerSecond: null });
  expect(entry!.cells[2]).toMatchObject({ status: "skipped", note: "no kv config" });
  expect(readHistory(storage, entry!.id)).toEqual(entry);
  // Only the declared entries were written.
  expect(readdirSync(home).sort()).toEqual(["checkout", "metrics"]);
  expect(readdirSync(join(home, "metrics")).sort()).toEqual(["bench", "history"]);
});

test("an incomplete run keeps its history entry with the problems bench-serve printed, and the job fails", async () => {
  writeFileSync(join(benchDirectories(storage).plans, "quick.json"), plan());
  const runner = createBenchRunner({ storage, script, bun: "bun", spawn: fakeSpawn({ code: 1, record: RUN,
    lines: ["INCOMPLETE (scoped; full qualification no; performance acceptance unreviewed) → /x", "  problem: qwen/candidate/default: failed (server exited)"] }, []) });
  await expect(runner(() => {}, { profile: "quick" }, new AbortController().signal)).rejects.toThrow("the run is incomplete (qwen/candidate/default: failed (server exited))");
  expect(listHistory(storage)[0]).toMatchObject({ complete: false, exitCode: 1, problems: ["qwen/candidate/default: failed (server exited)"] });
});

test("a run that exits without a record fails and leaves no history", async () => {
  writeFileSync(join(benchDirectories(storage).plans, "quick.json"), plan());
  const runner = createBenchRunner({ storage, script, bun: "bun", spawn: fakeSpawn({ code: 2 }, []) });
  await expect(runner(() => {}, { profile: "quick" }, new AbortController().signal)).rejects.toThrow("exited 2 before writing a run record");
  expect(listHistory(storage)).toEqual([]);
});

test("cancelling sends the child SIGTERM (bench-serve stops its servers and saves the run) and the job ends cancelled", async () => {
  writeFileSync(join(benchDirectories(storage).plans, "quick.json"), plan());
  const calls: { argv: string[]; signals: string[] }[] = [];
  const runner = createBenchRunner({ storage, script, bun: "bun", spawn: fakeSpawn({ hang: true }, calls), graceMs: 5 });
  const abort = new AbortController();
  const running = runner(() => {}, { profile: "quick" }, abort.signal);
  await Bun.sleep(5);
  abort.abort(new Error("cancelled"));
  await expect(running).rejects.toThrow("cancelled");
  expect(calls[0]!.signals).toEqual(["SIGTERM"]);
});

test("without a checkout or a Bun on PATH the run says so instead of failing obscurely", async () => {
  const runner = createBenchRunner({ storage, script: join(home, "missing/bench-serve.ts"), bun: "bun" });
  await expect(runner(() => {}, { profile: "x" }, new AbortController().signal)).rejects.toThrow("bench-serve needs a source checkout");
});

test("a plan is a profile in the plans directory or an absolute .json path, never both, and names are checked", () => {
  writeFileSync(join(benchDirectories(storage).plans, "quick.json"), plan());
  expect(resolvePlan(storage, { profile: "quick" })).toEqual({ name: "quick", path: join(benchDirectories(storage).plans, "quick.json") });
  const elsewhere = join(home, "elsewhere.json");
  writeFileSync(elsewhere, plan());
  expect(resolvePlan(storage, { plan: elsewhere })).toEqual({ name: "elsewhere", path: elsewhere });
  expect(() => resolvePlan(storage, { profile: "quick", plan: elsewhere })).toThrow("not both");
  expect(() => resolvePlan(storage, { profile: "../etc/passwd" })).toThrow("invalid profile name");
  expect(() => resolvePlan(storage, { profile: "missing" })).toThrow('no profile "missing"');
  expect(() => resolvePlan(storage, { plan: "relative.json" })).toThrow("absolute path");
  expect(() => resolvePlan(storage, {})).toThrow("name a profile");
});

test("profiles list the plans by name with their scope and models; history lists newest first and skips unreadable files", () => {
  writeFileSync(join(benchDirectories(storage).plans, "b.json"), plan());
  writeFileSync(join(benchDirectories(storage).plans, "a.json"), "{not json");
  writeFileSync(join(benchDirectories(storage).plans, "notes.txt"), "x");
  expect(listProfiles(storage)).toEqual([
    { name: "a", path: join(benchDirectories(storage).plans, "a.json"), scope: null, models: [] },
    { name: "b", path: join(benchDirectories(storage).plans, "b.json"), scope: "scoped", models: ["qwen"] }]);
  const { history } = benchDirectories(storage);
  mkdirSync(history, { recursive: true });
  const entry = (id: string, startedAt: string) => JSON.stringify(compactRun({ cells: [] }, { id, profile: "p", exitCode: 0, problems: [], runDirectory: "/r", startedAt, finishedAt: null, durationMs: 1 }));
  writeFileSync(join(history, "old.json"), entry("old", "2026-01-01T00:00:00.000Z"));
  writeFileSync(join(history, "new.json"), entry("new", "2026-09-01T00:00:00.000Z"));
  writeFileSync(join(history, "bad.json"), "{");
  expect(listHistory(storage).map(item => item.id)).toEqual(["new", "old"]);
  expect(listHistory(storage, 1).map(item => item.id)).toEqual(["new"]);
  expect(readHistory(storage, "../../etc/passwd")).toBeUndefined();
  expect(readHistory(storage, "nope")).toBeUndefined();
});
