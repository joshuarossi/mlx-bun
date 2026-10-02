// The runner wiring: the module drives the real script's command lines (plan, run,
// compare, tasks), streams its output, and keeps the compact scores under its
// storage entries. The last cases run the real script for what needs no server.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { JobEvent } from "@mlx-bun/app-core";
import { CHECKOUT, compactResult, compareRuns, createEvalRunner, evalDirectories, listHistory, listTasks, readHistory, resolveModel, taskSpec, type EvalOptions } from "../src/evals";
import type { EvalHistoryEntry } from "../src/protocol";
import { fakeCatalog, fakeModels, fakeResult, fakeSpawn, fakeStorage, type Call, type FakeRun } from "./support";

let home: string, storage: ReturnType<typeof fakeStorage>, root: string, script: string, native: string;
beforeEach(() => {
  home = mkdtempSync(join(tmpdir(), "benchmarks-evals-"));
  storage = fakeStorage(home);
  root = join(home, "checkout");
  script = join(root, "scripts/eval-serve.ts");
  native = join(home, "libmlxc.dylib");
  mkdirSync(join(root, "scripts"), { recursive: true });
  writeFileSync(script, "// stand-in\n");
  writeFileSync(native, "");
});
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

const options = (extra: Partial<EvalOptions> = {}): EvalOptions => ({ storage, models: fakeModels, catalog: fakeCatalog, root, script, native, bun: "/usr/bin/bun",
  now: () => Date.parse("2026-09-29T12:00:00Z"), ...extra });
const collect = () => { const events: JobEvent[] = []; return { events, emit: (event: JobEvent) => { events.push(event); } }; };
const signal = () => new AbortController().signal;

const RUN_LINES = ["=== label: bun /x/mlx-bun.mjs serve --model /models/served --port 1", "--- gsm8k-50", "gsm8k-50: 42.00% (complete)", "--- mmlu", "mmlu: 50.00% (complete)",
  "COMPLETE (id; score acceptance unreviewed) → /out"];

test("a run pins the served model and datasets with the runner's plan, then runs the plan against the app's own serve command", async () => {
  const calls: Call[] = [];
  const runner = createEvalRunner(options({ spawn: fakeSpawn(sub => sub === "plan" ? {} : { lines: RUN_LINES, errors: ["\r  gsm8k-50 25/50\r  gsm8k-50 50/50", "\r  mmlu 25/970\r  mmlu 970/970\n"], result: fakeResult() }, calls) }));
  const { events, emit } = collect();
  const result = await runner(emit, { tasks: "gsm8k-50,mmlu" }, signal());

  const id = "2026-09-29T12-00-00-000Z-gsm8k-50-mmlu", plan = join(home, `benchmarks/plans/${id}.json`), out = join(home, `benchmarks/runs/${id}`);
  expect(result).toEqual({ outputPath: out });
  expect(calls.map(call => call.argv)).toEqual([
    ["/usr/bin/bun", script, "plan", "--out", plan, "--model", "/models/served", "--data", join(home, "benchmarks/data"), "--native", native, "--tasks", "gsm8k-50,mmlu"],
    ["/usr/bin/bun", script, "run", "--plan", plan, "--root", root, "--command", JSON.stringify(["/usr/bin/bun", join(root, "apps/mlx-bun/bin/mlx-bun.mjs"), "serve"]), "--out", out, "--label", id]]);
  // Progress across both tasks of the plan: task starts (stdout) and the redrawn item counters (stderr, a separate pipe), each in order.
  const progress = events.flatMap(event => event.type === "stage" ? [[event.stage, event.progress, event.message ?? ""] as const] : []);
  expect(progress.filter(stage => stage[2].startsWith("task ")).map(stage => stage.slice(0, 2))).toEqual([["gsm8k-50", 0], ["mmlu", 0.5]]);
  expect(progress.filter(stage => /\d+\/\d+$/.test(stage[2])).map(stage => [stage[2], stage[1]])).toEqual([
    ["gsm8k-50 25/50", 0.25], ["gsm8k-50 50/50", 0.5], ["mmlu 25/970", 0.5 + 25 / 970 / 2], ["mmlu 970/970", 0.99]]);
  expect([progress[0]!.slice(0, 2), progress.at(-1)!.slice(0, 2)]).toEqual([["start", 0], ["done", 1]]);
  expect(events.filter(event => event.type === "log").map(event => event.type === "log" ? event.line : "")).toContain("mmlu: 50.00% (complete)");

  const [entry] = listHistory(storage);
  expect(entry).toMatchObject({ id, complete: true, exitCode: 0, runDirectory: out, enableThinking: false, model: { path: "/models/served", repo: "org/served" },
    machine: { chip: "Apple M1 Max", memoryBytes: 34_359_738_368 }, capability: { score: 50, components: { MMLU: 50 } } });
  expect(entry!.tasks).toEqual([
    { task: "gsm8k-50", status: "complete", reason: null, accuracy: 0.42, correct: 21, total: 50, wallMs: 90_000 },
    { task: "mmlu", status: "complete", reason: null, accuracy: 0.5, correct: 485, total: 970, wallMs: 300_000 },
    { task: "humaneval", status: "skipped", reason: "verifier unavailable: docker not found", accuracy: null, correct: null, total: null, wallMs: 0 }]);
  expect(readHistory(storage, id)).toEqual(entry);
  // Only the declared entries were written.
  expect(readdirSync(home).sort()).toEqual(["benchmarks", "checkout", "libmlxc.dylib"]);
  expect(readdirSync(join(home, "benchmarks")).sort()).toEqual(["data", "history", "plans", "runs"]);
});

test("a named model, thinking and a data directory reach the plan; the served model is the default", async () => {
  const calls: Call[] = [];
  const runner = createEvalRunner(options({ spawn: fakeSpawn(sub => sub === "plan" ? {} : { result: fakeResult() }, calls) }));
  const data = join(home, "elsewhere");
  await runner(() => {}, { tasks: ["mmlu", "ifeval"], model: "org/other", enableThinking: true, data }, signal());
  const plan = calls[0]!.argv;
  expect(plan.slice(plan.indexOf("--model"))).toEqual(["--model", "/models/other", "--data", data, "--native", native, "--tasks", "mmlu,ifeval", "--enable-thinking"]);
});

test("an existing plan runs as given and no plan is made", async () => {
  const calls: Call[] = [];
  const supplied = join(home, "mine.json");
  writeFileSync(supplied, JSON.stringify({ tasks: ["mmlu"] }));
  const runner = createEvalRunner(options({ spawn: fakeSpawn(() => ({ result: fakeResult() }), calls) }));
  await runner(() => {}, { plan: supplied }, signal());
  expect(calls.map(call => call.argv[2])).toEqual(["run"]);
  expect(calls[0]!.argv[calls[0]!.argv.indexOf("--plan") + 1]).toBe(supplied);
  expect(listHistory(storage)[0]!.id).toBe("2026-09-29T12-00-00-000Z-mine");
  await expect(runner(() => {}, { plan: "relative.json" }, signal())).rejects.toThrow("absolute path to an existing plan");
});

test("a plan the runner refuses ends the job with the runner's reason and starts nothing", async () => {
  const calls: Call[] = [];
  const runner = createEvalRunner(options({ spawn: fakeSpawn(() => ({ code: 1, errors: ["87 | code", "error: dataset mmlu_optiq_dev is missing: /d/mmlu_optiq_dev.jsonl", "      at readDataset (/x/plan.ts:92:36)"] }), calls) }));
  await expect(runner(() => {}, { tasks: "mmlu" }, signal())).rejects.toThrow("the plan was not made: dataset mmlu_optiq_dev is missing: /d/mmlu_optiq_dev.jsonl");
  expect(calls.map(call => call.argv[2])).toEqual(["plan"]);
  expect(listHistory(storage)).toEqual([]);
});

test("an incomplete run keeps its history entry with the problems the runner printed, and the job fails", async () => {
  const runner = createEvalRunner(options({ spawn: fakeSpawn(sub => sub === "plan" ? {} : { code: 1, result: fakeResult(),
    lines: ["INCOMPLETE (x; score acceptance unreviewed) → /out", "  problem: humaneval: skipped — verifier unavailable: docker not found"] }, []) }));
  await expect(runner(() => {}, { tasks: "all" }, signal())).rejects.toThrow("the run is incomplete (humaneval: skipped — verifier unavailable: docker not found)");
  expect(listHistory(storage)[0]).toMatchObject({ complete: false, exitCode: 1, problems: ["humaneval: skipped — verifier unavailable: docker not found"] });
});

test("a run that exits without a result fails and leaves no history", async () => {
  const runner = createEvalRunner(options({ spawn: fakeSpawn(sub => sub === "plan" ? {} : { code: 2, errors: ["error: --command does not name a file inside /r"] }, []) }));
  await expect(runner(() => {}, { tasks: "mmlu" }, signal())).rejects.toThrow("exited 2 before writing a result: --command does not name a file inside /r");
  expect(listHistory(storage)).toEqual([]);
});

test("cancelling sends the run SIGTERM (the runner stops its server and saves what it has) and the job ends cancelled", async () => {
  const calls: Call[] = [];
  const runner = createEvalRunner(options({ spawn: fakeSpawn(sub => sub === "plan" ? {} : { hang: true }, calls), graceMs: 5 }));
  const abort = new AbortController();
  const running = runner(() => {}, { tasks: "mmlu" }, abort.signal);
  await Bun.sleep(20);
  abort.abort(new Error("cancelled"));
  await expect(running).rejects.toThrow("cancelled");
  expect(calls.map(call => [call.argv[2], call.signals])).toEqual([["plan", []], ["run", ["SIGTERM"]]]);
});

test("without a checkout, a Bun on PATH, the MLX library or a model the run says so instead of failing obscurely", async () => {
  await expect(createEvalRunner(options({ script: join(home, "missing/eval-serve.ts") }))(() => {}, { tasks: "mmlu" }, signal())).rejects.toThrow("needs a source checkout");
  await expect(createEvalRunner(options({ native: join(home, "none.dylib") }))(() => {}, { tasks: "mmlu" }, signal())).rejects.toThrow("stage it");
  await expect(createEvalRunner(options())(() => {}, { tasks: "mmlu", model: "org/none" }, signal())).rejects.toThrow('no local model matches "org/none"');
  await expect(createEvalRunner(options({ models: { defaultFor: async () => undefined } }))(() => {}, { tasks: "mmlu" }, signal())).rejects.toThrow("no model is served");
});

test("the model is the one named or the served one, and must declare generate; tasks default to the smoketest and are checked for shape", async () => {
  expect(await resolveModel(options(), {})).toEqual({ id: "org/served", directory: "/models/served" });
  expect(await resolveModel(options(), { model: "org/other" })).toEqual({ id: "org/other", directory: "/models/other" });
  await expect(resolveModel({ models: fakeModels, catalog: { find: async () => ({ id: "e", kind: "model", directory: "/e", bytes: 1, operations: ["embed"] }) } }, {})).rejects.toThrow("does not declare generate");
  expect([taskSpec({}), taskSpec({ tasks: "capability" }), taskSpec({ tasks: ["gsm8k", "mmlu"] })]).toEqual(["smoketest", "capability", "gsm8k,mmlu"]);
  for (const bad of [42, "../x", "a b", "", ["ok", 1]]) expect(() => taskSpec({ tasks: bad })).toThrow("task ids or a set name");
});

test("history lists newest first, skips unreadable files and never reads outside its directory; the compact entry needs only what the runner recorded", () => {
  const { history } = evalDirectories(storage);
  mkdirSync(history, { recursive: true });
  const entry = (id: string, startedAt: string) => JSON.stringify(compactResult({}, { id, exitCode: 0, problems: [], runDirectory: "/r", startedAt, finishedAt: null, durationMs: 1 }));
  writeFileSync(join(history, "old.json"), entry("old", "2026-01-01T00:00:00.000Z"));
  writeFileSync(join(history, "new.json"), entry("new", "2026-09-01T00:00:00.000Z"));
  writeFileSync(join(history, "bad.json"), "{");
  expect(listHistory(storage).map(item => item.id)).toEqual(["new", "old"]);
  expect(listHistory(storage, 1).map(item => item.id)).toEqual(["new"]);
  expect(readHistory(storage, "../../etc/passwd")).toBeUndefined();
  expect(readHistory(storage, "nope")).toBeUndefined();
  expect(readHistory(storage, "new")).toMatchObject({ id: "new", tasks: [], capability: null, machine: null, model: { path: "", repo: null }, complete: true });
});

function twoRuns(): [EvalHistoryEntry, EvalHistoryEntry] {
  const make = (id: string, accuracy: number) => {
    const directory = join(home, "runs", id);
    mkdirSync(directory, { recursive: true });
    writeFileSync(join(directory, "result.json"), "{}");
    return compactResult(fakeResult({ tasks: [{ task: "gsm8k-50", status: "complete", score: { accuracy, nCorrect: accuracy * 50, nTotal: 50 }, timing: { wallMs: 1 } }] }),
      { id, exitCode: 0, problems: [], runDirectory: directory, startedAt: "2026-09-29T12:00:00.000Z", finishedAt: null, durationMs: 1 });
  };
  return [make("a", 0.4), make("b", 0.5)];
}

test("compare runs the runner's own comparison over the two full results and adds the per-task accuracy difference", async () => {
  const [a, b] = twoRuns(), calls: Call[] = [];
  const same = await compareRuns(options({ spawn: fakeSpawn(() => ({ stdout: "# compare\nno differences\n" }), calls) }), a, b);
  expect(calls[0]!.argv).toEqual(["/usr/bin/bun", script, "compare", join(a.runDirectory, "result.json"), join(b.runDirectory, "result.json")]);
  expect(same).toEqual({ base: "a", candidate: "b", comparable: true, markdown: "# compare\nno differences\n", tasks: [{ task: "gsm8k-50", base: 0.4, candidate: 0.5, delta: 0.09999999999999998 }] });
  expect((await compareRuns(options({ spawn: fakeSpawn(() => ({ code: 1, stdout: "differs" }), []) }), a, b)).comparable).toBe(false);
  await expect(compareRuns(options({ spawn: fakeSpawn(() => ({ code: 2, errors: ["error: not a result"] }), []) }), a, b)).rejects.toThrow("exited 2: not a result");
  rmSync(a.runDirectory, { recursive: true });
  await expect(compareRuns(options(), a, b)).rejects.toThrow("is gone");
});

// ---- the real script ---------------------------------------------------------------------------------
const realScript = join(CHECKOUT, "scripts/eval-serve.ts");
const real = existsSync(realScript) && Bun.which("bun") ? test : test.skip;

real("the real runner lists its tasks with the datasets it finds in the data directory", async () => {
  writeFileSync(join(evalDirectories(storage).data, "gsm8k_optiq_frozen.jsonl"), "");
  const { tasks, dataDirectory } = await listTasks({ storage, models: fakeModels, catalog: fakeCatalog });
  expect(dataDirectory).toBe(join(home, "benchmarks/data"));
  expect(tasks.map(task => task.id)).toEqual(["gsm8k", "mmlu", "ifeval", "bfcl", "humaneval", "hashhop", "gsm8k-50"]);
  expect(tasks.find(task => task.id === "humaneval")).toMatchObject({ needsVerifier: true, sets: ["capability", "all"], component: "HumanEval" });
  expect(tasks.find(task => task.id === "gsm8k-50")).toMatchObject({ sets: ["smoketest", "all"], component: null });
  expect(tasks.find(task => task.id === "gsm8k")!.datasets).toEqual([expect.objectContaining({ name: "gsm8k_optiq_frozen", rows: 1000, present: true })]);
  expect(tasks.find(task => task.id === "mmlu")!.datasets.map(dataset => [dataset.name, dataset.present])).toEqual([["mmlu_optiq_frozen", false], ["mmlu_optiq_dev", false]]);
});

real("the real runner refuses a plan over a missing dataset, and the job says which", async () => {
  const model = join(home, "model");
  mkdirSync(model);
  writeFileSync(join(model, "config.json"), JSON.stringify({ model_type: "x" }));
  writeFileSync(join(model, "model.safetensors"), "w");
  const runner = createEvalRunner({ storage, models: fakeModels, catalog: { find: async () => ({ id: "m", kind: "model", directory: model, bytes: 1, operations: ["generate"] }) },
    native, now: () => Date.parse("2026-09-29T12:00:00Z") });
  await expect(runner(() => {}, { tasks: "smoketest" }, signal())).rejects.toThrow(/the plan was not made: dataset gsm8k is missing: .*benchmarks\/data\/gsm8k\.jsonl/);
  expect(listHistory(storage)).toEqual([]);
});
