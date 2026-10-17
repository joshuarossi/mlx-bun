/** Checks every clause of M1MaxContract.lean `Contract` on this machine.
 * Unary f32 clauses are exhaustive over all 2^32 inputs; binary arithmetic is
 * structured plus >= 2^30 random cases per operation against exact flushed RNE
 * references; simd_sum/simd_max trees are identified and then replayed.
 *   MLX_BUN_LIBMLXC=/path/to/libmlxc.dylib bun proofs/contracts/mlx/probe-m1max-contract.ts \
 *     [--verify-lowering] [--quick]
 * The outer process re-executes itself under ~/mlx-bun-perf/gpu.sh (the machine GPU lock).
 * --verify-lowering loads the Metal tracer (MLX_BUN_KT_LIB, default
 * /tmp/kerneltrace/interpose/libkt.dylib) before MLX, serializes every runtime
 * library MLX compiles, disassembles it with `xcrun metal-objdump -d`, and fails
 * unless each probe kernel uses exactly the AIR operation its clause names.
 * --quick samples (1/16 of unary chunks, 1/64 of random counts) for smoke runs. */
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync } from "node:fs";

const argv = process.argv.slice(2);
if (!argv.includes("--under-gpu-lock")) {
  const child = Bun.spawn([
    join(homedir(), "mlx-bun-perf/gpu.sh"), process.execPath, import.meta.path, ...argv, "--under-gpu-lock",
  ], { stdout: "inherit", stderr: "inherit", stdin: "ignore" });
  const rc = await child.exited;
  if (rc === 75) console.error("probe: gpu.sh refused (training active or memory pressure); nothing ran.");
  process.exit(rc);
}
const VERIFY = argv.includes("--verify-lowering");
const QUICK = argv.includes("--quick");
const T0 = performance.now();
const sh = (cmd: string[]) => {
  const r = Bun.spawnSync(cmd);
  return r.exitCode === 0 ? r.stdout.toString().trim() : `(${cmd.join(" ")} failed)`;
};

// ---------------------------------------------------------------- environment
const chip = sh(["sysctl", "-n", "machdep.cpu.brand_string"]);
if (chip !== "Apple M1 Max") throw new Error(`Contract targets Apple M1 Max, found ${chip}`);
const plist = (p: string) => sh(["plutil", "-extract", "CFBundleVersion", "raw", p]);
console.log(`chip ${chip}; macOS ${sh(["sw_vers", "-productVersion"])} (${sh(["sw_vers", "-buildVersion"])}); ` +
  `AGXMetalG13X ${plist("/System/Library/Extensions/AGXMetalG13X.bundle/Contents/Info.plist")}; ` +
  `AGXCompilerCore ${plist("/System/Library/PrivateFrameworks/AGXCompilerCore.framework/Resources/Info.plist")}; ` +
  `offline ${sh(["xcrun", "metal", "--version"]).split("\n")[0]}`);

const KT_DIR = "/tmp/m1max-contract-lowering";
if (VERIFY) {
  const { dlopen, FFIType, ptr } = await import("bun:ffi");
  const lib = process.env.MLX_BUN_KT_LIB ?? "/tmp/kerneltrace/interpose/libkt.dylib";
  if (!existsSync(lib)) throw new Error(`--verify-lowering needs the Metal tracer dylib (${lib}); set MLX_BUN_KT_LIB`);
  rmSync(KT_DIR, { recursive: true, force: true });
  mkdirSync(KT_DIR, { recursive: true });
  const kt = dlopen(lib, { kt_init: { args: [FFIType.ptr], returns: FFIType.void } }).symbols;
  kt.kt_init(ptr(Buffer.from(KT_DIR + "\0")));
}

const { ptr } = await import("bun:ffi");
const { MlxArray } = await import("../../../packages/mlx/src/array.ts");
const { MetalKernel } = await import("../../../packages/mlx/src/metal-kernel.ts");
const { Dtype, clearCache } = await import("../../../packages/mlx/src/ffi.ts");
const ops = await import("../../../packages/mlx/src/ops.ts");
type Arr = InstanceType<typeof MlxArray>;

const { hex, clauses, clause, report, F1, U1, bitsOf, valOf, TINY, fl, sameF, isNaNBits, fmtF, bf16Rne, bfVal, BV, BVF,
  bfFromF32, bfFlush, leanWidenNaN, leanNarrowNaN, Policy, newStat, bfPolicies, Pool } = await import("./probe-m1max-contract-check.ts");
type Clause = InstanceType<typeof import("./probe-m1max-contract-check.ts").Clause>;
type UnaryName = import("./probe-m1max-contract-check.ts").UnaryName;
type Task = import("./probe-m1max-contract-check.ts").Task;
const section = (s: string) => console.log(`-- ${s} (${((performance.now() - T0) / 1000).toFixed(0)} s)`);
const WORKERS = Math.max(2, Number(sh(["sysctl", "-n", "hw.perflevel0.physicalcpu"])) || 8);
const pool = new Pool(WORKERS);
const addrOf = (a: Uint32Array) => Number(ptr(a));

const D1 = new Float64Array(1), DU = new Uint32Array(D1.buffer);
// Exact RNE fma for flushed binary32 inputs: exact product, TwoSum, round-to-odd to
// binary64, then RNE to binary32 (53 >= 24 + 2, so the second rounding is exact).
function fmaRO(a: number, b: number, c: number): number { // round-to-odd binary64 of a*b+c
  const p = a * b; // exact: 48-bit product of normal binary32 values
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
const fmaRef = (a: number, b: number, c: number) => Math.fround(fmaRO(a, b, c));
// Alternative flushing points, applied to a binary64 value 'pre' whose binary32 rounding is
// the correct rounding of the exact result (exact, or round-to-odd / innocuous double rounding):
// 'before' flushes when the exact result is below 2^-126 (tininess before rounding);
// 'unbounded' rounds to 24 bits with unbounded exponent, then flushes below 2^-126.
const flushBefore = (pre: number) => (pre !== 0 && pre > -TINY && pre < TINY ? (pre < 0 ? -0 : 0) : Math.fround(pre));
const flushUnbounded = (pre: number) => {
  const r = Math.abs(pre) >= 2 ** -100 ? Math.fround(pre) : Math.fround(pre * 2 ** 64) / 2 ** 64;
  return r !== 0 && r > -TINY && r < TINY ? (r < 0 ? -0 : 0) : r;
};
const addRef = (a: number, b: number) => fl(Math.fround(fl(a) + fl(b)));
const mulRef = (a: number, b: number) => fl(Math.fround(fl(a) * fl(b)));
const divRef = (a: number, b: number) => fl(Math.fround(fl(a) / fl(b)));
const fmaFlushRef = (a: number, b: number, c: number) => fl(fmaRef(fl(a), fl(b), fl(c)));

// Exact BigInt rational reference (self-test of the fast references).
type Q = { s: number; m: bigint; e: number }; // (-1)^s * m * 2^e
const toQ = (b: number): Q => {
  const ef = (b >>> 23) & 255, mf = b & 0x7fffff;
  return { s: b >>> 31, m: BigInt(ef ? mf | 0x800000 : mf), e: (ef ? ef : 1) - 150 };
};
const bl = (x: bigint) => x === 0n ? 0 : x.toString(2).length;
function roundQ(sign: number, num: bigint, den: bigint, P = 24): number { // num, den > 0; P-bit significand, binary32 exponent range
  let E = bl(num) - bl(den);
  const ge = (k: number) => (k >= 0 ? num >= den << BigInt(k) : num << BigInt(-k) >= den);
  if (!ge(E)) E--;
  let Ep = Math.max(E, -126);
  const sh = P - 1 - Ep;
  let n = sh >= 0 ? num << BigInt(sh) : num, d = sh >= 0 ? den : den << BigInt(-sh);
  let M = n / d; const r2 = (n % d) * 2n;
  if (r2 > d || (r2 === d && (M & 1n) === 1n)) M++;
  if (M === 1n << BigInt(P)) { M = 1n << BigInt(P - 1); Ep++; }
  if (Ep > 127) return sign ? -Infinity : Infinity;
  const v = Number(M) * 2 ** (Ep - P + 1);
  return sign ? -v : v;
}
function qRound(x: { s: number; m: bigint; e: number }, zeroSign: number, P = 24): number {
  if (x.m === 0n) return zeroSign ? -0 : 0;
  return x.e >= 0 ? roundQ(x.s, x.m << BigInt(x.e), 1n, P) : roundQ(x.s, x.m, 1n << BigInt(-x.e), P);
}
function qAdd(a: Q, b: Q): Q {
  const e = Math.min(a.e, b.e);
  const va = (a.s ? -1n : 1n) * (a.m << BigInt(a.e - e)), vb = (b.s ? -1n : 1n) * (b.m << BigInt(b.e - e));
  const v = va + vb;
  return { s: v < 0n ? 1 : 0, m: v < 0n ? -v : v, e };
}
const fq = (v: number) => toQ(bitsOf(fl(v)));
function exactAdd(x: number, y: number) {
  const a = fq(x), b = fq(y), r = qAdd(a, b);
  return fl(qRound(r, r.m === 0n && a.m === 0n && b.m === 0n ? a.s & b.s : 0));
}
function exactMul(x: number, y: number) {
  const a = fq(x), b = fq(y);
  return fl(qRound({ s: a.s ^ b.s, m: a.m * b.m, e: a.e + b.e }, a.s ^ b.s));
}
function exactDiv(x: number, y: number) {
  const a = fq(x), b = fq(y), s = a.s ^ b.s;
  if (a.m === 0n) return s ? -0 : 0;
  const e = a.e - b.e;
  return fl(e >= 0 ? roundQ(s, a.m << BigInt(e), b.m) : roundQ(s, a.m, b.m << BigInt(-e)));
}
function exactFma(x: number, y: number, z: number) {
  const a = fq(x), b = fq(y), c = fq(z);
  const p: Q = { s: a.s ^ b.s, m: a.m * b.m, e: a.e + b.e };
  const r = qAdd(p, c);
  return fl(qRound(r, r.m === 0n && p.m === 0n && c.m === 0n ? p.s & c.s : 0));
}

function bfFromF64(v: number): number { // direct RNE of a binary64 value to bf16 bits (subnormals kept)
  if (Number.isNaN(v)) return 0x7fc0;
  if (v === 0 || !Number.isFinite(v)) return bitsOf(v) >>> 16;
  const a = Math.abs(v);
  const e = Math.max(Math.floor(Math.log2(a)), -126);
  let E = e; if (2 ** E > a) E--; if (2 ** (E + 1) <= a) E++;
  E = Math.max(E, -126);
  const q = 2 ** (E - 7), x = a / q;
  let n = Math.floor(x); const d = x - n;
  if (d > 0.5 || (d === 0.5 && n % 2 === 1)) n++;
  const r = n * q;
  return (bitsOf(v < 0 ? -r : r) >>> 16) & 0xffff; // r >= 2^128 becomes inf through fround
}

// BFloat16Arithmetic.lean: flush subnormal inputs, exact op, RNE to bf16, flush subnormal result.
// fround(f64 op) is RN_24 of the exact result (53 >= 2*24+2) and RN_8(RN_24(x)) = RN_8(x) (24 >= 2*8+2).
const bfLean = (op: number, a: number, b: number) => { // op 0 + 1 - 2 * 3 /
  const x = BVF[a]!, y = BVF[b]!;
  return bfFromF32(Math.fround(op === 0 ? x + y : op === 1 ? x - y : op === 2 ? x * y : x / y));
};
function bfExact(op: number, a: number, b: number): number { // BigInt reference, finite inputs
  const qa = toQ(bitsOf(BVF[a]!)), qb = toQ(bitsOf(BVF[b]!));
  let v: number;
  if (op === 0 || op === 1) {
    const qb2 = op === 1 ? { ...qb, s: qb.s ^ 1 } : qb, r = qAdd(qa, qb2);
    v = qRound(r, r.m === 0n && qa.m === 0n && qb2.m === 0n ? qa.s & qb2.s : 0, 8);
  } else if (op === 2) v = qRound({ s: qa.s ^ qb.s, m: qa.m * qb.m, e: qa.e + qb.e }, qa.s ^ qb.s, 8);
  else {
    if (qb.m === 0n) return bfFromF32(BVF[a]! / BVF[b]!);
    const sg = qa.s ^ qb.s, e = qa.e - qb.e;
    v = qa.m === 0n ? (sg ? -0 : 0) : e >= 0 ? roundQ(sg, qa.m << BigInt(e), qb.m, 8) : roundQ(sg, qa.m, qb.m << BigInt(-e), 8);
  }
  return bfFlush(bitsOf(v) >>> 16);
}
// ---------------------------------------------------------------- kernels
const HASH = String.raw`
inline uint h32(uint x) { x ^= x >> 16; x *= 0x7feb352du; x ^= x >> 15; x *= 0x846ca68bu; x ^= x >> 16; return x; }
inline uint edgeMant(uint h) {
  switch (h & 15u) { case 0: return 0u; case 1: return 1u; case 2: return 2u; case 3: return 0x7fffffu;
    case 4: return 0x7ffffeu; case 5: return 0x400000u; case 6: return 0x3fffffu; case 7: return 0x400001u;
    default: return (h >> 4) & 0x7fffffu; } }
inline uint mant(uint h) { return (h & 1u) ? edgeMant(h >> 1) : ((h >> 1) & 0x7fffffu); }
inline uint mk(uint s, int e, uint m) { e = clamp(e, 0, 254); return (s << 31) | (uint(e) << 23) | (m & 0x7fffffu); }
constant uint EM[8] = {0u, 1u, 2u, 0x3fffffu, 0x400000u, 0x400001u, 0x7ffffeu, 0x7fffffu};
inline uint sv(uint k) { return ((k & 1u) << 31) | ((k >> 4) << 23) | EM[(k >> 1) & 7u]; }   // k < 4080
inline uint dv(uint k) { return k < 1008u ? (((127u + (k >> 3)) << 23) | EM[k & 7u]) : 0x7e800000u; } // k < 1009
constant int TE[20] = {0, 1, 2, 3, 23, 24, 25, 50, 63, 64, 100, 126, 127, 128, 150, 200, 230, 252, 253, 254};
constant uint TM[4] = {0u, 1u, 0x400000u, 0x7fffffu};
inline uint tv(uint k) { return ((k & 1u) << 31) | (uint(TE[k >> 3]) << 23) | TM[(k >> 1) & 3u]; } // k < 160
inline uint2 genPair(uint idx, uint seed, uint op) {
  uint h0 = h32(idx * 0x9e3779b9u ^ seed), h1 = h32(h0 ^ 0x85ebca6bu), h2 = h32(h1 + 0x68e31da4u);
  uint h3 = h32(h2 ^ 0xb5297a4du), h4 = h32(h3 + 0x1b56c4e9u), h5 = h32(h4 ^ 0x2545f491u);
  uint mode = h0 & 7u, sa = h4 >> 31, sb = (h4 >> 30) & 1u, ma = mant(h2), mb = mant(h5);
  int ea = int(h1 % 255u), eb = int(h3 % 255u);
  switch (mode) {
    case 0: case 1: break;
    case 2: case 3: eb = ea + int(h3 % 61u) - 30; break;
    case 4: ea = int(h1 % 6u); eb = ea + int(h3 % 7u) - 3; break;
    case 5: ea = 248 + int(h1 % 7u); eb = ea - int(h3 % 4u); break;
    case 6: if (op == 0u) { eb = ea; sb = sa ^ 1u; mb = ma ^ (h3 & 0xffu); } else eb = 128 - ea + int(h3 % 7u) - 3; break;
    default: if (op == 0u) { ea = 254; eb = 254 - int(h3 % 3u); sb = sa; } else eb = 381 - ea + int(h3 % 7u) - 3; break;
  }
  return uint2(mk(sa, ea, ma), mk(sb, eb, mb));
}
inline uint2 genDiv(uint idx, uint seed) {
  uint h0 = h32(idx * 0x9e3779b9u ^ seed), h1 = h32(h0 ^ 0x85ebca6bu), h2 = h32(h1 + 0x68e31da4u);
  uint h3 = h32(h2 ^ 0xb5297a4du), h4 = h32(h3 + 0x1b56c4e9u);
  uint mode = h0 & 7u, sel = (h0 >> 3) & 63u;
  int ey = 127 + int(h3 % 126u), ex = int(h1 % 255u);
  switch (mode) {
    case 4: ex = int(h1 % 6u); break;
    case 5: ex = 248 + int(h1 % 7u); break;
    case 6: ex = ey - 126 + int(h1 % 7u) - 3; break;
    case 7: ex = 254 - int(h1 % 4u); ey = 127 + int(h3 % 3u); break;
    default: break;
  }
  uint y = sel == 0u ? 0x7e800000u : sel == 1u ? 0x3f800000u : mk(0u, ey, mant(h4));
  return uint2(mk(h4 >> 31, ex, mant(h2)), y);
}
inline uint3 genFma(uint idx, uint seed) {
  uint2 ab = genPair(idx, seed, 1u);
  uint h5 = h32(idx * 0x2545f491u ^ seed ^ 0xdeadbeefu), h6 = h32(h5), h7 = h32(h6);
  uint pb = as_type<uint>(as_type<float>(ab.x) * as_type<float>(ab.y));
  int ep = int((pb >> 23) & 0xffu);
  uint cm = h5 & 3u, c;
  if (cm == 0u) c = mk(h6 >> 31, int(h6 % 255u), mant(h7));
  else if (cm == 1u) c = (pb ^ 0x80000000u) + (h6 % 17u) - 8u;
  else if (cm == 2u) c = mk(h6 >> 31, ep + int(h6 % 51u) - 25, mant(h7));
  else c = mk(h6 >> 31, int(h6 % 5u), mant(h7));
  if (((c >> 23) & 0xffu) == 0xffu) c = mk(h6 >> 31, int(h6 % 255u), mant(h7));
  return uint3(ab, c);
}
inline uint laneVal(uint vec, uint lane, uint seed, uint nonfinite) {
  uint hv = h32(vec * 0x9e3779b9u ^ seed), mode = hv & 7u;
  uint h = h32(hv ^ (lane * 0x85ebca6bu + 0x27d4eb2fu)), h2 = h32(h + 0x165667b1u);
  uint s = h >> 31, m = mant(h2);
  int E = int((hv >> 3) % 250u) + 1;
  uint r;
  switch (mode) {
    case 0: r = mk(s, int(h % 255u), m); break;
    case 1: r = mk(s, E + int((h >> 8) & 7u), m); break;
    case 2: r = mk(s, E + int((h >> 8) % 30u), m); break;
    case 3: r = mk(s, int((h >> 8) & 3u), m); break;
    case 4: r = mk(s, ((h >> 8) & 1u) ? E : E - 24 - int((h >> 9) % 5u), m); break;
    case 5: r = mk(s, 250 + int((h >> 8) % 5u), m); break;
    case 6: {
      uint hp = h32(hv ^ ((lane & ~1u) * 0x85ebca6bu + 0x27d4eb2fu)), hp2 = h32(hp + 0x165667b1u);
      uint mag = mk(0u, E / 2 + int((hp >> 8) % 8u), hp2) ^ (((h >> 8) & lane & 1u));
      r = mag | (((lane & 1u) ^ (hp >> 31)) << 31); break; }
    default: {
      const uint Z[8] = {0u, 0x80000000u, 0x00800000u, 0x80800000u, 0x00000001u, 0x807fffffu, 0x3f800000u, 0xb3800000u};
      r = Z[(h >> 8) & 7u]; }
  }
  if (nonfinite != 0u && ((h >> 20) & 7u) == 0u) {
    uint c = (h >> 23) & 3u;
    r = c == 0u ? 0x7f800000u : c == 1u ? 0xff800000u
      : ((h2 & 0x80000000u) | 0x7f800000u | (c == 2u ? (0x400000u | (h2 & 0x3fffffu)) : ((h2 & 0x3fffffu) | 1u)));
  }
  return r;
}
`;

type Lowering = { readonly require: readonly RegExp[]; readonly forbid?: readonly RegExp[] };
const kernels: { name: string; low: Lowering }[] = [];
const FP_FLAGS = /\b(fadd|fsub|fmul|fdiv|frem|fneg)\s+(fast|reassoc|nnan|ninf|nsz|arcp|contract|afn)\b/;
function kernel(name: string, inputNames: string[], source: string, low: Lowering, header = HASH) {
  kernels.push({ name, low });
  return new MetalKernel({ name, inputNames, outputNames: ["out"], source, header });
}
function dispatch(k: InstanceType<typeof MetalKernel>, inputs: Arr[], outLen: number, grid: number,
  dtype: number = Dtype.uint32, tg = 256, templateDtypes?: Record<string, number>): Arr {
  const [o] = k.apply(inputs, { outputs: [{ shape: [outLen], dtype }], grid: [grid, 1, 1], threadGroup: [tg, 1, 1], templateDtypes });
  return o!.eval();
}
const u32 = (a: Arr) => { const v = a.rawBytesView(); return new Uint32Array(v.buffer, v.byteOffset, v.byteLength >>> 2); };
const f32 = (a: Arr) => { const v = a.rawBytesView(); return new Float32Array(v.buffer, v.byteOffset, v.byteLength >>> 2); };
const params = (...v: number[]) => {
  const a = Uint32Array.from(v.map(x => x >>> 0));
  return MlxArray.fromBytesCopy(new Uint8Array(a.buffer), [a.length], Dtype.uint32);
};
const fromU32 = (a: Uint32Array, dtype: number = Dtype.uint32) =>
  MlxArray.fromBytesCopy(new Uint8Array(a.buffer, a.byteOffset, a.byteLength), [a.length], dtype);

// ---------------------------------------------------------------- self-test of references
section("reference self-test (fast TS references vs exact BigInt rationals)");
{
  const c = clause("reference_selftest");
  let s = 12345;
  const rnd = () => { s = (Math.imul(s, 1103515245) + 12345) >>> 0; s ^= s >>> 13; s = Math.imul(s, 0x5bd1e995) >>> 0; return s >>> 0; };
  const pick = (exp: number) => valOf((((rnd() & 1) << 31) | (Math.min(254, Math.max(0, exp)) << 23) | (rnd() & 0x7fffff)) >>> 0);
  for (let i = 0; i < 200000; i++) {
    const m = i & 7, ea = rnd() % 255;
    const eb = m < 2 ? rnd() % 255 : m < 4 ? ea + (rnd() % 61) - 30 : m === 4 ? rnd() % 6 : m === 5 ? 128 - ea + (rnd() % 7) - 3 : m === 6 ? 381 - ea + (rnd() % 7) - 3 : ea;
    const a = pick(m === 4 ? rnd() % 6 : ea), b = m === 7 ? -pick(eb) : pick(eb);
    const pc = -Math.fround(a * b), cc = i % 3 === 0 && Number.isFinite(pc) ? pc : pick(rnd() % 255);
    const y = valOf(((127 + rnd() % 126) << 23) | (rnd() & 0x7fffff));
    const x = m === 5 ? pick(((bitsOf(y) >>> 23) & 255) - 126 + (rnd() % 7) - 3) : a;
    c.cases += 4;
    if (!sameF(addRef(a, b), exactAdd(a, b))) c.fail(`add ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))}`);
    if (!sameF(mulRef(a, b), exactMul(a, b))) c.fail(`mul ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))}`);
    if (!sameF(divRef(x, y), exactDiv(x, y))) c.fail(`div ${fmtF(bitsOf(x))} ${fmtF(bitsOf(y))}`);
    if (!sameF(fmaFlushRef(a, b, cc), exactFma(a, b, cc))) c.fail(`fma ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))} ${fmtF(bitsOf(cc))}`);
  }
  for (let i = 0; i < 100000; i++) { // bf16 direct rounding of binary32 values vs integer RNE
    const f = Math.fround((rnd() / 2 ** 32 - 0.5) * 2 ** ((rnd() % 260) - 130)); c.cases++;
    if (Number.isFinite(f) && bfFromF64(f) !== bf16Rne(bitsOf(f))) c.fail(`bf16 ${fmtF(bitsOf(f))}`);
  }
  for (let i = 0; i < 400000; i++) { // bf16 Lean arithmetic: fround path vs exact rationals
    const a = rnd() & 0xffff; let b = rnd() & 0xffff;
    if (i & 1) b = (b & 0x807f) | (Math.min(254, Math.max(0, ((a >>> 7) & 255) + (rnd() % 21) - 10)) << 7);
    if (i % 5 === 0) b = (a ^ 0x8000) ^ (rnd() & 3);
    if (!Number.isFinite(BV[a]!) || !Number.isFinite(BV[b]!)) continue;
    const op = i & 3; c.cases++;
    const fast = bfLean(op, a, b), exact = bfExact(op, a, b);
    if (fast !== exact && !(Number.isNaN(bfVal(fast)) && Number.isNaN(bfVal(exact)))) c.fail(`bf16 op${op} ${hex(a)} ${hex(b)}: ${hex(fast)} vs ${hex(exact)}`);
  }
  report(c);
  if (c.fails) throw new Error("reference self-test failed; refusing to judge the hardware");
}

// ---------------------------------------------------------------- unary exhaustive sweeps
section("unary f32 sweeps over all 2^32 inputs");
const unarySpec: [UnaryName, string, Lowering][] = [
  ["rsqrt", "metal::precise::rsqrt(x)", { require: [/@air\.rsqrt\.f32/], forbid: [/@air\.fast_rsqrt/] }],
  ["exp", "metal::precise::exp(x)", { require: [/@air\.exp\.f32/], forbid: [/@air\.fast_exp/] }],
  ["fastExp", "metal::fast::exp(x)", { require: [/@air\.fast_exp\.f32/], forbid: [/@air\.exp\.f32/] }],
  ["exp2", "metal::precise::exp2(x)", { require: [/@air\.exp2\.f32/], forbid: [/@air\.fast_exp2/] }],
  ["log", "metal::precise::log(x)", { require: [/@air\.log\.f32/], forbid: [/@air\.fast_log/] }],
  ["fastLog", "metal::fast::log(x)", { require: [/@air\.fast_log\.f32/], forbid: [/@air\.log\.f32/] }],
  ["fastSin", "metal::fast::sin(x)", { require: [/@air\.fast_sin\.f32/], forbid: [/@air\.sin\.f32/] }],
  ["fastCos", "metal::fast::cos(x)", { require: [/@air\.fast_cos\.f32/], forbid: [/@air\.cos\.f32/] }],
  ["fabs", "metal::precise::fabs(x)", { require: [/@air\.fabs\.f32/], forbid: [/@air\.fast_fabs/] }],
  ["fastFabs", "metal::fast::fabs(x)", { require: [/@air\.fast_fabs\.f32/], forbid: [/@air\.fabs\.f32/] }],
];
const unaryKernels = new Map<UnaryName, InstanceType<typeof MetalKernel>>();
for (const [n, expr, low] of unarySpec) {
  unaryKernels.set(n, kernel(`m1c_u_${n}_v1`, ["p"],
    `uint i = thread_position_in_grid.x; float x = as_type<float>(p[0] + i); out[i] = as_type<uint>(${expr});`, low));
}
unaryKernels.set("bf16cast", kernel("m1c_u_bf16cast_v1", ["p"],
  `uint i = thread_position_in_grid.x; float x = as_type<float>(p[0] + i); out[i] = uint(as_type<ushort>(bfloat(x)));`,
  { require: [/fptrunc float [^\n]* to bfloat/] }));

// Tables on bf16-widened inputs for the bf16 composition checks.
const bfTable = new Map<UnaryName, Uint32Array>();
for (const n of ["exp", "fastExp", "fabs", "fastFabs"] as UnaryName[]) bfTable.set(n, new Uint32Array(65536));

const stat = newStat();
const CHUNK = 1 << 24;
{
  const order: UnaryName[] = ["rsqrt", "exp", "fastExp", "exp2", "log", "fastLog", "fastSin", "fastCos", "fabs", "fastFabs", "bf16cast"];
  const step = QUICK ? 16 : 1;
  const SLICE = CHUNK / 4;
  let pending: Promise<void> | null = null;
  for (let ci = 0; ci < 256; ci += step) {
    const base = ci * CHUNK;
    const p = params(base);
    const outs = order.map(n => dispatch(unaryKernels.get(n)!, [p], CHUNK, CHUNK));
    const tasks: Task[] = [];
    order.forEach((n, q) => {
      const rb = u32(outs[q]!);
      const tab = bfTable.get(n);
      if (tab) for (let i = 0; i < CHUNK; i += 65536) tab[(base + i) >>> 16] = rb[i]!;
      for (let lo = 0; lo < CHUNK; lo += SLICE) tasks.push({ kind: "unary", n, base, lo, hi: lo + SLICE, ptr: addrOf(rb), words: CHUNK });
    });
    // Overlap: the next chunk's GPU work is encoded while workers check this one.
    if (pending) await pending;
    pending = pool.run(tasks, stat).then(() => { for (const o of outs) o.dispose(); p.dispose(); });
    if (ci % 32 === 0) clearCache();
  }
  await pending;
  clause("rsqrt_normal.bound").info.push(`observed |r|*sqrt(x) in [${stat.rsqrtMin}, ${stat.rsqrtMax}]`);
  clause("fastExp_nonpositive").info.push(`max fastExp on x<=0 = ${stat.fexpMaxNonpos}`);
  clause("exp_small").info.push(`max exp on |x|<=8 = ${stat.expMaxSmall}`);
  clause("log_bounded").info.push(`max |log| = ${stat.logMaxAbs}`);
  clause("fastLog_unit").info.push(`range [${stat.flogMin}, ${stat.flogMax}]`);
  clause("fastSin_bounded").info.push(`max |sin| = ${stat.sinMax}`);
  clause("fastCos_bounded").info.push(`max |cos| = ${stat.cosMax}`);
  for (const [n, s] of [["fabs", [stat.fabsKept, stat.fabsOther, stat.fabsEx]], ["fastFabs", [stat.fastFabsKept, stat.fastFabsOther, stat.fastFabsEx]]] as const)
    clause(`${n}_clearsSign (non-NaN)`).info.push(`NaN inputs: ${s[0]} gave input&0x7fffffff, ${s[1]} other${s[2] ? ` e.g. ${s[2]}` : ""}`);
  clause("bf16 narrow T(f) = BFloat16.narrow (RNE, gradual underflow) (non-NaN)").info.push(
    `NaN inputs: ${stat.bfKept} gave (x>>16)|0x40, ${stat.bfOther} other${stat.bfEx ? ` e.g. ${stat.bfEx}` : ""}; ${stat.bfLean} equal BFloat16.narrow (FloatLib payload rule); ${stat.bf7fff} gave 0x7fff`);
  for (const c of clauses.values()) if (c.name !== "reference_selftest") report(c);
}

// ---------------------------------------------------------------- binary arithmetic
section("fadd/fmul/fdiv/fma against flushed RNE models");
const RANDOM_CHUNKS = QUICK ? 1 : 64; // x 2^24 = 2^30 random cases per operation
const binSpec = [
  { op: "fadd", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 0u);",
    expr: "as_type<float>(v.x) + as_type<float>(v.y)", structured: 4080 * 4080,
    ref: addRef, low: { require: [/= fadd float /], forbid: [/@air\.fma/, /@air\.fast_/] } },
  { op: "fmul", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 1u);",
    expr: "as_type<float>(v.x) * as_type<float>(v.y)", structured: 4080 * 4080,
    ref: mulRef, low: { require: [/= fmul float /], forbid: [/@air\.fma/, /@air\.fast_/] } },
  { op: "fdiv", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 1009u), dv(idx % 1009u)) : genDiv(idx, p[1]);",
    expr: "as_type<float>(v.x) / as_type<float>(v.y)", structured: 4080 * 1009,
    ref: divRef, low: { require: [/= fdiv float /], forbid: [/@air\.fast_/, /@air\.div/] } },
  { op: "fma", width: 4, gen: "uint3 v = s ? uint3(tv(idx / 25600u), tv((idx / 160u) % 160u), tv(idx % 160u)) : genFma(idx, p[1]);",
    expr: "metal::fma(as_type<float>(v.x), as_type<float>(v.y), as_type<float>(v.z))", structured: 160 ** 3,
    ref: null, low: { require: [/@air\.fma\.f32/], forbid: [/@air\.fast_/] } },
] as const;
for (const spec of binSpec) {
  const w = spec.width;
  const k = kernel(`m1c_b_${spec.op}_v1`, ["p"], String.raw`
    uint i = thread_position_in_grid.x; uint idx = p[0] + i; bool s = p[2] != 0u;
    if (s && idx >= p[3]) return;
    ${spec.gen}
    out[${w}u * i] = v.x; out[${w}u * i + 1u] = v.y; ${w === 4 ? "out[4u * i + 2u] = v.z;" : ""}
    out[${w}u * i + ${w - 1}u] = as_type<uint>(${spec.expr});`, spec.low);
  const c = clause(`${spec.op}_model`);
  const cb = clause(`${spec.op} = flush-before-rounding model (|exact| < 2^-126 -> signed 0, else RNE)`);
  const cu = clause(`${spec.op} = unbounded-exponent RNE then flush model`);
  const domain = spec.op === "fdiv";
  const run = (base: number, n: number, seed: number, structured: boolean) => {
    const p = params(base, seed, structured ? 1 : 0, spec.structured);
    const o = dispatch(k, [p], n * w, n);
    const b = u32(o), f = new Float32Array(b.buffer, b.byteOffset, b.length);
    for (let i = 0, j = 0; i < n; i++, j += w) {
      const a = f[j]!, bb = f[j + 1]!;
      if (!Number.isFinite(a) || !Number.isFinite(bb)) continue;
      let want: number, pre: number;
      if (w === 4) {
        const cc = f[j + 2]!; if (!Number.isFinite(cc)) continue;
        want = fmaFlushRef(a, bb, cc); pre = fmaRO(fl(a), fl(bb), fl(cc));
      } else {
        if (domain && !(bb >= 1 && bb <= 2 ** 126)) continue;
        want = spec.ref!(a, bb);
        const x = fl(a), y = fl(bb);
        pre = spec.op === "fadd" ? x + y : spec.op === "fmul" ? x * y : x / y;
      }
      c.cases++; cb.cases++; cu.cases++;
      const got = f[j + w - 1]!;
      const e = (m: number) => `${[...b.subarray(j, j + w - 1)].map(fmtF).join(" ")} -> ${fmtF(b[j + w - 1]!)} want ${fmtF(bitsOf(m))}`;
      if (!sameF(got, want)) c.fail(e(want));
      const wb = flushBefore(pre), wu = flushUnbounded(pre);
      if (!sameF(got, wb)) cb.fail(e(wb));
      if (!sameF(got, wu)) cu.fail(e(wu));
    }
    o.dispose(); p.dispose();
  };
  for (let base = 0; base < spec.structured; base += CHUNK) run(base, Math.min(CHUNK, spec.structured - base), 0, true);
  const structuredCases = c.cases;
  for (let ch = 0; ch < RANDOM_CHUNKS; ch++) run(ch * CHUNK, CHUNK, 0x51ed27 + ch * 7919, false);
  c.info.push(`${structuredCases} structured + ${c.cases - structuredCases} random`);
  clearCache();
  report(c); report(cb); report(cu);
}

// ---------------------------------------------------------------- fmax / fmin (binary)
section("fmax/fmin (precise, fast, unqualified): selection and tie policy");
const minmaxVariants = [
  ["fmax precise", "metal::precise::fmax(a, b)", { require: [/@air\.fmax\.f32/], forbid: [/@air\.fast_fmax/] }, 1],
  ["fmax fast", "metal::fast::fmax(a, b)", { require: [/@air\.fast_fmax\.f32/], forbid: [/@air\.fmax\.f32/] }, 1],
  ["max unqualified", "metal::max(a, b)", { require: [/@air\.fast_fmax\.f32/], forbid: [/@air\.fmax\.f32/] }, 1],
  ["fmin precise", "metal::precise::fmin(a, b)", { require: [/@air\.fmin\.f32/], forbid: [/@air\.fast_fmin/] }, 0],
  ["fmin fast", "metal::fast::fmin(a, b)", { require: [/@air\.fast_fmin\.f32/], forbid: [/@air\.fmin\.f32/] }, 0],
  ["min unqualified", "metal::min(a, b)", { require: [/@air\.fast_fmin\.f32/], forbid: [/@air\.fmin\.f32/] }, 0],
] as const;
for (const [label, expr, low, isMax] of minmaxVariants) {
  const k = kernel(`m1c_mm_${label.replace(/ /g, "_")}_v1`, ["p"], String.raw`
    uint i = thread_position_in_grid.x; uint idx = p[0] + i; bool s = p[2] != 0u;
    if (s && idx >= p[3]) return;
    uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 0u);
    uint h = h32(idx ^ 0x7a3c19u);
    if (!s && (h & 7u) == 0u) v.y = v.x; else if (!s && (h & 7u) == 1u) v.y = v.x ^ 0x80000000u;
    float a = as_type<float>(v.x), b = as_type<float>(v.y);
    out[3u * i] = v.x; out[3u * i + 1u] = v.y; out[3u * i + 2u] = as_type<uint>(${expr});`, low);
  const pol = new Policy(label, isMax, "f32 structured+random");
  const run = (base: number, n: number, seed: number, structured: boolean) => {
    const p = params(base, seed, structured ? 1 : 0, 4080 * 4080);
    const o = dispatch(k, [p], 3 * n, n);
    const b = u32(o), f = new Float32Array(b.buffer, b.byteOffset, b.length);
    for (let i = 0, j = 0; i < n; i++, j += 3) {
      const x = f[j]!, y = f[j + 1]!; if (!Number.isFinite(x) || !Number.isFinite(y)) continue;
      pol.check(b[j]!, b[j + 1]!, x, y, b[j + 2]!, f[j + 2]!);
    }
    o.dispose(); p.dispose();
  };
  run(0, 4080 * 4080, 0, true);
  for (let ch = 0; ch < (QUICK ? 1 : 4); ch++) run(ch * CHUNK, CHUNK, 0x3c6ef372 + ch, false);
  pol.finish();
}

// ---------------------------------------------------------------- simd_sum
section("simd_sum: tree identification and replay");
type Tree = number | [Tree, Tree];
const leaves = (t: Tree): number[] => typeof t === "number" ? [t] : [...leaves(t[0]), ...leaves(t[1])];
const show = (t: Tree): string => typeof t === "number" ? `${t}` : `(${show(t[0])}+${show(t[1])})`;
function buildTree(lca: number[][]): Tree | string {
  // clusters: for each lane j and each size s, {j} ∪ {k : |LCA(j,k)| <= s}
  const sets = new Set<string>([...Array(32).keys()].map(i => `${i}`));
  for (let j = 0; j < 32; j++) for (let k = 0; k < 32; k++) if (j !== k) {
    const s = lca[j]![k]!; const set = [j];
    for (let m = 0; m < 32; m++) if (m !== j && lca[j]![m]! <= s) set.push(m);
    if (set.length !== s) return `cluster size mismatch at (${j},${k}): ${set.length} != ${s}`;
    sets.add(set.sort((a, b) => a - b).join(","));
  }
  const cl = [...sets].map(s => s.split(",").map(Number));
  const make = (members: number[]): Tree | string => {
    if (members.length === 1) return members[0]!;
    const inner = cl.filter(c => c.length < members.length && c.every(x => members.includes(x)));
    const maximal = inner.filter(c => !inner.some(d => d.length > c.length && c.every(x => d.includes(x))));
    if (maximal.length !== 2 || maximal[0]!.length + maximal[1]!.length !== members.length) return `node {${members}} is not binary`;
    maximal.sort((a, b) => a[0]! - b[0]!);
    const l = make(maximal[0]!), r = make(maximal[1]!);
    if (typeof l === "string") return l; if (typeof r === "string") return r;
    return [l, r];
  };
  return make([...Array(32).keys()]);
}
// Bit-level FTZ add with FloatLib NaN rules (signaling first, then left).
function addBits(x: number, y: number): number {
  const xn = isNaNBits(x), yn = isNaNBits(y);
  if (xn || yn) {
    const xs = xn && !(x & 0x400000), ys = yn && !(y & 0x400000);
    return ((xs ? x : ys ? y : xn ? x : y) | 0x400000) >>> 0;
  }
  const v = addRef(valOf(x), valOf(y));
  return Number.isNaN(v) ? 0x7fc00000 : bitsOf(v);
}
function compileTree(t: Tree) {
  const lines: string[] = []; let n = 0;
  const emit = (u: Tree): string => {
    if (typeof u === "number") return `x[o+${u}]`;
    const a = emit(u[0]), b = emit(u[1]); const v = `t${n++}`; lines.push(`const ${v}=add(${a},${b});`); return v;
  };
  const r = emit(t);
  return {
    f64: new Function("add", "x", "o", `${lines.join("")}return ${r};`).bind(null, addRef) as (x: Float32Array, o: number) => number,
    bits: new Function("add", "x", "o", `${lines.join("")}return ${r};`).bind(null, addBits) as (x: Uint32Array, o: number) => number,
  };
}
let sumTree: Tree | null = null;
{
  const kd = kernel("m1c_simdsum_v1", ["v"], String.raw`
    uint gid = thread_position_in_grid.x;
    float s = simd_sum(as_type<float>(v[gid]));
    uint sb = as_type<uint>(s);
    bool same = simd_all(sb == simd_broadcast(sb, 0u));
    if (thread_index_in_simdgroup == 0u) { out[2u * (gid >> 5)] = sb; out[2u * (gid >> 5) + 1u] = same ? 1u : 0u; }`,
    { require: [/@air\.simd_sum\.f32/] });
  const BIG = 0x4c000000, NBIG = 0xcc000000, ONE = 0x3f800000; // 2^25, -2^25, 1
  const trip: [number, number, number][] = [];
  for (let j = 0; j < 32; j++) for (let k = j + 1; k < 32; k++) for (let i = 0; i < 32; i++) if (i !== j && i !== k) trip.push([j, k, i]);
  const v = new Uint32Array(trip.length * 32);
  trip.forEach(([j, k, i], q) => { v[q * 32 + j] = BIG; v[q * 32 + k] = NBIG; v[q * 32 + i] = ONE; });
  const va = fromU32(v); const o = dispatch(kd, [va], trip.length * 2, trip.length * 32, Dtype.uint32, 256);
  const r = u32(o);
  const lca = [...Array(32)].map(() => new Array(32).fill(2));
  let odd = 0;
  trip.forEach(([j, k], q) => {
    const x = r[2 * q]!;
    if (x === 0) { lca[j]![k]++; lca[k]![j]++; } else if (x !== ONE) odd++;
  });
  o.dispose(); va.dispose();
  const c = clause("simdSum_tree (finite inputs, bit-exact)");
  const t = odd ? `discovery saw ${odd} results other than 0 or 1` : buildTree(lca);
  if (typeof t === "string") { c.fail(`no binary tree of RNE adds: ${t}`); report(c); }
  else {
    sumTree = t;
    const perm = leaves(t).sort((a, b) => a - b).every((x, i) => x === i);
    console.log(`simd_sum tree: ${show(t)} (leaves a permutation of 0..31: ${perm})`);
    c.info.push(`tree ${show(t)}`);
  }
  if (sumTree) {
    const ev = compileTree(sumTree);
    const kr = kernel("m1c_simdsum_rand_v1", ["p"], String.raw`
      uint gid = thread_position_in_grid.x, lane = thread_index_in_simdgroup, vec = p[0] + (gid >> 5);
      uint xb = laneVal(vec, lane, p[1], p[2]);
      float s = simd_sum(as_type<float>(xb));
      uint sb = as_type<uint>(s);
      bool same = simd_all(sb == simd_broadcast(sb, 0u));
      uint o = 34u * (gid >> 5);
      out[o + lane] = xb;
      if (lane == 0u) { out[o + 32u] = sb; out[o + 33u] = same ? 1u : 0u; }`,
      { require: [/@air\.simd_sum\.f32/] });
    const cn = clause("simdSum_tree (infinite but no NaN lanes)");
    const cnn = clause("simdSum_tree (some NaN lane, FloatLib payload propagation)");
    const cnc = clause("simd_sum with some NaN lane = canonical 0x7fc00000 (alternative)");
    const ca = clause("simd_sum result identical in all 32 lanes");
    const VEC = 1 << 20;
    const run = (chunk: number, nonfinite: boolean) => {
      const p = params(chunk * VEC, 0x2b7e1516 + chunk * 104729 + (nonfinite ? 1 : 0), nonfinite ? 1 : 0);
      const o = dispatch(kr, [p], VEC * 34, VEC * 32);
      const b = u32(o), f = new Float32Array(b.buffer, b.byteOffset, b.length);
      const cc = nonfinite ? cn : c;
      for (let q = 0, off = 0; q < VEC; q++, off += 34) {
        ca.cases++; if (b[off + 33] !== 1) ca.fail(`vector ${chunk}:${q}`);
        let anyNonFinite = false, anyNaN = false;
        if (nonfinite) for (let l = 0; l < 32; l++) { const x = f[off + l]!; if (!Number.isFinite(x)) anyNonFinite = true; if (x !== x) anyNaN = true; }
        if (nonfinite && !anyNonFinite) continue;
        const got = b[off + 32]!;
        if (anyNaN) {
          cnc.cases++; if (got !== 0x7fc00000) cnc.fail(`lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}] -> ${hex(got)}`);
          cnn.cases++; const want = ev.bits(b, off);
          if (got !== want) cnn.fail(`lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}] -> ${hex(got)} want ${hex(want)}`);
          continue;
        }
        cc.cases++;
        let want: number;
        if (nonfinite) want = ev.bits(b, off);
        else { const w = ev.f64(f, off); want = Number.isNaN(w) ? 0x7fc00000 : bitsOf(w); }
        if (got !== want) cc.fail(`lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}] -> ${hex(got)} want ${hex(want)}`);
      }
      o.dispose(); p.dispose();
    };
    const N = QUICK ? 2 : 96; // 96 x 2^20 = 100,663,296 vectors
    for (let ch = 0; ch < N; ch++) run(ch, false);
    for (let ch = 0; ch < (QUICK ? 1 : 4); ch++) run(1000 + ch, true);
    clearCache();
    report(c); report(cn); report(cnn); report(cnc); report(ca);
  }
}

// ---------------------------------------------------------------- simd_max
section("simd_max: selection and tie order");
{
  const kd = kernel("m1c_simdmax_v1", ["v"], String.raw`
    uint gid = thread_position_in_grid.x;
    float s = simd_max(as_type<float>(v[gid]));
    uint sb = as_type<uint>(s);
    bool same = simd_all(sb == simd_broadcast(sb, 0u));
    if (thread_index_in_simdgroup == 0u) { out[2u * (gid >> 5)] = sb; out[2u * (gid >> 5) + 1u] = same ? 1u : 0u; }`,
    { require: [/@air\.simd_max\.f32/] });
  // +0 at lane i, -0 at lane j, -1 elsewhere: which zero survives?
  const pairs: [number, number][] = [];
  for (let i = 0; i < 32; i++) for (let j = 0; j < 32; j++) if (i !== j) pairs.push([i, j]);
  const v = new Uint32Array(pairs.length * 32).fill(0xbf800000);
  pairs.forEach(([i, j], q) => { v[q * 32 + i] = 0; v[q * 32 + j] = 0x80000000; });
  const va = fromU32(v), o = dispatch(kd, [va], pairs.length * 2, pairs.length * 32);
  const r = u32(o);
  const plusWins = [...Array(32)].map(() => new Array(32).fill(false));
  let other = 0;
  pairs.forEach(([i, j], q) => { const x = r[2 * q]!; if (x === 0) plusWins[i]![j] = true; else if (x !== 0x80000000) other++; });
  o.dispose(); va.dispose();
  let rule: string, order: number[] | null = null;
  const allPlus = pairs.every(([i, j]) => plusWins[i]![j]), allMinus = pairs.every(([i, j]) => !plusWins[i]![j]);
  if (other) rule = `discovery saw ${other} results other than +-0`;
  else if (allPlus) rule = "+0 always wins a +0/-0 tie (independent of lanes): no keep-left tree order matches";
  else if (allMinus) rule = "-0 always wins a +0/-0 tie: no keep-left tree order matches";
  else {
    const antisym = pairs.every(([i, j]) => plusWins[i]![j] !== plusWins[j]![i]);
    const ord = [...Array(32).keys()].sort((a, b) => plusWins[a]![b] ? -1 : 1);
    const consistent = antisym && pairs.every(([i, j]) => plusWins[i]![j] === (ord.indexOf(i) < ord.indexOf(j)));
    rule = consistent ? `first lane in leaf order [${ord}] wins ties` : "zero ties depend on lanes but form no total order";
    if (consistent) order = ord;
  }
  console.log(`simd_max signed-zero tie rule: ${rule}`);
  const kr = kernel("m1c_simdmax_rand_v1", ["p"], String.raw`
    uint gid = thread_position_in_grid.x, lane = thread_index_in_simdgroup, vec = p[0] + (gid >> 5);
    uint xb = laneVal(vec, lane, p[1], 0u);
    float s = simd_max(as_type<float>(xb));
    uint sb = as_type<uint>(s);
    bool same = simd_all(sb == simd_broadcast(sb, 0u));
    uint o = 34u * (gid >> 5);
    out[o + lane] = xb;
    if (lane == 0u) { out[o + 32u] = sb; out[o + 33u] = same ? 1u : 0u; }`,
    { require: [/@air\.simd_max\.f32/] });
  const cs = clause("simdMax_select"), ct = clause("simdMax = Maximum.tree (keep-left ties) bit-exact");
  const cp = clause("simdMax = first max lane, +0 preferred over -0 (alternative tie rule)");
  const ca = clause("simd_max result identical in all 32 lanes");
  const cf = clause("simdMax = keep-left tree in lane order 0..31 comparing flushed values, returning the unflushed lane");
  const csf = clause("simdMax selects a lane maximal among flushed values (replacement for simdMax_select)");
  const VEC = 1 << 20;
  for (let ch = 0; ch < (QUICK ? 1 : 16); ch++) {
    const p = params(ch * VEC, 0x9e3779b9 + ch * 31337, 0);
    const o = dispatch(kr, [p], VEC * 34, VEC * 32);
    const b = u32(o), f = new Float32Array(b.buffer, b.byteOffset, b.length);
    for (let q = 0, off = 0; q < VEC; q++, off += 34) {
      ca.cases++; if (b[off + 33] !== 1) ca.fail(`vector ${ch}:${q}`);
      let m = -Infinity, ok = true;
      for (let l = 0; l < 32; l++) { const x = f[off + l]!; if (!Number.isFinite(x)) { ok = false; break; } if (x > m) m = x; }
      if (!ok) continue;
      const got = b[off + 32]!;
      cs.cases++; ct.cases++; cp.cases++;
      let sel = false;
      for (let l = 0; l < 32; l++) if (b[off + l] === got) { sel = true; break; }
      const lanesStr = () => `lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}] -> ${hex(got)}`;
      if (!(sel && f[off + 32] === m)) cs.fail(lanesStr());
      cf.cases++; csf.cases++;
      let mf = -Infinity; for (let l = 0; l < 32; l++) { const x = fl(f[off + l]!); if (x > mf) mf = x; }
      let wantF = 0; for (let l = 0; l < 32; l++) if (fl(f[off + l]!) === mf) { wantF = b[off + l]!; break; }
      if (got !== wantF) cf.fail(`${lanesStr()} want ${hex(wantF)}`);
      if (!(sel && fl(f[off + 32]!) === mf)) csf.fail(lanesStr());
      if (order) {
        let want = 0; for (const l of order) if (f[off + l] === m) { want = b[off + l]!; break; }
        if (got !== want) ct.fail(`${lanesStr()} want ${hex(want)}`);
      } else ct.fail(`no tree order (${rule}); ${lanesStr()}`);
      let wantP = -1;
      for (let l = 0; l < 32; l++) if (f[off + l] === m && (wantP < 0 || (wantP === 0x80000000 && b[off + l] === 0))) wantP = b[off + l]!;
      if (got !== wantP) cp.fail(`${lanesStr()} want ${hex(wantP)}`);
    }
    o.dispose(); p.dispose();
  }
  ct.info.push(rule);
  if (!order) ct.fails = Math.max(ct.fails, 1);
  report(cs); report(ct); report(cp); report(cf); report(csf); report(ca);
}

// ---------------------------------------------------------------- loads
section("threadgroup float load at unaligned byte addresses; device float4 load");
{
  const src = readFileSync(join(import.meta.dir, "../../../packages/inference/src/kernels/trellis/codebook.ts"), "utf8");
  const win = /export const CODEBOOK_WINDOW = String\.raw`([\s\S]*?)`;/.exec(src)?.[1];
  if (!win) throw new Error("CODEBOOK_WINDOW not found");
  const k = kernel("m1c_tgload_v1", ["p"], String.raw`
    threadgroup float table[4096];
    const uint t = thread_position_in_threadgroup.x, g = threadgroup_position_in_grid.x;
    for (uint w = t; w < 4096u; w += 256u) table[w] = as_type<float>(h32(w * 2654435761u + g * 40503u + p[0]));
    threadgroup_barrier(mem_flags::mem_threadgroup);
    for (uint q = 0; q < 64u; ++q) {
      const uint slot = t * 64u + q;
      const uint byteoff = (slot ^ (p[1] * g)) & 16383u;
      const uint wv[1] = {byteoff};
      const uint vv[2] = {0u, 0u};
      out[g * 16384u + slot] = trellis_codebook_window((const threadgroup uchar*)table, wv, vv, 2u, 12u);
    }`, { require: [/load float, float addrspace\(3\)\*/] }, HASH + win);
  const c = clause("threadgroupLoad_contract (low two address bits ignored)");
  const h32 = (x: number) => { x >>>= 0; x ^= x >>> 16; x = Math.imul(x, 0x7feb352d); x ^= x >>> 15; x = Math.imul(x, 0x846ca68b); x ^= x >>> 16; return x >>> 0; };
  let nanWords = 0, subWords = 0;
  const G = 64;
  for (const [seed, mult] of [[1, 0], [0x1234567, 0x9e37], [0xabcdef, 0x3fff], [77, 1]] as const) {
    const p = params(seed, mult);
    const o = dispatch(k, [p], G * 16384, G * 256, Dtype.float32);
    const r = u32(o);
    for (let g = 0; g < G; g++) for (let slot = 0; slot < 16384; slot++) {
      const off = (slot ^ Math.imul(mult, g)) & 16383;
      const word = off >>> 2;
      const want = h32((Math.imul(word, 2654435761 | 0) + Math.imul(g, 40503) + seed) >>> 0);
      const got = r[g * 16384 + slot]!;
      c.cases++;
      if (isNaNBits(want)) nanWords++; else if ((want & 0x7f800000) === 0 && (want & 0x7fffff)) subWords++;
      if (got !== want) c.fail(`group ${g} byte offset ${off} (sub-word ${off & 3}) -> ${hex(got)} want word ${word} ${hex(want)}`);
    }
    o.dispose(); p.dispose();
  }
  c.info.push(`all 4 sub-word offsets x 4096 word bases x ${G} groups x 4 patterns; ${nanWords} NaN and ${subWords} subnormal words included`);
  report(c);

  const kv = kernel("m1c_vec4_v1", ["src", "perm"], String.raw`
    uint i = thread_position_in_grid.x, e = perm[i];
    float4 v = ((const device float4*)src)[e];
    out[4u * i] = v.x; out[4u * i + 1u] = v.y; out[4u * i + 2u] = v.z; out[4u * i + 3u] = v.w;`,
    { require: [/load <4 x float>, <4 x float> addrspace\(1\)\*/] });
  const cv = clause("vectorLoad_components (float4 at 16-aligned address = 4 scalar words)");
  const N4 = 1 << 20;
  let s = 99;
  const rnd = () => { s ^= s << 13; s ^= s >>> 17; s ^= s << 5; return s >>> 0; };
  for (let rep = 0; rep < 2; rep++) {
    const words = new Uint32Array(4 * N4); for (let i = 0; i < words.length; i++) words[i] = rnd();
    const perm = new Uint32Array(N4); for (let i = 0; i < N4; i++) perm[i] = rep ? (Math.imul(i, 2654435761) >>> 12) & (N4 - 1) : i;
    const sa = fromU32(words, Dtype.float32), pa = fromU32(perm);
    const o = dispatch(kv, [sa, pa], 4 * N4, N4, Dtype.float32);
    const r = u32(o);
    for (let i = 0; i < N4; i++) for (let comp = 0; comp < 4; comp++) {
      cv.cases++; const want = words[4 * perm[i]! + comp]!, got = r[4 * i + comp]!;
      if (got !== want) cv.fail(`float4 index ${perm[i]} component ${comp} -> ${hex(got)} want ${hex(want)}`);
    }
    o.dispose(); sa.dispose(); pa.dispose();
  }
  cv.info.push("random words including NaN payloads and subnormals; identity and scattered element order");
  report(cv);
}

// ---------------------------------------------------------------- bf16 operations
section("bf16: widen/narrow, native arithmetic (exhaustive), min/max policy (exhaustive), compositions");
const BF_ROWS = QUICK ? 512 : 65536;
{
  // float(v): fpext bfloat -> float over all 65536 inputs.
  {
    const k = kernel("m1c_bf16_widen_v1", ["p"], String.raw`
      uint i = thread_position_in_grid.x; const T v = as_type<T>(ushort(i)); out[i] = as_type<uint>(float(v));`,
      { require: [/fpext bfloat [^\n]* to float/] });
    const p = params(0), o = dispatch(k, [p], 65536, 65536, Dtype.uint32, 256, { T: Dtype.bfloat16 });
    const r = u32(o).slice(); o.dispose(); p.dispose();
    const c = clause("bf16 widen float(v) = BFloat16.widen (= bits << 16) (non-NaN)");
    let shift = 0, lean = 0, nan = 0;
    for (let h = 0; h < 65536; h++) {
      if (Number.isNaN(BV[h]!)) { nan++; if (r[h] === ((h << 16) >>> 0)) shift++; if (r[h] === leanWidenNaN(h)) lean++; continue; }
      c.cases++; if (r[h] !== ((h << 16) >>> 0)) c.fail(`${hex(h)} -> ${hex(r[h]!)}`);
    }
    c.info.push(`NaN inputs (${nan}): ${shift} gave bits<<16, ${lean} equal BFloat16.widen (FloatLib payload rule)`);
    report(c);
  }
  // Native bfloat + - * / in a runtime kernel, all 65536^2 ordered pairs.
  const bfOps = [["add", "+", /fadd bfloat/], ["sub", "-", /fsub bfloat/], ["mul", "*", /fmul bfloat/], ["div", "/", /fdiv bfloat/]] as const;
  for (const [oi, [name, sym, re]] of bfOps.entries()) {
    const k = kernel(`m1c_bf16_${name}_v1`, ["p"], String.raw`
      uint i = thread_position_in_grid.x, a = p[0] + (i >> 16), b = i & 0xffffu;
      const T x = as_type<T>(ushort(a)), y = as_type<T>(ushort(b));
      const T r = x ${sym} y;
      out[i] = uint(as_type<ushort>(r));`, { require: [re], forbid: [/@air\.fast_/] });
    const nanPol: Record<string, number> = {};
    const ROWS = 256;
    let pending: Promise<void> | null = null;
    for (let a0 = 0; a0 < BF_ROWS; a0 += ROWS) {
      const p = params(a0), o = dispatch(k, [p], ROWS * 65536, ROWS * 65536, Dtype.uint32, 256, { T: Dtype.bfloat16 });
      const r = u32(o), tasks: Task[] = [];
      for (let lo = 0; lo < ROWS; lo += 16) tasks.push({ kind: "bf16op", oi, name, a0, lo, hi: lo + 16, ptr: addrOf(r), words: r.length });
      if (pending) await pending;
      pending = pool.run(tasks, undefined, nanPol).then(() => { o.dispose(); p.dispose(); });
    }
    await pending; pending = null;
    const c = clause(`bf16 ${name} = BFloat16Arithmetic.${name} bitwise (all pairs with non-NaN model result)`);
    c.info.push(`NaN model results: ${Object.entries(nanPol).map(([k, v]) => `${k} ${v}`).join(", ")}`);
    report(c); report(clause(`bf16 ${name} = flush-before-rounding model (|exact| < 2^-126 -> signed 0, else RNE) (non-NaN)`));
  }
  // min/max intrinsics on all 65536^2 widened bf16 pairs.
  {
    const k = kernel("m1c_bf16_minmax_v1", ["p"], String.raw`
      uint i = thread_position_in_grid.x, a = p[0] + (i >> 16), b = i & 0xffffu;
      float x = as_type<float>(a << 16), y = as_type<float>(b << 16);
      uint o = 4u * i;
      out[o] = as_type<uint>(metal::fast::fmax(x, y)); out[o + 1u] = as_type<uint>(metal::fast::fmin(x, y));
      out[o + 2u] = as_type<uint>(metal::precise::fmax(x, y)); out[o + 3u] = as_type<uint>(metal::precise::fmin(x, y));`,
      { require: [/@air\.fast_fmax\.f32/, /@air\.fast_fmin\.f32/, /@air\.fmax\.f32/, /@air\.fmin\.f32/] });
    const pols = bfPolicies();
    const ROWS = 64;
    let pending: Promise<void> | null = null;
    for (let a0 = 0; a0 < BF_ROWS; a0 += ROWS) {
      const p = params(a0), o = dispatch(k, [p], 4 * ROWS * 65536, ROWS * 65536);
      const r = u32(o), tasks: Task[] = [];
      for (let lo = 0; lo < ROWS; lo += 4) tasks.push({ kind: "bf16mm", a0, lo, hi: lo + 4, ptr: addrOf(r), words: r.length });
      if (pending) await pending;
      pending = pool.run(tasks, undefined, undefined, pols).then(() => { o.dispose(); p.dispose(); });
    }
    await pending;
    for (const pol of pols) pol.finish();
  }
  clearCache();
}
// Compositions: runtime exp(abs(v)) and sigmoid; precompiled ops.sigmoid (needs the full unary tables).
if (!QUICK) {
  const fastAbs = bfTable.get("fastFabs")!, fastExp = bfTable.get("fastExp")!, pAbs = bfTable.get("fabs")!, pExp = bfTable.get("exp")!;
  const k = kernel("m1c_bf16_sigmoid_v1", ["p"], String.raw`
    uint i = thread_position_in_grid.x;
    const T value = as_type<T>(ushort(i));
    const auto e = metal::exp(metal::abs(value));
    const auto y = 1 / (1 + metal::exp(metal::abs(value)));
    const T sigmoid = T(value < T(0) ? y : 1 - y);
    out[2u * i] = uint(as_type<ushort>(e)) | (uint(sizeof(e)) << 16);
    out[2u * i + 1u] = uint(as_type<ushort>(sigmoid));`,
    { require: [/@air\.fast_fabs\.f32/, /@air\.fast_exp\.f32/], forbid: [/@air\.exp\.f32/, /@air\.fabs\.f32/] });
  const p = params(0);
  const o = dispatch(k, [p], 2 * 65536, 65536, Dtype.uint32, 256, { T: Dtype.bfloat16 });
  const r = u32(o).slice();
  o.dispose(); p.dispose();
  const ce = clause("bf16 runtime exp(abs(v)) = bf16(fast_exp(f32(bf16(fast_fabs(f32 v))))) (all 65536, NaN results compared as NaN)");
  const expAbs = (v: number, abs: Uint32Array, exT: Uint32Array) => bf16Rne(exT[bf16Rne(abs[v]!)]!);
  for (let v = 0; v < 65536; v++) {
    ce.cases++;
    if ((r[2 * v]! >>> 16) !== 2) ce.fail(`exp(abs(bfloat)) is not 2 bytes wide`);
    const got = r[2 * v]! & 0xffff, want = expAbs(v, fastAbs, fastExp);
    if (got !== want && !(Number.isNaN(BV[got]!) && Number.isNaN(BV[want]!))) ce.fail(`v=${hex(v)} -> ${hex(got)} want ${hex(want)}`);
  }
  report(ce);
  // Candidate models of native bfloat +, /, - (opcodes 0 +, 1 -, 3 /) and of bfloat < 0.
  type Route = (op: number, a: number, b: number) => number;
  const f64op = (op: number, x: number, y: number) => (op === 0 ? x + y : op === 1 ? x - y : op === 2 ? x * y : x / y);
  const routes: [string, Route][] = [
    ["BFloat16Arithmetic (flush in, RNE, flush out)", bfLean],
    ["flush in, flush-before-rounding, RNE", (op, a, b) => { const pre = f64op(op, BVF[a]!, BVF[b]!);
      return pre !== 0 && pre > -TINY && pre < TINY ? (pre < 0 ? 0x8000 : 0) : bfFromF32(Math.fround(pre)); }],
    ["via f32 FTZ RNE then bf16 RNE", (op, a, b) => bf16Rne(bitsOf(fl(Math.fround(f64op(op, BVF[a]!, BVF[b]!)))))],
    ["RNE without any flushing", (op, a, b) => bfFromF64(f64op(op, BV[a]!, BV[b]!))],
  ];
  const ONE = 0x3f80;
  const sigModel = (v: number, abs: Uint32Array, exT: Uint32Array, route: Route, flushCmp: boolean) => {
    const e = expAbs(v, abs, exT);
    const q = route(3, ONE, route(0, e, ONE));
    const neg = flushCmp ? BVF[v]! < 0 : BV[v]! < 0;
    return neg ? q : route(1, ONE, q);
  };
  const precompiled = (() => {
    const all = new Uint32Array(32768); for (let i = 0; i < 32768; i++) all[i] = (2 * i) | ((2 * i + 1) << 16);
    const x = MlxArray.fromBytesCopy(new Uint8Array(all.buffer), [65536], Dtype.bfloat16);
    const s = ops.sigmoid(x).eval();
    const b = s.rawBytesView(); const out = new Uint16Array(b.buffer, b.byteOffset, 65536).slice();
    s.dispose(); x.dispose();
    return out;
  })();
  for (const [label, got, abs, exT] of [
    ["runtime kernel (fast_fabs, fast_exp)", (v: number) => r[2 * v + 1]!, fastAbs, fastExp],
    ["precompiled ops.sigmoid (air.fabs, air.exp)", (v: number) => precompiled[v]!, pAbs, pExp],
  ] as const) {
    const matches: string[] = [];
    let best = { n: Infinity, label: "", ex: [] as string[] };
    for (const [rl, route] of routes) for (const flushCmp of [false, true]) {
      let n = 0; const ex: string[] = [];
      for (let v = 0; v < 65536; v++) {
        const g = got(v), w = sigModel(v, abs, exT, route, flushCmp);
        if (g !== w && !(Number.isNaN(BV[g]!) && Number.isNaN(BV[w]!))) { n++; if (ex.length < 4) ex.push(`v=${hex(v)} -> ${hex(g)} want ${hex(w)}`); }
      }
      const name = `${rl}, compare ${flushCmp ? "flushed" : "exact"}`;
      if (n === 0) matches.push(name);
      if (n < best.n) best = { n, label: name, ex };
    }
    const c = clause(`bf16 sigmoid ${label} = composition of probed ops (NaN results compared as NaN)`);
    c.cases = 65536;
    if (matches.length) c.info.push(`matching models: ${matches.join(" | ")}`);
    else { c.fails = best.n; c.ex = best.ex; c.info.push(`no model matched; closest: ${best.label}`); }
    report(c);
  }
}

// ---------------------------------------------------------------- lowering verification
if (VERIFY) {
  section("AIR lowering of every probe kernel (runtime-compiled libraries)");
  const funcs = new Map<string, string>();
  const idents = new Set<string>();
  for (const f of readdirSync(KT_DIR).filter(f => f.endsWith(".metallib"))) {
    const dis = sh(["xcrun", "metal-objdump", "-d", join(KT_DIR, f)]);
    for (const m of dis.matchAll(/!"(Apple metal version [^"]+)"/g)) idents.add(m[1]!);
    const parts = dis.split(/^0x[0-9a-f]+ -- (\S+):$/m);
    for (let i = 1; i < parts.length; i += 2) funcs.set(parts[i]!, parts[i + 1]!);
  }
  console.log(`runtime compiler: ${[...idents].join(", ") || "(no llvm.ident found)"}`);
  const c = clause("AIR lowering of probe kernels");
  for (const { name, low } of kernels) {
    const hits = [...funcs].filter(([fn]) => fn.startsWith(`custom_kernel_${name}`));
    c.cases++;
    if (hits.length === 0) { c.fail(`${name}: no runtime library captured`); continue; }
    for (const [fn, text] of hits) {
      const body = text.slice(0, text.search(/^attributes #/m) >>> 0 || undefined);
      const miss = low.require.filter(re => !re.test(body)), bad = (low.forbid ?? []).filter(re => re.test(body));
      const flags = FP_FLAGS.exec(body);
      const calls = [...new Set([...body.matchAll(/@(air\.[a-z_0-9.]+)\(/g)].map(m => m[1]).filter(n => !/^air\.(wg|simdgroup|thread|get)/.test(n!)))];
      console.log(`  ${name}: air calls [${calls.join(", ")}]${flags ? `; fast-math flag '${flags[0]}'` : ""}`);
      if (miss.length || bad.length || flags) c.fail(`${fn}: missing ${miss.join(",")} forbidden ${bad.join(",")} ${flags?.[0] ?? ""}`);
    }
  }
  // Precompiled sigmoid: every bf16 Sigmoid variant in mlx.metallib.
  const lib = process.env.MLX_BUN_LIBMLXC ? join(dirname(process.env.MLX_BUN_LIBMLXC), "mlx.metallib") : "";
  if (lib && existsSync(lib)) {
    const dis = sh(["xcrun", "metal-objdump", "-d", lib]);
    const parts = dis.split(/^0x[0-9a-f]+ -- (\S+):$/m);
    for (let i = 1; i < parts.length; i += 2) if (/^[a-z0-9]+_Sigmoidbfloat16bfloat16$/.test(parts[i]!)) {
      const body = parts[i + 1]!; c.cases++;
      const need = [/@air\.fabs\.f32/, /@air\.exp\.f32/, /fadd bfloat/, /fdiv bfloat/, /fsub bfloat/];
      const miss = need.filter(re => !re.test(body));
      const bad = /@air\.fast_/.test(body) || FP_FLAGS.test(body);
      console.log(`  mlx.metallib ${parts[i]}: ${miss.length || bad ? "UNEXPECTED" : "air.fabs.f32, air.exp.f32, native bfloat fadd/fdiv/fsub"}`);
      if (miss.length || bad) c.fail(`${parts[i]}: missing ${miss.join(",")}${bad ? " has fast ops" : ""}`);
    }
  } else c.info.push("mlx.metallib not found beside MLX_BUN_LIBMLXC; precompiled Sigmoid not checked");
  report(c);
}

// ---------------------------------------------------------------- summary
pool.close();
console.log("== summary");
let failed = 0;
for (const c of clauses.values()) { console.log(`${c.fails ? "FAIL" : "PASS"} ${c.name} (${c.cases})`); if (c.fails) failed++; }
console.log(`${failed} failing clause(s); total ${((performance.now() - T0) / 1000).toFixed(0)} s`);
process.exit(failed ? 1 : 0);
