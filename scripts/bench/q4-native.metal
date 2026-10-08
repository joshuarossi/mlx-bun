#include <metal_stdlib>
#include <metal_simdgroup_matrix>
using namespace metal;
#pragma clang fp reassociate(off)

// Lab affine-Q4 verifier. Each simdgroup unpacks one output channel's weights
// once and reuses them across a proposal window. No dense weight workspace.
// Deliberately simple reduction; this is NOT asserted bit-equal to MLX QMM.
template <ushort Rows>
void q4_tile(device const bfloat* x, device const uint* w,
             device const bfloat* scales, device const bfloat* biases,
             device bfloat* y, constant uint3& shape, uint n, ushort lane) {
  const uint M = shape.x, N = shape.y, K = shape.z;
  float sums[Rows];
  for (ushort m = 0; m < Rows; ++m) sums[m] = 0;
  for (uint k = lane * 8; k < K; k += 256) {
    const uint bits = w[n * (K / 8) + k / 8];
    const uint group = n * (K / 64) + k / 64;
    const float scale = float(scales[group]), bias = float(biases[group]);
    for (ushort j = 0; j < 8; ++j) {
      // Half has unit spacing at 1024: every Q4 code is recovered exactly.
      const half q = as_type<half>(ushort(0x6400 | ((bits >> (4 * j)) & 15))) - half(1024);
      const float weight = fma(float(q), scale, bias);
      for (ushort m = 0; m < Rows; ++m)
        if (m < M) sums[m] = fma(float(x[m * K + k + j]), weight, sums[m]);
    }
  }
  for (ushort m = 0; m < Rows; ++m) {
    const float value = simd_sum(sums[m]);
    if (lane == 0 && m < M) y[m * N + n] = bfloat(value);
  }
}
#define ENTRY(R) \
kernel void q4_rows##R(device const bfloat* x [[buffer(0)]], device const uint* w [[buffer(1)]], \
  device const bfloat* scales [[buffer(2)]], device const bfloat* biases [[buffer(3)]], \
  device bfloat* y [[buffer(4)]], constant uint3& shape [[buffer(5)]], \
  uint n [[threadgroup_position_in_grid]], ushort lane [[thread_index_in_simdgroup]]) { \
  q4_tile<R>(x, w, scales, biases, y, shape, n, lane); }
ENTRY(1)
ENTRY(2)
ENTRY(4)
ENTRY(8)
ENTRY(16)

// Second lab candidate: register-only 8x8 matrix products. Every Q4
// fragment feeds eight activation rows, with no decoded-weight workspace.
// SIMD fragment coordinates follow MLX steel/gemm/mma.h's Metal lane layout.
kernel void q4_mma(device const bfloat* x [[buffer(0)]], device const uint* w [[buffer(1)]],
  device const bfloat* scales [[buffer(2)]], device const bfloat* biases [[buffer(3)]],
  device bfloat* y [[buffer(4)]], constant uint3& shape [[buffer(5)]],
  uint2 tile [[threadgroup_position_in_grid]], ushort lane [[thread_index_in_simdgroup]]) {
  const uint M = shape.x, N = shape.y, K = shape.z;
  const uint fm = ((lane / 4) & 4) + ((lane / 2) % 4);
  const uint fn = ((lane / 4) & 2) * 2 + (lane % 2) * 2;
  const uint m = tile.y * 8 + fm, n = tile.x * 8 + fn;
  float2 result = 0;
  for (uint g = 0; g < K / 64; ++g) {
    simdgroup_float8x8 dot;
    dot.thread_elements()[0] = 0;
    dot.thread_elements()[1] = 0;
    float sum = 0;
    for (uint k = 0; k < 64; k += 8) {
      simdgroup_float8x8 a;
      simdgroup_half8x8 b;
      const float x0 = m < M ? float(x[m * K + g * 64 + k + fn]) : 0;
      const float x1 = m < M ? float(x[m * K + g * 64 + k + fn + 1]) : 0;
      a.thread_elements()[0] = x0;
      a.thread_elements()[1] = x1;
      sum += x0 + x1;
      for (ushort j = 0; j < 2; ++j) {
        const uint bits = n + j < N ? w[(n + j) * (K / 8) + g * 8 + k / 8] : 0;
        b.thread_elements()[j] = as_type<half>(ushort(0x6400 | ((bits >> (4 * fm)) & 15))) - half(1024);
      }
      simdgroup_multiply_accumulate(dot, a, b, dot);
    }
    // Four lanes with the same fragment row cover its 64 activations.
    sum += simd_shuffle_xor(sum, 1);
    sum += simd_shuffle_xor(sum, 8);
    for (ushort j = 0; j < 2; ++j) if (n + j < N) {
      const uint coefficient = (n + j) * (K / 64) + g;
      result[j] = fma(dot.thread_elements()[j], float(scales[coefficient]), result[j]);
      result[j] = fma(sum, float(biases[coefficient]), result[j]);
    }
  }
  for (ushort j = 0; j < 2; ++j)
    if (m < M && n + j < N) y[m * N + n + j] = bfloat(result[j]);
}

kernel void exact_operands(device float2* out [[buffer(0)]], uint i [[thread_position_in_grid]]) {
  out[i] = float2(float(as_type<half>(ushort(0x6400 | (i & 15))) - half(1024)),
                  float(as_type<bfloat>(ushort(i))));
}
