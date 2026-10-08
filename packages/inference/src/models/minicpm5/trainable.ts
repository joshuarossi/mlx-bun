import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache, SharedKv } from "../../contracts/mlx/cache";
import type { HeadQuant, PrefixLayout, SegmentedPass, TrainableGraph } from "../../contracts/mlx/trainable";
import { setActivePrefixLayout } from "../../layers/prefix-layout";
import { prefixSharedCaches, TrainingCache } from "../../state/training-cache";
import type { RMSNorm } from "../../layers/normalization";
import type { QuantizedEmbedding } from "../../layers/quantized-embedding";
import type { QuantizedLinear } from "../../layers/quantized-linear";

/** What the training declaration reads from a MiniCPM5 model (structural, so this
 *  module does not depend on the model file). */
export interface MiniCpmTraining {
  readonly embed: QuantizedEmbedding;
  readonly layers: readonly unknown[];
  readonly finalNorm: RMSNorm;
  readonly lmHead: QuantizedLinear;
  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray;
  runLayerRange(h: MlxArray, aIdx: number, bIdx: number, cache: Cache[]): MlxArray;
}

/** One segmented pass over a MiniCPM5 sequence: plain full attention with no KV
 *  sharing, so each layer reads its own stateless cache (prefix-shared caches
 *  build the block-sparse mask when a layout is given). */
class MiniCpmSegmentedPass implements SegmentedPass {
  readonly input: MlxArray;
  private readonly caches: Cache[];

  constructor(private readonly model: MiniCpmTraining, ids: MlxArray, private readonly prefix?: PrefixLayout) {
    const layers = model.layers.length;
    this.caches = prefix ? prefixSharedCaches(layers, prefix) : Array.from({ length: layers }, () => new TrainingCache());
    if (prefix) setActivePrefixLayout(prefix);
    try {
      this.input = model.embed.encode(ids); // [1, T, hidden]
    } catch (error) {
      this.releaseCaches();
      throw error;
    }
  }

  private releaseCaches(): void {
    if (this.prefix) setActivePrefixLayout(null);
    for (const c of this.caches) c.dispose();
  }

  runRange(h: MlxArray, lo: number, hi: number, _donorKvIn: Map<number, SharedKv>) {
    return { h: this.model.runLayerRange(h, lo, hi, this.caches), donorKvOut: new Map<number, SharedKv>() };
  }

  dispose(): void { this.releaseCaches(); }
}

/** MiniCPM5's training declaration. */
export function miniCpmTrainable(model: MiniCpmTraining): TrainableGraph {
  return {
    lmHead(): HeadQuant {
      const h = model.lmHead;
      return { w: h.w, scales: h.scales, biases: h.biases, spec: h.spec, softcap: null };
    },
    flashAttention: { supported: true },
    segmented: {
      layerCount: model.layers.length,
      sharedKv: { reusedDonors: new Set(), donorOf: model.layers.map(() => null) },
      finalNorm: (h) => model.finalNorm.forward(h),
      begin: (ids, prefix) => new MiniCpmSegmentedPass(model, ids, prefix),
    },
    prefixShared: {
      forwardHidden(ids: MlxArray, layout: PrefixLayout): MlxArray {
        const caches = prefixSharedCaches(model.layers.length, layout);
        setActivePrefixLayout(layout);
        try {
          return model.forwardHidden(ids, caches); // [1, T, hidden], post-finalNorm
        } finally {
          setActivePrefixLayout(null);
          for (const c of caches) c.dispose();
        }
      },
    },
  };
}
