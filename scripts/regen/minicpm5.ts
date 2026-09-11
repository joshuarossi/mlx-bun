// Regenerate MiniCPM5-1B llama-family goldens from the Python oracle.
// Explicit command:
//   MLX_BUN_ORACLE_VENV=<matching venv from docs/reference/environment.md> \
//     bun scripts/regen.ts minicpm5
//
// Writes:
//   <goldenOutDir>/minicpm5-parity.json
//   <goldenOutDir>/minicpm5-logits-step<i>.bin

import { existsSync, mkdirSync } from "node:fs";
import { goldenOutDir } from "../../tests/support/goldens";
import { ORACLE_PYTHON, SNAPSHOT_MINICPM5 } from "../../tests/support/paths";

const OUT = goldenOutDir();
for (const file of [ORACLE_PYTHON, `${SNAPSHOT_MINICPM5}/config.json`, `${SNAPSHOT_MINICPM5}/model.safetensors.index.json`]) {
  if (!existsSync(file)) throw new Error(`Missing MiniCPM5 comparison input: ${file}. See docs/reference/environment.md#reproduce-the-minicpm5-logit-comparison`);
}
mkdirSync(OUT, { recursive: true });

const PROMPT = "The capital of France is";
const MAX_TOKENS = 100;
const LOGIT_STEPS = MAX_TOKENS;

const py = `
import sys, json, hashlib, importlib.metadata
from pathlib import Path
import mlx.core as mx
from mlx_lm import load
from mlx_lm.models.cache import make_prompt_cache

snap, prompt, max_tokens, logit_steps, outdir = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
model, tokenizer = load(snap)
ids = tokenizer.encode(prompt)

cache = make_prompt_cache(model)
greedy = []
y = mx.array([ids])
for step in range(max_tokens):
    logits = model(y, cache=cache)
    last = logits[0, -1, :].astype(mx.float32)
    mx.eval(last)
    if step < logit_steps:
        with open(f"{outdir}/minicpm5-logits-step{step}.bin", "wb") as f:
            f.write(bytes(memoryview(last)))
    tok = mx.argmax(last).item()
    greedy.append(tok)
    y = mx.array([[tok]])

def file_hash(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()

out = {
    "model": "mlx-community/MiniCPM5-1B-OptiQ-4bit",
    "snapshot": snap,
    "prompt": prompt,
    "prompt_ids": ids,
    "greedy_ids": greedy,
    "logit_steps": logit_steps,
    "vocab_size": int(last.shape[0]),
    "oracle": {
        "python": sys.version.split()[0],
        "mlx": mx.__version__,
        "mlx_metal": importlib.metadata.version("mlx-metal"),
        "mlx_metal_wheel": json.loads(importlib.metadata.distribution("mlx-metal").read_text("direct_url.json") or "null"),
        "mlx_lm": importlib.metadata.version("mlx-lm"),
        "device": mx.device_info(),
        "config_sha256": hashlib.sha256(Path(snap, "config.json").read_bytes()).hexdigest(),
        "model_files_sha256": {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(Path(snap).iterdir())
            if p.suffix in (".json", ".jinja")},
        "weights_sha256": {p.name: file_hash(p)
            for p in sorted(Path(snap).glob("*.safetensors"))},
        "blobs": {f"minicpm5-logits-step{i}.bin": hashlib.sha256(
            Path(outdir, f"minicpm5-logits-step{i}.bin").read_bytes()).hexdigest()
            for i in range(logit_steps)},
    },
}
print(json.dumps(out))
`;

const proc = Bun.spawn(
  [ORACLE_PYTHON, "-c", py, SNAPSHOT_MINICPM5, PROMPT, String(MAX_TOKENS), String(LOGIT_STEPS), OUT],
  { stdout: "pipe", stderr: "pipe" },
);
const [out, err, code] = await Promise.all([
  new Response(proc.stdout).text(),
  new Response(proc.stderr).text(),
  proc.exited,
]);
if (code !== 0) throw new Error(`MiniCPM5 oracle failed (${code}):\n${err}`);
const manifest = JSON.parse(out);
manifest.oracle.requirements_sha256 = new Bun.CryptoHasher("sha256")
  .update(await Bun.file(new URL("../oracle/requirements.lock", import.meta.url)).arrayBuffer()).digest("hex");
await Bun.write(`${OUT}/minicpm5-parity.json`, JSON.stringify(manifest, null, 1));
console.log(`wrote ${OUT}/minicpm5-parity.json + minicpm5-logits-step*.bin`);
