import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import {
  disposeStepExtras,
  isPlainGreedy,
  makeStepSampler,
  type StepSamplerOptions,
} from "../../src/sampler";

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
