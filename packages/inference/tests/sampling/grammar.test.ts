import { afterAll, beforeAll, describe, expect, spyOn, test } from 'bun:test';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import xgrammar from '@mlc-ai/web-xgrammar';
import { MlxArray } from '@mlx-bun/mlx/array';
import { Dtype } from '@mlx-bun/mlx/ffi';
import * as ops from '@mlx-bun/mlx/ops';
import { compileGrammarRequest, type GrammarController, type GrammarRequest } from '@mlx-bun/inference/sampling/grammar';
import {
  disposeStepExtras, makeStepSampler, type DeviceStepSampler, type DeviceStepSamplerConfig, type StepSamplerOptions,
} from '@mlx-bun/inference/sampling';
import { loadTokenizer, type LoadedTokenizer } from '@mlx-bun/inference/input';
import { configureRuntime } from '@mlx-bun/inference/runtime/config';

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
    // partial one. Padding that starts inside the matcher's last word is covered
    // by 'grammar masks reject ids the matcher does not know' below.
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

// XGrammar decides only the ids its TokenizerInfo was built with: the
// tokenizer's model.vocab. When that count is not a multiple of 32 it can set
// the unused high bits of its final bitmask word, and the logits can be wider
// still (config padding, added tokens). Every ready mask must keep XGrammar's
// verdict below that count and reject every other id, on both mask paths.
// Opt in to the real-tokenizer case with MLX_BUN_TEST_GRAMMAR_TOKENIZER=/cached/checkpoint
// (tokenizer.json + config.json; e.g. MiniCPM5: 130072 ids, vocab_size 130560). No downloads.
const realCheckpoint = Bun.env.MLX_BUN_TEST_GRAMMAR_TOKENIZER;
if (realCheckpoint && !existsSync(join(realCheckpoint, 'tokenizer.json')))
  throw new Error(`unavailable tokenizer: ${realCheckpoint}`);

describe('grammar masks reject ids the matcher does not know', () => {
  const [YES, NO] = [1, 2];
  const paths = ['eager', 'metal'] as const;
  const dtypes = [Dtype.float32, Dtype.bfloat16];
  let dir = '';
  // XGrammar's raw bitmasks, in fill order: the verdicts each controller receives.
  const fills = spyOn(xgrammar.GrammarMatcher.prototype, 'getNextTokenBitmask');
  /** The raw bitmask of the one fill `action` causes. */
  const fillOf = async (action: () => Promise<void>): Promise<Int32Array> => {
    const before = fills.mock.calls.length;
    await action();
    expect(fills.mock.calls.length).toBe(before + 1);
    return fills.mock.results.at(-1)!.value as Promise<Int32Array>;
  };
  const tokenizerOf = async (name: string, vocab: string[]) => {
    const path = join(dir, name);
    mkdirSync(path);
    writeFileSync(join(path, 'tokenizer.json'), JSON.stringify({
      version: '1.0', added_tokens: [], normalizer: null,
      // Split lets a jump-forward string ("yesno") retokenize into vocabulary ids.
      pre_tokenizer: { type: 'Split', pattern: { Regex: 'yes|no|maybe' }, behavior: 'Isolated', invert: false },
      post_processor: null, decoder: null,
      model: { type: 'WordLevel', vocab: Object.fromEntries(vocab.map((token, id) => [token, id])), unk_token: '[UNK]' },
    }));
    writeFileSync(join(path, 'tokenizer_config.json'), JSON.stringify({ unk_token: '[UNK]' }));
    return loadTokenizer(path);
  };
  // Four ids fill part of one bitmask word: ids 4-31 share it.
  const four = ['[UNK]', 'yes', 'no', 'maybe'];
  // One full word, then ids 32-35 of a partial word; maybe is the last known id.
  const wide = ['[UNK]', 'yes', 'no', ...Array.from({ length: 32 }, (_, i) => `a${i}`), 'maybe'];
  let fourTokenizer: LoadedTokenizer;
  let wideTokenizer: LoadedTokenizer;

  beforeAll(async () => {
    dir = mkdtempSync(join(tmpdir(), 'mlx-grammar-vocab-'));
    fourTokenizer = await tokenizerOf('four', four);
    wideTokenizer = await tokenizerOf('wide', wide);
  });
  afterAll(() => {
    fills.mockRestore();
    rmSync(dir, { recursive: true, force: true });
  });

  // The controller reads MLX_BUN_TOKEN_MASK when it is built; compile one at a time.
  const compileOn = async (path: typeof paths[number], request: GrammarRequest, tok: LoadedTokenizer, logits: number) => {
    const restore = configureRuntime({ MLX_BUN_TOKEN_MASK: path === 'metal' ? 'metal' : undefined });
    try {
      const result = await compileGrammarRequest(request, tok, logits);
      expect(result?.controller).toBeTruthy();
      return result!.controller!;
    } finally { restore(); }
  };
  const bit = (bits: Int32Array, id: number) => ((bits[id >>> 5] ?? 0) >>> (id & 31)) & 1;
  const range = (start: number, end: number) => Array.from({ length: end - start }, (_, i) => start + i);
  /** Ids XGrammar marks valid although they lie past the ids it knows. */
  const strayBits = (bits: Int32Array, known: number) => range(known, bits.length * 32).filter(id => bit(bits, id));
  const logitsRows = (rows: number, row: Float32Array, dtype: Dtype) => {
    const data = new Float32Array(rows * row.length);
    for (let r = 0; r < rows; r++) data.set(row, r * row.length);
    const logits = MlxArray.fromFloat32(data, [rows, row.length]);
    if (dtype === Dtype.float32) return logits;
    try { return logits.astype(dtype); } finally { logits.dispose(); }
  };
  /** Differences from the expected mask: XGrammar's verdict below `known`, -inf from `known` on. */
  const maskErrors = (masked: MlxArray, row: Float32Array, raw: Int32Array, known: number): string[] => {
    const out = masked.toFloat32(), errors: string[] = [];
    for (let i = 0; i < out.length && errors.length < 8; i++) {
      const id = i % row.length;
      const want = id < known && bit(raw, id) ? row[id]! : -Infinity;
      if (!Object.is(out[i], want)) errors.push(`row ${Math.floor(i / row.length)} id ${id}: ${out[i]} != ${want}`);
    }
    return errors;
  };
  const draw = (grammar: GrammarController, options: StepSamplerOptions, logits: MlxArray, steps: number) => {
    const sampler = makeStepSampler({ ...options, grammar }, {
      tokenRepresentation: 'device', grammarWait: 'external', historyUpdate: 'after-sample', initialHistory: [],
    });
    try {
      return range(0, steps).map(step => {
        const { token, extras } = sampler.sample(logits, step);
        try { return ops.itemUint32(token); } finally { token.dispose(); disposeStepExtras(extras); }
      });
    } finally { sampler.dispose(); }
  };

  test('guided_choice over a 4-id tokenizer rejects ids 4-39 of 40 logits', async () => {
    const width = 40;
    // Every id past the tokenizer leads, and [UNK] and maybe outrank the choices.
    const row = Float32Array.from({ length: width }, (_, id) => id < four.length ? [20, 1, 0.5, 30][id]! : 100);
    for (const path of paths) {
      let controller: GrammarController | undefined;
      try {
        const raw = await fillOf(async () => {
          controller = await compileOn(path, { guidedChoice: ['yes', 'no'] }, fourTokenizer, width);
        });
        // XGrammar marks ids 4-31 valid in its only word.
        expect(strayBits(raw, four.length)).toEqual(range(four.length, 32));
        for (const dtype of dtypes) {
          using batch = logitsRows(3, row, dtype);
          using masked = controller!.applyMask(batch);
          expect(masked.shape).toEqual([3, width]);
          expect(maskErrors(masked, row, raw, four.length)).toEqual([]);
          using single = logitsRows(1, row, dtype);
          expect(draw(controller!, { temperature: 0 }, single, 4)).toEqual([YES, YES, YES, YES]);
          const sampled = new Set(draw(controller!, { temperature: 1, seed: 7 }, single, 32));
          expect([...sampled].every(id => id === YES || id === NO)).toBe(true);
        }
      } finally { controller?.dispose(); }
    }
  });

  test('forked and jump-resumed grammar states keep their own verdicts in one batch', async () => {
    // Ids 36-63 share the matcher's last word; ids 64-71 lie past it.
    const width = 72, known = wide.length, MAYBE = known - 1, fillers = range(3, MAYBE);
    const twoStep = 'root ::= ("yes" | "no") ("a" [0-9]+)* "maybe"';
    const jump = 'root ::= "yes" "no" ("a" [0-9]+)* "maybe"';
    // Every unknown id leads, and [UNK] outranks every allowed id.
    const row = Float32Array.from({ length: width }, (_, id) => id === 0 ? 50 : id < known ? id / 4 : 100);
    for (const path of paths) {
      const controllers: GrammarController[] = [];
      const raws: Int32Array[] = [];
      try {
        for (const request of [{ guidedGrammar: twoStep }, { guidedGrammar: twoStep }, { guidedGrammar: jump }])
          raws.push(await fillOf(async () => { controllers.push(await compileOn(path, request, wideTokenizer, width)); }));
        const [ahead, , resumed] = controllers as [GrammarController, GrammarController, GrammarController];
        const expectRows = async (want: number[][]) => {
          await Promise.all(controllers.map(controller => controller.ready()));
          for (const dtype of dtypes) {
            using batch = logitsRows(controllers.length, row, dtype);
            controllers.forEach((controller, b) => {
              using logits = batch.slice([b, 0], [b + 1, width]);
              using masked = controller.applyMask(logits);
              expect(maskErrors(masked, row, raws[b]!, known)).toEqual([]);
              expect(Array.from(masked.toFloat32()).flatMap((value, id) => value === -Infinity ? [] : [id])).toEqual(want[b]!);
              expect(draw(controller, { temperature: 0 }, logits, 1)).toEqual([want[b]!.at(-1)!]);
            });
          }
        };
        await expectRows([[YES, NO], [YES, NO], [YES]]);
        // Fork one grammar: only the first request advances.
        raws[0] = await fillOf(async () => { ahead.accept(YES); await ahead.ready(); });
        // Resume masked decoding after a forced span.
        raws[2] = await fillOf(async () => { expect(resumed.jumpForward(8)).toEqual([YES, NO]); await resumed.ready(); });
        // Both advanced states set every stray bit of the last word.
        expect(raws.map(raw => strayBits(raw, known).length)).toEqual([28, 0, 28]);
        await expectRows([[...fillers, MAYBE], [YES, NO], [...fillers, MAYBE]]);
      } finally { for (const controller of controllers) controller.dispose(); }
    }
  });

  test.skipIf(!realCheckpoint)('a real tokenizer whose vocabulary is not a multiple of 32 rejects its unknown ids', async () => {
    const json = JSON.parse(readFileSync(join(realCheckpoint!, 'tokenizer.json'), 'utf8'));
    const config = JSON.parse(readFileSync(join(realCheckpoint!, 'config.json'), 'utf8'));
    const known = Object.keys(json.model.vocab).length;
    const logitWidth: number = config.vocab_size ?? config.text_config?.vocab_size;
    expect(known % 32).not.toBe(0);
    expect(logitWidth).toBeGreaterThan(known);
    const real = await loadTokenizer(realCheckpoint!);
    const [hello] = real.encode('Hello', false);
    // Known ids share one logit, so greedy picks the lowest valid id; every other id leads.
    const row = Float32Array.from({ length: logitWidth }, (_, id) => id < known ? 0 : 100);
    // A line stays open until its newline; bare free text terminates after one token.
    const line = 'root ::= [^\\n]+ "\\n"';
    for (const path of paths) {
      const controllers: GrammarController[] = [];
      const raws: Int32Array[] = [];
      try {
        for (const request of [{ guidedGrammar: line }, { guidedGrammar: line }, { guidedGrammar: 'root ::= [^\\n]*' }])
          raws.push(await fillOf(async () => { controllers.push(await compileOn(path, request, real, logitWidth)); }));
        // Fork one line grammar: the first request is a token ahead of the second.
        for (const b of [0, 0, 1])
          raws[b] = await fillOf(async () => { controllers[b]!.accept(hello!); await controllers[b]!.ready(); });
        // Some state must set the final word's stray bits, or this tokenizer
        // cannot exercise the fix (MiniCPM5: added tokens 130072-130079).
        expect(raws.some(raw => strayBits(raw, known).length > 0)).toBe(true);
        for (const dtype of dtypes) {
          using batch = logitsRows(controllers.length, row, dtype);
          controllers.forEach((controller, b) => {
            using logits = batch.slice([b, 0], [b + 1, logitWidth]);
            using masked = controller.applyMask(logits);
            expect(maskErrors(masked, row, raws[b]!, known)).toEqual([]);
            const [token] = draw(controller, { temperature: 0 }, logits, 1);
            expect(token).toBeLessThan(known);
            expect(bit(raws[b]!, token!)).toBe(1);
          });
        }
      } finally { for (const controller of controllers) controller.dispose(); }
    }
  }, 120_000);
});
