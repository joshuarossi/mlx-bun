

// Compiled-decode trace mode (set by compiled-decode.ts around its trace,
// which runs synchronously on the serialized generation queue — same
// safety argument as LoraState). Inside a shapeless-compiled graph, mlx's
// Slice primitive cannot re-infer output shapes, so the two subrange
// slices on the decode path (per-layer-input split, MoE top-k) swap to
// DynamicSlice — identical values, shapeless-safe — ONLY while tracing.
// The uncompiled path keeps the exact oracle op sequence.
let compiledTrace = false;
export function setCompiledTrace(v: boolean): void {
  compiledTrace = v;
}
export function isCompiledTrace(): boolean {
  return compiledTrace;
}
