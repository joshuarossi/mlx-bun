// Hot-swap mounted LoRA adapters — port of optiq/adapters/{mount,
// registry,resolver}.py (serving side; lora/apply.py is the training-
// side rank logic). Mount N adapters on one quantized base, select per
// request by id, never reload the base.
//
// Deviations from the reference, both deliberate (PLAN Phase 8):
// - No ContextVar/serve-pin: our generation queue is serialized, so the
//   active adapter is a plain field (LoraState) set by generate().
// - Residual composition is mlx-lm LoRALinear / optiq apply.py
//   (`y + (scale·z).astype(x.dtype)`), not mount.py's uncast f32 add —
//   the cast form is what the adapters were trained behind.

import { existsSync, readdirSync, statSync } from "node:fs";
import { resolve } from "node:path";
import { ptr, read } from "bun:ffi";
import { MlxArray, cpuStream } from "./mlx/array";
import { C } from "./mlx/ffi";
import { SafetensorsFile } from "./safetensors";
import type { LoraWeights } from "./model/gemma4";
import type { RuntimeModel } from "./model/factory";

const cstr = (s: string) => Buffer.from(s + "\0", "utf8");

export interface AdapterInfo {
  id: string;
  path: string;
  rank: number | null;
  scale: number;
  sizeBytes: number;
  mountedLayers: number;
  /** Adapter tensors for modules outside the 7 target suffixes
   *  (per-layer-input projections etc.) — skipped, like the reference. */
  skippedTensors: number;
}

/** Read every tensor from an adapter safetensors file (small, f32) into
 *  materialized mlx arrays. Tensor names come from our header parser;
 *  arrays from mlx's native loader via the proven map-get pattern
 *  (weights.ts). The map and header mmap are freed before returning. */
export function loadAdapterTensors(file: string): Map<string, MlxArray> {
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
      arr.eval(); // materialize — the map (and its Load refs) is freed below
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

/** Adapter scale from its config: mlx-lm writes lora_parameters.scale;
 *  PEFT writes lora_alpha + r (scale = alpha / r). Reference: mount.py.
 *  `rsLora` (recorded at train time) means the effective per-layer scale is
 *  α/√rank — the caller divides by √(that layer's rank). */
export async function readAdapterScale(dir: string): Promise<{ scale: number; rank: number | null; rsLora: boolean }> {
  for (const name of ["optiq_lora_config.json", "adapter_config.json"]) {
    const f = Bun.file(`${dir}/${name}`);
    if (await f.exists()) {
      const cfg = (await f.json()) as Record<string, any>;
      const lp = cfg.lora_parameters;
      const rsLora = Boolean(cfg.rs_lora ?? lp?.rs_lora ?? false);
      if (lp && typeof lp === "object")
        return { scale: Number(lp.scale ?? 20.0), rank: lp.rank ?? null, rsLora };
      const alpha = Number(cfg.lora_alpha ?? 16);
      const r = Number(cfg.r ?? 8);
      return { scale: r ? alpha / r : 1.0, rank: r || null, rsLora };
    }
  }
  throw new Error(`no adapter_config.json in ${dir}`);
}

export function adapterWeightsFile(dir: string): string {
  for (const name of ["adapters.safetensors", "adapter_model.safetensors"]) {
    const p = `${dir}/${name}`;
    if (existsSync(p)) return p;
  }
  throw new Error(`no adapter weights at ${dir}/adapters.safetensors or adapter_model.safetensors`);
}

/** A mountable adapter found on disk (not yet mounted). */
export interface AvailableAdapter {
  id: string; // directory basename — the handle to mount it under
  path: string; // absolute adapter dir
  scale: number;
  rank: number | null;
  /** Base model repo id (org/name) the adapter was trained on, or null if the
   *  config doesn't record it. Lets the chat selector hide adapters that don't
   *  fit the served model (a MiniCPM5 adapter can't mount on Gemma). */
  baseModel: string | null;
}

/** The base-model repo id an adapter was trained on, from its config's
 *  source_model / base_model_name_or_path. These are stored as machine-local
 *  snapshot PATHS (…/models--ORG--NAME/snapshots/HASH), so recover the stable
 *  repo id (ORG/NAME) from the path; returns null if unrecorded. */
async function readAdapterBaseRepoId(dir: string): Promise<string | null> {
  for (const [name, key] of [
    ["optiq_lora_config.json", "source_model"],
    ["adapter_config.json", "base_model_name_or_path"],
  ] as const) {
    const f = Bun.file(`${dir}/${name}`);
    if (await f.exists()) {
      const cfg = (await f.json()) as Record<string, any>;
      const src = cfg[key];
      if (typeof src === "string" && src) {
        const m = src.match(/models--([^/]+)/);
        return m ? m[1]!.replace(/--/g, "/") : src;
      }
    }
  }
  return null;
}

/** Scan adapter stores for mountable adapters: directories holding an adapter
 *  weights file. id = dir basename; scale/rank/baseModel read from each adapter's
 *  config. Dirs without weights (dataset folders) and unreadable stores are skipped.
 *  Backs GET /v1/adapters/available, which populates the chat adapter selector. */
export async function listAvailableAdapters(stores: string[]): Promise<AvailableAdapter[]> {
  const out: AvailableAdapter[] = [];
  const seen = new Set<string>();
  for (const store of stores) {
    let entries;
    try {
      entries = readdirSync(store, { withFileTypes: true });
    } catch {
      continue; // store missing → skip
    }
    for (const e of entries) {
      if (!e.isDirectory()) continue;
      const dir = resolve(store, e.name);
      try {
        adapterWeightsFile(dir);
      } catch {
        continue; // no weights → not an adapter
      }
      if (seen.has(dir)) continue;
      seen.add(dir);
      let scale = 1;
      let rank: number | null = null;
      try {
        ({ scale, rank } = await readAdapterScale(dir));
      } catch {
        // keep defaults if the config is unreadable
      }
      const baseModel = await readAdapterBaseRepoId(dir).catch(() => null);
      out.push({ id: e.name, path: dir, scale, rank, baseModel });
    }
  }
  return out;
}

/** Parse an adapter selection spec: "sft" | "sft+dpo" | "sft,dpo"
 *  (reference mount.py stacking syntax — residuals sum in order). */
export function parseAdapterSpec(spec: string): string[] {
  const sep = spec.includes("+") ? "+" : ",";
  return spec.split(sep).map((s) => s.trim()).filter(Boolean);
}

export class AdapterManager {
  readonly #model: RuntimeModel;
  readonly #mounted = new Map<string, AdapterInfo>();
  /** Owned adapter arrays per id (disposed on unmount). */
  readonly #arrays = new Map<string, MlxArray[]>();

  constructor(model: RuntimeModel) {
    this.#model = model;
  }

  /** Mount an adapter directory under `id`. Validates layer-name and
   *  rank/shape compatibility against the base BEFORE any weights are
   *  attached — a bad adapter fails here, never at request time
   *  (reference: resolver.py + mount.py add_adapter checks). */
  async mount(id: string, dir: string): Promise<AdapterInfo> {
    if (this.#mounted.has(id)) return this.#mounted.get(id)!;
    if (id.includes("+") || id.includes(","))
      throw new Error(`adapter id ${JSON.stringify(id)} may not contain '+' or ','`);
    const path = resolve(dir);
    if (!existsSync(path)) throw new Error(`adapter dir not found: ${path}`);

    const weightsFile = adapterWeightsFile(path);
    const { scale, rank: configRank, rsLora } = await readAdapterScale(path);
    const tensors = loadAdapterTensors(weightsFile);
    const targets = this.#model.loraTargets();

    // Group adapter tensors into (modulePath → {a, b}), probing both the
    // pure-LLM and VLM-wrapped prefixes like the reference _find_weight_pair.
    const pairs = new Map<string, { a?: MlxArray; b?: MlxArray }>();
    let skipped = 0;
    const ourPrefix = `${this.#model.prefixBase}.layers.`;
    const altPrefix = ourPrefix.startsWith("language_model.")
      ? ourPrefix.slice("language_model.".length)
      : `language_model.${ourPrefix}`;
    for (const [name, arr] of tensors) {
      const m = name.match(/^(.*)\.(lora_a|lora_A|lora_b|lora_B)(\.weight)?$/);
      if (!m) { skipped++; arr.dispose(); continue; }
      let modulePath = m[1]!;
      if (modulePath.startsWith(altPrefix))
        modulePath = ourPrefix + modulePath.slice(altPrefix.length);
      if (!targets.has(modulePath)) { skipped++; arr.dispose(); continue; }
      const slot = pairs.get(modulePath) ?? {};
      if (m[2]!.toLowerCase() === "lora_a") slot.a = arr; else slot.b = arr;
      pairs.set(modulePath, slot);
    }

    // Validate every pair against the base linear's dims before mounting
    // anything (all-or-nothing: a bad adapter must not half-mount).
    const validated: { linear: import("./model/gemma4").QuantizedLinear; lw: LoraWeights }[] = [];
    const dispose = () => {
      for (const { a, b } of pairs.values()) { a?.dispose(); b?.dispose(); }
    };
    try {
      for (const [modulePath, { a, b }] of pairs) {
        if (!a || !b)
          throw new Error(`${modulePath}: adapter has only one of lora_a/lora_b`);
        const linear = targets.get(modulePath)!;
        const [aIn, rank] = a.shape as [number, number];
        const [bRank, bOut] = b.shape as [number, number];
        if (aIn !== linear.inFeatures || bRank !== rank || bOut !== linear.outFeatures)
          throw new Error(
            `${modulePath}: shape mismatch — lora_a [${a.shape}] / lora_b [${b.shape}] ` +
            `vs base [in ${linear.inFeatures}, out ${linear.outFeatures}]; ` +
            `was this adapter trained for a different base model?`,
          );
        // rsLoRA: effective per-layer scale is α/√rank (matches training).
        const effScale = rsLora ? scale / Math.sqrt(rank) : scale;
        validated.push({ linear, lw: { a, b, scale: effScale, rank } });
      }
      if (validated.length === 0)
        throw new Error(
          `failed to mount adapter ${JSON.stringify(id)}: no tensors match the ` +
          `target modules (q/k/v/o/gate/up/down_proj). Check that the adapter ` +
          `was trained for this base model.`,
        );
    } catch (e) {
      dispose();
      throw e;
    }

    for (const { linear, lw } of validated) {
      (linear.adapters ??= new Map()).set(id, lw);
      linear.loraState = this.#model.loraState;
    }

    const info: AdapterInfo = {
      id,
      path,
      rank: configRank,
      scale,
      sizeBytes: statSync(weightsFile).size,
      mountedLayers: validated.length,
      skippedTensors: skipped,
    };
    this.#mounted.set(id, info);
    this.#arrays.set(id, validated.flatMap(({ lw }) => [lw.a, lw.b]));
    return info;
  }

  /** Remove `id` from every linear (frees its arrays). The mount points
   *  stay in place for other adapters, like the reference. */
  unmount(id: string): number {
    if (!this.#mounted.delete(id)) return 0;
    let removed = 0;
    for (const linear of this.#model.loraTargets().values()) {
      if (linear.adapters?.delete(id)) removed++;
    }
    for (const a of this.#arrays.get(id) ?? []) a.dispose();
    this.#arrays.delete(id);
    if (this.#model.loraState.active.includes(id))
      this.#model.loraState.active = this.#model.loraState.active.filter((x) => x !== id);
    return removed;
  }

  list(): AdapterInfo[] {
    return [...this.#mounted.values()];
  }

  get(id: string): AdapterInfo | undefined {
    return this.#mounted.get(id);
  }

  /** Resolve a request's adapter spec to validated ids ([] for none).
   *  Unknown ids are an error — selection must fail loudly, not no-op. */
  resolveSpec(spec: string | null | undefined): string[] {
    if (!spec || spec.toLowerCase() === "none") return [];
    const ids = parseAdapterSpec(spec);
    for (const id of ids)
      if (!this.#mounted.has(id))
        throw new Error(
          `unknown adapter ${JSON.stringify(id)} — mounted: ` +
          `${[...this.#mounted.keys()].join(", ") || "(none)"}`,
        );
    return ids;
  }
}
