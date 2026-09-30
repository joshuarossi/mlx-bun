/** Reference producer for the Qwen3.8-27B packed-Trellis parity test: runs the
 * pre-refactor main checkout's own purpose-built graph and native shared MTP path
 * and records what they compute in a JSON file outside this repository.
 *
 *   cd <main checkout at 02d723a>
 *   MLX_BUN_LIBMLXC=<libmlxc.dylib> bun --no-env-file <this file> \
 *     --target <qwen38 packed-Trellis snapshot> --draft <folded MTP snapshot> --out main-qwen-trellis.json
 *
 * Main's sources are imported by path; nothing is written to or changed in the
 * main checkout. It records, for the prompts below rendered with the artifact's
 * chat template (thinking off):
 *  - greedy trajectories: the prompt once, then each selected token on the same
 *    live cache through `model.forward`, with the SHA-256 of every step's full
 *    last-position float32 logits;
 *  - native MTP speculation (shared batch-one gateway, depth 2, greedy, stop tokens off):
 *    the emitted tokens, every target forward's input ids (the verify rows
 *    [pending, ...proposals], accepted and rejected proposals alike) and the
 *    speculation counters.
 * The artifacts are pinned by the content of their metadata files and shards.
 * The test compares a checkout of this tree against the produced file, which is
 * pinned by its SHA-256 and never committed. */
import { createHash } from "node:crypto";
import { createReadStream, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";

const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
type Loose = any; // main's modules are imported by path at run time, so they have no static types here
const load = (main: string, path: string): Promise<Loose> => import(join(main, "src", path));
async function fileSha(path: string): Promise<string> {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}

const PROMPTS = [
  "List the planets of the solar system in order from the Sun.",
  "Write a bash one-liner that counts lines in all .ts files, then explain it briefly.",
  "Explain in two sentences why the sky is blue.",
];
const TRAJECTORY_STEPS = 32;
const MTP_TOKENS = 64;
const MTP_DEPTH = 2;
const METADATA = ["config.json", "model.safetensors.index.json", "tokenizer.json", "tokenizer_config.json", "chat_template.jinja"];

/** Pin an artifact by content: its metadata files and exactly the shards its
 * index names (or its one model.safetensors). */
async function pin(dir: string) {
  const files: Record<string, string> = {};
  for (const name of readdirSync(dir).sort())
    if (METADATA.includes(name) || name === "draft_vocab.json") files[name] = await fileSha(join(dir, name));
  let names = ["model.safetensors"];
  try {
    const index = JSON.parse(readFileSync(join(dir, "model.safetensors.index.json"), "utf8")) as { weight_map: Record<string, string> };
    names = [...new Set(Object.values(index.weight_map))].sort();
  } catch { /* single-file artifact */ }
  const weights: Record<string, string> = {};
  for (const name of names) weights[name] = await fileSha(join(dir, name));
  return { files, weights };
}

async function produce(main: string, targetDir: string, draftDir: string) {
  const [{ loadModelConfig }, { createModel }, { Weights }, { loadTokenizer }, { ChatTemplate }, gemma, ops, ffi, { QwenMtpProvider }, { bindMlxGateway }] =
    await Promise.all([
      load(main, "config.ts"), load(main, "model/factory.ts"), load(main, "weights.ts"), load(main, "tokenizer.ts"),
      load(main, "chat-template.ts"), load(main, "model/gemma4-base.ts"), load(main, "mlx/ops.ts"), load(main, "mlx/ffi.ts"),
      load(main, "spec/qwen-mtp-source.ts"), load(main, "backends/mlx/gateway-binding.ts"),
    ]);
  const config = await loadModelConfig(targetDir);
  const tokenizer = await loadTokenizer(targetDir), template = await ChatTemplate.load(targetDir);
  const prompts = PROMPTS.map(text => {
    const ids: number[] = tokenizer.encode(template.render([{ role: "user", content: text }], { enableThinking: false }));
    return { text, ids: ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids };
  });
  const weights = await Weights.open(targetDir);
  const model = createModel(weights, config);
  const graph = (model as Loose).constructor.name as string;

  const trajectories: unknown[] = [];
  for (const prompt of prompts) {
    const cache = model.makeCache();
    const greedy: number[] = [], logits: string[] = [];
    let finite = true, tokens = prompt.ids;
    try {
      for (let step = 0; step < TRAJECTORY_STEPS; step++) {
        const out = model.forward(tokens, cache);
        const last: Float32Array = gemma.lastPositionLogits(out);
        finite &&= last.every(Number.isFinite);
        logits.push(sha(new Uint8Array(last.buffer, last.byteOffset, last.byteLength)));
        const next: number = gemma.argmaxLastPosition(out);
        out.dispose();
        greedy.push(next);
        tokens = [next];
      }
    } finally { for (const c of cache) c.dispose(); ffi.clearCache(); }
    trajectories.push({ prompt: prompt.text, promptIds: prompt.ids, greedy, logitsSha256: logits, finite, vocab: config.text.vocabSize });
    console.log(`trajectory ${JSON.stringify(prompt.text.slice(0, 40))}: ${greedy.length} steps`);
  }

  // Native MTP: record every target forward's input ids, verify rows included.
  const provider = await QwenMtpProvider.load(draftDir);
  const forwardHidden = model.forwardHidden.bind(model);
  let forwards: number[][] = [];
  (model as Loose).forwardHidden = (ids: Loose, caches: Loose, ...rest: Loose[]) => {
    forwards.push(ids.toIntTokens());
    return forwardHidden(ids, caches, ...rest);
  };
  const binding = bindMlxGateway(model, { provider, numDraftTokens: MTP_DEPTH });
  const runs: unknown[] = [];
  try {
    for (const prompt of prompts) {
      forwards = [];
      const emitted: number[] = [];
      const options = { maxTokens: MTP_TOKENS, temperature: 0 };
      const plan = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
        kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true }, options,
      { continuous: true, quantizedBatch: false, checkpoints: false });
      if (plan.method !== "speculative") throw new Error("main did not bind shared speculation");
      const method = binding.methodRequest(plan, options);
      if (!method) throw new Error("main's shared MTP method is unavailable");
      const group = binding.createBatchGroup({ maxBatch: 1 });
      let stats: Loose;
      try {
        stats = await group.submit({ method, promptIds: prompt.ids, maxTokens: MTP_TOKENS, eosTokenIds: [],
          onToken(token: number) { emitted.push(token); } });
      } finally { await group.close(); }
      const spec = stats.spec as Record<string, unknown>;
      runs.push({ prompt: prompt.text, tokens: emitted, forwards, spec: Object.fromEntries(
        ["drafted", "accepted", "rejected", "targetCalls", "rounds", "acceptanceLengths", "draftedByPos", "acceptedByPos"].map(k => [k, spec[k]])) });
      console.log(`mtp ${JSON.stringify(prompt.text.slice(0, 40))}: ${emitted.length} tokens, ${String(spec.accepted)}/${String(spec.drafted)} accepted`);
    }
  } finally {
    (model as Loose).forwardHidden = forwardHidden;
    provider.dispose();
    weights.dispose();
    ffi.clearCache();
  }
  return { graph, runtime: { mlx: ffi.MLX_VERSION, architecture: ffi.deviceArchitecture() }, prompts, trajectories, mtp: { execution: "shared-b1", depth: MTP_DEPTH, maxTokens: MTP_TOKENS, runs } };
}

const { values } = parseArgs({ options: { main: { type: "string" }, target: { type: "string" }, draft: { type: "string" }, out: { type: "string" } } });
for (const name of ["target", "draft", "out"] as const) if (!values[name]) throw new Error(`--${name} is required (see the file header)`);
const main = resolve(values.main ?? process.cwd());
const [target, draft, out] = [resolve(values.target!), resolve(values.draft!), resolve(values.out!)];
const artifacts = { target: await pin(target), draft: await pin(draft) };
const reference = await produce(main, target, draft);
writeFileSync(out, JSON.stringify({ producer: "main-qwen-trellis-reference", schema: 1,
  mainRevision: Bun.spawnSync(["git", "-C", main, "rev-parse", "HEAD"]).stdout.toString().trim(), artifacts, ...reference }, null, 1) + "\n");
console.log(`wrote ${out}`);
