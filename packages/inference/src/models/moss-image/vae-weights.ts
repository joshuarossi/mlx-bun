// Decoder-local ownership of the precision conversion. The source maps can
// retain their original float32 buffers, so detach each converted tensor before
// releasing its shard. Nothing in the shared Weights implementation changes.
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { materializeCopy } from "@mlx-bun/mlx/materialize";
import type { Weights } from "../../artifacts/weights";

export type Flux2VaeWeightSource = Pick<Weights,
  "tensorNames" | "setView" | "fileOf" | "tensor" | "releaseShard" | "dispose">;

/** The tensors used by the published FLUX.2 VAE decode path. */
export function flux2DecoderTensor(name: string): boolean {
  return name.startsWith("decoder.") || name.startsWith("post_quant_conv.") || name.startsWith("bn.");
}

/** Owns evaluated bf16 copies. Layers borrow their handles until dispose(). */
export class Flux2VaeWeights {
  private constructor(readonly tensors: ReadonlyMap<string, MlxArray>) {}

  /** Consumes source, including on failure. Source maps are released shard by
   * shard after their converted tensors have independent, evaluated storage.
   * Only one shard's source/cast temporaries overlap the retained bf16 copies. */
  static from(source: Flux2VaeWeightSource): Flux2VaeWeights {
    const tensors = new Map<string, MlxArray>();
    try {
      const names = source.tensorNames.filter(flux2DecoderTensor);
      source.setView({
        names: new Map(names.map(name => [name, name])),
        fixup: (_name, array) => array.astype(Dtype.bfloat16),
      });
      const shards = new Map<string, string[]>();
      for (const name of names) {
        const file = source.fileOf(name);
        if (!file) throw new Error(`VAE weight has no shard: ${name}`);
        const group = shards.get(file) ?? [];
        group.push(name);
        shards.set(file, group);
      }
      for (const [file, group] of shards) {
        try {
          for (const name of group) {
            const owned = materializeCopy(source.tensor(name));
            try { owned.eval(); }
            catch (error) { owned.dispose(); throw error; }
            tensors.set(name, owned);
          }
        } finally {
          source.releaseShard(file);
        }
      }
      return new Flux2VaeWeights(tensors);
    } catch (error) {
      for (const tensor of tensors.values()) tensor.dispose();
      throw error;
    } finally {
      source.dispose();
    }
  }

  tensor(name: string): MlxArray {
    const tensor = this.tensors.get(name);
    if (!tensor) throw new Error(`missing VAE weight ${name}`);
    return tensor;
  }

  dispose(): void { for (const tensor of this.tensors.values()) tensor.dispose(); }
}
