// Quantize a DeepSpec-format drafter checkpoint (Phase 1a of the DSpark
// serving program, docs/design/speculative-decoding.md).
//
// Thin policy layer over the house quantizer (src/quantize): the generic
// shape-eligibility rule already captures every 2-D matmul weight — the
// layer projections, fc, lm_head, markov_w2, and the two gather tables
// (embed_tokens, markov_w1: quantized-embedding gather-dequant at load,
// mlx QuantizedEmbedding semantics). The drafter-specific overlay:
//
//   KEEP bf16: confidence_head.* — threshold-sensitive (the truncation
//   comparison runs on its sigmoid; borderline flips change proposal
//   lengths) and tiny (~4k params), so quantizing it buys nothing.
//   Norms / layer_scalar / biases are 1-D and never shape-eligible.
//
// Drafter numerics only move ACCEPTANCE, never correctness (the target
// verifies every draft) — the quality gate for any scheme swept through
// here is the Phase-1c acceptance A/B, not a KL battery.

import { quantizeModelDir, type QuantizeResult } from "../../quantize";
import { DeepspecDrafter } from "./deepspec-module";
import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";

/** Module bases kept full-precision regardless of shape eligibility. */
const KEEP_BF16 = [/^confidence_head\./];

/** The drafter per-tensor policy: quantize everything shape-eligible
 *  except the KEEP_BF16 set. */
export function drafterQuantizePredicate(base: string): boolean {
  return !KEEP_BF16.some((re) => re.test(base));
}

export interface QuantizeDrafterOptions {
  bits: 4 | 8;
  groupSize: 32 | 64;
  /** Skip the post-write load smoke (tests exercise loading separately). */
  skipLoadSmoke?: boolean;
  onProgress?: (stage: string, message: string, progress: number) => void;
}

/**
 * Quantize the DeepSpec drafter at `srcDir` into `outDir` and smoke the
 * result: reload through DeepspecDrafter (quantized detection + graph
 * build) and eval one projectContext row through the quantized fc path.
 */
export async function quantizeDrafterDir(
  srcDir: string,
  outDir: string,
  opts: QuantizeDrafterOptions,
): Promise<QuantizeResult> {
  const raw = (await Bun.file(`${srcDir}/config.json`).json()) as Record<string, any>;
  if (raw.architectures?.[0] !== "Gemma4DSparkModel")
    throw new Error(
      `quantizeDrafterDir: expected a DeepSpec checkpoint (architectures[0]==="Gemma4DSparkModel"), got ${JSON.stringify(raw.architectures)} — for regular models use \`mlx-bun quantize\``,
    );
  if (raw.quantization ?? raw.quantization_config)
    throw new Error("quantizeDrafterDir: source is already quantized — start from the bf16 checkpoint");

  const result = await quantizeModelDir(
    srcDir,
    outDir,
    {
      bits: opts.bits,
      groupSize: opts.groupSize,
      quantizePredicate: drafterQuantizePredicate,
    },
    opts.onProgress ? (e) => opts.onProgress!(e.stage, e.message, e.progress) : undefined,
  );

  if (!opts.skipLoadSmoke) {
    // Load smoke: quantized detection + one real quantized matmul (fc) so a
    // wrong spec/layout fails HERE, not at serve time.
    const d = await DeepspecDrafter.load(outDir);
    try {
      const width = d.tapLayers.length * d.hidden;
      const zeros = MlxArray.fromFloat32(new Float32Array(width), [1, 1, width]);
      const x = zeros.astype(Dtype.bfloat16);
      zeros.dispose();
      const proj = d.projectContext(x);
      x.dispose();
      const got = proj.shape;
      proj.dispose();
      if (got.length !== 3 || got[2] !== d.hidden)
        throw new Error(`load smoke: projectContext shape ${JSON.stringify(got)}, expected [1,1,${d.hidden}]`);
    } finally {
      d.dispose();
    }
  }

  return result;
}
