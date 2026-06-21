// Greedy-decode 8000 tokens with OUR engine from the SAME prompt ids mlx-lm used,
// via a manual forward+argmax loop (no EOS stop), and dump the token ids to compare.
import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel } from "../../src/eval/runner";

const promptIds: number[] = JSON.parse(readFileSync("/tmp/prompt_ids.json", "utf8"));
const tm = await loadTaskModel("MiniCPM5");
const cache = tm.model.makeCache();
if (promptIds.length > 1) tm.model.forward(promptIds.slice(0, -1), cache).dispose(); // prefill
let last = promptIds[promptIds.length - 1]!;
const out: number[] = [];
for (let i = 0; i < 8000; i++) {
  const lg = tm.model.forward([last], cache);
  const v = lg.toFloat32();
  lg.dispose();
  let best = 0, bv = -Infinity;
  for (let j = 0; j < v.length; j++) { const x = v[j]!; if (x > bv) { bv = x; best = j; } }
  out.push(best);
  last = best;
  if ((i + 1) % 500 === 0) process.stderr.write(`\r  ${i + 1}/8000`);
}
for (const c of cache) c.dispose();
process.stderr.write("\n");
writeFileSync("/tmp/our_ids.json", JSON.stringify(out));
console.log(`ours: generated ${out.length} first15=${JSON.stringify(out.slice(0, 15))}`);
