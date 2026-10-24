// The pinned MFLUX schedule: build and snap in float64, then store the
// completed levels in float32. Timesteps multiply those stored levels in float32.
import type { FlowMatchingSchedule } from "../../contracts/mlx/image-generation";

const f32 = Math.fround;

function linspace(start: number, end: number, count: number): Float64Array {
  const values = new Float64Array(count);
  if (count === 1) { values[0] = start; return values; }
  const step = (end - start) / (count - 1);
  for (let i = 0; i < count; i++) values[i] = start + i * step;
  values[count - 1] = end;
  return values;
}

function grid(count: number, shift: number, total: number): Float64Array {
  return linspace(1, shift / (total + shift - 1), count)
    .map(value => shift * value / (1 + (shift - 1) * value));
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
  readonly #training: Float64Array;

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
      const nearest = Math.abs(sigma - training[lower]!) <= Math.abs(training[upper]! - sigma) ? lower : upper;
      const level = training[nearest]!;
      levels.push(level);
    }
    const distinct = new Set(levels).size;
    if (distinct !== steps)
      throw new RangeError(`MOSS-Image cannot run ${steps} steps: the training grid gives only ${distinct} distinct steps. Use fewer steps.`);
    levels.push(0);
    return Float32Array.from(levels);
  }

  timestep(sigma: number): number {
    return f32(f32(sigma) * this.config.numTrainTimesteps);
  }
}
