import { Dtype } from "@mlx-bun/mlx/ffi";
import { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";
import { TdtCommitKernel } from "../kernels/tdt-commit";
import type { TdtDecodeState } from "../contracts/mlx/tdt";
import type { PhononPredictor, PhononJoint } from "./phonon-predictor";
/** Fixed-shape compiled predictor/joint/control step. Encoder length and all
 * request state remain dynamic inputs; one compile serves different clips. */
export class TdtGreedyStep {
  readonly #commit = new TdtCommitKernel();
  readonly #compiled: CompiledFunction;
  constructor(predictor: PhononPredictor, joint: PhononJoint) {
    try {
      this.#compiled = new CompiledFunction(
        ([frame, h0, h1, c0, c1, control, limit]) => {
          using token = control!.slice([1], [2]);
          const next = predictor.forward(token, {
            h: [h0!, h1!],
            c: [c0!, c1!],
          });
          try {
            using logits = joint.forward(frame!, next.h[1]!);
            using vocab = logits.slice([0, 0], [1, 8193]);
            using duration = logits.slice([0, 8193], [1, 8198]);
            using pred = ops.argmaxAxis(vocab, -1);
            using dur = ops.argmaxAxis(duration, -1);
            return this.#commit.apply([
              pred,
              dur,
              control!,
              limit!,
              h0!,
              h1!,
              c0!,
              c1!,
              ...next.h,
              ...next.c,
            ]);
          } finally {
            for (const a of [...next.h, ...next.c]) a.dispose();
          }
        },
        false,
      );
    } catch (error) {
      this.#commit.dispose();
      throw error;
    }
  }
  initialState(): TdtDecodeState {
    return {
      control: MlxArray.fromInt32(new Int32Array([0, 8192, 0, 0]), [4]),
      h: [
        ops.zeros([1, 640], Dtype.bfloat16),
        ops.zeros([1, 640], Dtype.bfloat16),
      ],
      c: [
        ops.zeros([1, 640], Dtype.bfloat16),
        ops.zeros([1, 640], Dtype.bfloat16),
      ],
    };
  }
  advance(
    encoded: MlxArray,
    state: TdtDecodeState,
    limit: MlxArray,
  ): { record: MlxArray; state: TdtDecodeState } {
    using index = state.control.slice([3], [4]);
    using selected = ops.takeAxis(encoded, index, 1);
    using frame = ops.reshape(selected, [1, 640]);
    const [h0, h1, c0, c1, control, record] = this.#compiled.apply([
      frame,
      ...state.h,
      ...state.c,
      state.control,
      limit,
    ]);
    return {
      record: record!,
      state: { h: [h0!, h1!], c: [c0!, c1!], control: control! },
    };
  }
  get traceCount(): number {
    return this.#compiled.traceCount;
  }
  dispose(): void {
    this.#compiled.dispose();
    this.#commit.dispose();
  }
}
