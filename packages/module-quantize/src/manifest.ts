// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "quantize",
  title: "Quantize",
  summary: "Quantize or convert a local MLX checkpoint: the managed quantize job, its web routes, and the convert verb.",
  requires: ["jobs", "storage", "catalog"],
  routes: [
    { id: "inspect", method: "POST", path: "/inspect", summary: "Whether a model is quantizable and its on-disk size, from its configuration alone", response: "json" },
    { id: "resolve-folder", method: "POST", path: "/resolve-folder", summary: "Locate a folder picked in the browser on disk (hub snapshot, the app's models directory, or an indexed model)", response: "json" },
    { id: "submit", method: "POST", path: "/submit", summary: "Queue a quantize job into the app's models directory; answers with the job id and output directory", response: "json" },
  ],
  verbs: [
    { name: "convert", summary: "Quantize an HF model into a local MLX snapshot (mlx_lm.convert counterpart)",
      positional: [{ name: "repo-or-path", summary: "The source model: a local path, a downloaded model, or an HF repo id" }],
      options: [
        { name: "hf-path", type: "string", summary: "Source model: local path, downloaded model, or HF repo id (fetched first); --model and the positional are aliases" },
        { name: "model", type: "string", summary: "Alias for --hf-path" },
        { name: "mlx-path", type: "string", summary: "Output directory; must not already exist [default: ~/.mlx-bun/models/<model>-<bits>bit]" },
        { name: "quantize", type: "boolean", short: "q", summary: "Quantize the model (uniform affine); without -q or --target-bpw the model is rewritten with --dtype and/or -d only" },
        { name: "q-bits", type: "string", summary: "Bits per weight: 4 or 8 [default: 4]" },
        { name: "q-group-size", type: "string", summary: "Quantization group size: 32 or 64 [default: 64]" },
        { name: "upload-repo", type: "string", missingValue: "--upload-repo expects a repo id (org/name)", summary: "Push the converted model to this Hugging Face repo afterwards (write token checked first)" },
        { name: "target-bpw", type: "string", summary: "Mixed precision target bits-per-weight, e.g. 4.5: OptiQ sensitivity sweep + per-layer knapsack; implies -q" },
        { name: "candidate-bits", type: "string", summary: "Comma list the knapsack may pick from [default: 4,8]" },
        { name: "calibration-mix", type: "string", summary: "\"optiq\" or a JSONL path [default: optiq]" },
        { name: "n-calibration", type: "string", summary: "Calibration samples [default: 2]" },
        { name: "rotate-weights", type: "boolean", summary: "Fold the model's offline TurboQuant rotation before quantization (auto-detects Llama/Qwen3.5/Qwen MTP)" },
        { name: "rotation-seed", type: "string", summary: "Deterministic rotation seed [default: 42]" },
        { name: "q-mode", type: "string", summary: "Quantization mode: affine, or trellis for packed Trellis (TCQ) MLP tensors of an HF-layout Qwen3.5-family model (rotation fold implied; implies -q) [default: affine]" },
        { name: "trellis-bits", type: "string", summary: "--q-mode trellis: bits per coded weight, 1-8 [default: 3]" },
        { name: "trellis-k-map", type: "string", summary: "--q-mode trellis: allocation JSON with per-tensor bits (budgets[--trellis-k-budget].kmap, optional affine_map)" },
        { name: "trellis-k-budget", type: "string", summary: "--q-mode trellis: budget key inside --trellis-k-map [default: 3.00]" },
        { name: "trellis-ldlq", type: "string", summary: "--q-mode trellis: directory of per-layer Hessian factors (layer-NNN-mlp|down.safetensors) enabling BlockLDLQ error feedback" },
        { name: "trellis-reuse", type: "string", summary: "--q-mode trellis: comma list of packed artifacts to copy unchanged-geometry tensors from instead of re-encoding" },
        { name: "trellis-down-axis", type: "string", summary: "--q-mode trellis: dim of down_proj the trellis runs along, out (rotated dim) or in [default: out]" },
        { name: "trellis-interleave", type: "boolean", summary: "--q-mode trellis: reorder eligible 3-bit axis-0 codes into the two-block scatter layout" },
        { name: "trellis-layers", type: "string", summary: "--q-mode trellis: trellis-code only the first N decoder layers (the rest ride the 3-bit affine base tier)" },
        { name: "dtype", type: "string", summary: "Dtype of the non-quantized tensors and of the quantization scales/biases: float16 | bfloat16 | float32 [default: bf16 scales/biases, other tensors unchanged]" },
        { name: "dequantize", type: "boolean", short: "d", summary: "Dequantize a quantized model to dense weights (not with -q)" },
        { name: "quant-predicate", type: "string", summary: "Not supported (mlx-lm's mixed_* recipes need 2/3/6-bit); use --target-bpw for mixed precision" },
      ] },
  ],
  jobs: [{ kind: "quantize", isolation: "process", gpu: "exclusive" }],
  storage: [{ key: "models", path: "models", kind: "directory", purpose: "Quantized and converted models: plain model directories, indexed beside the hub cache" }],
} as const satisfies Omit<AppModule<"jobs" | "storage" | "catalog">, "activate">;
