// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "models",
  title: "Models",
  summary: "Model management over the catalog and the model host: the library and hub (search, download, switch the served model, cache cleanup), adapter mounting, merge and export, and the ls, get, scan, fit, gc and upload verbs.",
  requires: ["catalog", "modelHost", "storage", "events"],
  placement: "app",
  routes: [
    { id: "library", method: "GET", path: "/library", summary: "Every local model with its fit on this machine, which one is served and which are loaded (`refresh=1` re-reads the index)", response: "json", mount: "root" },
    { id: "downloads", method: "GET", path: "/downloads", summary: "Model downloads in progress and the recent finished ones", response: "json", mount: "root" },
    { id: "hub-local", method: "GET", path: "/api/hub/local", summary: "Downloaded models with their fit verdicts, after re-indexing the Hub cache", response: "json", mount: "root" },
    { id: "hub-search", method: "GET", path: "/api/hub/search", summary: "Search Hugging Face for MLX models (`q`); offline is an answer, not an error", response: "json", mount: "root" },
    { id: "hub-serve", method: "POST", path: "/api/hub/serve", summary: "Make a local model the served one (`model`): loaded beside the resident ones when it fits, else in place of the least recently used; a host that serves one model answers with the restart command", response: "json", mount: "root" },
    { id: "hub-download", method: "POST", path: "/api/hub/download", summary: "Start a download that outlives the request (`repo`, `org/name`); a repo already downloading answers 409", response: "json", mount: "root" },
    { id: "resolve-folder", method: "POST", path: "/api/model/resolve-folder", summary: "Locate a folder picked in the browser on disk (hub snapshot, the app's models directory, or an indexed model)", response: "json", mount: "root" },
    { id: "gc-plan", method: "GET", path: "/api/gc/plan", summary: "What cleaning the Hub cache would reclaim: superseded snapshots and dead blobs per repo", response: "json", mount: "root" },
    { id: "gc-execute", method: "POST", path: "/api/gc/execute", summary: "Delete what the plan lists (`{ \"yes\": true }`), refusing to prune a snapshot a resident model reads, then re-index", response: "json", mount: "root" },
    { id: "adapters-available", method: "GET", path: "/v1/adapters/available", summary: "Every adapter found on disk with whether it is mounted and whether it fits the served model", response: "json", mount: "root" },
    { id: "adapters", method: "GET", path: "/v1/adapters", summary: "The adapters mounted on the served model, with their size and memory", response: "json", mount: "root" },
    { id: "adapter-mount", method: "POST", path: "/v1/adapters", summary: "Mount an adapter directory on the served model (`id`, `path`) under its execution lease", response: "json", mount: "root" },
    { id: "adapter-unmount", method: "DELETE", path: "/v1/adapters/:id", summary: "Unmount an adapter from the served model", response: "json", mount: "root" },
    { id: "adapter-merge", method: "POST", path: "/api/finetune/merge", summary: "Merge two adapters (`adapter_a`, `adapter_b`, optional `scales`) into a new adapter in the adapters directory, on the served model's execution lease", response: "json", mount: "root" },
    { id: "adapter-export", method: "POST", path: "/api/finetune/export", summary: "Write an export manifest for an adapter (`base_model`, `adapter_path`, optional `method`) into the exports directory", response: "json", mount: "root" },
  ],
  verbs: [
    { name: "get", summary: "Download a model from Hugging Face (resumable, verified)",
      positional: [{ name: "org/repo | substring", summary: "The repo to download, or a substring of a downloaded repo to refresh", required: true }],
      options: [
        { name: "revision", type: "string", summary: "Git revision [default: main]" },
      ] },
    { name: "ls", summary: "List downloaded models (one canonical revision per repo)",
      positional: [{ name: "query", summary: "Only models whose id contains this" }],
      options: [
        { name: "vision", type: "boolean", summary: "Only vision-capable models" },
        { name: "max-size", type: "string", summary: "Filter by weight size, e.g. 10GB or 800MB" },
        { name: "all-revisions", type: "boolean", summary: "Show each snapshot; canonical revision marked *" },
      ] },
    { name: "scan", summary: "Re-index the Hugging Face cache without reading tensor bytes", positional: [], options: [] },
    { name: "fit", summary: "Estimate model memory and decode speed on this machine",
      positional: [{ name: "query", summary: "A downloaded model", required: true }],
      options: [
        { name: "ctx", type: "string", summary: "Context tokens [default: 8192; a memory-planning runtime defaults to its own preset]" },
        { name: "kv-quant", type: "string", summary: "KV estimate: 4 | 8 | config | off [default: off]" },
        { name: "skus", type: "boolean", summary: "Print the Apple Silicon SKU matrix" },
      ] },
    { name: "gc", summary: "Reclaim superseded snapshots and dead blobs (preview by default)", positional: [], options: [
        { name: "yes", type: "boolean", summary: "Actually delete the planned snapshots and blobs" },
        { name: "dry-run", type: "boolean", summary: "Never delete, even with --yes" },
        { name: "force", type: "boolean", summary: "Also prune superseded snapshots with otherwise unique files" },
      ] },
    { name: "upload", summary: "Push a local model directory to the Hugging Face Hub (mlx_lm.upload counterpart)",
      usage: "usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]", positional: [], options: [
        { name: "path", type: "string", summary: "Local model directory to upload (required)" },
        { name: "upload-repo", type: "string", summary: "Hub repo id, org/name or bare name (required)" },
        { name: "private", type: "boolean", summary: "Create the repo as private (mlx-bun extension)" },
      ] },
  ],
  storage: [
    // Shared with the train module (every producer of an adapter writes here); a merge is one.
    { key: "adapters", path: "adapters", kind: "directory", purpose: "Fine-tuned and merged adapters: one directory per run, with checkpoints and metrics" },
    { key: "exports", path: "exports", kind: "directory", purpose: "Adapter export manifests" },
  ],
  panel: { tag: "mlx-models-panel", entry: "@mlx-bun/module-models/panel", title: "Models", path: "/models", developer: false },
} as const satisfies Omit<AppModule<"catalog" | "modelHost" | "storage" | "events">, "activate">;
