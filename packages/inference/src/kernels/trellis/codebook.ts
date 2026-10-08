import { MlxArray } from "@mlx-bun/mlx/array";

/** The only definition of the 1MAD decode arithmetic; every kernel header includes it. */
export const HEADER = String.raw`
static inline float trellis_bf16(float v) {
  uint u = as_type<uint>(v);
  u = (u + 0x7FFFu + ((u >> 16) & 1u)) & 0xFFFF0000u;
  return as_type<float>(u);
}
// QTIP 1MAD computed code for state s: x = s*34038481 + 76625530 (mod 2^32),
// y = sum of the four bytes of x - 510, value = y / 147.800537109375. Two
// byte-pair adds replace the four extracts; precise divide matches the host
// LUT (lut1mad below) bit for bit.
static inline int trellis_y(uint s) {
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}
static inline float trellis_val(uint s) {
  return metal::precise::divide((float)trellis_y(s), 147.800537109375f);
}
// y × (1/d) refined by one residual step: q' = fma(fma(-q, d, y), 1/d, q).
// Correctly rounded for every y in [-510, 510] (checked host-side against
// the LUT), 3 FMA-class ops instead of a precise divide. Every expansion and
// prefill kernel that reproduces the host LUT decodes through this.
static inline float trellis_refined_y(int y) {
  const float yf = (float)y;
  const float r = 1.0f / 147.800537109375f;
  const float q = yf * r;
  const float e = metal::fma(-q, 147.800537109375f, yf);
  return metal::fma(e, r, q);
}
static inline float trellis_val_rcp(uint s) { return trellis_refined_y(trellis_y(s)); }
// Unrefined y × (1/d) (≤1 ulp f32): the packed matvec/scatter weight is this
// f32 code value, a different numerical contract from the LUT-exact decode above.
static inline float trellis_unrefined_y(int y) {
  return (float)y * (1.0f / 147.800537109375f);
}
// For y in [-510, 510], 2^23 has unit f32 spacing, so setting its low
// mantissa bits constructs 2^23+y+510 exactly. Subtracting 2^23+510
// recovers the same f32 y as the integer conversion; the reciprocal is unchanged.
static inline float trellis_unrefined_bits_y(int y) {
  const float lifted = as_type<float>(0x4b000000u | uint(y + 510));
  return (lifted - 8389118.0f) * (1.0f / 147.800537109375f);
}
// VARIANT: 0 = inline 1MAD + precise divide; 1 = inline 1MAD × reciprocal
// (1 ulp risk vs the host LUT); 2 = 4096-entry f32 LUT in threadgroup memory;
// 3 = the same LUT gathered from device memory.
// 4 = NO decode (timing floor only, wrong numerics); 5 = rcp decode, no bf16
// rounding; 6 = unrefined y×(1/d) (≤1 ulp f32), no bf16 rounding — the
// weight is f32 code×scale, more accurate than the artifact's stored bf16.
#define TRELLIS_DECODE(win, lutTG, lut) \
  ((VARIANT) == 0 ? trellis_val(win) : \
   (VARIANT) == 1 || (VARIANT) == 5 ? trellis_val_rcp(win) : \
   (VARIANT) == 6 ? trellis_unrefined_y(trellis_y(win)) : \
   (VARIANT) == 2 ? lutTG[win] : \
   (VARIANT) == 4 ? (float)(win) : lut[win])
#define TRELLIS_ROUND(v) ((VARIANT) >= 4 ? (v) : trellis_bf16(v))
// state_t of one packed block: L bits at offset (BT-1-t)*K, wrapping (32-bit ops).
static inline uint trellis_state(const device uint32_t* blk, uint wpb, uint t, uint bt, uint k, uint l) {
  const uint p = (bt - 1u - t) * k;
  const uint wi = p >> 5;
  const uint off = p & 31u;
  uint win = blk[wi] >> off;
  if (off + l > 32u) win |= blk[(wi + 1u == wpb) ? 0u : (wi + 1u)] << (32u - off);
  return win & ((1u << l) - 1u);
}
`;

export function lut1mad(L: number): Float32Array {
  const n = 1 << L;
  const out = new Float32Array(n);
  const M = (1n << 32n) - 1n;
  for (let i = 0; i < n; i++) {
    let x = BigInt(i) & M;
    x = (x * 34038481n + 76625530n) & M;
    const y =
      Number((x & 255n) + ((x >> 8n) & 255n) + ((x >> 16n) & 255n) + ((x >> 24n) & 255n)) - 510;
    out[i] = y / 147.800537109375;
  }
  return out;
}

export function wordsPerBlock(T: number, k: number): number {
  if ((T * k) % 32 !== 0) throw new Error(`T·k = ${T * k} not a multiple of 32`);
  return (T * k) / 32;
}

const luts = new Map<number, MlxArray>();
export function lutFor(L: number): MlxArray {
  let a = luts.get(L);
  if (!a) { a = MlxArray.fromFloat32(lut1mad(L), [1 << L]); a.eval(); luts.set(L, a); }
  return a;
}

// Variants 7..13 retain variant 6 decoded values.
export function decoderVariant(selected: number): number { return selected >= 7 && selected <= 13 ? 6 : selected; }
