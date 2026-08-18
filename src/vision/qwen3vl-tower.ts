// Qwen3-VL vision tower (Qwen3.8's `vision_tower`, PLAN 14v) — faithful port
// of mlx-vlm qwen3_vl/vision.py at the qwen3_5 configuration: depth 27,
// hidden 1152, heads 16 (head_dim 72), patch 16, temporal 2, merge 2,
// intermediate 4304 with gelu_pytorch_tanh, learned 48×48 pos-embed grid
// bilinearly interpolated, 2D half/half rotary (dim 36) over full head_dim,
// pre-LN blocks with biased LayerNorms, merger LayerNorm→fc1→GELU(erf)→fc2
// to out_hidden 5120. deepstack is EMPTY for qwen3_5 and not ported.
//
// Weights: the artifact ships the tower as a bf16 sidecar
// (optiq/optiq_vision.safetensors, 333 tensors, MLX conv layout). The
// Conv3d patch embed has kernel == stride, so it is computed as one matmul
// against the weight flattened to the preprocessor's (c, t, py, px) row
// order — same values, GEMM accumulation (gate: tower output vs the mlx-vlm
// capture; e2e tokens are the decisive gate, the SigLIP precedent).
//
// Input rows arrive MERGE-BLOCK-MAJOR from qwen3vl-preprocess.ts; rope
// h/w positions and the pos-embed permutation are built in the same order.

import { ptr, read } from "bun:ffi";
import { MlxArray, cpuStream } from "../mlx/array";
import { C, Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Qwen3VLPreprocessed } from "./qwen3vl-preprocess";
import {
  QWEN3VL_MERGE_SIZE,
  QWEN3VL_PATCH_SIZE,
  QWEN3VL_TEMPORAL_PATCH_SIZE,
} from "./qwen3vl-preprocess";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

const DEPTH = 27;
const HIDDEN = 1152;
const HEADS = 16;
const HEAD_DIM = HIDDEN / HEADS; // 72
const ROT_DIM = HEAD_DIM / 2; // 36 (VisionRotaryEmbedding dim)
const INTERMEDIATE = 4304;
const OUT_HIDDEN = 5120;
const POS_GRID = 48; // sqrt(num_position_embeddings 2304)
const ROPE_THETA = 10000;

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

interface Block {
  norm1W: MlxArray; norm1B: MlxArray;
  norm2W: MlxArray; norm2B: MlxArray;
  qkvW: MlxArray; qkvB: MlxArray;
  projW: MlxArray; projB: MlxArray;
  fc1W: MlxArray; fc1B: MlxArray;
  fc2W: MlxArray; fc2B: MlxArray;
}

export class Qwen3VLVisionTower {
  #patchW: MlxArray; // [1536, 1152] — flattened conv, already transposed
  #patchB: MlxArray;
  #posEmbed: MlxArray; // [2304, 1152]
  #blocks: Block[];
  #mergerNormW: MlxArray; #mergerNormB: MlxArray;
  #mergerFc1W: MlxArray; #mergerFc1B: MlxArray;
  #mergerFc2W: MlxArray; #mergerFc2B: MlxArray;

  private constructor(w: Map<string, MlxArray>) {
    const t = (n: string): MlxArray => {
      const a = w.get(`vision_tower.${n}`);
      if (!a) throw new Error(`vision sidecar missing tensor vision_tower.${n}`);
      return a;
    };
    // Conv3d weight [1152, 2, 16, 16, 3] (out, kT, kH, kW, in) — used with
    // the REAL conv3d op (kernel == stride): a value-equivalent GEMM rounds
    // differently in bf16 and the ulp seeds diverge through 27 blocks.
    this.#patchW = t("patch_embed.proj.weight");
    this.#patchB = t("patch_embed.proj.bias");
    this.#posEmbed = t("pos_embed.weight");
    this.#blocks = [];
    for (let i = 0; i < DEPTH; i++) {
      const p = `blocks.${i}`;
      this.#blocks.push({
        norm1W: t(`${p}.norm1.weight`), norm1B: t(`${p}.norm1.bias`),
        norm2W: t(`${p}.norm2.weight`), norm2B: t(`${p}.norm2.bias`),
        qkvW: t(`${p}.attn.qkv.weight`), qkvB: t(`${p}.attn.qkv.bias`),
        projW: t(`${p}.attn.proj.weight`), projB: t(`${p}.attn.proj.bias`),
        fc1W: t(`${p}.mlp.linear_fc1.weight`), fc1B: t(`${p}.mlp.linear_fc1.bias`),
        fc2W: t(`${p}.mlp.linear_fc2.weight`), fc2B: t(`${p}.mlp.linear_fc2.bias`),
      });
    }
    this.#mergerNormW = t("merger.norm.weight");
    this.#mergerNormB = t("merger.norm.bias");
    this.#mergerFc1W = t("merger.linear_fc1.weight");
    this.#mergerFc1B = t("merger.linear_fc1.bias");
    this.#mergerFc2W = t("merger.linear_fc2.weight");
    this.#mergerFc2B = t("merger.linear_fc2.bias");
  }

  static load(modelDir: string): Qwen3VLVisionTower {
    const arrMap = new BigUint64Array([C.mlx_map_string_to_array_new()]);
    const metaMap = new BigUint64Array([C.mlx_map_string_to_string_new()]);
    const arrMapPtr = ptr(arrMap);
    const metaMapPtr = ptr(metaMap);
    const status = C.mlx_load_safetensors(
      arrMapPtr, metaMapPtr,
      ptr(cstr(`${modelDir}/optiq/optiq_vision.safetensors`)), cpuStream,
    );
    C.mlx_map_string_to_string_free(read.u64(metaMapPtr, 0));
    const handle = read.u64(arrMapPtr, 0);
    if (status !== 0) {
      // The out-param map was allocated regardless — free it on the error
      // path too (2026-08-18 review; one-shot leak, but a leak).
      C.mlx_map_string_to_array_free(handle);
      throw new Error(`failed to load qwen vision sidecar from ${modelDir}`);
    }
    const weights = new Map<string, MlxArray>();
    // Pull every tensor we model by constructed name (333 total).
    const names: string[] = [
      "vision_tower.patch_embed.proj.weight", "vision_tower.patch_embed.proj.bias",
      "vision_tower.pos_embed.weight",
      "vision_tower.merger.norm.weight", "vision_tower.merger.norm.bias",
      "vision_tower.merger.linear_fc1.weight", "vision_tower.merger.linear_fc1.bias",
      "vision_tower.merger.linear_fc2.weight", "vision_tower.merger.linear_fc2.bias",
    ];
    for (let i = 0; i < DEPTH; i++) {
      for (const nm of [
        "norm1.weight", "norm1.bias", "norm2.weight", "norm2.bias",
        "attn.qkv.weight", "attn.qkv.bias", "attn.proj.weight", "attn.proj.bias",
        "mlp.linear_fc1.weight", "mlp.linear_fc1.bias",
        "mlp.linear_fc2.weight", "mlp.linear_fc2.bias",
      ]) names.push(`vision_tower.blocks.${i}.${nm}`);
    }
    try {
      for (const name of names) {
        const slot = new BigUint64Array([C.mlx_array_new()]);
        const slotPtr = ptr(slot);
        if (C.mlx_map_string_to_array_get(slotPtr, handle, ptr(cstr(name))) !== 0)
          throw new Error(`qwen vision sidecar missing tensor ${name}`);
        weights.set(name, new MlxArray(read.u64(slotPtr, 0)));
      }
    } catch (e) {
      for (const [, a] of weights) a.dispose();
      throw e;
    } finally {
      C.mlx_map_string_to_array_free(handle);
    }
    return new Qwen3VLVisionTower(weights);
  }

  /** One vision block: pre-LN attention (+residual), pre-LN MLP (+residual).
   *  Consumes `h`. */
  #block(
    h: MlxArray, blk: Block, cos: MlxArray, sin: MlxArray,
    scale: number, n: number, segLen: number = n,
  ): MlxArray {
    const xn = ops.layerNorm(h, blk.norm1W, blk.norm1B, 1e-6);
    const qkv = this.#linear(xn, blk.qkvW, blk.qkvB); // [n, 3456]
    xn.dispose();
    const qkv4 = disposing(qkv, ops.reshape(qkv, [n, 3, HEADS, HEAD_DIM]));
    const [qs, ks, vs] = ops.split(qkv4, [1, 2], 1) as [MlxArray, MlxArray, MlxArray];
    qkv4.dispose();
    let q = disposing(qs, ops.reshape(qs, [n, HEADS, HEAD_DIM]));
    let k = disposing(ks, ops.reshape(ks, [n, HEADS, HEAD_DIM]));
    const v = disposing(vs, ops.reshape(vs, [n, HEADS, HEAD_DIM]));
    q = disposing(q, this.#applyRope(q, cos, sin));
    k = disposing(k, this.#applyRope(k, cos, sin));
    // [1, HEADS, n, HEAD_DIM] full (non-causal) attention — one image =
    // one cu_seqlens segment, so no mask. The reference's ensure_fused_sdpa
    // ZERO-PADS head_dim 72 → 80 (nearest fused-kernel width), runs fused
    // sdpa there, and slices back; the padded kernel's accumulation is the
    // parity-relevant arithmetic, so replicate it exactly.
    const PAD_DIM = 80;
    const padTo = (x: MlxArray): MlxArray => {
      const z = ops.zeros([n, HEADS, PAD_DIM - HEAD_DIM], Dtype.bfloat16);
      const p = ops.concatAxis([x, z], -1);
      z.dispose();
      return disposing(x, p);
    };
    const lift = (x: MlxArray): MlxArray => {
      const p = padTo(x); // consumes x
      const tr = ops.transposeAxes(p, [1, 0, 2]);
      p.dispose();
      return disposing(tr, ops.expandDims(tr, 0));
    };
    const qT = lift(q);
    const kT = lift(k);
    const vT = lift(v);
    // cu_seqlens split: one sdpa per temporal segment (single segment for
    // images), outputs concatenated in order — the reference's exact walk.
    let attnP: MlxArray;
    if (segLen === n) {
      attnP = ops.sdpa(qT, kT, vT, scale, "", null);
    } else {
      const outs: MlxArray[] = [];
      for (let s = 0; s < n; s += segLen) {
        const qs = qT.slice([0, 0, s, 0], [1, HEADS, s + segLen, PAD_DIM]);
        const ks = kT.slice([0, 0, s, 0], [1, HEADS, s + segLen, PAD_DIM]);
        const vsS = vT.slice([0, 0, s, 0], [1, HEADS, s + segLen, PAD_DIM]);
        outs.push(ops.sdpa(qs, ks, vsS, scale, "", null));
        qs.dispose(); ks.dispose(); vsS.dispose();
      }
      attnP = ops.concatAxis(outs, 2);
      for (const o of outs) o.dispose();
    }
    qT.dispose(); kT.dispose(); vT.dispose();
    const attn = disposing(
      attnP, attnP.slice([0, 0, 0, 0], [1, HEADS, n, HEAD_DIM]),
    );
    const attnT = disposing(attn, ops.transposeAxes(attn, [0, 2, 1, 3]));
    const merged = disposing(attnT, ops.reshape(attnT, [n, HIDDEN]));
    const proj = disposing(merged, this.#linear(merged, blk.projW, blk.projB));
    h = disposing(h, disposing(proj, ops.add(h, proj)));
    const mn = ops.layerNorm(h, blk.norm2W, blk.norm2B, 1e-6);
    const f1 = disposing(mn, this.#linear(mn, blk.fc1W, blk.fc1B));
    const act = disposing(f1, ops.geluApprox(f1)); // gelu_pytorch_tanh
    const f2 = disposing(act, this.#linear(act, blk.fc2W, blk.fc2B));
    return disposing(h, disposing(f2, ops.add(h, f2)));
  }

  /** nn.Linear on bf16 — mx.addmm(bias, x, W^T), the reference's exact bias
   *  path (a separate matmul+add rounds differently and seeded the ±1-ulp
   *  block divergence found in the stage bisect). */
  #linear(x: MlxArray, w: MlxArray, b: MlxArray): MlxArray {
    const wT = ops.transposeAxes(w, [1, 0]);
    const y = ops.addmm(b, x, wT);
    wT.dispose();
    return y;
  }

  /** Bilinearly interpolated learned pos embeds, in merge-block-major row
   *  order — port of fast_pos_embed_interpolate + the merge permutation. */
  #interpolatedPosEmbeds(gridH: number, gridW: number): MlxArray {
    const n = gridH * gridW;
    const idx = [new Int32Array(n), new Int32Array(n), new Int32Array(n), new Int32Array(n)];
    const wts = [new Float32Array(n), new Float32Array(n), new Float32Array(n), new Float32Array(n)];
    const lin = (count: number): Float32Array => {
      // mx.linspace(0, POS_GRID-1, count) in f32.
      const outArr = new Float32Array(count);
      if (count === 1) { outArr[0] = 0; return outArr; }
      const step = Math.fround((POS_GRID - 1) / (count - 1));
      for (let i = 0; i < count; i++) outArr[i] = Math.fround(i * step);
      return outArr;
    };
    const hIdx = lin(gridH);
    const wIdx = lin(gridW);
    for (let h = 0; h < gridH; h++) {
      const hf = Math.trunc(hIdx[h]!);
      const hc = Math.min(hf + 1, POS_GRID - 1);
      const dh = Math.fround(hIdx[h]! - hf);
      for (let x = 0; x < gridW; x++) {
        const wf = Math.trunc(wIdx[x]!);
        const wc = Math.min(wf + 1, POS_GRID - 1);
        const dw = Math.fround(wIdx[x]! - wf);
        const i = h * gridW + x;
        idx[0]![i] = hf * POS_GRID + wf;
        idx[1]![i] = hf * POS_GRID + wc;
        idx[2]![i] = hc * POS_GRID + wf;
        idx[3]![i] = hc * POS_GRID + wc;
        wts[0]![i] = Math.fround((1 - dh) * (1 - dw));
        wts[1]![i] = Math.fround((1 - dh) * dw);
        wts[2]![i] = Math.fround(dh * (1 - dw));
        wts[3]![i] = Math.fround(dh * dw);
      }
    }
    // pos_embeds[k] = pos_embed[idx_k] * w_k (bf16, like the reference's
    // weight tensor cast); summed pairwise in reference order.
    let acc: MlxArray | null = null;
    for (let k = 0; k < 4; k++) {
      const ids = MlxArray.fromInt32(idx[k]!, [n]);
      const rows = ops.takeAxis(this.#posEmbed, ids, 0); // [n, 1152] bf16
      ids.dispose();
      const wf = MlxArray.fromFloat32(wts[k]!, [n, 1]);
      const wb = disposing(wf, wf.astype(Dtype.bfloat16));
      const term = ops.mul(rows, wb);
      rows.dispose();
      wb.dispose();
      acc = acc ? disposing(acc, disposing(term, ops.add(acc, term))) : term;
    }
    // Merge-block-major permutation (rows currently h-major patch order).
    const ms = QWEN3VL_MERGE_SIZE;
    const permIdx = new Int32Array(n);
    let r = 0;
    for (let h1 = 0; h1 < gridH / ms; h1++)
      for (let w1 = 0; w1 < gridW / ms; w1++)
        for (let mh = 0; mh < ms; mh++)
          for (let mw = 0; mw < ms; mw++)
            permIdx[r++] = (h1 * ms + mh) * gridW + (w1 * ms + mw);
    const pIds = MlxArray.fromInt32(permIdx, [n]);
    const out = ops.takeAxis(acc!, pIds, 0);
    pIds.dispose();
    acc!.dispose();
    return out;
  }

  /** 2D rotary cos/sin [n, HEAD_DIM] f32 in merge-block-major order —
   *  port of rot_pos_emb + apply_rotary_pos_emb_vision's tile(·,2). */
  #ropeCosSin(gridH: number, gridW: number): [MlxArray, MlxArray] {
    const n = gridH * gridW;
    const half = ROT_DIM / 2; // 18 inv freqs
    // inv_freq on-device, the reference's exact graph — Metal powf is not
    // correctly rounded, so a JS Math.pow emulation differs by 1 ulp on some
    // entries (seen as 2.4e-7 in the freq gate before this).
    const invFreq = (() => {
      const ar = ops.arange(0, ROT_DIM, 2, Dtype.float32);
      const ex = disposing(ar, ops.mulScalar(ar, 1 / ROT_DIM));
      const theta = MlxArray.fromFloat32(Float32Array.from([ROPE_THETA]), [1]);
      const p = ops.pow(theta, ex);
      theta.dispose();
      ex.dispose();
      const one = MlxArray.fromFloat32(Float32Array.from([1]), [1]);
      const inv = disposing(p, ops.div(one, p));
      one.dispose();
      const v = inv.toFloat32();
      inv.dispose();
      return v;
    })();
    const ms = QWEN3VL_MERGE_SIZE;
    const freqs = new Float32Array(n * ROT_DIM);
    let r = 0;
    for (let h1 = 0; h1 < gridH / ms; h1++) {
      for (let w1 = 0; w1 < gridW / ms; w1++) {
        for (let mh = 0; mh < ms; mh++) {
          for (let mw = 0; mw < ms; mw++) {
            const hPos = h1 * ms + mh;
            const wPos = w1 * ms + mw;
            const base = r * ROT_DIM;
            for (let i = 0; i < half; i++) {
              freqs[base + i] = Math.fround(hPos * invFreq[i]!);
              freqs[base + half + i] = Math.fround(wPos * invFreq[i]!);
            }
            r++;
          }
        }
      }
    }
    const f = MlxArray.fromFloat32(freqs, [n, ROT_DIM]);
    const cosH = ops.cos(f);
    const sinH = ops.sin(f);
    f.dispose();
    // tile(·, (1, 2)) over the last dim → [n, HEAD_DIM].
    const cos = disposing(cosH, ops.concatAxis([cosH, cosH], -1));
    const sin = disposing(sinH, ops.concatAxis([sinH, sinH], -1));
    return [cos, sin];
  }

  /** (t·cos) + (rotate_half(t)·sin), f32 math, cast back to bf16. */
  #applyRope(x: MlxArray, cos: MlxArray, sin: MlxArray): MlxArray {
    // x [n, HEADS, HEAD_DIM]; cos/sin [n, 1, HEAD_DIM] broadcast over heads.
    const half = HEAD_DIM / 2;
    const n = x.shape[0]!;
    const x1 = x.slice([0, 0, 0], [n, HEADS, half]);
    const x2 = x.slice([0, 0, half], [n, HEADS, HEAD_DIM]);
    const negX2 = ops.mulScalar(x2, -1);
    x2.dispose();
    const rot = disposing(negX2, ops.concatAxis([negX2, x1], -1));
    x1.dispose();
    const a = ops.mul(x, cos);
    const b = disposing(rot, ops.mul(rot, sin));
    const sum = ops.add(a, b);
    a.dispose();
    b.dispose();
    return disposing(sum, sum.astype(Dtype.bfloat16));
  }

  /** Stage-instrumented encode for parity bisection (tests/debug): returns
   *  named f32 copies of each pipeline stage alongside the final output. */
  encodeStages(pp: Qwen3VLPreprocessed): Map<string, Float32Array> {
    const stages = new Map<string, Float32Array>();
    const out = this.encode(pp, (name, arr) => {
      const f = arr.astype(Dtype.float32);
      stages.set(name, f.toFloat32());
      f.dispose();
    });
    const f = out.astype(Dtype.float32);
    stages.set("merged", f.toFloat32());
    f.dispose();
    out.dispose();
    return stages;
  }

  /** Parity-bisect helper: run ONLY the block chain (+ optional merger) on a
   *  caller-provided hidden grid — used to separate patch-embed seed ulp
   *  from block-math divergence in the stage gates. */
  debugRunBlocks(
    hF32: Float32Array, gridH: number, gridW: number, throughMerger = false,
  ): Float32Array {
    const n = gridH * gridW;
    const hf = MlxArray.fromFloat32(hF32, [n, HIDDEN]);
    let h = disposing(hf, hf.astype(Dtype.bfloat16));
    const [cosF, sinF] = this.#ropeCosSin(gridH, gridW);
    const cos = disposing(cosF, ops.expandDims(cosF, 1));
    const sin = disposing(sinF, ops.expandDims(sinF, 1));
    const scale = Math.pow(HEAD_DIM, -0.5);
    for (const blk of this.#blocks) h = this.#block(h, blk, cos, sin, scale, n);
    cos.dispose();
    sin.dispose();
    if (throughMerger) {
      const mnorm = disposing(h, ops.layerNorm(h, this.#mergerNormW, this.#mergerNormB, 1e-6));
      const grouped = disposing(mnorm, ops.reshape(mnorm, [n / 4, HIDDEN * 4]));
      const f1 = disposing(grouped, this.#linear(grouped, this.#mergerFc1W, this.#mergerFc1B));
      const act = disposing(f1, ops.geluPrecise(f1));
      h = disposing(act, this.#linear(act, this.#mergerFc2W, this.#mergerFc2B));
    }
    const f = disposing(h, h.astype(Dtype.float32));
    const out = f.toFloat32();
    f.dispose();
    return out;
  }

  /** Encode one preprocessed image → [imageTokens, 5120] bf16. */
  encode(
    pp: Qwen3VLPreprocessed,
    tap?: (name: string, arr: MlxArray) => void,
  ): MlxArray {
    const [gridT, gridH, gridW] = pp.gridThw;
    const n = pp.rows;
    const pvF = MlxArray.fromFloat32(pp.pixelValues, [n, pp.cols]);
    const pv = disposing(pvF, pvF.astype(Dtype.bfloat16));
    // PatchEmbed: rows (c,t,py,px) → [N, tps, ps, ps, C] NDHWC → Conv3d with
    // kernel == stride — the reference's exact reshape/moveaxis/conv graph.
    const tps = QWEN3VL_TEMPORAL_PATCH_SIZE;
    const ps = QWEN3VL_PATCH_SIZE;
    const r5 = disposing(pv, ops.reshape(pv, [n, 3, tps, ps, ps]));
    const tr = disposing(r5, ops.transposeAxes(r5, [0, 2, 3, 4, 1]));
    const ndhwc = disposing(tr, ops.contiguous(tr));
    const convOut = disposing(
      ndhwc, ops.conv3d(ndhwc, this.#patchW, [tps, ps, ps]),
    );
    let h = disposing(convOut, ops.reshape(convOut, [n, HIDDEN]));
    h = disposing(h, ops.add(h, this.#patchB));
    tap?.("patch", h);
    // Per-temporal-group pos/rope embeds are identical — tile the (h,w)
    // block gridT times (the reference tiles coords/pos_embed per frame).
    const tile = (a: MlxArray): MlxArray => {
      if (gridT === 1) return a;
      const parts = new Array(gridT).fill(a);
      return disposing(a, ops.concatAxis(parts, 0));
    };
    const pos = tile(this.#interpolatedPosEmbeds(gridH, gridW));
    tap?.("pos", pos);
    h = disposing(h, disposing(pos, ops.add(h, pos)));

    const [cosF0, sinF0] = this.#ropeCosSin(gridH, gridW);
    const cosF = tile(cosF0);
    const sinF = tile(sinF0);
    const cos = disposing(cosF, ops.expandDims(cosF, 1)); // [n,1,72]
    const sin = disposing(sinF, ops.expandDims(sinF, 1));

    const scale = Math.pow(HEAD_DIM, -0.5);
    // Attention never crosses temporal groups (cu_seqlens = h·w per frame
    // pair): images run one segment, videos gridT segments.
    const segLen = gridH * gridW;
    let blkIdx = 0;
    for (const blk of this.#blocks) {
      h = this.#block(h, blk, cos, sin, scale, n, segLen);
      tap?.(`blk${blkIdx}`, h);
      blkIdx++;
    }
    tap?.("blocks", h);
    cos.dispose();
    sin.dispose();

    // Merger: LayerNorm(1152) → reshape 4× → fc1 → GELU(erf) → fc2.
    const mnorm = disposing(h, ops.layerNorm(h, this.#mergerNormW, this.#mergerNormB, 1e-6));
    const grouped = disposing(mnorm, ops.reshape(mnorm, [n / 4, HIDDEN * 4]));
    const f1 = disposing(grouped, this.#linear(grouped, this.#mergerFc1W, this.#mergerFc1B));
    const act = disposing(f1, ops.geluPrecise(f1)); // reference nn.GELU()
    return disposing(act, this.#linear(act, this.#mergerFc2W, this.#mergerFc2B));
  }

  dispose(): void {
    // Sidecar arrays are process-pinned (house rule: mmap-backed weights are
    // never handed a JS dtor); nothing to free eagerly.
  }
}
