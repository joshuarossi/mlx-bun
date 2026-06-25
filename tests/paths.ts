// Shared reference-environment paths (see PLAN.md "Reference environment").

import { existsSync, readdirSync, realpathSync } from "node:fs";

/** Resolve a HF-cache snapshot dir for a repo by globbing snapshots/ for the
 *  one carrying config.json — so a freshly-downloaded model needs no hardcoded
 *  commit hash. Returns a non-existent path (availability check → false) until
 *  the download lands. */
function hfSnapshot(repoDir: string): string {
  const base = `${process.env.HOME}/.cache/huggingface/hub/${repoDir}/snapshots`;
  try {
    for (const snap of readdirSync(base))
      if (existsSync(`${base}/${snap}/config.json`)) return `${base}/${snap}`;
  } catch {
    /* not downloaded yet */
  }
  return `${base}/_unresolved`;
}

/** A venv is usable only if bin/python resolves to a real file — a venv
 *  whose interpreter symlink dangles (e.g. Homebrew bumped python 3.13→3.14
 *  and orphaned the venv) must be skipped, not picked: spawning it gives a
 *  confusing ENOENT at eval time rather than at resolution time. */
function venvUsable(venv: string): boolean {
  try {
    return existsSync(realpathSync(`${venv}/bin/python`));
  } catch {
    return false; // missing dir or broken symlink chain
  }
}

/** Oracle venv root. Different laptops keep the reference environment in
 *  different directories (mlx-lm vs mlx-lm-example); pick the first
 *  candidate whose interpreter actually works. Override the search with
 *  MLX_BUN_ORACLE_VENV (still validated, so a typo'd override falls back). */
function resolveOracleVenv(): string {
  const home = process.env.HOME ?? "";
  const candidates = [
    process.env.MLX_BUN_ORACLE_VENV,
    `${home}/Code/mlx-lm/.venv`,
    `${home}/Code/mlx-lm-example/.venv`,
  ].filter((v): v is string => !!v);
  return candidates.find(venvUsable) ?? candidates[0] ?? `${home}/Code/mlx-lm/.venv`;
}

export const ORACLE_VENV = resolveOracleVenv();

export const ORACLE_PYTHON = `${ORACLE_VENV}/bin/python`;

export const SNAPSHOT = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`;

export const SNAPSHOT_26B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-26B-A4B-it-OptiQ-4bit/snapshots/dbfd2a779b038b267bb20ff95dad717f42e4de16`;

export const SNAPSHOT_MINICPM5 = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`;

// Gemma-4 e4b: the SigLIP-vision target (full vision encoder in its
// optiq_vision.safetensors sidecar, per-layer-input text). Resolved
// dynamically so the download needs no hash edit.
export const SNAPSHOT_E4B = hfSnapshot("models--mlx-community--gemma-4-e4b-it-OptiQ-4bit");

export const SNAPSHOT_QWEN35 = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--Qwen3.6-27B-OptiQ-4bit/snapshots/e9a616f2a388d41a7b7306e079f248825b90071f`;

// Lighter same-architecture (qwen3_5) OptiQ checkpoint: 4-bit, 32 layers, tied
// head, ships kv_config.json → BOTH parity bars (bf16 vs mlx-lm, mixed vs
// optiq) on ~4.5 GB. Resolved dynamically so the download needs no hash edit.
export const SNAPSHOT_QWEN35_4B = hfSnapshot("models--mlx-community--Qwen3.5-4B-OptiQ-4bit");

// DiffusionGemma-26B-A4B-it: the first non-autoregressive (block-diffusion)
// model. ~14 GB, OptiQ mixed 4/8-bit. Oracle is mlx-optiq itself (stock
// mlx-lm/mlx-vlm can't load it). Resolved dynamically — no hash edit on pull.
export const SNAPSHOT_DIFFUSION = hfSnapshot(
  "models--mlx-community--diffusiongemma-26B-A4B-it-OptiQ-4bit",
);

export async function snapshotDiffusionAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_DIFFUSION}/config.json`).exists();
}

export async function snapshotAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT}/config.json`).exists();
}

export async function snapshot26bAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_26B}/config.json`).exists();
}

export async function snapshotMiniCPM5Available(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_MINICPM5}/config.json`).exists();
}

export async function snapshotE4bAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_E4B}/config.json`).exists();
}

export async function snapshotQwen35Available(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_QWEN35}/config.json`).exists();
}

export async function snapshotQwen35_4bAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_QWEN35_4B}/config.json`).exists();
}
