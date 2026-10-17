/** CPU-side references and checks for probe-m1max-contract.ts, shared by the main thread and
 * its check workers (exhaustive sweeps are split across cores; GPU results are read in place
 * through their buffer address). Each reference implements the Lean definition named beside
 * it. No MLX import: workers only check. */
import { toArrayBuffer, type Pointer } from "bun:ffi";

export const hex = (n: number) => "0x" + (n >>> 0).toString(16).padStart(8, "0");
export class Clause {
  cases = 0; fails = 0; ex: string[] = []; info: string[] = [];
  constructor(readonly name: string) {}
  fail(msg: string) { this.fails++; if (this.ex.length < 6) this.ex.push(msg); }
}
export const clauses = new Map<string, Clause>();
export const clause = (name: string) => clauses.get(name) ?? (clauses.set(name, new Clause(name)), clauses.get(name)!);
export const passed = (c: Clause) => c.fails === 0 && c.cases > 0;
export function report(c: Clause) {
  console.log(`${passed(c) ? "PASS" : "FAIL"} ${c.name}: ${c.cases} cases, ${c.fails} failures` +
    (c.info.length ? `; ${c.info.join("; ")}` : ""));
  for (const e of c.ex) console.log(`    counterexample ${e}`);
}

export const F1 = new Float32Array(1), U1 = new Uint32Array(F1.buffer);
export const bitsOf = (v: number) => { F1[0] = v; return U1[0]!; };
export const valOf = (b: number) => { U1[0] = b; return F1[0]!; };
export const TINY = 2 ** -126;
export const isNaNBits = (b: number) => (b & 0x7fffffff) > 0x7f800000;
export const fmtF = (b: number) => `${hex(b)}(${valOf(b)})`;
export const sameF = (got: number, want: number) => got === want && (want !== 0 || 1 / got === 1 / want);
// Lean's Float32 has one NaN: Float32.ofBits maps every NaN word to 0x7fc00000. Words are
// compared with Lean values through this map.
export const canon = (b: number) => (isNaNBits(b) ? 0x7fc00000 : b >>> 0);

// FlushToZero.flush: a binary32 subnormal becomes the zero of its sign.
export const fl = (v: number) => (v !== 0 && v > -TINY && v < TINY ? (v < 0 ? -0 : 0) : v);
// FlushToZero.flushExact over a binary64 value `pre` whose binary32 rounding is the rounding of the
// exact result (pre exact, or within an innocuous double rounding, or round-to-odd): a nonzero
// exact result below 2^-126 is the zero of its sign, otherwise RNE.
export const flushBefore = (pre: number) => (pre !== 0 && pre > -TINY && pre < TINY ? (pre < 0 ? -0 : 0) : Math.fround(pre));

const D1 = new Float64Array(1), DU = new Uint32Array(D1.buffer);
// Round-to-odd binary64 of a*b+c for binary32 inputs: exact product, TwoSum, sticky bit.
// RN24(RO53(v)) = RN24(v) since 53 >= 24 + 2, and RO preserves the 2^-126 comparison.
export function fmaRO(a: number, b: number, c: number): number {
  const p = a * b; // exact: product of two binary32 values
  const s = p + c;
  const bb = s - p;
  const e = (p - (s - bb)) + (c - bb);
  if (e === 0 || !Number.isFinite(s)) return s;
  D1[0] = s;
  if ((DU[0]! & 1) === 0) {
    const away = (e > 0) === (s > 0);
    if (away) { if (DU[0] === 0xffffffff) { DU[0] = 0; DU[1] = DU[1]! + 1; } else DU[0] = DU[0]! + 1; }
    else { if (DU[0] === 0) { DU[0] = 0xffffffff; DU[1] = DU[1]! - 1; } else DU[0] = DU[0]! - 1; }
  }
  return D1[0]!;
}
// FlushToZero.add / mul / div / fma on finite inputs.
export const addRef = (a: number, b: number) => fl(Math.fround(fl(a) + fl(b)));
export const mulRef = (a: number, b: number) => flushBefore(fl(a) * fl(b));
export const divRef = (a: number, b: number) => flushBefore(fl(a) / fl(b));
export const fmaRef = (a: number, b: number, c: number) => flushBefore(fmaRO(fl(a), fl(b), fl(c)));
// FlushToZero.add on words with FloatLib NaN rules: any NaN operand or invalid sum is 0x7fc00000.
export function addBits(x: number, y: number): number {
  if (isNaNBits(x) || isNaNBits(y)) return 0x7fc00000;
  const v = addRef(valOf(x), valOf(y));
  return Number.isNaN(v) ? 0x7fc00000 : bitsOf(v);
}
// Maximum.less / Maximum.value: compare flushed values (unordered is not less), keep the left
// word unless the right one is strictly greater.
export const maxLess = (l: number, r: number) => fl(valOf(l)) < fl(valOf(r));
export const maxValue = (l: number, r: number) => (maxLess(l, r) ? r : l);

// bfloat16. BFloat16.narrow: RNE with gradual underflow; BFloat16.widen: exact (= bits << 16).
export const bf16Rne = (b: number) => isNaNBits(b) ? ((b >>> 16) | 0x40) : ((b + 0x7fff + ((b >>> 16) & 1)) >>> 16);
export const bfVal = (h: number) => valOf((h & 0xffff) << 16);
export const BV = new Float64Array(65536), BVF = new Float64Array(65536);
for (let h = 0; h < 65536; h++) { BV[h] = bfVal(h); BVF[h] = fl(BV[h]!); }
export const bfFlush = (h: number) => ((h & 0x7f80) === 0 && (h & 0x7f) ? h & 0x8000 : h);
// FloatLib invalid results are the canonical NaN 0x7fc0.
export const bfFromF32 = (v: number) => (Number.isNaN(v) ? 0x7fc0 : bfFlush(bf16Rne(bitsOf(v))));
// BFloat16Arithmetic.add/sub/mul/div (op 0 + 1 - 2 * 3 /) on finite inputs: flush inputs;
// add/sub round then flush; mul/div flush a nonzero exact result below 2^-126, else round.
// fround(f64 op) is RN24 of the exact result (53 >= 2*24+2) and RN8(RN24(x)) = RN8(x) (24 >= 2*8+2).
export function bfModel(op: number, a: number, b: number): number {
  const x = BVF[a]!, y = BVF[b]!;
  const pre = op === 0 ? x + y : op === 1 ? x - y : op === 2 ? x * y : x / y;
  if (op >= 2 && pre !== 0 && pre > -TINY && pre < TINY) return pre < 0 ? 0x8000 : 0;
  return bfFromF32(Math.fround(pre));
}
export const BF_OPS = ["bfadd_model", "bfsub_model", "bfmul_model", "bfdiv_model"] as const;
const BF_SYM = ["+", "-", "*", "/"];

export type UnaryName = "rsqrt" | "exp" | "fastExp" | "exp2" | "log" | "fastLog" | "fastSin" | "fastCos" | "fabs" | "fastFabs" | "narrow";
export const newStat = () => ({ rsqrtMax: 0, rsqrtMin: Infinity, fexpMaxNonpos: 0, expMaxSmall: 0, logMaxAbs: 0, flogMin: Infinity,
  flogMax: -Infinity, sinMax: 0, cosMax: 0 });
export type Stat = ReturnType<typeof newStat>;
export function mergeStat(into: Stat, s: Stat) {
  into.rsqrtMax = Math.max(into.rsqrtMax, s.rsqrtMax); into.rsqrtMin = Math.min(into.rsqrtMin, s.rsqrtMin);
  into.fexpMaxNonpos = Math.max(into.fexpMaxNonpos, s.fexpMaxNonpos); into.expMaxSmall = Math.max(into.expMaxSmall, s.expMaxSmall);
  into.logMaxAbs = Math.max(into.logMaxAbs, s.logMaxAbs); into.flogMin = Math.min(into.flogMin, s.flogMin);
  into.flogMax = Math.max(into.flogMax, s.flogMax); into.sinMax = Math.max(into.sinMax, s.sinMax); into.cosMax = Math.max(into.cosMax, s.cosMax);
}

// One unary family over inputs base+lo .. base+hi-1; rb holds the outputs for the whole chunk.
// `real` in the Lean clauses is the exact value, which a binary64 holds for every binary32.
function checkUnary(n: UnaryName, base: number, lo: number, hi: number, rb: Uint32Array, stat: Stat) {
  const r = new Float32Array(rb.buffer, rb.byteOffset, rb.length);
  const xsU = new Uint32Array(hi - lo), xsF = new Float32Array(xsU.buffer);
  for (let i = 0; i < hi - lo; i++) xsU[i] = (base + lo + i) >>> 0;
  const at = (i: number, what: string) => `${what}: x=${fmtF(xsU[i - lo]!)} -> ${fmtF(rb[i]!)}`;
  const X = (i: number) => xsF[i - lo]!;
  const finite = (v: number) => v - v === 0;
  if (n === "rsqrt") { // NormalEnvelope rsqrt (17/16): finite x > 2^-126
    const c = clause("rsqrt_normal");
    let cases = 0, mx = stat.rsqrtMax, mn = stat.rsqrtMin;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x > TINY) || x === Infinity) continue;
      cases++;
      const y = r[i]!;
      if (!finite(y)) { c.fail(at(i, "not finite")); continue; }
      const pr = Math.abs(y) * Math.sqrt(x);
      if (pr > mx) mx = pr; if (pr < mn) mn = pr;
      if (!(pr <= 17 / 16)) c.fail(at(i, `|r|*sqrt(x)=${pr}`));
    }
    c.cases += cases; stat.rsqrtMax = mx; stat.rsqrtMin = mn;
    return;
  }
  if (n === "exp" || n === "fastExp") {
    const cnp = clause(`${n}_nonpositive`), cz = clause(`${n}_zero`), cnn = clause(`${n}_nonnegative`), co = clause(`${n}_overflow`);
    const cs = clause("exp_small"), small = n === "exp";
    let nNp = 0, nZ = 0, nNn = 0, nO = 0, nS = 0, mNp = stat.fexpMaxNonpos, mS = stat.expMaxSmall;
    for (let i = lo; i < hi; i++) {
      const x = X(i), y = r[i]!;
      if (n === "fastExp" && xsU[i - lo] === 0xff800000) {
        const c = clause("fastExp_negInf"); c.cases++; if (!(finite(y) && y === 0)) c.fail(at(i, "not finite with value 0"));
      }
      if (!finite(x)) continue;
      const fin = finite(y);
      nO++; if (!fin && rb[i] !== 0x7f800000) co.fail(at(i, "neither finite nor +inf"));
      if (fin) { nNn++; if (!(y >= 0)) cnn.fail(at(i, "negative")); }
      if (x <= 0) {
        nNp++;
        if (!(fin && y >= 0 && y <= 1)) cnp.fail(at(i, "not finite in [0,1]"));
        if (y > mNp) mNp = y;
      }
      if (x === 0) { nZ++; if (y !== 1) cz.fail(at(i, "not 1")); }
      if (small && x <= 8 && x >= -8) {
        nS++; if (!(fin && y <= 4096)) cs.fail(at(i, "not finite or > 2^12"));
        if (y > mS) mS = y;
      }
    }
    cnp.cases += nNp; cz.cases += nZ; cnn.cases += nNn; co.cases += nO; if (small) cs.cases += nS;
    if (n === "fastExp") stat.fexpMaxNonpos = mNp; else stat.expMaxSmall = mS;
    return;
  }
  if (n === "exp2") {
    const c = clause("exp2_nonpositive"); let k = 0;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x <= 0) || x === -Infinity) continue;
      k++; const y = r[i]!; if (!(finite(y) && y >= 0 && y <= 1)) c.fail(at(i, "not finite in [0,1]"));
    }
    c.cases += k; return;
  }
  if (n === "log") {
    const c = clause("log_bounded"); let k = 0, m = stat.logMaxAbs;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x >= 1 && x <= 262144)) continue;
      k++; const y = r[i]!, a = Math.abs(y);
      if (!(finite(y) && a <= 32)) c.fail(at(i, "not finite or |log|>32"));
      if (a > m) m = a;
    }
    c.cases += k; stat.logMaxAbs = m; return;
  }
  if (n === "fastLog") {
    const c = clause("fastLog_unit"); let k = 0, mn = stat.flogMin, mx = stat.flogMax;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x >= 1 && x <= 2)) continue;
      k++; const y = r[i]!;
      if (!(finite(y) && y >= 0 && y <= 1)) c.fail(at(i, "not finite in [0,1]"));
      if (y < mn) mn = y; if (y > mx) mx = y;
    }
    c.cases += k; stat.flogMin = mn; stat.flogMax = mx; return;
  }
  if (n === "fastSin" || n === "fastCos") {
    const c = clause(`${n}_bounded`); let k = 0, m = n === "fastSin" ? stat.sinMax : stat.cosMax;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x <= 262144 && x >= -262144)) continue;
      k++; const y = r[i]!, a = Math.abs(y);
      if (!(finite(y) && a <= 2)) c.fail(at(i, "not finite or |y|>2"));
      if (a > m) m = a;
    }
    c.cases += k; if (n === "fastSin") stat.sinMax = m; else stat.cosMax = m; return;
  }
  if (n === "fabs" || n === "fastFabs") { // finite result with real value |x|
    const c = clause(`${n}_value`); let k = 0;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!finite(x)) continue;
      k++; const y = r[i]!; if (!(finite(y) && y === Math.abs(x))) c.fail(at(i, "not |x|"));
    }
    c.cases += k; return;
  }
  if (n === "narrow") { // narrow_model: finite x -> BFloat16.narrow x bitwise
    const c = clause("narrow_model"); let k = 0;
    for (let i = lo; i < hi; i++) {
      const xb = xsU[i - lo]!; if ((xb & 0x7f800000) === 0x7f800000) continue;
      k++; const w = (xb + 0x7fff + ((xb >>> 16) & 1)) >>> 16; if (rb[i] !== w) c.fail(at(i, `want ${hex(w)}`));
    }
    c.cases += k;
  }
}

// Native bf16 op over rows a0+ra (ra in [lo, hi)) x all 65536 b; r[ra*65536 + b] holds the result bits.
function checkBf16Op(oi: number, a0: number, lo: number, hi: number, r: Uint32Array) {
  const c = clause(BF_OPS[oi]!), sym = BF_SYM[oi]!;
  let k = 0;
  for (let ra = lo; ra < hi; ra++) {
    const a = a0 + ra; if (!Number.isFinite(BV[a]!)) continue;
    const base = ra * 65536;
    for (let b = 0; b < 65536; b++) {
      if (!Number.isFinite(BV[b]!)) continue;
      k++;
      const got = r[base + b]!, want = bfModel(oi, a, b);
      if (got !== want) c.fail(`${hex(a)} ${sym} ${hex(b)} -> ${hex(got)} want ${hex(want)}`);
    }
  }
  c.cases += k;
}

// fmax_value on all finite bf16-valued binary32 pairs; r[2*(ra*65536+b)+q] holds fast (q=0) and precise (q=1).
export const FMAX_OPS = ["air.fast_fmax.f32", "air.fmax.f32"] as const;
function checkFmaxBf16(a0: number, lo: number, hi: number, r: Uint32Array) {
  const c = clause("fmax_value");
  let k = 0;
  for (let ra = lo; ra < hi; ra++) {
    const a = a0 + ra; if (!Number.isFinite(BV[a]!)) continue;
    const xb = (a << 16) >>> 0;
    for (let b = 0; b < 65536; b++) {
      if (!Number.isFinite(BV[b]!)) continue;
      const yb = (b << 16) >>> 0, o2 = 2 * (ra * 65536 + b), want = maxLess(yb, xb) ? xb : yb;
      for (let q = 0; q < 2; q++) {
        k++;
        if (r[o2 + q] !== want) c.fail(`${FMAX_OPS[q]} ${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(r[o2 + q]!)} want ${fmtF(want)}`);
      }
    }
  }
  c.cases += k;
}

// ------------------------------------------------------------ worker protocol
export type Task =
  | { kind: "unary"; n: UnaryName; base: number; lo: number; hi: number; ptr: number; words: number }
  | { kind: "bf16op"; oi: number; a0: number; lo: number; hi: number; ptr: number; words: number }
  | { kind: "fmaxbf16"; a0: number; lo: number; hi: number; ptr: number; words: number };
export type Result = { clauses: { name: string; cases: number; fails: number; ex: string[] }[]; stat: Stat };

function runTask(t: Task): Result {
  clauses.clear();
  const view = new Uint32Array(toArrayBuffer(t.ptr as Pointer, 0, t.words * 4));
  const stat = newStat();
  if (t.kind === "unary") checkUnary(t.n, t.base, t.lo, t.hi, view, stat);
  else if (t.kind === "bf16op") checkBf16Op(t.oi, t.a0, t.lo, t.hi, view);
  else checkFmaxBf16(t.a0, t.lo, t.hi, view);
  return { clauses: [...clauses.values()].map(c => ({ name: c.name, cases: c.cases, fails: c.fails, ex: c.ex })), stat };
}

declare const self: Worker;
if (!Bun.isMainThread) self.onmessage = (e: MessageEvent<Task>) => self.postMessage(runTask(e.data));

export class Pool {
  workers: Worker[];
  constructor(n: number) { this.workers = [...Array(n)].map(() => new Worker(import.meta.path)); }
  /** Run tasks (at most one per worker at a time) and merge their clauses into this thread's registry. */
  async run(tasks: Task[], stat?: Stat) {
    const queue = [...tasks];
    await Promise.all(this.workers.map(async w => {
      for (let t = queue.shift(); t; t = queue.shift()) {
        const r = await new Promise<Result>(res => { w.onmessage = (e: MessageEvent<Result>) => res(e.data); w.postMessage(t); });
        for (const c of r.clauses) {
          const m = clause(c.name); m.cases += c.cases; m.fails += c.fails;
          for (const x of c.ex) if (m.ex.length < 6) m.ex.push(x);
        }
        if (stat) mergeStat(stat, r.stat);
      }
    }));
  }
  close() { for (const w of this.workers) w.terminate(); }
}
