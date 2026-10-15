import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import type { MlxHeadForward, MlxSequenceForward } from "../contracts/mlx/graph";
import type { MlxPromptInput } from "../contracts/mlx/media";
import { logitsFromHiddenPadM, sequenceLogProbabilities } from "./response-logps";

/** The operations a closed-answer decision consumes. The graph and its weights
 * are borrowed; each call owns fresh state. No sampling or generation is required. */
export interface DecisionScoringGraph {
  makeCache(): Cache[];
  forward: MlxSequenceForward;
  logits: MlxHeadForward;
}

/** Teacher-forced conditional likelihoods for complete supplied answers.
 * Each forward reads [prompt; answer[:-1]]. Only hidden rows that predict answer
 * tokens reach the head: prompt targets are masked out. Average log p(token | prefix)
 * over each answer (negative mean NLL), then softmax across candidate averages. No vocabulary restriction
 * changes a token's likelihood. Include a terminator in each answer to score
 * complete, mutually exclusive responses (especially when one prefixes another).
 *
 * Inputs and graph are borrowed; every candidate gets fresh caches, released with
 * its intermediates on success, error or cancellation. The caller serializes
 * shared graph access. This is inference, with no training or reference model.
 * The average includes the terminator and excludes every prompt token. */
export async function scoreDecisionAnswers(graph: DecisionScoringGraph, prompt: readonly number[],
  candidates: readonly (readonly number[])[], options: { signal?: AbortSignal; input?: MlxPromptInput;
    /** Run one candidate's owned work at a scheduler boundary. Direct library
     * callers may omit this when they already own exclusive graph access. */
    execute?: <T>(work: () => Promise<T>) => Promise<T>;
  } = {}): Promise<{
    probabilities: number[]; meanLogLikelihoods: number[];
  }> {
  options.signal?.throwIfAborted();
  if (!prompt.length) throw new RangeError("a decision prompt must contain tokens");
  if (!candidates.length || candidates.some(answer => !answer.length || answer.some(id => !Number.isSafeInteger(id) || id < 0)))
    throw new RangeError("a decision requires nonempty candidate token sequences");
  const meanLogLikelihoods: number[] = [];
  for (const answer of candidates) {
    options.signal?.throwIfAborted();
    const score = await (options.execute ?? (work => work()))(async () => {
      options.signal?.throwIfAborted();
      const caches = graph.makeCache();
      try {
        const tokens = [...prompt, ...answer.slice(0, -1)];
        using ids = ops.fromInt32(tokens, [1, tokens.length]);
        using hidden = options.input ? mediaResponseHidden(options.input, prompt, answer, caches, options.signal)
          : graph.forward(ids, caches, tokens.length);
        const [batch, length, width] = hidden.shape;
        if (batch !== 1 || length !== (options.input ? answer.length : tokens.length) || !width)
          throw new Error("decision forward returned an invalid hidden shape");
        // Prediction at prompt.length - 1 targets answer[0], not prompt's last token.
        using response = hidden.slice([0, options.input ? 0 : prompt.length - 1, 0], [1, length, width]);
        using logits = logitsFromHiddenPadM({ logitsFromHidden: graph.logits }, response);
        const vocab = logits.shape.at(-1)!;
        if (answer.some(id => id >= vocab)) throw new RangeError("decision token id is outside the graph vocabulary");
        // The DPO reduction sees only supervised rows; equivalent to a zero mask
        // on all earlier prompt positions, without projecting them to vocabulary.
        using logp = sequenceLogProbabilities(logits, [[prompt.at(-1)!, ...answer]], [[0, ...answer.map(() => 1)]]);
        const score = logp.toFloat32()[0]! / answer.length;
        options.signal?.throwIfAborted();
        if (!Number.isFinite(score)) throw new Error("decision answer has a nonfinite log likelihood");
        return score;
      } finally {
        const errors: unknown[] = [];
        for (const cache of caches) { try { cache.dispose(); } catch (error) { errors.push(error); } }
        if (errors.length) throw new AggregateError(errors, "decision cache cleanup failed");
      }
    });
    meanLogLikelihoods.push(score);
    await new Promise<void>(resolve => setImmediate(resolve));
  }
  options.signal?.throwIfAborted();
  const maximum = Math.max(...meanLogLikelihoods), weights = meanLogLikelihoods.map(value => Math.exp(value - maximum));
  const total = weights.reduce((sum, value) => sum + value, 0);
  return { meanLogLikelihoods, probabilities: weights.map(value => value / total) };
}

/** Media ports expose the prompt tip and position-aware continuation. Feed
 * supplied answer tokens through those operations, collecting their prediction
 * rows; no sampling, generated ids, or generation state is involved. */
function mediaResponseHidden(input: MlxPromptInput, prompt: readonly number[], answer: readonly number[],
  caches: Cache[], signal?: AbortSignal): MlxArray {
  const rows: MlxArray[] = [];
  try {
    using ids = ops.fromInt32([...prompt], [1, prompt.length]);
    rows.push(input.prefill(ids, caches, 0, "tail", prompt.length));
    for (let i = 0; i < answer.length - 1; i++) {
      signal?.throwIfAborted();
      using token = ops.fromInt32([answer[i]!], [1, 1]);
      rows.push(input.prefill(token, caches, prompt.length + i, "decode", 1));
    }
    return ops.concatAxis(rows, 1);
  } finally { for (const row of rows) row.dispose(); }
}
