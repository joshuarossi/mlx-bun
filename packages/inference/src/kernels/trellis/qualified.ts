/** Single-row down representations at the qualified geometry (`scatterBitsEligible`). */
export interface ScatterRepresentation {
  /** Balanced 3-bit decoder value from exact float32 bits. */
  bits: boolean;
  /** The same for 2/4-bit codes. */
  genericBits: boolean;
  /** Generated float32 threadgroup codebook. */
  floatCodebook: boolean;
}

/** What the Trellis kernels take from the GPU family, as explicit arguments.
 *  The single-row representations were measured on the Qwen MLP geometry
 *  (bf16, variant 13); each keeps output bits and is a speed choice. */
export interface TrellisRepresentations {
  /** Threadgroup codebook in the same-width gate/up decode. */
  gateUpCodebook: boolean;
  /** Exact float32 bits in the mixed-width gate/up decoder. */
  mixedExactBits: boolean;
  scatter: ScatterRepresentation;
  /** The bundled runtime reduces M=5..15 matmuls with GemvWide on this GPU, so
   *  wide prefill matches it there and tiled prefill steps aside. */
  widePrefill: boolean;
}

/** The choices qualified on `architecture`: the single-row representations on
 *  `applegpu_g13s` only, wide prefill on GPU family 15 (M3) and newer. A layer
 *  resolves this once, when it is constructed, and passes the stored result to
 *  the kernels on every call. */
export function qualifiedRepresentations(architecture: string): TrellisRepresentations {
  const qualified = architecture === "applegpu_g13s";
  return { gateUpCodebook: qualified, mixedExactBits: qualified,
    scatter: { bits: qualified, genericBits: qualified, floatCodebook: qualified },
    widePrefill: Number(/^applegpu_[a-z](\d{2})/.exec(architecture)?.[1] ?? 0) >= 15 };
}
