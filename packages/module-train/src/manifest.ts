// The module's static manifest: plain data, read by hosts and documentation
// generators without loading a model or native code (this file imports only
// types). `index.ts` adds `activate`.
import type { AppModule } from "@mlx-bun/app-core";

export const manifest = {
  id: "train",
  title: "Train",
  summary: "Fine-tune LoRA adapters (SFT, DPO, ORPO), fuse them into a model and train speculative-decoding drafters: the managed finetune job, its web routes, and the train, train-watch, fuse and draft verbs.",
  requires: ["jobs", "storage", "catalog"],
  routes: [
    { id: "inspect-dataset", method: "POST", path: "/api/finetune/inspect-dataset", summary: "Count a dataset directory's train and validation rows and detect its format before submitting", response: "json", mount: "root" },
    { id: "submit", method: "POST", path: "/api/finetune/submit", summary: "Queue a fine-tune job (SFT, DPO or ORPO); answers with the job id and the adapter directory", response: "json", mount: "root" },
  ],
  verbs: [
    { name: "train", summary: "Fine-tune a LoRA adapter on your data (sft | dpo | orpo)",
      positional: [{ name: "model", summary: "The model to fine-tune: a local path or a downloaded model; the automatic choice when omitted" }],
      options: [
        { name: "query", type: "string", summary: "Model to fine-tune when no positional query is supplied (auto-picks the default model if omitted)" },
        { name: "data", type: "string", summary: "Dataset dir with train.jsonl (+ optional valid.jsonl); rows are {prompt, chosen, rejected} for dpo/orpo, {messages|text} for sft  (required)" },
        { name: "method", type: "string", summary: "sft | dpo | orpo  [default: orpo]" },
        { name: "adapter", type: "string", summary: "Output adapter dir  [default: ~/.mlx-bun/adapters/<method>-<model>]" },
        { name: "iters", type: "string", summary: "Training iterations  [default: 100]" },
        { name: "lr", type: "string", summary: "Learning rate  [default: orpo 1e-5 · dpo 5e-5 · sft 2e-4]" },
        { name: "rank", type: "string", summary: "LoRA rank  [default: orpo 16 · else 8]" },
        { name: "scale", type: "string", summary: "LoRA scale  [default: orpo 2.0 · else 1.0]" },
        { name: "seq", type: "string", summary: "Max sequence length  [default: the model's own; 4096 when it declares none]" },
        { name: "batch", type: "string", summary: "Batch size  [default: 1]" },
        { name: "grad-accum", type: "string", summary: "Gradient accumulation steps (effective batch = batch × grad-accum at batch-size-1 memory)  [default: 1]" },
        { name: "grad-clip", type: "string", summary: "Gradient-norm clip (0 = off)  [default: 1.0]" },
        { name: "seed", type: "string", summary: "Data-shuffle / init seed  [default: 0]" },
        { name: "val-size", type: "string", summary: "Max validation examples per eval  [default: 256]" },
        { name: "lambda", type: "string", summary: "ORPO odds-ratio weight  [default: 0.1]" },
        { name: "sft-scope", type: "string", summary: "ORPO chosen-NLL scope: full (paper/TRL-faithful, prompt+response) | response (pre-2026-07 runs, bit-exact)  [default: full]" },
        { name: "seg", type: "string", summary: "Layers per segment (segmented backward; orpo default 2)" },
        { name: "save-every", type: "string", summary: "Crash-safe mountable checkpoint every n steps" },
        { name: "resume", type: "string", summary: "Warm-start LoRA weights from a checkpoint/adapter dir" },
        { name: "no-flash", type: "boolean", summary: "Disable the flash-CCE Metal head (use the MLX fused head)" },
        { name: "no-prefix", type: "boolean", summary: "Disable prefix-sharing (two-forward branches)" },
        { name: "no-segment", type: "boolean", summary: "Disable the segmented backward (hold all activations)" },
        { name: "num-layers", type: "string", summary: "Layers to adapt, counted from the last; -1 = all  [default: -1]" },
        { name: "steps-per-report", type: "string", summary: "Steps between loss reports  [default: 1]" },
        { name: "steps-per-eval", type: "string", summary: "Steps between validations  [default: every --save-every steps, else never]" },
        { name: "dropout", type: "string", summary: "LoRA dropout  [default: 0]" },
        { name: "weight-decay", type: "string", summary: "AdamW weight decay  [default: 0.01]" },
        { name: "grad-checkpoint", type: "boolean", summary: "Recompute activations in the backward pass to save memory" },
        { name: "dry-run", type: "boolean", summary: "Inspect the dataset + print the resolved plan, don't train" },
      ] },
    { name: "draft", summary: "Produce a speculative-decoding drafter: regen | train | calibrate | quantize",
      usage: "usage: mlx-bun draft <regen|train|calibrate|quantize> <model|drafter-dir> [options]",
      details: `Produce the drafters \`mlx-bun serve --draft-model\` mounts. A DSpark drafter is
trained against ONE frozen target, in three stages, each a subcommand:

  regen <model> --topics <file>          The target answers each topic with its own
                                         greedy generation; one tapped forward per
                                         sequence records the drafter's context
                                         hiddens (shards under ~/.mlx-bun/datasets)
  train <model> --data <shards>          Train the drafter on the shards; the best
                                         held-out τ is saved as a directory in
                                         ~/.mlx-bun/models that serve mounts
  calibrate <model> --drafter <dir> --data <prompts.jsonl>
                                         Fit per-position confidence thresholds by
                                         speculative runs; written into dspark.json
                                         so serving prunes positions the head cannot call
  quantize <drafter-dir>                 Affine-quantize a released DeepSpec
                                         (Gemma4DSparkModel) drafter; its
                                         confidence_head stays bf16

The target and \`--tap-layers\` MUST be the same for regen and train. Drafter
numerics only move acceptance, never correctness (the target verifies every
draft): gate a drafter, or a quantized one, with \`bun scripts/drafter-ab.ts\`.
Stages run in the foreground on the GPU; do not run one while a server or
another training run holds it.`,
      positional: [
        { name: "action", summary: "regen, train, calibrate or quantize", required: true },
        { name: "model", summary: "The target model (regen, train, calibrate) or the DeepSpec drafter directory (quantize); --model is the option spelling" },
      ],
      options: [
        { name: "model", type: "string", summary: "Target model (regen, train, calibrate) or DeepSpec drafter directory (quantize); the option spelling of the second positional" },
        { name: "topics", type: "string", summary: "regen: text file with one topic per line the target writes an article about  (required)" },
        { name: "data", type: "string", summary: "train: shard directory from regen  (required) · calibrate: JSONL of {prompt} rows, a string or chat messages  (required)" },
        { name: "out", type: "string", summary: "Output directory  [default: regen ~/.mlx-bun/datasets/dspark-<model> · train ~/.mlx-bun/models/<model>-dspark · quantize ~/.mlx-bun/models/<drafter>-affine-q<bits>-g<group> · calibrate: in place]" },
        { name: "tap-layers", type: "string", summary: "regen/train: target layers the drafter reads, comma separated, the last normally the layer count (post-final-norm). MUST match between regen and train  [default: 20,31,41,42 (gemma-4 e4b)]" },
        { name: "max-resp", type: "string", summary: "regen: generated tokens per topic  [default: 320]" },
        { name: "seqs-per-shard", type: "string", summary: "regen: sequences per shard file  [default: 32]" },
        { name: "min-resp", type: "string", summary: "regen: drop responses shorter than this  [default: 6]" },
        { name: "iters", type: "string", summary: "train: optimizer steps  [default: 6000]" },
        { name: "batch", type: "string", summary: "train: anchors per step  [default: 8]" },
        { name: "gamma", type: "string", summary: "train: draft block length  [default: 5]" },
        { name: "max-ctx", type: "string", summary: "train: cap on the prefix context each anchor attends  [default: 512]" },
        { name: "lr", type: "string", summary: "train: peak learning rate  [default: 1.5e-3]" },
        { name: "warmup", type: "string", summary: "train: warmup steps  [default: 150]" },
        { name: "eval-every", type: "string", summary: "train: steps between held-out evaluations; the best held-out τ is what is saved  [default: 500]" },
        { name: "eval-anchors", type: "string", summary: "train: anchors per held-out evaluation  [default: 256]" },
        { name: "seed", type: "string", summary: "train: init and sampling seed  [default: 0]" },
        { name: "d-draft", type: "string", summary: "train: drafter width  [default: 1024]" },
        { name: "n-heads", type: "string", summary: "train: drafter attention heads  [default: 8]" },
        { name: "layers", type: "string", summary: "train: drafter backbone depth  [default: 5]" },
        { name: "markov-rank", type: "string", summary: "train: sequential-head rank  [default: 256]" },
        { name: "seq-head", type: "string", summary: "train: sequential head, markov (Eq 5) | rnn (Eq 6)  [default: markov]" },
        { name: "resume", type: "boolean", summary: "train: warm-start weights from an existing checkpoint in --out (the optimizer and schedule restart)" },
        { name: "drafter", type: "string", summary: "calibrate: the trained drafter directory whose dspark.json receives the thresholds  (required)" },
        { name: "n", type: "string", summary: "calibrate: prompts to run  [default: 32]" },
        { name: "max-tokens", type: "string", summary: "calibrate: generated tokens per prompt  [default: 128]" },
        { name: "precision", type: "string", summary: "calibrate: acceptance precision each kept position must reach, in (0, 1]  [default: 0.5]" },
        { name: "min-samples", type: "string", summary: "calibrate: positions with fewer observations are never pruned  [default: 50]" },
        { name: "force", type: "boolean", summary: "calibrate: recalibrate a drafter that already carries thresholds" },
        { name: "bits", type: "string", summary: "quantize: 4 | 8  [default: 4]" },
        { name: "group-size", type: "string", summary: "quantize: 32 | 64  [default: 64]" },
      ] },
    { name: "train-watch", summary: "Live dashboard for a training run (tails <adapter-dir>/metrics.jsonl)",
      positional: [{ name: "adapter-dir", summary: "The adapter directory to watch; the latest run when omitted" }],
      options: [
        { name: "adapter", type: "string", summary: "Adapter directory to watch; accepted for the positional  [default: the latest run in ~/.mlx-bun/adapters]" },
      ] },
    { name: "fuse", summary: "Merge a LoRA adapter into the base weights (writes a standalone snapshot)",
      positional: [{ name: "model", summary: "The base model: a local path or a downloaded model" }],
      options: [
        { name: "model", type: "string", summary: "Base model (registry query or a snapshot path); the mlx_lm.fuse spelling of the positional" },
        { name: "adapter", type: "string", summary: "Adapter directory (adapters.safetensors + adapter_config.json)  [default: adapters]" },
        { name: "adapter-path", type: "string", summary: "mlx_lm.fuse alias for --adapter" },
        { name: "save-path", type: "string", summary: "Output model directory  [default: ~/.mlx-bun/models/<model>-fused]" },
        { name: "dequantize", type: "boolean", summary: "Write dense weights instead of the base's quantized layout (drops the config's quantization block)" },
        { name: "export-gguf", type: "boolean", summary: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
        { name: "gguf-path", type: "string", summary: "Not supported (mlx_lm.fuse flag); the command exits with an error" },
        { name: "upload-repo", type: "string", summary: "Push the fused model to this Hugging Face repo afterwards (write token checked first)" },
      ] },
  ],
  jobs: [{ kind: "finetune", isolation: "process", gpu: "exclusive" }],
  storage: [
    { key: "adapters", path: "adapters", kind: "directory", purpose: "Fine-tuned adapters: one directory per run, with checkpoints and metrics" },
    // Shared with the quantize module (every producer of a model writes here).
    { key: "models", path: "models", kind: "directory", purpose: "Fused models and trained drafters: plain model directories, indexed beside the hub cache" },
    // Shared with the datasets module.
    { key: "datasets", path: "datasets", kind: "directory", purpose: "Drafter regeneration shards, one directory per target model" },
  ],
  panel: { tag: "mlx-train-panel", entry: "@mlx-bun/module-train/panel", title: "Fine-tune", path: "/finetune" },
} as const satisfies Omit<AppModule<"jobs" | "storage" | "catalog">, "activate">;
