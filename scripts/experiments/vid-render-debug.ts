// One-off: what does the chat template render for a {type:"video"} part?
import { SNAPSHOT_QWEN38 } from "../../tests/paths";
import { ChatTemplate } from "../../src/chat-template";
import { loadTokenizer } from "../../src/tokenizer";

const template = await ChatTemplate.load(SNAPSHOT_QWEN38);
const tok = await loadTokenizer(SNAPSHOT_QWEN38);
const rendered = template.render(
  [{
    role: "user",
    content: [
      { type: "video" },
      { type: "text", text: "Describe this video in one short sentence." },
    ],
  } as never],
  { addGenerationPrompt: true },
);
console.log("rendered:", JSON.stringify(rendered.slice(0, 400)));
const ids = tok.encode(rendered, false);
console.log("video pads:", ids.filter((t) => t === 248057).length,
  "| image pads:", ids.filter((t) => t === 248056).length);
