import { loadTaskModel } from "../../src/eval/runner";
const tm = await loadTaskModel("MiniCPM5");
const body = "Q: There are 15 trees.\nA: 6\n\nQ: Janet's ducks lay 16 eggs. How many?\nA:";
const rendered = tm.template!.render([{ role: "user", content: body }], { addGenerationPrompt: true, enableThinking: false });
console.log("rendered head:", JSON.stringify(rendered.slice(0, 50)));
const ids = tm.tokenizer.encode(rendered);
const bos = tm.tokenizer.bosTokenId;
console.log("encode(rendered) first 6 ids:", ids.slice(0, 6));
console.log("bosTokenId:", bos, "| ids[0]==bos?", ids[0] === bos, "| ids[1]==bos? (DOUBLE-BOS):", ids[1] === bos);
console.log("decode(first 4):", JSON.stringify(tm.tokenizer.decode(ids.slice(0, 4), false)));
// also: how the eval actually feeds it (generateText encodes the rendered text) — same path
