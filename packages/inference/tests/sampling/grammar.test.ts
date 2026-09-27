import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { MlxArray } from '@mlx-bun/mlx/array';
import { Dtype } from '@mlx-bun/mlx/ffi';
import * as ops from '@mlx-bun/mlx/ops';
import { compileGrammarRequest, type GrammarRequest } from '@mlx-bun/inference/sampling/grammar';
import {
  disposeStepExtras, makeStepSampler, type DeviceStepSampler, type DeviceStepSamplerConfig, type StepSamplerOptions,
} from '@mlx-bun/inference/sampling';
import { loadTokenizer, type LoadedTokenizer } from '@mlx-bun/inference/input';

test('a caller-loaded tokenizer drives independent grammar masks', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'mlx-grammar-'));
  try {
    writeFileSync(join(dir, 'tokenizer.json'), JSON.stringify({
      version: '1.0', added_tokens: [], normalizer: null,
      pre_tokenizer: { type: 'Whitespace' }, post_processor: null, decoder: null,
      model: { type: 'WordLevel', vocab: { '[UNK]': 0, yes: 1, no: 2, maybe: 3 }, unk_token: '[UNK]' },
    }));
    writeFileSync(join(dir, 'tokenizer_config.json'), JSON.stringify({ unk_token: '[UNK]' }));
    const tokenizer = await loadTokenizer(dir);
    const results = await Promise.all([
      compileGrammarRequest({ guidedChoice: ['yes'] }, tokenizer, 4),
      compileGrammarRequest({ guidedChoice: ['no'] }, tokenizer, 4),
    ]);
    try {
      for (const [i, result] of results.entries()) {
        expect(result).not.toBeNull();
        const controller = result!.controller!;
        await controller.ready();
        using logits = ops.zeros([1, 4], Dtype.float32);
        using masked = controller.applyMask(logits);
        expect(Array.from(masked.toFloat32())).toEqual(
          Array.from({ length: 4 }, (_, id) => id === i + 1 ? 0 : -Infinity),
        );
        controller.accept(i + 1);
        await controller.ready();
      }
    } finally { for (const result of results) result?.controller?.dispose(); }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

// Ordinary grammar rows of every family sample through this row sampler
// (GenerationGateway's configuration). The batch group awaits ready() before a
// row's sample and accepts the read token after it; the sampler sees only the
// model's logits, never the model.
describe('XGrammar through the shared row sampler', () => {
  // 32 ids fill exactly one bitmask word.
  const vocab = ['[UNK]', 'yes', 'no', 'maybe', ...Array.from({ length: 28 }, (_, i) => `f${i + 4}`)];
  const [YES, NO, MAYBE] = [1, 2, 3];
  let dir = '';
  let tokenizer: LoadedTokenizer;

  beforeAll(async () => {
    dir = mkdtempSync(join(tmpdir(), 'mlx-grammar-sampling-'));
    writeFileSync(join(dir, 'tokenizer.json'), JSON.stringify({
      version: '1.0', added_tokens: [], normalizer: null,
      pre_tokenizer: { type: 'Whitespace' }, post_processor: null, decoder: null,
      model: { type: 'WordLevel', vocab: Object.fromEntries(vocab.map((token, id) => [token, id])), unk_token: '[UNK]' },
    }));
    writeFileSync(join(dir, 'tokenizer_config.json'), JSON.stringify({ unk_token: '[UNK]' }));
    tokenizer = await loadTokenizer(dir);
  });
  afterAll(() => rmSync(dir, { recursive: true, force: true }));

  const compile = async (request: GrammarRequest, width = vocab.length) => {
    const result = await compileGrammarRequest(request, tokenizer, width);
    expect(result?.controller).toBeTruthy();
    return result!.controller!;
  };
  const rowSampler = (options: StepSamplerOptions, capture: Partial<DeviceStepSamplerConfig> = {}) =>
    makeStepSampler(options, {
      tokenRepresentation: 'device', grammarWait: 'external', historyUpdate: 'after-sample', initialHistory: [], ...capture,
    });
  const draw = (sampler: DeviceStepSampler, logits: MlxArray, step: number): number => {
    const { token, extras } = sampler.sample(logits, step);
    try { return ops.itemUint32(token); } finally { token.dispose(); disposeStepExtras(extras); }
  };
  const logitsRows = (rows: number, width: number, fill: number, values: Record<number, number>,
    dtype: Dtype = Dtype.float32) => {
    const data = new Float32Array(rows * width).fill(fill);
    for (let row = 0; row < rows; row++)
      for (const [id, value] of Object.entries(values)) data[row * width + Number(id)] = value;
    const logits = MlxArray.fromFloat32(data, [rows, width]);
    if (dtype === Dtype.float32) return logits;
    try { return logits.astype(dtype); } finally { logits.dispose(); }
  };

  test('the mask applies before sampling: a forbidden id with the top logit is never drawn', async () => {
    const controller = await compile({ guidedChoice: ['yes', 'no'] });
    try {
      await controller.ready();
      const values = { 0: 20, [YES]: 1, [NO]: 0.5, [MAYBE]: 30 };
      using logits = logitsRows(1, vocab.length, 8, values);
      using masked = controller.applyMask(logits);
      expect(Array.from(masked.toFloat32())).toEqual(
        Array.from({ length: vocab.length }, (_, id) => id === YES || id === NO ? values[id]! : -Infinity));
      for (const [options, capture, allowed] of [
        [{ temperature: 0 }, {}, [YES]],
        [{ temperature: 0 }, { captureSelectedLogprob: true, captureTopLogprobs: 2 }, [YES]],
        [{ temperature: 0, logitBias: { [MAYBE]: 5 } }, {}, [YES]],
        [{ temperature: 1.5, seed: 11 }, {}, [YES, NO]],
      ] as const) {
        const sampler = rowSampler({ ...options, grammar: controller }, capture);
        try {
          const drawn = new Set<number>();
          for (let step = 0; step < 32; step++) drawn.add(draw(sampler, logits, step));
          expect([...drawn].sort((a, b) => a - b)).toEqual([...allowed]);
        } finally { sampler.dispose(); }
      }
    } finally { controller.dispose(); }
  });

  test('logits processors run before the mask; normalization and sampler filters run after it', async () => {
    const controller = await compile({ guidedChoice: ['yes', 'no'] });
    try {
      await controller.ready();
      const raw = { 0: 0, [YES]: 1, [NO]: 3, [MAYBE]: 5 };
      using logits = logitsRows(1, vocab.length, -1, raw);
      const maskInputs: number[][] = [];
      const recorded = {
        get isTerminated() { return controller.isTerminated; },
        ready: () => controller.ready(),
        accept: (token: number) => controller.accept(token),
        applyMask(input: MlxArray) {
          maskInputs.push(Array.from(input.toFloat32()));
          return controller.applyMask(input);
        },
      };
      let samplerInput: number[] = [];
      const observed = makeStepSampler({ logitBias: { [YES]: 2 }, repetitionPenalty: 2, presencePenalty: 0.5, grammar: recorded }, {
        tokenRepresentation: 'device', grammarWait: 'external', historyUpdate: 'after-sample', initialHistory: [NO, NO],
        sampler: logprobs => { samplerInput = Array.from(logprobs.toFloat32()); return ops.fromInt32([YES], [1]); },
      });
      try { observed.sample(logits, 0).token.dispose(); } finally { observed.dispose(); }
      // Bias (yes 1 + 2), repetition penalty (no 3 / 2), presence penalty (no 1.5 - 0.5).
      const processed: Record<number, number> = { ...raw, [YES]: 3, [NO]: 1 };
      expect(maskInputs).toEqual([Array.from({ length: vocab.length }, (_, id) => processed[id] ?? -1)]);
      // The sampler receives log-probabilities normalized over the grammar's ids only.
      const lse = Math.log(Math.exp(3) + Math.exp(1));
      expect(samplerInput[YES]).toBeCloseTo(3 - lse, 5);
      expect(samplerInput[NO]).toBeCloseTo(1 - lse, 5);
      expect(samplerInput.filter((_, id) => id !== YES && id !== NO).every(value => value === -Infinity)).toBe(true);
      // Top-k and top-p see the masked distribution: 'maybe' leads the raw
      // logits, yet each filter keeps only the best allowed id.
      for (const filter of [{ topK: 1 }, { topP: 0.5 }]) {
        const sampler = rowSampler({ temperature: 1, seed: 3, ...filter, grammar: controller });
        try { expect(draw(sampler, logits, 0)).toBe(NO); } finally { sampler.dispose(); }
      }
    } finally { controller.dispose(); }
  });

  test('padded logits past the tokenizer vocabulary are never drawn and allowed ids keep their positions', async () => {
    // Padding starts at a word boundary: one full padded bitmask word, then a
    // partial one. Padding inside the matcher's last word would follow XGrammar's
    // bits for that word, which this test does not cover.
    const padding = 40;
    const width = vocab.length + padding;
    const controller = await compile({ guidedGrammar: 'root ::= ("yes" | "no") "maybe"' }, width);
    const values: Record<number, number> = { [YES]: 0.5, [NO]: 0.25, [MAYBE]: 0.75 };
    for (let id = vocab.length; id < width; id++) values[id] = 100;
    try {
      for (const [step, allowed] of [[0, [YES, NO]], [1, [MAYBE]]] as const) {
        await controller.ready();
        for (const dtype of [Dtype.float32, Dtype.bfloat16]) {
          using logits = logitsRows(1, width, 0, values, dtype);
          using masked = controller.applyMask(logits);
          expect(masked.shape).toEqual([1, width]);
          expect(Array.from(masked.toFloat32())).toEqual(
            Array.from({ length: width }, (_, id) => (allowed as readonly number[]).includes(id) ? values[id]! : -Infinity));
          for (const options of [{ temperature: 0 }, { temperature: 1, seed: 5 }]) {
            const sampler = rowSampler({ ...options, grammar: controller });
            try {
              for (let n = 0; n < 8; n++) expect(allowed).toContain(draw(sampler, logits, step * 8 + n));
              if (options.temperature === 0) expect(draw(sampler, logits, step)).toBe(allowed[0]);
            } finally { sampler.dispose(); }
          }
        }
        controller.accept(allowed[0]);
      }
      expect(controller.isTerminated).toBe(true);
    } finally { controller.dispose(); }
  });

  test('requests sampled in one batch step keep independent matchers', async () => {
    const pair = 'root ::= "yes" "no"';
    const controllers = await Promise.all([
      compile({ guidedGrammar: pair }), compile({ guidedGrammar: pair }), compile({ guidedChoice: ['maybe'] }),
    ]);
    const [ahead, behind] = controllers;
    const rows = controllers.map(grammar => ({ grammar, sampler: rowSampler({ temperature: 0, grammar }), step: 0 }));
    try {
      // Forbidden ids lead every row, so only a row's own matcher picks its token.
      const values = { [YES]: 1, [NO]: 1, [MAYBE]: 1 };
      // Advance one request alone: two requests now hold the same grammar at different states.
      await ahead.ready();
      using solo = logitsRows(1, vocab.length, 9, values);
      const first = draw(rows[0]!.sampler, solo, rows[0]!.step++);
      expect(first).toBe(YES);
      ahead.accept(first);
      // One batch step over a [3, V] logits tensor with identical rows.
      using batch = logitsRows(3, vocab.length, 9, values);
      await Promise.all(rows.map(row => row.grammar.ready()));
      const tokens = rows.map((row, b) => {
        using logits = batch.slice([b, 0], [b + 1, vocab.length]);
        return draw(row.sampler, logits, row.step++);
      });
      expect(tokens).toEqual([NO, YES, MAYBE]);
      rows.forEach((row, b) => row.grammar.accept(tokens[b]!));
      expect(rows.map(row => row.grammar.isTerminated)).toEqual([true, false, true]);
      await behind.ready();
      using next = behind.applyMask(solo);
      expect(Array.from(next.toFloat32()).flatMap((value, id) => value === -Infinity ? [] : [id])).toEqual([NO]);
    } finally { for (const row of rows) { row.sampler.dispose(); row.grammar.dispose(); } }
  });
});
