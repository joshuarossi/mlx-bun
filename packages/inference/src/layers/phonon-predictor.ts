import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Phonon2Weights } from "../artifacts/phonon2";
import { LstmCell } from "./lstm-cell";
import { DenseLinear } from "./dense-linear";
import type { TdtState } from "../contracts/mlx/tdt";

export class PhononPredictor {
  readonly #embedding: MlxArray;
  readonly #cells: LstmCell[] = [];
  readonly #biases: MlxArray[] = [];
  constructor(w: Phonon2Weights) {
    try {
      this.#embedding = w.tensor("decoder.embedding.weight");
      for (let i = 0; i < 2; i++) {
        const p = "decoder.lstm";
        const bih = w.tensor(`${p}.bias_ih_l${i}`, undefined, Dtype.float32),
          bhh = w.tensor(`${p}.bias_hh_l${i}`, undefined, Dtype.float32);
        using sum = ops.add(bih, bhh);
        using half = sum.astype(Dtype.float16);
        const bias = half.astype(Dtype.bfloat16);
        this.#biases.push(bias);
        this.#cells.push(
          new LstmCell(
            w.tensor(`${p}.weight_ih_l${i}`),
            w.tensor(`${p}.weight_hh_l${i}`),
            bias,
          ),
        );
      }
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  forward(index: MlxArray, state: TdtState): TdtState {
    using embedded = ops.takeAxis(this.#embedding, index, 0);
    using blank = MlxArray.fromInt32(new Int32Array([8192]), [1]);
    using isBlank = ops.equal(index, blank);
    using zero = ops.zeros([1, 640], Dtype.bfloat16);
    using input = ops.where(isBlank, zero, embedded);
    const h: MlxArray[] = [],
      c: MlxArray[] = [];
    try {
      for (let i = 0; i < this.#cells.length; i++) {
        const [hi, ci] = this.#cells[i]!.forward(
          i ? h[i - 1]! : input,
          state.h[i]!,
          state.c[i]!,
        );
        h.push(hi);
        c.push(ci);
      }
      return { h, c };
    } catch (error) {
      for (const a of [...h, ...c]) a.dispose();
      throw error;
    }
  }
  dispose(): void {
    for (const cell of this.#cells) cell.dispose();
    for (const bias of this.#biases) bias.dispose();
  }
}
/** Encoder and predictor project into the same joint space; head predicts
 * vocabulary+blank followed by the five duration logits. */
export class PhononJoint {
  readonly encoder: DenseLinear;
  readonly #predictor: DenseLinear;
  readonly #head: DenseLinear;
  constructor(w: Phonon2Weights) {
    const linear = (p: string) =>
      new DenseLinear(w.tensor(p + ".weight"), w.tensor(p + ".bias"));
    try {
      this.encoder = linear("encoder_projector");
      this.#predictor = linear("decoder.decoder_projector");
      this.#head = linear("joint.head");
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  forward(encoded: MlxArray, prediction: MlxArray): MlxArray {
    using p = this.#predictor.forward(prediction);
    using sum = ops.add(encoded, p);
    using zero = ops.scalarLike(0, sum);
    using act = ops.maximum(sum, zero);
    return this.#head.forward(act);
  }
  dispose(): void {
    this.encoder?.wT.dispose();
    this.#predictor?.wT.dispose();
    this.#head?.wT.dispose();
  }
}
