import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { Phonon2Weights } from "../../artifacts/phonon2";
import {
  PhononSubsampling,
  PhononConformerBlock,
  PhononRelativePositions,
} from "../../layers/phonon-conformer";
import { PhononPredictor, PhononJoint } from "../../layers/phonon-predictor";
import { TdtGreedyStep } from "../../layers/tdt-greedy";
import type { TdtGraph, TdtDecodeState } from "../../contracts/mlx/tdt";

/** The Phonon-2 graph: Metal palette expansion, position encoding, LSTM gates
 * and TDT state; MLX fp16 GEMM, convolution and relative attention. */
export class Phonon2Model implements TdtGraph {
  readonly dtype = Dtype.bfloat16;
  readonly blank = 8192;
  readonly durations = [0, 1, 2, 3, 4];
  readonly maxSymbols = 10;
  readonly frameSeconds = 0.08;
  readonly vocabulary: readonly string[];
  readonly #subsample: PhononSubsampling;
  readonly #blocks: PhononConformerBlock[] = [];
  readonly #predictor: PhononPredictor;
  readonly #joint: PhononJoint;
  readonly #decode: TdtGreedyStep;
  readonly #positions: PhononRelativePositions;
  constructor(readonly weights: Phonon2Weights) {
    const c = weights.config,
      e = c.encoder;
    if (
      e?.n_layers !== 24 ||
      e.d_model !== 1024 ||
      e.n_heads !== 8 ||
      e.subsampling_factor !== 8 ||
      e.conv_kernel_size !== 9 ||
      e.xscaling ||
      e.use_bias ||
      c.joint?.vocabulary?.length !== 8192 ||
      c.decoder?.prednet?.pred_hidden !== 640 ||
      c.decoder.prednet.pred_rnn_layers !== 2
    )
      throw new Error("Phonon-2: unsupported graph geometry");
    this.vocabulary = Object.freeze([...c.joint.vocabulary]);
    try {
      this.#positions = new PhononRelativePositions();
      this.#subsample = new PhononSubsampling(weights);
      this.#predictor = new PhononPredictor(weights);
      this.#joint = new PhononJoint(weights);
      this.#decode = new TdtGreedyStep(this.#predictor, this.#joint);
      for (let i = 0; i < 24; i++)
        this.#blocks.push(new PhononConformerBlock(weights, i));
      weights.finish();
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  get weightsBytes(): number {
    return (
      this.weights.residentBytes +
      this.#blocks.reduce((n, b) => n + b.weightBytes, 0)
    );
  }
  get decodeTraceCount(): number {
    return this.#decode.traceCount;
  }
  initialState(): TdtDecodeState {
    return this.#decode.initialState();
  }
  encode(mel: MlxArray): MlxArray {
    let x = this.#subsample.forward(mel);
    using positions = this.#positions.forward(x.shape[1]!);
    try {
      for (const block of this.#blocks) {
        const next = block.forward(x, positions);
        x.dispose();
        x = next;
      }
      return this.#joint.encoder.forward(x);
    } finally {
      x.dispose();
    }
  }
  advance(encoded: MlxArray, state: TdtDecodeState, maxLength: MlxArray) {
    return this.#decode.advance(encoded, state, maxLength);
  }
  dispose(): void {
    this.#decode?.dispose();
    this.#positions?.dispose();
    for (const b of this.#blocks) b.dispose();
    this.#subsample?.dispose();
    this.#predictor?.dispose();
    this.#joint?.dispose();
    this.weights.dispose();
  }
}
