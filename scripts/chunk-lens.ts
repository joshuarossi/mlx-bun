import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";

const DIR = "/Users/joshrossi/Code/lucien/benchmark/finetune/chunk";
const MODEL = process.env.MODEL ?? `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

const tok = await loadTokenizer(MODEL);
const tmpl = await ChatTemplate.load(MODEL);

for (const split of ["train", "valid"]) {
  const text = await Bun.file(`${DIR}/${split}.jsonl`).text();
  const lines = text.split("\n").map((l) => l.trim()).filter(Boolean);
  const lens: number[] = [];
  for (const line of lines) {
    const rec = JSON.parse(line) as { messages?: { role: string; content: string }[]; prompt?: string; completion?: string };
    let ids: number[];
    if (rec.messages) {
      const rendered = tmpl.render(rec.messages as any, { addGenerationPrompt: false });
      ids = tok.encode(rendered);
    } else {
      ids = tok.encode((rec.prompt ?? "") + (rec.completion ?? ""));
    }
    lens.push(ids.length);
  }
  lens.sort((a, b) => a - b);
  const n = lens.length;
  const pct = (p: number) => lens[Math.min(n - 1, Math.floor((p / 100) * n))];
  const fit = (cap: number) => lens.filter((x) => x <= cap).length;
  console.log(`\n=== ${split}: n=${n} ===`);
  console.log(`  min=${lens[0]}  p50=${pct(50)}  p90=${pct(90)}  p99=${pct(99)}  max=${lens[n-1]}`);
  console.log(`  fit <=1024: ${fit(1024)} (${(100*fit(1024)/n).toFixed(0)}%)   <=2048: ${fit(2048)} (${(100*fit(2048)/n).toFixed(0)}%)   <=4096: ${fit(4096)} (${(100*fit(4096)/n).toFixed(0)}%)   <=8192: ${fit(8192)} (${(100*fit(8192)/n).toFixed(0)}%)`);
}
