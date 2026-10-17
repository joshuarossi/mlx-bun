/** Checks every clause of M1MaxContract.lean (`Contract` and `Pipelines`) on this machine and
 * prints one PASS/FAIL line per Lean field. References implement the Lean definitions
 * (probe-m1max-contract-check.ts). Unary f32 clauses are exhaustive over all 2^32 inputs;
 * bf16 arithmetic and bf16-valued fmax are exhaustive over all finite pairs; binary32
 * arithmetic is structured plus 2^30 random cases per operation; simd_sum/simd_max trees are
 * identified and then replayed; pipeline limits are read from the pipelines MLX creates.
 *   MLX_BUN_LIBMLXC=/path/to/libmlxc.dylib bun proofs/contracts/mlx/probe-m1max-contract.ts \
 *     [--verify-lowering] [--quick]
 * The outer process re-executes itself under ~/mlx-bun-perf/gpu.sh (the machine GPU lock).
 * metal-tracer.m is built and loaded before MLX (it records libraries and pipelines).
 * --verify-lowering disassembles every runtime library MLX compiled with `xcrun metal-objdump -d`
 * and fails unless each probe kernel uses exactly the AIR operation its clause names.
 * --quick samples (1/16 of unary chunks, 1/64 of random counts, 1/128 of bf16 rows) for smoke runs.
 * Exit status 0 iff every clause (and each precondition) passes. */
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { mkdirSync, readdirSync, readFileSync, rmSync } from "node:fs";

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

const { dlopen, FFIType, ptr } = await import("bun:ffi");
const KT_DIR = "/tmp/m1max-contract-lowering";
const kt = (() => {
  const lib = join(KT_DIR + "-lib", "libmetal-tracer.dylib");
  mkdirSync(dirname(lib), { recursive: true });
  const built = Bun.spawnSync(["clang", "-dynamiclib", "-fobjc-arc", "-O1", "-Wno-deprecated-declarations", "-framework", "Foundation",
    "-framework", "Metal", "-o", lib, join(import.meta.dir, "metal-tracer.m")]);
  if (built.exitCode !== 0) throw new Error(`Building the Metal tracer failed: ${built.stderr}`);
  rmSync(KT_DIR, { recursive: true, force: true });
  mkdirSync(KT_DIR, { recursive: true });
  const k = dlopen(lib, {
    kt_init: { args: [FFIType.ptr], returns: FFIType.void },
    kt_dump_pipelines: { args: [FFIType.ptr], returns: FFIType.void },
  }).symbols;
  k.kt_init(ptr(Buffer.from(KT_DIR + "\0")));
  return k;
})();

const { MlxArray } = await import("../../../packages/mlx/src/array.ts");
const { MetalKernel } = await import("../../../packages/mlx/src/metal-kernel.ts");
const { Dtype, clearCache } = await import("../../../packages/mlx/src/ffi.ts");
const ops = await import("../../../packages/mlx/src/ops.ts");
type Arr = InstanceType<typeof MlxArray>;

const { hex, clauses, clause, passed, report, bitsOf, valOf, TINY, fl, sameF, isNaNBits, canon, fmtF, bf16Rne, BV, BVF,
  bfFlush, bfModel, BF_OPS, fmaRO, addRef, mulRef, divRef, fmaRef, addBits, maxValue, maxLess, newStat, Pool } =
  await import("./probe-m1max-contract-check.ts");
type UnaryName = import("./probe-m1max-contract-check.ts").UnaryName;
type Task = import("./probe-m1max-contract-check.ts").Task;
const section = (s: string) => console.log(`-- ${s} (${((performance.now() - T0) / 1000).toFixed(0)} s)`);
const WORKERS = Math.max(2, Number(sh(["sysctl", "-n", "hw.perflevel0.physicalcpu"])) || 8);
const pool = new Pool(WORKERS);
const addrOf = (a: Uint32Array) => Number(ptr(a));

// ---------------------------------------------------------------- clause list = Lean fields
// The clause fields of each structure: fields whose type mentions another field (an operation).
function leanClauses(structure: string): string[] {
  const src = readFileSync(join(import.meta.dir, "M1MaxContract.lean"), "utf8");
  const body = new RegExp(`^structure ${structure} where\\n((?:(?:  .*)?\\n)*)`, "m").exec(src)?.[1];
  if (!body) throw new Error(`structure ${structure} not found in M1MaxContract.lean`);
  const fields: [string, string][] = [];
  for (const line of body.split("\n")) {
    const m = /^  ([A-Za-z_][A-Za-z_0-9]*) : (.*)$/.exec(line);
    if (m) fields.push([m[1]!, m[2]!]); else if (/^   /.test(line) && fields.length) fields[fields.length - 1]![1] += " " + line.trim();
  }
  const names = fields.map(f => f[0]);
  return fields.filter(([n, t]) => names.some(o => o !== n && new RegExp(`(^|[^.\\w])${o}([^\\w]|$)`).test(t))).map(f => f[0]);
}
const FIELDS = ["fadd_model", "fmul_model", "fma_model", "fdiv_model", "rsqrt_normal", "exp_nonpositive", "exp_zero",
  "exp_nonnegative", "exp_small", "exp_overflow", "fastExp_nonpositive", "fastExp_zero", "fastExp_negInf", "fastExp_nonnegative",
  "fastExp_overflow", "exp2_nonpositive", "log_bounded", "fastLog_unit", "fastSin_bounded", "fastCos_bounded", "fmax_value",
  "simdMax_tree", "fabs_value", "fastFabs_value", "simdSum_tree", "threadgroupLoad_contract", "vectorLoad_components",
  "bfadd_model", "bfsub_model", "bfmul_model", "bfdiv_model", "narrow_model", "widen_model"];
const PIPELINE_FIELDS = ["rmsLooped", "logSumExpLooped", "generalCopy2D", "simdWidth"];
for (const [s, mine] of [["Contract", FIELDS], ["Pipelines", PIPELINE_FIELDS]] as const) {
  const lean = leanClauses(s);
  if (lean.join() !== mine.join()) throw new Error(`probe clauses differ from M1MaxContract.lean ${s}: lean [${lean}] probe [${mine}]`);
}
const PRE = ["reference_selftest", ...(VERIFY ? ["lowering"] : [])];
for (const n of [...PRE, ...FIELDS, ...PIPELINE_FIELDS.map(f => `Pipelines.${f}`)]) clause(n);

// ---------------------------------------------------------------- exact references (self-test)
// Exact BigInt rationals for the Lean definitions; the fast references must agree with them.
type Q = { s: number; m: bigint; e: number }; // (-1)^s * m * 2^e
const toQ = (b: number): Q => {
  const ef = (b >>> 23) & 255, mf = b & 0x7fffff;
  return { s: b >>> 31, m: BigInt(ef ? mf | 0x800000 : mf), e: (ef ? ef : 1) - 150 };
};
const bl = (x: bigint) => x === 0n ? 0 : x.toString(2).length;
function roundQ(sign: number, num: bigint, den: bigint, P = 24): number { // RNE of num/den > 0, P-bit significand, gradual underflow
  let E = bl(num) - bl(den);
  const ge = (k: number) => (k >= 0 ? num >= den << BigInt(k) : num << BigInt(-k) >= den);
  if (!ge(E)) E--;
  let Ep = Math.max(E, -126);
  const s = P - 1 - Ep;
  const n = s >= 0 ? num << BigInt(s) : num, d = s >= 0 ? den : den << BigInt(-s);
  let M = n / d; const r2 = (n % d) * 2n;
  if (r2 > d || (r2 === d && (M & 1n) === 1n)) M++;
  if (M === 1n << BigInt(P)) { M = 1n << BigInt(P - 1); Ep++; }
  if (Ep > 127) return sign ? -Infinity : Infinity;
  const v = Number(M) * 2 ** (Ep - P + 1);
  return sign ? -v : v;
}
// below 2^-126: num/den < 2^-126
const belowQ = (num: bigint, den: bigint) => num !== 0n && (num << 126n) < den;
const ratio = (x: Q): [bigint, bigint] => x.e >= 0 ? [x.m << BigInt(x.e), 1n] : [x.m, 1n << BigInt(-x.e)];
function qAdd(a: Q, b: Q): Q {
  const e = Math.min(a.e, b.e);
  const va = (a.s ? -1n : 1n) * (a.m << BigInt(a.e - e)), vb = (b.s ? -1n : 1n) * (b.m << BigInt(b.e - e));
  const v = va + vb;
  return { s: v < 0n ? 1 : 0, m: v < 0n ? -v : v, e };
}
const fq = (v: number) => toQ(bitsOf(fl(v)));
// FlushToZero.flushExact over an exact rational: zero of its sign below 2^-126, else RNE.
function flushExactQ(x: Q, zeroSign: number, P = 24): number {
  if (x.m === 0n) return zeroSign ? -0 : 0;
  const [n, d] = ratio(x);
  if (belowQ(n, d)) return x.s ? -0 : 0;
  return roundQ(x.s, n, d, P);
}
function exactAdd(x: number, y: number) {
  const a = fq(x), b = fq(y), r = qAdd(a, b);
  if (r.m === 0n) return a.m === 0n && b.m === 0n && a.s & b.s ? -0 : 0;
  const [n, d] = ratio(r);
  return fl(roundQ(r.s, n, d));
}
const exactMul = (x: number, y: number) => { const a = fq(x), b = fq(y); return flushExactQ({ s: a.s ^ b.s, m: a.m * b.m, e: a.e + b.e }, a.s ^ b.s); };
function exactDiv(x: number, y: number) {
  const a = fq(x), b = fq(y), s = a.s ^ b.s;
  if (a.m === 0n) return s ? -0 : 0;
  const e = a.e - b.e, n = e >= 0 ? a.m << BigInt(e) : a.m, d = e >= 0 ? b.m : b.m << BigInt(-e);
  return belowQ(n, d) ? (s ? -0 : 0) : roundQ(s, n, d);
}
function exactFma(x: number, y: number, z: number) {
  const a = fq(x), b = fq(y), c = fq(z);
  const p: Q = { s: a.s ^ b.s, m: a.m * b.m, e: a.e + b.e };
  const r = qAdd(p, c);
  return flushExactQ(r, r.m === 0n && p.m === 0n && c.m === 0n ? p.s & c.s : 0);
}
function bfExact(op: number, a: number, b: number): number { // BFloat16Arithmetic, finite inputs
  const qa = toQ(bitsOf(BVF[a]!)), qb = toQ(bitsOf(BVF[b]!));
  const bits = (v: number) => (bitsOf(v) >>> 16) & 0xffff;
  if (op === 0 || op === 1) {
    const qb2 = op === 1 ? { ...qb, s: qb.s ^ 1 } : qb, r = qAdd(qa, qb2);
    if (r.m === 0n) return qa.m === 0n && qb2.m === 0n && qa.s & qb2.s ? 0x8000 : 0;
    const [n, d] = ratio(r);
    return bfFlush(bits(roundQ(r.s, n, d, 8)));
  }
  const sg = qa.s ^ qb.s;
  if (op === 2) return bits(flushExactQ({ s: sg, m: qa.m * qb.m, e: qa.e + qb.e }, sg, 8));
  if (qb.m === 0n) return qa.m === 0n ? 0x7fc0 : sg ? 0xff80 : 0x7f80;
  if (qa.m === 0n) return sg ? 0x8000 : 0;
  const e = qa.e - qb.e, n = e >= 0 ? qa.m << BigInt(e) : qa.m, d = e >= 0 ? qb.m : qb.m << BigInt(-e);
  return belowQ(n, d) ? (sg ? 0x8000 : 0) : bits(roundQ(sg, n, d, 8));
}
section("reference self-test (fast references vs exact BigInt rationals)");
{
  const c = clause("reference_selftest");
  let s = 12345;
  const rnd = () => { s = (Math.imul(s, 1103515245) + 12345) >>> 0; s ^= s >>> 13; s = Math.imul(s, 0x5bd1e995) >>> 0; return s >>> 0; };
  const pick = (exp: number) => valOf((((rnd() & 1) << 31) | (Math.min(254, Math.max(0, exp)) << 23) | (rnd() & 0x7fffff)) >>> 0);
  for (let i = 0; i < 200000; i++) {
    const m = i & 7, ea = rnd() % 255;
    const eb = m < 2 ? rnd() % 255 : m < 4 ? ea + (rnd() % 61) - 30 : m === 4 ? rnd() % 6 : m === 5 ? 128 - ea + (rnd() % 7) - 3 : m === 6 ? 381 - ea + (rnd() % 7) - 3 : ea;
    const a = pick(m === 4 ? rnd() % 6 : ea), b = m === 7 ? -pick(eb) : pick(eb);
    const pc = -Math.fround(a * b), cc = i % 3 === 0 && Number.isFinite(pc) ? pc : i % 3 === 1 ? pick(rnd() % 4) : pick(rnd() % 255);
    const y = valOf(((127 + rnd() % 126) << 23) | (rnd() & 0x7fffff));
    const x = m === 5 ? pick(((bitsOf(y) >>> 23) & 255) - 126 + (rnd() % 7) - 3) : a;
    c.cases += 4;
    if (!sameF(addRef(a, b), exactAdd(a, b))) c.fail(`add ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))}`);
    if (!sameF(mulRef(a, b), exactMul(a, b))) c.fail(`mul ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))}`);
    if (!sameF(divRef(x, y), exactDiv(x, y))) c.fail(`div ${fmtF(bitsOf(x))} ${fmtF(bitsOf(y))}`);
    if (!sameF(fmaRef(a, b, cc), exactFma(a, b, cc))) c.fail(`fma ${fmtF(bitsOf(a))} ${fmtF(bitsOf(b))} ${fmtF(bitsOf(cc))}`);
  }
  for (let i = 0; i < 400000; i++) {
    const a = rnd() & 0xffff; let b = rnd() & 0xffff;
    if (i & 1) b = (b & 0x807f) | (Math.min(254, Math.max(0, ((a >>> 7) & 255) + (rnd() % 21) - 10)) << 7);
    if (i % 5 === 0) b = (a ^ 0x8000) ^ (rnd() & 3);
    if (i % 7 === 0) b = (b & 0x807f) | (Math.min(254, Math.max(0, 254 - ((a >>> 7) & 255) + (rnd() % 9) - 4)) << 7);
    if (i % 11 === 0) b &= 0x807f;
    if (!Number.isFinite(BV[a]!) || !Number.isFinite(BV[b]!)) continue;
    const op = i & 3; c.cases++;
    const fast = bfModel(op, a, b), exact = bfExact(op, a, b);
    if (fast !== exact) c.fail(`bf16 op${op} ${hex(a)} ${hex(b)}: ${hex(fast)} vs ${hex(exact)}`);
  }
  report(c);
  if (c.fails) throw new Error("reference self-test failed; refusing to judge the hardware");
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
const params = (...v: number[]) => {
  const a = Uint32Array.from(v.map(x => x >>> 0));
  return MlxArray.fromBytesCopy(new Uint8Array(a.buffer), [a.length], Dtype.uint32);
};
const fromU32 = (a: Uint32Array, dtype: number = Dtype.uint32) =>
  MlxArray.fromBytesCopy(new Uint8Array(a.buffer, a.byteOffset, a.byteLength), [a.length], dtype);
const CHUNK = 1 << 24;

// ---------------------------------------------------------------- unary exhaustive sweeps
section("unary f32 sweeps over all 2^32 inputs");
const unarySpec: [UnaryName, string, Lowering][] = [
  ["rsqrt", "as_type<uint>(metal::precise::rsqrt(x))", { require: [/@air\.rsqrt\.f32/], forbid: [/@air\.fast_rsqrt/] }],
  ["exp", "as_type<uint>(metal::precise::exp(x))", { require: [/@air\.exp\.f32/], forbid: [/@air\.fast_exp/] }],
  ["fastExp", "as_type<uint>(metal::fast::exp(x))", { require: [/@air\.fast_exp\.f32/], forbid: [/@air\.exp\.f32/] }],
  ["exp2", "as_type<uint>(metal::precise::exp2(x))", { require: [/@air\.exp2\.f32/], forbid: [/@air\.fast_exp2/] }],
  ["log", "as_type<uint>(metal::precise::log(x))", { require: [/@air\.log\.f32/], forbid: [/@air\.fast_log/] }],
  ["fastLog", "as_type<uint>(metal::fast::log(x))", { require: [/@air\.fast_log\.f32/], forbid: [/@air\.log\.f32/] }],
  ["fastSin", "as_type<uint>(metal::fast::sin(x))", { require: [/@air\.fast_sin\.f32/], forbid: [/@air\.sin\.f32/] }],
  ["fastCos", "as_type<uint>(metal::fast::cos(x))", { require: [/@air\.fast_cos\.f32/], forbid: [/@air\.cos\.f32/] }],
  ["fabs", "as_type<uint>(metal::precise::fabs(x))", { require: [/@air\.fabs\.f32/], forbid: [/@air\.fast_fabs/] }],
  ["fastFabs", "as_type<uint>(metal::fast::fabs(x))", { require: [/@air\.fast_fabs\.f32/], forbid: [/@air\.fabs\.f32/] }],
  ["narrow", "uint(as_type<ushort>(bfloat(x)))", { require: [/fptrunc float [^\n]* to bfloat/] }],
];
const stat = newStat();
{
  const ks = unarySpec.map(([n, expr, low]) => [n, kernel(`m1c_u_${n}_v2`, ["p"],
    `uint i = thread_position_in_grid.x; float x = as_type<float>(p[0] + i); out[i] = ${expr};`, low)] as const);
  // --quick: every 16th chunk plus chunk 255 (it holds -inf for fastExp_negInf).
  const chunks = [...Array(256).keys()].filter(ci => !QUICK || ci % 16 === 0 || ci === 255);
  const SLICE = CHUNK / 4;
  let pending: Promise<void> | null = null;
  for (const ci of chunks) {
    const base = ci * CHUNK;
    const p = params(base);
    const outs = ks.map(([, k]) => dispatch(k, [p], CHUNK, CHUNK));
    const tasks: Task[] = [];
    ks.forEach(([n], q) => {
      const rb = u32(outs[q]!);
      for (let lo = 0; lo < CHUNK; lo += SLICE) tasks.push({ kind: "unary", n, base, lo, hi: lo + SLICE, ptr: addrOf(rb), words: CHUNK });
    });
    // Overlap: the next chunk's GPU work is encoded while workers check this one.
    if (pending) await pending;
    pending = pool.run(tasks, stat).then(() => { for (const o of outs) o.dispose(); p.dispose(); });
    if (ci % 32 === 0) clearCache();
  }
  await pending;
  clause("rsqrt_normal").info.push(`observed |r|*sqrt(x) in [${stat.rsqrtMin}, ${stat.rsqrtMax}]`);
  clause("fastExp_nonpositive").info.push(`max fastExp on x<=0 = ${stat.fexpMaxNonpos}`);
  clause("exp_small").info.push(`max exp on |x|<=8 = ${stat.expMaxSmall}`);
  clause("log_bounded").info.push(`max |log| = ${stat.logMaxAbs}`);
  clause("fastLog_unit").info.push(`range [${stat.flogMin}, ${stat.flogMax}]`);
  clause("fastSin_bounded").info.push(`max |sin| = ${stat.sinMax}`);
  clause("fastCos_bounded").info.push(`max |cos| = ${stat.cosMax}`);
  for (const n of ["rsqrt_normal", "exp_nonpositive", "exp_zero", "exp_nonnegative", "exp_small", "exp_overflow", "fastExp_nonpositive",
    "fastExp_zero", "fastExp_negInf", "fastExp_nonnegative", "fastExp_overflow", "exp2_nonpositive", "log_bounded", "fastLog_unit",
    "fastSin_bounded", "fastCos_bounded", "fabs_value", "fastFabs_value", "narrow_model"]) report(clause(n));
}

// ---------------------------------------------------------------- binary arithmetic
section("fadd/fmul/fdiv/fma against FlushToZero.add/mul/div/fma");
const RANDOM_CHUNKS = QUICK ? 1 : 64; // x 2^24 = 2^30 random cases per operation
const binSpec = [
  { op: "fadd", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 0u);",
    expr: "as_type<float>(v.x) + as_type<float>(v.y)", structured: 4080 * 4080,
    low: { require: [/= fadd float /], forbid: [/@air\.fma/, /@air\.fast_/] } },
  { op: "fmul", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 1u);",
    expr: "as_type<float>(v.x) * as_type<float>(v.y)", structured: 4080 * 4080,
    low: { require: [/= fmul float /], forbid: [/@air\.fma/, /@air\.fast_/] } },
  { op: "fdiv", width: 3, gen: "uint2 v = s ? uint2(sv(idx / 1009u), dv(idx % 1009u)) : genDiv(idx, p[1]);",
    expr: "as_type<float>(v.x) / as_type<float>(v.y)", structured: 4080 * 1009,
    low: { require: [/= fdiv float /], forbid: [/@air\.fast_/, /@air\.div/] } },
  { op: "fma", width: 4, gen: "uint3 v = s ? uint3(tv(idx / 25600u), tv((idx / 160u) % 160u), tv(idx % 160u)) : genFma(idx, p[1]);",
    expr: "metal::fma(as_type<float>(v.x), as_type<float>(v.y), as_type<float>(v.z))", structured: 160 ** 3,
    low: { require: [/@air\.fma\.f32/], forbid: [/@air\.fast_/] } },
] as const;
for (const spec of binSpec) {
  const w = spec.width;
  const k = kernel(`m1c_b_${spec.op}_v2`, ["p"], String.raw`
    uint i = thread_position_in_grid.x; uint idx = p[0] + i; bool s = p[2] != 0u;
    if (s && idx >= p[3]) return;
    ${spec.gen}
    out[${w}u * i] = v.x; out[${w}u * i + 1u] = v.y; ${w === 4 ? "out[4u * i + 2u] = v.z;" : ""}
    out[${w}u * i + ${w - 1}u] = as_type<uint>(${spec.expr});`, spec.low);
  const c = clause(`${spec.op}_model`);
  const run = (base: number, n: number, seed: number, structured: boolean) => {
    const p = params(base, seed, structured ? 1 : 0, spec.structured);
    const o = dispatch(k, [p], n * w, n);
    const b = u32(o), f = new Float32Array(b.buffer, b.byteOffset, b.length);
    for (let i = 0, j = 0; i < n; i++, j += w) {
      const a = f[j]!, bb = f[j + 1]!;
      if (!Number.isFinite(a) || !Number.isFinite(bb)) continue;
      let want: number;
      if (w === 4) {
        const cc = f[j + 2]!; if (!Number.isFinite(cc)) continue;
        want = fmaRef(a, bb, cc);
      } else if (spec.op === "fdiv") {
        if (!(bb >= 1 && bb <= 2 ** 126)) continue; // Division.DivisorDomain
        want = divRef(a, bb);
      } else want = spec.op === "fadd" ? addRef(a, bb) : mulRef(a, bb);
      c.cases++;
      if (!sameF(f[j + w - 1]!, want))
        c.fail(`${[...b.subarray(j, j + w - 1)].map(fmtF).join(" ")} -> ${fmtF(b[j + w - 1]!)} want ${fmtF(bitsOf(want))}`);
    }
    o.dispose(); p.dispose();
  };
  for (let base = 0; base < spec.structured; base += CHUNK) run(base, Math.min(CHUNK, spec.structured - base), 0, true);
  const structuredCases = c.cases;
  for (let ch = 0; ch < RANDOM_CHUNKS; ch++) run(ch * CHUNK, CHUNK, 0x51ed27 + ch * 7919, false);
  c.info.push(`${structuredCases} structured + ${c.cases - structuredCases} random`);
  clearCache();
  report(c);
}

// ---------------------------------------------------------------- fmax (binary32 pairs)
section("fmax_value: air.fmax.f32 and air.fast_fmax.f32 (binary32 structured + random)");
const fmaxCases = new Map<string, number>();
{
  const c = clause("fmax_value");
  for (const [label, expr, low] of [
    ["air.fmax.f32", "metal::precise::fmax(a, b)", { require: [/@air\.fmax\.f32/], forbid: [/@air\.fast_fmax/] }],
    ["air.fast_fmax.f32", "metal::fast::fmax(a, b)", { require: [/@air\.fast_fmax\.f32/], forbid: [/@air\.fmax\.f32/] }],
  ] as const) {
    const k = kernel(`m1c_fmax_${label.replace(/\W/g, "_")}_v2`, ["p"], String.raw`
      uint i = thread_position_in_grid.x; uint idx = p[0] + i; bool s = p[2] != 0u;
      if (s && idx >= p[3]) return;
      uint2 v = s ? uint2(sv(idx / 4080u), sv(idx % 4080u)) : genPair(idx, p[1], 0u);
      uint h = h32(idx ^ 0x7a3c19u);
      if (!s && (h & 7u) == 0u) v.y = v.x; else if (!s && (h & 7u) == 1u) v.y = v.x ^ 0x80000000u;
      float a = as_type<float>(v.x), b = as_type<float>(v.y);
      out[3u * i] = v.x; out[3u * i + 1u] = v.y; out[3u * i + 2u] = as_type<uint>(${expr});`, low);
    const before = c.cases;
    const run = (base: number, n: number, seed: number, structured: boolean) => {
      const p = params(base, seed, structured ? 1 : 0, 4080 * 4080);
      const o = dispatch(k, [p], 3 * n, n);
      const b = u32(o);
      for (let i = 0, j = 0; i < n; i++, j += 3) {
        const xb = b[j]!, yb = b[j + 1]!;
        if ((xb & 0x7f800000) === 0x7f800000 || (yb & 0x7f800000) === 0x7f800000) continue;
        c.cases++;
        const want = maxLess(yb, xb) ? xb : yb; // if Maximum.less y x then x else y
        if (b[j + 2] !== want) c.fail(`${label} ${fmtF(xb)} ${fmtF(yb)} -> ${fmtF(b[j + 2]!)} want ${fmtF(want)}`);
      }
      o.dispose(); p.dispose();
    };
    run(0, 4080 * 4080, 0, true);
    for (let ch = 0; ch < (QUICK ? 1 : 4); ch++) run(ch * CHUNK, CHUNK, 0x3c6ef372 + ch, false);
    fmaxCases.set(label, c.cases - before);
  }
}

// ---------------------------------------------------------------- simd_sum
section("simdSum_tree: tree identification and replay");
type Tree = number | [Tree, Tree];
const leaves = (t: Tree): number[] => typeof t === "number" ? [t] : [...leaves(t[0]), ...leaves(t[1])];
const show = (t: Tree): string => typeof t === "number" ? `${t}` : `(${show(t[0])},${show(t[1])})`;
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
// Evaluates a tree of the binary word operation `op` over words x[o..o+31].
function compileTree(t: Tree, op: (a: number, b: number) => number) {
  const lines: string[] = []; let n = 0;
  const emit = (u: Tree): string => {
    if (typeof u === "number") return `x[o+${u}]`;
    const a = emit(u[0]), b = emit(u[1]); const v = `t${n++}`; lines.push(`const ${v}=op(${a},${b});`); return v;
  };
  const r = emit(t);
  return new Function("op", "x", "o", `${lines.join("")}return ${r};`).bind(null, op) as (x: Uint32Array, o: number) => number;
}
// Replays `got` (lane-0 result, 32 input words before it, lane-uniform flag after) against models.
const LANE_OUT = String.raw`
    bool isnanb = (sb & 0x7fffffffu) > 0x7f800000u;
    uint cb = isnanb ? 0x7fc00000u : sb;
    bool same = simd_all(cb == simd_broadcast(cb, 0u));`;
let sumTree: Tree | null = null;
{
  const c = clause("simdSum_tree");
  const kd = kernel("m1c_simdsum_v2", ["v"], String.raw`
    uint gid = thread_position_in_grid.x;
    float s = simd_sum(as_type<float>(v[gid]));
    uint sb = as_type<uint>(s);
    if (thread_index_in_simdgroup == 0u) out[gid >> 5] = sb;`,
    { require: [/@air\.simd_sum\.f32/] });
  const BIG = 0x4c000000, NBIG = 0xcc000000, ONE = 0x3f800000; // 2^25, -2^25, 1
  const trip: [number, number, number][] = [];
  for (let j = 0; j < 32; j++) for (let k = j + 1; k < 32; k++) for (let i = 0; i < 32; i++) if (i !== j && i !== k) trip.push([j, k, i]);
  const v = new Uint32Array(trip.length * 32);
  trip.forEach(([j, k, i], q) => { v[q * 32 + j] = BIG; v[q * 32 + k] = NBIG; v[q * 32 + i] = ONE; });
  const va = fromU32(v); const o = dispatch(kd, [va], trip.length, trip.length * 32, Dtype.uint32, 256);
  const r = u32(o);
  const lca = [...Array(32)].map(() => new Array(32).fill(2));
  let odd = 0;
  trip.forEach(([j, k], q) => {
    const x = r[q]!;
    if (x === 0) { lca[j]![k]++; lca[k]![j]++; } else if (x !== ONE) odd++;
  });
  o.dispose(); va.dispose();
  const t = odd ? `identification saw ${odd} results other than 0 or 1` : buildTree(lca);
  if (typeof t === "string") c.fail(`no binary tree of flushed adds: ${t}`);
  else {
    sumTree = t;
    if (!leaves(t).sort((a, b) => a - b).every((x, i) => x === i)) c.fail(`tree leaves are not a permutation of 0..31`);
    c.info.push(`tree ${show(t)}`);
    const ev = compileTree(sumTree, addBits); // FlushedReduction.evaluate
    const kr = kernel("m1c_simdsum_rand_v2", ["p"], String.raw`
      uint gid = thread_position_in_grid.x, lane = thread_index_in_simdgroup, vec = p[0] + (gid >> 5);
      uint xb = laneVal(vec, lane, p[1], p[2]);
      float s = simd_sum(as_type<float>(xb));
      uint sb = as_type<uint>(s);${LANE_OUT}
      uint o = 34u * (gid >> 5);
      out[o + lane] = xb;
      if (lane == 0u) { out[o + 32u] = sb; out[o + 33u] = same ? 1u : 0u; }`,
      { require: [/@air\.simd_sum\.f32/] });
    const VEC = 1 << 20;
    let finite = 0, inf = 0, nan = 0;
    const run = (chunk: number, nonfinite: boolean) => {
      const p = params(chunk * VEC, 0x2b7e1516 + chunk * 104729 + (nonfinite ? 1 : 0), nonfinite ? 1 : 0);
      const o = dispatch(kr, [p], VEC * 34, VEC * 32);
      const b = u32(o);
      for (let q = 0, off = 0; q < VEC; q++, off += 34) {
        let anyInf = false, anyNaN = false;
        for (let l = 0; l < 32; l++) { const x = b[off + l]!; if ((x & 0x7f800000) === 0x7f800000) { if (x & 0x7fffff) anyNaN = true; else anyInf = true; } }
        if (anyNaN) nan++; else if (anyInf) inf++; else finite++;
        c.cases++;
        const got = canon(b[off + 32]!), want = ev(b, off);
        const lanes = () => `lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}]`;
        if (b[off + 33] !== 1) c.fail(`${lanes()}: lanes disagree`);
        else if (got !== want) c.fail(`${lanes()} -> ${hex(b[off + 32]!)} want ${hex(want)}`);
      }
      o.dispose(); p.dispose();
    };
    const N = QUICK ? 2 : 96; // 96 x 2^20 = 100,663,296 vectors
    for (let ch = 0; ch < N; ch++) run(ch, false);
    for (let ch = 0; ch < (QUICK ? 1 : 4); ch++) run(1000 + ch, true);
    c.info.push(`${finite} finite, ${inf} with infinite and no NaN lanes, ${nan} with NaN lanes; NaN words compared through Float32.ofBits`);
    clearCache();
  }
  report(c);
}

// ---------------------------------------------------------------- simd_max
section("simdMax_tree: Maximum.tree replay (all-finite lanes)");
{
  const c = clause("simdMax_tree");
  // For inputs without NaN every tree whose in-order leaves are 0..31 gives the first lane holding
  // the largest flushed value; NaN lanes depend on the tree shape, so candidate trees are replayed.
  const balanced = (lo: number, hi: number): Tree => hi - lo === 1 ? lo : [balanced(lo, (lo + hi) >> 1), balanced((lo + hi) >> 1, hi)];
  let fold: Tree = 0; for (let l = 1; l < 32; l++) fold = [fold, l];
  const candidates: [string, Tree][] = [["balanced in-order", balanced(0, 32)], ["left fold 0..31", fold]];
  if (sumTree) candidates.push(["simd_sum tree", sumTree]);
  const evs = candidates.map(([, t]) => compileTree(t, maxValue)); // Maximum.tree
  const miss = candidates.map(() => ({ n: 0, finite: 0, ex: [] as string[] }));
  let finite = 0, inf = 0, nan = 0, disagree = 0;
  const lanesStr = (b: Uint32Array, off: number) => `lanes [${[...b.subarray(off, off + 32)].map(hex).join(",")}]`;
  const check = (b: Uint32Array, off: number, got: number, same: boolean) => {
    let anyInf = false, anyNaN = false;
    for (let l = 0; l < 32; l++) { const x = b[off + l]!; if ((x & 0x7f800000) === 0x7f800000) { if (x & 0x7fffff) anyNaN = true; else anyInf = true; } }
    // simdMax_tree quantifies over all-finite lane vectors only.
    if (anyNaN) { nan++; return; } else if (anyInf) { inf++; return; } else finite++;
    c.cases++;
    if (!same) { disagree++; if (c.ex.length < 6) c.ex.push(`${lanesStr(b, off)}: lanes disagree`); }
    evs.forEach((ev, q) => {
      const want = canon(ev(b, off));
      if (canon(got) !== want) {
        const m = miss[q]!; m.n++; if (!anyNaN) m.finite++;
        if (m.ex.length < 6) m.ex.push(`${lanesStr(b, off)} -> ${hex(got)} want ${hex(want)}`);
      }
    });
  };
  const kd = kernel("m1c_simdmax_v2", ["v"], String.raw`
    uint gid = thread_position_in_grid.x;
    float s = simd_max(as_type<float>(v[gid]));
    uint sb = as_type<uint>(s);${LANE_OUT}
    if (thread_index_in_simdgroup == 0u) { out[2u * (gid >> 5)] = sb; out[2u * (gid >> 5) + 1u] = same ? 1u : 0u; }`,
    { require: [/@air\.simd_max\.f32/] });
  // Structured: +0 at lane i and -0 at lane j over -1; one NaN (quiet, signaling, negative) at lane k over 1.0 or ascending lanes.
  const rows: Uint32Array[] = [];
  for (let i = 0; i < 32; i++) for (let j = 0; j < 32; j++) if (i !== j) {
    const v = new Uint32Array(32).fill(0xbf800000); v[i] = 0; v[j] = 0x80000000; rows.push(v);
  }
  for (const nanWord of [0x7fc00000, 0x7fa00001, 0xffc00001]) for (let k = 0; k < 32; k++) {
    const flat = new Uint32Array(32).fill(0x3f800000); flat[k] = nanWord; rows.push(flat);
    const up = Uint32Array.from({ length: 32 }, (_, l) => bitsOf(l + 1)); up[k] = nanWord; rows.push(up);
  }
  for (let k = 0; k < 32; k++) { const v = new Uint32Array(32).fill(0x3f800000); v[k] = 0x7f800000; rows.push(v); v[(k + 1) % 32] = 0xff800000; }
  const v = new Uint32Array(rows.length * 32); rows.forEach((r, q) => v.set(r, q * 32));
  const va = fromU32(v), o = dispatch(kd, [va], rows.length * 2, rows.length * 32);
  const r = u32(o);
  const single = new Map<number, number>(); // NaN lane k over 1.0 -> result
  rows.forEach((_, q) => {
    check(v, q * 32, r[2 * q]!, r[2 * q + 1] === 1);
    if (q >= 992 && (q - 992) % 2 === 0 && (q - 992) < 64) single.set((q - 992) / 2, r[2 * q]!);
  });
  o.dispose(); va.dispose();
  const kr = kernel("m1c_simdmax_rand_v2", ["p"], String.raw`
    uint gid = thread_position_in_grid.x, lane = thread_index_in_simdgroup, vec = p[0] + (gid >> 5);
    uint xb = laneVal(vec, lane, p[1], p[2]);
    float s = simd_max(as_type<float>(xb));
    uint sb = as_type<uint>(s);${LANE_OUT}
    uint o = 34u * (gid >> 5);
    out[o + lane] = xb;
    if (lane == 0u) { out[o + 32u] = sb; out[o + 33u] = same ? 1u : 0u; }`,
    { require: [/@air\.simd_max\.f32/] });
  const VEC = 1 << 20;
  const run = (ch: number, nonfinite: boolean) => {
    const p = params(ch * VEC, 0x9e3779b9 + ch * 31337, nonfinite ? 1 : 0);
    const o = dispatch(kr, [p], VEC * 34, VEC * 32);
    const b = u32(o);
    for (let q = 0, off = 0; q < VEC; q++, off += 34) check(b, off, b[off + 32]!, b[off + 33] === 1);
    o.dispose(); p.dispose();
  };
  for (let ch = 0; ch < (QUICK ? 1 : 16); ch++) run(ch, false);
  for (let ch = 0; ch < (QUICK ? 1 : 4); ch++) run(100 + ch, true);
  // Pass iff the lanes agree and some candidate tree reproduces every vector.
  let best = 0; miss.forEach((m, q) => { if (m.n < miss[best]!.n) best = q; });
  c.fails = disagree + miss[best]!.n;
  for (const e of miss[best]!.ex) if (c.ex.length < 6) c.ex.push(`[${candidates[best]![0]}] ${e}`);
  c.info.push(`${finite} finite, ${inf} with infinite and no NaN lanes, ${nan} with NaN lanes`);
  c.info.push(`mismatches per candidate tree: ${candidates.map(([n], q) => `${n} ${miss[q]!.n} (${miss[q]!.finite} without NaN)`).join(", ")}`);
  const ignored = [...single.values()].filter(x => x === 0x3f800000).length;
  if (ignored === 32) c.info.push("a single NaN lane over 1.0 gives 1.0 at every lane position; in Maximum.tree a NaN at the leftmost leaf reaches the root, so no tree reproduces NaN inputs");
  else c.info.push(`single NaN lane over 1.0: ${ignored}/32 lane positions give 1.0`);
  clearCache();
  report(c);
}

// ---------------------------------------------------------------- loads
section("threadgroupLoad_contract and vectorLoad_components");
{
  const src = readFileSync(join(import.meta.dir, "../../../packages/inference/src/kernels/trellis/codebook.ts"), "utf8");
  const win = /export const CODEBOOK_WINDOW = String\.raw`([\s\S]*?)`;/.exec(src)?.[1];
  if (!win) throw new Error("CODEBOOK_WINDOW not found");
  const k = kernel("m1c_tgload_v2", ["p"], String.raw`
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
  const c = clause("threadgroupLoad_contract");
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

  const kv = kernel("m1c_vec4_v2", ["src", "perm"], String.raw`
    uint i = thread_position_in_grid.x, e = perm[i];
    float4 v = ((const device float4*)src)[e];
    out[4u * i] = v.x; out[4u * i + 1u] = v.y; out[4u * i + 2u] = v.z; out[4u * i + 3u] = v.w;`,
    { require: [/load <4 x float>, <4 x float> addrspace\(1\)\*/] });
  const cv = clause("vectorLoad_components");
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
section("bf16: widen, native arithmetic and bf16-valued fmax (exhaustive over finite pairs)");
const BF_ROWS = QUICK ? 512 : 65536;
{
  {
    const k = kernel("m1c_bf16_widen_v2", ["p"], String.raw`
      uint i = thread_position_in_grid.x; const T v = as_type<T>(ushort(i)); out[i] = as_type<uint>(float(v));`,
      { require: [/fpext bfloat [^\n]* to float/] });
    const p = params(0), o = dispatch(k, [p], 65536, 65536, Dtype.uint32, 256, { T: Dtype.bfloat16 });
    const r = u32(o).slice(); o.dispose(); p.dispose();
    const c = clause("widen_model");
    for (let h = 0; h < 65536; h++) {
      if (!Number.isFinite(BV[h]!)) continue;
      c.cases++; if (r[h] !== ((h << 16) >>> 0)) c.fail(`${hex(h)} -> ${hex(r[h]!)} want ${hex(h << 16)}`);
    }
    report(c);
  }
  const bfOps = [["add", "+", /fadd bfloat/], ["sub", "-", /fsub bfloat/], ["mul", "*", /fmul bfloat/], ["div", "/", /fdiv bfloat/]] as const;
  for (const [oi, [name, sym, re]] of bfOps.entries()) {
    const k = kernel(`m1c_bf16_${name}_v2`, ["p"], String.raw`
      uint i = thread_position_in_grid.x, a = p[0] + (i >> 16), b = i & 0xffffu;
      const T x = as_type<T>(ushort(a)), y = as_type<T>(ushort(b));
      const T r = x ${sym} y;
      out[i] = uint(as_type<ushort>(r));`, { require: [re], forbid: [/@air\.fast_/] });
    const ROWS = 256;
    let pending: Promise<void> | null = null;
    for (let a0 = 0; a0 < BF_ROWS; a0 += ROWS) {
      const p = params(a0), o = dispatch(k, [p], ROWS * 65536, ROWS * 65536, Dtype.uint32, 256, { T: Dtype.bfloat16 });
      const r = u32(o), tasks: Task[] = [];
      for (let lo = 0; lo < ROWS; lo += 16) tasks.push({ kind: "bf16op", oi, a0, lo, hi: lo + 16, ptr: addrOf(r), words: r.length });
      if (pending) await pending;
      pending = pool.run(tasks).then(() => { o.dispose(); p.dispose(); });
    }
    await pending;
    report(clause(BF_OPS[oi]!));
  }
  {
    const k = kernel("m1c_bf16_fmax_v2", ["p"], String.raw`
      uint i = thread_position_in_grid.x, a = p[0] + (i >> 16), b = i & 0xffffu;
      float x = as_type<float>(a << 16), y = as_type<float>(b << 16);
      out[2u * i] = as_type<uint>(metal::fast::fmax(x, y)); out[2u * i + 1u] = as_type<uint>(metal::precise::fmax(x, y));`,
      { require: [/@air\.fast_fmax\.f32/, /@air\.fmax\.f32/] });
    const before = clause("fmax_value").cases;
    const ROWS = 128;
    let pending: Promise<void> | null = null;
    for (let a0 = 0; a0 < BF_ROWS; a0 += ROWS) {
      const p = params(a0), o = dispatch(k, [p], 2 * ROWS * 65536, ROWS * 65536);
      const r = u32(o), tasks: Task[] = [];
      for (let lo = 0; lo < ROWS; lo += 8) tasks.push({ kind: "fmaxbf16", a0, lo, hi: lo + 8, ptr: addrOf(r), words: r.length });
      if (pending) await pending;
      pending = pool.run(tasks).then(() => { o.dispose(); p.dispose(); });
    }
    await pending;
    const c = clause("fmax_value");
    c.info.push(`binary32 structured+random: ${[...fmaxCases].map(([k, n]) => `${k} ${n}`).join(", ")}; ` +
      `all finite bf16-valued pairs x 2 ops: ${c.cases - before}`);
    report(c);
  }
  clearCache();
}

// ---------------------------------------------------------------- pipelines
section("Pipelines: limits of the compute pipelines MLX creates");
{
  const bf = (n: number, f: (i: number) => number) => {
    const h = new Uint16Array(n); for (let i = 0; i < n; i++) h[i] = bf16Rne(bitsOf(f(i)));
    return MlxArray.fromBytesCopy(new Uint8Array(h.buffer), [n], Dtype.bfloat16);
  };
  // rms_looped (axis 5120 > 4096), looped logsumexp (axis 248320), KV-row slice update (gg2 copy).
  const x = bf(5120, i => Math.sin(i)), wt = bf(5120, () => 1);
  const x2 = ops.reshape(x, [1, 5120]);
  ops.rmsNorm(x2, wt, 1e-6).eval().dispose();
  const l = bf(248320, i => Math.cos(i) * 4), l2 = ops.reshape(l, [1, 248320]);
  ops.logsumexpAxis(l2, 1, true).eval().dispose();
  const cache = ops.zeros([1, 4, 64, 256], Dtype.bfloat16), row = ops.reshape(bf(1024, i => i / 1024), [1, 4, 1, 256]);
  ops.sliceUpdate(cache, row, [0, 0, 5, 0], [1, 4, 6, 256]).eval().dispose();
  for (const a of [x, wt, x2, l, l2, cache, row]) a.dispose();
  const path = join(KT_DIR, "pipelines.tsv");
  kt.kt_dump_pipelines(ptr(Buffer.from(path + "\0")));
  const pipes = readFileSync(path, "utf8").trim().split("\n").map(s => s.split("\t"))
    .map(([name, , origin, maxTotal, width]) => ({ name: name!, origin: origin!, maxTotal: Number(maxTotal), width: Number(width) }));
  for (const [field, fn] of [["rmsLooped", "rms_loopedbfloat16"], ["logSumExpLooped", "looped_logsumexp_bfloat16"],
    ["generalCopy2D", "gg2_copybfloat16bfloat16"]] as const) {
    const c = clause(`Pipelines.${field}`), hits = pipes.filter(p => p.name === fn);
    if (!hits.length) c.fail(`no pipeline for ${fn} was created`);
    for (const p of hits) { c.cases++; if (p.maxTotal !== 1024) c.fail(`${fn} (${p.origin}) maxTotalThreadsPerThreadgroup ${p.maxTotal}`); }
    c.info.push(`${fn} maxTotalThreadsPerThreadgroup ${hits.map(p => p.maxTotal).join(",")}`);
    report(c);
  }
  const c = clause("Pipelines.simdWidth");
  for (const p of pipes) { c.cases++; if (p.width !== 32) c.fail(`${p.name} threadExecutionWidth ${p.width}`); }
  c.info.push(`every pipeline created by this probe (${pipes.length}); maxTotalThreadsPerThreadgroup values seen: ` +
    [...new Set(pipes.map(p => p.maxTotal))].sort((a, b) => a - b).join(","));
  report(c);
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
  const c = clause("lowering");
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
  report(c);
}

// ---------------------------------------------------------------- summary
pool.close();
console.log("== summary (preconditions, then M1MaxContract.lean fields in declaration order)");
let failed = 0;
for (const c of clauses.values()) { console.log(`${passed(c) ? "PASS" : "FAIL"} ${c.name} (${c.cases})`); if (!passed(c)) failed++; }
console.log(`${failed} failing clause(s); total ${((performance.now() - T0) / 1000).toFixed(0)} s`);
process.exit(failed ? 1 : 0);
