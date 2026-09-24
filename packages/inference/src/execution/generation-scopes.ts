// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import { gpuStream } from "@mlx-bun/mlx/array";
import {
maxRecommendedWorkingSetSize,
setWiredLimit,
synchronize
} from "@mlx-bun/mlx/ffi";
import { GenerateStats,GeneratedToken } from '../generation/types';
import {
type MlxModelMemory
} from "./autoregressive";
import { runtimeValue } from "./config";

// Scoped wired limit, raised only for near-ceiling models. mlx-lm's
// wired_limit context wires unconditionally per generation; we deviate
// with a measured justification (PLAN Phase 6 verification findings):
// - 26B-A4B (16.4 GB = 92% of the 17.8 GiB working set) NEEDS wiring —
//   8.6 tok/s without, 32.3 with (Metal evicts weight buffers per token).
// - 12B/e4b (≤47%) hit reference parity WITHOUT wiring, and wiring in a
//   multi-model process (the test suite) pins memory the OTHER resident
//   models need — async GPU exec OOM, which is uncatchable (the mlx
//   completion-handler throw terminates the process).
// Scope semantics match the reference: set → generate → synchronize →
// restore; nothing stays pinned between generations. Re-entrant: only
// the outermost wiring scope touches the limit.
// macOS 26.6 reports a 26.8e9 B (24.96 GiB, 0.78 × RAM) recommended set on
// a 32 GB M1 Max (2026-09-08; the earlier "24 GB machine" attribution was
// wrong — 24.96 GiB exceeds a 24 GB box's RAM). At 0.75 × that the old
// fraction stopped wiring the 13-16 GiB Qwen/GLM models even though they
// page heavily without an explicit wired limit.
// Keep smaller 8-9 GiB models unwired while covering the large-model class.
const WIRE_THRESHOLD = 0.5;
let wiredScopeDepth = 0;
let wiredOldLimit = 0;

type WiredModelMemory = MlxModelMemory;

/** Bytes whose MLX graph must stay resident while a model executes. */
export function wiredWorkingSetBytes(model: WiredModelMemory): number {
  const planned = model.expertRuntime?.plan.plannedBytes;
  return typeof planned === "number" && Number.isFinite(planned) && planned > 0
    ? Math.max(model.weightsBytes, planned)
    : model.weightsBytes;
}

export function modelNeedsWiredLimit(
  model: WiredModelMemory,
  recommendedBytes = maxRecommendedWorkingSetSize(),
  force = runtimeValue("MLX_BUN_FORCE_WIRE") === "1",
): boolean {
  return force ||
    wiredWorkingSetBytes(model) > WIRE_THRESHOLD * recommendedBytes;
}

function enterWiredScope(): void {
  if (wiredScopeDepth++ === 0)
    wiredOldLimit = setWiredLimit(maxRecommendedWorkingSetSize());
}
function exitWiredScope(): void {
  if (--wiredScopeDepth === 0) {
    synchronize(gpuStream);
    setWiredLimit(wiredOldLimit);
  }
}

/** Hold the process wired limit while one model owns GPU execution. */
export function acquireModelWiredLimit(model: WiredModelMemory): () => void {
  if (!modelNeedsWiredLimit(model)) return () => {};
  enterWiredScope();
  let released = false;
  return () => {
    if (released) return;
    released = true;
    exitWiredScope();
  };
}

/** Hold the model's active-adapter list for exactly this generation. */
export async function* adapterScoped(
  model: { loraState: { active: string[] } },
  adapters: string[],
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  const previous = model.loraState.active;
  model.loraState.active = adapters;
  try {
    return yield* inner;
  } finally {
    model.loraState.active = previous;
  }
}

/** Wrap the generator so the wired limit is held exactly while it runs
 *  (incl. early break/return/throw — finally fires on .return()). */
export async function* wiredScoped(
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  enterWiredScope();
  try {
    return yield* inner;
  } finally {
    exitWiredScope();
  }
}

/** Publish the streamed model's route ledger on every generator exit path. */
export async function* usageScoped(
  model: WiredModelMemory,
  inner: AsyncGenerator<GeneratedToken, GenerateStats>,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  try {
    return yield* inner;
  } finally {
    if (model.expertRuntime?.finishUsage)
      await model.expertRuntime.finishUsage();
    else
      model.expertRuntime?.flushUsage?.();
  }
}

/** Apply generate()'s scoped wiring policy to non-generator execution paths. */
export async function withModelWiredLimit<T>(
  model: WiredModelMemory,
  run: () => Promise<T>,
): Promise<T> {
  const release = acquireModelWiredLimit(model);
  try {
    return await run();
  } finally {
    release();
  }
}

/** Apply generate()'s usage safe-point to direct/non-generator paths. */
export async function withModelUsageFlush<T>(
  model: WiredModelMemory,
  run: () => Promise<T>,
): Promise<T> {
  try {
    return await run();
  } finally {
    if (model.expertRuntime?.finishUsage)
      await model.expertRuntime.finishUsage();
    else
      model.expertRuntime?.flushUsage?.();
  }
}
