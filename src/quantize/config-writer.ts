// Config + sidecar writer for a quantized model directory.
//
// Produces the `config.json` block the loader (src/config.ts → parseQuantization)
// reads back: a top-level `quantization` object AND a mirror `quantization_config`
// (HF compatibility — config.ts reads `raw.quantization ?? raw.quantization_config`).
// The block carries default {group_size, bits, mode} plus per-module overrides
// keyed by module path (e.g. "model.embed_tokens") — exactly the OptiQ layout.
//
// Aux files (tokenizer, chat template, generation config, …) are copied through
// verbatim so the output directory is a complete, loadable model snapshot.

import { existsSync } from "node:fs";
import { join } from "node:path";

/** A per-module quantization override. `false` means "left unquantized". */
export type PerLayerEntry = { bits: number; groupSize: number } | false;

/** The default quantization definition for the model. */
export interface QuantDef {
  bits: number;
  groupSize: number;
  mode?: string;
}

/** The serialized quantization block, ready to drop into config.json. */
export interface QuantizationBlock {
  group_size: number;
  bits: number;
  mode: string;
  // plus per-module entries: { [modulePath]: {bits, group_size} | false }
  [modulePath: string]: number | string | { bits: number; group_size: number } | false;
}

/**
 * Build the `quantization` config object: a `{group_size, bits, mode}` default
 * plus one entry per module in `perLayer`. A module mapped to `false` is
 * serialized as `false` (mlx's "not quantized" convention); otherwise it
 * becomes `{bits, group_size}`.
 */
export function buildQuantizationBlock(
  def: QuantDef,
  perLayer: Map<string, PerLayerEntry>,
): QuantizationBlock {
  const block: QuantizationBlock = {
    group_size: def.groupSize,
    bits: def.bits,
    mode: def.mode ?? "affine",
  };
  for (const [path, entry] of perLayer) {
    block[path] = entry === false ? false : { bits: entry.bits, group_size: entry.groupSize };
  }
  return block;
}

/** Aux files copied through verbatim from the source dir when present. */
const AUX_FILES = [
  "tokenizer.json",
  "tokenizer_config.json",
  "tokenizer.model",
  "spiece.model",
  "chat_template.jinja",
  "generation_config.json",
  "special_tokens_map.json",
  "added_tokens.json",
  "vocab.json",
  "merges.txt",
  "README.md",
  "kv_config.json",
];

/** Metadata for the OptiQ-style sidecar describing the achieved quantization. */
export interface OptiqMetadata {
  method: string;
  base_model: string;
  bits: number;
  group_size: number;
  achieved_bpw: number;
  per_layer_count: number;
}

/**
 * Write `config.json` (deep copy of `srcConfigRaw` with both `quantization`
 * and `quantization_config` set to `block`) into `outDir`, copy through any
 * present aux files, and write `optiq_metadata.json` describing the run.
 *
 * `*.model` tokenizer files beyond the known names are also swept in so SPM /
 * tiktoken sidecars survive the round-trip.
 */
export async function writeQuantizedConfig(
  srcConfigRaw: Record<string, unknown>,
  outDir: string,
  block: QuantizationBlock,
  opts: { srcDir?: string; optiq?: OptiqMetadata } = {},
): Promise<void> {
  // Deep copy so we never mutate the caller's config object.
  const config = JSON.parse(JSON.stringify(srcConfigRaw)) as Record<string, unknown>;
  config.quantization = block;
  config.quantization_config = block;
  await Bun.write(join(outDir, "config.json"), JSON.stringify(config, null, 2));

  if (opts.srcDir) await copyAuxFiles(opts.srcDir, outDir);

  if (opts.optiq) {
    await Bun.write(
      join(outDir, "optiq_metadata.json"),
      JSON.stringify(opts.optiq, null, 2),
    );
  }
}

/** Copy known aux files (and any `*.model`) from src → out when present. */
export async function copyAuxFiles(srcDir: string, outDir: string): Promise<void> {
  const seen = new Set<string>();
  for (const f of AUX_FILES) {
    const src = join(srcDir, f);
    if (existsSync(src)) {
      await Bun.write(join(outDir, f), Bun.file(src));
      seen.add(f);
    }
  }
  // Sweep any additional *.model tokenizer sidecars not in the known list.
  try {
    const { readdirSync } = await import("node:fs");
    for (const f of readdirSync(srcDir)) {
      if (f.endsWith(".model") && !seen.has(f)) {
        await Bun.write(join(outDir, f), Bun.file(join(srcDir, f)));
      }
    }
  } catch {
    // src dir unreadable — aux copy is best-effort.
  }
}
