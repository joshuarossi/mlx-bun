// Sampling — port of mlx-lm's sample_utils.make_sampler /
// make_logits_processors (temperature, top-p, top-k, min-p, XTC,
// repetition/presence/frequency penalties, logit bias).
// All filtering happens on-device; only the chosen token id crosses to JS.
// Seeded: each step derives a fresh key from (seed, step) so runs are
// reproducible without sharing global RNG state. (mlx-lm draws XTC's
// uniform and the categorical from one global stream; we split the
// per-step key into (xtc, categorical) subkeys instead — deterministic,
// and the XTC-off path is unchanged.)

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { runtimeFlag } from "../runtime/config";
import { normalizedArgmax } from "../kernels/sampling/normalized-argmax";
import { disposeStepExtras } from "./extras";
import { applyTopKRows,applyTopPRows } from "./window-filters";
import { logitsHistoryLimit,makeLogitsProcessors } from "./processors";
import { makeSampler,stepKey,toLogprobs } from "./sampler";
import { DeviceStepSampler,DeviceStepSamplerConfig,NumberStepSampler,NumberStepSamplerConfig,StepExtras,StepSample,StepSamplerOptions } from "./types";

/** Whether scores can use stateless greedy sampling across independent rows. */
export function isPlainGreedy(
  opts: StepSamplerOptions,
  hasProcessors = makeLogitsProcessors(opts).length > 0,
): boolean {
  return (opts.temperature ?? 0) === 0 && !opts.curve && !hasProcessors && !opts.grammar;
}

export function makeStepSampler(
  options: StepSamplerOptions,
  config: DeviceStepSamplerConfig,
): DeviceStepSampler;
export function makeStepSampler(
  options: StepSamplerOptions,
  config: NumberStepSamplerConfig,
): NumberStepSampler;
export function makeStepSampler(
  options: StepSamplerOptions,
  config: DeviceStepSamplerConfig | NumberStepSamplerConfig,
): DeviceStepSampler | NumberStepSampler {
  const sampler = config.sampler ?? makeSampler(options);
  const processors = makeLogitsProcessors(options);
  const grammar = options.grammar ?? null;
  const captureSelected = config.captureSelectedLogprob === true;
  const captureTop = Math.max(0, config.captureTopLogprobs ?? 0);
  const capture = captureSelected || captureTop > 0;
  const greedyWithoutMetadata = (options.temperature ?? 0) === 0 && !options.curve && !capture && !config.sampler;
  const historyLimit = logitsHistoryLimit(options);
  let history: MlxArray | null = null;

  const seedHistory = (tokens: readonly number[]): void => {
    if (historyLimit === 0) return;
    if (tokens.length === 0) {
      history?.dispose();
      history = null;
      return;
    }
    const recent = tokens.slice(Math.max(0, tokens.length - historyLimit));
    const next = ops.fromInt32(recent, [recent.length]);
    const previous = history;
    history = next;
    previous?.dispose();
  };

  // Takes ownership of next. Trim before concatenation so the appended array
  // never exceeds the largest active finite window.
  const appendHistory = (next: MlxArray): void => {
    const previous = history;
    if (!previous || next.size >= historyLimit) {
      history = next;
      previous?.dispose();
      return;
    }
    const keep = Math.min(previous.size, historyLimit - next.size);
    let tail: MlxArray | null = null;
    try {
      if (keep < previous.size) tail = previous.slice([previous.size - keep], [previous.size]);
      history = ops.concatAxis([tail ?? previous, next], 0);
      previous.dispose();
    } finally {
      tail?.dispose();
      next.dispose();
    }
  };

  const commitDevice = (token: MlxArray): void => {
    if (historyLimit === 0) return;
    appendHistory(ops.reshape(token, [1]));
  };

  const commitNumbers = (tokens: readonly number[]): void => {
    if (tokens.length === 0 || historyLimit === 0) return;
    const recent = tokens.slice(Math.max(0, tokens.length - historyLimit));
    appendHistory(ops.fromInt32(recent, [recent.length]));
  };

  const sampleDevice = (input: MlxArray, step: number): StepSample<MlxArray> => {
    const vocab = input.shape[input.shape.length - 1]!;
    let current = input.shape.length === 2 ? input : ops.reshape(input, [1, vocab]);
    let ownsCurrent = current !== input;
    let logprobs: MlxArray | null = null;
    let token: MlxArray | null = null;
    let extras: StepExtras | null = null;
    try {
      for (const processor of processors) {
        const next = processor(history, current);
        if (ownsCurrent && next !== current) current.dispose();
        current = next;
        ownsCurrent = current !== input;
      }
      if (grammar && !grammar.isTerminated) {
        const next = grammar.applyMask(current);
        if (ownsCurrent && next !== current) current.dispose();
        current = next;
        ownsCurrent = current !== input;
      }
      if (greedyWithoutMetadata)
        return { token: normalizedArgmax(current), extras: null };
      logprobs = toLogprobs(current);
      if (ownsCurrent) current.dispose();
      current = input;
      ownsCurrent = false;
      token = sampler(logprobs, step);

      if (capture) {
        extras = { sel: null, topIdx: null, topVals: null };
        if (captureSelected) {
          const idx = ops.reshape(token, [1, 1]);
          try {
            extras.sel = ops.takeAlongAxis(logprobs, idx, -1);
          } finally {
            idx.dispose();
          }
        }
        if (captureTop > 0) {
          const k = Math.min(captureTop, vocab);
          let neg: MlxArray | null = null;
          let partition: MlxArray | null = null;
          let view: MlxArray | null = null;
          try {
            neg = ops.neg(logprobs);
            partition = ops.argpartitionAxis(neg, k - 1, -1);
            view = partition.slice([0, 0], [1, k]);
            extras.topIdx = ops.contiguous(view);
            extras.topVals = ops.takeAlongAxis(logprobs, extras.topIdx, -1);
          } finally {
            neg?.dispose();
            partition?.dispose();
            view?.dispose();
          }
        }
      }

      logprobs.dispose();
      logprobs = null;
      const result = { token, extras };
      token = null;
      extras = null;
      return result;
    } finally {
      if (ownsCurrent) current.dispose();
      logprobs?.dispose();
      token?.dispose();
      disposeStepExtras(extras);
    }
  };

  if (config.initialHistory) seedHistory(config.initialHistory);

  // Per-position sampling for a verify window: with no processors, grammar or
  // capture, position p's draw depends only on its scores and its step key, so
  // every position of the window can sit in ONE device graph and read back
  // together. Row p reproduces sample(scores[p], steps[p]) exactly.
  // The plain filter chain (top-p -> top-k -> temperature -> categorical) can run
  // its filters once over the whole window. Other samplers keep per-row calls.
  const windowFilters = !config.sampler && !options.curve && options.hlg?.enabled !== true &&
    (options.minP ?? 0) === 0 && (options.xtcProbability ?? 0) === 0 && (options.temperature ?? 0) > 0 &&
    runtimeFlag("MLX_BUN_SAMPLER_WINDOW_FILTERS", true)
    ? { temperature: options.temperature!, topP: options.topP ?? 0, topK: options.topK ?? 0, seed: options.seed ?? 0 }
    : null;
  const positional = processors.length === 0 && !grammar && !capture
    ? {
      sample(scores: MlxArray, steps: readonly number[]): MlxArray {
        if (scores.shape.length !== 2 || scores.shape[0] !== steps.length)
          throw new Error(`positional sampling expects [${steps.length}, V] scores, got [${scores.shape.join(", ")}]`);
        const vocab = scores.shape[1]!;
        const tokens: MlxArray[] = [];
        let packed: MlxArray | null = null;
        try {
          if (windowFilters && steps.length > 1) {
            // One filter chain over [W, V] (bit-identical per row to the [1, V]
            // chain, tests/unit/sampler-window.test.ts), then each row's own
            // keyed draw on its [1, V] slice: that shape keeps MLX's inverse-CDF
            // categorical, which the draft's coupled draw relies on.
            using logprobs = toLogprobs(scores);
            let current = logprobs, owned: MlxArray | null = null;
            try {
              if (windowFilters.topP > 0 && windowFilters.topP < 1) { owned = applyTopPRows(current, windowFilters.topP); current = owned; }
              if (windowFilters.topK > 0) {
                const next = applyTopKRows(current, windowFilters.topK);
                owned?.dispose(); owned = next; current = next;
              }
              for (const [position, step] of steps.entries()) {
                using row = current.slice([position, 0], [position + 1, vocab]);
                using scaled = ops.mulScalar(row, 1 / windowFilters.temperature);
                using key = stepKey(windowFilters.seed, step);
                tokens.push(ops.randomCategorical(scaled, key));
              }
            } finally { owned?.dispose(); }
          } else
          for (const [position, step] of steps.entries()) {
            using row = scores.slice([position, 0], [position + 1, vocab]);
            if (greedyWithoutMetadata) { tokens.push(normalizedArgmax(row)); continue; }
            using logprobs = toLogprobs(row);
            tokens.push(sampler(logprobs, step));
          }
          if (tokens.length === 1) return tokens.pop()!;
          packed = ops.concatAxis(tokens, 0);
          const result = packed;
          packed = null;
          return result;
        } finally {
          packed?.dispose();
          for (const token of tokens) token.dispose();
        }
      },
    }
    : undefined;

  const common = {
    independent: isPlainGreedy(options, processors.length > 0) && !capture && !config.sampler
      ? independentGreedySampling : undefined,
    positional,
    isPlainGreedy: isPlainGreedy(options, processors.length > 0),
    capturesLogprobs: capture,
    needsHistory: historyLimit > 0,
    seedHistory,
    commitDevice,
    commitNumbers,
    dispose: () => {
      history?.dispose();
      history = null;
    },
  };

  if (config.tokenRepresentation === "device") {
    return {
      ...common,
      sample(logits, step) {
        const result = sampleDevice(logits, step);
        if (config.historyUpdate === "after-sample") commitDevice(result.token);
        return result;
      },
    };
  }

  return {
    ...common,
    async sample(logits, step) {
      if (grammar && !grammar.isTerminated) await grammar.ready();
      const result = sampleDevice(logits, step);
      let tokenArray: MlxArray | null = result.token;
      try {
        // Read the sampler's integer result directly. Adding an astype here
        // would append work behind the next dispatched decode step.
        const token = ops.itemUint32(tokenArray);
        tokenArray.dispose();
        tokenArray = null;
        if (config.acceptGrammar && grammar && !config.eosTokenIds?.includes(token))
          grammar.accept(token);
        if (config.historyUpdate === "after-sample") commitNumbers([token]);
        return { token, extras: result.extras };
      } catch (error) {
        disposeStepExtras(result.extras);
        throw error;
      } finally {
        tokenArray?.dispose();
      }
    },
  };
}

/** Stateless sampling across rows or verification positions. Preserve the
 * normalized-score argmax, including rounding-created ties. */
export const independentGreedySampling = Object.freeze({
  sample: normalizedArgmax,
});
