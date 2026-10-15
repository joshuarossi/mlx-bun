import OpenAI from "openai";
import { TypeSafeClient, choice } from "@typesafe-ai/sdk";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

// Website calling patterns with local connection settings and an exact local model ID.
// https://developers.openai.com/api/docs/guides/decisions
// https://docs.typesafe.ai/sdk/javascript
export const decisionExampleModel = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
export async function runWebsiteExamples(baseURL, model = decisionExampleModel, laneImage) {
  const openai = new OpenAI({ apiKey: "local", baseURL: `${baseURL.replace(/\/$/, "")}/v1` });
  const jev = new TypeSafeClient({ apiKey: "local", baseURL });
  const openaiResult = await openai.decisions.create({
    model, input: "I was charged twice for my order.", questions: [{
      type: "choice", name: "department", instructions: "Which department should handle this complaint?",
      choices: [
        { value: "billing", description: "Payments, invoices, and refunds." },
        { value: "technical", description: "Problems using the product." },
        { value: "shipping", description: "Delivery and tracking." },
        { value: "other", description: "Requests outside these categories." },
      ],
    }],
  });
  const jevResult = await jev.systemOne({
    model,
    state: { document: "I was charged twice. Please fix this ASAP." }, questions: {
      category: choice("What is this ticket about?", { billing: null, technical: null, other: null }),
    },
  });
  let lane;
  if (laneImage) {
    const bytes = await readFile(laneImage);
    // The website's lane animation has scripted illustrative scores. Supply a
    // scene-only capture, with no probabilities or answer text in the image.
    lane = await openai.decisions.create({ model, input: [{ role: "user", content: [
      { type: "input_text", text: "A car is driving along the three-lane road shown in this image. Lane numbers are printed above the road." },
      { type: "input_image", image_url: `data:image/png;base64,${bytes.toString("base64")}` },
    ] }], questions: [{ type: "choice", name: "lane", instructions: "Which lane should the car choose to avoid the barriers ahead? Choose a destination lane, not a steering direction.",
      choices: [{ value: "lane_1", description: "The left lane, labeled 1." },
        { value: "lane_2", description: "The middle lane, labeled 2." },
        { value: "lane_3", description: "The right lane, labeled 3." }],
    }] });
  }
  return { openai: openaiResult, jev: jevResult, ...(lane ? { lane } : {}) };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  if (process.argv.includes("--help")) console.log(`Usage: node apps/mlx-bun/scripts/decision-website-examples.mjs [server-url] [model-id] [lane-scene.png]\nDefault model: ${decisionExampleModel}. Use an exact local ID from GET /v1/models.\nRequires an existing local server. Uses the upstream SDKs, Node 22+, and no cloud calls.`);
  else console.log(JSON.stringify(await runWebsiteExamples(process.argv[2] ?? "http://127.0.0.1:8080", process.argv[3], process.argv[4]), null, 2));
}
