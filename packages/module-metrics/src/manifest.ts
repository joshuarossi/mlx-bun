// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "metrics",
  title: "Metrics and performance",
  summary: "Live serving metrics from the host's events (tokens per second, time to first token, batch occupancy, queue depth, KV and prefix-cache usage, memory and load times per model) and the history of bench-serve runs.",
  requires: ["events", "storage", "jobs"],
  routes: [
    { id: "snapshot", method: "GET", path: "/snapshot", summary: "The current metrics as JSON: models, scheduler, caches, request-timing distributions and a throughput series", response: "json" },
    { id: "stream", method: "GET", path: "/stream", summary: "The same snapshot as a server-sent stream: one `snapshot` event on connect, then one each time the metrics change (at most twice a second)", response: "sse" },
    { id: "history", method: "GET", path: "/history", summary: "Finished bench-serve runs, newest first, as compact per-cell medians (`limit` query)", response: "json" },
    { id: "history-entry", method: "GET", path: "/history/:id", summary: "One finished bench-serve run", response: "json" },
    { id: "profiles", method: "GET", path: "/bench/profiles", summary: "The bench-serve plans a run can start from", response: "json" },
    { id: "bench-start", method: "POST", path: "/bench", summary: "Start a bench-serve run from a profile name in the JSON body (`profile`); it takes the GPU exclusively until it ends", response: "json" },
    { id: "bench-list", method: "GET", path: "/bench", summary: "Recent bench-serve jobs", response: "json" },
    { id: "bench-job", method: "GET", path: "/bench/:id", summary: "One bench-serve job", response: "json" },
    { id: "bench-cancel", method: "DELETE", path: "/bench/:id", summary: "Stop a running bench-serve job", response: "json" },
  ],
  jobs: [{ kind: "bench-serve", isolation: "task", gpu: "exclusive" }],
  storage: [
    { key: "history", path: "metrics/history", kind: "directory", purpose: "Compact results of finished bench-serve runs, one JSON file each" },
    { key: "bench", path: "metrics/bench", kind: "directory", purpose: "bench-serve plans (plans/) and each run's full record and report (runs/)" },
  ],
  panel: { tag: "mlx-metrics-panel", entry: "@mlx-bun/module-metrics/panel", title: "Metrics", path: "/metrics" },
} as const satisfies Omit<AppModule<"events" | "storage" | "jobs">, "activate">;
