// Two-model speculative drafting — mlx-lm parity (`mlx_lm.server
// --draft-model`). A full second model drafts autoregressively; the serve
// loop (src/spec/serve-loop.ts) verifies with the target. L1 oracle:
// mlx_lm.server with the same target/draft pair, greedy, token-for-token
// (spec-vs-spec — both batch the verify lm-head, so neither is bit-exact to
// stock decode at knife-edges; see src/spec/generate.ts header).
//
// Faithfulness notes (read from the oracle venv's generate.py):
//  - drafts are sampled with the REQUEST sampler (generate.py:593-601) —
//    greedy drafting under a temperature>0 request is not parity;
//  - draft-cache rewind is max(n - kAccept - 1, 0) (generate.py:589-591),
//    with the all-accept re-feed of the last draft handled by the serve
//    loop's `feed` (generate.py:645-648);
//  - logits processors do NOT run on draft steps (they're target-side).

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { clearCache } from "../mlx/ffi";
import { runtimeFlag } from "../runtime-config";
import { loadModelConfig } from "../config";
import { Weights } from "../weights";
import { createModel, type RuntimeModel } from "../model/factory";
import type { DraftProvider, DraftSource, GroupedDraftProvider } from "./source";
import { standaloneDraftGroups, openStandaloneDraftRows } from "./two-model-rows";
import { bindLegacyAutoregressiveModel } from "../backends/mlx/autoregressive";
import { artifactIdentity } from "../model/artifact-identity";
import { configFingerprint } from "../model/fingerprint";

/** mlx-lm's prefill_step_size — the draft drain chunks at the same stride
 *  as the target's (serve-loop.ts); chunking is numerically exact for
 *  causal attention. */
const PREFILL_CHUNK = 2048;

export class TwoModelProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  readonly grouped: GroupedDraftProvider;

  private constructor(
    readonly model: RuntimeModel,
    private readonly weights: Weights,
    id: string,
    private readonly namespace: string,
  ) {
    this.id = id;
    this.grouped = standaloneDraftGroups(bindLegacyAutoregressiveModel(model), namespace);
    this.weightsBytes = [...weights.shards.files.values()].reduce(
      (a, f) => a + f.mmap.size,
      0,
    );
  }

  /** Load the draft model from a snapshot dir. Vocab-size mismatch with the
   *  target is a WARNING (mlx-lm parity, server.py:363-368); the tokenizer-
   *  family hard check lives at the server (it owns both tokenizers). */
  static async load(modelDir: string, targetVocabSize?: number): Promise<TwoModelProvider> {
    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    try {
      const model = createModel(weights, config);
      if (
        targetVocabSize !== undefined &&
        config.text.vocabSize !== targetVocabSize
      )
        console.warn(
          `draft model vocab size ${config.text.vocabSize} != target ${targetVocabSize} — ` +
            `speculation will accept nothing useful (mlx-lm warns identically)`,
        );
      const identity = await artifactIdentity(configFingerprint(config),
        [...weights.shards.files].map(([name, shard]) => ({ name, path: shard.path })));
      return new TwoModelProvider(model, weights, modelDir.split("/").filter(Boolean).at(-1)!,
        `standalone-draft-v1:${identity}`);
    } catch (error) { weights.dispose(); throw error; }
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new TwoModelSource(this.model, opts.sampler, this.namespace);
  }

  dispose(): void {
    this.weights.dispose();
  }
}

/** Compatibility adapter: the existing request loop also uses the shared
 * draft graph at B=1. Proposal generation and state recovery have one owner. */
class TwoModelSource implements DraftSource {
  readonly weightsBytes = 0;
  private readonly rows: ReturnType<typeof openStandaloneDraftRows>;
  private processed = 0;
  constructor(model: RuntimeModel, sampler: (lp: MlxArray, step: number) => MlxArray, namespace: string) {
    this.rows = openStandaloneDraftRows(bindLegacyAutoregressiveModel(model), namespace,
      { sample: (logprobs, steps) => sampler(logprobs, steps[0]!) }, [null]);
  }
  async prefill(promptIds: number[]): Promise<void> {
    const tailSplit = runtimeFlag("MLX_BUN_PREFILL_TAIL_SPLIT", true);
    const upTo = tailSplit && promptIds.length > 1 ? promptIds.length - 1 : promptIds.length;
    for (let at = this.processed; at < upTo; at += PREFILL_CHUNK) {
      const end = Math.min(at + PREFILL_CHUNK, upTo);
      using ids = ops.fromInt32(promptIds.slice(at, end), [1, end - at]);
      await this.rows.prefill(ids); clearCache();
    }
    this.processed = upTo;
  }
  async draft(feed: number[], count: number, step: number): Promise<number[]> {
    return (await this.rows.draft([feed.at(-1)!], count, [step]))[0]!;
  }
  async commit(_drafted: number, accepted: number): Promise<void> {
    await this.rows.commit([accepted]);
    this.processed += accepted + 1;
  }
  dispose(): void { this.rows.dispose(); }
}
