import type { CommandArgs } from "./args";

/** Resolve main's numerical aliases once, before model loading. An explicit
 * KV choice overrides the preset; the explicit kernel choice overrides both. */
export function numericalPolicy(args: CommandArgs): { kv: string | undefined; fusedSdpa: boolean } {
  const value = (name: string) => typeof args.values[name] === "string" ? args.values[name] as string : undefined;
  const kv = value("kv-quant") ?? (args.values.l2 === true ? "config" : args.values.l1 === true ? "off" : undefined);
  const fused = value("fused-sdpa");
  if (fused !== undefined && !["on", "off", "1", "0", "true", "false"].includes(fused))
    throw new Error("--fused-sdpa expects on|off");
  return { kv, fusedSdpa: fused === undefined ? kv === "config" : ["on", "1", "true"].includes(fused) };
}
