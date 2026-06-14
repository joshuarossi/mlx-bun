// Merge multiple LoRA adapters into one — rank-concat, mathematically exact.
// Port of optiq/lora/merge.py.
//
// For two adapters on a layer (A1[in,r1] B1[r1,out] scale s1; A2 B2 s2):
//   A_m = concat([A1, A2], rankAxis)           shape [in, r1+r2]
//   B_m = concat([s1·B1, s2·B2], rankAxis)      shape [r1+r2, out]
//   (x @ A_m) @ B_m == s1·(x@A1@B1) + s2·(x@A2@B2)
// so the merged adapter writes scale=1.0 (per-source scales folded into B).
//
// Tensor names follow the AdapterManager.mount format (lora_a / lora_b).

import { mkdirSync, existsSync } from "node:fs";
import { ptr, read } from "bun:ffi";
import { C } from "../mlx/ffi";
import { MlxArray, cpuStream } from "../mlx/array";
import * as ops from "../mlx/ops";
import { SafetensorsFile } from "../safetensors";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

export interface MergeStats {
  layersMerged: number;
  layersOnlyInOne: number;
  totalKeysOut: number;
  sources: string[];
  scales: number[];
}

/** Merge N adapter directories into `outputDir`. `scales` overrides the
 *  per-source scales (else each source's adapter config scale is used). */
export async function mergeAdapters(
  adapterDirs: string[],
  outputDir: string,
  scales?: number[],
): Promise<MergeStats> {
  if (adapterDirs.length < 2) throw new Error("mergeAdapters needs at least two sources");

  const resolvedScales = scales ?? (await Promise.all(adapterDirs.map(resolveScale)));
  if (resolvedScales.length !== adapterDirs.length)
    throw new Error("scales length must match adapter count");

  const sources = adapterDirs.map((d) => ({
    tensors: loadAdapterTensors(resolveSafetensors(d)),
  }));

  // Universe of module paths across all sources.
  const allMods = new Set<string>();
  for (const s of sources)
    for (const k of s.tensors.keys())
      if (k.endsWith(".lora_a")) allMods.add(k.slice(0, -".lora_a".length));

  const merged = new Map<string, MlxArray>();
  const stats: MergeStats = {
    layersMerged: 0,
    layersOnlyInOne: 0,
    totalKeysOut: 0,
    sources: adapterDirs,
    scales: resolvedScales,
  };

  try {
    for (const mod of [...allMods].sort()) {
      const aParts: MlxArray[] = [];
      const bParts: MlxArray[] = [];
      for (let s = 0; s < sources.length; s++) {
        const a = sources[s]!.tensors.get(`${mod}.lora_a`);
        const b = sources[s]!.tensors.get(`${mod}.lora_b`);
        if (a && b) {
          aParts.push(a);
          const scale = resolvedScales[s]!;
          bParts.push(scale === 1.0 ? b : ops.mulScalar(b, scale));
        }
      }
      if (aParts.length === 0) continue;
      if (aParts.length === 1) {
        stats.layersOnlyInOne++;
        // A is the original; B may be a scaled copy (own it) or the original.
        merged.set(`${mod}.lora_a`, aParts[0]!);
        merged.set(`${mod}.lora_b`, bParts[0]!);
      } else {
        // rank axis: A is [in, r] → axis 1; B is [r, out] → axis 0.
        const aMerged = ops.concatAxis(aParts, 1);
        const bMerged = ops.concatAxis(bParts, 0);
        merged.set(`${mod}.lora_a`, aMerged);
        merged.set(`${mod}.lora_b`, bMerged);
        stats.layersMerged++;
      }
    }

    stats.totalKeysOut = merged.size;
    mkdirSync(outputDir, { recursive: true });

    const map = C.mlx_map_string_to_array_new();
    const meta = C.mlx_map_string_to_string_new();
    try {
      for (const [name, arr] of merged) {
        arr.eval();
        if (C.mlx_map_string_to_array_insert(map, ptr(cstr(name)), arr.handle) !== 0)
          throw new Error(`map insert ${name} failed`);
      }
      const file = `${outputDir}/adapters.safetensors`;
      if (C.mlx_save_safetensors(ptr(cstr(file)), map, meta) !== 0)
        throw new Error(`mlx_save_safetensors(${file}) failed`);
    } finally {
      C.mlx_map_string_to_array_free(map);
      C.mlx_map_string_to_string_free(meta);
    }

    // Merged config: scale 1.0 (folded into B), rank = sum of source ranks.
    let rankSum = 0;
    for (const d of adapterDirs) rankSum += (await resolveRank(d)) ?? 0;
    const cfg = {
      fine_tune_type: "lora",
      lora_parameters: { scale: 1.0, rank: rankSum || null },
      r: rankSum || null,
      peft_type: "LORA",
      optiq_merge: { sources: adapterDirs, scales: resolvedScales },
    };
    await Bun.write(`${outputDir}/adapter_config.json`, JSON.stringify(cfg, null, 2) + "\n");
    await Bun.write(`${outputDir}/optiq_lora_config.json`, JSON.stringify(cfg, null, 2) + "\n");
  } finally {
    // dispose all source + merged arrays (merged copies are owned here).
    for (const s of sources) for (const a of s.tensors.values()) a.dispose();
    for (const a of merged.values()) a.dispose();
  }

  return stats;
}

function resolveSafetensors(dir: string): string {
  for (const p of [`${dir}/best/adapters.safetensors`, `${dir}/adapters.safetensors`])
    if (existsSync(p)) return p;
  if (existsSync(dir)) return dir; // explicit file path
  throw new Error(`${dir}: no adapters.safetensors`);
}

async function resolveScale(dir: string): Promise<number> {
  const cfg = await readConfig(dir);
  if (cfg?.lora_parameters?.scale != null) return Number(cfg.lora_parameters.scale);
  if (cfg?.lora_alpha != null && cfg?.r) return Number(cfg.lora_alpha) / Number(cfg.r);
  if (cfg?.scale != null) return Number(cfg.scale);
  return 1.0;
}

async function resolveRank(dir: string): Promise<number | null> {
  const cfg = await readConfig(dir);
  const r = cfg?.lora_parameters?.rank ?? cfg?.r;
  return r != null ? Number(r) : null;
}

async function readConfig(dir: string): Promise<any | null> {
  for (const name of ["adapter_config.json", "optiq_lora_config.json"]) {
    const f = Bun.file(`${dir}/${name}`);
    if (await f.exists()) return f.json();
  }
  return null;
}

/** Materialize every tensor from an adapter safetensors file (mirrors the
 *  read idiom in src/lora.ts loadAdapterTensors). */
function loadAdapterTensors(file: string): Map<string, MlxArray> {
  const sf = SafetensorsFile.open(file);
  const names = [...sf.tensors.keys()];
  sf.mmap.unmap();

  const arrMapSlot = new BigUint64Array([C.mlx_map_string_to_array_new()]);
  const metaMapSlot = new BigUint64Array([C.mlx_map_string_to_string_new()]);
  const arrMapPtr = ptr(arrMapSlot);
  const metaMapPtr = ptr(metaMapSlot);
  const status = C.mlx_load_safetensors(arrMapPtr, metaMapPtr, ptr(cstr(file)), cpuStream);
  C.mlx_map_string_to_string_free(read.u64(metaMapPtr, 0));
  const mapHandle = read.u64(arrMapPtr, 0);
  if (status !== 0) {
    C.mlx_map_string_to_array_free(mapHandle);
    throw new Error(`mlx_load_safetensors(${file}) failed`);
  }
  const out = new Map<string, MlxArray>();
  try {
    for (const name of names) {
      const slot = new BigUint64Array([C.mlx_array_new()]);
      const slotPtr = ptr(slot);
      if (C.mlx_map_string_to_array_get(slotPtr, mapHandle, ptr(cstr(name))) !== 0)
        throw new Error(`adapter tensor ${name} missing from native map`);
      const arr = new MlxArray(read.u64(slotPtr, 0));
      arr.eval();
      out.set(name, arr);
    }
  } catch (e) {
    for (const a of out.values()) a.dispose();
    C.mlx_map_string_to_array_free(mapHandle);
    throw e;
  }
  C.mlx_map_string_to_array_free(mapHandle);
  return out;
}
