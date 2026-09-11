import { KvScheme } from "../../../src/kv-scheme";
import type { KvSchemeOptions } from "../../../src/kv-scheme";
import type { ServerOptions } from "../../../src/server";

/** Explicit parity matrix; defaults retain the original bf16 fixture. */
export function continuationKv(promptLength: number) {
  const mode = Bun.env.MLX_BUN_TEST_CONTINUATION_KV ?? "bf16";
  const requestedStart = Bun.env.MLX_BUN_TEST_CONTINUATION_KV_START ?? "0";
  const start = requestedStart.startsWith("prompt+")
    ? promptLength + Number(requestedStart.slice(7)) : Number(requestedStart);
  const interruptAt = Number(Bun.env.MLX_BUN_TEST_CONTINUATION_INTERRUPT ?? 6);
  if (!Number.isSafeInteger(start) || start < 0 || !Number.isSafeInteger(interruptAt) || interruptAt < 6 || interruptAt >= 16)
    throw new Error("continuation fixture requires start>=0 and 6<=interrupt<16");
  let options: KvSchemeOptions = {};
  let kind: ConstructorParameters<typeof KvScheme>[0] = "bf16";
  let serverOptions: Pick<ServerOptions, "kvQuant" | "turboQuant" | "quantizedKvStart"> = { kvQuant: "off" };
  if (mode === "4" || mode === "8") {
    kind = "affine-uniform";
    options = { kvBits: Number(mode), kvGroupSize: 64, quantizedKvStart: start };
    serverOptions = { kvQuant: Number(mode), quantizedKvStart: start };
  } else if (mode === "turbo") {
    kind = "turbo";
    options = { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: start };
    serverOptions = { turboQuant: options.turboQuant, quantizedKvStart: start };
  } else if (mode === "per-layer") {
    kind = "affine-config";
    options = { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 1, bits: 8, groupSize: 64 }], quantizedKvStart: start };
    serverOptions = { kvQuant: "config", quantizedKvStart: start };
  } else if (mode !== "bf16") throw new Error(`unknown continuation KV fixture: ${mode}`);
  return { mode, start, interruptAt, options, serverOptions, scheme: new KvScheme(kind, options) };
}
