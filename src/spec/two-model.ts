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
import { flagOn } from "../runtime-config";
import { loadModelConfig } from "../config";
import { Weights } from "../weights";
import { createModel, type RuntimeModel } from "../model/factory";
import type { Cache } from "../model/gemma4";
import { toLogprobs } from "../sampler";
import type { DraftProvider, DraftSource } from "./source";

/** mlx-lm's prefill_step_size — the draft drain chunks at the same stride
 *  as the target's (serve-loop.ts); chunking is numerically exact for
 *  causal attention. */
const PREFILL_CHUNK = 2048;

export class TwoModelProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;

  private constructor(
    readonly model: RuntimeModel,
    private readonly weights: Weights,
    id: string,
  ) {
    this.id = id;
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
    const model = createModel(weights, config);
    if (
      targetVocabSize !== undefined &&
      config.text.vocabSize !== targetVocabSize
    )
      console.warn(
        `draft model vocab size ${config.text.vocabSize} != target ${targetVocabSize} — ` +
          `speculation will accept nothing useful (mlx-lm warns identically)`,
      );
    return new TwoModelProvider(model, weights, modelDir.split("/").filter(Boolean).at(-1)!);
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new TwoModelSource(this.model, opts.sampler);
  }

  dispose(): void {
    this.weights.dispose();
  }
}

class TwoModelSource implements DraftSource {
  readonly weightsBytes = 0; // provider-owned weights; per-request adds caches only
  private caches: Cache[];

  constructor(
    private readonly model: RuntimeModel,
    private readonly sampler: (lp: MlxArray, step: number) => MlxArray,
  ) {
    this.caches = this.model.makeCache();
  }

  prefill(promptIds: number[]): void {
    // Oracle convention (mlx-lm speculative_generate_step._prefill, re-anchored
    // 2026-07-07): the DRAFT model also drains only to len-1 (`while y.size >
    // 1`) — the last prompt token stays unprocessed and is consumed by the
    // FIRST draft() round's feed ([pending] = that same token under the serve
    // loop's oracle shape), mirroring _draft_generate's first _step. Draft-side
    // full-prefill was the residual knife-edge flipper in the 2026-07-07 live
    // oracle gate (γ=2 haiku cell). MLX_BUN_PREFILL_TAIL_SPLIT=0 reverts.
    // (mlx-lm chunks its drain at prefill_step_size=2048; chunking is
    // numerically exact for causal attention — same KV, same positions —
    // so we chunk too. Pre-2026-07-07 this was a SINGLE forward of the
    // whole head: nothing enforced the "<2048 serve regime" the old
    // comment assumed, and a 32k prompt through the spec lane ran one
    // 32k-position draft forward — a large activation/mask transient on a
    // 24 GB box, and untested numerics vs the chunked oracle.)
    const tailSplit = flagOn("MLX_BUN_PREFILL_TAIL_SPLIT", true);
    const upTo = tailSplit && promptIds.length > 1 ? promptIds.length - 1 : promptIds.length;
    for (let at = 0; at < upTo; at += PREFILL_CHUNK) {
      const end = Math.min(at + PREFILL_CHUNK, upTo);
      const ids = ops.fromInt32(promptIds.slice(at, end), [1, end - at]);
      const h = this.model.forwardHidden(ids, this.caches);
      ids.dispose();
      // The head's last-position logits are not needed: the serve loop's
      // first `feed` is consumed at the top of draft().
      h.dispose();
      clearCache();
    }
  }

  /** One forward over `feed`, sample the first draft from its last position,
   *  then n-1 single-token steps — mirrors _draft_generate's autoregressive
   *  chain (with async_eval pipelining upstream; eager here, the draft is
   *  small and the serve loop overlaps nothing with it in v1). */
  draft(feed: number[], n: number, stepBase: number): number[] {
    const drafts: number[] = [];
    let input = feed;
    for (let k = 0; k < n; k++) {
      const ids = ops.fromInt32(input, [1, input.length]);
      const h = this.model.forwardHidden(ids, this.caches);
      ids.dispose();
      const L = h.shape[1]!;
      const H = h.shape[2]!;
      const hLast = h.slice([0, L - 1, 0], [1, L, H]);
      h.dispose();
      const logits = this.model.logitsFromHidden(hLast);
      hLast.dispose();
      const V = logits.shape[logits.shape.length - 1]!;
      const flat = ops.reshape(logits, [1, V]);
      logits.dispose();
      const lp = toLogprobs(flat);
      flat.dispose();
      const tokArr = this.sampler(lp, stepBase + k);
      lp.dispose();
      const tok = ops.itemUint32(tokArr);
      tokArr.dispose();
      drafts.push(tok);
      input = [tok];
    }
    return drafts;
  }

  commit(n: number, kAccept: number): void {
    const rewind = Math.max(n - kAccept - 1, 0);
    if (rewind > 0) {
      for (const c of this.caches) {
        if (!c.isTrimmable()) {
          // The serve loop stops speculating on the TARGET-side trim check
          // before this can matter; a wrapped draft ring here just means the
          // source is done being useful. Recreate is the safe recovery.
          this.resetCaches();
          return;
        }
        c.trim(rewind);
      }
    }
  }

  private resetCaches(): void {
    for (const c of this.caches) c.dispose();
    this.caches = this.model.makeCache();
  }

  dispose(): void {
    for (const c of this.caches) c.dispose();
  }
}
