// Generic on/off resolver for the per-fork decode flags (--compiled-decode,
// --compiled-activations, --fused-sdpa, …). An explicit "1"/"0" in the env
// always wins; otherwise the caller's `defaultOn` applies. The tier aliases
// (--l1/--l2, applyDecodeRoute in cli.ts) set the env vars; model code
// reads them through this helper so a hand-set flag and a tier preset resolve
// identically.

/** Resolve an on/off env flag. An explicit "1"/"0" always wins; otherwise the
 *  flag takes `defaultOn`. */
export function flagOn(name: string, defaultOn: boolean): boolean {
  const v = process.env[name];
  return v === "1" ? true : v === "0" ? false : defaultOn;
}
