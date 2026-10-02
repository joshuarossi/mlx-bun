// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "benchmarks",
  title: "Benchmarks",
  summary: "Answer-quality benchmarks over the capability evaluation runner (GSM8K, MMLU, IFEval, BFCL, HumanEval, HashHop): runs a plan against the served or a named model as a job, keeps the compact results history, and compares two runs.",
  requires: ["jobs", "storage", "modelHost", "catalog"],
  routes: [
    { id: "tasks", method: "GET", path: "/tasks", summary: "The tasks a run can evaluate: their sets, pinned datasets and whether each dataset file is present", response: "json" },
    { id: "run-start", method: "POST", path: "/runs", summary: "Start an evaluation run from the JSON body (`tasks`: ids or a set name, default `smoketest`; `model`: a catalog id or query, default the served model; `enableThinking`); it takes the GPU exclusively until it ends", response: "json" },
    { id: "history", method: "GET", path: "/runs", summary: "Finished evaluation runs, newest first, as compact per-task scores (`limit` query)", response: "json" },
    { id: "run", method: "GET", path: "/runs/:id", summary: "One finished evaluation run", response: "json" },
    { id: "compare", method: "GET", path: "/compare", summary: "The runner's paired comparison of two finished runs (`base` and `candidate` ids)", response: "json" },
    { id: "jobs", method: "GET", path: "/jobs", summary: "Recent evaluation jobs", response: "json" },
    { id: "job", method: "GET", path: "/jobs/:id", summary: "One evaluation job", response: "json" },
    { id: "job-cancel", method: "DELETE", path: "/jobs/:id", summary: "Stop a running evaluation job", response: "json" },
  ],
  jobs: [{ kind: "eval-serve", isolation: "task", gpu: "exclusive" }],
  storage: [
    { key: "history", path: "benchmarks/history", kind: "directory", purpose: "Compact results of finished evaluation runs, one JSON file each" },
    { key: "runs", path: "benchmarks/runs", kind: "directory", purpose: "Each run's own directory: result.json with provenance, samples.jsonl, report.md, the server's log" },
    { key: "plans", path: "benchmarks/plans", kind: "directory", purpose: "The pinned plan each run was made from" },
    { key: "data", path: "benchmarks/data", kind: "directory", purpose: "The sha256-pinned evaluation datasets, placed here by the user; never downloaded" },
  ],
  panel: { tag: "mlx-benchmarks-panel", entry: "@mlx-bun/module-benchmarks/panel", title: "Benchmarks", path: "/benchmarks" },
} as const satisfies Omit<AppModule<"jobs" | "storage" | "modelHost" | "catalog">, "activate">;
