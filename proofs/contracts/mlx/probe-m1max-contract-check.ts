/** CPU-side checks for probe-m1max-contract.ts, shared by the main thread and its
 * check workers (exhaustive sweeps are split across cores; GPU results are read
 * in place through their buffer address). No MLX import: workers only check. */
import { toArrayBuffer, type Pointer } from "bun:ffi";

export const hex = (n: number) => "0x" + (n >>> 0).toString(16).padStart(8, "0");
export class Clause {
  cases = 0; fails = 0; ex: string[] = []; info: string[] = [];
  constructor(readonly name: string) {}
  fail(msg: string) { this.fails++; if (this.ex.length < 6) this.ex.push(msg); }
}
export const clauses = new Map<string, Clause>();
export const clause = (name: string) => clauses.get(name) ?? (clauses.set(name, new Clause(name)), clauses.get(name)!);
export function report(c: Clause) {
  console.log(`${c.fails ? "FAIL" : "PASS"} ${c.name}: ${c.cases} cases, ${c.fails} failures` +
    (c.info.length ? `; ${c.info.join("; ")}` : ""));
  for (const e of c.ex) console.log(`    counterexample ${e}`);
}

export const F1 = new Float32Array(1), U1 = new Uint32Array(F1.buffer);
export const bitsOf = (v: number) => { F1[0] = v; return U1[0]!; };
export const valOf = (b: number) => { U1[0] = b; return F1[0]!; };
export const TINY = 2 ** -126;
export const fl = (v: number) => (v !== 0 && v > -TINY && v < TINY ? (v < 0 ? -0 : 0) : v);
export const sameF = (got: number, want: number) => got === want && (want !== 0 || 1 / got === 1 / want);
export const isNaNBits = (b: number) => (b & 0x7fffffff) > 0x7f800000;
export const fmtF = (b: number) => `${hex(b)}(${valOf(b)})`;

export const bf16Rne = (b: number) => isNaNBits(b) ? ((b >>> 16) | 0x40) : ((b + 0x7fff + ((b >>> 16) & 1)) >>> 16);
export const bfVal = (h: number) => valOf((h & 0xffff) << 16);
export const BV = new Float64Array(65536), BVF = new Float64Array(65536);
for (let h = 0; h < 65536; h++) { BV[h] = bfVal(h); BVF[h] = fl(BV[h]!); }
export const bfFlush = (h: number) => ((h & 0x7f80) === 0 && (h & 0x7f) ? h & 0x8000 : h);
export const bfFromF32 = (v: number) => (Number.isNaN(v) ? 0x7fc0 : bfFlush(bf16Rne(bitsOf(v))));
// FloatLib cast of NaNs: quiet, keep sign, keep the numeric payload (below the quiet bit) when it fits.
export const nanPayload = (field: number, quietBit: number) => (field & quietBit ? field - quietBit : field);
export const leanNarrowNaN = (b: number) => { const pl = nanPayload(b & 0x7fffff, 0x400000); return ((b >>> 16) & 0x8000) | 0x7fc0 | (pl < 0x40 ? pl : 0); };
export const leanWidenNaN = (h: number) => ((((h & 0x8000) << 16) | 0x7fc00000 | nanPayload(h & 0x7f, 0x40)) >>> 0);

// Finite x, y. max keep-left = (x<y ? y : x), keep-right = (y<x ? x : y);
// min keep-left = (y<x ? y : x), keep-right = (x<y ? x : y). "Flushed" variants compare fl(x), fl(y)
// and still return the unflushed operand.
export class Policy {
  sel: Clause; left: Clause; right: Clause; leftF: Clause; rightF: Clause; zero = new Map<string, string>(); n = 0;
  constructor(readonly label: string, readonly isMax: number, scope: string) {
    this.sel = clause(`${label} selects an input with the extreme real value [${scope}]`);
    this.left = clause(`${label} = keep-left-on-tie policy bitwise [${scope}]`);
    this.right = clause(`${label} = keep-right-on-tie policy bitwise [${scope}]`);
    this.leftF = clause(`${label} = keep-left-on-tie, comparing flushed values, returning the unflushed operand [${scope}]`);
    this.rightF = clause(`${label} = keep-right-on-tie, comparing flushed values, returning the unflushed operand [${scope}]`);
  }
  check(xb: number, yb: number, x: number, y: number, rb: number, r: number) {
    this.n++;
    const ext = this.isMax ? (x < y ? y : x) : (y < x ? y : x);
    if (!((rb === xb || rb === yb) && r === ext)) this.sel.fail(`${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(rb)}`);
    const L = this.isMax ? (x < y ? yb : xb) : (y < x ? yb : xb), R = this.isMax ? (y < x ? xb : yb) : (x < y ? xb : yb);
    if (rb !== L) this.left.fail(`${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(rb)}`);
    if (rb !== R) this.right.fail(`${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(rb)}`);
    const fx = fl(x), fy = fl(y);
    const LF = this.isMax ? (fx < fy ? yb : xb) : (fy < fx ? yb : xb), RF = this.isMax ? (fy < fx ? xb : yb) : (fx < fy ? xb : yb);
    if (rb !== LF) this.leftF.fail(`${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(rb)}`);
    if (rb !== RF) this.rightF.fail(`${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(rb)}`);
    if (x === 0 && y === 0 && xb !== yb && this.zero.size < 4) this.zero.set(`(${hex(xb)},${hex(yb)})`, hex(rb));
  }
  sync() { for (const c of [this.sel, this.left, this.right, this.leftF, this.rightF]) { c.cases += this.n; } this.n = 0; }
  finish() {
    this.sync();
    this.left.info.push(`signed zeros: ${[...this.zero].map(([k, v]) => `${k}->${v}`).join(" ")}`);
    const verdict = !this.left.fails ? "left on tie = true" : !this.right.fails ? "left on tie = false"
      : !this.leftF.fails ? "left on tie = true, ties judged on flushed values"
      : !this.rightF.fails ? "left on tie = false, ties judged on flushed values" : "no tested policy";
    console.log(`policy ${this.label} [${this.sel.name.split("[")[1]}: ${verdict}`);
    for (const c of [this.sel, this.left, this.right, this.leftF, this.rightF]) report(c);
  }
}

export type UnaryName = "rsqrt" | "exp" | "fastExp" | "exp2" | "log" | "fastLog" | "fastSin" | "fastCos" | "fabs" | "fastFabs" | "bf16cast";
export const newStat = () => ({ rsqrtMax: 0, rsqrtMin: Infinity, fexpMaxNonpos: 0, expMaxSmall: 0, logMaxAbs: 0, flogMin: Infinity,
  flogMax: -Infinity, sinMax: 0, cosMax: 0, fabsKept: 0, fabsOther: 0, fabsEx: "", fastFabsKept: 0, fastFabsOther: 0, fastFabsEx: "",
  bfKept: 0, bfOther: 0, bfEx: "", bfLean: 0, bf7fff: 0 });
export type Stat = ReturnType<typeof newStat>;
export function mergeStat(into: Stat, s: Stat) {
  into.rsqrtMax = Math.max(into.rsqrtMax, s.rsqrtMax); into.rsqrtMin = Math.min(into.rsqrtMin, s.rsqrtMin);
  into.fexpMaxNonpos = Math.max(into.fexpMaxNonpos, s.fexpMaxNonpos); into.expMaxSmall = Math.max(into.expMaxSmall, s.expMaxSmall);
  into.logMaxAbs = Math.max(into.logMaxAbs, s.logMaxAbs); into.flogMin = Math.min(into.flogMin, s.flogMin);
  into.flogMax = Math.max(into.flogMax, s.flogMax); into.sinMax = Math.max(into.sinMax, s.sinMax); into.cosMax = Math.max(into.cosMax, s.cosMax);
  for (const k of ["fabsKept", "fabsOther", "fastFabsKept", "fastFabsOther", "bfKept", "bfOther", "bfLean", "bf7fff"] as const) into[k] += s[k];
  for (const k of ["fabsEx", "fastFabsEx", "bfEx"] as const) if (!into[k]) into[k] = s[k];
}

// One unary clause family over inputs base+lo .. base+hi-1; rb holds the outputs for the whole chunk.
function checkUnary(n: UnaryName, base: number, lo: number, hi: number, rb: Uint32Array, stat: Stat) {
  const r = new Float32Array(rb.buffer, rb.byteOffset, rb.length);
  const xsU = new Uint32Array(hi - lo), xsF = new Float32Array(xsU.buffer);
  for (let i = 0; i < hi - lo; i++) xsU[i] = (base + lo + i) >>> 0;
  const at = (i: number, what: string) => `${what}: x=${fmtF(xsU[i - lo]!)} -> ${fmtF(rb[i]!)}`;
  const X = (i: number) => xsF[i - lo]!;
  if (n === "rsqrt") {
    const cf = clause("rsqrt_normal.finite"), cb = clause("rsqrt_normal.bound");
    let cases = 0, mx = stat.rsqrtMax, mn = stat.rsqrtMin;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x > TINY) || x === Infinity) continue;
      cases++;
      const y = r[i]!;
      if (y - y !== 0) { cf.fail(at(i, "not finite")); cb.fail(at(i, "not finite")); continue; }
      const pr = Math.abs(y) * Math.sqrt(x);
      if (pr > mx) mx = pr; if (pr < mn) mn = pr;
      if (!(pr <= 17 / 16)) cb.fail(at(i, `|r|*sqrt(x)=${pr}`));
    }
    cf.cases += cases; cb.cases += cases; stat.rsqrtMax = mx; stat.rsqrtMin = mn;
    return;
  }
  if (n === "exp" || n === "fastExp") {
    const cnp = clause(`${n}_nonpositive`), cz = clause(`${n}_zero`), cnn = clause(`${n}_nonnegative`), co = clause(`${n}_overflow`);
    const cs = clause("exp_small"), small = n === "exp";
    let nNp = 0, nZ = 0, nNn = 0, nO = 0, nS = 0, mNp = stat.fexpMaxNonpos, mS = stat.expMaxSmall;
    for (let i = lo; i < hi; i++) {
      const x = X(i), y = r[i]!;
      if (n === "fastExp" && xsU[i - lo] === 0xff800000) {
        const c = clause("fastExp_negInf"); c.cases++; if (rb[i] !== 0) c.fail(at(i, "not +0"));
      }
      if (x - x !== 0) continue;
      const fin = y - y === 0;
      nO++; if (!fin && rb[i] !== 0x7f800000) co.fail(at(i, "neither finite nor +inf"));
      if (fin) { nNn++; if (!(y >= 0)) cnn.fail(at(i, "negative")); }
      if (x <= 0) {
        nNp++;
        if (!(fin && y >= 0 && y <= 1)) cnp.fail(at(i, "outside [0,1]"));
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
      k++; const y = r[i]!; if (!(y - y === 0 && y >= 0 && y <= 1)) c.fail(at(i, "outside [0,1]"));
    }
    c.cases += k; return;
  }
  if (n === "log") {
    const c = clause("log_bounded"); let k = 0, m = stat.logMaxAbs;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x >= 1 && x <= 262144)) continue;
      k++; const y = r[i]!, a = Math.abs(y);
      if (!(y - y === 0 && a <= 32)) c.fail(at(i, "not finite or |log|>32"));
      if (a > m) m = a;
    }
    c.cases += k; stat.logMaxAbs = m; return;
  }
  if (n === "fastLog") {
    const c = clause("fastLog_unit"); let k = 0, mn = stat.flogMin, mx = stat.flogMax;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x >= 1 && x <= 2)) continue;
      k++; const y = r[i]!;
      if (!(y - y === 0 && y >= 0 && y <= 1)) c.fail(at(i, "outside [0,1]"));
      if (y < mn) mn = y; if (y > mx) mx = y;
    }
    c.cases += k; stat.flogMin = mn; stat.flogMax = mx; return;
  }
  if (n === "fastSin" || n === "fastCos") {
    const c = clause(`${n}_bounded`); let k = 0, m = n === "fastSin" ? stat.sinMax : stat.cosMax;
    for (let i = lo; i < hi; i++) {
      const x = X(i); if (!(x <= 262144 && x >= -262144)) continue;
      k++; const y = r[i]!, a = Math.abs(y);
      if (!(y - y === 0 && a <= 2)) c.fail(at(i, "not finite or |y|>2"));
      if (a > m) m = a;
    }
    c.cases += k; if (n === "fastSin") stat.sinMax = m; else stat.cosMax = m; return;
  }
  if (n === "fabs" || n === "fastFabs") {
    const c = clause(`${n}_clearsSign (non-NaN)`); let k = 0, kept = 0, other = 0, ex = "";
    for (let i = lo; i < hi; i++) {
      const want = (xsU[i - lo]! & 0x7fffffff) >>> 0;
      if (want > 0x7f800000) { if (rb[i] === want) kept++; else { other++; if (!ex) ex = at(i, "NaN"); } continue; }
      k++; if (rb[i] !== want) c.fail(at(i, `want ${hex(want)}`));
    }
    c.cases += k;
    if (n === "fabs") { stat.fabsKept += kept; stat.fabsOther += other; stat.fabsEx ||= ex; }
    else { stat.fastFabsKept += kept; stat.fastFabsOther += other; stat.fastFabsEx ||= ex; }
    return;
  }
  if (n === "bf16cast") {
    const c = clause("bf16 narrow T(f) = BFloat16.narrow (RNE, gradual underflow) (non-NaN)"); let k = 0;
    for (let i = lo; i < hi; i++) {
      const xb = xsU[i - lo]!;
      if ((xb & 0x7fffffff) > 0x7f800000) {
        if (rb[i] === leanNarrowNaN(xb)) stat.bfLean++;
        if (rb[i] === 0x7fff) stat.bf7fff++;
        if (rb[i] === ((xb >>> 16) | 0x40)) stat.bfKept++; else { stat.bfOther++; if (!stat.bfEx) stat.bfEx = at(i, "NaN"); }
        continue;
      }
      k++; const w = (xb + 0x7fff + ((xb >>> 16) & 1)) >>> 16; if (rb[i] !== w) c.fail(at(i, `want ${hex(w)}`));
    }
    c.cases += k;
  }
}

// Native bf16 op over rows a0+ra (ra in [lo, hi)) x all 65536 b; r[ra*65536 + b] holds the result bits.
const BF_SYM = ["+", "-", "*", "/"];
function checkBf16Op(oi: number, name: string, a0: number, lo: number, hi: number, r: Uint32Array, nanPol: Record<string, number>) {
  const c = clause(`bf16 ${name} = BFloat16Arithmetic.${name} bitwise (all pairs with non-NaN model result)`);
  const cb = clause(`bf16 ${name} = flush-before-rounding model (|exact| < 2^-126 -> signed 0, else RNE) (non-NaN)`);
  const sym = BF_SYM[oi]!;
  let k = 0;
  const f1 = new Float32Array(1), u1 = new Uint32Array(f1.buffer);
  for (let ra = lo; ra < hi; ra++) {
    const a = a0 + ra, x = BVF[a]!, base = ra * 65536;
    for (let b = 0; b < 65536; b++) {
      const y = BVF[b]!;
      const pre = oi === 0 ? x + y : oi === 1 ? x - y : oi === 2 ? x * y : x / y;
      f1[0] = pre; const w = u1[0]!;
      const got = r[base + b]!;
      if ((w & 0x7fffffff) > 0x7f800000) {
        const key = !Number.isNaN(BV[got]!) ? "non-NaN" : (Number.isNaN(BV[a]!) && got === (a | 0x40)) ? "quieted x"
          : (Number.isNaN(BV[b]!) && got === (b | 0x40)) ? "quieted y" : hex(got);
        nanPol[key] = (nanPol[key] ?? 0) + 1;
        continue;
      }
      k++;
      const rn = (w + 0x7fff + ((w >>> 16) & 1)) >>> 16;
      const h = (rn & 0x7f80) === 0 && (rn & 0x7f) ? rn & 0x8000 : rn;
      if (got !== h) c.fail(`${hex(a)} ${sym} ${hex(b)} -> ${hex(got)} want ${hex(h)}`);
      const hb = pre !== 0 && pre > -TINY && pre < TINY ? (pre < 0 ? 0x8000 : 0) : rn;
      if (got !== hb) cb.fail(`${hex(a)} ${sym} ${hex(b)} -> ${hex(got)} want ${hex(hb)}`);
    }
  }
  c.cases += k; cb.cases += k;
}

export const BF_MM_LABELS = ["air.fast_fmax.f32", "air.fast_fmin.f32", "air.fmax.f32", "air.fmin.f32"] as const;
export const bfPolicies = () => BF_MM_LABELS.map((l, q) => new Policy(l, q % 2 === 0 ? 1 : 0, "all bf16-valued pairs"));
function checkBf16MinMax(a0: number, lo: number, hi: number, r: Uint32Array, pols: Policy[]) {
  const rf = new Float32Array(r.buffer, r.byteOffset, r.length);
  for (let ra = lo; ra < hi; ra++) {
    const a = a0 + ra, x = BV[a]!; if (x - x !== 0) continue;
    const xb = (a << 16) >>> 0;
    for (let b = 0; b < 65536; b++) {
      const y = BV[b]!; if (y - y !== 0) continue;
      const yb = (b << 16) >>> 0, o4 = 4 * (ra * 65536 + b);
      for (let q = 0; q < 4; q++) pols[q]!.check(xb, yb, x, y, r[o4 + q]!, rf[o4 + q]!);
    }
  }
}

// ------------------------------------------------------------ worker protocol
export type Task =
  | { kind: "unary"; n: UnaryName; base: number; lo: number; hi: number; ptr: number; words: number }
  | { kind: "bf16op"; oi: number; name: string; a0: number; lo: number; hi: number; ptr: number; words: number }
  | { kind: "bf16mm"; a0: number; lo: number; hi: number; ptr: number; words: number };
export type Result = { clauses: { name: string; cases: number; fails: number; ex: string[] }[]; stat: Stat;
  nanPol: Record<string, number>; zeros: [string, string][][] };

function runTask(t: Task): Result {
  clauses.clear();
  const view = new Uint32Array(toArrayBuffer(t.ptr as Pointer, 0, t.words * 4));
  const stat = newStat(), nanPol: Record<string, number> = {};
  let zeros: [string, string][][] = [];
  if (t.kind === "unary") checkUnary(t.n, t.base, t.lo, t.hi, view, stat);
  else if (t.kind === "bf16op") checkBf16Op(t.oi, t.name, t.a0, t.lo, t.hi, view, nanPol);
  else { const pols = bfPolicies(); checkBf16MinMax(t.a0, t.lo, t.hi, view, pols); for (const q of pols) q.sync(); zeros = pols.map(p => [...p.zero]); }
  return { clauses: [...clauses.values()].map(c => ({ name: c.name, cases: c.cases, fails: c.fails, ex: c.ex })), stat, nanPol, zeros };
}

declare const self: Worker;
if (!Bun.isMainThread) self.onmessage = (e: MessageEvent<Task>) => self.postMessage(runTask(e.data));

export class Pool {
  workers: Worker[];
  constructor(n: number) { this.workers = [...Array(n)].map(() => new Worker(import.meta.path)); }
  /** Run tasks (at most one per worker at a time) and merge their clauses into this thread's registry. */
  async run(tasks: Task[], stat?: Stat, nanPol?: Record<string, number>, pols?: Policy[]) {
    const queue = [...tasks];
    await Promise.all(this.workers.map(async w => {
      for (let t = queue.shift(); t; t = queue.shift()) {
        const r = await new Promise<Result>(res => { w.onmessage = (e: MessageEvent<Result>) => res(e.data); w.postMessage(t); });
        for (const c of r.clauses) {
          const m = clause(c.name); m.cases += c.cases; m.fails += c.fails;
          for (const x of c.ex) if (m.ex.length < 6) m.ex.push(x);
        }
        if (stat) mergeStat(stat, r.stat);
        if (nanPol) for (const [k, v] of Object.entries(r.nanPol)) nanPol[k] = (nanPol[k] ?? 0) + v;
        if (pols) r.zeros.forEach((z, q) => { for (const [k, v] of z) pols[q]!.zero.set(k, v); });
      }
    }));
  }
  close() { for (const w of this.workers) w.terminate(); }
}
