import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.QuantizedEmbedding
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/quantized-embedding.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { quantFor,type ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";

export class QuantizedEmbedding {
  constructor(
    readonly w: MlxArray,
    readonly scales: MlxArray,
    readonly biases: MlxArray | null,
    readonly spec: ops.QuantSpec,
  ) {}

  static load(weights: Weights, path: string, config: ModelConfig): QuantizedEmbedding {
    const spec = quantFor(config.quantization, path)!;
    return new QuantizedEmbedding(
      weights.tensor(`${path}.weight`),
      weights.tensor(`${path}.scales`),
      weights.has(`${path}.biases`) ? weights.tensor(`${path}.biases`) : null,
      spec,
    );
  }

  /** ids [1, L] (int/uint) → embeddings [1, L, hidden]. */
  encode(ids: MlxArray): MlxArray {
    const rows = ops.takeAxis(this.w, ids, 0);
    const scaleRows = ops.takeAxis(this.scales, ids, 0);
    const biasRows = this.biases ? ops.takeAxis(this.biases, ids, 0) : null;
    const out = ops.dequantize(rows, scaleRows, biasRows, this.spec);
    for (const a of [rows, scaleRows]) a.dispose();
    biasRows?.dispose();
    return out;
  }

  /** Tied output head: h [1, L, hidden] → logits [1, L, vocab]. */
  asLinear(h: MlxArray): MlxArray {
    return ops.quantizedMatmul(h, this.w, this.scales, this.biases, this.spec, true);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.QuantizedEmbedding
