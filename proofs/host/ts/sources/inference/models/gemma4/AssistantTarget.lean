import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.AssistantTarget
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/assistant-target.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache, KvDonorAttention } from "../../contracts/mlx/cache";
import { captureKvDonorAttention } from "../../state/kv-attention-view";
import type { AssistantAttention } from "../../contracts/mlx/attention";
import { disposeResources } from "../../runtime/resources";

/** Bind captured cache validity to Q-only attention. Encoded layouts can
 * supply this same numerical port without changing the draft graph. */
export function readAssistantDonors(sliding: Cache, full: Cache) {
  const views: KvDonorAttention[] = [], masks: MlxArray[] = [];
  const dispose = () => disposeResources([...masks, ...views]);
  try {
    for (const cache of [sliding, full]) views.push(captureKvDonorAttention(cache));
    const bind = (view: KvDonorAttention): AssistantAttention => {
      // All draft steps borrow the same target snapshot. Build each validity
      // mask once, then reuse it across matching layers and the entire chain.
      const byWindow = new Map<number | null, MlxArray | null>();
      return { attend(query, scale, window) {
        if (!byWindow.has(window)) {
          const width = view.width, B = view.offsets.length;
          const starts = view.starts.map((start, row) => Math.max(start,
            window === null ? start : view.ends[row]! - window));
          let mask: MlxArray | null = null;
          if (starts.some(start => start !== 0) || view.ends.some(end => end !== width)) {
            using columns = ops.arange(0, width, 1, Dtype.int32);
            using lower = ops.fromInt32(starts, [B, 1, 1, 1]);
            using upper = ops.fromInt32([...view.ends], [B, 1, 1, 1]);
            using before = ops.less(columns, lower);
            using after = ops.greaterEqual(columns, upper);
            using invalid = ops.logicalOr(before, after);
            using floats = invalid.astype(view.dtype);
            mask = ops.mulScalar(floats, -1e9);
            masks.push(mask);
          }
          byWindow.set(window, mask);
        }
        const mask = byWindow.get(window)!;
        return view.attend(query, scale, { mode: mask ? "array" : "", arr: mask });
      } };
    };
    return { positions: views[0]!.offsets.map(offset => offset - 1),
      sliding: bind(views[0]!), full: bind(views[1]!), dispose };
  } catch (error) { dispose(); throw error; }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.AssistantTarget
