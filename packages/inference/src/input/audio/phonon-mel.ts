import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Slaney-normalized triangular bank, [257,128], for the Parakeet frontend. */
export function phononMelFilters(): Float32Array {
  const toMel = (f: number) =>
    f >= 1000 ? 15 + Math.log(f / 1000) / (Math.log(6.4) / 27) : f / (200 / 3);
  const toHz = (m: number) =>
    m >= 15 ? 1000 * Math.exp((m - 15) * (Math.log(6.4) / 27)) : m * (200 / 3);
  const hz = Array.from({ length: 130 }, (_, i) =>
      toHz((toMel(8000) * i) / 129),
    ),
    bank = new Float32Array(257 * 128);
  for (let m = 0; m < 128; m++)
    for (let k = 0; k < 257; k++) {
      const f = (16000 * k) / 512;
      bank[k * 128 + m] =
        (Math.max(
          0,
          Math.min(
            (f - hz[m]!) / (hz[m + 1]! - hz[m]!),
            (hz[m + 2]! - f) / (hz[m + 2]! - hz[m + 1]!),
          ),
        ) *
          2) /
        (hz[m + 2]! - hz[m]!);
    }
  return bank;
}
/** FP32 frontend, then bf16 activations: pre-emphasis, centered 512-point
 * STFT with a symmetric 400-point Hann window, 128 log-mels and unbiased
 * per-feature normalization. Matches Fermion's MLX frame rule (1+n/160). */
export class PhononMelExtractor {
  readonly #filters = MlxArray.fromFloat32(phononMelFilters(), [257, 128]);
  readonly #window: MlxArray;
  constructor() {
    const window = new Float32Array(512);
    for (let i = 0; i < 400; i++)
      window[56 + i] = 0.5 - 0.5 * Math.cos((2 * Math.PI * i) / 399);
    this.#window = MlxArray.fromFloat32(window, [512]);
  }
  logMel(samples: Float32Array): MlxArray {
    if (samples.length < 160)
      throw new Error("Phonon-2 needs at least 10 ms of audio");
    const frames = 1 + Math.floor(samples.length / 160);
    using audio = MlxArray.fromFloat32(samples, [samples.length]);
    using bf16 = audio.astype(Dtype.bfloat16);
    using wave = bf16.astype(Dtype.float32);
    using first = wave.slice([0], [1]);
    using rest = wave.slice([1], [samples.length]);
    using previous = wave.slice([0], [samples.length - 1]);
    using factor = ops.scalarLike(0.97, wave);
    using scaled = ops.mul(previous, factor);
    using emphasized = ops.sub(rest, scaled);
    using joined = ops.concatAxis([first, emphasized], 0);
    using padded = ops.pad(joined, [[256, 256]]);
    using strided = ops.asStrided(padded, [frames, 512], [160, 1]);
    using windowed = ops.mul(strided, this.#window);
    using fft = ops.rfft(windowed, 512, -1);
    using magnitude = ops.abs(fft);
    using power = ops.square(magnitude);
    using mel = ops.matmul(power, this.#filters);
    using guard = ops.scalarLike(2 ** -24, mel);
    using guarded = ops.add(mel, guard);
    using log = ops.log(guarded);
    using mean = ops.meanAxis(log, 0, true);
    using centered = ops.sub(log, mean);
    using squared = ops.square(centered);
    using total = ops.sumAxis(squared, 0, true);
    using count = ops.scalarLike(Math.max(1, frames - 1), total);
    using variance = ops.div(total, count);
    using std = ops.sqrt(variance);
    using eps = ops.scalarLike(1e-5, std);
    using denominator = ops.add(std, eps);
    using normalized = ops.div(centered, denominator);
    using cast = normalized.astype(Dtype.bfloat16);
    return ops.reshape(cast, [1, frames, 128]);
  }
  dispose(): void {
    this.#filters.dispose();
    this.#window.dispose();
  }
}
