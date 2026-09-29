import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Checkpoint } from "@mlx-bun/mlx/checkpoint";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache, Mask, SharedKv } from "../../contracts/mlx/cache";
import type {
  GradCheckpointRun, HeadQuant, LoraLeaves, PrefixLayout, SegmentedPass, TrainableGraph,
} from "../../contracts/mlx/trainable";
import { setActivePrefixLayout } from "../../layers/prefix-layout";
import { PrefixSharedCache, TrainingCache } from "../../state/training-cache";
import type { LoraWeights } from "../../layers/lora";
import type { RMSNorm } from "../../layers/normalization";
import type { QuantizedEmbedding } from "../../layers/quantized-embedding";

/** Optional gradient-checkpointing context for the training forward. When set,
 *  forwardLayers wraps each layer in a Checkpoint so its interior activations
 *  are recomputed in the backward pass. `byLayer` maps a layer index to that
 *  layer's trainable LoRA weights, partitioned into the attention sub-block
 *  (q/k/v/o_proj) and the MLP sub-block (gate/up/down_proj + per-layer gate/
 *  projection) — re-swapped inside the closure so they are explicit checkpoint
 *  inputs (required because the autograd primals are disposed before the
 *  recompute). When `splitMlp` is set, the layer is wrapped in TWO checkpoints
 *  (attn sub-block + MLP sub-block) with the post-attn residual `hMid` as the
 *  boundary, so the backward recompute holds `max(attn,MLP)+hMid` instead of the
 *  whole layer (the intra-layer MLP split, lever 4). `keepAlive` collects the
 *  Checkpoint objects; the trainer disposes them after value_and_grad. */
export interface LayerLoras {
  attn: LoraWeights[];
  mlp: LoraWeights[];
}
export interface GradCheckpointCtx {
  byLayer: Map<number, LayerLoras>;
  splitMlp: boolean;
  keepAlive: Checkpoint[];
}

/** What the training declaration reads from a Gemma 4 model (structural, so this
 *  module does not depend on the model file). */
export interface Gemma4Training {
  readonly config: { readonly text: { readonly finalLogitSoftcapping: number | null } };
  readonly embed: QuantizedEmbedding;
  readonly finalNorm: RMSNorm;
  readonly layers: readonly unknown[];
  /** Donor count: layers [0, numDonors) own caches; the rest share. */
  readonly numDonors: number;
  readonly previousKvs: readonly number[];
  readonly cacheIndex: readonly number[];
  readonly reusedDonors: Set<number>;
  gradCkpt: GradCheckpointCtx | null;
  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray;
  embedForSegmented(ids: MlxArray): { hScaled: MlxArray; perLayer: MlxArray | null };
  makeTrainingMasks(cache: Cache[], L: number): Map<string, Mask>;
  runLayerRange(
    h: MlxArray, aIdx: number, bIdx: number, cache: Cache[],
    masks: Map<string, Mask>, perLayer: MlxArray | null, donorKvIn: Map<number, SharedKv>,
  ): { h: MlxArray; donorKvOut: Map<number, SharedKv> };
}

/** Copy `a` into a graph-free leaf (an evaluated, row-major copy), disposing `a`. */
function detached(a: MlxArray): MlxArray {
  const c = ops.contiguous(a);
  const leaf = c.detachCopy();
  c.dispose();
  a.dispose();
  return leaf;
}

/** One segmented pass over a Gemma 4 sequence: the per-layer-input tensor (a
 *  constant boundary sliced per layer), the per-layer-type masks (block-sparse
 *  with a logical-position window when prefix-shared), and one stateless cache
 *  per donor layer (sharers reuse the donors' fetched K/V). */
class Gemma4SegmentedPass implements SegmentedPass {
  readonly input: MlxArray;
  private readonly caches: Cache[];
  private readonly prefixCaches: Cache[] = [];
  private readonly perLayer: MlxArray | null = null;
  private readonly masks: Map<string, Mask>;

  constructor(private readonly model: Gemma4Training, ids: MlxArray, private readonly prefix?: PrefixLayout) {
    this.caches = Array.from({ length: model.numDonors }, () => new TrainingCache());
    if (prefix) {
      this.prefixCaches = Array.from({ length: model.numDonors }, () => new PrefixSharedCache(prefix));
      setActivePrefixLayout(prefix);
    }
    let input: MlxArray | null = null;
    let perLayer: MlxArray | null = null;
    try {
      const embedded = model.embedForSegmented(ids);
      input = embedded.hScaled;
      perLayer = embedded.perLayer ? detached(embedded.perLayer) : null;
      // Prefix masks come from the prefix caches; the running K/V still fetches into `caches`.
      this.masks = model.makeTrainingMasks(prefix ? this.prefixCaches : this.caches, ids.shape[1]!);
    } catch (error) {
      input?.dispose();
      perLayer?.dispose();
      this.releaseCaches();
      throw error;
    }
    this.input = input;
    this.perLayer = perLayer;
  }

  private releaseCaches(): void {
    if (this.prefix) setActivePrefixLayout(null);
    for (const c of this.prefixCaches) c.dispose();
    for (const c of this.caches) c.dispose();
  }

  runRange(h: MlxArray, lo: number, hi: number, donorKvIn: Map<number, SharedKv>) {
    return this.model.runLayerRange(h, lo, hi, this.caches, this.masks, this.perLayer, donorKvIn);
  }

  dispose(): void {
    this.releaseCaches();
    this.perLayer?.dispose();
    for (const m of this.masks.values()) m.arr?.dispose();
  }
}

function checkpointRun(model: Gemma4Training, targets: readonly { modulePath: string; lw: LoraLeaves }[], splitMlp: boolean): GradCheckpointRun {
  // Partition each layer's LoRA into the attention sub-block (self_attn.*) and
  // the MLP sub-block (everything else in the layer: gate/up/down_proj +
  // per_layer_*) so the split-MLP checkpoint can wrap them independently.
  const byLayer: GradCheckpointCtx["byLayer"] = new Map();
  for (const t of targets) {
    const m = t.modulePath.match(/\.layers\.(\d+)\./);
    if (!m) continue;
    const li = Number(m[1]);
    const ll = byLayer.get(li) ?? byLayer.set(li, { attn: [], mlp: [] }).get(li)!;
    (t.modulePath.includes(".self_attn.") ? ll.attn : ll.mlp).push(t.lw);
  }
  // Checkpoints are created per forward and disposed after each step's backward.
  const ctx: GradCheckpointCtx = { byLayer, splitMlp, keepAlive: [] };
  model.gradCkpt = ctx;
  return {
    releaseStep() {
      for (const ck of ctx.keepAlive) ck.dispose();
      ctx.keepAlive.length = 0;
    },
    suspend() { model.gradCkpt = null; },
    resume() { model.gradCkpt = ctx; },
    end() {
      model.gradCkpt = null;
      for (const ck of ctx.keepAlive) ck.dispose();
    },
  };
}

/** Gemma 4's training declaration. */
export function gemma4Trainable(model: Gemma4Training): TrainableGraph {
  const donorOf = model.layers.map((_, i) => (model.cacheIndex[i] === -1 ? model.previousKvs[i]! : null));
  return {
    lmHead(): HeadQuant {
      // Tied: the quantized embedding is the head; the softcap comes from the config.
      const e = model.embed;
      return { w: e.w, scales: e.scales, biases: e.biases, spec: e.spec, softcap: model.config.text.finalLogitSoftcapping };
    },
    flashAttention: {
      supported: false,
      reason: "e4b SIGTRAPs on this path at seq >= 2048 and it has not been re-validated at that scale since the kernel fixes",
    },
    segmented: {
      layerCount: model.layers.length,
      sharedKv: { reusedDonors: model.reusedDonors, donorOf },
      finalNorm: (h) => model.finalNorm.forward(h),
      begin: (ids, prefix) => new Gemma4SegmentedPass(model, ids, prefix),
    },
    prefixShared: {
      forwardHidden(ids: MlxArray, layout: PrefixLayout): MlxArray {
        // One prefix cache per DONOR layer (sharers consume donors' fetched K/V inside forwardLayers).
        const caches: Cache[] = Array.from({ length: model.numDonors }, () => new PrefixSharedCache(layout));
        setActivePrefixLayout(layout);
        try {
          return model.forwardHidden(ids, caches); // [1, T, hidden], post-finalNorm
        } finally {
          setActivePrefixLayout(null);
          for (const c of caches) c.dispose();
        }
      },
    },
    gradCheckpoint: { enable: (targets, splitMlp) => checkpointRun(model, targets, splitMlp) },
  };
}
