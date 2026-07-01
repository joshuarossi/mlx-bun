// CPU smoke for the faithful DFlash drafter: KV-injection forward, autograd
// step, inference, and the multi-layer data round-trip — no GPU model needed.

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { AdamW } from "../src/train/optimizer";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type TargetDims } from "../src/spec/dspark/module-dflash";
import { dsparkLoss, positionWeights } from "../src/spec/dspark/loss";
import { writeDflashShard, DflashShard, sampleDflashBatch, type DflashRecord } from "../src/spec/dspark/data-dflash";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const TMP = mkdtempSync(join(tmpdir(), "dflash-smoke-"));
let pass = 0, fail = 0;
const check = (n: string, c: boolean, d = "") => { c ? (pass++, console.log(`  ✓ ${n}`)) : (fail++, console.log(`  ✗ ${n} ${d}`)); };
function rng(seed: number) { let s = seed >>> 0 || 1; return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; }; }

const A = 3, G = 5, V = 64, H = 32, m = 3, dDraft = 32;
const cfg = { ...DEFAULT_DFLASH_CONFIG, gamma: G, dDraft, nLayers: 2, nHeads: 4, markovRank: 16, tapLayers: [1, 2, 3] };
const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };
const r = rng(7);

// stub model (only embed.scales.dtype, embed.encode, logitsFromHidden used)
const fakeEmbed = MlxArray.fromFloat32(new Float32Array(V * H).map(() => (r() - 0.5) * 0.1), [V, H]).eval();
const fakeHead = MlxArray.fromFloat32(new Float32Array(H * V).map(() => (r() - 0.5) * 0.1), [H, V]).eval();
const fakeScales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
const stub = {
  embed: { scales: fakeScales, encode: (ids: MlxArray) => ops.takeAxis(fakeEmbed, ids, 0) },
  logitsFromHidden: (h: MlxArray) => { const hf = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32); const o = ops.matmul(hf, fakeHead); if (hf !== h) hf.dispose(); return o; },
} as unknown as import("../src/model/gemma4").Gemma4Model;

console.log("faithful DFlash module");
{
  const d = DflashDrafter.initFromDims(dims, cfg, "smoke");
  const nParams = d.names.length;
  const w = positionWeights(G);
  const Lctx = 7;
  const mH = m * H;
  const hCtx = MlxArray.fromFloat32(new Float32Array(A * Lctx * mH).map(() => r()), [A, Lctx, mH]);
  // left-padded mask: first 2 cols pad on row 0, etc.
  const maskData = new Float32Array(A * Lctx).fill(1);
  for (let c = 0; c < 2; c++) maskData[c] = 0; // row 0 has 2 pads
  const ctxMask = MlxArray.fromFloat32(maskData, [A, Lctx]);
  const anchorIds = MlxArray.fromInt32(Int32Array.from({ length: A }, () => Math.floor(r() * V)), [A]);
  const anchorEmb = stub.embed.encode(anchorIds); anchorIds.dispose();
  const prevToks = MlxArray.fromInt32(new Int32Array(A * G).map(() => Math.floor(r() * V)), [A, G]);
  const xStar = MlxArray.fromInt32(new Int32Array(A * G).map(() => Math.floor(r() * V)), [A, G]);
  const tgtHidden = MlxArray.fromFloat32(new Float32Array(A * G * H).map(() => r()), [A, G, H]);
  const targetLogits = stub.logitsFromHidden(tgtHidden); tgtHidden.dispose();

  const out = d.forwardTrain(stub, hCtx, ctxMask, anchorEmb, prevToks);
  check("forwardTrain draftLogits [A,γ,V]", out.draftLogits.shape[0] === A && out.draftLogits.shape[1] === G && out.draftLogits.shape[2] === V, JSON.stringify(out.draftLogits.shape));
  check("forwardTrain conf [A,γ]", out.conf.shape[0] === A && out.conf.shape[1] === G);
  const cf = out.conf.toFloat32(); check("conf in (0,1)", cf.every((x) => x > 0 && x < 1));
  out.draftLogits.dispose(); out.conf.dispose();

  const vag = new ValueAndGrad((primals) => d.useParams(primals, () => {
    const o = d.forwardTrain(stub, hCtx, ctxMask, anchorEmb, prevToks);
    const { loss, ce, tv, conf } = dsparkLoss(o, targetLogits, xStar, G, w);
    o.draftLogits.dispose(); o.conf.dispose(); ce.dispose(); tv.dispose(); conf.dispose();
    return loss;
  }), Array.from({ length: nParams }, (_, i) => i));
  const { value, grads } = vag.apply(d.flatParams());
  check("grad-loss finite", Number.isFinite(value.toFloat32()[0]!));
  check("one grad per param", grads.length === nParams);
  check("grad shapes match", grads.every((g, i) => JSON.stringify(g.shape) === JSON.stringify(d.get(d.names[i]!).shape)));
  const wcGrad = grads.find((_, i) => d.names[i] === "W_c")!.toFloat32();
  check("W_c grad finite & nonzero", wcGrad.every(Number.isFinite) && wcGrad.some((x) => x !== 0));
  value.dispose();
  const before = d.get("W_c").toFloat32();
  const opt = new AdamW(d.flatParams(), { lr: 1e-2, weightDecay: 0 }, (i, p) => d.installParam(i, p));
  opt.step(grads); opt.evalState();
  check("AdamW moves W_c", before.some((v, i) => Math.abs(v - d.get("W_c").toFloat32()[i]!) > 1e-9));

  // inference: hCtx [1, Lctx, m*H]
  const hCtx1 = hCtx.slice([0, 0, 0], [1, Lctx, mH]);
  const blk = d.forwardInfer(stub, hCtx1, 3, G);
  check("forwardInfer γ tokens in-vocab", blk.tokens.length === G && blk.tokens.every((t) => t >= 0 && t < V));
  blk.draftLogits.dispose(); hCtx1.dispose();

  vag.dispose(); opt.dispose(); d.dispose(); w.dispose();
  hCtx.dispose(); ctxMask.dispose(); anchorEmb.dispose(); prevToks.dispose(); xStar.dispose(); targetLogits.dispose();
}

console.log("multi-layer data round-trip");
{
  const records: DflashRecord[] = [];
  for (let s = 0; s < 4; s++) {
    const L = 24 + s;
    const ids = Array.from({ length: L }, (_, i) => (s * 7 + i) % V);
    const hb = MlxArray.fromFloat32(new Float32Array(L * m * H).map(() => r()), [L, m * H]).astype(Dtype.bfloat16);
    const cont = ops.contiguous(hb); hb.dispose();
    records.push({ ids, respStart: 8, hiddenMlBf16: cont.rawBytes() }); cont.dispose();
  }
  const meta = writeDflashShard(TMP, 0, records, H, m, [1, 2, 3]);
  check("shard meta", meta.nSeq === 4 && meta.m === m);
  const shard = DflashShard.load(join(TMP, "shard_00000"));
  check("hidden_ml shape [Ltot, m*H]", shard.hiddenMl.shape[1] === m * H);
  const batch = sampleDflashBatch(shard, A, G, 16, rng(3));
  check("batch non-null", batch !== null);
  if (batch) {
    check("hCtx [A,maxCtx,m*H]", batch.hCtx.shape[0] === batch.size && batch.hCtx.shape[1] === 16 && batch.hCtx.shape[2] === m * H, JSON.stringify(batch.hCtx.shape));
    check("ctxMask [A,maxCtx]", batch.ctxMask.shape[0] === batch.size && batch.ctxMask.shape[1] === 16);
    check("targetHidden [A,γ,H]", batch.targetHidden.shape[1] === G && batch.targetHidden.shape[2] === H, JSON.stringify(batch.targetHidden.shape));
    check("blockToks length γ", batch.blockToks.every((b) => b.length === G));
    batch.hCtx.dispose(); batch.ctxMask.dispose(); batch.targetHidden.dispose();
  }
  shard.dispose();
}

fakeEmbed.dispose(); fakeHead.dispose(); fakeScales.dispose();
rmSync(TMP, { recursive: true, force: true });
console.log(`\n[dflash-smoke] ${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
