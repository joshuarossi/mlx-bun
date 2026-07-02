// curve-distinctness.ts — the per-step WITNESS for the curve sampler's distinctness claim.
//
// Theorem being demonstrated (the gap-ratio invariant): every member of the
// (temperature, top-p, top-k, min-p, top-nσ, ε/η) family produces
//   q_i ∝ exp(ℓ_i / T)  restricted to a rank-prefix survivor set S,
// so for any three surviving tokens a,b,c the LOG-GAP RATIO
//   R = (ln q_a − ln q_b) / (ln q_b − ln q_c) = (ℓ_a − ℓ_b) / (ℓ_b − ℓ_c)
// is INVARIANT — one global slope 1/T cannot set different sharpness in
// different probability regions. A monotone curve with region-dependent slope
// breaks R while preserving order, so its output distribution lies outside the
// whole family, for every (T, S).
//
// This probe makes that concrete on a real model. For ~20 real next-token
// distributions it constructs a WITNESS curve that (i) keeps the top-2 gap
// exactly as sharp as T=0.7 while (ii) doubling the total mass of the
// p ∈ [0.001, 0.02] band relative to its T=0.7 value, then exhaustively fits
// the best (T, survivor-prefix m) — a superset of every (T, top-p, top-k,
// min-p, top-nσ) combination, since all of those survivor sets are rank
// prefixes — and reports the irreducible total-variation gap.
//
// Then (directional, small-N) it generates continuations under a fixed global
// witness curve vs its best-matching (T, k) and reports output-level stats.
//
//   bun scripts/experiments/curve-distinctness.ts [--model MiniCPM5-1B-OptiQ-4bit]
//     [--positions-per-prompt 4] [--gen-n 30] [--gen-tokens 60] [--skip-text]
//
// GPU cost: one small cached model, a few hundred single-token forwards for the
// capture phase, ~10k for the text phase. No downloads, no servers.

import { loadTaskModel, type TaskModel } from "../../src/eval/runner";
import * as ops from "../../src/mlx/ops";
import {
  buildSpline, evalSpline, isMonotone, curveSecants,
  type CurveParams, type Spline,
} from "../../src/curve-sampler";

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const MODEL = opt("model", "MiniCPM5-1B-OptiQ-4bit");
const PER_PROMPT = Number(opt("positions-per-prompt", "4"));
const GEN_N = Number(opt("gen-n", "30"));
const GEN_TOKENS = Number(opt("gen-tokens", "60"));
const SKIP_TEXT = process.argv.includes("--skip-text");

const T_REF = 0.7;                    // the reference temperature the witness must stay as sharp as
const BAND_LO = Math.log(0.001);      // witness band: base p ∈ [0.001, 0.02]
const BAND_HI = Math.log(0.02);
const BAND_FACTOR = 2;                // lift the band's T_REF mass by this factor
const TAIL_SLOPE = 2.2;               // below the band: crush the deep tail (slope > 1)

const PROMPTS = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "advice", text: "My 14-year-old wants to start lifting weights. Is that safe, and how should they begin?" },
  { tag: "factual", text: "What is the capital of France, and roughly how many people live there?" },
  { tag: "continuation", text: "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'" },
  { tag: "brainstorm", text: "Give me three unusual uses for a paperclip." },
];

// ---------- deterministic RNG (probe-local; the shipped sampler's device RNG is not under test) ----------
function mulberry32(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// ---------- model I/O ----------
const tm: TaskModel = await loadTaskModel(MODEL);
const EOS = new Set(tm.config.eosTokenIds);
function promptIds(body: string): number[] {
  const templated = tm.template !== null;
  const text = templated
    ? tm.template!.render([{ role: "user", content: body }], { addGenerationPrompt: true, enableThinking: false })
    : body;
  return tm.tokenizer.encode(text, /* addSpecialTokens */ !templated);
}
/** Normalized next-token logprobs [V] after feeding `ids` through `cache`. */
function stepLogprobs(ids: number[], cache: ReturnType<TaskModel["model"]["makeCache"]>): Float32Array {
  const lg = tm.model.forward(ids, cache); // [1, L, V]
  const [, L, V] = lg.shape as [number, number, number];
  const last = lg.slice([0, L - 1, 0], [1, L, V]);
  const cont = ops.contiguous(last); // strided-readback safety (see SigLIP op-parity lesson)
  const f = cont.toFloat32();
  lg.dispose(); last.dispose(); cont.dispose();
  // log-softmax in JS (V ~73k, cheap; f64 accumulation)
  let mx = -Infinity;
  for (let i = 0; i < f.length; i++) if (f[i]! > mx) mx = f[i]!;
  let z = 0;
  for (let i = 0; i < f.length; i++) z += Math.exp(f[i]! - mx);
  const lse = mx + Math.log(z);
  for (let i = 0; i < f.length; i++) f[i] = f[i]! - lse;
  return f;
}

// ---------- distribution helpers (all in f64 over full V) ----------
function entropyNats(lp: Float32Array): number {
  let h = 0;
  for (let i = 0; i < lp.length; i++) { const p = Math.exp(lp[i]!); if (p > 1e-15) h -= p * lp[i]!; }
  return h;
}
/** softmax of arbitrary transformed scores (returns probs + keeps caller's ordering). */
function softmaxOf(scores: Float64Array): Float64Array {
  let mx = -Infinity;
  for (let i = 0; i < scores.length; i++) if (scores[i]! > mx) mx = scores[i]!;
  let z = 0;
  for (let i = 0; i < scores.length; i++) z += Math.exp(scores[i]! - mx);
  const out = new Float64Array(scores.length);
  for (let i = 0; i < scores.length; i++) out[i] = Math.exp(scores[i]! - mx) / z;
  return out;
}

// ---------- the per-position witness (piecewise-linear monotone map in log-prob space) ----------
interface Witness {
  headLo: number;      // head/band boundary (min(ln .02, ℓ2)) — slope is exactly 1/T_REF above it
  bandSlope: number;   // fitted slope on [BAND_LO, headLo)
  q: Float64Array;     // witness distribution over the SORTED-desc logprobs
  bandIdx: [number, number]; // sorted-index range [start, end) of band tokens
  bandMassRef: number; // band mass under plain T_REF
  bandMassW: number;   // band mass under the witness (≈ factor × ref)
  factor: number;      // achieved lift factor (BAND_FACTOR, or the fallback that was feasible)
  gapRef: number;      // (ℓ1−ℓ2)/T_REF
  gapW: number;        // witness top-2 gap (== gapRef by construction)
}
/** Piecewise-linear witness value at logprob x. */
function witnessMap(x: number, headLo: number, s: number): number {
  if (x >= headLo) return x / T_REF;
  const yHead = headLo / T_REF;
  if (x >= BAND_LO) return yHead - s * (headLo - x);
  const yBand = yHead - s * (headLo - BAND_LO);
  return yBand - TAIL_SLOPE * (BAND_LO - x);
}
function witnessDist(sorted: Float64Array, headLo: number, s: number): Float64Array {
  const t = new Float64Array(sorted.length);
  for (let i = 0; i < t.length; i++) t[i] = witnessMap(sorted[i]!, headLo, s);
  return softmaxOf(t);
}
function buildWitness(sorted: Float64Array): Witness | null {
  const l1 = sorted[0]!, l2 = sorted[1]!;
  const headLo = Math.min(BAND_HI, l2);
  // band = tokens with base p ∈ [.001, .02] strictly below the head boundary
  let bStart = -1, bEnd = -1;
  for (let i = 0; i < sorted.length; i++) {
    const x = sorted[i]!;
    if (x < headLo && x <= BAND_HI && x >= BAND_LO) { if (bStart < 0) bStart = i; bEnd = i + 1; }
    if (x < BAND_LO) break;
  }
  if (bStart < 0) return null; // band genuinely empty (near-deterministic position)
  const bandMass = (q: Float64Array): number => {
    let m = 0;
    for (let i = bStart; i < bEnd; i++) m += q[i]!;
    return m;
  };
  const ref = witnessDist(sorted, headLo, 1 / T_REF); // s = 1/T_REF head-slope everywhere above tail...
  // NOTE: with s = 1/T_REF the map is x/T_REF down to BAND_LO (pure temperature there); only the
  // deep tail differs (TAIL_SLOPE) — the band-mass reference is the T=0.7 value on the same tail
  // treatment, which is the conservative comparison (the fit family also gates the tail).
  const refMass = bandMass(ref);
  const maxMass = bandMass(witnessDist(sorted, headLo, 1e-4)); // fully lifted band
  // On flat (high-entropy) distributions the band already holds a lot of mass and 2× is
  // infeasible even at slope→0; fall back to the largest comfortably-achievable factor.
  let factor = BAND_FACTOR;
  const feasible = maxMass / refMass;
  if (feasible < factor) factor = Math.max(1.1, 1 + 0.9 * (feasible - 1));
  if (factor <= 1.05) return null; // no headroom at all
  const target = factor * refMass;
  // bisect s ∈ (0, 1/T_REF]: band mass is decreasing in s
  let lo = 1e-4, hi = 1 / T_REF;
  for (let it = 0; it < 60; it++) {
    const mid = 0.5 * (lo + hi);
    if (bandMass(witnessDist(sorted, headLo, mid)) >= target) lo = mid; else hi = mid;
  }
  const s = lo;
  const q = witnessDist(sorted, headLo, s);
  return {
    headLo, bandSlope: s, q, bandIdx: [bStart, bEnd],
    bandMassRef: refMass, bandMassW: bandMass(q), factor,
    gapRef: (l1 - l2) / T_REF,
    gapW: witnessMap(l1, headLo, s) - witnessMap(l2, headLo, s),
  };
}

// ---------- exhaustive (T, prefix-m) fit: superset of all (T, top-p, top-k, min-p, top-nσ) ----------
interface Fit { tv: number; T: number; m: number; tvFull: number; Tfull: number }
/** TV between witness q (sorted order) and softmax_{top-m}(ℓ/T). */
function tvAt(sorted: Float64Array, q: Float64Array, qSuffix: Float64Array, m: number, T: number): number {
  const top = sorted[0]!;
  let z = 0;
  for (let i = 0; i < m; i++) z += Math.exp((sorted[i]! - top) / T);
  let acc = 0;
  for (let i = 0; i < m; i++) acc += Math.abs(q[i]! - Math.exp((sorted[i]! - top) / T) / z);
  return 0.5 * (acc + qSuffix[m]!); // mass the truncation zeroes out
}
function fitBest(sorted: Float64Array, q: Float64Array): Fit {
  const V = sorted.length;
  const qSuffix = new Float64Array(V + 1); // qSuffix[m] = Σ_{i≥m} q_i
  for (let i = V - 1; i >= 0; i--) qSuffix[i] = qSuffix[i + 1]! + q[i]!;
  const ms: number[] = [];
  for (let m = 1; m <= 300; m++) ms.push(m);
  for (let m = 325; m <= 2000; m += 25) ms.push(m);
  let best: Fit = { tv: Infinity, T: NaN, m: 0, tvFull: Infinity, Tfull: NaN };
  for (let T = 0.05; T <= 3.0001; T += 0.01) {
    for (const m of ms) {
      const tv = tvAt(sorted, q, qSuffix, m, T);
      if (tv < best.tv) best = { ...best, tv, T, m };
    }
    const tvF = tvAt(sorted, q, qSuffix, V, T); // full support: k off, p = 1
    if (tvF < best.tvFull) { best.tvFull = tvF; best.Tfull = T; }
  }
  // local refine on T around the winner (grid 0.001) for the winning m and neighbors
  for (const m of [Math.max(1, best.m - 2), best.m - 1, best.m, best.m + 1, best.m + 2].filter((x) => x >= 1 && x <= V)) {
    for (let T = Math.max(0.02, best.T - 0.02); T <= best.T + 0.02; T += 0.001) {
      const tv = tvAt(sorted, q, qSuffix, m, T);
      if (tv < best.tv) best = { ...best, tv, T, m };
    }
  }
  return best;
}

// ---------- phase 1: capture real next-token distributions at diverse positions ----------
interface Position {
  tag: string; step: number; kind: string; context: string;
  sorted: Float64Array; entropy: number;
}
console.log(`# curve-distinctness — model "${MODEL}", T_ref=${T_REF}, band p∈[0.001,0.02] ×${BAND_FACTOR}`);
const CAPTURE_STEPS = 40;
const positions: Position[] = [];
for (const pr of PROMPTS) {
  const ids = promptIds(pr.text);
  const cache = tm.model.makeCache();
  const rng = mulberry32(0xC0FFEE ^ pr.tag.length);
  const perStep: { lp: Float32Array; tok: number; prevText: string }[] = [];
  let feed = ids;
  const genToks: number[] = [];
  for (let s = 0; s < CAPTURE_STEPS; s++) {
    const lp = stepLogprobs(feed, cache);
    // sample at T_REF (CDF walk over exp(lp/T))
    let mx = -Infinity;
    for (let i = 0; i < lp.length; i++) if (lp[i]! > mx) mx = lp[i]!;
    let z = 0;
    for (let i = 0; i < lp.length; i++) z += Math.exp((lp[i]! - mx) / T_REF);
    let u = rng() * z, tok = lp.length - 1;
    for (let i = 0; i < lp.length; i++) { u -= Math.exp((lp[i]! - mx) / T_REF); if (u <= 0) { tok = i; break; } }
    perStep.push({ lp, tok, prevText: tm.tokenizer.decode(genToks.slice(-6), true) });
    if (EOS.has(tok)) break;
    genToks.push(tok);
    feed = [tok];
  }
  for (const c of cache) c.dispose();
  // select positions: start, max-entropy (fork), min-entropy (locked), after-comma (else 2nd-max entropy)
  const H = perStep.map((s) => entropyNats(s.lp));
  const order = H.map((h, i) => i).sort((a, b) => H[b]! - H[a]!);
  const chosen = new Set<number>();
  const picks: { i: number; kind: string }[] = [];
  const add = (i: number | undefined, kind: string): void => {
    if (i === undefined || chosen.has(i)) return;
    chosen.add(i); picks.push({ i, kind });
  };
  add(0, "start");
  add(order[0], "max-H");
  add(order[order.length - 1], "min-H");
  const afterComma = perStep.findIndex((s, i) => i > 0 && s.prevText.trimEnd().endsWith(","));
  add(afterComma >= 0 ? afterComma : order[1], afterComma >= 0 ? "after-comma" : "2nd-max-H");
  for (let oi = 1; picks.length < PER_PROMPT && oi < order.length; oi++) add(order[oi], "extra-H");
  for (const p of picks.slice(0, PER_PROMPT)) {
    const st = perStep[p.i]!;
    const sorted = Float64Array.from(st.lp).sort((a, b) => b - a);
    positions.push({ tag: pr.tag, step: p.i, kind: p.kind, context: st.prevText.slice(-40), sorted, entropy: H[p.i]! });
  }
  console.log(`captured ${pr.tag}: ${perStep.length} steps, picked ${picks.slice(0, PER_PROMPT).map((p) => `${p.i}(${p.kind})`).join(" ")}`);
}

// ---------- phase 2: witness + fit per position ----------
console.log(`\n== per-position witness vs best (T, prefix-m) fit — m sweep covers ALL top-p/top-k/min-p/top-nσ survivor sets ==`);
console.log(`pos  tag           kind         H(nats)  p1     gap12   bandN  bandRef→W (×f)        slope_s  |  TV_min    T*     m*    TV_full(T)`);
const fitted: { pos: Position; w: Witness; fit: Fit; control: number }[] = [];
let skipped = 0;
for (let pi = 0; pi < positions.length; pi++) {
  const pos = positions[pi]!;
  const w = buildWitness(pos.sorted);
  if (!w) {
    skipped++;
    console.log(`${String(pi).padStart(3)}  ${pos.tag.padEnd(13)} ${pos.kind.padEnd(12)} ${pos.entropy.toFixed(2).padStart(6)}  — band empty / no lift headroom, skipped`);
    continue;
  }
  const fit = fitBest(pos.sorted, w.q);
  // control: the fitter must reproduce PLAIN temperature ~exactly (validates the fit machinery)
  const qT = witnessDist(pos.sorted, w.headLo, 1 / T_REF);
  const control = fitBest(pos.sorted, qT).tv;
  fitted.push({ pos, w, fit, control });
  const p1 = Math.exp(pos.sorted[0]!);
  console.log(
    `${String(pi).padStart(3)}  ${pos.tag.padEnd(13)} ${pos.kind.padEnd(12)} ${pos.entropy.toFixed(2).padStart(6)}  ${p1.toFixed(3)}  ${w.gapRef.toFixed(2).padStart(5)}  ${String(w.bandIdx[1] - w.bandIdx[0]).padStart(5)}  ${w.bandMassRef.toFixed(4)}→${w.bandMassW.toFixed(4)} (×${w.factor.toFixed(2)})  ${w.bandSlope.toFixed(3).padStart(6)}  |  ${fit.tv.toFixed(4)}  ${fit.T.toFixed(2).padStart(5)}  ${String(fit.m).padStart(5)}  ${fit.tvFull.toFixed(4)}(${fit.Tfull.toFixed(2)})`,
  );
}
if (fitted.length) {
  const tvs = fitted.map((f) => f.fit.tv).sort((a, b) => a - b);
  const mean = tvs.reduce((a, b) => a + b, 0) / tvs.length;
  const ctl = fitted.map((f) => f.control);
  console.log(`\nwitness positions: ${fitted.length} (skipped ${skipped} too-peaked)`);
  console.log(`irreducible TV gap: min ${tvs[0]!.toFixed(4)}  median ${tvs[Math.floor(tvs.length / 2)]!.toFixed(4)}  mean ${mean.toFixed(4)}  max ${tvs[tvs.length - 1]!.toFixed(4)}`);
  console.log(`fitter control (plain T=${T_REF} must be reproducible): max TV ${Math.max(...ctl).toFixed(5)}  (≈0 ⇒ the gap above is real, not fitter slack)`);
}

// ---------- phase 3 (directional): fixed global witness curve vs its best (T, k) — text level ----------
if (!SKIP_TEXT && fitted.length) {
  const sMed = fitted.map((f) => f.w.bandSlope).sort((a, b) => a - b)[Math.floor(fitted.length / 2)]!;
  // global curve in designer coordinates (x_pct/y_pct percent-probability, log-space):
  // head slope 1/T_REF on [2%,100%], band slope sMed on [0.1%,2%], tail slope TAIL_SLOPE below.
  const yAt = (xPct: number): number => 100 * Math.exp(witnessMapGlobal(Math.log(xPct / 100)));
  function witnessMapGlobal(x: number): number {
    return witnessMap(x, BAND_HI, sMed);
  }
  const XS = [1e-4, 0.005, 0.03, 0.1, 0.45, 2, 10, 40, 100]; // knots incl. collinear helpers per segment
  const curve: CurveParams = { space: "logprob", points: XS.map((x) => ({ x_pct: x, y_pct: yAt(x) })), monotonic: true };
  if (!isMonotone(curve)) throw new Error("global witness curve is not monotone — construction bug");
  const spline: Spline = buildSpline(curve);
  console.log(`\n== global witness curve (median band slope s=${sMed.toFixed(3)}) — paste into the designer ==`);
  console.log(JSON.stringify(curve));
  console.log(`secants top→bottom: ${curveSecants(curve).map((s) => s.toFixed(2)).join(" ")}`);

  // PCHIP realization vs analytic piecewise-linear witness + global (T,m) fit over captured positions
  const qOf = (sorted: Float64Array, f: (x: number) => number): Float64Array => {
    const t = new Float64Array(sorted.length);
    for (let i = 0; i < t.length; i++) t[i] = f(sorted[i]!);
    return softmaxOf(t);
  };
  let meanPchipTv = 0;
  const qCurves: Float64Array[] = [];
  for (const f of fitted) {
    const qp = qOf(f.pos.sorted, (x) => evalSpline(spline, x));
    const ql = qOf(f.pos.sorted, witnessMapGlobal);
    let tv = 0;
    for (let i = 0; i < qp.length; i++) tv += Math.abs(qp[i]! - ql[i]!);
    meanPchipTv += 0.5 * tv / fitted.length;
    qCurves.push(qp);
  }
  console.log(`PCHIP realization vs analytic piecewise-linear map: mean TV ${meanPchipTv.toFixed(4)} (the designer's spline realizes the witness)`);

  // global fit: one (T, m) minimizing MEAN TV across positions against the PCHIP-realized curve
  let gBest = { tv: Infinity, T: NaN, m: 0 };
  const suffixes = qCurves.map((q) => {
    const s = new Float64Array(q.length + 1);
    for (let i = q.length - 1; i >= 0; i--) s[i] = s[i + 1]! + q[i]!;
    return s;
  });
  const gms: number[] = [];
  for (let m = 1; m <= 300; m += 1) gms.push(m);
  for (let m = 325; m <= 2000; m += 25) gms.push(m);
  gms.push(qCurves[0]!.length);
  for (let T = 0.05; T <= 3.0001; T += 0.02) {
    for (const m of gms) {
      let mean = 0;
      for (let i = 0; i < fitted.length; i++) mean += tvAt(fitted[i]!.pos.sorted, qCurves[i]!, suffixes[i]!, m, T) / fitted.length;
      if (mean < gBest.tv) gBest = { tv: mean, T, m };
    }
  }
  console.log(`best global (T, k) match to the curve: T=${gBest.T.toFixed(2)} k=${gBest.m}  mean per-position TV ${gBest.tv.toFixed(4)}`);

  // --- generation: 3 prompts × GEN_N continuations per arm ---
  console.log(`\n== text-level (directional, N=${GEN_N}/arm/prompt, ${GEN_TOKENS} tok): curve arm vs fitted (T=${gBest.T.toFixed(2)}, k=${gBest.m}) ==`);
  const words = (s: string): string[] => s.toLowerCase().match(/[a-z0-9']+/g) ?? [];
  const distinctN = (outs: string[], n: number): number => {
    const g = new Set<string>();
    let total = 0;
    for (const o of outs) {
      const w = words(o);
      for (let i = 0; i + n <= w.length; i++) { g.add(w.slice(i, i + n).join(" ")); total++; }
    }
    return total ? g.size / total : 0;
  };
  const junkRatio = (s: string): number => {
    const L = s.match(/\p{L}/gu) ?? [];
    if (!L.length) return 0;
    return L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length;
  };

  type Arm = "curve" | "fit";
  function generateArm(pIds: number[], arm: Arm, seed: number): { text: string; meanLp: number; stepTv: number[] } {
    const cache = tm.model.makeCache();
    const rng = mulberry32(seed);
    const out: number[] = [];
    let feed = pIds, lpSum = 0;
    const stepTv: number[] = [];
    try {
      for (let s = 0; s < GEN_TOKENS; s++) {
        const lp = stepLogprobs(feed, cache);
        // fit distribution (needed by both: fit arm samples it; curve arm reports TV to it)
        const mx = ((): number => { let m = -Infinity; for (let i = 0; i < lp.length; i++) if (lp[i]! > m) m = lp[i]!; return m; })();
        // survivors = top-m: collect above a loose threshold, sort, cut
        const idx: number[] = [];
        for (let i = 0; i < lp.length; i++) if (lp[i]! > mx - 25) idx.push(i);
        idx.sort((a, b) => lp[b]! - lp[a]!);
        const surv = idx.slice(0, Math.min(gBest.m, idx.length));
        let zF = 0;
        for (const i of surv) zF += Math.exp((lp[i]! - mx) / gBest.T);
        let tok: number;
        if (arm === "fit") {
          let u = rng() * zF; tok = surv[surv.length - 1]!;
          for (const i of surv) { u -= Math.exp((lp[i]! - mx) / gBest.T); if (u <= 0) { tok = i; break; } }
        } else {
          // curve arm: transform every logprob through the PCHIP spline, softmax, sample
          const t = new Float64Array(lp.length);
          let tmx = -Infinity;
          for (let i = 0; i < lp.length; i++) { t[i] = evalSpline(spline, lp[i]!); if (t[i]! > tmx) tmx = t[i]!; }
          let zC = 0;
          for (let i = 0; i < lp.length; i++) zC += Math.exp(t[i]! - tmx);
          let u = rng() * zC; tok = lp.length - 1;
          for (let i = 0; i < lp.length; i++) { u -= Math.exp(t[i]! - tmx); if (u <= 0) { tok = i; break; } }
          // per-step TV between the curve distribution and the fitted (T,k) distribution
          let acc = 0, cMass = 0;
          for (const i of surv) {
            const qc = Math.exp(t[i]! - tmx) / zC;
            cMass += qc;
            acc += Math.abs(qc - Math.exp((lp[i]! - mx) / gBest.T) / zF);
          }
          stepTv.push(0.5 * (acc + (1 - cMass)));
        }
        lpSum += lp[tok]!;
        if (EOS.has(tok)) break;
        out.push(tok);
        feed = [tok];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    return { text: tm.tokenizer.decode(out, true), meanLp: out.length ? lpSum / out.length : 0, stepTv };
  }

  const TEXT_PROMPTS = PROMPTS.slice(0, 3);
  for (const pr of TEXT_PROMPTS) {
    const pIds = promptIds(pr.text);
    const res: Record<Arm, { texts: string[]; meanLp: number[]; tv: number[] }> = {
      curve: { texts: [], meanLp: [], tv: [] },
      fit: { texts: [], meanLp: [], tv: [] },
    };
    for (const arm of ["curve", "fit"] as Arm[]) {
      const seedBase = arm === "curve" ? 42000 : 52000; // disjoint seed bands, no cross-arm pairing
      for (let i = 0; i < GEN_N; i++) {
        const r = generateArm(pIds, arm, seedBase + i);
        res[arm].texts.push(r.text);
        res[arm].meanLp.push(r.meanLp);
        res[arm].tv.push(...r.stepTv);
      }
    }
    const mean = (a: number[]): number => (a.length ? a.reduce((x, y) => x + y, 0) / a.length : NaN);
    console.log(`\n[${pr.tag}]`);
    for (const arm of ["curve", "fit"] as Arm[]) {
      const t = res[arm].texts;
      const junk = mean(t.map(junkRatio));
      console.log(
        `  ${arm.padEnd(5)}  distinct-1/2/3 ${distinctN(t, 1).toFixed(3)}/${distinctN(t, 2).toFixed(3)}/${distinctN(t, 3).toFixed(3)}` +
        `  mean-logprob ${mean(res[arm].meanLp).toFixed(3)}  junk ${(junk * 100).toFixed(1)}%` +
        (arm === "curve" ? `  per-step TV vs fit: mean ${mean(res[arm].tv).toFixed(4)} max ${Math.max(...res[arm].tv).toFixed(4)}` : ""),
      );
    }
    console.log(`  sample curve: "${res.curve.texts[0]!.slice(0, 110).replace(/\n/g, " ")}"`);
    console.log(`  sample fit  : "${res.fit.texts[0]!.slice(0, 110).replace(/\n/g, " ")}"`);
  }
  console.log(`\n(directional only — the preregistered run is docs/planning/curve-sampler-research-plan.md)`);
}
