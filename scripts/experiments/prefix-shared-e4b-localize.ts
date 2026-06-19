// Localize the e4b prefix-shared forward divergence with ON-DEVICE per-position
// rel (no large host readback). Three forwards, all compared at chosen-relevant
// positions against the chosen-only reference:
//   (a) chosen-only   : plain array-mask forward over [prompt; chosen]
//   (b) concat-plain   : plain array-mask forward over [prompt; chosen; rejected]
//                        (NO prefix plan — normal offset-0 rope, normal causal
//                        mask; rejected just trails causally). Isolates "does a
//                        longer sequence alone change the chosen hiddens?"
//   (c) prefix         : block-wise rope + block-sparse mask (the real path)
// If (b)==(a) but (c)!=(a) → the divergence is the block-rope or block-mask.
// If (b)!=(a) → it is a plain length-dependent kernel effect, not our construction.

import { readdirSync } from "node:fs";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { Gemma4Model } from "../../src/model/gemma4";
import { setFusedGeluTraining } from "../../src/model/fused-geglu-kernel";
import { resolveRanks, DEFAULT_TARGET_MODULES } from "../../src/train/rank";
import { buildTrainableLora, attachForTraining } from "../../src/train/lora-params";
import { prefixForwardHiddenGemma } from "../../src/train/prefix-shared";
import { createCausalMask, type Cache, type Mask } from "../../src/model/gemma4-base";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";

const HOME = process.env.HOME!;
const base = `${HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots`;
const MODEL = process.env.MODEL ?? `${base}/${readdirSync(base)[0]}`;
const P = Number(process.env.P ?? 200);
const RC = Number(process.env.RC ?? 64);
const RR = Number(process.env.RR ?? 80);
if (process.env.FUSED_GELU !== "0") setFusedGeluTraining(true);

const config = await loadModelConfig(MODEL);
const weights = await Weights.open(MODEL);
const model = createModel(weights, config);
if (!(model instanceof Gemma4Model)) throw new Error("expected Gemma4Model");
const numDonors = model.numDonors; // capture where the instanceof narrowing holds (lost inside closures)
const ranks = resolveRanks(model, { rank: 8, rankScaling: "by_bits", targetModules: [...DEFAULT_TARGET_MODULES], numLayers: -1 });
const lora = buildTrainableLora(model, ranks, 1.0, 0);
attachForTraining(model, lora, "train");

const promptIds = Array.from({ length: P }, (_, i) => ((i * 13 + 5) % 4000) + 1);
const chosenResp = Array.from({ length: RC }, (_, i) => ((i * 7 + 11) % 4000) + 1);
const rejectedResp = Array.from({ length: RR }, (_, i) => ((i * 17 + 3) % 4000) + 1);

class ArrayMaskCache implements Cache {
  offset = 0;
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return [k.slice([0, 0, 0, 0], k.shape), v.slice([0, 0, 0, 0], v.shape)]; }
  makeMask(N: number, w: number | null): Mask { return { mode: "array", arr: createCausalMask(N, 0, w) }; }
  state(): MlxArray[] { return []; }
  isTrimmable(): boolean { return true; }
  trim(): void {}
  dispose(): void {}
}
function plainHidden(ids: number[]): MlxArray {
  const a = MlxArray.fromInt32(new Int32Array(ids), [1, ids.length]);
  const caches: Cache[] = Array.from({ length: numDonors }, () => new ArrayMaskCache());
  const h = model.forwardHidden(a, caches);
  a.dispose(); for (const c of caches) c.dispose();
  return h;
}

// on-device rel of row `i` of hA[1,*,H] vs row `i` of hB[1,*,H]
function relAt(hRef: MlxArray, hCmp: MlxArray, i: number): number {
  const H = hRef.shape[2]!;
  const ra = hRef.slice([0, i, 0], [1, i + 1, H]);
  const rb = hCmp.slice([0, i, 0], [1, i + 1, H]);
  const d = ops.sub(ra, rb);
  const d2 = ops.sumAxis(ops.mul(d, d), 2, false);
  const r2 = ops.sumAxis(ops.mul(ra, ra), 2, false);
  const dv = ops.contiguous(d2).toFloat32()[0]!;
  const rv = ops.contiguous(r2).toFloat32()[0]!;
  for (const x of [ra, rb, d, d2, r2]) x.dispose();
  return Math.sqrt(dv) / (Math.sqrt(rv) || 1);
}

const hChosen = plainHidden([...promptIds, ...chosenResp]); // (a) [1, P+Rc, H]
const hConcat = plainHidden([...promptIds, ...chosenResp, ...rejectedResp]); // (b) [1, P+Rc+Rr, H]
const hPre = prefixForwardHiddenGemma(model, promptIds, chosenResp, rejectedResp); // (c) [1, P+Rc+Rr, H]

const probes = [0, Math.floor(P / 2), P - 1, P, P + Math.floor(RC / 2), P + RC - 1];
console.log(`### localize-ondevice  P=${P} Rc=${RC} Rr=${RR} window=${model.windowSize}`);
console.log(`### pos : (b)concat-plain-vs-chosen   (c)prefix-vs-chosen`);
for (const i of probes) {
  const b = relAt(hChosen, hConcat, i);
  const c = relAt(hChosen, hPre, i);
  const tag = i < P ? "prompt" : "chosen";
  console.log(`### ${String(i).padStart(4)} (${tag}): b=${(b * 100).toExponential(2)}%   c=${(c * 100).toExponential(2)}%`);
}
hChosen.dispose(); hConcat.dispose(); hPre.dispose(); weights.dispose();
