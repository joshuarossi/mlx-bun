// DSpark draft module — a trainable, semi-autoregressive speculative drafter
// for frozen Gemma-4 e4b. Port of the architecture in DeepSeek's DSpark paper
// ("Confidence-Scheduled Speculative Decoding with Semi-Autoregressive
// Generation"), instantiated against this repo's e4b spine.
//
// Three sub-parts (paper §3.1–3.2), all reading e4b's tapped hidden state:
//   1. DFlash backbone — a lightweight bidirectional transformer over a
//      γ-token block (anchor + γ−1 learned mask tokens) plus one injected
//      context token (the tapped target hidden, H_ctx). One forward pass
//      predicts all γ draft positions in parallel. (paper Eq 2–3, m=1
//      single-vector context for v1.)
//   2. Markov head — low-rank first-order transition bias added to the base
//      logits, B(x_{k-1},·) = W1[x_{k-1}]·W2, r=256. W2 INIT 0 so the module
//      starts as the pure-parallel DFlash baseline and τ climbs as the head
//      learns intra-block dependency. (paper Eq 5)
//   3. Confidence head — c_k = σ(wᵀ[h_k; W1[x_{k-1}]]) ∈ (0,1), per-position
//      predicted acceptance probability. (paper Eq 7)
//
// It SHARES e4b's frozen embedding + LM head (logits = the same head the
// target verifies with, so draft tokens live in the same vocab/logit space).
// Only the parts here are trainable; the target stays frozen.
//
// Tap point (v1, by design decision): the final post-norm hidden from
// model.forwardHidden — the m=1 degenerate of DFlash's multi-layer H_ctx,
// and exactly what the existing GemmaAssistantDrafter consumes. Zero changes
// to the parity-gated model files. Richer context injection (intermediate
// post-PLE residual, multi-layer concat, or borrowing the target's prefix
// K/V à la GemmaAssistantDrafter) is the main τ lever after v1.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import type { Gemma4Model } from "../../model/gemma4";
import { loadAdapterTensors } from "../../lora";
import { writeShardedSafetensors, type NamedTensor } from "../../quantize/safetensors-writer";
import { processLogits, sampleToken, KeyStream, type DSparkSampleConfig } from "./sample";
import { mkdirSync, writeFileSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

export interface DSparkConfig {
  /** Max draft-block size γ (paper default 5). */
  gamma: number;
  /** Backbone hidden width. */
  dDraft: number;
  /** Backbone depth (paper default 5; 2 already beats 5-layer DFlash). */
  nLayers: number;
  /** Backbone attention heads (dDraft must be divisible). */
  nHeads: number;
  /** Markov low-rank dim r (paper default 256). */
  markovRank: number;
  /** FFN expansion multiple (dInter = ffMult·dDraft). */
  ffMult: number;
}

export const DEFAULT_DSPARK_CONFIG: DSparkConfig = {
  gamma: 5,
  dDraft: 1024,
  nLayers: 2,
  nHeads: 8,
  markovRank: 256,
  ffMult: 2,
};

/** Dims read from the live target model — never hardcoded. */
export interface TargetDims {
  hiddenSize: number;
  vocabSize: number;
  eps: number;
}

/** Output of the parallel training forward over a batch of A anchors. */
export interface DSparkTrainOut {
  /** Draft logits U_k + B_k, pre-softmax. [A, γ, V] (float32). */
  draftLogits: MlxArray;
  /** Per-position predicted acceptance probability c_k ∈ (0,1). [A, γ]. */
  conf: MlxArray;
}

/** Output of one inference draft-block generation. */
export interface DSparkDraftBlock {
  /** Drafted token ids d_1..d_γ. */
  tokens: number[];
  /** Per-position confidence c_1..c_γ. */
  conf: number[];
  /** Raw per-position draft logits U_k+B_k [1, γ, V] (given the sampled prefix).
   *  The verifier reprocesses these with the same sampling config to recover the
   *  draft distribution q_k for the accept/residual rule. Caller disposes. */
  draftLogits: MlxArray;
}

/** Options for one draft-block generation. */
export interface DSparkDraftOpts {
  /** Sampling config; omit (or temperature 0) ⇒ greedy argmax. */
  sample?: DSparkSampleConfig;
  /** Shared key stream (so draft + verify draws are reproducible together). */
  keys?: KeyStream;
}

const CDT = Dtype.float32; // compute & param dtype for the small draft module

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

// --- seeded init --------------------------------------------------------
// xorshift32 + Box–Muller. Deterministic given a seed so checkpoints and
// smoke tests reproduce. (Date/Math.random are unavailable in some harness
// contexts; this is self-contained anyway.)
function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 0x9e3779b9;
  return () => {
    s ^= s << 13; s >>>= 0;
    s ^= s >> 17;
    s ^= s << 5; s >>>= 0;
    return s / 0x100000000;
  };
}

function normalArray(rng: () => number, shape: number[], std: number): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i += 2) {
    const u1 = Math.max(rng(), 1e-12);
    const u2 = rng();
    const r = Math.sqrt(-2 * Math.log(u1));
    out[i] = r * Math.cos(2 * Math.PI * u2) * std;
    if (i + 1 < n) out[i + 1] = r * Math.sin(2 * Math.PI * u2) * std;
  }
  return MlxArray.fromFloat32(out, shape);
}

function zerosArray(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  return MlxArray.fromFloat32(new Float32Array(n), shape);
}

function constArray(shape: number[], value: number): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  return MlxArray.fromFloat32(new Float32Array(n).fill(value), shape);
}

export class DSparkDrafter {
  readonly cfg: DSparkConfig;
  readonly dims: TargetDims;
  /** Stamped onto the checkpoint so the registry can key it to its target. */
  readonly targetId: string;
  /** Trainable params keyed by stable name. */
  #p = new Map<string, MlxArray>();
  /** Canonical flat order — the only source of truth for param ordering. */
  readonly names: string[];

  private constructor(cfg: DSparkConfig, dims: TargetDims, targetId: string) {
    this.cfg = cfg;
    this.dims = dims;
    this.targetId = targetId;
    if (cfg.dDraft % cfg.nHeads !== 0)
      throw new Error(`dDraft ${cfg.dDraft} not divisible by nHeads ${cfg.nHeads}`);
    this.names = buildNames(cfg);
  }

  static dimsOf(model: Gemma4Model): TargetDims {
    const t = model.config.text;
    return { hiddenSize: t.hiddenSize, vocabSize: t.vocabSize, eps: t.rmsNormEps };
  }

  /** Fresh, randomly initialized module sized to `model`. W2=0 (pure DFlash
   *  at init), confidence head zero (c≈0.5 at init). */
  static init(model: Gemma4Model, cfg: DSparkConfig, targetId: string, seed = 0): DSparkDrafter {
    return DSparkDrafter.initFromDims(DSparkDrafter.dimsOf(model), cfg, targetId, seed);
  }

  /** As `init` but sized from explicit dims (no model needed — used by tests
   *  and the offline checkpoint path). */
  static initFromDims(dims: TargetDims, cfg: DSparkConfig, targetId: string, seed = 0): DSparkDrafter {
    const d = new DSparkDrafter(cfg, dims, targetId);
    const rng = makeRng(seed);
    const { dDraft, nLayers, markovRank: r, ffMult } = cfg;
    const dInter = ffMult * dDraft;
    const { hiddenSize: H, vocabSize: V } = d.dims;
    const set = (n: string, a: MlxArray) => d.#p.set(n, a.eval());

    for (let i = 0; i < nLayers; i++) {
      set(`bb.${i}.attn_norm`, constArray([dDraft], 1.0));
      for (const w of ["q", "k", "v", "o"]) set(`bb.${i}.${w}`, normalArray(rng, [dDraft, dDraft], 0.02));
      set(`bb.${i}.ff_norm`, constArray([dDraft], 1.0));
      set(`bb.${i}.gate`, normalArray(rng, [dDraft, dInter], 0.02));
      set(`bb.${i}.up`, normalArray(rng, [dDraft, dInter], 0.02));
      set(`bb.${i}.down`, normalArray(rng, [dInter, dDraft], 0.02));
    }
    set("ctx_proj", normalArray(rng, [H, dDraft], 0.02));
    set("tok_proj", normalArray(rng, [H, dDraft], 0.02));
    set("mask_emb", normalArray(rng, [cfg.gamma - 1, dDraft], 0.02));
    set("pos_emb", normalArray(rng, [cfg.gamma + 1, dDraft], 0.02));
    set("out_norm", constArray([dDraft], 1.0));
    set("out_proj", normalArray(rng, [dDraft, H], 0.02));
    set("markov.w1", normalArray(rng, [V, r], 0.02));
    set("markov.w2", zerosArray([r, V]));        // ← starts as pure DFlash
    set("conf.w", zerosArray([dDraft + r, 1]));   // ← c≈0.5 at init
    set("conf.b", zerosArray([1]));
    return d;
  }

  get(name: string): MlxArray {
    const a = this.#p.get(name);
    if (!a) throw new Error(`DSpark param not found: ${name}`);
    return a;
  }

  /** Params in canonical flat order — the leaves ValueAndGrad differentiates. */
  flatParams(): MlxArray[] {
    return this.names.map((n) => this.get(n));
  }

  /** Run `fn` with `primals` temporarily installed as the params (then restore
   *  the originals). Mirrors the LoRA swapPrimals discipline — lets a
   *  ValueAndGrad closure differentiate w.r.t. the flat param list while the
   *  forward reads params by name. */
  useParams<T>(primals: MlxArray[], fn: () => T): T {
    if (primals.length !== this.names.length)
      throw new Error(`useParams: ${primals.length} primals vs ${this.names.length} params`);
    const saved = this.names.map((n) => this.get(n));
    this.names.forEach((n, i) => this.#p.set(n, primals[i]!));
    try {
      return fn();
    } finally {
      this.names.forEach((n, i) => this.#p.set(n, saved[i]!));
    }
  }

  /** Install the optimizer's updated leaf as the i-th param. Does NOT dispose
   *  the previous one — AdamW.step already freed it. Use as AdamW's write
   *  callback: `new AdamW(d.flatParams(), opts, (i, p) => d.installParam(i, p))`. */
  installParam(i: number, p: MlxArray): void {
    this.#p.set(this.names[i]!, p);
  }

  // --- backbone -----------------------------------------------------------

  /** One pre-norm bidirectional transformer layer over [A, S, dDraft]. */
  #layer(i: number, x: MlxArray, A: number, S: number): MlxArray {
    const { dDraft, nHeads } = this.cfg;
    const hd = dDraft / nHeads;
    const eps = this.dims.eps;

    // attention (full / bidirectional — no mask)
    const residual = x;
    let n = ops.rmsNorm(x, this.get(`bb.${i}.attn_norm`), eps);
    const proj = (w: string) => {
      const m = ops.matmul(n, this.get(`bb.${i}.${w}`)); // [A,S,dDraft]
      const r = ops.reshape(m, [A, S, nHeads, hd]);
      m.dispose();
      const t = ops.transposeAxes(r, [0, 2, 1, 3]); // [A,nHeads,S,hd]
      r.dispose();
      return t;
    };
    const q = proj("q");
    const k = proj("k");
    const v = proj("v");
    n.dispose();
    let attn = ops.sdpa(q, k, v, Math.pow(hd, -0.5), "", null);
    q.dispose(); k.dispose(); v.dispose();
    attn = disposing(attn, ops.transposeAxes(attn, [0, 2, 1, 3])); // [A,S,nHeads,hd]
    attn = disposing(attn, ops.reshape(attn, [A, S, dDraft]));
    attn = disposing(attn, ops.matmul(attn, this.get(`bb.${i}.o`)));
    x = ops.add(residual, attn);
    attn.dispose();

    // gated-GELU FFN
    const res2 = x;
    n = ops.rmsNorm(x, this.get(`bb.${i}.ff_norm`), eps);
    const g = ops.matmul(n, this.get(`bb.${i}.gate`));
    const u = ops.matmul(n, this.get(`bb.${i}.up`));
    n.dispose();
    const act = ops.geluApprox(g);
    g.dispose();
    let mlp = ops.mul(act, u);
    act.dispose(); u.dispose();
    mlp = disposing(mlp, ops.matmul(mlp, this.get(`bb.${i}.down`)));
    const out = ops.add(res2, mlp);
    res2.dispose(); mlp.dispose();
    return out;
  }

  /** Build the [A, γ+1, dDraft] input sequence: [ctxToken, anchor, mask₁..].
   *  hCtx [A,H], anchorEmb [A,H] (raw embedding, no scale). */
  #buildSeq(hCtx: MlxArray, anchorEmb: MlxArray, A: number): MlxArray {
    const { gamma, dDraft } = this.cfg;
    const posEmb = this.get("pos_emb"); // [γ+1, dDraft]

    // backbone math is float32; cast the (possibly bf16) target tensors in.
    const hCtxF = hCtx.dtype === CDT ? hCtx : hCtx.astype(CDT);
    const anchorF = anchorEmb.dtype === CDT ? anchorEmb : anchorEmb.astype(CDT);

    // ctx token = ctx_proj(hCtx) + pos[0]
    let ctx = ops.matmul(hCtxF, this.get("ctx_proj")); // [A,dDraft]
    if (hCtxF !== hCtx) hCtxF.dispose();
    const pos0 = posEmb.slice([0, 0], [1, dDraft]);
    ctx = disposing(ctx, ops.add(ctx, pos0));
    pos0.dispose();
    ctx = disposing(ctx, ops.reshape(ctx, [A, 1, dDraft]));

    // anchor token (block position 0) = tok_proj(anchorEmb) + pos[1]
    let anchor = ops.matmul(anchorF, this.get("tok_proj")); // [A,dDraft]
    if (anchorF !== anchorEmb) anchorF.dispose();
    const pos1 = posEmb.slice([1, 0], [2, dDraft]);
    anchor = disposing(anchor, ops.add(anchor, pos1));
    pos1.dispose();
    anchor = disposing(anchor, ops.reshape(anchor, [A, 1, dDraft]));

    const parts = [ctx, anchor];
    if (gamma > 1) {
      // mask tokens (block positions 1..γ-1) = mask_emb[j-1] + pos[j+1], built
      // once at batch 1 then broadcast to A in a single add.
      const maskEmb = this.get("mask_emb"); // [γ-1, dDraft]
      const posMask = posEmb.slice([2, 0], [gamma + 1, dDraft]); // pos[2..γ] → [γ-1,dDraft]
      let masks = ops.add(maskEmb, posMask); // [γ-1, dDraft]
      posMask.dispose();
      masks = disposing(masks, ops.reshape(masks, [1, gamma - 1, dDraft]));
      const zerosA = MlxArray.fromFloat32(new Float32Array(A * dDraft), [A, 1, dDraft]);
      const masksA = ops.add(masks, zerosA); // broadcast → [A, γ-1, dDraft]
      masks.dispose(); zerosA.dispose();
      parts.push(masksA);
    }
    const seq = ops.concatAxis(parts, 1); // [A, γ+1, dDraft]
    for (const p of parts) p.dispose();
    return seq;
  }

  /** Run the backbone and return the per-block-position hidden h_1..h_γ
   *  [A, γ, dDraft]. */
  #backbone(hCtx: MlxArray, anchorEmb: MlxArray, A: number): MlxArray {
    const { gamma, dDraft } = this.cfg;
    const S = gamma + 1;
    let h = this.#buildSeq(hCtx, anchorEmb, A);
    for (let i = 0; i < this.cfg.nLayers; i++) h = disposing(h, this.#layer(i, h, A, S));
    h = disposing(h, ops.rmsNorm(h, this.get("out_norm"), this.dims.eps));
    // drop the ctx position (index 0); keep the γ block outputs
    const block = h.slice([0, 1, 0], [A, S, dDraft]); // [A,γ,dDraft]
    h.dispose();
    return block;
  }

  /** Base logits U from the SHARED frozen LM head over the backbone block
   *  hidden. [A,γ,V] (model dtype). */
  #baseLogits(model: Gemma4Model, block: MlxArray): MlxArray {
    const hOut = ops.matmul(block, this.get("out_proj")); // [A,γ,H] (f32)
    const hBf = hOut.astype(model.embed.scales.dtype);    // head's activation dtype
    hOut.dispose();
    const logits = model.logitsFromHidden(hBf); // shared head (+softcap) [A,γ,V]
    hBf.dispose();
    return logits;
  }

  /** Markov transition bias B [A,γ,V] from teacher/prev tokens [A,γ] and the
   *  W1-embedding emb1 [A,γ,r] (also returned for the confidence head). */
  #markov(prevToks: MlxArray): { B: MlxArray; emb1: MlxArray } {
    const w1 = this.get("markov.w1"); // [V,r]
    const w2 = this.get("markov.w2"); // [r,V]
    const emb1 = ops.takeAxis(w1, prevToks, 0); // [A,γ,r]
    const B = ops.matmul(emb1, w2);             // [A,γ,V]
    return { B, emb1 };
  }

  /** Confidence c_k = σ(wᵀ[h_k; emb1_k]). block [A,γ,dDraft], emb1 [A,γ,r]. */
  #confidence(block: MlxArray, emb1: MlxArray): MlxArray {
    const inp = ops.concatAxis([block, emb1], 2); // [A,γ,dDraft+r]
    let z = ops.matmul(inp, this.get("conf.w"));  // [A,γ,1]
    inp.dispose();
    z = disposing(z, ops.add(z, this.get("conf.b")));
    z = disposing(z, ops.sigmoid(z));
    const A = z.shape[0]!, G = z.shape[1]!;
    const c = ops.reshape(z, [A, G]); // [A,γ]
    z.dispose();
    return c;
  }

  /**
   * Parallel TRAINING forward over A anchors (teacher-forced Markov).
   *  - hCtx       [A, H]   target final hidden at each anchor (the tap, const)
   *  - anchorEmb  [A, H]   raw embedding of the anchor token x0 (const)
   *  - prevToks   [A, γ]   int32: [x0, x*_1, …, x*_{γ-1}] (teacher tokens)
   * Returns draftLogits = U + B [A,γ,V] (float32) and conf [A,γ].
   */
  forwardTrain(model: Gemma4Model, hCtx: MlxArray, anchorEmb: MlxArray, prevToks: MlxArray): DSparkTrainOut {
    const A = hCtx.shape[0]!;
    const block = this.#backbone(hCtx, anchorEmb, A);   // [A,γ,dDraft]
    const U = this.#baseLogits(model, block);        // [A,γ,V]
    const Uf = U.astype(CDT); U.dispose();
    const { B, emb1 } = this.#markov(prevToks);
    let draftLogits = ops.add(Uf, B);                   // [A,γ,V] f32
    Uf.dispose(); B.dispose();
    const conf = this.#confidence(block, emb1);
    block.dispose(); emb1.dispose();
    return { draftLogits, conf };
  }

  /**
   * INFERENCE: generate one γ-block by the semi-autoregressive rule — the
   * backbone runs ONCE (parallel U_1..U_γ), then the Markov head walks the block
   * left-to-right (each position conditions on the previously emitted draft
   * token). Greedy argmax when no sampling config (or temperature 0); otherwise
   * samples each token from the SAME processed distribution the verifier
   * reconstructs (so q is consistent). hCtx [1,H], anchorTok the bonus token.
   * Returns the raw per-position logits so the verifier can recover q.
   */
  forwardInfer(model: Gemma4Model, hCtx: MlxArray, anchorTok: number, gamma: number, opts: DSparkDraftOpts = {}): DSparkDraftBlock {
    const { dDraft, markovRank: r } = this.cfg;
    const V = this.dims.vocabSize;
    const A = 1;
    const sample = opts.sample && opts.sample.temperature > 0 ? opts.sample : null;
    const keys = opts.keys ?? new KeyStream(opts.sample?.seed ?? 0);

    // anchor embedding (raw)
    const ids = ops.fromInt32([anchorTok], [1, 1]);
    const anchorEmb3 = model.embed.encode(ids); // [1,1,H]
    ids.dispose();
    const anchorEmb = ops.reshape(anchorEmb3, [1, this.dims.hiddenSize]);
    anchorEmb3.dispose();

    const block = this.#backbone(hCtx, anchorEmb, A); // [1,γ,dDraft]
    anchorEmb.dispose();
    const U = this.#baseLogits(model, block);      // [1,γ,V]
    const Uf = U.astype(CDT); U.dispose();

    const w1 = this.get("markov.w1"); // [V,r]
    const w2 = this.get("markov.w2"); // [r,V]
    const tokens: number[] = [];
    const conf: number[] = [];
    const perPosLogits: MlxArray[] = []; // each [1,1,V], stacked into draftLogits
    let prevTok = anchorTok;
    for (let k = 0; k < gamma; k++) {
      // U_k [1,V]
      const Uk = Uf.slice([0, k, 0], [1, k + 1, V]);
      const UkFlat = ops.reshape(Uk, [1, V]);
      Uk.dispose();
      // B_k = W1[prevTok] · W2  → [1,V]
      const prevIdx = ops.fromInt32([prevTok], [1]);
      const e1 = ops.takeAxis(w1, prevIdx, 0); // [1,r]
      prevIdx.dispose();
      const Bk = ops.matmul(e1, w2);           // [1,V]
      const logitsK = ops.add(UkFlat, Bk);     // raw U_k + B_k [1,V]
      UkFlat.dispose(); Bk.dispose();

      let tok: number;
      if (sample) {
        const scaled = processLogits(logitsK, sample); // top-p/top-k/temp
        tok = sampleToken(scaled, keys.next());
        scaled.dispose();
      } else {
        const am = ops.argmaxAxis(logitsK, -1);
        tok = ops.itemUint32(am);
        am.dispose();
      }
      perPosLogits.push(ops.reshape(logitsK, [1, 1, V]));
      logitsK.dispose();

      // confidence c_k = σ(conf.w·[h_k; e1] + b)
      const hk = block.slice([0, k, 0], [1, k + 1, dDraft]);
      const hkFlat = ops.reshape(hk, [1, dDraft]);
      hk.dispose();
      const ci = ops.concatAxis([hkFlat, e1], 1); // [1,dDraft+r]
      hkFlat.dispose(); e1.dispose();
      let cz = ops.matmul(ci, this.get("conf.w"));
      ci.dispose();
      cz = disposing(cz, ops.add(cz, this.get("conf.b")));
      cz = disposing(cz, ops.sigmoid(cz));
      const cv = cz.toFloat32()[0]!;
      cz.dispose();
      tokens.push(tok);
      conf.push(cv);
      prevTok = tok;
    }
    Uf.dispose();
    block.dispose();
    const draftLogits = ops.concatAxis(perPosLogits, 1); // [1,γ,V]
    for (const a of perPosLogits) a.dispose();
    return { tokens, conf, draftLogits };
  }

  // --- persistence --------------------------------------------------------

  /** Save params + a sidecar dspark.json (config + target identity). */
  save(dir: string): void {
    mkdirSync(dir, { recursive: true });
    const tensors: NamedTensor[] = this.names.map((name) => ({ name, array: this.get(name) }));
    writeShardedSafetensors(dir, tensors);
    const meta = {
      kind: "dspark-drafter",
      version: 1,
      target_id: this.targetId,
      config: this.cfg,
      dims: this.dims,
      param_names: this.names,
    };
    writeFileSync(join(dir, "dspark.json"), JSON.stringify(meta, null, 2));
  }

  /** Load a saved module. Validates only that the tensor set matches the
   *  declared names (structural staleness lives in the registry association,
   *  not a runtime check). */
  static load(dir: string): DSparkDrafter {
    const metaPath = join(dir, "dspark.json");
    if (!existsSync(metaPath)) throw new Error(`no dspark.json in ${dir}`);
    const meta = JSON.parse(readFileSync(metaPath, "utf8")) as {
      target_id: string; config: DSparkConfig; dims: TargetDims; param_names: string[];
    };
    const d = new DSparkDrafter(meta.config, meta.dims, meta.target_id);
    const tensors = loadAdapterTensors(join(dir, "model.safetensors"));
    try {
      for (const name of d.names) {
        const a = tensors.get(name);
        if (!a) throw new Error(`checkpoint missing tensor: ${name}`);
        d.#p.set(name, a);
      }
    } finally {
      // dispose anything not adopted
      for (const [name, arr] of tensors) if (!d.names.includes(name)) arr.dispose();
    }
    return d;
  }

  dispose(): void {
    for (const a of this.#p.values()) a.dispose();
    this.#p.clear();
  }
}

/** Canonical flat param-name order (single source of truth). */
function buildNames(cfg: DSparkConfig): string[] {
  const names: string[] = [];
  for (let i = 0; i < cfg.nLayers; i++) {
    names.push(`bb.${i}.attn_norm`, `bb.${i}.q`, `bb.${i}.k`, `bb.${i}.v`, `bb.${i}.o`,
      `bb.${i}.ff_norm`, `bb.${i}.gate`, `bb.${i}.up`, `bb.${i}.down`);
  }
  names.push("ctx_proj", "tok_proj", "mask_emb", "pos_emb", "out_norm", "out_proj",
    "markov.w1", "markov.w2", "conf.w", "conf.b");
  return names;
}

