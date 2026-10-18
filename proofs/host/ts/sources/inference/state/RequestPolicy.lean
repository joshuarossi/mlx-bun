import host.ts.Source
namespace Host.Ts.Sources.Inference.State.RequestPolicy
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/request-policy.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"export function maybePageKv(cache: Cache[], kv: KvStorageScheme, paged: PagedKvComposition | null, capacityTokens: number): void {
  if (!paged) return;
  if (cache.some((c) => c.offset > 0)) return;
  for (let i = 0; i < cache.length; i++) {
    const storage = composedStorageOf(cache[i]!);
    if (!isPlainKvCache(storage)) continue;
    const turbo: PagedTurboQuant | undefined = kv.kind === "turbo" ? Object.freeze({ kBits: kv.kBits, vBits: kv.vBits,
      fusedDecode: turboQuantFusedDecode(), kernels: (storage as KVCache).turboQuantKernels }) : undefined;
    cache[i]!.dispose(); // fresh (offset 0) — nothing stored yet
    cache[i] = new PagedKVCache(capacityTokens, paged.blockSize, paged.direct, pageQuantization(kv, i), undefined, turbo);
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.RequestPolicy
