// Model-free gate for DeepspecDrafter (src/spec/dspark/deepspec-module.ts) —
// a port of DeepSeek's DeepSpec Gemma4DSparkModel
// (github.com/deepseek-ai/DeepSpec, MIT), NOT this repo's own in-house
// DSpark/DFlash experiment (module.ts / module-dflash.ts — untouched here).
//
// Builds a TINY synthetic checkpoint on disk in THEIR exact config.json
// field names and model.safetensors tensor keys (scaled-down dims), then
// exercises: load + validation, context projection → block forward shape
// flow, sequential greedy sampling, determinism, confidence truncation
// (including the ℓ=0 empty-proposal case), k≡v equivalence, and the
// layer_scalar semantics (`return hidden_states * layer_scalar` — the
// WHOLE layer output, residual included).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { writeShardedSafetensors, type NamedTensor } from "../src/quantize/safetensors-writer";
import { DeepspecDrafter } from "../src/spec/dspark/deepspec-module";
import { quantizeDrafterDir } from "../src/spec/dspark/quantize-drafter";
import { Weights } from "../src/weights";

function rng(seed: number): () => number {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

function bf16(data: Float32Array, shape: number[]): MlxArray {
  const f = MlxArray.fromFloat32(data, shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b.eval();
}

function randBf16(r: () => number, shape: number[], scale = 0.02): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  for (let i = 0; i < n; i++) data[i] = (r() - 0.5) * 2 * scale;
  return bf16(data, shape);
}

function zerosBf16(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  return bf16(new Float32Array(n), shape);
}

function onesBf16(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  return bf16(new Float32Array(n).fill(1), shape);
}

// --- tiny synthetic dims, THEIR field names ---------------------------
const HIDDEN = 32;
const N_LAYERS = 2;
const N_HEADS = 4;
const HEAD_DIM = 8;
const N_KV_HEADS = 1;
const VOCAB = 64;
const BLOCK = 5; // gamma
const INTERMEDIATE = 64;
const TAPS = [1, 2];
const MARKOV_RANK = 4;
const MASK_TOKEN = 4;

interface BuildOpts {
  layerScalars?: number[]; // per-layer scalar override (default all 1)
  markovZero?: boolean; // zero markov_w2 (pure base-logits argmax)
  confidenceZero?: boolean; // zero confidence_head weights → sigmoid(0)=0.5
  confidenceThreshold?: number;
  seed?: number;
  /** Override MARKOV_RANK (the quantized-checkpoint block uses 32 so the
   *  markov tensors and the confidence proj are group-eligible). */
  markovRank?: number;
}

function buildCheckpoint(dir: string, opts: BuildOpts = {}) {
  const r = rng(opts.seed ?? 42);
  const markovRank = opts.markovRank ?? MARKOV_RANK;
  const tensors: NamedTensor[] = [];
  const push = (name: string, array: MlxArray) => tensors.push({ name, array });

  push("embed_tokens.weight", randBf16(r, [VOCAB, HIDDEN]));
  push("fc.weight", randBf16(r, [HIDDEN, TAPS.length * HIDDEN]));
  push("hidden_norm.weight", onesBf16([HIDDEN]));
  push("norm.weight", onesBf16([HIDDEN]));
  push("lm_head.weight", randBf16(r, [VOCAB, HIDDEN]));

  for (let i = 0; i < N_LAYERS; i++) {
    const p = `layers.${i}`;
    push(`${p}.self_attn.q_proj.weight`, randBf16(r, [N_HEADS * HEAD_DIM, HIDDEN]));
    push(`${p}.self_attn.k_proj.weight`, randBf16(r, [N_KV_HEADS * HEAD_DIM, HIDDEN]));
    push(`${p}.self_attn.o_proj.weight`, randBf16(r, [HIDDEN, N_HEADS * HEAD_DIM]));
    push(`${p}.self_attn.q_norm.weight`, onesBf16([HEAD_DIM]));
    push(`${p}.self_attn.k_norm.weight`, onesBf16([HEAD_DIM]));
    push(`${p}.input_layernorm.weight`, onesBf16([HIDDEN]));
    push(`${p}.post_attention_layernorm.weight`, onesBf16([HIDDEN]));
    push(`${p}.pre_feedforward_layernorm.weight`, onesBf16([HIDDEN]));
    push(`${p}.post_feedforward_layernorm.weight`, onesBf16([HIDDEN]));
    push(`${p}.mlp.gate_proj.weight`, randBf16(r, [INTERMEDIATE, HIDDEN]));
    push(`${p}.mlp.up_proj.weight`, randBf16(r, [INTERMEDIATE, HIDDEN]));
    push(`${p}.mlp.down_proj.weight`, randBf16(r, [HIDDEN, INTERMEDIATE]));
    const scalarVal = opts.layerScalars ? opts.layerScalars[i]! : 1;
    push(`${p}.layer_scalar`, bf16(new Float32Array([scalarVal]), [1]));
  }

  push(
    "markov_head.markov_w1.weight",
    opts.markovZero ? zerosBf16([VOCAB, markovRank]) : randBf16(r, [VOCAB, markovRank]),
  );
  push(
    "markov_head.markov_w2.weight", // stored as Linear [vocab, rank] (out,in)
    opts.markovZero ? zerosBf16([VOCAB, markovRank]) : randBf16(r, [VOCAB, markovRank]),
  );

  push(
    "confidence_head.proj.weight",
    opts.confidenceZero ? zerosBf16([1, HIDDEN + markovRank]) : randBf16(r, [1, HIDDEN + markovRank]),
  );
  push("confidence_head.proj.bias", zerosBf16([1]));

  writeShardedSafetensors(dir, tensors);
  for (const t of tensors) t.array.dispose();

  const config = {
    architectures: ["Gemma4DSparkModel"],
    hidden_size: HIDDEN,
    num_hidden_layers: N_LAYERS,
    num_attention_heads: N_HEADS,
    global_head_dim: HEAD_DIM,
    num_global_key_value_heads: N_KV_HEADS,
    attention_k_eq_v: true,
    intermediate_size: INTERMEDIATE,
    hidden_activation: "gelu_pytorch_tanh",
    rms_norm_eps: 1e-6,
    final_logit_softcapping: 30.0,
    vocab_size: VOCAB,
    block_size: BLOCK,
    mask_token_id: MASK_TOKEN,
    target_layer_ids: TAPS,
    num_target_layers: 5,
    markov_rank: markovRank,
    markov_head_type: "vanilla",
    enable_confidence_head: true,
    confidence_head_with_markov: true,
    rope_parameters: {
      full_attention: { partial_rotary_factor: 0.25, rope_theta: 1e6, rope_type: "proportional" },
    },
    confidence_threshold: opts.confidenceThreshold ?? 0,
  };
  writeFileSync(join(dir, "config.json"), JSON.stringify(config, null, 2));
}

async function withTmpDir<T>(fn: (dir: string) => Promise<T> | T): Promise<T> {
  const dir = mkdtempSync(join(tmpdir(), "dspark-deepspec-"));
  try {
    return await fn(dir);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/** targetHiddens [1, L=taps.length, TAPS.length*HIDDEN] stub — a fixed
 *  concat vector standing in for the target model's tapped hidden states. */
function fakeTargetHiddens(r: () => number, ctxLen: number): MlxArray {
  const n = ctxLen * TAPS.length * HIDDEN;
  const data = new Float32Array(n);
  for (let i = 0; i < n; i++) data[i] = (r() - 0.5) * 0.2;
  return bf16(data, [1, ctxLen, TAPS.length * HIDDEN]);
}

describe("DeepspecDrafter", () => {
  test("load validates architecture and reads config fields", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir);
      const d = await DeepspecDrafter.load(dir);
      try {
        expect(d.gamma).toBe(BLOCK);
        expect(d.tapLayers).toEqual(TAPS);
        expect(d.cfg.mask_token_id).toBe(MASK_TOKEN);
        expect(d.cfg.vocab_size).toBe(VOCAB);
        expect(d.cfg.confidence_threshold).toBe(0);
        expect(d.hidden).toBe(HIDDEN);
        expect(d.nHeads).toBe(N_HEADS);
        expect(d.headDim).toBe(HEAD_DIM);
      } finally {
        d.dispose();
      }
    });
  });

  test("load rejects wrong architecture", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir);
      const cfgPath = join(dir, "config.json");
      const cfg = JSON.parse(await Bun.file(cfgPath).text());
      cfg.architectures = ["SomethingElse"];
      writeFileSync(cfgPath, JSON.stringify(cfg));
      await expect(DeepspecDrafter.load(dir)).rejects.toThrow(/Gemma4DSparkModel/);
    });
  });

  test("shapes flow: context project -> context KV -> block forward -> logits [1,gamma,V]", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir);
      const d = await DeepspecDrafter.load(dir);
      const r = rng(1);
      const ctxLen = 3;
      try {
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        expect(projected.shape).toEqual([1, ctxLen, HIDDEN]);

        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();
        expect(ctxKV.length).toBe(N_LAYERS);
        for (const { k, v } of ctxKV) {
          expect(k.shape).toEqual([1, N_KV_HEADS, ctxLen, HEAD_DIM]);
          expect(v.shape).toEqual([1, N_KV_HEADS, ctxLen, HEAD_DIM]);
        }

        const result = d.draftBlock(ctxKV, /* anchorTok */ 7, /* anchorPos */ ctxLen);
        expect(result.baseLogits.shape).toEqual([1, BLOCK, VOCAB]);
        expect(result.tokens.length).toBeLessThanOrEqual(BLOCK);
        for (const t of result.tokens) {
          expect(Number.isInteger(t)).toBe(true);
          expect(t).toBeGreaterThanOrEqual(0);
          expect(t).toBeLessThan(VOCAB);
        }

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("sequential greedy sampling returns gamma in-vocab tokens (threshold disabled)", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir, { confidenceThreshold: 0 });
      const d = await DeepspecDrafter.load(dir);
      const r = rng(2);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        const result = d.draftBlock(ctxKV, 3, ctxLen);
        // threshold<=0 disables truncation: full block_size tokens returned.
        expect(result.tokens.length).toBe(BLOCK);
        expect(result.conf.length).toBe(BLOCK);
        for (const t of result.tokens) {
          expect(t).toBeGreaterThanOrEqual(0);
          expect(t).toBeLessThan(VOCAB);
        }

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("determinism: same inputs produce same tokens twice", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir);
      const d = await DeepspecDrafter.load(dir);

      const runOnce = () => {
        const r = rng(5);
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();
        const result = d.draftBlock(ctxKV, 9, ctxLen);
        const tokens = [...result.tokens];
        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
        return tokens;
      };

      try {
        const first = runOnce();
        const second = runOnce();
        expect(second).toEqual(first);
      } finally {
        d.dispose();
      }
    });
  });

  test("confidence truncation: zero confidence weights -> sigmoid(0)=0.5, threshold 0.6 truncates to ZERO tokens", async () => {
    await withTmpDir(async (dir) => {
      // Zero confidence_head.proj weight AND bias => proj output is always
      // exactly 0 regardless of features => sigmoid(0) = 0.5 at EVERY
      // position. threshold=0.6 > 0.5 means below_threshold is true at
      // position 0 => _confident_prefix_length returns 0 => EMPTY proposal
      // is representable (ℓ=0, base logits still valid for a plain target
      // step per draft_ops.py's _empty_dspark_proposal contract).
      buildCheckpoint(dir, { confidenceZero: true, confidenceThreshold: 0.6 });
      const d = await DeepspecDrafter.load(dir);
      const r = rng(6);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        const result = d.draftBlock(ctxKV, 1, ctxLen);
        expect(result.tokens.length).toBe(0);
        expect(result.conf.length).toBe(0);
        // base logits are still full width — a verifier could still recover
        // a plain single-step target logit from position 0 if it wanted to.
        expect(result.baseLogits.shape).toEqual([1, BLOCK, VOCAB]);

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("confidence truncation: threshold below 0.5 keeps the full block (below.any() is false)", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir, { confidenceZero: true, confidenceThreshold: 0.4 });
      const d = await DeepspecDrafter.load(dir);
      const r = rng(6);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        const result = d.draftBlock(ctxKV, 1, ctxLen);
        // sigmoid(0)=0.5 is NOT below 0.4 at any position => full block kept.
        expect(result.tokens.length).toBe(BLOCK);

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("k===v equivalence: attention_k_eq_v means V bits equal K bits pre-rope (v gets no rope)", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir);
      const d = await DeepspecDrafter.load(dir);
      const r = rng(8);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        // v ≡ k pre-rope (v_norm is scale-less rms over the SAME k_proj
        // output the k-path norms with a weight) — v and k are therefore
        // different tensors post-rope (k gets roped, v does not), but both
        // derive from identical raw k_proj(context) bits. Assert BY VALUE
        // (2026-07-06 review: the shape-only version passed even if k/v were
        // aliased or v wrongly roped):
        //  - v must NOT equal roped-k at some position with a nonzero rope
        //    angle (position > 0 rows rotate; the drafter branches, not
        //    aliases);
        //  - v must not be all-zero/garbage (real values flowed).
        for (const { k, v } of ctxKV) {
          expect(k.shape).toEqual(v.shape);
          const kf = k.toFloat32();
          const vf = v.toFloat32();
          expect(kf.length).toBe(vf.length);
          // some position-1+ element must differ (k roped there, v not)
          let differs = false;
          for (let i = 0; i < kf.length; i++) if (Math.abs(kf[i]! - vf[i]!) > 1e-6) { differs = true; break; }
          expect(differs).toBe(true);
          // v carries real signal
          expect(vf.some((x) => Number.isFinite(x) && x !== 0)).toBe(true);
        }

        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("layer_scalar=0 on layer 1 zeroes that layer's ENTIRE output (residual included, not just the delta)", async () => {
    // Gemma4DSparkDecoderLayer.forward: `return hidden_states * self.layer_scalar`
    // — applied to `residual + mlp_out` (the whole post-FFN sum), so
    // layer_scalar=0 must make the entire layer's contribution to h vanish:
    // h_after_layer1 == 0 * anything == exactly zero, NOT "residual passes
    // through unchanged" (a naive reading of "layer_scalar gates the delta"
    // would predict h_after_layer1 == h_before_layer1; the source scales
    // the WHOLE return value, so it's zero instead).
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir, { layerScalars: [1, 0] });
      const d = await DeepspecDrafter.load(dir);
      const r = rng(11);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        const result = d.draftBlock(ctxKV, 2, ctxLen);
        // With layer 1's output forced to exactly zero, `norm(h)` after the
        // stack is rms_norm(0) = 0 (rms_norm of an all-zero vector is 0
        // regardless of eps/weight — 0/sqrt(0+eps) = 0), so compute_logits
        // is lm_head(0) = 0, softcapped: tanh(0/30)*30 = 0.
        const logits = result.baseLogits.toFloat32();
        for (const v of logits) expect(v).toBeCloseTo(0, 5);

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });

  test("markov head with W2=0 degenerates to pure base-logits argmax", async () => {
    await withTmpDir(async (dir) => {
      buildCheckpoint(dir, { markovZero: true, confidenceThreshold: 0 });
      const d = await DeepspecDrafter.load(dir);
      const r = rng(13);
      try {
        const ctxLen = 2;
        const raw = fakeTargetHiddens(r, ctxLen);
        const projected = d.projectContext(raw);
        raw.dispose();
        const positions = Array.from({ length: ctxLen }, (_, i) => i);
        const ctxKV = d.projectContextKV(projected, positions);
        projected.dispose();

        const result = d.draftBlock(ctxKV, 5, ctxLen);
        // markov_w2 == 0 => bias == 0 at every step => step_logits ==
        // base_logits[:,k] exactly => tokens are the per-position argmax of
        // baseLogits directly (cross-check by recomputing argmax ourselves).
        const flat = result.baseLogits.toFloat32();
        for (let k = 0; k < BLOCK; k++) {
          let best = 0, bestV = -Infinity;
          for (let v = 0; v < VOCAB; v++) {
            const val = flat[k * VOCAB + v]!;
            if (val > bestV) { bestV = val; best = v; }
          }
          expect(result.tokens[k]).toBe(best);
        }

        result.baseLogits.dispose();
        for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
      } finally {
        d.dispose();
      }
    });
  });
});

// ---------------------------------------------------------------------------
// Quantized checkpoint (Phase 1a/1b, docs/design/speculative-decoding.md):
// quantize the synthetic bf16 checkpoint through the drafter policy
// (scripts/dspark.ts quantize), then verify detection, policy, and
// that the quantized forward tracks the bf16 forward. markovRank=32 makes
// the markov tensors and the confidence proj group-32-eligible, so the
// policy exclusion (confidence stays bf16) is actually exercised rather
// than hidden behind shape ineligibility.
// ---------------------------------------------------------------------------

describe("DeepspecDrafter (quantized checkpoint)", () => {
  const QOPTS = { bits: 8 as const, groupSize: 32 as const };

  async function buildPair(fn: (bf16Dir: string, qDir: string) => Promise<void>): Promise<void> {
    await withTmpDir(async (bf16Dir) => {
      await withTmpDir(async (qDir) => {
        buildCheckpoint(bf16Dir, { markovRank: 32, confidenceThreshold: 0 });
        await quantizeDrafterDir(bf16Dir, qDir, QOPTS);
        await fn(bf16Dir, qDir);
      });
    });
  }

  test("policy: matmul weights + gather tables quantized, confidence head kept bf16", async () => {
    await buildPair(async (_bf16Dir, qDir) => {
      const w = await Weights.open(qDir);
      try {
        // Quantized: every 2-D matmul weight and both gather tables.
        for (const base of [
          "embed_tokens", "fc", "lm_head",
          "layers.0.self_attn.q_proj", "layers.0.self_attn.k_proj", "layers.0.self_attn.o_proj",
          "layers.1.mlp.gate_proj", "layers.1.mlp.up_proj", "layers.1.mlp.down_proj",
          "markov_head.markov_w1", "markov_head.markov_w2",
        ]) {
          expect(w.has(`${base}.scales`)).toBe(true);
          expect(w.has(`${base}.biases`)).toBe(true);
        }
        // Kept bf16: the confidence head (policy), norms + scalars (shape).
        for (const base of [
          "confidence_head.proj", "norm", "hidden_norm",
          "layers.0.input_layernorm", "layers.0.self_attn.q_norm",
        ]) {
          expect(w.has(`${base}.scales`)).toBe(false);
        }
        expect(w.has("layers.0.layer_scalar")).toBe(true); // passthrough survived
        expect(w.has("confidence_head.proj.bias")).toBe(true);
      } finally {
        w.dispose();
      }

      // Config block: house default + the mlx `false` convention for the
      // policy-excluded head.
      const cfg = (await Bun.file(join(qDir, "config.json")).json()) as Record<string, any>;
      expect(cfg.quantization.bits).toBe(QOPTS.bits);
      expect(cfg.quantization.group_size).toBe(QOPTS.groupSize);
      expect(cfg.quantization["confidence_head.proj"]).toBe(false);
      expect(cfg.architectures).toEqual(["Gemma4DSparkModel"]);
    });
  });

  test("quantized checkpoint loads and drafts deterministically (full gamma, in-vocab)", async () => {
    await buildPair(async (_bf16Dir, qDir) => {
      const d = await DeepspecDrafter.load(qDir);
      try {
        const runOnce = () => {
          const r = rng(21);
          const raw = fakeTargetHiddens(r, 2);
          const projected = d.projectContext(raw);
          raw.dispose();
          const ctxKV = d.projectContextKV(projected, [0, 1]);
          projected.dispose();
          const result = d.draftBlock(ctxKV, 7, 2);
          const tokens = [...result.tokens];
          result.baseLogits.dispose();
          for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
          return tokens;
        };
        const first = runOnce();
        expect(first.length).toBe(BLOCK);
        for (const t of first) {
          expect(t).toBeGreaterThanOrEqual(0);
          expect(t).toBeLessThan(VOCAB);
        }
        expect(runOnce()).toEqual(first);
      } finally {
        d.dispose();
      }
    });
  });

  test("8-bit quantized forward tracks the bf16 forward (same tokens, close logits)", async () => {
    await buildPair(async (bf16Dir, qDir) => {
      const run = async (dir: string) => {
        const d = await DeepspecDrafter.load(dir);
        try {
          const r = rng(33);
          const raw = fakeTargetHiddens(r, 3);
          const projected = d.projectContext(raw);
          raw.dispose();
          const ctxKV = d.projectContextKV(projected, [0, 1, 2]);
          projected.dispose();
          const result = d.draftBlock(ctxKV, 5, 3);
          const logits = result.baseLogits.toFloat32();
          const tokens = [...result.tokens];
          result.baseLogits.dispose();
          for (const { k, v } of ctxKV) { k.dispose(); v.dispose(); }
          return { logits, tokens };
        } finally {
          d.dispose();
        }
      };
      const a = await run(bf16Dir);
      const b = await run(qDir);
      // 8-bit affine is near-lossless on this scale: the greedy block must
      // survive quantization, and the softcapped logits (range ±30) must
      // stay close — a wrong transpose/spec/gather in the quantized path
      // produces garbage far outside this tolerance.
      expect(b.tokens).toEqual(a.tokens);
      let maxDiff = 0;
      for (let i = 0; i < a.logits.length; i++) {
        maxDiff = Math.max(maxDiff, Math.abs(a.logits[i]! - b.logits[i]!));
      }
      expect(maxDiff).toBeLessThan(0.5);
      expect(maxDiff).toBeGreaterThan(0); // actually a different code path ran
    });
  });

  test("rejects an already-quantized source", async () => {
    await buildPair(async (_bf16Dir, qDir) => {
      await withTmpDir(async (q2Dir) => {
        await expect(quantizeDrafterDir(qDir, q2Dir, QOPTS)).rejects.toThrow(/already quantized/);
      });
    });
  });
});
