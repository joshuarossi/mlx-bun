import { dlopen, FFIType, ptr as ffiPtr, toArrayBuffer } from "bun:ffi";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import type { MlxArray } from "./mlx/array";
import type { MlxHandle } from "./mlx/ffi";

const { cstring, i32, ptr: pointer, u32, u64 } = FFIType;
const EBUSY = 16;
const EAGAIN = 35;
const MAX_SEGMENTS = 8;

type ExpertIOState = "open" | "closing" | "closed";

/**
 * Poll an asynchronous expert read without letting an await cross the
 * store's lifetime boundary. Exported only so the race can be tested with a
 * deterministic fake poller rather than relying on native I/O timing.
 */
export async function _pollExpertReadUntilReady(
  assertOpen: () => void,
  poll: () => number,
  sleep: () => Promise<void> = () => Bun.sleep(1),
): Promise<void> {
  for (;;) {
    assertOpen();
    const status = poll();
    if (status === 0) return;
    if (status !== EAGAIN) throw new Error(`expert read failed: errno ${status}`);
    await sleep();
  }
}

export interface ExpertIOOptions {
  slots: number;
  slotBytes: number;
  workers?: number;
  alignment?: number;
  noCache?: boolean;
  libraryPath?: string;
}

export interface ExpertIOSegment {
  readonly file: number;
  readonly offset: number;
  readonly destination: number;
  readonly length: number;
}

function resolveLibrary(explicit?: string): string {
  if (explicit) return explicit;
  if (process.env.MLX_BUN_EXPERT_IO_DYLIB) return process.env.MLX_BUN_EXPERT_IO_DYLIB;
  const candidates = [
    join(dirname(process.execPath), "libmlx_bun_expert_io.dylib"),
    join(import.meta.dir, "..", "dist-native", "libmlx_bun_expert_io.dylib"),
  ];
  return candidates.find(existsSync) ?? candidates[0]!;
}

export class ExpertIOSlabStore {
  readonly files: readonly string[];
  readonly slots: number;
  readonly slotBytes: number;
  #lib: any;
  #handle: bigint;
  #state: ExpertIOState = "open";

  constructor(path: string | readonly string[], options: ExpertIOOptions) {
    if (!Number.isSafeInteger(options.slots) || options.slots <= 0) throw new Error("slots must be positive");
    if (!Number.isSafeInteger(options.slotBytes) || options.slotBytes <= 0) throw new Error("slotBytes must be positive");
    const paths = typeof path === "string" ? [path] : [...path];
    if (paths.length === 0 || paths.some((entry) => entry.length === 0))
      throw new Error("expert slab store requires at least one file");
    this.files = Object.freeze(paths);
    this.slots = options.slots; this.slotBytes = options.slotBytes;
    this.#lib = dlopen(resolveLibrary(options.libraryPath), {
      mlx_bun_expert_io_open: { args: [cstring, u32, u64, u64, u32, i32], returns: u64 },
      mlx_bun_expert_io_open_many: {
        args: [pointer, u64, u32, u32, u64, u64, u32, i32],
        returns: u64,
      },
      mlx_bun_expert_io_submit: { args: [u64, u32, u64, u64, u64], returns: i32 },
      mlx_bun_expert_io_submitv: {
        args: [u64, u32, u64, pointer, pointer, pointer, pointer, u32],
        returns: i32,
      },
      mlx_bun_expert_io_wait: { args: [u64, u32, u64], returns: i32 },
      mlx_bun_expert_io_poll: { args: [u64, u32, u64], returns: i32 },
      mlx_bun_expert_io_cancel: { args: [u64, u32, u64], returns: i32 },
      mlx_bun_expert_io_lease: { args: [u64, u32, u64, i32], returns: i32 },
      mlx_bun_expert_io_release: { args: [u64, u32, u64, i32], returns: i32 },
      mlx_bun_expert_io_discard: { args: [u64, u32, u64], returns: i32 },
      mlx_bun_process_phys_footprint: { args: [], returns: u64 },
      mlx_bun_expert_io_ptr: { args: [u64, u32, u64], returns: u64 },
      mlx_bun_expert_io_length: { args: [u64, u32, u64], returns: u64 },
      mlx_bun_expert_io_close: { args: [u64], returns: i32 },
    });
    const encoded = Buffer.from(`${paths.join("\0")}\0`);
    this.#handle = this.#lib.symbols.mlx_bun_expert_io_open_many(
      ffiPtr(encoded), BigInt(encoded.byteLength), paths.length,
      options.slots, BigInt(options.slotBytes),
      BigInt(options.alignment ?? 16 * 1024),
      options.workers ?? 2, options.noCache === false ? 0 : 1,
    ) as bigint;
    if (this.#handle === 0n) {
      this.#lib.close();
      throw new Error(`failed to open expert slab store: ${paths.join(", ")}`);
    }
  }

  submit(slot: number, generation: bigint, offset: number, length: number): void {
    this.submitSegments(slot, generation, [{
      file: 0,
      offset,
      destination: 0,
      length,
    }]);
  }

  submitSegments(
    slot: number,
    generation: bigint,
    segments: readonly ExpertIOSegment[],
  ): void {
    this.#checkSlot(slot);
    if (generation <= 0n) throw new RangeError("expert generation must be positive");
    if (segments.length === 0 || segments.length > MAX_SEGMENTS)
      throw new RangeError(`expert read requires 1..${MAX_SEGMENTS} segments`);
    const files = new Uint32Array(segments.length);
    const offsets = new BigUint64Array(segments.length);
    const destinations = new BigUint64Array(segments.length);
    const lengths = new BigUint64Array(segments.length);
    let extent = 0;
    for (let index = 0; index < segments.length; index++) {
      const segment = segments[index]!;
      if (!Number.isSafeInteger(segment.file) || segment.file < 0 ||
          segment.file >= this.files.length)
        throw new RangeError(`expert segment ${index} file is out of range`);
      if (!Number.isSafeInteger(segment.offset) || segment.offset < 0)
        throw new RangeError(`expert segment ${index} offset must be non-negative`);
      if (!Number.isSafeInteger(segment.destination) || segment.destination < 0)
        throw new RangeError(`expert segment ${index} destination must be non-negative`);
      if (!Number.isSafeInteger(segment.length) || segment.length <= 0)
        throw new RangeError(`expert segment ${index} length must be positive`);
      const end = segment.destination + segment.length;
      if (!Number.isSafeInteger(end) || end > this.slotBytes)
        throw new RangeError(`expert segment ${index} exceeds slot capacity`);
      for (let prior = 0; prior < index; prior++) {
        const other = segments[prior]!;
        const otherEnd = other.destination + other.length;
        if (segment.destination < otherEnd && other.destination < end)
          throw new RangeError(`expert segment ${index} overlaps segment ${prior}`);
      }
      files[index] = segment.file;
      offsets[index] = BigInt(segment.offset);
      destinations[index] = BigInt(segment.destination);
      lengths[index] = BigInt(segment.length);
      extent = Math.max(extent, end);
    }
    if (extent > this.slotBytes)
      throw new RangeError("expert segmented read exceeds slot capacity");
    const status = this.#lib.symbols.mlx_bun_expert_io_submitv(
      this.#handle,
      slot,
      generation,
      ffiPtr(files),
      ffiPtr(offsets),
      ffiPtr(destinations),
      ffiPtr(lengths),
      segments.length,
    );
    if (status !== 0)
      throw new Error(`expert segmented read submit failed: errno ${status}`);
  }

  async wait(slot: number, generation: bigint): Promise<void> {
    await _pollExpertReadUntilReady(
      () => this.#checkSlot(slot),
      () => this.#lib.symbols.mlx_bun_expert_io_poll(this.#handle, slot, generation),
    );
  }

  cancel(slot: number, generation: bigint): void {
    this.#checkSlot(slot);
    const status = this.#lib.symbols.mlx_bun_expert_io_cancel(this.#handle, slot, generation);
    if (status !== 0) throw new Error(`expert read cancel failed: errno ${status}`);
  }

  lease(slot: number, generation: bigint, consumer: "cpu" | "gpu" = "cpu"): void {
    this.#checkSlot(slot);
    const status = this.#lib.symbols.mlx_bun_expert_io_lease(this.#handle, slot, generation, consumer === "gpu" ? 1 : 0);
    if (status !== 0) throw new Error(`expert slot lease failed: errno ${status}`);
  }

  releaseCpu(slot: number, generation: bigint): void {
    this.#checkSlot(slot);
    const status = this.#lib.symbols.mlx_bun_expert_io_release(this.#handle, slot, generation, 0);
    if (status !== 0) throw new Error(`expert slot release failed: errno ${status}`);
  }

  releaseGpuFenced(slot: number, generation: bigint): void {
    this.#checkSlot(slot);
    const status = this.#lib.symbols.mlx_bun_expert_io_release(this.#handle, slot, generation, 1);
    if (status !== 0) throw new Error(`expert GPU slot release failed: errno ${status}`);
  }

  async releaseAfterGpuSync(
    slot: number, generation: bigint, dependentOutputs: readonly MlxArray[], stream?: MlxHandle,
  ): Promise<void> {
    this.#checkSlot(slot);
    if (dependentOutputs.length === 0) throw new Error("GPU slot release requires dependent outputs to evaluate");
    const [{ gpuStream }, { synchronize }, ops] = await Promise.all([
      import("./mlx/array"), import("./mlx/ffi"), import("./mlx/ops"),
    ]);
    ops.evalAll([...dependentOutputs]);
    synchronize(stream ?? gpuStream);
    this.releaseGpuFenced(slot, generation);
  }

  discard(slot: number, generation: bigint): void {
    this.#checkSlot(slot);
    const status = this.#lib.symbols.mlx_bun_expert_io_discard(this.#handle, slot, generation);
    if (status !== 0) throw new Error(`expert slot discard failed: errno ${status}`);
  }

  physicalFootprint(): number {
    this.#checkOpen();
    return Number(this.#lib.symbols.mlx_bun_process_phys_footprint());
  }

  pointer(slot: number, generation: bigint): number {
    this.#checkSlot(slot);
    const result = Number(this.#lib.symbols.mlx_bun_expert_io_ptr(this.#handle, slot, generation));
    if (!result) throw new Error("expert slot pointer requires the matching active lease");
    return result;
  }

  view(slot: number, generation: bigint, length?: number): Uint8Array {
    this.#checkSlot(slot);
    const resolvedLength = length ?? Number(this.#lib.symbols.mlx_bun_expert_io_length(this.#handle, slot, generation));
    if (resolvedLength < 0 || resolvedLength > this.slotBytes) throw new RangeError("expert slot view exceeds capacity");
    return new Uint8Array(toArrayBuffer(this.pointer(slot, generation) as never, 0, resolvedLength));
  }

  close(): void {
    if (this.#state === "closed") return;
    if (this.#state === "closing") return;
    this.#state = "closing";
    let status: number;
    try {
      status = this.#lib.symbols.mlx_bun_expert_io_close(this.#handle);
    } catch (error) {
      this.#state = "open";
      throw error;
    }
    if (status !== 0) {
      this.#state = "open";
      throw new Error(`expert slab close failed: errno ${status}`);
    }
    this.#state = "closed";
    this.#lib.close();
  }

  #checkSlot(slot: number): void {
    this.#checkOpen();
    if (!Number.isInteger(slot) || slot < 0 || slot >= this.slots) throw new RangeError("expert slot out of range");
  }

  #checkOpen(): void {
    if (this.#state !== "open") throw new Error("expert slab store is closed");
  }
}

export { EBUSY as EXPERT_IO_BUSY_ERRNO };

export interface LruCandidate { slot: number; lastUse: bigint; pinned?: boolean; leased?: boolean }

/** Deterministic eviction primitive: oldest use wins, then lowest slot ID. */
export function selectExpertLruVictim(candidates: readonly LruCandidate[]): number | null {
  let best: LruCandidate | null = null;
  for (const candidate of candidates) {
    if (candidate.pinned || candidate.leased) continue;
    if (!best || candidate.lastUse < best.lastUse ||
        (candidate.lastUse === best.lastUse && candidate.slot < best.slot)) best = candidate;
  }
  return best?.slot ?? null;
}
