// Regenerate oracle goldens by running the Python reference (mlx-lm venv).
// Explicit command, never run automatically (see PLAN.md testing strategy):
//
//   bun scripts/regen-goldens.ts
//
// Writes goldens/*.json used by the test suite.

import { ORACLE_PYTHON, SNAPSHOT } from "../tests/paths";

const valuesPy = `
import sys, json
import mlx.core as mx

snap = sys.argv[1]
w = mx.load(f"{snap}/model-00001-of-00002.safetensors")

ln = w["language_model.model.layers.0.input_layernorm.weight"].astype(mx.float32)
deq = mx.dequantize(
    w["language_model.model.embed_tokens.weight"][:4],
    scales=w["language_model.model.embed_tokens.scales"][:4],
    biases=w["language_model.model.embed_tokens.biases"][:4],
    group_size=64, bits=8,
).astype(mx.float32)

out = {
    "input_layernorm_l0_first16": ln[:16].tolist(),
    "input_layernorm_l0_sum": float(ln.sum()),
    "embed_dequant_rows4_first16": deq[0][:16].tolist(),
    "embed_dequant_rows4_sum": float(deq.sum()),
    "embed_dequant_shape": list(deq.shape),
}
print(json.dumps(out))
`;

const tokenizerPy = `
import sys, json
from transformers import AutoTokenizer

snap = sys.argv[1]
tok = AutoTokenizer.from_pretrained(snap)
prompts = [
    "Hello, world!",
    "The quick brown fox jumps over the lazy dog.",
    "def fibonacci(n):\\n    return n if n < 2 else fibonacci(n-1) + fibonacci(n-2)",
    "Ünïcödé ░▒▓ 日本語のテキスト 🦀🔥 \\u200d emoji zwj",
    "  leading and trailing spaces  ",
    "<start_of_turn>user\\nWhat is 2+2?<end_of_turn>\\n<start_of_turn>model\\n",
    "",
]
cases = []
for p in prompts:
    ids = tok.encode(p)
    cases.append({"text": p, "ids": ids, "decoded": tok.decode(ids)})
out = {
    "cases": cases,
    "bos_token_id": tok.bos_token_id,
    "eos_token_id": tok.eos_token_id,
    "vocab_size": len(tok),
}
print(json.dumps(out))
`;

async function runOracle(script: string): Promise<unknown> {
  const proc = Bun.spawn([ORACLE_PYTHON, "-c", script, SNAPSHOT], {
    stdout: "pipe",
    stderr: "pipe",
  });
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  if (code !== 0) throw new Error(`oracle script failed (${code}):\n${err}`);
  return JSON.parse(out);
}

console.log("regenerating goldens from oracle:", ORACLE_PYTHON);
await Bun.write("goldens/values.json", JSON.stringify(await runOracle(valuesPy), null, 1));
console.log("wrote goldens/values.json");
await Bun.write("goldens/tokenizer.json", JSON.stringify(await runOracle(tokenizerPy), null, 1));
console.log("wrote goldens/tokenizer.json");
