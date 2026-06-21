// Exp 2: head-to-head base-vs-trained on AlpacaEval / MT-Bench, judged by codex.
// Two phases (so generation = GPU runs when free; judging = codex runs anytime):
//
//   bun scripts/experiments/prefbench.ts dry   <mtbench|alpaca> [limit]
//   bun scripts/experiments/prefbench.ts gen   <mtbench|alpaca> <adapterDir> <stem> [limit]
//   bun scripts/experiments/prefbench.ts judge <stem> [limit]
//
// gen   -> runs/<stem>.responses.jsonl  {id, instruction, base, trained}   (GPU)
// judge -> runs/<stem>.judged.json + a printed TRAINED win-rate vs BASE     (codex)
//
// We compare base vs trained DIRECTLY (not vs a fixed reference): the question is
// "did ORPO make our model better", so consistency (same judge both sides, both
// orders) matters, not absolute comparability to the paper's GPT-4 numbers.
import { readFileSync, writeFileSync, mkdirSync, readdirSync } from "node:fs";
import { judgePair } from "./llm-judge";

const DIR = `${process.env.HOME}/.cache/mlx-bun/eval-data`;

function loadPrompts(bench: string, limit?: number): { id: string; instruction: string }[] {
  let out: { id: string; instruction: string }[];
  if (bench === "mtbench") {
    out = readFileSync(`${DIR}/mt_bench.jsonl`, "utf8").trim().split("\n").map((l) => {
      const o = JSON.parse(l) as { question_id: number; turns: string[] };
      return { id: String(o.question_id), instruction: o.turns[0]! }; // turn-1 (single-turn head-to-head)
    });
  } else if (bench === "alpaca") {
    out = (JSON.parse(readFileSync(`${DIR}/alpaca_eval.json`, "utf8")) as { instruction: string }[])
      .map((o, i) => ({ id: String(i), instruction: o.instruction }));
  } else throw new Error(`unknown bench '${bench}' (mtbench|alpaca)`);
  return limit ? out.slice(0, limit) : out;
}

const mode = process.argv[2];

if (mode === "dry") {
  const ps = loadPrompts(process.argv[3]!, process.argv[4] ? Number(process.argv[4]) : undefined);
  console.log(`${ps.length} prompts loaded from ${process.argv[3]}`);
  console.log(`first: [${ps[0]!.id}] ${ps[0]!.instruction.slice(0, 80)}…`);

} else if (mode === "gen") {
  const [, , , bench, adapterDir, stem, limitStr] = process.argv;
  if (!bench || !adapterDir || !stem) { console.error("gen <mtbench|alpaca> <adapterDir> <stem> [limit]"); process.exit(1); }
  const { loadTaskModel, generateText } = await import("../../src/eval/runner");
  const { AdapterManager } = await import("../../src/lora");
  const hub = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
  const BASE = `${hub}/${readdirSync(hub)[0]}`;
  const maxTokens = Number(process.env.MAXTOK ?? "768");
  const prompts = loadPrompts(bench, limitStr ? Number(limitStr) : undefined);

  const tm = await loadTaskModel(BASE);
  console.log(`### gen: ${prompts.length} prompts, base then trained (adapter ${adapterDir}), maxTok=${maxTokens}`);
  const base: string[] = [];
  for (let i = 0; i < prompts.length; i++) {
    base.push(await generateText(tm, prompts[i]!.instruction, { maxTokens, useChat: true }));
    if ((i + 1) % 20 === 0) console.log(`  base ${i + 1}/${prompts.length}`);
  }
  const mgr = new AdapterManager(tm.model);
  await mgr.mount("trained", adapterDir);
  const trained: string[] = [];
  for (let i = 0; i < prompts.length; i++) {
    trained.push(await generateText(tm, prompts[i]!.instruction, { maxTokens, useChat: true }));
    if ((i + 1) % 20 === 0) console.log(`  trained ${i + 1}/${prompts.length}`);
  }
  mkdirSync("runs", { recursive: true });
  const rows = prompts.map((p, i) => ({ id: p.id, instruction: p.instruction, base: base[i], trained: trained[i] }));
  writeFileSync(`runs/${stem}.responses.jsonl`, rows.map((r) => JSON.stringify(r)).join("\n") + "\n");
  console.log(`wrote ${rows.length} base+trained pairs -> runs/${stem}.responses.jsonl`);

} else if (mode === "judge") {
  const [, , , stem, limitStr] = process.argv;
  if (!stem) { console.error("judge <stem> [limit]"); process.exit(1); }
  const rows = readFileSync(`runs/${stem}.responses.jsonl`, "utf8").trim().split("\n").map((l) => JSON.parse(l) as { id: string; instruction: string; base: string; trained: string });
  const lim = limitStr ? Number(limitStr) : rows.length;
  let tW = 0, bW = 0, tie = 0;
  const detail: { id: string; trained: number; base: number; tie: number }[] = [];
  for (let i = 0; i < lim; i++) {
    const r = rows[i]!;
    const v = judgePair(r.instruction, r.trained, r.base); // first = trained, second = base
    tW += v.first; bW += v.second; tie += v.tie;
    detail.push({ id: r.id, trained: v.first, base: v.second, tie: v.tie });
    if ((i + 1) % 10 === 0) console.log(`  judged ${i + 1}/${lim}  (trained ${tW} / base ${bW} / tie ${tie})`);
  }
  const total = tW + bW + tie;
  const winRate = (tW + 0.5 * tie) / total;
  mkdirSync("runs", { recursive: true });
  writeFileSync(`runs/${stem}.judged.json`, JSON.stringify({ stem, trainedWins: tW, baseWins: bW, ties: tie, total, winRate, detail }, null, 2));
  console.log(`\nTRAINED win-rate vs BASE: ${(winRate * 100).toFixed(1)}%  (trained ${tW} / base ${bW} / tie ${tie} over ${lim} prompts × 2 orders)`);

} else {
  console.error("usage: prefbench.ts <dry|gen|judge> ...");
  process.exit(1);
}
