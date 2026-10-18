import host.ts.Source
namespace Host.Ts.Sources.Inference.State.DecodedKvDonor
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/decoded-kv-donor.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import * as ops from "@mlx-bun/mlx/ops";
import type { KvDonorAttention, KvDonorRows } from "../contracts/mlx/cache";

/** Takes ownership of decoded donor planes. Assistant attention uses decoded
 * values, preserving its SDPA arithmetic rather than moving inverse rotation. */
export function decodedKvDonorAttention(view: KvDonorRows): KvDonorAttention {
  const { keys, values, offsets, starts, ends } = view;
  return { width: keys.shape[2]!, dtype: keys.dtype, offsets, starts, ends,
    attend: (q, scale, mask) => ops.sdpa(q, keys, values, scale, mask.mode, mask.arr),
    dispose() { keys.dispose(); values.dispose(); },
  };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.DecodedKvDonor
