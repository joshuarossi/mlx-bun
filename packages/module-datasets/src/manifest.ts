// The module's static manifest: plain data, read by hosts and documentation
// generators without loading anything (this file imports only types).
// `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "datasets",
  title: "Datasets",
  summary: "Template-driven JSONL dataset generation: thirteen templates, an in-process job that calls the served model, and a Docker verifier for generated Python.",
  requires: ["jobs", "storage", "modelHost"],
  routes: [
    { id: "templates", method: "GET", path: "/api/dataset/templates", summary: "List the thirteen dataset templates with their input fields", response: "json", mount: "root" },
    { id: "submit", method: "POST", path: "/api/dataset/submit", summary: "Start a dataset job for a template; returns the job id and the output directory", response: "json", mount: "root" },
  ],
  // Generation calls the served model through the model host's `generate` operation, so each
  // request joins the scheduler; the job itself holds no exclusive GPU lease.
  jobs: [{ kind: "dataset", isolation: "task", gpu: "shared" }],
  storage: [{ key: "datasets", path: "datasets", kind: "directory", purpose: "Generated train.jsonl and valid.jsonl, one directory per job" }],
} as const satisfies Omit<AppModule<"jobs" | "storage" | "modelHost">, "activate">;
