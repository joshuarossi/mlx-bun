// Shared reference-environment paths (see PLAN.md "Reference environment").

/** Oracle venv root — override with MLX_BUN_ORACLE_VENV on machines
 *  where the reference environment lives elsewhere. */
export const ORACLE_VENV =
  process.env.MLX_BUN_ORACLE_VENV ?? "/Users/joshrossi/Code/mlx-lm/.venv";

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
