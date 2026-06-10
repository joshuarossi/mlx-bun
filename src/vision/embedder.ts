// Vision feature pipeline — port of optiq's gemma4_unified VisionEmbedder
// + MultimodalEmbedder (vendored from mlx-vlm, BSD-3).
//
// Encoder-free: patches [n, 6912] → LayerNorm → Linear(+bias) → LayerNorm
// → + 2D pos embedding → LayerNorm → RMSNormNoScale → Linear(no bias)
// → divide by embed_scale (the language model re-multiplies it).
//
// Sidecar weights stay bf16; features come out bf16 like text embeddings.

import { ptr } from "bun:ffi";
import { MlxArray, cpuStream } from "../mlx/array";
import { C } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { PreprocessedImage } from "./preprocess";
import { NUM_SOFT_TOKENS } from "./preprocess";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

export class VisionTower {
  #weights = new Map<string, MlxArray>();
  readonly embedScale: number;
  readonly rmsNormEps: number;

  private constructor(embedScale: number, rmsNormEps: number) {
    this.embedScale = embedScale;
    this.rmsNormEps = rmsNormEps;
  }

  static load(modelDir: string, embedScale: number, rmsNormEps = 1e-6): VisionTower {
    const self = new VisionTower(embedScale, rmsNormEps);
    const arrMap = new BigUint64Array([C.mlx_map_string_to_array_new()]);
    const metaMap = new BigUint64Array([C.mlx_map_string_to_string_new()]);
    const status = C.mlx_load_safetensors(
      ptr(arrMap), ptr(metaMap), ptr(cstr(`${modelDir}/optiq_vision.safetensors`)), cpuStream,
    );
    C.mlx_map_string_to_string_free(metaMap[0]!);
    if (status !== 0) throw new Error(`failed to load vision sidecar from ${modelDir}`);
    const names = [
      "vision_embedder.patch_ln1.weight", "vision_embedder.patch_ln1.bias",
      "vision_embedder.patch_dense.weight", "vision_embedder.patch_dense.bias",
      "vision_embedder.patch_ln2.weight", "vision_embedder.patch_ln2.bias",
      "vision_embedder.pos_embedding",
      "vision_embedder.pos_norm.weight", "vision_embedder.pos_norm.bias",
      "embed_vision.embedding_projection.weight",
    ];
    for (const name of names) {
      const slot = new BigUint64Array([C.mlx_array_new()]);
      if (C.mlx_map_string_to_array_get(ptr(slot), arrMap[0]!, ptr(cstr(name))) !== 0)
        throw new Error(`vision sidecar missing tensor ${name}`);
      self.#weights.set(name, new MlxArray(slot[0]!));
    }
    C.mlx_map_string_to_array_free(arrMap[0]!);
    return self;
  }

  #w(name: string): MlxArray {
    return this.#weights.get(name)!;
  }

  /** nn.Linear: x @ W.T (+ bias). */
  #linear(x: MlxArray, weight: MlxArray, bias: MlxArray | null): MlxArray {
    const wT = ops.transposeAxes(weight, [1, 0]);
    let out = ops.matmul(x, wT);
    wT.dispose();
    if (bias) {
      const withBias = ops.add(out, bias);
      out.dispose();
      out = withBias;
    }
    return out;
  }

  /** One image's preprocessed patches → language-space features
   *  [softTokens, hidden] (pre-divided by embed_scale). */
  features(img: PreprocessedImage): MlxArray {
    const eps = this.rmsNormEps;
    const patchDim = img.patches.length / NUM_SOFT_TOKENS;
    let h: MlxArray = MlxArray.fromFloat32(img.patches, [1, NUM_SOFT_TOKENS, patchDim]);

    h = disposing(h, ops.layerNorm(h,
      this.#w("vision_embedder.patch_ln1.weight"),
      this.#w("vision_embedder.patch_ln1.bias"), eps));
    h = disposing(h, this.#linear(h,
      this.#w("vision_embedder.patch_dense.weight"),
      this.#w("vision_embedder.patch_dense.bias")));
    h = disposing(h, ops.layerNorm(h,
      this.#w("vision_embedder.patch_ln2.weight"),
      this.#w("vision_embedder.patch_ln2.bias"), eps));

    // + 2D position embedding: posemb[clamped[:,0], 0] + posemb[clamped[:,1], 1]
    // (clamp + validity mask precomputed host-side; padding rows get -1)
    const n = NUM_SOFT_TOKENS;
    const xIdx = new Int32Array(n);
    const yIdx = new Int32Array(n);
    const valid = new Float32Array(2 * n);
    for (let i = 0; i < n; i++) {
      const px = img.positions[i * 2]!;
      const py = img.positions[i * 2 + 1]!;
      xIdx[i] = Math.max(px, 0);
      yIdx[i] = Math.max(py, 0);
      valid[i] = px === -1 ? 0 : 1;
      valid[n + i] = py === -1 ? 0 : 1;
    }
    const posemb = this.#w("vision_embedder.pos_embedding"); // [1120, 2, 3840]
    const addPos = (idx: Int32Array, dim: number, validOff: number): MlxArray => {
      const idxArr = MlxArray.fromInt32(idx, [n]);
      const rows = ops.takeAxis(posemb, idxArr, 0); // [n, 2, 3840]
      idxArr.dispose();
      const sel = rows.slice([0, dim, 0], [n, dim + 1, 3840]);
      rows.dispose();
      const flat = ops.reshape(sel, [1, n, 3840]);
      sel.dispose();
      const v = MlxArray.fromFloat32(valid.subarray(validOff, validOff + n).slice(), [1, n, 1]);
      const vCast = v.astype(flat.dtype);
      v.dispose();
      const masked = ops.mul(flat, vCast);
      flat.dispose();
      vCast.dispose();
      return masked;
    };
    const xPos = addPos(xIdx, 0, 0);
    const yPos = addPos(yIdx, 1, n);
    const posSum = ops.add(xPos, yPos);
    xPos.dispose();
    yPos.dispose();
    h = disposing(h, ops.add(h, posSum));
    posSum.dispose();

    h = disposing(h, ops.layerNorm(h,
      this.#w("vision_embedder.pos_norm.weight"),
      this.#w("vision_embedder.pos_norm.bias"), eps));

    // MultimodalEmbedder: RMSNormNoScale → Linear(no bias)
    h = disposing(h, ops.rmsNorm(h, null, eps));
    h = disposing(h, this.#linear(h,
      this.#w("embed_vision.embedding_projection.weight"), null));

    // keep only real (unpadded) soft tokens; pre-divide by embed_scale
    const hidden = h.shape[2]!;
    const real = h.slice([0, 0, 0], [1, img.softTokens, hidden]);
    h.dispose();
    const scale = ops.scalarLike(this.embedScale, real);
    const out = ops.div(real, scale);
    real.dispose();
    scale.dispose();
    return out; // [1, softTokens, hidden]
  }

  dispose(): void {
    for (const w of this.#weights.values()) w.dispose();
    this.#weights.clear();
  }
}

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
