import type { AutoregressiveGraph, GraphDescriptor, LogitSelection } from "../../inference/graph";
import type { MlxArray } from "../../mlx/array";

/** Structural input: generated and hand-written graphs need no union membership. */
export interface MlxGraphOperations<State> {
  forwardHidden(ids: MlxArray, state: State): MlxArray;
  forwardHiddenAsync?: (ids: MlxArray, state: State) => Promise<MlxArray>;
  logitsFromHidden(hidden: MlxArray): MlxArray;
}

/** Bind once. No array wrapper, await, readback, or synchronization is added
 * to synchronous forward calls. Existing quant-specific kernels stay inside
 * the supplied operations. This adapter does not take ownership of weights. */
export function bindMlxGraph<State>(
  operations: MlxGraphOperations<State>,
  descriptor: Omit<GraphDescriptor, "backend" | "graphAbi">,
): AutoregressiveGraph<MlxArray, State, MlxArray> {
  const forward = operations.forwardHiddenAsync
    ? operations.forwardHiddenAsync.bind(operations)
    : operations.forwardHidden.bind(operations);
  const project = operations.logitsFromHidden.bind(operations);
  return {
    descriptor: Object.freeze({ ...descriptor, backend: "mlx", graphAbi: "mlx-hidden-bsh-v1" }),
    forwardHidden: forward,
    projectLogits(hidden: MlxArray, selection: LogitSelection) {
      if (selection.type === "all") return project(hidden);
      const shape = hidden.shape;
      if (shape.length !== 3) throw new Error("MLX hidden state must have shape [batch, positions, width]");
      const [batch, positions, width] = shape as [number, number, number];
      const start = selection.type === "last" ? positions - 1 : selection.start;
      const end = selection.type === "last" ? positions : selection.end;
      if (!Number.isInteger(start) || !Number.isInteger(end) || start < 0 || end <= start || end > positions)
        throw new Error("invalid logits position selection");
      const selected = hidden.slice([0, start, 0], [batch, end, width]);
      try { return project(selected); } finally { selected.dispose(); }
    },
  };
}
