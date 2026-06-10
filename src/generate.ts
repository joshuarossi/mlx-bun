// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - sampling stays on-device; only the chosen token id crosses to JS

import { MlxArray } from "./mlx/array";
import * as ops from "./mlx/ops";
import { Gemma4Model } from "./model/gemma4";
import {
  makeLogitsProcessors, makeSampler,
  type LogitsProcessorOptions, type SamplerOptions, toLogprobs,
} from "./sampler";

export interface GenerateOptions extends SamplerOptions, LogitsProcessorOptions {
  maxTokens?: number;
  eosTokenIds?: number[];
  prefillChunkSize?: number;
}

export interface GenerateStats {
  promptTokens: number;
  generatedTokens: number;
  prefillTps: number;
  decodeTps: number;
  prefillMs: number;
  decodeMs: number;
}

export interface GeneratedToken {
  token: number;
  index: number;
}

export class Generation implements AsyncIterable<GeneratedToken> {
  stats: GenerateStats | null = null;
  readonly #iter: AsyncGenerator<GeneratedToken, GenerateStats>;

  constructor(iter: AsyncGenerator<GeneratedToken, GenerateStats>) {
    this.#iter = iter;
  }

  async *[Symbol.asyncIterator](): AsyncGenerator<GeneratedToken> {
    while (true) {
      const r = await this.#iter.next();
      if (r.done) {
        this.stats = r.value;
        return;
      }
      yield r.value;
    }
  }
}

export function generate(
  model: Gemma4Model,
  promptTokens: number[],
  options: GenerateOptions = {},
): Generation {
  return new Generation(generateInner(model, promptTokens, options));
}

async function* generateInner(
  model: Gemma4Model,
  promptTokens: number[],
  options: GenerateOptions,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  const {
    maxTokens = 512,
    eosTokenIds = model.config.eosTokenIds,
    prefillChunkSize = 2048,
  } = options;
  const sampler = makeSampler(options);
  const processors = makeLogitsProcessors(options);
  const needsTokenHistory = processors.length > 0;

  const cache = model.makeCache();
  /** device-side token history (only maintained when processors need it) */
  let history: MlxArray | null = null;

  // logits [1,1,V] → sampled token array [1] (all on-device)
  const sampleStep = (logits3d: MlxArray, step: number): MlxArray => {
    const V = logits3d.shape[2]!;
    let logits = ops.reshape(logits3d, [1, V]);
    for (const p of processors) logits = disposing(logits, p(history, logits));
    const lp = toLogprobs(logits);
    logits.dispose();
    const tok = sampler(lp, step);
    lp.dispose();
    return tok;
  };

  const pushHistory = (tok: MlxArray) => {
    if (!needsTokenHistory) return;
    if (!history) {
      history = ops.reshape(tok, [1]);
    } else {
      const prev = history;
      history = ops.concatAxis([prev, tok], 0);
      prev.dispose();
    }
  };

  try {
    // ---- prefill ----
    const tPrefill = performance.now();
    let pos = 0;
    while (promptTokens.length - pos > prefillChunkSize) {
      const chunk = promptTokens.slice(pos, pos + prefillChunkSize);
      const ids = ops.fromInt32(chunk, [1, chunk.length]);
      const h = model.forwardHidden(ids, cache);
      ids.dispose();
      h.dispose(); // logits never computed for non-final chunks
      ops.evalAll(cache.flatMap((c) => c.state()));
      pos += prefillChunkSize;
    }
    if (needsTokenHistory) {
      history = ops.fromInt32(promptTokens, [promptTokens.length]);
    }
    const lastChunk = promptTokens.slice(pos);
    const ids0 = ops.fromInt32(lastChunk, [1, lastChunk.length]);
    const h0 = model.forwardHidden(ids0, cache);
    ids0.dispose();
    const [, L0, H] = h0.shape as [number, number, number];
    const hLast = h0.slice([0, L0 - 1, 0], [1, L0, H]);
    h0.dispose();
    const logits0 = model.logitsFromHidden(hLast);
    hLast.dispose();
    let pending = sampleStep(logits0, 0); // token array [1]
    logits0.dispose();
    // sync: the final chunk's compute belongs to prefill time, not the
    // first decode step (mlx-lm accounts the same way)
    pending.eval();
    const prefillMs = performance.now() - tPrefill;

    // ---- decode (pipelined) ----
    const tDecode = performance.now();
    let generated = 0;
    let stop = false;
    while (!stop) {
      // build step n+1's graph from the *unread* pending token
      let nextPending: MlxArray | null = null;
      if (generated + 1 < maxTokens) {
        pushHistory(pending);
        const ids = ops.reshape(pending, [1, 1]);
        const h = model.forwardHidden(ids, cache);
        ids.dispose();
        const logits = model.logitsFromHidden(h);
        h.dispose();
        nextPending = sampleStep(logits, generated + 1);
        logits.dispose();
        ops.asyncEvalAll([nextPending]);
      }

      // sync-read step n's token while n+1 computes
      const token = ops.itemUint32(pending);
      pending.dispose();
      generated++;

      if (eosTokenIds.includes(token)) {
        nextPending?.dispose();
        stop = true;
      } else {
        yield { token, index: generated - 1 };
        if (nextPending === null) stop = true;
        else pending = nextPending;
      }
    }
    const decodeMs = performance.now() - tDecode;

    return {
      promptTokens: promptTokens.length,
      generatedTokens: generated,
      prefillMs,
      decodeMs,
      prefillTps: (promptTokens.length / prefillMs) * 1000,
      decodeTps: (generated / decodeMs) * 1000,
    };
  } finally {
    for (const c of cache) c.dispose();
    history?.dispose();
  }
}

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
