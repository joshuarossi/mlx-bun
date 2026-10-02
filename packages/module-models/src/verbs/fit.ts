import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { fit, skuMatrix, thisMachine } from "@mlx-bun/inference/execution/fit";
import { planRuntimeMemory } from "@mlx-bun/inference/models/memory-plan";
import { resolveKvScheme } from "@mlx-bun/inference/state/kv-scheme";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import { flag, gb, option, printer } from "./shared";

/** `fit`: will this model run on this machine, and how fast. */
export async function runFit(invocation: CliInvocation, catalog: Pick<ModelCatalog, "find">): Promise<number> {
  const print = printer(invocation), { terminal } = invocation, { style } = terminal;
  const query = invocation.positionals[0];
  if (!query) throw new Error("usage: mlx-bun fit <query> [--ctx N] [--kv-quant 4|8|config] [--skus]");
  const ctxOption = option(invocation, "ctx");
  if (ctxOption !== null && (!Number.isSafeInteger(Number(ctxOption)) || Number(ctxOption) <= 0)) throw new Error("--ctx must be a positive integer");
  const entry = await catalog.find(query);
  // A directory used as given (its path is its id) carries no index record: the fit needs the checkpoint's sizes.
  if (!entry.details) throw new Error(`no model matching "${query}" — run \`mlx-bun scan\``);
  const { directory: path, bytes, details } = entry;
  const config = await loadModelConfig(path);
  let planned;
  try { planned = await planRuntimeMemory(path, config, ctxOption === null ? {} : { contextTokens: Number(ctxOption) }); }
  catch (error) {
    invocation.stderr(`memory plan refused: ${error instanceof Error ? error.message : String(error)}\n`);
    return 1;
  }
  const context = planned?.contextTokens ?? Number(ctxOption ?? 8192);
  if (planned) {
    const gib = (value: number): string => `${(value / 2 ** 30).toFixed(2)} GiB`;
    const streamed = Object.entries(planned.streamedWeights ?? {});
    const streamedBytes = streamed.reduce((sum, [, size]) => sum + size, 0);
    const residentBytes = planned.weightsBytes - streamedBytes;
    const otherBytes = planned.transientBytes + planned.reserveBytes;
    const rows = [
      ["artifact on disk", `${gib(bytes).padStart(10)} ${style.dim("(streamed, not resident)")}`],
      ["resident weights", gib(residentBytes).padStart(10)],
      ...streamed.map(([label, size]) => [label, gib(size).padStart(10)] as const),
      ["KV cache", gib(planned.kvBytes).padStart(10)],
      ["runtime reserves", gib(otherBytes).padStart(10)],
      ["process plan", `${gib(planned.totalBytes).padStart(10)} ${style.dim(`of ${gib(planned.usableBytes)}`)}  ${style.green(style.bold("FITS"))}`],
      ...(planned.machineHeadroomBytes === undefined ? [] : [["macOS headroom", gib(planned.machineHeadroomBytes).padStart(10)] as const]),
    ];
    const width = Math.max(...rows.map(([label]) => label.length)) + 2;
    terminal.heading("will it fit?");
    print(`  ${style.bold(entry.id)} ${style.dim(`@ ${context.toLocaleString()} context · planned runtime`)}`);
    print();
    terminal.box([
      ...rows.map(([label, value]) => `${label.padEnd(width)}${value}`),
      "",
      `${"max safe context".padEnd(width)}${style.bold(planned.maxSafeContext.toLocaleString())} tokens`,
      ...(planned.maxGenerationTokens === undefined ? [] : [`${"max generation".padEnd(width)}${style.bold(planned.maxGenerationTokens.toLocaleString())} tokens`]),
    ]);
    if (flag(invocation, "skus"))
      print(style.dim("  This model's runtime plans its memory from the artifact; the generic resident-weight SKU projection does not apply."));
    print();
    return 0;
  }
  // --kv-quant mirrors serve: bill the quantized cache's true bytes so the reported window matches what serving with the same flag admits.
  const kvQuant = option(invocation, "kv-quant");
  let kvScheme: KvSchemeOptions | undefined;
  if (kvQuant === "4" || kvQuant === "8") kvScheme = resolveKvScheme({ override: Number(kvQuant) }).fitOptions;
  else if (kvQuant === "config") {
    if (!config.kvQuant?.length) throw new Error(`${entry.id} ships no per-layer kv-quant config — use --kv-quant 4|8`);
    kvScheme = resolveKvScheme({ override: "config", config: config.kvQuant, missingConfig: "error" }).fitOptions;
  } else if (kvQuant != null && kvQuant !== "off") throw new Error(`--kv-quant ${kvQuant}: expected 4, 8, config, or off`);
  const result = fit(config, bytes, context, thisMachine(), undefined, details.expertsBytes, undefined, kvScheme);
  terminal.heading("will it fit?");
  const kvNote = kvScheme ? style.dim(` · kv-quant ${kvScheme.kvBits ? `${kvScheme.kvBits}-bit` : "config"}`) : "";
  print(`  ${style.bold(entry.id)} ${style.dim(`@ ${context.toLocaleString()} context · this machine`)}${kvNote}`);
  print();
  const expertsNote = config.text.enableMoeBlock && details.expertsBytes > 0
    ? style.dim(`  (experts ${gb(details.expertsBytes)}; top ${config.text.topKExperts}/${config.text.numExperts} read per token)`) : "";
  terminal.box([
    `weights    ${gb(result.weightsBytes).padStart(9)}${expertsNote}`,
    ...(details.sidecarBytes > 0 ? [style.dim(`  + vision sidecar ${gb(details.sidecarBytes)} (bf16, loads only for vision)`)] : []),
    `kv cache   ${gb(result.kvBytes).padStart(9)}`,
    `transient  ${gb(result.transientBytes).padStart(9)}`,
    `total      ${gb(result.totalBytes).padStart(9)} ${style.dim(`of ${gb(result.usableBytes)} usable`)}  ${result.fits ? style.green(style.bold("FITS")) : style.bold("DOES NOT FIT")}`,
    "",
    `max safe context   ${style.bold(result.maxSafeContext.toLocaleString())} tokens`,
    `predicted decode   ${style.gradient(`${result.predictedDecodeTps.toFixed(1)} tok/s`)}`,
  ]);
  if (flag(invocation, "skus")) {
    terminal.heading("apple silicon matrix");
    print();
    terminal.table([
      { header: "chip" }, { header: "ram", align: "right" },
      { header: "fits", paint: cell => cell.includes("fits") ? style.green(cell) : style.dim(cell) },
      { header: "max context", align: "right" }, { header: "decode", align: "right" },
    ], skuMatrix(config, bytes, context, details.expertsBytes, kvScheme).map(row => [
      row.sku, `${row.ramGB} GB`, row.fits ? "fits" : "—",
      row.fits ? row.maxContext.toLocaleString() : "—", row.fits ? `~${row.decodeTps.toFixed(0)} tok/s` : "—",
    ]));
  }
  print();
  return 0;
}
