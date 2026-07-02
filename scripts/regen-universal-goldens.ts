// Regenerate universal (Tier-0 generic) parity goldens from the mlx-lm
// oracle, manifest-driven (tests/universal-manifest.ts).
//
//   bun scripts/regen-universal-goldens.ts <prefix>   # one arch
//   bun scripts/regen-universal-goldens.ts all        # every DOWNLOADED entry
//
// Wraps scripts/gen-universal-golden.py in the oracle venv. Explicit token
// ids, per-step raw f32 logits — same pattern as regen-qwen-parity-goldens.
// Logit goldens are machine-specific (goldens.ts): output goes to the flat
// set on the reference box, goldens/<machine>/ elsewhere.
//
// Heavy: loads each model in the oracle. Never run automatically; models
// are downloaded by Josh (`hf download <repo>`), never from a session.

import { existsSync, mkdirSync } from "node:fs";
import { goldenOutDir } from "../tests/goldens";
import { ORACLE_PYTHON } from "../tests/paths";
import { UNIVERSAL_MANIFEST } from "../tests/universal-manifest";

const PROMPT = "The capital of France is";
const STEPS = 12;

const key = process.argv[2];
if (!key) {
  console.error("usage: bun scripts/regen-universal-goldens.ts <prefix>|all");
  console.error("prefixes:");
  for (const e of UNIVERSAL_MANIFEST)
    console.error(`  ${e.prefix.padEnd(20)} ${e.repoId}${existsSync(e.snapshot) ? "" : "  (not downloaded)"}`);
  process.exit(1);
}

const selected = key === "all"
  ? UNIVERSAL_MANIFEST.filter((e) => existsSync(`${e.snapshot}/config.json`))
  : UNIVERSAL_MANIFEST.filter((e) => e.prefix === key);
if (selected.length === 0) {
  console.error(`no manifest entry named ${key} (or nothing downloaded for 'all')`);
  process.exit(1);
}

const OUT = goldenOutDir();
mkdirSync(OUT, { recursive: true });

for (const e of selected) {
  if (!existsSync(`${e.snapshot}/config.json`)) {
    console.error(`${e.prefix}: snapshot missing — download first: hf download ${e.repoId}`);
    process.exit(1);
  }
  console.log(`${e.prefix}: oracle pass over ${e.repoId} …`);
  const proc = Bun.spawn(
    [ORACLE_PYTHON, "scripts/gen-universal-golden.py",
      e.snapshot, PROMPT, String(STEPS), OUT, e.prefix, e.repoId],
    { stdout: "pipe", stderr: "pipe" },
  );
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) throw new Error(`${e.prefix}: oracle failed (${code}):\n${err}`);
  await Bun.write(`${OUT}/${e.prefix}-parity.json`, JSON.stringify(JSON.parse(out), null, 1));
  console.log(`  wrote ${OUT}/${e.prefix}-parity.json + ${e.prefix}-logits-step*.bin`);
}
console.log(`universal parity goldens regenerated (${selected.length} arch(es)).`);
