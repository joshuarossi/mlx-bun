// Non-quantizing conversion (mlx_lm.convert without -q): rewrite a checkpoint
// with its floating tensors cast to one dtype and/or its quantized modules
// dequantized to dense weights. Tensor names, shard layout rules, and aux files
// follow the quantizer's writer; the CPU stream discipline is the same.

import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { clearCache } from "@mlx-bun/mlx/ffi";
import { cpuStream } from "@mlx-bun/mlx/array";
import { dequantize } from "@mlx-bun/mlx/ops";
import { Weights, loadModelConfig, quantFor, writeShardedSafetensors, type NamedTensor, type WriteResult } from "@mlx-bun/inference/artifacts";
import { copyAuxFiles } from "@mlx-bun/inference/artifacts/auxiliary-files";
import { writeAtomicDirectory } from "./atomic-output";
import { castTensor, type ConvertDtype, type ProgressEvent } from "./quantizer";

export interface ConvertOptions {
  /** Cast every floating tensor (quantization scales/biases included) to this dtype. */
  dtype?: ConvertDtype;
  /** Replace each quantized module with its dense weight and drop the config's quantization block. */
  dequantize?: boolean;
}

export interface ConvertResult {
  outDir: string;
  /** Modules that were dequantized to dense weights. */
  nDequantized: number;
  write: WriteResult;
}

/** Rewrite `srcDir` into `outDir` (published atomically). Without options the
 * tensors are copied unchanged, as `mlx_lm.convert` without -q/--dtype does. */
export async function convertModelDir(
  srcDir: string,
  outDir: string,
  opts: ConvertOptions = {},
  onProgress?: (e: ProgressEvent) => void,
): Promise<ConvertResult> {
  return writeAtomicDirectory(outDir, async (staging) => {
    const progress = (stage: string, message: string, fraction: number) => onProgress?.({ stage, message, progress: fraction });
    progress("loading", `Reading ${srcDir}`, 0);
    const config = await loadModelConfig(srcDir);
    const weights = await Weights.open(srcDir);
    const out: NamedTensor[] = [];
    try {
      const names = weights.tensorNames;
      const present = new Set(names), scaled = new Set<string>();
      for (const name of names) if (name.endsWith(".scales")) scaled.add(name.slice(0, -".scales".length));
      // Modules to dequantize: a `.scales` sibling and a quantization spec for the module.
      const dense = new Set([...scaled].filter(base => opts.dequantize && quantFor(config.quantization, base)));
      let processed = 0;
      for (const name of names) {
        const base = /^(.*)\.(weight|scales|biases)$/.exec(name)?.[1];
        if (base && dense.has(base)) {
          if (!name.endsWith(".weight")) continue; // scales/biases are folded into the dense weight
          const spec = quantFor(config.quantization, base)!;
          const packed = weights.tensor(name), scales = weights.tensor(`${base}.scales`);
          const biases = present.has(`${base}.biases`) ? weights.tensor(`${base}.biases`) : null;
          const weight = dequantize(packed, scales, biases, spec, cpuStream);
          out.push({ name, array: castTensor(name, weight, opts.dtype) });
        } else out.push({ name, array: castTensor(name, weights.tensor(name), opts.dtype) });
        if (++processed % 16 === 0) clearCache();
        progress("converting", `Tensor ${processed}/${names.length}`, processed / names.length);
      }
      progress("writing", `Writing ${out.length} tensors to ${outDir}`, 1);
      mkdirSync(staging, { recursive: true });
      const write = writeShardedSafetensors(staging, out);
      const raw = JSON.parse(JSON.stringify(config.raw)) as Record<string, unknown>;
      if (opts.dequantize) { delete raw.quantization; delete raw.quantization_config; }
      await Bun.write(join(staging, "config.json"), JSON.stringify(raw, null, 2));
      await copyAuxFiles(srcDir, staging);
      progress("done", `Converted ${out.length} tensors → ${outDir}`, 1);
      return { outDir, nDequantized: dense.size, write };
    } finally {
      for (const tensor of out) { try { tensor.array.dispose(); } catch { /* already released */ } }
      weights.dispose();
      clearCache();
    }
  });
}
