// MOSSImageScheduler (the snapshot's pipeline_moss_image.py): a shifted
// flow-matching grid snapped to the nearest noise level of the training grid,
// then diffusers' FlowMatchEulerDiscreteScheduler with no further shift and a
// terminal 0. Every value is computed with float32 rounding at the reference's
// operation boundaries (torch.linspace's two-sided float32 recurrence, the
// float32 shift, searchsorted and the nearest-neighbour test), so the levels
// equal the reference's bit for bit.

import type { FlowMatchingSchedule } from "../../contracts/mlx/image-generation";

const f32 = Math.fround;

/** torch.linspace(start, end, count) in float32 (CPU kernel: the step in float32,
 * the first half counted up from start, the second half down from end). */
function linspace(start: number, end: number, count: number): Float32Array {
  const out = new Float32Array(count);
  if (count === 1) { out[0] = start; return out; }
  const s = f32(start), e = f32(end);
  const step = f32(f32(e - s) / (count - 1));
  const halfway = Math.floor(count / 2);
  for (let i = 0; i < count; i++)
    out[i] = i < halfway ? f32(s + f32(step * i)) : f32(e - f32(step * (count - i - 1)));
  return out;
}

/** `shift * v / (1 + (shift - 1) * v)` over `linspace(1, shift / (total + shift - 1), count)`. */
function grid(count: number, shift: number, total: number): Float32Array {
  const values = linspace(1, shift / (total + shift - 1), count);
  const s = f32(shift), s1 = f32(shift - 1);
  return values.map(v => f32(f32(s * v) / f32(1 + f32(s1 * v))));
}

export interface MossImageScheduleConfig {
  readonly numTrainTimesteps: number;
  readonly shift: number;
  readonly trainingShift: number;
}

/** Reads `scheduler/scheduler_config.json`'s fields the schedule uses. */
export function parseMossImageScheduleConfig(raw: Record<string, unknown>): MossImageScheduleConfig {
  const numTrainTimesteps = raw.num_train_timesteps ?? 1000, shift = raw.shift ?? 5, trainingShift = raw.training_shift ?? 1;
  if (typeof numTrainTimesteps !== "number" || !Number.isInteger(numTrainTimesteps) || numTrainTimesteps < 2)
    throw new Error(`scheduler: num_train_timesteps must be an integer >= 2, got ${String(numTrainTimesteps)}`);
  if (typeof shift !== "number" || !(shift > 0)) throw new Error(`scheduler: shift must be positive, got ${String(shift)}`);
  if (typeof trainingShift !== "number" || !(trainingShift > 0))
    throw new Error(`scheduler: training_shift must be positive, got ${String(trainingShift)}`);
  return { numTrainTimesteps, shift, trainingShift };
}

export class MossImageSchedule implements FlowMatchingSchedule {
  readonly #training: Float32Array;

  constructor(readonly config: MossImageScheduleConfig) {
    this.#training = grid(config.numTrainTimesteps, config.trainingShift, config.numTrainTimesteps).reverse();
  }

  sigmas(steps: number): Float32Array {
    if (!Number.isInteger(steps) || steps < 1) throw new RangeError(`steps must be a positive integer, got ${steps}`);
    const training = this.#training, total = training.length;
    const levels: number[] = [];
    for (const sigma of grid(steps, this.config.shift, total)) {
      let upper = 0;
      while (upper < total && training[upper]! < sigma) upper++;
      upper = Math.min(upper, total - 1);
      const lower = Math.max(upper - 1, 0);
      const nearest = Math.abs(f32(sigma - training[lower]!)) <= Math.abs(f32(training[upper]! - sigma)) ? lower : upper;
      const level = training[nearest]!;
      if (levels.at(-1) !== level) levels.push(level);
    }
    levels.push(0);
    return Float32Array.from(levels);
  }

  timestep(sigma: number): number {
    return f32(f32(sigma) * this.config.numTrainTimesteps);
  }
}
