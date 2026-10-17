import host.ts.Source
namespace Host.Ts.Sources.Inference.Artifacts.Config
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/artifacts/config.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"export function parseQuantization(raw: Record<string, any> | undefined): QuantizationConfig | null {
  if (!raw) return null;
  const def: QuantSpec = {
    bits: raw.bits,
    groupSize: raw.group_size,
    mode: raw.mode ?? "affine",
  };
  const perLayer = new Map<string, QuantSpec>();
  for (const [key, value] of Object.entries(raw)) {
    if (key === "bits" || key === "group_size" || key === "mode") continue;
    if (typeof value === "object" && value !== null) {
      const spec: QuantSpec = {
        bits: (value as any).bits ?? def.bits,
        groupSize: (value as any).group_size ?? def.groupSize,
        mode: (value as any).mode ?? def.mode,
      };
      const tr = (value as any).trellis;
      if (spec.mode === "trellis") {
        if (!tr || typeof tr !== "object") throw new Error(`quantization.${key}: mode "trellis" needs a trellis {L, code, axis} block`);
        spec.trellis = { L: Number(tr.L), code: String(tr.code ?? "1mad"), axis: tr.axis === 0 ? 0 : 1 };
      }
      perLayer.set(key, spec);
    } else if (value === false) {
      // mlx convention: `"layer": false` means not quantized
      perLayer.set(key, { bits: 0, groupSize: 0, mode: "none" });
    }
  }
  return { default: def, perLayer };
}

export function quantFor(q: QuantizationConfig | null, modulePath: string): QuantSpec | null {
  if (!q) return null;
  const spec = q.perLayer.get(modulePath) ?? q.default;
  return spec.mode === "none" ? null : spec;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Artifacts.Config
