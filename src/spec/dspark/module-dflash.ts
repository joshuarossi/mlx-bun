// Faithful DFlash drafter (DSpark paper §3.1, Eq 2–3) — the REAL KV-injection
// architecture, in a parallel file so the v1 single-vector module stays intact
// as the baseline. Selected by variant="dflash" in the checkpoint metadata.
//
// vs v1 (module.ts): v1 collapsed the target context to ONE vector fused as a
// sequence token before layer 0. This builds the paper's mechanism:
//   Eq 2:  H_ctx = RMSNorm(W_c · [H^{l1};…;H^{lm}])   — m tapped target layers,
//          over the FULL context, projected into the draft width.
//   Eq 3:  every draft layer i forms K_i=[W_i^K H_ctx; W_i^K H_d],
//          V_i=[W_i^V H_ctx; W_i^V H_d], Q_i=W_i^Q H_d — the block attends
//          bidirectionally over [context ++ block]; context is read-only memory
//          re-projected fresh at every layer, never a token that gets rewritten.
// The draft projects the target's HIDDEN STATES with its OWN Wk/Wv (not the
// target's K/V — that's the separate GemmaAssistantDrafter baseline).

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import type { Gemma4Model } from "../../model/gemma4";
import { loadAdapterTensors } from "../../lora";
import { writeShardedSafetensors, type NamedTensor } from "../../quantize/safetensors-writer";
import { processLogits, sampleToken, KeyStream, type DSparkSampleConfig } from "./sample";
import { mkdirSync, writeFileSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

/** STS calibration (§3.2.1) — per-position confidence thresholds fit on real
 *  (confidence, accepted) verify outcomes (src/spec/dspark/calibration.ts,
 *  scripts/dspark-calibrate.ts). Consumed by the confidence-scheduled
 *  draft-length pruning (Alg 1, single-user form) in forwardInfer. Stored
 *  inside DflashConfig so it round-trips through dspark.json for free.
 *  ABSENT ⟹ no pruning — an uncalibrated checkpoint drafts exactly as before. */
export interface StsCalibration {
  /** thresholds[k] = min confidence to KEEP draft position k. length γ. */
  thresholds: number[];
  /** Target acceptance precision the thresholds were fit for (e.g. 0.5). */
  target: number;
  /** Verify outcomes the fit saw (provenance). */
  samples?: number;
}

export interface DflashConfig {
  gamma: number;
  dDraft: number;
  /** Backbone depth (paper default 5). */
  nLayers: number;
  nHeads: number;
  markovRank: number;
  ffMult: number;
  /** Target layer indices tapped for H_ctx (Eq 2). nLayers-of-target..sentinel.
   *  For e4b (42 layers): index 0..41 = post-layer residual, 42 = post-finalNorm. */
  tapLayers: number[];
  /** Sequential head: "markov" (Eq 5, default) or "rnn" (Eq 6). */
  seqHead?: "markov" | "rnn";
  /** STS calibration (§3.2.1); absent = no confidence pruning. */
  sts?: StsCalibration;
}

export const DEFAULT_DFLASH_CONFIG: DflashConfig = {
  gamma: 5,
  dDraft: 1024,
  nLayers: 5,
  nHeads: 8,
  markovRank: 256,
  ffMult: 2,
  tapLayers: [20, 31, 41, 42],
};

export interface TargetDims { hiddenSize: number; vocabSize: number; eps: number }

export interface DflashTrainOut { draftLogits: MlxArray; conf: MlxArray }
/** tokens/conf may be SHORTER than the requested γ when confidence pruning
 *  fires (Alg 1); always ≥1. draftLogits covers exactly tokens.length
 *  positions — ABSENT when the caller passed collectLogits:false (the loop
 *  never materialized/concatenated the per-position logits). */
export interface DflashDraftBlock { tokens: number[]; conf: number[]; draftLogits?: MlxArray }
export interface DflashDraftOpts {
  sample?: DSparkSampleConfig;
  keys?: KeyStream;
  /** Confidence-scheduled draft-length pruning (Alg 1, single-user form):
   *  position k is DROPPED (and the block truncated there) when its predicted
   *  acceptance c_k < thresholds[k] (per-position, STS-calibrated) or < minConf
   *  (uniform manual override). Position 0 is always kept (a source must
   *  return ≥1 token). Both absent ⟹ fixed-γ drafting (pre-scheduler
   *  behavior). Losslessness is invariant — pruning only changes how many
   *  positions the target VERIFIES, never what is emitted. */
  thresholds?: number[];
  minConf?: number;
  /** Materialize+concat the per-position draft logits into the returned
   *  DflashDraftBlock.draftLogits. Default true (the standalone
   *  dflashGenerate sampling-verify path reads it). The serve-loop draft()
   *  path runs its own verify lm-head and never reads it — pass false there
   *  to skip the dead concat + a host-unrelated GPU alloc every round. */
  collectLogits?: boolean;
}

const CDT = Dtype.float32;
const NEG = -1e9;

function disposing(old: MlxArray, next: MlxArray): MlxArray { old.dispose(); return next; }

function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 0x9e3779b9;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}
function normalArray(rng: () => number, shape: number[], std: number): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i += 2) {
    const u1 = Math.max(rng(), 1e-12), u2 = rng();
    const r = Math.sqrt(-2 * Math.log(u1));
    out[i] = r * Math.cos(2 * Math.PI * u2) * std;
    if (i + 1 < n) out[i + 1] = r * Math.sin(2 * Math.PI * u2) * std;
  }
  return MlxArray.fromFloat32(out, shape);
}
const zerosArray = (shape: number[]) => MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)), shape);
const constArray = (shape: number[], v: number) => MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)).fill(v), shape);

export class DflashDrafter {
  readonly cfg: DflashConfig;
  readonly dims: TargetDims;
  readonly targetId: string;
  readonly m: number; // number of tapped layers
  #p = new Map<string, MlxArray>();
  readonly names: string[];

  private constructor(cfg: DflashConfig, dims: TargetDims, targetId: string) {
    this.cfg = cfg;
    this.dims = dims;
    this.targetId = targetId;
    this.m = cfg.tapLayers.length;
    if (cfg.dDraft % cfg.nHeads !== 0) throw new Error(`dDraft ${cfg.dDraft} not divisible by nHeads ${cfg.nHeads}`);
    this.names = buildNames(cfg);
  }

  static dimsOf(model: Gemma4Model): TargetDims {
    const t = model.config.text;
    return { hiddenSize: t.hiddenSize, vocabSize: t.vocabSize, eps: t.rmsNormEps };
  }
  static init(model: Gemma4Model, cfg: DflashConfig, targetId: string, seed = 0): DflashDrafter {
    return DflashDrafter.initFromDims(DflashDrafter.dimsOf(model), cfg, targetId, seed);
  }
  static initFromDims(dims: TargetDims, cfg: DflashConfig, targetId: string, seed = 0): DflashDrafter {
    const d = new DflashDrafter(cfg, dims, targetId);
    const rng = makeRng(seed);
    const { dDraft, nLayers, markovRank: r, ffMult } = cfg;
    const dInter = ffMult * dDraft;
    const { hiddenSize: H, vocabSize: V } = dims;
    const mH = d.m * H;
    const set = (n: string, a: MlxArray) => d.#p.set(n, a.eval());
    for (let i = 0; i < nLayers; i++) {
      set(`bb.${i}.attn_norm`, constArray([dDraft], 1.0));
      for (const w of ["q", "k", "v", "o"]) set(`bb.${i}.${w}`, normalArray(rng, [dDraft, dDraft], 0.02));
      set(`bb.${i}.ff_norm`, constArray([dDraft], 1.0));
      set(`bb.${i}.gate`, normalArray(rng, [dDraft, dInter], 0.02));
      set(`bb.${i}.up`, normalArray(rng, [dDraft, dInter], 0.02));
      set(`bb.${i}.down`, normalArray(rng, [dInter, dDraft], 0.02));
    }
    set("W_c", normalArray(rng, [mH, dDraft], 0.02));   // Eq 2 projection
    set("ctx_norm", constArray([dDraft], 1.0));
    set("tok_proj", normalArray(rng, [H, dDraft], 0.02));
    set("mask_emb", normalArray(rng, [cfg.gamma - 1, dDraft], 0.02));
    set("block_pos", normalArray(rng, [cfg.gamma, dDraft], 0.02));
    set("out_norm", constArray([dDraft], 1.0));
    set("out_proj", normalArray(rng, [dDraft, H], 0.02));
    set("markov.w1", normalArray(rng, [V, r], 0.02));
    set("markov.w2", zerosArray([r, V]));   // W2=0 → starts as pure parallel DFlash
    set("conf.w", zerosArray([dDraft + r, 1]));
    set("conf.b", zerosArray([1]));
    // rnn.* MUST be initialized last (after every markov/shared param) so the
    // seeded rng stream hands out IDENTICAL draws to a markov-only init up to
    // this point — this is what makes the init-equivalence gate hold (an rnn
    // drafter and a markov drafter, same seed, are bit-identical at t=0).
    if (cfg.seqHead === "rnn") {
      set("rnn.wH", normalArray(rng, [r, r], 0.02));
      set("rnn.bH", zerosArray([r]));
      set("rnn.wO", zerosArray([r, V])); // zero-init → starts as pure DFlash, mirrors markov.w2
    }
    return d;
  }

  get(name: string): MlxArray { const a = this.#p.get(name); if (!a) throw new Error(`param ${name}`); return a; }
  flatParams(): MlxArray[] { return this.names.map((n) => this.get(n)); }
  useParams<T>(primals: MlxArray[], fn: () => T): T {
    const saved = this.names.map((n) => this.get(n));
    this.names.forEach((n, i) => this.#p.set(n, primals[i]!));
    try { return fn(); } finally { this.names.forEach((n, i) => this.#p.set(n, saved[i]!)); }
  }
  installParam(i: number, p: MlxArray): void { this.#p.set(this.names[i]!, p); }

  // --- Eq 2: context construction ---
  /** hCtx [A, Lctx, m*H] (m tapped layers concatenated on the feature axis) →
   *  H_ctx [A, Lctx, d]. */
  #buildContext(hCtx: MlxArray): MlxArray {
    const f = hCtx.dtype === CDT ? hCtx : hCtx.astype(CDT);
    const proj = ops.matmul(f, this.get("W_c")); // [A,Lctx,d]
    if (f !== hCtx) f.dispose();
    const out = ops.rmsNorm(proj, this.get("ctx_norm"), this.dims.eps);
    proj.dispose();
    return out;
  }

  /** Block hidden H_d [A, γ, d]: anchor at pos 0, mask tokens after. */
  #buildBlock(anchorEmb: MlxArray, A: number): MlxArray {
    const { gamma, dDraft } = this.cfg;
    const bp = this.get("block_pos"); // [γ,d]
    const af = anchorEmb.dtype === CDT ? anchorEmb : anchorEmb.astype(CDT);
    let anchor = ops.matmul(af, this.get("tok_proj")); // [A,d]
    if (af !== anchorEmb) af.dispose();
    const p0 = bp.slice([0, 0], [1, dDraft]);
    anchor = disposing(anchor, ops.add(anchor, p0)); p0.dispose();
    anchor = disposing(anchor, ops.reshape(anchor, [A, 1, dDraft]));
    const parts = [anchor];
    if (gamma > 1) {
      const me = this.get("mask_emb"); // [γ-1,d]
      const pm = bp.slice([1, 0], [gamma, dDraft]); // [γ-1,d]
      let masks = ops.add(me, pm); pm.dispose(); // [γ-1,d]
      masks = disposing(masks, ops.reshape(masks, [1, gamma - 1, dDraft]));
      const zerosA = MlxArray.fromFloat32(new Float32Array(A * dDraft), [A, 1, dDraft]);
      const masksA = ops.add(masks, zerosA); // broadcast → [A,γ-1,d]
      masks.dispose(); zerosA.dispose();
      parts.push(masksA);
    }
    const H_d = ops.concatAxis(parts, 1); // [A,γ,d]
    for (const p of parts) p.dispose();
    return H_d;
  }

  /** Additive attention bias [A,1,1,Lctx+γ] from a context key-padding mask
   *  ([A,Lctx], 1=real/0=pad). Context pad cols → -1e9; real ctx + all block
   *  cols → 0. null when no padding (inference, batch 1). */
  #maskBias(ctxMask: MlxArray | null, A: number, Lctx: number): MlxArray | null {
    if (!ctxMask) return null;
    const mf = ctxMask.dtype === CDT ? ctxMask : ctxMask.astype(CDT);
    const one = MlxArray.fromFloat32(new Float32Array([1]), [1]);
    const sub = ops.sub(mf, one); one.dispose(); // real→0, pad→-1
    if (mf !== ctxMask) mf.dispose();
    const bias = ops.mulScalar(sub, -NEG); sub.dispose(); // real→0, pad→-1e9  (-NEG = 1e9; (-1)*1e9=-1e9)
    let ctxBias = ops.reshape(bias, [A, 1, 1, Lctx]); bias.dispose();
    const blockZeros = MlxArray.fromFloat32(new Float32Array(A * this.cfg.gamma), [A, 1, 1, this.cfg.gamma]);
    const full = ops.concatAxis([ctxBias, blockZeros], 3); // [A,1,1,Lctx+γ]
    ctxBias.dispose(); blockZeros.dispose();
    return full;
  }

  // --- Eq 3: one KV-injection layer. H_ctx read-only; H_d is queries+updated ---
  #layer(i: number, H_d: MlxArray, H_ctx: MlxArray, maskBias: MlxArray | null, A: number, Lctx: number): MlxArray {
    const { dDraft, nHeads, gamma } = this.cfg;
    const hd = dDraft / nHeads;
    const eps = this.dims.eps;
    const wk = this.get(`bb.${i}.k`), wv = this.get(`bb.${i}.v`);

    const residual = H_d;
    const nd = ops.rmsNorm(H_d, this.get(`bb.${i}.attn_norm`), eps);
    const nc = ops.rmsNorm(H_ctx, this.get(`bb.${i}.attn_norm`), eps); // SAME norm as block

    // Q from block only
    let q = ops.matmul(nd, this.get(`bb.${i}.q`)); // [A,γ,d]
    q = disposing(q, ops.reshape(q, [A, gamma, nHeads, hd]));
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3])); // [A,nHeads,γ,hd]

    // K/V = [Wk·H_ctx ; Wk·H_d]  (context first, then block)
    const kc = ops.matmul(nc, wk), kd = ops.matmul(nd, wk);
    const vc = ops.matmul(nc, wv), vd = ops.matmul(nd, wv);
    nd.dispose(); nc.dispose();
    const shape4 = (x: MlxArray) => { const r = ops.reshape(x, [A, Lctx + gamma, nHeads, hd]); x.dispose(); const t = ops.transposeAxes(r, [0, 2, 1, 3]); r.dispose(); return t; };
    let K = ops.concatAxis([kc, kd], 1); kc.dispose(); kd.dispose(); // [A,Lctx+γ,d]
    let V = ops.concatAxis([vc, vd], 1); vc.dispose(); vd.dispose();
    K = shape4(K); V = shape4(V); // [A,nHeads,Lctx+γ,hd]

    let attn = ops.sdpa(q, K, V, Math.pow(hd, -0.5), maskBias ? "array" : "", maskBias);
    q.dispose(); K.dispose(); V.dispose();
    attn = disposing(attn, ops.transposeAxes(attn, [0, 2, 1, 3])); // [A,γ,nHeads,hd]
    attn = disposing(attn, ops.reshape(attn, [A, gamma, dDraft]));
    attn = disposing(attn, ops.matmul(attn, this.get(`bb.${i}.o`)));
    let H = ops.add(residual, attn); residual.dispose(); attn.dispose();

    // gated-GELU FFN on the block only
    const res2 = H;
    const n2 = ops.rmsNorm(H, this.get(`bb.${i}.ff_norm`), eps);
    const g = ops.matmul(n2, this.get(`bb.${i}.gate`));
    const u = ops.matmul(n2, this.get(`bb.${i}.up`));
    n2.dispose();
    const act = ops.geluApprox(g); g.dispose();
    let mlp = ops.mul(act, u); act.dispose(); u.dispose();
    mlp = disposing(mlp, ops.matmul(mlp, this.get(`bb.${i}.down`)));
    const out = ops.add(res2, mlp); res2.dispose(); mlp.dispose();
    return out;
  }

  /** hCtx [A,Lctx,m*H], anchorEmb [A,H], ctxMask [A,Lctx]|null → block [A,γ,d]. */
  #backbone(hCtx: MlxArray, anchorEmb: MlxArray, ctxMask: MlxArray | null, A: number): MlxArray {
    const Lctx = hCtx.shape[1]!;
    const H_ctx = this.#buildContext(hCtx);
    let H_d = this.#buildBlock(anchorEmb, A);
    const maskBias = this.#maskBias(ctxMask, A, Lctx);
    for (let i = 0; i < this.cfg.nLayers; i++) H_d = disposing(H_d, this.#layer(i, H_d, H_ctx, maskBias, A, Lctx));
    H_ctx.dispose(); maskBias?.dispose();
    H_d = disposing(H_d, ops.rmsNorm(H_d, this.get("out_norm"), this.dims.eps));
    return H_d;
  }

  #baseLogits(model: Gemma4Model, block: MlxArray): MlxArray {
    const hOut = ops.matmul(block, this.get("out_proj")); // [A,γ,H]
    const hBf = hOut.astype(model.embed.scales.dtype); hOut.dispose();
    const logits = model.logitsFromHidden(hBf); hBf.dispose();
    return logits;
  }
  #markov(prevToks: MlxArray): { B: MlxArray; emb1: MlxArray } {
    const emb1 = ops.takeAxis(this.get("markov.w1"), prevToks, 0); // [A,γ,r]
    const B = ops.matmul(emb1, this.get("markov.w2")); // [A,γ,V]
    return { B, emb1 };
  }

  /** RNN sequential head (design-doc Eq 6 shape — the DSpark paper PDF is not
   *  in this repo; §"RNN sequential head" of docs/design/dspark-speculative-
   *  decoding.md only names it as a Markov-head alternative with no formula,
   *  so this is the natural GRU/Elman-style faithful reading: a scalar-gain
   *  tanh recurrence over the SAME token embedding (markov.w1, weight-shared)
   *  the Markov head uses, producing a per-position bias B_k exactly like Eq 5
   *  so the rest of the module (base logits add, confidence input) is
   *  untouched. FLAG: unverified against the actual paper equation. */
  #rnn(prevToks: MlxArray): { B: MlxArray; emb1: MlxArray } {
    const { gamma: G, markovRank: r } = this.cfg;
    const A = prevToks.shape[0]!;
    const emb1 = ops.takeAxis(this.get("markov.w1"), prevToks, 0); // [A,γ,r] (shared embedding, no 2nd table)
    const wH = this.get("rnn.wH"), bH = this.get("rnn.bH"), wO = this.get("rnn.wO");
    let s: MlxArray | null = zerosArray([A, r]); // s_{-1} = 0
    const bSlices: MlxArray[] = [];
    const pending: MlxArray[] = []; // iteration temps, for the catch (forwardInfer pattern)
    try {
      for (let k = 0; k < G; k++) {
        const e1S = emb1.slice([0, k, 0], [A, k + 1, r]); pending.push(e1S);
        const e1k = ops.reshape(e1S, [A, r]); pending.push(e1k);
        e1S.dispose();
        const sh = ops.matmul(s!, wH); pending.push(sh);
        s!.dispose(); s = null;
        let sNext = ops.add(sh, e1k); pending.push(sNext);
        sh.dispose(); e1k.dispose();
        sNext = disposing(sNext, ops.add(sNext, bH)); pending.push(sNext);
        sNext = disposing(sNext, ops.tanh(sNext)); pending.push(sNext);
        s = sNext; // s_k
        const bk = ops.matmul(s, wO); pending.push(bk); // [A,V]
        bSlices.push(ops.reshape(bk, [A, 1, this.dims.vocabSize])); bk.dispose();
        pending.length = 0;
      }
      s!.dispose(); s = null;
      const B = ops.concatAxis(bSlices, 1); // [A,γ,V]
      for (const b of bSlices) b.dispose();
      return { B, emb1 };
    } catch (err) {
      // Mid-recurrence throw: free the carried state, the collected slices,
      // the current iteration's temps, and the emb1 the caller never received
      // (dispose() idempotence makes over-disposal inert).
      for (const a of pending) a.dispose();
      for (const b of bSlices) b.dispose();
      s?.dispose();
      emb1.dispose();
      throw err;
    }
  }

  #seqHead(prevToks: MlxArray): { B: MlxArray; emb1: MlxArray } {
    return this.cfg.seqHead === "rnn" ? this.#rnn(prevToks) : this.#markov(prevToks);
  }
  #confidence(block: MlxArray, emb1: MlxArray): MlxArray {
    const inp = ops.concatAxis([block, emb1], 2);
    let z = ops.matmul(inp, this.get("conf.w")); inp.dispose();
    z = disposing(z, ops.add(z, this.get("conf.b")));
    z = disposing(z, ops.sigmoid(z));
    const A = z.shape[0]!, G = z.shape[1]!;
    const c = ops.reshape(z, [A, G]); z.dispose();
    return c;
  }

  /** Parallel training forward (teacher-forced Markov).
   *  hCtx [A,Lctx,m*H], ctxMask [A,Lctx]|null, anchorEmb [A,H], prevToks [A,γ]. */
  forwardTrain(model: Gemma4Model, hCtx: MlxArray, ctxMask: MlxArray | null, anchorEmb: MlxArray, prevToks: MlxArray): DflashTrainOut {
    const A = hCtx.shape[0]!;
    let block: MlxArray | null = null, Uf: MlxArray | null = null;
    let B: MlxArray | null = null, emb1: MlxArray | null = null;
    try {
      block = this.#backbone(hCtx, anchorEmb, ctxMask, A);
      const U = this.#baseLogits(model, block);
      Uf = U.astype(CDT); U.dispose();
      ({ B, emb1 } = this.#seqHead(prevToks));
      const draftLogits = ops.add(Uf, B);
      Uf.dispose(); Uf = null; B.dispose(); B = null;
      const conf = this.#confidence(block, emb1);
      block.dispose(); block = null; emb1.dispose(); emb1 = null;
      return { draftLogits, conf };
    } catch (err) {
      // Free whatever a mid-forward throw left live (each slot is nulled the
      // moment its normal disposal ran — no double-free).
      block?.dispose(); Uf?.dispose(); B?.dispose(); emb1?.dispose();
      throw err;
    }
  }

  /** Inference: parallel backbone once, then sequential Markov sampling.
   *  hCtx [1,Lctx,m*H] (full current context), anchorTok the bonus token.
   *
   *  Host-sync discipline (docs/investigations/dspark-handoff.md item 3): the
   *  greedy path's token recurrence stays ON-DEVICE across positions — the
   *  argmax result [1] uint32 feeds directly into the next position's
   *  takeAxis, no itemUint32 in the loop. Per-position token arrays are
   *  collected and resolved to host numbers with exactly ONE concat +
   *  toIntTokens() after the loop. Confidence is the one read the pruning
   *  ALGORITHM inherently needs per position (Alg 1 must decide whether to
   *  stop NOW) — so it stays per-position whenever thresholds/minConf are
   *  actually active; when pruning is inactive there is no such need, so
   *  confidence is deferred the same way (collect [1] arrays, one concat +
   *  one toFloat32 after the loop). The sampling path already forces a host
   *  read every position (sampleToken draws from a device RNG key) — that
   *  path is unchanged. */
  forwardInfer(model: Gemma4Model, hCtx: MlxArray, anchorTok: number, gamma: number, opts: DflashDraftOpts = {}): DflashDraftBlock {
    const { dDraft, markovRank: r } = this.cfg;
    const V = this.dims.vocabSize;
    const sample = opts.sample && opts.sample.temperature > 0 ? opts.sample : null;
    const keys = opts.keys ?? new KeyStream(opts.sample?.seed ?? 0);
    const collectLogits = opts.collectLogits ?? true;
    const pruningActive = opts.thresholds !== undefined || opts.minConf !== undefined;

    const ids = ops.fromInt32([anchorTok], [1, 1]);
    const ae3 = model.embed.encode(ids); ids.dispose();
    const anchorEmb = ops.reshape(ae3, [1, this.dims.hiddenSize]); ae3.dispose();
    const block = this.#backbone(hCtx, anchorEmb, null, 1); // [1,γ,d]
    anchorEmb.dispose();
    const U = this.#baseLogits(model, block);
    const Uf = U.astype(CDT); U.dispose();

    const w1 = this.get("markov.w1"), w2 = this.get("markov.w2");
    const isRnn = this.cfg.seqHead === "rnn";
    const wH = isRnn ? this.get("rnn.wH") : null;
    const bH = isRnn ? this.get("rnn.bH") : null;
    const wO = isRnn ? this.get("rnn.wO") : null;
    let s: MlxArray | null = isRnn ? zerosArray([1, r]) : null; // s_{-1} = 0, carried across k
    const conf: number[] = [];
    const perPos: MlxArray[] = []; // per-position [1,1,V] draft logits (collectLogits only)
    const tokArrs: MlxArray[] = []; // per-position [1] device token ids, greedy path only
    const confArrs: MlxArray[] = []; // per-position [1] device confidences, deferred (no pruning) only
    let tokens: number[] = [];
    let prevIdx: MlxArray = ops.fromInt32([anchorTok], [1]); // device token id fed to takeAxis
    let ownPrevIdx = true; // false once prevIdx aliases a tokArrs/argmax entry we must not double-dispose
    // Iteration-local temps register here at creation so the catch can reach
    // them on a mid-flight throw; drained (length=0) at the bottom of each
    // iteration once everything in it was disposed on the normal path.
    // dispose() idempotence makes catch-side re-disposal of the already-freed
    // ones inert.
    const pending: MlxArray[] = [];
    try {
      for (let k = 0; k < gamma; k++) {
        const UkS = Uf.slice([0, k, 0], [1, k + 1, V]); pending.push(UkS);
        const Uk = ops.reshape(UkS, [1, V]); pending.push(Uk);
        UkS.dispose();
        const e1 = ops.takeAxis(w1, prevIdx, 0); pending.push(e1); // [1,r], shared embedding either way
        if (ownPrevIdx) { prevIdx.dispose(); ownPrevIdx = false; } // consumed; prevIdx reassigned below
        let Bk: MlxArray;
        if (isRnn) {
          const sh = ops.matmul(s!, wH!); pending.push(sh);
          s!.dispose(); s = null;
          let sNext = ops.add(sh, e1); pending.push(sNext);
          sh.dispose();
          sNext = disposing(sNext, ops.add(sNext, bH!)); pending.push(sNext);
          sNext = disposing(sNext, ops.tanh(sNext)); pending.push(sNext);
          s = sNext; // s_k, survives to the next iteration (covered by the s slot from here)
          Bk = ops.matmul(s, wO!); pending.push(Bk);
        } else {
          Bk = ops.matmul(e1, w2); pending.push(Bk);
        }
        const logitsK = ops.add(Uk, Bk); pending.push(logitsK);
        Uk.dispose(); Bk.dispose();
        // prevIdx becomes the SINGLE tracked owner of the next token id the
        // moment it exists — no separate local for the catch to miss.
        if (sample) {
          const sc = processLogits(logitsK, sample); pending.push(sc);
          const tok = sampleToken(sc, keys.next()); sc.dispose();
          tokens.push(tok);
          prevIdx = ops.fromInt32([tok], [1]); ownPrevIdx = true;
        } else {
          const am = ops.argmaxAxis(logitsK, -1); // [1] uint32, ON-DEVICE — no itemUint32 here
          tokArrs.push(am);
          prevIdx = am; ownPrevIdx = false; // aliases tokArrs[k] — that collection owns it
        }
        if (collectLogits) perPos.push(ops.reshape(logitsK, [1, 1, V]));
        logitsK.dispose();
        const hkS = block.slice([0, k, 0], [1, k + 1, dDraft]); pending.push(hkS);
        const hk = ops.reshape(hkS, [1, dDraft]); pending.push(hk);
        hkS.dispose();
        const ci = ops.concatAxis([hk, e1], 1); pending.push(ci);
        hk.dispose(); e1.dispose();
        let cz = ops.matmul(ci, this.get("conf.w")); pending.push(cz);
        ci.dispose();
        cz = disposing(cz, ops.add(cz, this.get("conf.b"))); pending.push(cz);
        cz = disposing(cz, ops.sigmoid(cz)); pending.push(cz);

        // Alg 1 (single-user): drop position k when its predicted acceptance
        // is below the calibrated/manual threshold — the target then
        // verifies a shorter window. Position 0 always survives (sources
        // return ≥1 token). Pruning inherently needs the confidence value
        // THIS position, on the host, to decide whether to stop — no way
        // around that read when active. When inactive, defer it (device
        // array, resolved once after the loop) since nothing this iteration
        // depends on its value.
        const thr = opts.thresholds?.[k] ?? opts.minConf;
        if (pruningActive) {
          const cVal = cz.toFloat32()[0]!; cz.dispose();
          if (thr !== undefined && k > 0 && cVal < thr) {
            // Drop position k SYMMETRICALLY on both paths so tokens/conf/
            // draftLogits stay aligned (the DflashDraftBlock contract —
            // verifySampling slices draftLogits per token). Greedy: pop the
            // device array (prevIdx aliases it — one dispose via the owning
            // collection). Sample: pop the host token + free the standalone
            // fromInt32.
            if (!sample) tokArrs.pop()!.dispose(); // also frees prevIdx (same array)
            else { prevIdx.dispose(); tokens.pop(); }
            ownPrevIdx = false; // dead either way — post-loop/catch must not re-dispose
            if (collectLogits) perPos.pop()!.dispose(); // logits row for the dropped position
            break;
          }
          conf.push(cVal);
        } else {
          confArrs.push(cz);
        }
        pending.length = 0; // everything above was disposed (or handed to a collection)
      }
      pending.length = 0; // early-break path: the broken iteration's temps are all freed too
      if (ownPrevIdx) prevIdx.dispose(); // last iteration's fresh sample-path array, unused past the loop
      s?.dispose(); // final on-device state (loop end or early break — both leave s live)
      Uf.dispose(); block.dispose();

      if (!sample) {
        const allToks = ops.concatAxis(tokArrs, 0); // [nKept] uint32, ONE host read below
        for (const a of tokArrs) a.dispose();
        tokens = allToks.toIntTokens(); allToks.dispose();
      }
      if (!pruningActive && confArrs.length) {
        const allConf = ops.concatAxis(confArrs, 0); // [nKept,1]
        for (const a of confArrs) a.dispose();
        const flat = allConf.toFloat32(); allConf.dispose();
        for (const v of flat) conf.push(v);
      }
      const draftLogits = collectLogits ? ops.concatAxis(perPos, 1) : undefined;
      if (collectLogits) for (const a of perPos) a.dispose();
      return { tokens, conf, draftLogits };
    } catch (err) {
      // Cleanup on a mid-flight throw — the collections, the carried state,
      // AND the current iteration's registered temps (`pending`). dispose()
      // is idempotent (array.ts #disposed guard) so re-disposing an array the
      // try block already freed (or that aliases one of these collections,
      // e.g. prevIdx === tokArrs[k]) is inert, never a double-free bug.
      for (const a of pending) a.dispose();
      if (ownPrevIdx) prevIdx.dispose();
      for (const a of tokArrs) a.dispose();
      for (const a of confArrs) a.dispose();
      for (const a of perPos) a.dispose();
      s?.dispose();
      Uf.dispose(); block.dispose();
      throw err;
    }
  }

  save(dir: string): void {
    mkdirSync(dir, { recursive: true });
    const tensors: NamedTensor[] = this.names.map((name) => ({ name, array: this.get(name) }));
    writeShardedSafetensors(dir, tensors);
    writeFileSync(join(dir, "dspark.json"), JSON.stringify({
      // "dspark" is the canonical variant (this faithful module IS DSpark);
      // load() accepts the legacy "dflash" stamp from older checkpoints.
      kind: "dspark-drafter", variant: "dspark", version: 1,
      target_id: this.targetId, config: this.cfg, dims: this.dims, param_names: this.names,
    }, null, 2));
  }
  static load(dir: string): DflashDrafter {
    const meta = JSON.parse(readFileSync(join(dir, "dspark.json"), "utf8")) as {
      variant?: string; config: DflashConfig; dims: TargetDims; target_id: string;
    };
    if (meta.variant !== "dspark" && meta.variant !== "dflash")
      throw new Error(`${dir} is not a dspark drafter (variant=${meta.variant ?? "none — a v1 single-vector checkpoint?"})`);
    const d = new DflashDrafter(meta.config, meta.dims, meta.target_id);
    const tensors = loadAdapterTensors(join(dir, "model.safetensors"));
    try {
      for (const name of d.names) { const a = tensors.get(name); if (!a) throw new Error(`missing ${name}`); d.#p.set(name, a); }
    } finally { for (const [name, arr] of tensors) if (!d.names.includes(name)) arr.dispose(); }
    return d;
  }
  dispose(): void { for (const a of this.#p.values()) a.dispose(); this.#p.clear(); }
}

function buildNames(cfg: DflashConfig): string[] {
  const names: string[] = [];
  for (let i = 0; i < cfg.nLayers; i++)
    names.push(`bb.${i}.attn_norm`, `bb.${i}.q`, `bb.${i}.k`, `bb.${i}.v`, `bb.${i}.o`, `bb.${i}.ff_norm`, `bb.${i}.gate`, `bb.${i}.up`, `bb.${i}.down`);
  names.push("W_c", "ctx_norm", "tok_proj", "mask_emb", "block_pos", "out_norm", "out_proj", "markov.w1", "markov.w2", "conf.w", "conf.b");
  // rnn.* MUST be appended LAST — see the matching comment in initFromDims:
  // this ordering keeps the shared/markov params drawing identical seeded rng
  // values whether or not the rnn head is present (init-equivalence gate).
  if (cfg.seqHead === "rnn") names.push("rnn.wH", "rnn.bH", "rnn.wO");
  return names;
}
