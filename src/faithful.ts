// MLX_BUN_FAITHFUL — the "run exactly like mlx-lm" base preset.
//
// The faithful path (proven byte-identical to stock mlx-lm's decode kernels —
// see docs and the geglu/softcap/arange work) is the PARITY FLOOR. This module
// makes it a first-class, selectable base so the benchmark can layer our own
// optimizations on top of it à la carte and measure what each still buys.
//
// Design: `MLX_BUN_FAITHFUL=1` flips the DEFAULTS of the optimization flags to
// off and turns the faithful kernels on. Any flag set EXPLICITLY (to "1" or
// "0") always wins, so a run like
//   MLX_BUN_FAITHFUL=1 MLX_BUN_COMPILED_DECODE=1
// is "faithful base + our whole-decode fusion". Non-faithful runs are unchanged.

/** True when the faithful (mlx-lm-matching) base preset is selected. */
export function faithfulMode(): boolean {
  return process.env.MLX_BUN_FAITHFUL === "1";
}

/** Resolve an on/off env flag. An explicit "1"/"0" always wins; otherwise the
 *  flag takes `defaultOn`. Callers pass a faithful-aware default, e.g.
 *  `flagOn("MLX_BUN_FUSED_GELU", !faithfulMode())` so the flag defaults OFF in
 *  the faithful base but can be layered back on explicitly. */
export function flagOn(name: string, defaultOn: boolean): boolean {
  const v = process.env[name];
  return v === "1" ? true : v === "0" ? false : defaultOn;
}
