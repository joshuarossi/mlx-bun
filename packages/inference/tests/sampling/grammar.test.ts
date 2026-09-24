import { expect, test } from 'bun:test';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Dtype } from '@mlx-bun/mlx/ffi';
import * as ops from '@mlx-bun/mlx/ops';
import { compileGrammarRequest } from '@mlx-bun/inference/sampling/grammar';
import { loadTokenizer } from '@mlx-bun/inference/input';

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
