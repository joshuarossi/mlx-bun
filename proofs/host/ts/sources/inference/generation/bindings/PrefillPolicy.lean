import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Bindings.PrefillPolicy
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/bindings/prefill-policy.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { ModelConfig } from "../../artifacts/config";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import { declaredGraph } from "../../models/capabilities";
import type { PrefillPolicy } from "../../contracts/portable/prefill";
import { sdpaFallbackBytes } from "../../state/kv-scheme";
import type { RuntimeConfig } from "../../runtime/config";

/** The graph facts prefill sizing reads: its geometry and its declaration. */
export interface PrefillSizedGraph {
  readonly config: ModelConfig;
  readonly graphCapabilities: GraphDeclaration;
}

/** Retain large chunks for short prompts, but where the graph declares a
 * bounded prefill workspace, bound the materialized attention score workspace
 * at long context. This changes work size, never request admission. Explicit
 * chunk settings remain exact. */
export function resolveMlxPrefillPolicy(graph: PrefillSizedGraph, runtime: RuntimeConfig,
  override?: number): PrefillPolicy {
  const explicit = override ?? (runtime.value("MLX_BUN_RD_PREFILL_CHUNK") === undefined
    ? undefined : runtime.number("MLX_BUN_RD_PREFILL_CHUNK", 2048));
  if (explicit !== undefined) {
    const chunk = Math.max(1, Math.floor(explicit));
    return { chunkSize: () => chunk };
  }
  if (!declaredGraph(graph).graphCapabilities.prefill.boundedWorkspace) return { chunkSize: () => 2048 };
  const config = graph.config;
  // Capture geometry now, independently of later configuration mutation.
  const geometry = { ...config, text: { ...config.text, layerTypes: [...(config.text.layerTypes ?? [])] } };
  const workspaceBytes = 1024 ** 3;
  return { chunkSize(promptTokens) {
    let chunk = 2048;
    while (chunk > 8 && sdpaFallbackBytes(geometry, chunk, promptTokens) > workspaceBytes) chunk /= 2;
    return chunk;
  } };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Bindings.PrefillPolicy
