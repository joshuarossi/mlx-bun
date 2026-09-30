import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { DecodeStepInputs } from "../contracts/mlx/cache";

/** The per-step arrays a cache assembles its compiled-decode closure inputs from.
 *  Everything it creates is pushed onto `temps`, which the caller releases after the step. */
export function decodeStepInputs(temps: MlxArray[]): DecodeStepInputs {
  const writePositions = new Map<number, MlxArray>();
  return {
    activeView(array, length) {
      const stop = [...array.shape];
      stop[2] = length;
      const view = array.slice(stop.map(() => 0), stop);
      temps.push(view);
      return view;
    },
    writePosition(position) {
      let a = writePositions.get(position);
      if (!a) {
        a = ops.fromInt32([position], [1]);
        writePositions.set(position, a);
        temps.push(a);
      }
      return a;
    },
  };
}
