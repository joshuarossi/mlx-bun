// The mlx-lm command aliases (mlx-bun.<cmd>), model-free and CPU-only: mlx_lm's
// own argument forms translated to the mlx-bun verb, the resolved verb options,
// and the launcher files npm/Bun link under each alias name.
import { afterAll, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, statSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { plainTerminal } from "@mlx-bun/app-services";
import { runConvert, type ConvertDependencies } from "@mlx-bun/module-quantize";
import { parseTrainArgs, runFuse, trainPlan, type FuseDependencies } from "@mlx-bun/module-train";
import { isCommand } from "../src/cli/args";
import { generateOptions } from "../src/cli/inference";
import { ALIASES, ALIAS_GAPS, invokedAlias, translateAlias } from "../src/cli/mlx-lm-aliases";
import { installedVerbs, runInstalledVerb } from "../src/cli/module-verbs";
import { parseServeOptions } from "../src/cli/serve";
import { runUpload, type UploadDependencies } from "../src/cli/upload";

const app = resolve(import.meta.dir, "..");
const manifest = JSON.parse(readFileSync(join(app, "package.json"), "utf8")) as { bin: Record<string, string> };

function translate(name: string, ...argv: string[]) {
  const result = translateAlias(name, argv);
  if ("help" in result) throw new Error("unexpected help");
  return result;
}
const values = (name: string, ...argv: string[]) => translate(name, ...argv).parsed.values;
const roots: string[] = [];
function temporary(prefix: string): string { const dir = mkdtempSync(join(tmpdir(), prefix)); roots.push(dir); return dir; }
afterAll(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

test("every mlx-lm 0.31.3 console script is an alias or a listed gap, and the package links exactly the aliases", () => {
  // mlx_lm-0.31.3.dist-info/entry_points.txt; `mlx_lm` itself is the `python -m mlx_lm <cmd>` dispatcher.
  const scripts = ["awq", "benchmark", "cache_prompt", "chat", "convert", "dwq", "dynamic_quant", "evaluate", "fuse", "generate",
    "gptq", "lora", "manage", "perplexity", "server", "share", "upload"];
  expect(scripts.filter(name => !(name in ALIASES) && !(name in ALIAS_GAPS))).toEqual([]);
  expect(Object.keys(ALIASES).filter(name => name in ALIAS_GAPS)).toEqual([]);
  expect(Object.keys(ALIASES).sort()).toEqual(["convert", "fuse", "generate", "lora", "server", "upload"]);
  // Each alias runs a verb the app owns or one an installed module declares.
  for (const alias of Object.values(ALIASES)) expect(isCommand(alias.verb) || installedVerbs().has(alias.verb)).toBe(true);
  expect(Object.keys(manifest.bin).sort()).toEqual(["mlx-bun", ...Object.keys(ALIASES).map(name => `mlx-bun.${name}`)].sort());
  for (const [name, file] of Object.entries(manifest.bin)) {
    expect(file).toBe(`./bin/${name}.mjs`);
    expect(existsSync(join(app, file))).toBe(true);
    expect(statSync(join(app, file)).mode & 0o111).not.toBe(0);
  }
});

test("the invoked name selects the alias: the standalone executable's own name, or the launcher file from source", () => {
  expect(invokedAlias({ main: "/$bunfs/root/mlx-bun", argv0: "mlx-bun.generate" })).toBe("generate");
  expect(invokedAlias({ main: "/$bunfs/root/mlx-bun", argv0: "/Users/x/.local/bin/mlx-bun.lora" })).toBe("lora");
  expect(invokedAlias({ main: "/$bunfs/root/mlx-bun", argv0: "mlx-bun" })).toBeNull();
  expect(invokedAlias({ main: "/repo/apps/mlx-bun/bin/mlx-bun.server.mjs", argv1: "/repo/apps/mlx-bun/bin/mlx-bun.server.mjs" })).toBe("server");
  expect(invokedAlias({ main: "/repo/bin/mlx-bun.mjs", argv1: "/repo/bin/mlx-bun.mjs" })).toBeNull();
  expect(invokedAlias({ main: "/repo/src/cli/main.ts", argv1: "/repo/src/cli/main.ts" })).toBeNull();
  expect(() => translateAlias("chat", [])).toThrow("mlx-bun.chat: mlx_lm.chat has no mlx-bun counterpart (no interactive terminal chat");
  expect(() => translateAlias("nope", [])).toThrow("mlx-bun.nope: unknown mlx-lm alias; available: mlx-bun.server, mlx-bun.generate");
});

test("argparse-style forms: =value, short flags, negative numbers, --, lists, and refusals", () => {
  expect(values("generate", "--max-tokens=12", "-p", "-")).toEqual({ "max-tokens": "12", prompt: "-" });
  expect(values("generate", "-m", "5", "--temp", "-0.5")).toEqual({ "max-tokens": "5", temp: "-0.5" });
  expect(values("lora", "--train", "--num-layers", "-1", "--val-batches", "-1")).toMatchObject({ "num-layers": "-1", "val-size": String(Number.MAX_SAFE_INTEGER) });
  expect(translate("generate", "--", "model", "hi").parsed.positionals).toEqual(["model", "hi"]);
  expect(translate("generate", "model", "--prompt", "hi").parsed.positionals).toEqual(["model"]);
  for (const [argv, message] of [
    [["--nope"], "mlx-bun.generate: unrecognized argument: --nope"],
    [["--max-tokens"], "mlx-bun.generate: argument --max-tokens: expected one argument"],
    [["--max-tokens", "--temp", "1"], "mlx-bun.generate: argument --max-tokens: expected one argument"],
    [["--ignore-chat-template=1"], "mlx-bun.generate: argument --ignore-chat-template: ignored explicit argument '1'"],
    [["--extra-eos-token"], "mlx-bun.generate: argument --extra-eos-token: expected at least one argument"],
    [["a", "b", "c"], "Too many arguments for generate"],
    [["-z"], "mlx-bun.generate: unrecognized argument: -z"],
  ] as [string[], string][]) expect(() => translateAlias("generate", argv)).toThrow(message);
  for (const name of Object.keys(ALIASES)) {
    for (const flag of ["--help", "-h"]) {
      const help = translateAlias(name, [flag]);
      expect("help" in help && help.help).toContain(`mlx-bun.${name} — mlx_lm.${name}-compatible alias of`);
    }
  }
});

test("mlx-bun.generate: mlx_lm.generate's flags resolve to the one-shot generate's options", () => {
  const { command, parsed } = translate("generate", "--model", "/m", "--prompt", "a\\nb\\tc", "--max-tokens", "8", "--temp", "0.6", "--top-p", "0.9",
    "--top-k", "5", "--min-p", "0.1", "--xtc-probability", "0.5", "--xtc-threshold", "0.1", "--min-tokens-to-keep", "2", "--seed", "3",
    "--system-prompt", "be brief", "--adapter-path", "/a", "--ignore-chat-template", "--trust-remote-code", "--verbose", "False", "--kv-bits", "4");
  expect(command).toBe("generate");
  expect(parsed.values).toEqual({ query: "/m", prompt: "a\nb\tc", "max-tokens": "8", temp: "0.6", "top-p": "0.9", "top-k": "5", "min-p": "0.1",
    "xtc-probability": "0.5", "xtc-threshold": "0.1", "min-tokens-to-keep": "2", seed: "3", "system-prompt": "be brief", "adapter-path": "/a",
    raw: true, "kv-quant": "4", "quantized-kv-start": "5000" });
  expect(generateOptions(parsed)).toEqual({ prompt: "a\nb\tc", raw: true, kvQuant: 4, fusedSdpa: false, system: "be brief", adapter: "/a", quantizedKvStart: 5000,
    options: { maxTokens: 8, temperature: 0.6, topP: 0.9, topK: 5, minP: 0.1, minTokensToKeep: 2, xtcProbability: 0.5, xtcThreshold: 0.1, seed: 3 } });

  // --kv-bits starts at mlx_lm's token 5000 unless --quantized-kv-start says otherwise, before or after it.
  expect(values("generate", "--kv-bits", "8", "--quantized-kv-start", "0")).toMatchObject({ "kv-quant": "8", "quantized-kv-start": "0" });
  expect(values("generate", "--quantized-kv-start", "10", "--kv-bits", "4")).toMatchObject({ "kv-quant": "4", "quantized-kv-start": "10" });
  expect(values("generate", "--kv-quant", "8")).not.toHaveProperty("quantized-kv-start");
  expect(() => translateAlias("generate", ["--kv-bits", "3"])).toThrow("mlx-bun.generate: --kv-bits 3: mlx-bun's affine KV cache supports 4 or 8 bits");
  expect(() => translateAlias("generate", ["--kv-bits", "4", "--kv-group-size", "32"])).toThrow("--kv-group-size 32: mlx-bun's affine KV cache uses group size 64");
  expect(values("generate", "--kv-bits", "4", "--kv-group-size", "64")).not.toHaveProperty("kv-group-size");

  // The verb's own options remain accepted (an alias is a superset).
  expect(values("generate", "/m", "hi", "--kv-quant", "turbo", "--l2")).toMatchObject({ "kv-quant": "turbo", l2: true });
  for (const [flag, ...rest] of [["--extra-eos-token", "a", "b"], ["--prefill-response", "x"], ["--use-default-chat-template"], ["--chat-template-config", "{}"],
    ["--max-kv-size", "512"], ["--prompt-cache-file", "c.safetensors"], ["--quantize-activations"], ["-qa"], ["--draft-model", "d"], ["--num-draft-tokens", "3"]] as string[][])
    expect(() => translateAlias("generate", [flag!, ...rest])).toThrow(/^mlx-bun\.generate: --[a-z-]+ is an mlx_lm\.generate option mlx-bun does not support: /);
});

test("mlx-bun.server: mlx_lm.server's flags resolve to serve's options, headless like mlx_lm", () => {
  const { command, parsed } = translate("server", "--model", "m", "--adapter-path", "/a", "--host", "0.0.0.0", "--port", "9000", "--decode-concurrency", "4",
    "--max-tokens", "64", "--temp", "0.5", "--top-p", "0.9", "--top-k", "5", "--draft-model", "d", "--num-draft-tokens", "2", "--trust-remote-code");
  expect(command).toBe("serve");
  expect(parsed.values).toMatchObject({ model: "m", "adapter-path": "/a", host: "0.0.0.0", port: "9000", "no-open": true });
  expect(parseServeOptions(parsed)).toMatchObject({ query: "m", hostname: "0.0.0.0", port: 9000, capacity: 4, defaultGeneratedTokens: 64, noOpen: true,
    adapterDir: "/a", request: { defaultTemperature: 0.5, defaultTopP: 0.9, defaultTopK: 5 }, draft: { model: "d", numTokens: 2 } });
  // serve's own options still apply, and --no-open is the alias's default only.
  expect(values("server", "--isolate", "--batch", "2")).toMatchObject({ isolate: true, batch: "2", "no-open": true });
  for (const [flag, ...rest] of [["--allowed-origins", "*"], ["--log-level", "INFO"], ["--chat-template", "t"], ["--use-default-chat-template"], ["--chat-template-args", "{}"],
    ["--min-p", "0.1"], ["--prompt-concurrency", "8"], ["--prefill-step-size", "2048"], ["--prompt-cache-size", "10"], ["--prompt-cache-bytes", "1G"], ["--pipeline"]] as string[][])
    expect(() => translateAlias("server", [flag!, ...rest])).toThrow(/^mlx-bun\.server: --[a-z-]+ is an mlx_lm\.server option mlx-bun does not support: /);
});

function convertHarness() {
  const configs: Record<string, unknown>[] = [], published: unknown[] = [];
  const deps: ConvertDependencies = {
    async quantize(config, outDir) { configs.push(config); return { outputPath: outDir }; },
    catalog: { find: async () => { throw new Error("no model"); }, download: async () => { throw new Error("no download"); }, canPublish: () => true,
      async publish(directory, request) { published.push({ ...request, directory }); return { url: "https://huggingface.co/org/r" }; } },
    modelsDir: () => "/store/models",
    terminal: { ...plainTerminal(() => {}), step: () => ({ update() {}, done() {}, fail() {} }), box() {} }, log() {},
  };
  return { deps, configs, published };
}

test("mlx-bun.convert: mlx_lm.convert's flags, quantized, cast, or dequantized", async () => {
  const dir = temporary("mlx-alias-convert-"), local = join(dir, "src"), out = join(dir, "out");
  mkdirSync(local); writeFileSync(join(local, "config.json"), "{}");
  const quantized = translate("convert", "--hf-path", local, "--mlx-path", out, "-q", "--q-bits", "8", "--q-group-size", "32", "--dtype", "float16",
    "--upload-repo", "org/r", "--trust-remote-code");
  expect(quantized.command).toBe("convert");
  expect(quantized.parsed.values).toEqual({ "hf-path": local, "mlx-path": out, quantize: true, "q-bits": "8", "q-group-size": "32", dtype: "float16", "upload-repo": "org/r" });
  const run = convertHarness();
  await runConvert(quantized.parsed, run.deps);
  expect(run.configs).toEqual([{ src_dir: local, out_dir: out, bits: 8, group_size: 32, mode: "affine", dtype: "float16" }]);
  expect(run.published).toEqual([{ repoId: "org/r", directory: out }]);

  const dense = convertHarness();
  await runConvert(translate("convert", "--model", local, "-d", "--mlx-path", out).parsed, dense.deps);
  expect(dense.configs).toEqual([{ src_dir: local, out_dir: out, quantize: false, dequantize: true }]);
  // Without an explicit --mlx-path the output lands under the storage root, not `mlx_model` in the working directory.
  const cast = convertHarness();
  await runConvert(translate("convert", "--hf-path", local, "--dtype", "bfloat16").parsed, cast.deps);
  expect(cast.configs[0]!.out_dir).toBe("/store/models/src-bfloat16");

  for (const [argv, message] of [
    [["--hf-path", local, "-q", "--q-mode", "mxfp4"], '--q-mode mxfp4: only "affine" and "trellis" are supported'],
    [["--hf-path", local, "-q", "--quant-predicate", "mixed_4_6"], "--quant-predicate: not supported"],
    [["--hf-path", local, "-q", "-d"], "Choose either quantize or dequantize, not both."],
    [["--hf-path", local, "-q", "--dtype", "int8"], '--dtype must be float16, bfloat16, float32 (got "int8")'],
    [["--hf-path", local, "-q", "--q-bits", "6"], '--q-bits must be 4 or 8 (got "6")'],
    [["--hf-path", local, "-q", "--mlx-path", dir], "already exists"],
  ] as [string[], string][])
    await expect(runConvert(translate("convert", ...argv).parsed, convertHarness().deps)).rejects.toThrow(message);
});

test("mlx-bun.convert reaches the module's verb through the host's verb table with the alias's translated options", async () => {
  const { parsed } = translate("convert", "--hf-path", "/nonexistent/model", "-q", "-d", "--trust-remote-code");
  // The module rejects the combination before any job or download, so this needs no model and starts no child.
  await expect(runInstalledVerb("convert", { values: parsed.values, positionals: parsed.positionals })).rejects.toThrow("Choose either quantize or dequantize, not both.");
  const { parsed: numeric } = translate("convert", "--hf-path", "/nonexistent/model", "-q", "--q-bits", "6");
  await expect(runInstalledVerb("convert", { values: numeric.values, positionals: numeric.positionals })).rejects.toThrow('--q-bits must be 4 or 8 (got "6")');
  await expect(runInstalledVerb("convert", { values: {}, positionals: ["a", "b"] })).rejects.toThrow("Too many arguments for convert");
});

function fuseHarness(token: string | null = "hf_token") {
  const calls: unknown[][] = [], published: unknown[] = [];
  const deps: FuseDependencies = {
    modelsDir: () => "/store/models", exists: path => !path.startsWith("/store/"), log() {},
    terminal: { ...plainTerminal(() => {}), step: () => ({ update() {}, done() {}, fail() {} }), box() {} },
    catalog: { find: async () => { throw new Error("no model"); }, canPublish: () => token !== null,
      publish: async (directory, request) => { published.push({ ...request, sourcePath: directory }); return { url: "https://huggingface.co/org/r" }; } },
    fuse: async (...call) => { calls.push(call.slice(0, 3), [call[4]]); return { outDir: call[2], fusedModules: 1, skippedAdapterTensors: 0, totalTensors: 2 }; },
  };
  return { deps, calls, published };
}

test("mlx-bun.fuse: mlx_lm.fuse's flags, including --dequantize and --upload-repo", async () => {
  const { command, parsed } = translate("fuse", "--model", "m", "--adapter-path", "/ad", "--save-path", "/out", "--dequantize", "--upload-repo", "org/r");
  expect(command).toBe("fuse");
  expect(parsed.values).toEqual({ model: "m", "adapter-path": "/ad", "save-path": "/out", dequantize: true, "upload-repo": "org/r" });
  const run = fuseHarness();
  await runFuse(parsed, run.deps);
  expect(run.calls).toEqual([["m", "/ad", "/out"], [{ dequantize: true }]]);
  expect(run.published).toEqual([{ repoId: "org/r", sourcePath: "/out" }]);
  // The default output is the storage root's, not `fused_model` in the working directory.
  const plain = fuseHarness();
  await runFuse(translate("fuse", "--model", "m", "--adapter-path", "/ad").parsed, plain.deps);
  expect(plain.calls[0]).toEqual(["m", "/ad", "/store/models/m-fused"]);
  for (const flags of [["--export-gguf"], ["--gguf-path", "x.gguf"]])
    await expect(runFuse(translate("fuse", "--model", "m", ...flags).parsed, fuseHarness().deps)).rejects.toThrow("not supported (GGUF export is not implemented");
});

test("mlx-bun.upload: mlx_lm.upload's --path and --upload-repo", async () => {
  const { command, parsed } = translate("upload", "--path", "/models/fused", "--upload-repo", "org/repo");
  expect(command).toBe("upload");
  expect(parsed.values).toEqual({ path: "/models/fused", "upload-repo": "org/repo" });
  const calls: unknown[][] = [];
  const deps: UploadDependencies = { credentials: { get: () => "hf_token" }, isDirectory: () => true, box() {}, log() {},
    step: () => ({ update() {}, done() {}, fail() {} }),
    upload: async (dir, repo) => { calls.push([dir, repo]); return { ok: true, url: `https://huggingface.co/${repo}`, commitOid: "abc" }; } };
  await runUpload(parsed, deps);
  expect(calls).toEqual([["/models/fused", "org/repo"]]);
});

test("mlx-bun.lora: mlx_lm.lora's flags resolve to an SFT train run over the same data", () => {
  const { command, parsed } = translate("lora", "--model", "/m", "--train", "--data", "/d", "--fine-tune-type", "lora", "--optimizer", "adam", "--mask-prompt",
    "--num-layers", "8", "--batch-size", "2", "--iters", "50", "--val-batches", "10", "--learning-rate", "1e-4", "--steps-per-report", "5",
    "--steps-per-eval", "20", "--grad-accumulation-steps", "4", "--resume-adapter-file", "/prev/adapters.safetensors", "--adapter-path", "/out",
    "--save-every", "10", "--max-seq-length", "512", "--grad-checkpoint", "--seed", "9");
  expect(command).toBe("train");
  expect(parsed.values).toEqual({ query: "/m", data: "/d", "num-layers": "8", batch: "2", iters: "50", "val-size": "20", lr: "1e-4", "steps-per-report": "5",
    "steps-per-eval": "20", "grad-accum": "4", resume: "/prev", adapter: "/out", "save-every": "10", seq: "512", "grad-checkpoint": true, seed: "9",
    method: "sft", "weight-decay": "0" });
  const plan = trainPlan(parseTrainArgs(parsed, () => true), { path: "/m", repoId: "m" }, { maxSeqLength: 4096 }, () => "/store/adapters");
  expect(plan.method).toBe("sft");
  expect(plan.cfg).toMatchObject({ model_dir: "/m", data_dir: "/d", adapter_path: "/out", method: "sft", num_layers: 8, batch_size: 2, iters: 50,
    val_max_examples: 20, learning_rate: 1e-4, steps_per_report: 5, steps_per_eval: 20, grad_accumulation_steps: 4, warm_start_adapter: "/prev",
    save_checkpoints: true, max_seq_length: 512, grad_checkpoint: true, seed: 9, weight_decay: 0 });
  // Output stays under the storage root unless --adapter-path names one.
  expect(trainPlan(parseTrainArgs(translate("lora", "--model", "/m", "--train", "--data", "/d").parsed, () => true), { path: "/m", repoId: "org/m" }, { maxSeqLength: 4096 }, () => "/store/adapters").adapter)
    .toBe("/store/adapters/sft-m");
  // adamw keeps mlx-bun's weight decay; the verb's own --method stays available.
  expect(values("lora", "--train", "--optimizer", "adamw")).not.toHaveProperty("weight-decay");
  expect(values("lora", "--train", "--method", "orpo").method).toBe("orpo");
  expect(values("lora", "--train", "--resume-adapter-file", "adapters.safetensors").resume).toBe(".");
  expect(values("lora", "--train", "--resume-adapter-file", "/prev/dir").resume).toBe("/prev/dir");
  for (const [argv, message] of [
    [["--data", "/d"], "mlx-bun.lora: Must provide --train"],
    [["--train", "--test"], "--test is an mlx_lm.lora option mlx-bun does not support"],
    [["--train", "--test-batches", "5"], "--test-batches is an mlx_lm.lora option mlx-bun does not support"],
    [["--train", "--fine-tune-type", "dora"], "--fine-tune-type dora: dora is not supported by mlx-bun's LoRA trainer; only lora"],
    [["--train", "--fine-tune-type", "full"], "--fine-tune-type full: full is not supported by mlx-bun's LoRA trainer; only lora"],
    [["--train", "--optimizer", "sgd"], "--optimizer sgd: only adam and adamw are supported"],
    [["--train", "--report-to", "wandb"], "--report-to is an mlx_lm.lora option mlx-bun does not support"],
    [["--train", "--project-name", "p"], "--project-name is an mlx_lm.lora option mlx-bun does not support"],
    [["--train", "--clear-cache-threshold", "1G"], "--clear-cache-threshold is an mlx_lm.lora option mlx-bun does not support"],
  ] as [string[], string][]) expect(() => translateAlias("lora", argv)).toThrow(message);
});

test("mlx-bun.lora -c reads mlx_lm's YAML config keys; flags on the command line win", () => {
  const config = { model: "/cfg-model", train: true, fine_tune_type: "lora", data: "/cfg-data", num_layers: 4, batch_size: 3, iters: 7, learning_rate: 1e-5,
    lora_parameters: { rank: 4, scale: 20.0, dropout: 0.1 }, optimizer: "adamw", optimizer_config: { adamw: { weight_decay: 0.05 } }, adapter_path: "/cfg-out",
    grad_checkpoint: true, resume_adapter_file: null, test: false, mask_prompt: true, lr_schedule: null };
  const result = translateAlias("lora", ["-c", "cfg.yaml", "--iters", "9", "--batch-size", "5"], path => { expect(path).toBe("cfg.yaml"); return config; });
  if (!("parsed" in result)) throw new Error("expected a translation");
  expect(result.parsed.values).toEqual({ query: "/cfg-model", data: "/cfg-data", "num-layers": "4", batch: "5", iters: "9", lr: "0.00001", rank: "4", scale: "20",
    dropout: "0.1", "weight-decay": "0.05", adapter: "/cfg-out", "grad-checkpoint": true, method: "sft" });
  for (const [entry, message] of [
    [{ train: true, lr_schedule: { name: "cosine_decay" } }, "lr_schedule is not supported"],
    [{ train: true, lora_parameters: { keys: ["self_attn.q_proj"] } }, "lora_parameters.keys is not supported"],
    [{ train: true, optimizer_config: { adam: { betas: [0.9, 0.99] } } }, "optimizer_config.betas is not supported"],
    [{ train: true, fine_tune_type: "dora" }, "dora is not supported"],
    [{ train: true, nonsense_key: 1 }, "unrecognized key nonsense_key"],
    [{ model: "/m" }, "Must provide --train"],
  ] as [Record<string, unknown>, string][]) expect(() => translateAlias("lora", ["-c", "c.yaml"], () => entry)).toThrow(message);
  expect(() => translateAlias("lora", ["-c", "c.yaml"], () => [1])).toThrow("must be a YAML mapping");
  expect(() => translateAlias("lora", ["-c", "c.yaml"], () => { throw new Error("ENOENT"); })).toThrow("cannot read config c.yaml: ENOENT");

  // The real reader parses mlx_lm's example-style YAML (comments, scientific floats).
  const path = join(temporary("mlx-alias-yaml-"), "lora.yaml");
  writeFileSync(path, "# mlx_lm.lora config\nmodel: \"/cfg-model\"\ntrain: true\nfine_tune_type: lora\noptimizer: adam\noptimizer_config:\n  adam: {}\ndata: /cfg-data\nseed: 0\nnum_layers: 16\nbatch_size: 4\niters: 1000\nlearning_rate: 1e-5\nlora_parameters:\n  keys: null\n  rank: 8\n  dropout: 0.0\n  scale: 20.0\n");
  expect(values("lora", "-c", path)).toMatchObject({ query: "/cfg-model", data: "/cfg-data", "num-layers": "16", batch: "4", iters: "1000", lr: "0.00001", seed: "0",
    rank: "8", dropout: "0", scale: "20", method: "sft", "weight-decay": "0" });
});

// ------------------------------------------------------------ the launcher files

async function spawn(command: string[], home: string, cwd: string = home) {
  const proc = Bun.spawn(command, { cwd, stdout: "pipe", stderr: "pipe",
    env: { ...process.env, HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"), HF_HUB_CACHE: join(home, "absent"), HF_HUB_OFFLINE: "1", HF_TOKEN: "",
      NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" } });
  const deadline = setTimeout(() => proc.kill("SIGKILL"), 20_000);
  try {
    const [out, err, code] = await Promise.all([new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited]);
    return { out, err, code };
  } finally { clearTimeout(deadline); }
}
const launcher = (name: string) => join(app, "bin", `${name}.mjs`);
const preference = (i: number) => JSON.stringify({ prompt: `p${i}`, chosen: "c", rejected: "r" }) + "\n";

test("each launcher, run directly or through a symlink named like the alias, is that alias; mlx-bun itself is not", async () => {
  const home = temporary("mlx-alias-launch-"), links = join(home, "bin");
  mkdirSync(links);
  for (const [name, alias] of Object.entries(ALIASES)) {
    const command = `mlx-bun.${name}`;
    symlinkSync(launcher(command), join(links, command));
    for (const argv of [[process.execPath, "--no-env-file", launcher(command), "--help"], [join(links, command), "--help"]]) {
      const shown = await spawn(argv, home);
      expect({ code: shown.code, err: shown.err }).toEqual({ code: 0, err: "" });
      expect(shown.out.split("\n")[0]).toBe(`mlx-bun.${name} — mlx_lm.${name}-compatible alias of \`mlx-bun ${alias.verb}\``);
      expect(shown.out).toContain(`Options of \`mlx-bun ${alias.verb}\`:`);
    }
  }
  const plain = await spawn([process.execPath, "--no-env-file", launcher("mlx-bun"), "--help"], home);
  expect(plain.code).toBe(0); expect(plain.out).toContain("Usage: mlx-bun [options]"); expect(plain.out).not.toContain("compatible alias");
  // A launcher for a name that is not an alias (or a gap) fails with the reason, not as plain mlx-bun.
  const stray = join(links, "mlx-bun.chat.mjs");
  writeFileSync(stray, `#!/usr/bin/env bun\nawait import(${JSON.stringify(launcher("mlx-bun"))});\n`);
  const chat = await spawn([process.execPath, "--no-env-file", stray, "--help"], home);
  expect(chat.code).toBe(1); expect(chat.err).toContain("mlx-bun.chat: mlx_lm.chat has no mlx-bun counterpart");
});

test("spawned aliases resolve mlx_lm's argument forms to the verbs and fail with mlx_lm-named refusals", async () => {
  const home = temporary("mlx-alias-spawn-"), cwd = join(home, "cwd"), snapshot = join(home, "snap"), data = join(home, "data"), adapter = join(home, "adapter");
  for (const dir of [cwd, snapshot, data, adapter]) mkdirSync(dir);
  writeFileSync(join(snapshot, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 8, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2,
    intermediate_size: 16, vocab_size: 32, max_position_embeddings: 64 }));
  writeFileSync(join(snapshot, "model.safetensors"), new Uint8Array(4096));
  writeFileSync(join(data, "train.jsonl"), [0, 1].map(preference).join(""));
  const run = (name: string, ...argv: string[]) => spawn([process.execPath, "--no-env-file", launcher(`mlx-bun.${name}`), ...argv], home, cwd);

  // lora: the SFT plan the alias resolved (a dry run: no model is loaded and nothing is trained).
  const dry = await run("lora", "--model", snapshot, "--train", "--data", data, "--dry-run", "--adapter-path", join(home, "out"), "--iters", "5",
    "--batch-size", "2", "--learning-rate", "3e-5", "--num-layers", "4", "--fine-tune-type", "lora");
  expect({ code: dry.code, err: dry.err }).toEqual({ code: 0, err: "" });
  for (const line of ["● train sft · snap", "iters 5 · lr 0.00003 · rank 8 · scale 1 · seq 4096 · batch 2", `adapter    ${join(home, "out")}`, "dry run — not training."])
    expect(dry.out).toContain(line);
  const noTrain = await run("lora", "--model", snapshot, "--data", data);
  expect(noTrain.code).toBe(1); expect(noTrain.err).toContain("mlx-bun.lora: Must provide --train");

  // fuse: mlx_lm's --adapter-path names the adapter; GGUF export is refused naming the flag.
  const noAdapter = await run("fuse", "--model", snapshot, "--adapter-path", join(home, "nope"));
  expect(noAdapter.code).toBe(1); expect(noAdapter.err).toContain(`adapter dir not found: ${join(home, "nope")}`);
  const gguf = await run("fuse", "--model", snapshot, "--adapter-path", adapter, "--export-gguf");
  expect(gguf.code).toBe(1); expect(gguf.err).toContain("--export-gguf: not supported (GGUF export is not implemented");
  const fusedTo = join(home, "fused-out");
  const blocked = await run("fuse", "--model", snapshot, "--adapter-path", adapter, "--save-path", fusedTo, "--dequantize");
  expect(blocked.code).toBe(1); expect(existsSync(fusedTo)).toBe(false); // policy passed; the merge itself needs native MLX

  // convert: mlx_lm's spellings reach convert's checks (nothing is written).
  const taken = join(home, "taken"); mkdirSync(taken);
  const exists = await run("convert", "--hf-path", snapshot, "-q", "--mlx-path", taken);
  expect(exists.code).toBe(1); expect(exists.err).toContain("already exists");
  const both = await run("convert", "--hf-path", snapshot, "-q", "-d");
  expect(both.code).toBe(1); expect(both.err).toContain("Choose either quantize or dequantize, not both.");
  const mode = await run("convert", "--hf-path", snapshot, "-q", "--q-mode", "mxfp4");
  expect(mode.code).toBe(1); expect(mode.err).toContain('--q-mode mxfp4: only "affine" and "trellis" are supported');
  const token = await run("convert", "--hf-path", snapshot, "--dtype", "float16", "--upload-repo", "org/r");
  expect(token.code).toBe(1); expect(token.err).toContain("--upload-repo needs a Hugging Face WRITE token");

  // upload: --path and --upload-repo reach the token check before any network.
  const upload = await run("upload", "--path", snapshot, "--upload-repo", "org/r");
  expect(upload.code).toBe(1); expect(upload.err).toContain("no Hugging Face token found");

  // generate / server: unsupported flags name the mlx_lm option; a missing model is the verb's error.
  const kv = await run("generate", "--model", snapshot, "--prompt", "hi", "--max-kv-size", "64");
  expect(kv.code).toBe(1); expect(kv.err).toContain("mlx-bun.generate: --max-kv-size is an mlx_lm.generate option mlx-bun does not support");
  const missing = await run("generate", "--model", "/nonexistent/model", "--prompt", "hi", "--max-tokens", "8");
  expect(missing.code).toBe(1); expect(missing.err).toContain("no model matching");
  const origins = await run("server", "--model", snapshot, "--allowed-origins", "*");
  expect(origins.code).toBe(1); expect(origins.err).toContain("mlx-bun.server: --allowed-origins is an mlx_lm.server option mlx-bun does not support");
  const unknown = await run("server", "--nonsense");
  expect(unknown.code).toBe(1); expect(unknown.err).toContain("mlx-bun.server: unrecognized argument: --nonsense");

  // Nothing landed in the working directory (mlx_lm would have used ./mlx_model, ./fused_model, ./adapters).
  expect(existsSync(join(cwd, "mlx_model")) || existsSync(join(cwd, "fused_model")) || existsSync(join(cwd, "adapters"))).toBe(false);
});
