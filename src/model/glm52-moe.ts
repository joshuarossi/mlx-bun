// Exact GLM-5.2 noaux_tc routing and shared+routed MoE composition seams.
//
// The 256-way route decision is a deliberately bounded host correctness path:
// it preserves Colibri's float32 sigmoid, correction-bias ranking, and strict
// lower-ID tie behavior. Expert tensor arithmetic remains on MLX.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import {
  buildExpertBatchUnion,
  type ExpertUnionWave,
} from "../expert-residency";
import {
  routeTrueTopKF32,
  swiGluF32,
  type Glm52Route,
  type NumericVector,
  type SwiGluWeights,
} from "./glm52-reference";

export interface Glm52MoeRouterConfig {
  readonly topK: number;
  readonly normalize: boolean;
  readonly routedScale: number;
}

export interface Glm52RoutedExpertOutput<T> {
  readonly expertId: number;
  readonly output: T;
}

export interface Glm52MoeExpertJob {
  readonly expertId: number;
  readonly rows: Int32Array;
  readonly ranks: Int32Array;
  readonly weights: Float32Array;
}

export interface Glm52MoeBatchWave {
  readonly jobs: readonly Glm52MoeExpertJob[];
}

export interface Glm52MoeBatchPlan {
  readonly routes: readonly Glm52Route[];
  readonly waves: readonly Glm52MoeBatchWave[];
  readonly uniqueExperts: number;
}

function f32(value: number): number {
  return Math.fround(value);
}

function shapeEquals(left: MlxArray, right: MlxArray): boolean {
  const a = left.shape;
  const b = right.shape;
  return a.length === b.length && a.every((dimension, index) => dimension === b[index]);
}

/** Exact, bounded host route selection for the GLM noaux_tc router. */
export function routeGlm52MoeF32(
  logits: NumericVector,
  correctionBias: NumericVector,
  config: Glm52MoeRouterConfig,
): Glm52Route {
  return routeTrueTopKF32(
    logits,
    correctionBias,
    config.topK,
    config.normalize,
    config.routedScale,
  );
}

/**
 * Route flattened [batch,tokens] rows in order, then form the exact first-seen
 * expert union consumed by the global residency working bank.
 */
export function planGlm52MoeBatchF32(
  logitsByRow: readonly NumericVector[],
  correctionBias: NumericVector,
  config: Glm52MoeRouterConfig,
  maxUniquePerWave = 64,
): Glm52MoeBatchPlan {
  const routes = logitsByRow.map((logits) =>
    routeGlm52MoeF32(logits, correctionBias, config));
  const union: readonly ExpertUnionWave[] =
    buildExpertBatchUnion(routes, maxUniquePerWave);
  let uniqueExperts = 0;
  const waves = union.map((wave) => ({
    jobs: wave.entries.map((entry) => {
      uniqueExperts++;
      const rows = new Int32Array(entry.consumers.length);
      const ranks = new Int32Array(entry.consumers.length);
      const weights = new Float32Array(entry.consumers.length);
      for (let index = 0; index < entry.consumers.length; index++) {
        const consumer = entry.consumers[index]!;
        rows[index] = consumer.row;
        ranks[index] = consumer.rank;
        weights[index] = routes[consumer.row]!.executionWeights[consumer.rank]!;
      }
      return {
        expertId: entry.expertId,
        rows,
        ranks,
        weights,
      };
    }),
  }));
  return { routes, waves, uniqueExperts };
}

function validateRouteOutputs<T>(
  route: Glm52Route,
  routed: ReadonlyArray<Glm52RoutedExpertOutput<T>>,
): void {
  if (routed.length !== route.indices.length)
    throw new Error(`routed output count ${routed.length} != route count ${route.indices.length}`);
  for (let rank = 0; rank < routed.length; rank++) {
    if (routed[rank]!.expertId !== route.indices[rank]) {
      throw new Error(
        `routed output ${rank} expert ${routed[rank]!.expertId} != route ${route.indices[rank]}`,
      );
    }
  }
}

/**
 * Float32 oracle for the composition seam. Routed outputs are accumulated in
 * route order with raw-sigmoid-derived weights; the shared output is added
 * once, unweighted, after the routed sum.
 */
export function composeGlm52MoeOutputsF32(
  route: Glm52Route,
  routed: ReadonlyArray<Glm52RoutedExpertOutput<NumericVector>>,
  shared: NumericVector | null,
): Float32Array {
  validateRouteOutputs(route, routed);
  if (routed.length === 0 && shared === null)
    throw new Error("GLM MoE composition needs a routed or shared output");

  const width = routed[0]?.output.length ?? shared!.length;
  if (!Number.isSafeInteger(width) || width < 1)
    throw new Error("GLM MoE output width must be positive");
  const out = new Float32Array(width);
  for (let rank = 0; rank < routed.length; rank++) {
    const value = routed[rank]!.output;
    if (value.length !== width) throw new Error("routed expert output dimensions differ");
    const weight = route.executionWeights[rank]!;
    for (let index = 0; index < width; index++)
      out[index] = f32(out[index]! + f32(weight * value[index]!));
  }
  if (shared !== null) {
    if (shared.length !== width) throw new Error("shared expert output dimension differs");
    for (let index = 0; index < width; index++)
      out[index] = f32(out[index]! + shared[index]!);
  }
  return out;
}

/**
 * MLX composition path. Inputs remain caller-owned; returned output is owned by
 * the caller. The API intentionally accepts already-computed shared output so
 * the model can issue it in parallel with expert residency/I/O.
 */
export function composeGlm52MoeOutputsMlx(
  route: Glm52Route,
  routed: ReadonlyArray<Glm52RoutedExpertOutput<MlxArray>>,
  shared: MlxArray | null,
): MlxArray {
  validateRouteOutputs(route, routed);
  if (routed.length === 0 && shared === null)
    throw new Error("GLM MoE composition needs a routed or shared output");

  const exemplar = routed[0]?.output ?? shared!;
  for (const contribution of routed)
    if (!shapeEquals(contribution.output, exemplar))
      throw new Error("routed expert output dimensions differ");
  if (shared !== null && !shapeEquals(shared, exemplar))
    throw new Error("shared expert output dimension differs");

  let out: MlxArray | null = null;
  for (let rank = 0; rank < routed.length; rank++) {
    const scaled = ops.mulScalar(routed[rank]!.output, route.executionWeights[rank]!);
    if (out === null) {
      out = scaled;
    } else {
      const next = ops.add(out, scaled);
      out.dispose();
      scaled.dispose();
      out = next;
    }
  }
  if (shared !== null) {
    if (out === null) {
      // Return a new owned graph value, never an alias of the caller's input.
      out = ops.mulScalar(shared, 1);
    } else {
      const next = ops.add(out, shared);
      out.dispose();
      out = next;
    }
  }
  return out!;
}

/**
 * Tiny/reference execution seam: the caller resolves streamed experts by ID;
 * shared weights are passed independently so their work can later be issued
 * before routed expert loads complete.
 */
export function executeGlm52MoeReferenceF32(
  input: NumericVector,
  route: Glm52Route,
  routedExpert: (expertId: number) => SwiGluWeights,
  sharedExpert: SwiGluWeights | null,
): Float32Array {
  const routed = route.indices.map((expertId) => ({
    expertId,
    output: swiGluF32(input, routedExpert(expertId)),
  }));
  const shared = sharedExpert === null ? null : swiGluF32(input, sharedExpert);
  return composeGlm52MoeOutputsF32(route, routed, shared);
}
