import { runtimeFlag, type RuntimeKey } from "./runtime-config";

// Generic on/off resolver for per-fork decode flags. Process environment is
// captured once by runtime-config; CLI tier aliases install an explicit
// immutable override before model modules are loaded.

/** Resolve an on/off env flag. An explicit "1"/"0" always wins; otherwise the
 *  flag takes `defaultOn`. */
export function flagOn(name: RuntimeKey, defaultOn: boolean): boolean {
  return runtimeFlag(name, defaultOn);
}
