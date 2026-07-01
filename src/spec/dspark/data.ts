// DSpark training data — the regen target (paper §3.3 + §5.1 "hidden state
// communication"). Training the drafter requires, per block position, the
// frozen target's TRUE distribution p^t and the tapped hidden state. Rather
// than store full-vocab logits (V≈262k → enormous), we store only the target's
// per-position final hidden states (the tap, H≈2816) plus the token ids, and
// recompute p^t on the fly during training via the SHARED frozen LM head —
// O(d) storage instead of O(V). (paper §5.1.)
//
// On-disk layout: a directory of shards, each `shard_NNNNN/model.safetensors`
// holding three tensors over a pack of sequences:
//   - "hidden"   [Ltot, H] bf16  — concatenated per-position final hiddens
//   - "ids"      [Ltot]    int32 — concatenated token ids
//   - "seq_lens" [nSeq]    int32 — per-sequence lengths (to split Ltot)
// plus a sidecar `shard.json` with counts. The regen script (Josh runs it on
// GPU) writes these; the trainer reads them and samples anchor blocks.
//
// An anchor at sequence position t yields a training example:
//   hCtx        = hidden[t]            (the injected context, paper H_ctx)
//   anchorTok   = ids[t]              (the bonus token x0)
//   blockToks   = ids[t+1 .. t+γ]     (ground truth x*_1..x*_γ)
//   targetHidden= hidden[t+1 .. t+γ]  (→ p^t_k via the frozen head at train)

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { loadAdapterTensors } from "../../lora";
import { writeShardedSafetensors, type NamedTensor } from "../../quantize/safetensors-writer";
import { mkdirSync, writeFileSync, readFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

/** One re-forwarded sequence: ids + per-position final hidden (bf16 bytes). */
export interface DSparkRecord {
  ids: number[];
  /** Row-major [L, H] bf16 bytes (from MlxArray.rawBytes of the tap). */
  hiddenBf16: Uint8Array;
}

export interface DSparkShardMeta {
  nSeq: number;
  nTokens: number;
  hiddenSize: number;
}

/** Write a shard of re-forwarded sequences to `dir/shard_NNNNN/`. */
export function writeDSparkShard(
  outDir: string,
  shardIdx: number,
  records: DSparkRecord[],
  hiddenSize: number,
): DSparkShardMeta {
  const dir = join(outDir, `shard_${String(shardIdx).padStart(5, "0")}`);
  mkdirSync(dir, { recursive: true });

  const seqLens: number[] = [];
  const allIds: number[] = [];
  const hiddenParts: Uint8Array[] = [];
  for (const rec of records) {
    seqLens.push(rec.ids.length);
    for (const id of rec.ids) allIds.push(id);
    hiddenParts.push(rec.hiddenBf16);
  }
  const nTokens = allIds.length;

  // concat hidden bytes
  let total = 0;
  for (const p of hiddenParts) total += p.length;
  const hiddenBytes = new Uint8Array(total);
  let off = 0;
  for (const p of hiddenParts) { hiddenBytes.set(p, off); off += p.length; }

  const hidden = MlxArray.fromBytesCopy(hiddenBytes, [nTokens, hiddenSize], Dtype.bfloat16);
  const ids = MlxArray.fromInt32(new Int32Array(allIds), [nTokens]);
  const lens = MlxArray.fromInt32(new Int32Array(seqLens), [seqLens.length]);
  const tensors: NamedTensor[] = [
    { name: "hidden", array: hidden },
    { name: "ids", array: ids },
    { name: "seq_lens", array: lens },
  ];
  writeShardedSafetensors(dir, tensors);
  hidden.dispose(); ids.dispose(); lens.dispose();

  const meta: DSparkShardMeta = { nSeq: records.length, nTokens, hiddenSize };
  writeFileSync(join(dir, "shard.json"), JSON.stringify(meta, null, 2));
  return meta;
}

/** A loaded shard, ready for anchor sampling. Owns `hidden`; call dispose(). */
export class DSparkShard {
  readonly hidden: MlxArray;   // [Ltot, H] bf16
  readonly ids: Int32Array;    // [Ltot]
  readonly seqStart: number[]; // per-seq start offset into Ltot
  readonly seqLen: number[];   // per-seq length
  readonly hiddenSize: number;

  constructor(hidden: MlxArray, ids: Int32Array, seqLens: Int32Array, hiddenSize: number) {
    this.hidden = hidden;
    this.ids = ids;
    this.hiddenSize = hiddenSize;
    this.seqStart = [];
    this.seqLen = [];
    let off = 0;
    for (const l of seqLens) {
      this.seqStart.push(off);
      this.seqLen.push(l);
      off += l;
    }
  }

  static load(dir: string): DSparkShard {
    const metaPath = join(dir, "shard.json");
    if (!existsSync(metaPath)) throw new Error(`no shard.json in ${dir}`);
    const meta = JSON.parse(readFileSync(metaPath, "utf8")) as DSparkShardMeta;
    const t = loadAdapterTensors(join(dir, "model.safetensors"));
    try {
      const hidden = t.get("hidden");
      const idsArr = t.get("ids");
      const lensArr = t.get("seq_lens");
      if (!hidden || !idsArr || !lensArr) throw new Error(`shard ${dir} missing tensors`);
      // int32 ids round-trip exactly through f32 (vocab < 2^24).
      const ids = Int32Array.from(idsArr.toFloat32(), (v) => Math.round(v));
      const lens = Int32Array.from(lensArr.toFloat32(), (v) => Math.round(v));
      idsArr.dispose(); lensArr.dispose();
      return new DSparkShard(hidden, ids, lens, meta.hiddenSize);
    } catch (e) {
      for (const [, arr] of t) arr.dispose();
      throw e;
    }
  }

  dispose(): void {
    this.hidden.dispose();
  }
}

/** List shard directories under a data root, sorted. */
export function listShards(root: string): string[] {
  if (!existsSync(root)) return [];
  return readdirSync(root)
    .filter((n) => n.startsWith("shard_"))
    .sort()
    .map((n) => join(root, n));
}

export interface DSparkBatch {
  /** [A, H] bf16 — tapped target hidden at each anchor. */
  hCtx: MlxArray;
  /** [A, γ, H] bf16 — target final hiddens at the γ block positions. */
  targetHidden: MlxArray;
  /** anchor token x0 per row. */
  anchorToks: number[];
  /** ground-truth block tokens x*_1..x*_γ per row [A][γ]. */
  blockToks: number[][];
  /** number of anchors A. */
  size: number;
}

/**
 * Sample A anchors from a loaded shard and gather them into a training batch.
 * A valid anchor at global index g (within a sequence) needs γ continuation
 * tokens in the SAME sequence. `rng` returns [0,1).
 */
export function sampleBatch(shard: DSparkShard, A: number, gamma: number, rng: () => number): DSparkBatch | null {
  const anchorGlobal: number[] = [];
  const anchorToks: number[] = [];
  const blockToks: number[][] = [];
  const blockGlobal: number[] = []; // flattened γ indices per anchor

  let guard = 0;
  while (anchorGlobal.length < A && guard < A * 64) {
    guard++;
    const s = Math.floor(rng() * shard.seqLen.length);
    const len = shard.seqLen[s]!;
    if (len < gamma + 1) continue;
    const start = shard.seqStart[s]!;
    // local anchor position t in [0, len-γ-1]
    const t = Math.floor(rng() * (len - gamma));
    const g = start + t;
    anchorGlobal.push(g);
    anchorToks.push(shard.ids[g]!);
    const bt: number[] = [];
    for (let k = 1; k <= gamma; k++) {
      bt.push(shard.ids[g + k]!);
      blockGlobal.push(g + k);
    }
    blockToks.push(bt);
  }
  if (anchorGlobal.length === 0) return null;
  const got = anchorGlobal.length;

  const anchorIdx = MlxArray.fromInt32(new Int32Array(anchorGlobal), [got]);
  const hCtx = ops.takeAxis(shard.hidden, anchorIdx, 0); // [A,H]
  anchorIdx.dispose();

  const blockIdx = MlxArray.fromInt32(new Int32Array(blockGlobal), [got * gamma]);
  const tgtFlat = ops.takeAxis(shard.hidden, blockIdx, 0); // [A*γ, H]
  blockIdx.dispose();
  const targetHidden = ops.reshape(tgtFlat, [got, gamma, shard.hiddenSize]);
  tgtFlat.dispose();

  return { hCtx, targetHidden, anchorToks, blockToks, size: got };
}
