import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { TokenLogprobs } from "../../contracts/generation";
import { readStepExtras, stepExtrasArrays, disposeStepExtras,
  type DeviceStepSampler, type StepExtras } from "../../sampler";
import { disposeResources, cleanupFailure } from "../../engine/resources";

type TokenSink = (token: number, logprobs?: TokenLogprobs) => void | boolean | Promise<void | boolean>;

/** Request-owned sampling and output metadata. Execution groups receive token
 * tensors and an output callback; they need no logprob or retention policy. */
export function createRowSampling(
  sampler: DeviceStepSampler, onToken: TokenSink,
) {
  if (!sampler.capturesLogprobs) return {
    sample: (logits: MlxArray, step: number) => sampler.sample(logits, step).token,
    plainGreedy: sampler.isPlainGreedy, onToken, dispose: () => sampler.dispose(),
  };

  // A pipelined group can sample the next token before emitting the previous
  // one. Keep captures by request-local step, independently of row position.
  const pending = new Map<number, StepExtras>();
  let emitted = 0;
  return {
    sample(logits: MlxArray, step: number): MlxArray {
      const result = sampler.sample(logits, step);
      try {
        ops.asyncEvalAll([result.token, ...stepExtrasArrays(result.extras)]);
        if (result.extras) pending.set(step, result.extras);
        return result.token;
      } catch (error) {
        return cleanupFailure(error, () => disposeResources([result.token,
          { dispose: () => disposeStepExtras(result.extras) }]));
      }
    },
    // The vectorized token-only shortcut bypasses the per-request sampler.
    plainGreedy: false,
    onToken(token: number) {
      const extras = pending.get(emitted) ?? null;
      pending.delete(emitted++);
      return onToken(token, readStepExtras(extras));
    },
    dispose() {
      const extras = [...pending.values()];
      pending.clear();
      disposeResources([sampler, ...extras.map(value => ({ dispose: () => disposeStepExtras(value) }))]);
    },
  };
}
