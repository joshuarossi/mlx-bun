// Shared reference-environment paths (see PLAN.md "Reference environment").

import { existsSync, realpathSync } from "node:fs";

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

export async function snapshotAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT}/config.json`).exists();
}

export async function snapshot26bAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_26B}/config.json`).exists();
}

export async function snapshotMiniCPM5Available(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT_MINICPM5}/config.json`).exists();
}
