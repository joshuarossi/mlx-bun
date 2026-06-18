// Diagnostic: e4b vision greedy vs the optiq golden, with the forward-path
// flags controllable from the environment. Separates the two divergence
// sources: (a) my SigLIP vision features, (b) mlx-bun's LM forward path (fused
// GELU / fused SDPA / perf kernels are ON by default — the L3 path, NOT optiq's
// reference). Run twice:
//   bun scripts/diag-e4b-greedy.ts                                   # default (perf) path
//   MLX_BUN_FUSED_GELU=0 MLX_BUN_PERF_KERNEL=0 MLX_BUN_NO_FUSED_SDPA=1 \
//     MLX_BUN_FUSED_DECODE=0 MLX_BUN_COMPILED_DECODE=0 \
//     bun scripts/diag-e4b-greedy.ts                                 # reference path
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { Gemma4Model } from "../../src/model/gemma4";
import { SiglipVisionTower, parseSiglipConfig } from "../../src/vision/siglip";
import { buildVisionPrompt } from "../../src/vision/prompt";
import { ChatTemplate } from "../../src/chat-template";
import { loadTokenizer } from "../../src/tokenizer";
import { generate } from "../../src/generate";

const E4B = process.argv[2]
  ?? `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;

const flags = ["MLX_BUN_FUSED_GELU", "MLX_BUN_PERF_KERNEL", "MLX_BUN_NO_FUSED_SDPA",
  "MLX_BUN_FUSED_DECODE", "MLX_BUN_COMPILED_DECODE"];
console.log("flags:", flags.map((f) => `${f}=${process.env[f] ?? "(unset)"}`).join(" "));

const golden = await Bun.file("goldens/e4b-vision.json").json();
const config = await loadModelConfig(E4B);
const weights = await Weights.open(E4B);
const model = new Gemma4Model(weights, config);
const sigCfg = parseSiglipConfig(config.raw.vision_config as Record<string, unknown>);
const tower = SiglipVisionTower.load(E4B, sigCfg, model.embedScale);
const tokenizer = await loadTokenizer(E4B);
const template = await ChatTemplate.load(E4B);
const imageBytes = new Uint8Array(await Bun.file("tests/fixtures/grad-768.png").arrayBuffer());

const vp = await buildVisionPrompt(
  model, tower, tokenizer, template,
  [{ role: "user", content: [
    { type: "image" as const, data: Buffer.from(imageBytes).toString("base64") },
    { type: "text" as const, text: "Describe this image in one short sentence." },
  ] }] as never,
  [imageBytes], { imageTokenId: 258880, boiTokenId: 255999, eoiTokenId: 258882 },
);
// MLX_BUN_KV=quant exercises the L2 (optiq) mixed-precision quantized-KV path
// — the default `mlx-bun serve` config (kv_config.json). Default here is L1 bf16.
const kvScheme = process.env.MLX_BUN_KV === "quant" && config.kvQuant?.length
  ? { kvConfig: config.kvQuant, quantizedKvStart: 0 }
  : {};
console.log("kv path:", process.env.MLX_BUN_KV === "quant" ? "L2 quantized" : "L1 bf16");
const gen = generate(model, vp.ids, {
  maxTokens: 16, temperature: 0, promptEmbeddings: vp.embeddings, imageMask: vp.imageMask,
  ...kvScheme,
});
const out: number[] = [];
for await (const t of gen) out.push(t.token);
vp.embeddings.dispose();
vp.imageMask.dispose();

let match = 0;
while (match < out.length && out[match] === golden.greedy_ids[match]) match++;
console.log("golden:", JSON.stringify(golden.greedy_ids));
console.log("mine:  ", JSON.stringify(out));
console.log(`greedy prefix match: ${match}/${golden.greedy_ids.length}`);
console.log("decoded:", tokenizer.decode(out, true));
