// Regenerate the Whisper oracle goldens (goldens/whisper.json + untracked
// .bin blobs) with the mlx-whisper oracle venv.
//
//   bun scripts/regen.ts whisper [model-dir]
//
// The venv (MLX_BUN_WHISPER_ORACLE_VENV, default ~/Code/mlx-whisper-oracle/.venv)
// must carry mlx == MLX_CORE_VERSION and mlx-whisper; see
// docs/reference/environment.md "Whisper oracle".

import { existsSync } from "node:fs";
import { goldenOutDir } from "../../tests/support/goldens";
import { SNAPSHOT_WHISPER, WHISPER_ORACLE_PYTHON } from "../../tests/support/paths";

const modelDir = process.argv[2] ?? SNAPSHOT_WHISPER;
if (!existsSync(WHISPER_ORACLE_PYTHON)) {
  console.error(`whisper oracle venv missing: ${WHISPER_ORACLE_PYTHON}`);
  process.exit(1);
}
const proc = Bun.spawn(
  [WHISPER_ORACLE_PYTHON, "scripts/oracle/gen-whisper-golden.py", modelDir, goldenOutDir()],
  { stdout: "inherit", stderr: "inherit" },
);
process.exit(await proc.exited);
