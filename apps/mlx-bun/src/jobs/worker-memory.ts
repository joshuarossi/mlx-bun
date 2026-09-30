// What an isolation worker reports of the MLX memory its process holds (the parent has no native
// module, so the worker measures): on its `/health` (`memory`), and as a `worker.memory` line in its
// `/admin/events` stream at connect, on an interval when it changed, and after each finished request.
// The parent's residency (cli/worker-unit.ts) counts a worker's active plus cache bytes once one arrives.

/** MLX memory of one worker process, in bytes. */
export interface WorkerMemory {
  /** Memory held by live arrays: the weights, the KV the model carries and the working set of a step. */
  readonly activeBytes: number;
  /** Buffers the allocator keeps for reuse; the process still holds them. */
  readonly cacheBytes: number;
  /** The high-water mark of active memory since the process started. */
  readonly peakBytes: number;
  /** What the device recommends a process wire at most (`max_recommended_working_set_size`); 0 when unknown. */
  readonly workingSetBytes: number;
}

/** The stream line's `type`: the parent consumes it and never republishes it as an app event. */
export const WORKER_MEMORY_EVENT = "worker.memory";

const bytes = (value: unknown): number | undefined => typeof value === "number" && Number.isFinite(value) && value >= 0 ? value : undefined;

function build(active: unknown, cache: unknown, peak: unknown, workingSet: unknown): WorkerMemory | undefined {
  const activeBytes = bytes(active), cacheBytes = bytes(cache), peakBytes = bytes(peak);
  if (activeBytes === undefined || cacheBytes === undefined || peakBytes === undefined) return undefined;
  return { activeBytes, cacheBytes, peakBytes, workingSetBytes: bytes(workingSet) ?? 0 };
}

/** The stream line for one reading. */
export const memoryLine = (memory: WorkerMemory, at = Date.now()): string => JSON.stringify({ type: WORKER_MEMORY_EVENT, at, ...memory }) + "\n";
/** A stream line's reading; undefined when it is not one. */
export function parseMemoryLine(value: unknown): WorkerMemory | undefined {
  const line = value as Record<string, unknown> | null;
  return line && typeof line === "object" && line.type === WORKER_MEMORY_EVENT ? build(line.activeBytes, line.cacheBytes, line.peakBytes, line.workingSetBytes) : undefined;
}

/** `/health`'s `memory` member (snake case, like the rest of the report). */
export const memoryHealth = (memory: WorkerMemory) => ({ active_bytes: memory.activeBytes, cache_bytes: memory.cacheBytes,
  peak_bytes: memory.peakBytes, working_set_bytes: memory.workingSetBytes });
export function parseMemoryHealth(value: unknown): WorkerMemory | undefined {
  const body = (value as { memory?: Record<string, unknown> } | null)?.memory;
  return body && typeof body === "object" ? build(body.active_bytes, body.cache_bytes, body.peak_bytes, body.working_set_bytes) : undefined;
}

/** What the residency manager counts a worker as holding: everything its process keeps. */
export const heldBytes = (memory: WorkerMemory): number => memory.activeBytes + memory.cacheBytes;
