// Opt-in with real weights (MLX_BUN_APP_TEST_MODEL, an already-downloaded
// snapshot; MLX_BUN_EVAL_DATA, a directory holding the runner's pinned datasets):
// the app's real serve composition with the installed benchmarks module runs
// gsm8k-50 and mmlu against the served model as a job, and its history must equal
// a direct `eval-serve.ts run` of the same plan: the same scores and the same
// per-sample outcomes (greedy decoding, one request at a time). Datasets are
// linked into the module's data entry, never downloaded. It needs a git checkout
// and Bun on PATH, and takes the GPU for two evaluations (minutes each).
import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const modelDir = process.env.MLX_BUN_APP_TEST_MODEL, dataDir = process.env.MLX_BUN_EVAL_DATA;
const DATASETS = ["gsm8k", "mmlu_optiq_frozen", "mmlu_optiq_dev"];
const checkout = resolve(import.meta.dir, "../../../..");
const ready = !!modelDir && !!dataDir && DATASETS.every(name => existsSync(join(dataDir, `${name}.jsonl`))) && !!Bun.which("bun");

test.skipIf(!ready)("a benchmarks job over the served model reproduces a direct eval-serve run of the same plan", async () => {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const hf = /models--([^/]+)--([^/]+)\/snapshots\//.exec(modelDir!);
  const model = await scanSnapshot(modelDir!, hf ? `${hf[1]}/${hf[2]}` : "test-model");
  if (!model) throw new Error("Model path has no loadable checkpoint");
  const root = mkdtempSync(join(tmpdir(), "mlx-real-benchmarks-"));
  const options = parseServeOptions({ values: { port: "0", "no-open": true, thinking: "off" }, positionals: [] });
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), jobsLogs: join(root, "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
  // The module's data entry under this test's artifact root: links to the pinned files.
  const data = join(root, "artifacts/benchmarks/data");
  mkdirSync(data, { recursive: true });
  for (const name of DATASETS) symlinkSync(join(dataDir!, `${name}.jsonl`), join(data, `${name}.jsonl`));
  let app: Awaited<ReturnType<typeof startModelServer>> | undefined;
  try {
    app = await startModelServer(model, options);
    const base = `http://127.0.0.1:${app.port}`;
    const get = async (path: string) => (await fetch(base + path)).json() as Promise<any>;

    const tasks = await get("/api/benchmarks/tasks");
    expect(tasks.dataDirectory).toBe(data);
    expect(tasks.tasks.filter((task: any) => ["gsm8k-50", "mmlu"].includes(task.id)).every((task: any) => task.datasets.every((dataset: any) => dataset.present))).toBe(true);

    const started = await fetch(`${base}/api/benchmarks/runs`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ tasks: "gsm8k-50,mmlu" }) });
    expect(started.status).toBe(202);
    const job = await started.json() as any;
    let record: any;
    for (const end = Date.now() + 45 * 60_000;;) {
      record = await get(`/api/benchmarks/jobs/${job.id}`);
      if (record.status === "done" || record.status === "failed") break;
      if (Date.now() > end) throw new Error(`the job never finished: ${JSON.stringify(record)}`);
      await Bun.sleep(5_000);
    }
    // A dirty checkout makes the runner call the run incomplete (its commit does not identify the source): the entry and its scores are kept either way.
    const { runs } = await get("/api/benchmarks/runs");
    expect(runs).toHaveLength(1);
    const entry = runs[0];
    console.log(`job ${record.status}${record.error ? ` (${record.error})` : ""}; problems: ${JSON.stringify(entry.problems)}`);
    expect(entry.model.path).toBe(modelDir);
    expect(entry.tasks.map((task: any) => task.task)).toEqual(["mmlu", "gsm8k-50"]);
    expect(entry.tasks.every((task: any) => task.status === "complete" && task.total > 0)).toBe(true);

    // The direct run: the same plan file, the same server command, a fresh directory.
    const plan = join(root, "artifacts/benchmarks/plans", `${entry.id}.json`);
    expect(existsSync(plan)).toBe(true);
    const direct = join(root, "direct");
    const child = Bun.spawn([Bun.which("bun")!, join(checkout, "scripts/eval-serve.ts"), "run", "--plan", plan, "--root", checkout, "--out", direct, "--label", "direct",
      "--command", JSON.stringify([Bun.which("bun")!, join(checkout, "apps/mlx-bun/bin/mlx-bun.mjs"), "serve"])], { stdout: "inherit", stderr: "inherit" });
    await child.exited;
    const viaModule = JSON.parse(readFileSync(join(entry.runDirectory, "result.json"), "utf8")), viaScript = JSON.parse(readFileSync(join(direct, "result.json"), "utf8"));
    expect(viaScript.tasks.map((task: any) => task.task)).toEqual(["mmlu", "gsm8k-50"]);
    for (const [module, script] of viaModule.tasks.map((task: any, index: number) => [task, viaScript.tasks[index]])) {
      expect(module.status).toBe("complete");
      expect(module.outcomes).toBe(script.outcomes);
      expect(module.score).toEqual(script.score);
    }
    expect(viaModule.capability).toEqual(viaScript.capability);
    // The history is the module's reduction of that same result.
    for (const task of entry.tasks) expect(task.accuracy).toBe(viaScript.tasks.find((item: any) => item.task === task.task).score.accuracy);
  } finally {
    await app?.close();
    rmSync(root, { recursive: true, force: true });
  }
}, 3_600_000);
