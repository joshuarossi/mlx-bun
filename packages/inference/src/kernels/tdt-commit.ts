import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
/** Commit recurrence only for valid nonblank predictions, apply the TDT symbol
 * cap, and keep the next gather index in bounds after the final frame. */
export class TdtCommitKernel {
  readonly #kernel = new MetalKernel({
    name: "mlx_bun_tdt_commit",
    inputNames: [
      "pred",
      "dur",
      "control",
      "limit",
      "h0",
      "h1",
      "c0",
      "c1",
      "nh0",
      "nh1",
      "nc0",
      "nc1",
    ],
    outputNames: ["oh0", "oh1", "oc0", "oc1", "next", "record"],
    source: String.raw`
      const uint i = thread_position_in_grid.x;
      const int time = control[0], token = int(pred[0]), duration = int(dur[0]);
      const bool valid = time < limit[0], emit = valid && token != 8192;
      if (i < 640) {
        oh0[i] = emit ? nh0[i] : h0[i]; oh1[i] = emit ? nh1[i] : h1[i];
        oc0[i] = emit ? nc0[i] : c0[i]; oc1[i] = emit ? nc1[i] : c1[i];
      }
      if (i == 0) {
        const int symbols = control[2] + 1;
        const bool cap = duration == 0 && symbols >= 10;
        const int time_next = valid ? time + duration + int(cap) : time;
        next[0] = time_next; next[1] = emit ? token : control[1];
        next[2] = duration != 0 || cap ? 0 : symbols;
        next[3] = metal::min(time_next, limit[0] - 1);
        record[0] = emit ? token : -1; record[1] = time; record[2] = duration;
      }
    `,
  });
  apply(inputs: MlxArray[]): MlxArray[] {
    return this.#kernel.apply(inputs, {
      outputs: [
        ...Array.from({ length: 4 }, () => ({
          shape: [1, 640],
          dtype: inputs[4]!.dtype,
        })),
        { shape: [4], dtype: Dtype.int32 },
        { shape: [3], dtype: Dtype.int32 },
      ],
      grid: [640, 1, 1],
      threadGroup: [128, 1, 1],
    });
  }
  dispose(): void {
    this.#kernel.dispose();
  }
}
