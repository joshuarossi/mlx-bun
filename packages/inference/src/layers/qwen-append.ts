// MLX 0.32.2, mlx/backend/metal/scaled_dot_product_attention.cpp (MIT):
// https://github.com/ml-explore/mlx/blob/v0.32.2/mlx/backend/metal/scaled_dot_product_attention.cpp
// For the qualified Qwen GQA-6/D256 graph on applegpu_g16s, one-pass/vector
// selection and two-pass block counts change after these inclusive KV lengths.
// A committed span must stay within one arithmetic regime to match M=1.
const ATTENTION_BOUNDARIES = [1023, 1024, 8192, 32768, 65536];

export function qwenAppendChunkSize(cacheTokens: number): number {
  for (const end of ATTENTION_BOUNDARIES)
    if (cacheTokens < end) return Math.min(4, end - cacheTokens);
  return 4;
}
