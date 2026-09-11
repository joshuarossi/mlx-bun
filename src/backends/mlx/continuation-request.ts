import { snapshotGenerationPolicy } from "./request-policy";
import type { GenerateOptions } from "../../generate";
import type { ResolvedExecution } from "../../contracts/execution";
import { makeStepSampler } from "../../sampler";
import { createRowSampling } from "./row-sampling";
import { bindContinuationPolicy, type OrdinaryContinuation } from "./continuation";

/** Optional policy and sampler recovery for the existing ordinary driver.
 * KV layout and delayed conversion remain owned by cache maintenance and persistence. */
export function createOrdinaryContinuationRequest(input: Omit<Parameters<typeof bindContinuationPolicy>[0], "namespace"> & {
  interval: number;
  persistence: import("./continuation-persistence").ContinuationPersistence;
  onToken: Parameters<typeof createRowSampling>[1];
}) {
  const options: GenerateOptions = snapshotGenerationPolicy(input.options);
  if (!Number.isSafeInteger(input.interval) || input.interval < 1) throw new Error("continuation interval must be positive");
  if (options.grammar || options.logprobs || options.topLogprobs || options.fill || options.pagedKv ||
      input.execution.method !== "autoregressive")
    throw new Error("ordinary continuation requires replayable ordinary sampling");
  const make = (seed = options.seed, history: readonly number[] = input.prompt) => createRowSampling(makeStepSampler(
    { ...options, seed }, { tokenRepresentation: "device", grammarWait: "external", historyUpdate: "after-sample",
      initialHistory: [...history] }), input.onToken);
  let sampling = make();
  let policy: ReturnType<typeof bindContinuationPolicy> | undefined;
  const continuation: OrdinaryContinuation = {
    interval: input.interval,
    restore(namespace) { policy = bindContinuationPolicy({ ...input, options, namespace }); return policy.restore(); },
    resumeSampling(state) {
      const next = make(state.seed, [...state.cacheTokens, state.pendingToken]);
      const previous = sampling; sampling = next; previous.dispose();
    },
    captureOwned: state => policy!.captureOwned(state),
    complete: () => policy?.complete(),
  };
  return {
    continuation,
    sample: ((...args) => sampling.sample(...args)) as ReturnType<typeof createRowSampling>["sample"],
    // History-free greedy sampling needs no recovery work in the fast path.
    plainGreedy: sampling.plainGreedy,
    onToken: input.onToken,
    dispose: () => { policy?.release(); sampling.dispose(); },
  };
}
