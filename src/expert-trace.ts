// E0 expert-routing tracer (PLAN Phase 19 — expert offload).
//
// Records every MoE router decision as JSONL — one record per router call:
//   { c: callSeq, l: layerIdx, s: [B, L, k], i: [flattened uint32 expert ids] }
// Analyse with scripts/analyze-expert-trace.ts (coverage curve, working-set
// size, within-task stability, cross-task specialisation).
//
// Two ways to drive it:
//   - env: `MLX_BUN_EXPERT_TRACE=<path> mlx-bun serve ...` (auto-starts here)
//   - programmatic: beginExpertTrace(path) / endExpertTrace() per domain
//     (scripts/run-expert-trace.ts uses this to trace several domains from
//     one model load).
//
// Recording adds a per-call GPU->host sync (it reads the routed indices back),
// so a traced run decodes slower — it's a MEASUREMENT tool, not a serving
// path. When no trace is active, isExpertTracing() is false and the hook in
// Router.forward is a single branch (zero overhead) — inert by default, same
// discipline as the slots flag.

import { Dtype } from "./mlx/ffi";
import type { MlxArray } from "./mlx/array";

let sink: Bun.FileSink | null = null;
let seq = 0;
let written = 0;

export function beginExpertTrace(path: string): void {
  if (sink) endExpertTrace();
  sink = Bun.file(path).writer();
  seq = 0;
  written = 0;
  sink.write(JSON.stringify({ meta: "mlx-bun-expert-trace-v1", note: "one record per router call" }) + "\n");
  process.stderr.write(`[expert-trace] recording -> ${path}\n`);
}

export function endExpertTrace(): void {
  if (!sink) return;
  sink.flush();
  sink.end();
  process.stderr.write(`[expert-trace] wrote ${written} records (${seq} calls)\n`);
  sink = null;
}

/** Alias kept for the process-exit handler / env callers. */
export const finishExpertTrace = endExpertTrace;

export function isExpertTracing(): boolean {
  return sink !== null;
}

/** Record one router decision. `indices` is [B, L, k] uint32 (expert ids). */
export function recordRouting(layer: number, indices: MlxArray): void {
  if (!sink) return;
  const shape = indices.shape; // [B, L, k]
  const f = indices.astype(Dtype.float32); // ids <=127 are exact in f32
  const data = f.toFloat32();
  f.dispose();
  const ids = new Array<number>(data.length);
  for (let i = 0; i < data.length; i++) ids[i] = Math.round(data[i]!);
  sink.write(JSON.stringify({ c: seq++, l: layer, s: shape, i: ids }) + "\n");
  if (++written % 2000 === 0) sink.flush();
}

if (process.env.MLX_BUN_EXPERT_TRACE) beginExpertTrace(process.env.MLX_BUN_EXPERT_TRACE);

process.on("exit", () => { try { endExpertTrace(); } catch { /* best-effort */ } });
process.on("SIGINT", () => { endExpertTrace(); process.exit(0); });
