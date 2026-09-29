// Generation stage of the drafter pipeline (paper §5.1): the frozen target
// answers a prompt corpus with its OWN greedy generations, and one tapped
// forward over each full sequence records the m tapped layers' hiddens, so the
// drafter later attends the whole prefix context (Eq 2) and the last tapped
// layer (post-final-norm) supplies p^t through the target's own head.
//
// Composed only through the graph's public ports: `generate` for the answers
// and the speculative target binding's tapped forward for the hiddens, so any
// graph that declares `hiddenLayerTaps` can be a drafter target.

import * as ops from "@mlx-bun/mlx/ops";
import type { RuntimeModel } from "@mlx-bun/inference/models";
import type { ChatTemplate, LoadedTokenizer } from "@mlx-bun/inference/input";
import { generate } from "@mlx-bun/inference/generation";
import { bindSpeculativeTargetModel } from "@mlx-bun/inference/generation/speculative/binding";
import { existsSync, mkdirSync, readFileSync, readdirSync, appendFileSync } from "node:fs";
import { join } from "node:path";
import { writeDflashShard, type DflashRecord } from "./data";

export interface RegenOptions {
  outDir: string;
  /** Target layers to tap, in the order the drafter concatenates them; the last
   *  is normally `numHiddenLayers` (the post-final-norm hidden). MUST equal the
   *  drafter's `tapLayers` (the shard feature width is `tapLayers.length * H`). */
  tapLayers: readonly number[];
  /** Cap on generated tokens per topic. Default 320. */
  maxResponseTokens?: number;
  /** Sequences per shard file. Default 32. */
  sequencesPerShard?: number;
  /** Responses shorter than this are dropped (a block needs γ tokens). Default 6. */
  minResponseTokens?: number;
  /** Prompt for one topic. Default: an encyclopedia article request. */
  prompt?: (topic: string) => string;
  onProgress?: (event: RegenProgress) => void;
  signal?: AbortSignal;
}

export type RegenProgress =
  | { type: "start"; tapLayers: readonly number[]; hiddenSize: number; layers: number; resumed: number; nextShard: number }
  | { type: "shard"; index: number; sequences: number; tokens: number }
  | { type: "topics"; done: number; total: number; kept: number; tokens: number };

export interface RegenResult { kept: number; tokens: number; shards: number; skippedShort: number }

const articlePrompt = (topic: string) =>
  `Write a detailed, thorough encyclopedia article about ${topic}. Be specific and informative.`;

/** Regenerate `topics` into shards under `opts.outDir`. Resumable: topics already
 *  recorded in `progress.txt` are skipped and shard numbering continues. */
export async function regenDrafterData(
  model: RuntimeModel, tokenizer: LoadedTokenizer, template: ChatTemplate, topics: readonly string[], opts: RegenOptions,
): Promise<RegenResult> {
  const { outDir, tapLayers } = opts;
  const maxResponse = opts.maxResponseTokens ?? 320, perShard = opts.sequencesPerShard ?? 32, minResponse = opts.minResponseTokens ?? 6;
  const promptFor = opts.prompt ?? articlePrompt;
  const target = bindSpeculativeTargetModel(model);
  const hiddenSize = model.config.text.hiddenSize, layers = model.config.text.numHiddenLayers;
  if (!tapLayers.length) throw new Error("regen: tapLayers is empty");
  if (!target.supportsTapLayers(tapLayers))
    throw new Error(`regen: target cannot tap layers [${tapLayers}] (needs a graph declaring hiddenLayerTaps and layers in [0, ${layers}])`);
  const eos = [...model.config.eosTokenIds];
  mkdirSync(outDir, { recursive: true });

  const progressFile = join(outDir, "progress.txt");
  const done = new Set(existsSync(progressFile) ? readFileSync(progressFile, "utf8").split("\n").filter(Boolean) : []);
  let shard = readdirSync(outDir).filter(name => name.startsWith("shard_")).length;
  opts.onProgress?.({ type: "start", tapLayers, hiddenSize, layers, resumed: done.size, nextShard: shard });

  let records: DflashRecord[] = [], pending: string[] = [];
  let kept = done.size, tokens = 0, skippedShort = 0, shards = 0;
  const flush = () => {
    if (!records.length) return;
    const meta = writeDflashShard(outDir, shard, records, hiddenSize, tapLayers.length, [...tapLayers]);
    opts.onProgress?.({ type: "shard", index: shard, sequences: meta.nSeq, tokens: meta.nTokens });
    shard++; shards++;
    appendFileSync(progressFile, pending.map(topic => topic + "\n").join(""));
    records = []; pending = [];
  };

  for (let i = 0; i < topics.length; i++) {
    opts.signal?.throwIfAborted();
    const topic = topics[i]!;
    if (done.has(topic)) continue;
    const text = template.render([{ role: "user", content: promptFor(topic) }], { addGenerationPrompt: true });
    let promptIds = tokenizer.encode(text, true);
    if (promptIds.length >= 2 && promptIds[0] === promptIds[1] && promptIds[0] === tokenizer.bosTokenId) promptIds = promptIds.slice(1);
    const response: number[] = [];
    for await (const next of generate(model, promptIds, { maxTokens: maxResponse, eosTokenIds: eos, temperature: 0 })) response.push(next.token);
    if (response.length < minResponse) { skippedShort++; continue; }
    const ids = [...promptIds, ...response];
    // The last prompt token seeds the first draft block.
    const respStart = promptIds.length - 1;

    // Tap the m layers over the FULL sequence in one forward: [1, L, m*H].
    const caches = target.makeCache();
    try {
      using input = ops.fromInt32(ids, [1, ids.length]);
      const { hidden, ctxML } = await target.forward(input, caches, [...tapLayers]);
      hidden.dispose();
      using context = ctxML!;
      using rows = ops.reshape(context, [ids.length, tapLayers.length * hiddenSize]);
      using packed = ops.contiguous(rows);
      records.push({ ids, respStart, hiddenMlBf16: packed.rawBytes() });
    } finally { for (const cache of caches) cache.dispose(); }
    pending.push(topic);
    kept++; tokens += ids.length;
    if (records.length >= perShard) flush();
    if ((i + 1) % 20 === 0) opts.onProgress?.({ type: "topics", done: i + 1, total: topics.length, kept, tokens });
  }
  flush();
  return { kept, tokens, shards, skippedShort };
}
