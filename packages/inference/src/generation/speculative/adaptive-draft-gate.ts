/** Cost-aware speculative draft scheduler.
 *
 * Adapted from mlx-optiq 0.5.8's AcceptanceGate (MIT). The scheduler models
 * the expected emitted tokens for a proposal depth and divides that by the
 * measured cost of its verification forward. It uses acceptance rather than
 * observed wall-clock throughput as the online signal, so unrelated machine
 * load does not make it oscillate.
 */

export type VerifyCostModel = ReadonlyMap<number, number>;

function interpolatedCost(costs: VerifyCostModel, positions: number): number {
  const keys = [...costs.keys()].sort((a, b) => a - b);
  if (keys.length < 2 || !costs.has(1))
    throw new Error("adaptive draft costs need position 1 and at least one larger position");
  const exact = costs.get(positions);
  if (exact !== undefined) return exact;
  if (positions > keys.at(-1)!) {
    const hi = keys.at(-1)!;
    const lo = keys.at(-2)!;
    return costs.get(hi)! +
      ((costs.get(hi)! - costs.get(lo)!) / (hi - lo)) * (positions - hi);
  }
  const lo = keys.filter((key) => key < positions).at(-1)!;
  const hi = keys.find((key) => key > positions)!;
  return costs.get(lo)! +
    ((costs.get(hi)! - costs.get(lo)!) / (hi - lo)) * (positions - lo);
}

export interface AdaptiveDraftGateOptions {
  maxDraftTokens: number;
  /** Whether rejection requires replaying the accepted prefix. */
  replayOnReject?: boolean;
  priorAccepted?: number;
  priorRejected?: number;
  decay?: number;
  margin?: number;
}

export class AdaptiveDraftGate {
  #accepted: number;
  #rejected: number;
  readonly #decay: number;
  readonly #margin: number;
  readonly #maxDraftTokens: number;
  readonly #replayOnReject: boolean;

  constructor(readonly costs: VerifyCostModel, options: AdaptiveDraftGateOptions) {
    this.#maxDraftTokens = options.maxDraftTokens;
    this.#replayOnReject = options.replayOnReject ?? false;
    this.#accepted = options.priorAccepted ?? 3;
    this.#rejected = options.priorRejected ?? 2;
    this.#decay = options.decay ?? 0.85;
    this.#margin = options.margin ?? 0.03;
  }

  get acceptanceProbability(): number {
    return this.#accepted / Math.max(this.#accepted + this.#rejected, Number.EPSILON);
  }

  observe(accepted: number, rejected: number): void {
    this.#accepted = this.#accepted * this.#decay + accepted;
    this.#rejected = this.#rejected * this.#decay + rejected;
  }

  expectedRate(k: number, p = this.acceptanceProbability): number {
    let tokens = 0;
    let replay = 0;
    for (let accepted = 0; accepted < k; accepted++) {
      const probability = p ** accepted * (1 - p);
      tokens += (accepted + 1) * probability;
      if (this.#replayOnReject)
        replay += probability * interpolatedCost(this.costs, accepted + 1);
    }
    tokens += (k + 1) * p ** k;
    return tokens / (interpolatedCost(this.costs, k + 1) + replay);
  }

  choose(budget: number): number {
    const limit = Math.min(this.#maxDraftTokens, budget);
    let bestDepth = 0;
    let bestRate = 1 + this.#margin;
    for (let depth = 1; depth <= limit; depth++) {
      const rate = this.expectedRate(depth);
      if (rate > bestRate) {
        bestDepth = depth;
        bestRate = rate;
      }
    }
    return bestDepth;
  }
}
