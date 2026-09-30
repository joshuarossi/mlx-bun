// Finding adapters on disk and reading their configs: file system only, no native library, so a process that owns
// no model (an isolated host's catalog) can list what a model could mount.
import { existsSync, readdirSync } from "node:fs";
import { resolve } from "node:path";

/** Adapter scale from its config: mlx-lm writes lora_parameters.scale;
 *  PEFT writes lora_alpha + r and optionally use_rslora. For ordinary PEFT
 *  return alpha/r as the scale. For PEFT rsLoRA return alpha and set rsLora,
 *  so the caller's one per-layer division produces alpha/√rank exactly once.
 *  Internal configs already store their pre-√rank scale directly. */
export async function readAdapterScale(dir: string): Promise<{ scale: number; rank: number | null; rsLora: boolean }> {
  for (const name of ["optiq_lora_config.json", "adapter_config.json"]) {
    const f = Bun.file(`${dir}/${name}`);
    if (await f.exists()) {
      const cfg = (await f.json()) as Record<string, any>;
      const lp = cfg.lora_parameters;
      const rsLora = Boolean(cfg.rs_lora ?? lp?.rs_lora ?? cfg.use_rslora ?? false);
      if (lp && typeof lp === "object")
        return { scale: Number(lp.scale ?? 20.0), rank: lp.rank ?? null, rsLora };
      const alpha = Number(cfg.lora_alpha ?? 16);
      const r = Number(cfg.r ?? 8);
      return {
        scale: rsLora ? alpha : r ? alpha / r : 1.0,
        rank: r || null,
        rsLora,
      };
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
