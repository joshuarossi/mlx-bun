import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import type { Cache } from "../../src/model/gemma4-base";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("complete Qwen MTP row rounds", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { KVCache, QuantizedKVCache } = await import("../../src/model/gemma4-base");
  const { BatchedKVCache } = await import("../../src/model/batched-kv");
  const { BatchedQuantizedKVCache } = await import("../../src/model/batched-quantized-kv");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { BatchedSSMCache } = await import("../../src/model/batched-ssm");
  const { MlxStateRows } = await import("../../src/backends/mlx/state-rows");
  const { applyStateChanges } = await import("../../src/engine/resources");
  const { MtpModule } = await import("../../src/spec/qwen-mtp-module");
  const { QwenMtpRows } = await import("../../src/spec/qwen-mtp-rows");
  const { QwenMtpSource, QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { bindRowCacheRollback, bindCacheRollback } = await import("../../src/backends/mlx/rollback");
  const { advanceSpeculativeOutputs, sampleSpeculativeRows } = await import("../../src/backends/mlx/speculative-round");
  const { makeSampler, makeStepSampler, readStepExtras } = await import("../../src/sampler");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { MlxArray } = await import("../../src/mlx/array");
  const { clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  type Array = InstanceType<typeof MlxArray>;
  type RowCache = InstanceType<typeof SSMCache> | InstanceType<typeof BatchedKVCache> | InstanceType<typeof BatchedQuantizedKVCache>;
  const digest = (array: Array) => { using flat = ops.contiguous(array);
    return createHash("sha256").update(flat.rawBytesView()).digest("hex"); };
  const dispose = (caches: readonly Cache[]) => { for (const cache of caches) cache.dispose(); };

  for (const variable of [false, true]) test(`complete rounds and terminal state match same-B controls, variable proposals=${variable}`, async () => {
    using resources = new DisposableStack();
    const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draftPath = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const weights = await Weights.open(path); resources.defer(() => weights.dispose());
    const model = new Qwen35Model(weights, await loadModelConfig(path));
    const dw = await Weights.open(draftPath); resources.defer(() => dw.dispose());
    const module = new MtpModule(dw, await loadModelConfig(draftPath), resources);
    const provider = await QwenMtpProvider.load(draftPath); resources.defer(() => provider.dispose());
    const H = model.config.text.hiddenSize;
    const kvBits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
    const maintain = createKvMaintenance(kvBits ? { kvBits, kvGroupSize: 64, quantizedKvStart: 0 } : {});
    const target = { hiddenSize: H, layerCount: model.layers.length,
      embed: model.embed.encode.bind(model.embed), logitsFromHidden: model.logitsFromHidden.bind(model) };
    const forward = (ids: Array, caches: Cache[]) => {
      const captured = new Map<number, Array>();
      const layer = model.layers.length - 1;
      const previous = model.hiddenTap;
      model.hiddenTap = { layers: new Set([layer]), captured };
      try {
        using hidden = model.forwardHidden(ids, caches);
        const logits = model.logitsFromHidden(hidden);
        const context = captured.get(layer)!; captured.delete(layer);
        return { logits, context };
      } finally { model.hiddenTap = previous; for (const array of captured.values()) array.dispose(); }
    };
    const prompts = [[1, 2, 3], [11, 12, 13, 14, 15, 16, 17],
      [21, 22, 23, 24, 25], [31, 32, 33, 34, 35, 36, 37, 38, 39]];
    const seeds: Cache[][] = [], sources: InstanceType<typeof QwenMtpSource>[] = [];
    const pending: number[] = [];
    try {
      for (const prompt of prompts) {
        const caches = model.makeCache(); seeds.push(caches);
        using ids = ops.fromInt32(prompt, [1, prompt.length]);
        const output = forward(ids, caches);
        using logits = output.logits;
        using tail = logits.slice([0, prompt.length - 1, 0], [1, prompt.length, logits.shape[2]!]);
        using token = ops.argmaxAxis(tail, -1); pending.push(token.toIntTokens()[0]!);
        const source = new QwenMtpSource(target, module, makeSampler({ temperature: 0 })); sources.push(source);
        await source.prefill(prompt, output.context);
        maintain(caches);
      }
      const merged = (B: number): RowCache[] => seeds[0]!.map((_, layer) => {
        const caches = seeds.slice(0, B).map(state => state[layer]!);
        if (caches[0] instanceof SSMCache) {
          let result: InstanceType<typeof SSMCache> | null = null;
          for (const cache of caches) {
            const source = cache as InstanceType<typeof SSMCache>, copy = new SSMCache();
            copy.conv = ops.copyOf(source.conv!); copy.recurrent = ops.copyOf(source.recurrent!); copy.offset = source.offset;
            try { const next = SSMCache.mergeRows(result, copy); result?.dispose(); result = next; }
            finally { copy.dispose(); }
          }
          return result!;
        }
        const result = caches[0] instanceof QuantizedKVCache
          ? new BatchedQuantizedKVCache(caches[0].groupSize, caches[0].bits) : new BatchedKVCache();
        result.mergeRows(caches); return result;
      });
      const stateDigest = (caches: Cache[], row: number) => caches.map(cache => {
        if (cache instanceof SSMCache) {
          const rowHash = (array: Array) => { const lo = array.shape.map(() => 0), hi = [...array.shape];
            lo[0] = row; hi[0] = row + 1; using view = array.slice(lo, hi); return digest(view); };
          return [cache.offsets?.[row] ?? cache.offset, rowHash(cache.conv!), rowHash(cache.recurrent!)];
        }
        const owned = cache instanceof BatchedKVCache || cache instanceof BatchedQuantizedKVCache
          ? cache.extractRow(row) : null;
        const kv = owned ?? cache as InstanceType<typeof KVCache> | InstanceType<typeof QuantizedKVCache>;
        const view = kv.temporalView();
        const tensors = view.flatMap(value => value instanceof MlxArray
          ? [value] : [value.packed, value.scales, value.biases]);
        try { return [kv.offset, ...tensors.map(digest)]; }
        finally { for (const array of tensors) array.dispose(); owned?.dispose(); }
      });
      const cases = variable ? [[3, false], [3, true]] as const : [[0, false], [1, false], [2, false], [4, false], [2, true]] as const;
      for (const B of variable ? [4] : [1, 2, 4]) for (const [depth, seeded] of cases) {
        console.error(JSON.stringify({ B, depth, seeded, kvBits }));
        const stateRows = new MlxStateRows(seeds[0]!.map(cache => cache instanceof SSMCache
          ? new BatchedSSMCache() : cache instanceof QuantizedKVCache
          ? new BatchedQuantizedKVCache(cache.groupSize, cache.bits) : new BatchedKVCache()));
        const actual = stateRows.caches, reference = B === 1 ? cloneKvCaches(seeds[0]!) : merged(B);
        const samplers = () => prompts.slice(0, B).map((prompt, row) => makeStepSampler(seeded
          ? { temperature: 0.7, topK: 20, topP: 0.9, seed: 101 + row } : { temperature: 0 }, {
          tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
          initialHistory: prompt, captureSelectedLogprob: true, captureTopLogprobs: 2,
        }));
        const sampling = samplers(), controls = samplers();
        const draftSampling = prompts.slice(0, B).map((_, row) => makeSampler(seeded
          ? { temperature: 0.7, topK: 20, topP: 0.9, seed: 101 + row } : { temperature: 0 }));
        let members = Array.from({ length: B }, (_, row) => row);
        const sampleRows = (lp: Array, steps: readonly number[]) => {
          const tokens: Array[] = [];
          try { for (let row = 0; row < members.length; row++) {
            using scores = lp.slice([row, 0], [row + 1, lp.shape[1]!]);
            tokens.push(draftSampling[members[row]!]!(scores, steps[row]!));
          } return ops.concatAxis(tokens, 0); } finally { for (const token of tokens) token.dispose(); }
        };
        const attachments = sources.slice(0, B).map((source, row) => source.checkpoint.capture(prompts[row]!.length));
        const draftSeeds = attachments.map((attachment, row) => {
          const cache = new KVCache(); cache.restoreState(attachment.tensors[0]!, attachment.tensors[1]!, prompts[row]!.length - 1);
          return { cache, hidden: attachment.tensors[2]! };
        });
        const checkpoints = attachments.map((attachment, row) => ({ attachment, processedTokens: prompts[row]!.length }));
        const draft = provider.grouped.open({ target: { identity: model, qwenMtp: target },
          sampling: { sample: sampleRows }, checkpoints: [] });
        const limitProposals = (proposals: number[][]) => variable ? proposals.map((tokens, row) =>
          tokens.slice(0, Math.floor(row * depth / (proposals.length - 1)))) : proposals;
        const proposer = {
          async draft(...args: Parameters<typeof draft.draft>) { return limitProposals(await draft.draft(...args)); },
          commit: draft.commit.bind(draft),
        };
        for (let row = 0; row < B; row++) applyStateChanges([
          () => stateRows.prepareAppend(seeds[row]!),
          () => draft.prepareAppend([checkpoints[row]!]),
        ]);
        expect(draft.rowCount).toBe(B);
        const old = B === 1 ? new QwenMtpSource(target, module, draftSampling[0]!) : null;
        old?.checkpoint.restore(prompts[0]!.length, attachments[0]!);
        const host = B > 1 ? new QwenMtpRows(target, module, { sample(lp, steps) {
          using token = sampleRows(lp, steps); return ops.fromInt32(token.toIntTokens(), [members.length]);
        } }, draftSeeds) : null;
        for (const state of draftSeeds) { state.cache.dispose(); state.hidden.dispose(); }
        const current = pending.slice(0, B), steps = current.map(() => 1), lengths = prompts.slice(0, B).map(p => p.length);
        try {
          for (let round = 0; round < 3; round++) {
            const delivered: number[][] = current.map(() => []);
            const completed = await advanceSpeculativeOutputs(current.map((token, row) => ({ pending: token,
              step: steps[row]!, remaining: 100, eosTokenIds: [], sampling: sampling[row]!,
              output: { async commit(ids) {
                delivered[row]!.push(...ids);
                if (round === 2 && row % 2 === 0) return false;
              } },
            })), depth, proposer, {
              transaction: bindRowCacheRollback(actual, B), async forward(ids) { return forward(ids, actual); },
            });
            const result = completed.rounds;
            // The independent request producer cannot advance a zero-draft
            // round. Its depth-one proposal supplies the same pending KV
            // row; discard the proposal and retain zero accepted inputs.
            const controlDepth = Math.max(1, depth);
            const controlDrafts = host ? host.draft(current, controlDepth, steps)
              : [await old!.draft([current[0]!], controlDepth, steps[0]!)];
            const proposals = depth ? limitProposals(controlDrafts) : current.map(() => []);
            expect(result.map(row => row.drafts)).toEqual(proposals);
            // Use a different right-padding token from the candidate. Causal
            // logits and the committed prefixes must not depend on its value.
            using ids = ops.fromInt32(proposals.flatMap((tokens, row) =>
              Array.from({ length: depth + 1 }, (_, column) => column ? tokens[column - 1] ?? 0 : current[row]!)), [B, depth + 1]);
            const tx = B === 1 ? bindCacheRollback(reference) : null;
            const rtx = B > 1 ? bindRowCacheRollback(reference as RowCache[], B) : null;
            tx?.begin(depth); rtx?.begin(depth);
            const output = forward(ids, reference);
            using logits = output.logits; using context = output.context;
            const accepted: number[] = [];
            for (let row = 0; row < B; row++) {
              const emitted: number[] = [], metadata = []; let kept = 0;
              for (let position = 0; position <= proposals[row]!.length; position++) {
                using view = logits.slice([row, position, 0], [row + 1, position + 1, logits.shape[2]!]);
                using scores = ops.reshape(view, [1, logits.shape[2]!]);
                const sample = await controls[row]!.sample(scores, steps[row]! + emitted.length);
                emitted.push(sample.token); metadata.push(readStepExtras(sample.extras));
                if (position === proposals[row]!.length || sample.token !== proposals[row]![position]) break;
                kept++;
              }
              accepted.push(kept);
              expect(result[row]!.acceptance.accepted).toBe(kept);
              expect(result[row]!.acceptance.emitted).toEqual(emitted);
              expect(result[row]!.logprobs).toEqual(metadata);
              current[row] = emitted.at(-1)!; steps[row]! += emitted.length;
            }
            // On the final round, even-numbered consumers stop after their
            // first delivered token. Other requests continue. Resolve both
            // stores to the published prefix without another target forward.
            const retained = accepted.map((count, row) => round === 2 && row % 2 === 0 ? Math.min(count, 1) : count);
            expect(completed.outputs.map(row => row.accepted)).toEqual(retained);
            for (let row = 0; row < B; row++) expect(delivered[row]).toEqual(
              round === 2 && row % 2 === 0 ? result[row]!.acceptance.emitted.slice(0, 1) : result[row]!.acceptance.emitted);
            for (let row = 0; row < B; row++) lengths[row]! += retained[row]! + 1;
            tx?.resolve(retained[0]!); rtx?.resolve(retained);
            if (old) await old.commit(controlDepth, retained[0]!, ops.copyOf(context), undefined, proposals[0]!.slice(0, retained[0]!));
            host?.commit(retained, context);
            for (let row = 0; row < B; row++) {
              expect(stateDigest(actual, row)).toEqual(stateDigest(reference, row));
              const state = draft.capture(row);
              const expected = host?.extractRow(row);
              const tensors = expected ? [...expected.cache.temporalView(), expected.hidden]
                : old!.checkpoint.capture(lengths[row]!).tensors;
              try {
                expect(state.processedTokens).toBe(lengths[row]!);
                expect(state.attachment.tensors.map(digest)).toEqual(tensors.map(digest));
              } finally { for (const tensor of state.attachment.tensors) tensor.dispose(); expected?.cache.dispose();
                for (const tensor of tensors) tensor.dispose(); }
            }
          }
          if (B > 1) {
            // Retire the consumers that stopped, then advance the survivors
            // at the smaller B. Sampler identity follows the request through
            // compaction; model/state code sees only its new row positions.
            const keep = members.filter(row => row % 2 === 1);
            stateRows.filterRows(keep); draft.filterRows(keep);
            for (const cache of reference as RowCache[]) cache.filterRows(keep);
            host!.filterRows(keep); members = keep;
            // Re-admit committed outputs through the provider interface.
            // Checkpoints outlive group storage and retain exact coverage.
            const checkpoints = members.map((_, row) => draft.capture(row));
            const raw = members.map((_, row) => host!.extractRow(row));
            try {
              for (let row = 0; row < members.length; row++) {
                expect(checkpoints[row]!.processedTokens).toBe(raw[row]!.cache.offset + 1);
                expect(checkpoints[row]!.attachment.tensors.map(digest)).toEqual(
                  [raw[row]!.cache.keys!, raw[row]!.cache.values!, raw[row]!.hidden].map(digest));
              }
              // Extraction removes old padding. Rebuild the raw-state control
              // too, so the next graph sees identical attention geometry.
              draft.filterRows([]); host!.filterRows([]);
              draft.append(checkpoints); host!.append(raw);
            } finally {
              for (const checkpoint of checkpoints) for (const tensor of checkpoint.attachment.tensors) tensor.dispose();
              for (const state of raw) { state.cache.dispose(); state.hidden.dispose(); }
            }
            const live = members.map(row => ({ pending: current[row]!, step: steps[row]!, remaining: 100,
              eosTokenIds: [], sampling: sampling[row]! }));
            const N = members.length;
            const resumed = await advanceSpeculativeOutputs(live.map(row => ({ ...row,
              output: { async commit() {} },
            })), depth, proposer, {
              transaction: bindRowCacheRollback(actual, N), async forward(ids) { return forward(ids, actual); },
            });
            const controlDrafts = host!.draft(live.map(row => row.pending), Math.max(1, depth), live.map(row => row.step));
            const proposals = depth ? limitProposals(controlDrafts) : live.map(() => []);
            expect(resumed.rounds.map(row => row.drafts)).toEqual(proposals);
            using ids = ops.fromInt32(proposals.flatMap((tokens, row) =>
              Array.from({ length: depth + 1 }, (_, column) => column ? tokens[column - 1] ?? 0 : live[row]!.pending)), [N, depth + 1]);
            const tx = bindRowCacheRollback(reference as RowCache[], N); tx.begin(depth);
            const verified = forward(ids, reference);
            using logits = verified.logits; using context = verified.context;
            const control = await sampleSpeculativeRows(live.map((row, index) => ({ ...row,
              sampling: controls[members[index]!]! })), proposals, logits);
            const retained = control.map(row => row.acceptance.accepted);
            tx.resolve(retained); host!.commit(retained, context);
            expect(resumed.rounds.map(row => row.acceptance.emitted)).toEqual(control.map(row => row.acceptance.emitted));
            expect(resumed.rounds.map(row => row.logprobs)).toEqual(control.map(row => row.logprobs));
            for (let row = 0; row < N; row++) {
              expect(stateDigest(actual, row)).toEqual(stateDigest(reference, row));
              const state = draft.capture(row), expected = host!.extractRow(row);
              try {
                expect(state.processedTokens).toBe(expected.cache.offset + 1);
                expect(state.attachment.tensors.map(digest)).toEqual(
                  [expected.cache.keys!, expected.cache.values!, expected.hidden].map(digest));
              } finally { for (const tensor of state.attachment.tensors) tensor.dispose(); expected.cache.dispose(); expected.hidden.dispose(); }
            }
          }
        } finally { stateRows.dispose(); dispose(reference); draft.dispose(); old?.dispose(); host?.dispose();
          for (const sampler of [...sampling, ...controls]) sampler.dispose(); clearCache(); }
      }
    } finally { for (const state of seeds) dispose(state); for (const source of sources) source.dispose(); clearCache(); }
  }, 240000);
});
