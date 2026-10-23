// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "images",
  title: "Images",
  summary: "Text-to-image with a local image model: the OpenAI Images-compatible generations route and the image verb.",
  requires: ["modelHost", "catalog"],
  routes: [
    { id: "generations", method: "POST", path: "/v1/images/generations", summary: "Generate one PNG from a prompt (OpenAI Images-compatible; b64_json only)", response: "json", mount: "root" },
  ],
  verbs: [
    { name: "image", summary: "Text-to-image: write a PNG from a prompt with a local image model (no server)",
      positional: [{ name: "prompt", summary: "What to draw (quote it)", required: true }],
      usage: "usage: mlx-bun image <prompt> [--model <query>] [--out image.png] [--width 1024] [--height 1024] [--steps n] [--seed n]",
      options: [
        { name: "model", type: "string", summary: "Image model directory or cached query [default: the host's image model]" },
        { name: "out", type: "string", summary: "PNG path to write [default: image-<seed>.png in the current directory]" },
        { name: "width", type: "number", summary: "Width in pixels, a multiple of the model's latent scale [default: the model's]" },
        { name: "height", type: "number", summary: "Height in pixels, a multiple of the model's latent scale [default: the model's]" },
        { name: "steps", type: "number", summary: "Denoising steps [default: the model's]" },
        { name: "guidance", type: "number", summary: "Classifier-free guidance scale; 1 runs the conditional prediction alone [default: the model's]" },
        { name: "seed", type: "number", summary: "Initial-noise seed, an integer in [0, 2^53) [default: random, reported]" },
        { name: "negative-prompt", type: "string", summary: "What the guidance steers away from [default: the model's]" },
        { name: "no-skip-layers", type: "boolean", summary: "Run the unconditional prediction through every block (disables skip-layer guidance)" },
        { name: "json", type: "boolean", summary: "Print a JSON summary (path, model, size, seed, steps, guidance, timings) instead of the path" },
      ] },
  ],
} as const satisfies Omit<AppModule<"modelHost" | "catalog">, "activate">;
