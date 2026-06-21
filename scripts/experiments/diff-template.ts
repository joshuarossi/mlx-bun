// Isolate template parity: take optiq's captured rendered_prompt, extract the
// user body he fed, render THAT same body through OUR ChatTemplate, and compare.
// If they differ, our chat template is the divergence (a porting bug we fix).
// CPU only — no model forward.
//   bun scripts/experiments/diff-template.ts [task]
import { readdirSync, readFileSync } from "node:fs";
import { ChatTemplate } from "../../src/chat-template";

const task = process.argv[2] ?? "gsm8k";
const hub = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots`;
const dir = `${hub}/${readdirSync(hub)[0]}`;
const tmpl = await ChatTemplate.load(dir);

const line = readFileSync(`${process.env.HOME}/.cache/mlx-bun/eval-data/${task}_optiq_frozen.jsonl`, "utf8").split("\n")[0]!;
const his: string = JSON.parse(line).rendered_prompt;

// Pull the user body out of his rendered prompt (between the user turn markers).
const m = his.match(/<\|im_start\|>user\n([\s\S]*?)<\|im_end\|>/);
if (!m) { console.log("could not locate user body in his prompt; raw head:\n", JSON.stringify(his.slice(0, 160))); process.exit(1); }
const body = m[1]!;

// Render that exact body through OUR template, the way generateText(useChat:true) does.
const ours = tmpl.render([{ role: "user", content: body }], { addGenerationPrompt: true, enableThinking: false });

console.log(`task=${task}  match=${ours === his}`);
if (ours !== his) {
  let i = 0;
  while (i < ours.length && i < his.length && ours[i] === his[i]) i++;
  console.log(`first diff at char ${i}:`);
  console.log("  HIS :", JSON.stringify(his.slice(Math.max(0, i - 20), i + 40)));
  console.log("  OURS:", JSON.stringify(ours.slice(Math.max(0, i - 20), i + 40)));
  console.log(`lengths: his=${his.length} ours=${ours.length}`);
  console.log("HIS  tail:", JSON.stringify(his.slice(-60)));
  console.log("OURS tail:", JSON.stringify(ours.slice(-60)));
}
