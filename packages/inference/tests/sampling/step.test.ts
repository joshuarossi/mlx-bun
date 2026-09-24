import { describe, expect, spyOn, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import {
  disposeStepExtras,
  isPlainGreedy,
  makeStepSampler,
  makeLogitsProcessors,
  toLogprobs,
  type StepSamplerOptions,
} from "../../src/sampling/index";

class ScriptedGrammar {
  readonly events: string[] = [];
  readonly isTerminated = false;

  async ready(): Promise<void> {
    this.events.push("ready");
  }

  applyMask(logits: MlxArray): MlxArray {
    this.events.push("mask");
    // A fresh equivalent array exercises the sampler's intermediate ownership.
    return ops.mulScalar(logits, 1);
  }

  accept(token: number): void {
    this.events.push(`accept:${token}`);
  }
}

const SCRIPTED_LOGITS = [
  [0.2, 1.4, -0.1, 0.8, 0.5],
  [0.9, 0.4, 1.1, -0.3, 0.2],
  [-0.2, 0.7, 0.3, 1.2, 0.4],
];

const optionsFor = (grammar: ScriptedGrammar): StepSamplerOptions => ({
  temperature: 0.8,
  topP: 0.95,
  seed: 73,
  logitBias: { 0: -0.25 },
  repetitionPenalty: 1.1,
  grammar,
});

describe("StepSampler lane contract", () => {
  test("scripted logits produce identical tokens in serial, batch, and spec modes", async () => {
    const serialGrammar = new ScriptedGrammar();
    const batchGrammar = new ScriptedGrammar();
    const specGrammar = new ScriptedGrammar();
    const serial = makeStepSampler(optionsFor(serialGrammar), {
      tokenRepresentation: "device",
      grammarWait: "external",
      historyUpdate: "manual",
      initialHistory: [4, 1],
      captureSelectedLogprob: true,
      captureTopLogprobs: 2,
    });
    const batch = makeStepSampler(optionsFor(batchGrammar), {
      tokenRepresentation: "device",
      grammarWait: "external",
      historyUpdate: "after-sample",
      initialHistory: [4, 1],
    });
    const spec = makeStepSampler(optionsFor(specGrammar), {
      tokenRepresentation: "number",
      grammarWait: "before-sample",
      historyUpdate: "after-sample",
      initialHistory: [4, 1],
      acceptGrammar: true,
      eosTokenIds: [],
    });
    const serialTokens: number[] = [];
    const batchTokens: number[] = [];
    const specTokens: number[] = [];

    try {
      for (let step = 0; step < SCRIPTED_LOGITS.length; step++) {
        await serialGrammar.ready();
        const serialLogits = MlxArray.fromFloat32(
          Float32Array.from(SCRIPTED_LOGITS[step]!),
          [1, 1, SCRIPTED_LOGITS[step]!.length],
        );
        const serialResult = serial.sample(serialLogits, step);
        const serialToken = ops.itemUint32(serialResult.token);
        serialTokens.push(serialToken);
        serialGrammar.accept(serialToken);
        serial.commitDevice(serialResult.token);
        expect(serialResult.extras?.sel).not.toBeNull();
        expect(serialResult.extras?.topIdx?.shape).toEqual([1, 2]);
        disposeStepExtras(serialResult.extras);
        serialResult.token.dispose();
        serialLogits.dispose();

        await batchGrammar.ready();
        const batchLogits = MlxArray.fromFloat32(
          Float32Array.from(SCRIPTED_LOGITS[step]!),
          [1, SCRIPTED_LOGITS[step]!.length],
        );
        const batchResult = batch.sample(batchLogits, step);
        const batchToken = ops.itemUint32(batchResult.token);
        batchTokens.push(batchToken);
        batchGrammar.accept(batchToken);
        batchResult.token.dispose();
        batchLogits.dispose();

        const specLogits = MlxArray.fromFloat32(
          Float32Array.from(SCRIPTED_LOGITS[step]!),
          [1, SCRIPTED_LOGITS[step]!.length],
        );
        specTokens.push((await spec.sample(specLogits, step)).token);
        specLogits.dispose();
      }
    } finally {
      serial.dispose();
      batch.dispose();
      spec.dispose();
    }

    expect(batchTokens).toEqual(serialTokens);
    expect(specTokens).toEqual(serialTokens);
    expect(batchGrammar.events).toEqual(serialGrammar.events);
    expect(specGrammar.events).toEqual(serialGrammar.events);
  });

  test("plain greedy eligibility is one exported rule", () => {
    expect(isPlainGreedy({ temperature: 0 })).toBe(true);
    expect(isPlainGreedy({ temperature: 0.8 })).toBe(false);
    expect(isPlainGreedy({
      temperature: 0,
      curve: { points: [{ x_pct: 0.001, y_pct: 0.001 }, { x_pct: 100, y_pct: 100 }] },
    })).toBe(false);
    expect(isPlainGreedy({ temperature: 0, logitBias: { 2: 1 } })).toBe(false);
    expect(isPlainGreedy({ temperature: 0, grammar: new ScriptedGrammar() })).toBe(false);
  });
});


describe("processor history retention", () => {
  test("finite and unlimited windows match full-history processor scores after commits and reseeding", async () => {
    const cases: StepSamplerOptions[] = [
      { logitBias: { 2: 0.3 } },
      { repetitionPenalty: 1.2 },
      { presencePenalty: 0.4, presenceContextSize: 1 },
      { frequencyPenalty: 0.07, frequencyContextSize: 128 },
      { repetitionPenalty: 1.1, repetitionContextSize: 20,
        presencePenalty: 0.2, presenceContextSize: 128,
        frequencyPenalty: 0.03, frequencyContextSize: 7, logitBias: { 0: -0.2 } },
      { repetitionPenalty: 1.1, repetitionContextSize: 0, presencePenalty: 0.2 },
      { presencePenalty: 0.2, presenceContextSize: 0, frequencyPenalty: 0.03 },
      { frequencyPenalty: 0.03, frequencyContextSize: 0, repetitionPenalty: 1.1 },
      { frequencyPenalty: 0, frequencyContextSize: 0, repetitionPenalty: 1.1 },
    ];
    for (const options of cases) for (const dtype of [Dtype.float32, Dtype.bfloat16]) {
      let observed: Buffer | null = null;
      let history = Array.from({ length: 301 }, (_, i) => (i * 7) % 17);
      const sampler = makeStepSampler(options, {
        tokenRepresentation: "device", grammarWait: "external", historyUpdate: "manual",
        initialHistory: history,
        sampler: scores => { observed = Buffer.from(scores.rawBytesView()); return ops.fromInt32([3], [1]); },
      });
      const processors = makeLogitsProcessors(options);
      try {
        for (let step = 0; step < 8; step++) {
          if (step === 5) { history = []; sampler.seedHistory(history); }
          if (step === 7) { history = [1, 1, 8]; sampler.seedHistory(history); }
          using input = MlxArray.fromFloat32(Float32Array.from({ length: 17 }, (_, i) =>
            Math.sin(i + step) * 2), [1, 17]);
          using logits = input.astype(dtype);
          using fullHistory = history.length ? ops.fromInt32(history, [history.length]) : null;
          let scores = logits;
          try {
            for (const processor of processors) {
              const next = processor(fullHistory, scores);
              if (scores !== logits && next !== scores) scores.dispose();
              scores = next;
            }
            using expected = toLogprobs(scores);
            const result = sampler.sample(logits, step);
            result.token.dispose();
            expect(observed!.equals(Buffer.from(expected.rawBytesView()))).toBe(true);
          } finally { if (scores !== logits) scores.dispose(); }
          if (step % 2 === 0) {
            const committed = step === 2 ? Array.from({ length: 257 }, (_, i) => i % 17) : [2, 2, 9];
            sampler.commitNumbers(committed); history.push(...committed);
          } else {
            using token = ops.fromInt32([step % 17], [1]);
            sampler.commitDevice(token); history.push(step % 17);
            sampler.commitNumbers([]);
          }
        }
      } finally { sampler.dispose(); }
    }
  });

  test("finite windows bound seeded and committed history, and bias-only sampling needs none", () => {
    const allocate = spyOn(ops, "fromInt32");
    const config = { tokenRepresentation: "device", grammarWait: "external", historyUpdate: "manual" } as const;
    const tokens = Array.from({ length: 100_000 }, (_, i) => i % 17);
    try {
      const bounded = makeStepSampler({ repetitionPenalty: 1.1, frequencyPenalty: 0.03,
        frequencyContextSize: 128 }, { ...config, initialHistory: tokens });
      try {
        bounded.commitNumbers(tokens);
        expect(bounded.needsHistory).toBe(true);
        expect(allocate.mock.calls.map(call => call[1])).toEqual([[128], [128]]);
      } finally { bounded.dispose(); }
      allocate.mockClear();
      const bias = makeStepSampler({ logitBias: { 1: 0.2 } }, { ...config, initialHistory: tokens });
      try {
        bias.seedHistory(tokens); bias.commitNumbers(tokens);
        expect(bias.needsHistory).toBe(false);
        expect(allocate).not.toHaveBeenCalled();
      } finally { bias.dispose(); }
    } finally { allocate.mockRestore(); }
  });
});
