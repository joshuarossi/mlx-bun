// Shared reference-environment paths (see PLAN.md "Reference environment").

export const ORACLE_PYTHON = "/Users/joshrossi/Code/mlx-lm/.venv/bin/python";

export const SNAPSHOT = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7`;

export async function snapshotAvailable(): Promise<boolean> {
  return Bun.file(`${SNAPSHOT}/config.json`).exists();
}
