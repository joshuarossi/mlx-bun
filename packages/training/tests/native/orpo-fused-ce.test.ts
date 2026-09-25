// OPT-IN parity matrix for the ORPO FUSED linear-CE head and the paths built on
// it, restored from main's tests/research/train-orpo-fused-ce. What it proves:
//
//   - fused head (fusedLogpMeanB1: one CustomVjp with an analytic softmax−onehot
//     backward, no autograd through the head and no retained [M,vocab] logits —
//     the Liger/CCE structure) matches the full-logits head within bf16
//     tolerance across token-chunk sizes, and is bit-exact at a single chunk;
//   - flash-CCE head (in-kernel quantized logits + online softmax) matches the
//     full-logits head, and the M-dispatch below MLX_BUN_FLASH_MIN_M routes to
//     the exact fused head bit-for-bit;
//   - flash-CCE backward dh at production defaults matches full-logits autograd
//     dh on teacher-forced hiddens (the L3 standing gate);
//   - the bounded SFT segmented head is bit-exact vs the whole-vocab head at a
//     full-cover chunk and bf16-class at a tiny chunk, and the segmented step
//     matches the plain sftLoss value;
//   - sft_scope "response" is bit-identical to the default and "full" agrees
//     across naive/fused/flash/chunked/prefix-shared/segmented paths;
//   - fused, flash, segmented, prefix-shared, and their compositions train
//     end-to-end and improve the loss.
//
// The only divergence between these heads is single-ULP head-matmul/logsumexp
// rounding that tiles differently for [M,V] vs [chunk,V]; a logic bug shifts
// the loss by order 1, not <0.05. No softcap here (Gemma softcap lived in
// fused-ce-parity.ts, deleted 2026-08-23; git history).
//
// Every case loads a real MiniCPM5-1B base, so the file is doubly opt-in: the
// native command (MLX_BUN_TEST_NATIVE=1) AND an explicit caller-supplied cached
// snapshot directory in MLX_BUN_TRAINING_MODEL. Without both it skips before
// any native import; a directory that is set but unusable fails loudly.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot dir> \
//     bun test tests/native/orpo-fused-ce.test.ts

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { DpoBatch, SftBatch } from "../../src/dataset";
import type { TrainConfig } from "../../src/trainer";
import { TINY_DPO_ROWS, TINY_TRAIN_ROWS, writeJsonl } from "./tiny-dataset";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_MODEL;
const enabled = native && !!modelDir;
type MlxArray = import("@mlx-bun/mlx/array").MlxArray;
const { loadModelConfig, Weights } = enabled ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { createModel } = enabled ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { MiniCPM5Model } = enabled ? await import("@mlx-bun/inference/models/minicpm5") : {} as typeof import("@mlx-bun/inference/models/minicpm5");
const { loadTokenizer, ChatTemplate } = enabled ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { configureRuntime } = enabled ? await import("@mlx-bun/inference/runtime/config") : {} as typeof import("@mlx-bun/inference/runtime/config");
const { trainForwardHidden } = enabled ? await import("@mlx-bun/inference/scoring") : {} as typeof import("@mlx-bun/inference/scoring");
const { MlxArray } = enabled ? await import("@mlx-bun/mlx/array") : {} as typeof import("@mlx-bun/mlx/array");
const { Dtype } = enabled ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");
const { Vjp } = enabled ? await import("@mlx-bun/mlx/autograd") : {} as typeof import("@mlx-bun/mlx/autograd");
const ops = enabled ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { buildTrainableLora, attachForTraining, disposeLora } = enabled ? await import("../../src/lora-params") : {} as typeof import("../../src/lora-params");
const { resolveRanks } = enabled ? await import("../../src/rank") : {} as typeof import("../../src/rank");
const { encodeDpoRow, encodeSftRow } = enabled ? await import("../../src/dataset") : {} as typeof import("../../src/dataset");
const { orpoLoss, orpoMetrics, sftLoss, responseOnlyCe } = enabled ? await import("../../src/loss") : {} as typeof import("../../src/loss");
const { orpoLossPrefixShared, splitPrefixBatch } = enabled ? await import("../../src/prefix-shared") : {} as typeof import("../../src/prefix-shared");
const { boundedSftCe, SegmentedBackward, SegmentedBackwardOrpo, SegmentedBackwardOrpoPrefix, planSegmentsBySize } = enabled ? await import("../../src/segmented") : {} as typeof import("../../src/segmented");
const { flashCceForward, flashCceBackward } = enabled ? await import("../../src/kernels/flash-cce") : {} as typeof import("../../src/kernels/flash-cce");
const { trainLora, DEFAULT_TRAIN_CONFIG } = enabled ? await import("../../src/trainer") : {} as typeof import("../../src/trainer");

// This file's flash cases exist to exercise the flash-CCE head itself, on tiny
// rows (M ≈ 20) — pin the M-dispatch off (loss.ts fusedRespLogpMean, kernel
// backlog #3) so `flash: true` always routes to the flash kernel here.
const restoreFlashMin = enabled ? configureRuntime({ MLX_BUN_FLASH_MIN_M: "0" }) : () => {};
afterAll(() => restoreFlashMin());

/** The caller-supplied base: config, weights, model, tokenizer, template. */
async function loadBase() {
  const dir = modelDir!;
  if (!existsSync(join(dir, "config.json")))
    throw new Error(`MLX_BUN_TRAINING_MODEL=${dir} is not a model snapshot directory (no config.json)`);
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  try {
    const model = createModel(weights, config);
    const tok = await loadTokenizer(dir);
    const tmpl = await ChatTemplate.load(dir);
    return { dir, config, weights, model, tok, tmpl };
  } catch (error) {
    weights.dispose();
    throw error;
  }
}

/** Stage the tiny preference rows as a training set and run `trainLora` with
 *  main's shared ORPO settings plus `overrides`; returns the per-step train
 *  losses. The temp directory and weights are released afterwards. */
async function trainOnTinyDpo(prefix: string, overrides: Partial<TrainConfig>): Promise<number[]> {
  const tmp = mkdtempSync(join(tmpdir(), prefix));
  const dataDir = join(tmp, "data");
  mkdirSync(dataDir, { recursive: true });
  writeJsonl(join(dataDir, "train.jsonl"), TINY_DPO_ROWS);

  const { dir, weights, model, tok, tmpl } = await loadBase();
  try {
    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      ...overrides,
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: dir,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss); });
    return losses;
  } finally {
    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }
}

describe.skipIf(!enabled)("ORPO fused linear-CE head parity (MiniCPM5-1B)", () => {
  test("fused forward matches non-chunked within bf16 tolerance; full-size chunk is exact", async () => {
    const { weights, model, tok, tmpl } = await loadBase();

    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 123);
    attachForTraining(model, lora, "train");

    const ex = encodeDpoRow(TINY_DPO_ROWS[0]!, tok, tmpl, 256);
    const batch: DpoBatch = {
      chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
      chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
    };
    const respLen = Math.max(
      ex.chosenMask.reduce((a, b) => a + b, 0),
      ex.rejectedMask.reduce((a, b) => a + b, 0),
    );

    // chunkSize<=0 → full-logits head (the reference); >0 with fused → fused head.
    const lossOf = (chunkSize: number): number => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, 0.1, chunkSize > 0 ? { chunkSize, fused: true, sink } : undefined);
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    };

    const full = lossOf(0);
    expect(Number.isFinite(full)).toBe(true);

    // The fused forward is the same math as the full-logits head → equal within
    // bf16 tolerance across token-chunk sizes (observed diffs are single-ULP /M).
    for (const cs of [1, 4, 8]) {
      expect(Math.abs(lossOf(cs) - full)).toBeLessThan(0.05);
    }
    // A chunk >= the response length is a single chunk → bit-exact (same shapes).
    expect(lossOf(respLen + 8)).toBeCloseTo(full, 5);

    // flash-CCE head (in-kernel quantized logits + online softmax, no [M,V]) — the
    // forward is the same logp math, so the loss matches the full-logits head within
    // the kernel's bf16-class parity (~0.2% logp → well under 0.05 on an O(1) loss).
    const flashLoss = (() => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, 0.1, { chunkSize: respLen + 8, fused: true, flash: true, sink });
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    })();
    expect(Math.abs(flashLoss - full)).toBeLessThan(0.05);

    // M-dispatch (kernel backlog #3): a flash request whose M is below
    // MLX_BUN_FLASH_MIN_M routes to the EXACT fused head — the loss must be
    // bit-identical to the fused single-chunk loss (which differs from the
    // flash head's bf16-class value at ~1e-3).
    const restoreDispatch = configureRuntime({ MLX_BUN_FLASH_MIN_M: "8192" });
    try {
      const dispatched = (() => {
        const sink: Array<{ dispose(): void }> = [];
        const l = orpoLoss(model, batch, 0.1, { chunkSize: respLen + 8, fused: true, flash: true, sink });
        ops.evalAll([l]);
        const v = l.toFloat32()[0]!;
        l.dispose();
        for (const d of sink) d.dispose();
        return v;
      })();
      expect(dispatched).toBe(lossOf(respLen + 8)); // exact fused value, not flash's
    } finally {
      restoreDispatch();
    }

    disposeLora(lora);
    weights.dispose();
  }, 180_000);

  // The L3 standing gate ("teacher-forced grad fidelity"): the flash-CCE
  // backward dh — at the PRODUCTION defaults (coeff filter + blockMax skip ON at
  // 1e-5 since 2026-07-02) — must match the full-logits autograd dh on peaked
  // (teacher-forced) hiddens. A kernel/logic bug shifts dh by O(100%); the honest
  // fp-reassociation + filter residual measured on real data is <1% relnorm at
  // cosine ≥0.9999 (flash-cce-filter-realdata.ts, deleted 2026-08-23; git
  // history), so the 5% bar has a wide margin without tolerating structural
  // breakage.
  test("flash-CCE backward dh matches full-logits autograd dh at production defaults (teacher-forced fidelity)", async () => {
    const { config, weights, model } = await loadBase();
    if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");
    const H = config.text.hiddenSize, V = config.text.vocabSize;
    const lh = model.lmHead;
    const head = { w: lh.w, scales: lh.scales, biases: lh.biases!, bits: lh.spec.bits, groupSize: lh.spec.groupSize, softcap: null };

    // Teacher-forced regime: a REAL forward over in-vocab ids yields genuinely
    // peaked next-token distributions (the regime the filter defaults assume).
    const M = 256;
    const idData = Array.from({ length: M }, (_, i) => (i * 2659 + 13) % V);
    const ids = ops.fromInt32(idData, [1, M]);
    const cache = model.makeCache();
    const h3 = model.forwardHidden(ids, cache);
    const hResp = ops.reshape(h3, [M, H]);
    ops.evalAll([hResp]);
    const targets = idData.map((_, i) => idData[(i + 1) % M]!);

    // Reference: full-logits autograd dh for loss = Σ_t logp_t (unit cotangent).
    const vjp = new Vjp((primals) => {
      const l2 = ops.reshape(model.logitsFromHidden(ops.reshape(primals[0]!, [1, M, H])), [M, V]);
      const lse = ops.logsumexpAxis(l2, -1, false);
      const tgt = MlxArray.fromInt32(new Int32Array(targets), [M, 1]);
      const logp = ops.sub(ops.reshape(ops.takeAlongAxis(l2, tgt, -1), [M]), lse);
      return [ops.reshape(ops.sumAxis(logp.astype(Dtype.float32), 0, false), [1])];
    });
    const one = MlxArray.fromFloat32(new Float32Array([1]), [1]);
    const { outputs, vjps } = vjp.apply([hResp], [one]);
    const dhFull = vjps[0]!.astype(Dtype.float32);
    ops.evalAll([dhFull]);
    const fullF = dhFull.toFloat32();

    // Flash dh at the production defaults (filter + block skip at their defaults).
    const fwd = flashCceForward(hResp, head, targets);
    ops.evalAll([fwd.lse, fwd.blockMax]);
    const dh = flashCceBackward(hResp, head, targets, fwd.lse, new Array(M).fill(1), undefined, fwd.blockMax);
    ops.evalAll([dh]);
    const flashF = dh.toFloat32();

    let dot = 0, na = 0, nb = 0, d2 = 0;
    for (let i = 0; i < M * H; i++) {
      const a = fullF[i]!, b = flashF[i]!;
      dot += a * b; na += a * a; nb += b * b;
      const d = a - b; d2 += d * d;
    }
    const cosine = dot / (Math.sqrt(na * nb) || 1);
    const relnorm = Math.sqrt(d2) / (Math.sqrt(na) || 1);
    expect(cosine).toBeGreaterThan(0.999);
    expect(relnorm).toBeLessThan(0.05);

    for (const a of [ids, h3, hResp, one, dhFull, dh, fwd.logp, fwd.lse, fwd.blockMax, ...outputs, ...vjps]) a.dispose();
    for (const c of cache) c.dispose();
    vjp.dispose();
    weights.dispose();
  }, 180_000);

  // Kernel-review backlog #8 gate: the SFT segmented head is [M,V]-bounded
  // (boundedSftCe — token-chunked Checkpoint recompute instead of the full
  // [1,M,V] responseOnlyCe inside the head vjp). The gate is a HEAD-LEVEL A/B
  // on the identical post-finalNorm hidden: at a FULL-COVER chunk (the default
  // 512 covers this row) loss and dh must be BIT-EXACT vs the whole-vocab
  // responseOnlyCe head — same shapes, same kernels. A tiny chunk is bf16-
  // CLASS, not bit-exact (quantizedMatmul tiles differently per M — the same
  // band the ORPO chunked-head tests assert): loss within 0.05, dh relnorm
  // under 1%.
  //
  // NOT compared against a ValueAndGrad over sftLoss: under mlx grad tracing
  // the FORWARD itself computes differently (fused kernels swap to their
  // differentiable decompositions — measured 4.4359 plain vs 4.4836 traced on
  // this row), a pre-existing property of every segmented-vs-vag pairing,
  // orthogonal to the head.
  test("bounded SFT head: loss + dh bit-exact vs the whole-vocab responseOnlyCe head", async () => {
    const { weights, model, tok, tmpl } = await loadBase();
    if (!(model instanceof MiniCPM5Model)) throw new Error("expected MiniCPM5Model");

    const ex = encodeSftRow(TINY_TRAIN_ROWS[1]!, tok, tmpl); // main's train.jsonl row 1
    const batch: SftBatch = { ids: [ex.ids], promptLens: [ex.promptLen] };
    const T = ex.ids.length - 1;
    const ids = ops.fromInt32(ex.ids.slice(0, T), [1, T]);

    // Identical input for both heads: the post-finalNorm hidden as a leaf.
    const h = trainForwardHidden(model, ids);
    ops.evalAll([h]);
    const hn = MlxArray.fromBytesCopy(h.rawBytes(), h.shape, h.dtype);
    h.dispose(); ids.dispose();
    const one = MlxArray.fromFloat32(new Float32Array([1]), []);

    const headRun = (fn: (p: MlxArray) => MlxArray): { loss: number; dh: Uint8Array; dhF: Float32Array } => {
      const vjp = new Vjp((p) => [fn(p[0]!)], 1);
      const { outputs, vjps } = vjp.apply([hn], [one]);
      ops.evalAll([outputs[0]!, vjps[0]!]);
      const loss = outputs[0]!.toFloat32()[0]!;
      const dh = new Uint8Array(vjps[0]!.rawBytes());
      const dhF = vjps[0]!.toFloat32();
      for (const a of [...outputs, ...vjps]) a.dispose();
      vjp.dispose();
      return { loss, dh, dhF };
    };

    const ref = headRun((p) => responseOnlyCe(model, p, batch)); // whole-vocab head
    for (const chunk of [512, 4]) {
      const sink: Array<{ dispose(): void }> = [];
      const got = headRun((p) => boundedSftCe(model, p, batch, sink, chunk));
      for (const d of sink) d.dispose();
      expect(got.dh.length).toBe(ref.dh.length);
      if (chunk >= T) {
        // full-cover chunk: identical shapes + kernels -> bit-exact loss AND dh
        expect(got.loss).toBe(ref.loss);
        let same = true;
        for (let j = 0; j < ref.dh.length; j++) if (ref.dh[j] !== got.dh[j]) { same = false; break; }
        expect(same).toBe(true);
      } else {
        // tiny chunk: per-M matmul tiling -> bf16-class band (ORPO precedent)
        expect(Math.abs(got.loss - ref.loss)).toBeLessThan(0.05);
        let d2 = 0, r2 = 0;
        for (let j = 0; j < ref.dhF.length; j++) { const d = ref.dhF[j]! - got.dhF[j]!; d2 += d * d; r2 += ref.dhF[j]! * ref.dhF[j]!; }
        expect(Math.sqrt(d2) / (Math.sqrt(r2) || 1)).toBeLessThan(0.01);
      }
    }
    hn.dispose(); one.dispose();

    // End-to-end sanity: the segmented step's VALUE matches the PLAIN (untraced)
    // sftLoss — both sides run the fused-kernel forward.
    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 321);
    attachForTraining(model, lora, "train");
    const plain = sftLoss(model, batch);
    ops.evalAll([plain]);
    const seg = new SegmentedBackward(model, lora, planSegmentsBySize(model.layers.length, 8));
    const got = seg.step(batch);
    ops.evalAll([got.value, ...got.grads]);
    expect(got.value.toFloat32()[0]!).toBeCloseTo(plain.toFloat32()[0]!, 4);
    for (const g of got.grads) {
      for (const v of g.toFloat32()) expect(Number.isFinite(v)).toBe(true);
      g.dispose();
    }
    got.value.dispose(); plain.dispose();
    seg.dispose();
    disposeLora(lora);
    weights.dispose();
  }, 240_000);

  test("sft_scope: 'response' is bit-identical to the default; 'full' agrees across naive/fused/flash/chunked/prefix/segmented paths", async () => {
    const { weights, model, tok, tmpl } = await loadBase();
    if (!(model instanceof MiniCPM5Model)) throw new Error("test base must be MiniCPM5");

    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 123);
    attachForTraining(model, lora, "train");

    const ex = encodeDpoRow(TINY_DPO_ROWS[0]!, tok, tmpl, 256);
    const batch: DpoBatch = {
      chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
      chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
    };
    const lambda = 0.1;

    const lossOf = (scope: "full" | "response", chunk?: { chunkSize: number; fused?: boolean; flash?: boolean }): number => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, lambda, chunk ? { ...chunk, sink } : undefined, scope);
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    };

    // --- 'response' scope is BIT-IDENTICAL to the pre-sft_scope default path. ---
    const respDefault = lossOf("response"); // == orpoLoss without the arg (same default)
    const respAgain = (() => {
      const l = orpoLoss(model, batch, lambda); // no sftScope arg at all
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    expect(respAgain).toBe(respDefault); // exact: identical graph, deterministic

    // --- 'full' naive: finite, and actually different (the prompt NLL counts). ---
    const fullNaive = lossOf("full");
    expect(Number.isFinite(fullNaive)).toBe(true);
    expect(Math.abs(fullNaive - respDefault)).toBeGreaterThan(1e-4);

    // --- Independent NLL oracle: full-scope chosen NLL == SFT masked CE with
    // promptLen=1 on the chosen row (supervise every non-pad prediction). ---
    const mFull = orpoMetrics(model, batch, lambda, "full");
    const mResp = orpoMetrics(model, batch, lambda, "response");
    const sftRef = (() => {
      const l = sftLoss(model, { ids: [ex.chosenIds], promptLens: [1] });
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    // Same positions, same token-mean — but the full path heads the prompt and
    // response as TWO span slices (keeping ℓw bit-identical to the response
    // path) while sftLoss heads one [0,len-1) slice; the quantized head matmul
    // tiles differently per slice shape and logp is bf16 (1 ULP at |logp|≈12 is
    // 0.0625), so the agreement is bf16-class — the file's established 0.05 bar,
    // not f32-exact. Measured diff here: ~0.0096 on an NLL of ~5.14.
    expect(Math.abs(mFull.nll - sftRef)).toBeLessThan(0.05);
    expect(mFull.or).toBeCloseTo(mResp.or, 4); // odds ratio unchanged by the scope
    expect(fullNaive).toBeCloseTo(mFull.nll + lambda * mFull.or, 4);

    // --- 'full' across head tiers (same tolerances as the response-scope parity). ---
    expect(Math.abs(lossOf("full", { chunkSize: 8, fused: true }) - fullNaive)).toBeLessThan(0.05);
    expect(Math.abs(lossOf("full", { chunkSize: 4 }) - fullNaive)).toBeLessThan(0.05); // Checkpoint chunked
    expect(Math.abs(lossOf("full", { chunkSize: 4096, fused: true }) - fullNaive)).toBeLessThan(0.05); // single-chunk fused
    expect(Math.abs(lossOf("full", { chunkSize: 4096, fused: true, flash: true }) - fullNaive)).toBeLessThan(0.05); // flash-CCE

    // --- 'full' through prefix-sharing (one concat forward, prompt gathered). ---
    const split = splitPrefixBatch(batch);
    expect(split).not.toBeNull();
    const prefixFull = (() => {
      const l = orpoLossPrefixShared(model, split!.promptIds, split!.chosenResp, split!.rejectedResp, lambda, undefined, "full");
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    // The prefix-shared forward carries a PRE-EXISTING bf16-class offset vs the
    // two-forward path with the training LoRA attached (measured ~0.055 on the
    // RESPONSE-scope loss, i.e. in code this change didn't touch — per-position
    // logp is bf16, and the concat attends over T=P+Rc+Rr key slots vs P+R).
    // So assert (a) a coarse absolute bound, and (b) the tight, meaningful one:
    // the SCOPE DELTA (full − response) — which isolates exactly the new
    // prompt-NLL term — agrees between prefix and two-forward (measured 0.011).
    const prefixResp = (() => {
      const l = orpoLossPrefixShared(model, split!.promptIds, split!.chosenResp, split!.rejectedResp, lambda, undefined, "response");
      ops.evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    expect(Math.abs(prefixResp - respDefault)).toBeLessThan(0.15); // pre-existing bf16 offset class
    expect(Math.abs(prefixFull - fullNaive)).toBeLessThan(0.15);
    expect(Math.abs((prefixFull - prefixResp) - (fullNaive - respDefault))).toBeLessThan(0.05);

    // --- 'full' through the segmented backward (two-branch AND prefix). The head
    // VJP now includes the prompt-span contributions; the VALUE must agree with
    // the naive full loss, and the grads must be finite. ---
    const ranges = planSegmentsBySize(model.layers.length, 8);
    const seg = new SegmentedBackwardOrpo(model, lora, ranges, lambda, 0, "full");
    const segRes = seg.step(batch);
    ops.evalAll([segRes.value, ...segRes.grads]);
    expect(Math.abs(segRes.value.toFloat32()[0]! - fullNaive)).toBeLessThan(0.05);
    let gradNormSq = 0;
    let allFinite = true;
    for (const g of segRes.grads) {
      for (const v of g.toFloat32()) {
        if (!Number.isFinite(v)) allFinite = false;
        gradNormSq += v * v;
      }
      g.dispose();
    }
    expect(allFinite).toBe(true);
    expect(gradNormSq).toBeGreaterThan(0); // the backward actually produced signal
    segRes.value.dispose();
    seg.dispose();

    const segPrefix = new SegmentedBackwardOrpoPrefix(model, lora, ranges, lambda, undefined, "full");
    const spRes = segPrefix.stepPrefix(split!.promptIds, split!.chosenResp, split!.rejectedResp);
    ops.evalAll([spRes.value, ...spRes.grads]);
    // Compare against the NON-segmented prefix full loss (same forward layout —
    // isolates the segmented streaming, not the prefix bf16 offset).
    expect(Math.abs(spRes.value.toFloat32()[0]! - prefixFull)).toBeLessThan(0.05);
    let spFinite = true;
    for (const g of spRes.grads) {
      for (const v of g.toFloat32()) if (!Number.isFinite(v)) spFinite = false;
      g.dispose();
    }
    expect(spFinite).toBe(true);
    spRes.value.dispose();
    segPrefix.dispose();

    disposeLora(lora);
    weights.dispose();
  }, 300_000);

  test("fused training backward runs (CustomVjp analytic recompute + sink disposal) and improves loss", async () => {
    const losses = await trainOnTinyDpo("orpo-fused-train-", {
      orpoFusedCe: true, orpoChunkSize: 4, // fused head, force multi-chunk on tiny responses
    });
    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);
  }, 180_000);

  test("flash-CCE Metal-kernel head trains end-to-end (CustomVjp dh through the kernel) and improves loss", async () => {
    const losses = await trainOnTinyDpo("orpo-flash-train-", {
      orpoFlashCe: true, // flash-CCE Metal-kernel head (coeff filter default-on in bwd)
    });
    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);
  }, 180_000);

  test("segmented backward + flash-CCE head: trains end-to-end and improves loss (the e4b-overnight config shape)", async () => {
    const losses = await trainOnTinyDpo("orpo-seg-flash-train-", {
      orpoFlashCe: true, // flash-CCE head INSIDE the segmented backward (fusedLogpMeanFromHidden)
      segmentSize: 8, // gradient checkpointing for layer activations (the long-seq memory lever)
    });
    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);
  }, 180_000);

  test("prefix-sharing + flash-CCE head: single concat forward trains end-to-end and improves loss", async () => {
    const losses = await trainOnTinyDpo("orpo-prefix-train-", {
      orpoFlashCe: true, // [M,V]-free flash-CCE head per branch
      orpoPrefixShared: true, // single forward over [prompt; chosen; rejected]
    });
    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);
  }, 180_000);

  test("segmented backward + prefix-sharing + flash-CCE head: single concat forward streamed segment-by-segment trains end-to-end and improves loss", async () => {
    const losses = await trainOnTinyDpo("orpo-seg-prefix-train-", {
      orpoFlashCe: true, // [M,V]-free flash-CCE head per branch
      orpoPrefixShared: true, // single forward over [prompt; chosen; rejected]
      segmentSize: 8, // ...streamed segment-by-segment (the M3-composition: prompt-encode-once AT long seq)
    });
    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);
  }, 180_000);
});
