import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.PrefixLayout
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/prefix-layout.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { PrefixLayout } from "../contracts/mlx/trainable";

/** Block-wise RoPE for the prefix-shared concat [prompt; chosen; rejected] along
 *  the sequence axis (axis 2 of [B,H,T,D]): prompt rotated at offset 0, each
 *  response at offset P (reset), so ONE forward over the concat equals the two
 *  separate [prompt; response] forwards. RoPE is per-token, so roping each
 *  contiguous block at its scalar offset and concatenating == roping with
 *  per-token position-ids [0..P-1, P..P+Rc-1, P..P+Rr-1]. `rope` applies the
 *  layer's own rotation (its base, frequency table and dims) to one block at a
 *  scalar offset. The prefix-shared training cache (`PrefixSharedCache`) owns
 *  the layout and ropes through this. Caller disposes the input. */
export function ropeBlocks(
  x: MlxArray, plan: PrefixLayout, rope: (block: MlxArray, offset: number) => MlxArray,
): MlxArray {
  const { P, Rc, Rr } = plan;
  const [B, H, , D] = x.shape as [number, number, number, number];
  const blocks = [
    { start: 0, len: P, off: 0 },
    { start: P, len: Rc, off: P },
    { start: P + Rc, len: Rr, off: P },
  ].filter((b) => b.len > 0);
  const parts = blocks.map((b) => {
    const sl = x.slice([0, 0, b.start, 0], [B, H, b.start + b.len, D]);
    const r = rope(sl, b.off);
    sl.dispose();
    return r;
  });
  const out = ops.concatAxis(parts, 2);
  for (const p of parts) p.dispose();
  return out;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.PrefixLayout
