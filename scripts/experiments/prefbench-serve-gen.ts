// Exp 2 generation via the running mlx-bun SERVER (so it works while the GPU is
// busy serving, instead of loading its own model like prefbench.ts gen). Base is
// genned ONCE and reused across adapters. Writes the same
// runs/<stem>.responses.jsonl that `prefbench.ts judge <stem>` consumes.
//
//   bun scripts/experiments/prefbench-serve-gen.ts <mtbench|alpaca> <id1:stem1,id2:stem2,...> [limit]
//   PORT=8080 MAXTOK=512 bun ... mtbench orpo6000:mt-orpo6000
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const DIR = `${process.env.HOME}/.cache/mlx-bun/eval-data`;
const PORT = process.env.PORT ?? "8080";
const MODEL = process.env.SERVE_MODEL ?? "mlx-community/MiniCPM5-1B-OptiQ-4bit";
const MAXTOK = Number(process.env.MAXTOK ?? "512");

function loadPrompts(bench: string, limit?: number): { id: string; instruction: string }[] {
  let out: { id: string; instruction: string }[];
  if (bench === "mtbench") {
    out = readFileSync(`${DIR}/mt_bench.jsonl`, "utf8").trim().split("\n").map((l) => {
      const o = JSON.parse(l) as { question_id: number; turns: string[] };
      return { id: String(o.question_id), instruction: o.turns[0]! };
    });
  } else if (bench === "alpaca") {
    out = (JSON.parse(readFileSync(`${DIR}/alpaca_eval.json`, "utf8")) as { instruction: string }[])
      .map((o, i) => ({ id: String(i), instruction: o.instruction }));
  } else throw new Error(`unknown bench '${bench}' (mtbench|alpaca)`);
  return limit ? out.slice(0, limit) : out;
}

async function gen(instruction: string, adapter: string | null): Promise<string> {
  const body: Record<string, unknown> = { model: MODEL, messages: [{ role: "user", content: instruction }], max_tokens: MAXTOK, temperature: 0 };
  if (adapter) body.adapter = adapter;
  const r = await fetch(`http://localhost:${PORT}/v1/chat/completions`, {
    method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 200)}`);
  const j = (await r.json()) as { choices: { message: { content: string } }[] };
  return j.choices[0]!.message.content;
}

const bench = process.argv[2]!;
const pairs = process.argv[3]!.split(",").map((p) => { const [id, stem] = p.split(":"); return { id: id!, stem: stem! }; });
const limit = process.argv[4] ? Number(process.argv[4]) : undefined;
const prompts = loadPrompts(bench, limit);
console.log(`### serve-gen: ${prompts.length} ${bench} prompts · base + ${pairs.length} adapter(s) · maxTok=${MAXTOK}`);

const t0 = Date.now();
const base: string[] = [];
for (let i = 0; i < prompts.length; i++) { base.push(await gen(prompts[i]!.instruction, null)); if ((i + 1) % 20 === 0) console.log(`  base ${i + 1}/${prompts.length}`); }
mkdirSync("runs", { recursive: true });
for (const { id, stem } of pairs) {
  const rows: { id: string; instruction: string; base: string; trained: string }[] = [];
  for (let i = 0; i < prompts.length; i++) {
    const trained = await gen(prompts[i]!.instruction, id);
    rows.push({ id: prompts[i]!.id, instruction: prompts[i]!.instruction, base: base[i]!, trained });
    if ((i + 1) % 20 === 0) console.log(`  ${stem} ${i + 1}/${prompts.length}`);
  }
  writeFileSync(`runs/${stem}.responses.jsonl`, rows.map((r) => JSON.stringify(r)).join("\n") + "\n");
  console.log(`  wrote runs/${stem}.responses.jsonl`);
}
console.log(`### done in ${Math.round((Date.now() - t0) / 1000)}s`);
