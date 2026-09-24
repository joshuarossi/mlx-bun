// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import { runtimeConfig,withRuntimeConfig } from "../execution/config";
import { GenerateStats,GeneratedToken } from './types';

export class Generation implements AsyncIterable<GeneratedToken> {
  stats: GenerateStats | null = null;
  readonly #next: () => Promise<IteratorResult<GeneratedToken, GenerateStats>>;
  readonly #return: () => Promise<IteratorResult<GeneratedToken, GenerateStats>>;

  constructor(iter: AsyncGenerator<GeneratedToken, GenerateStats>, runtime = runtimeConfig()) {
    // Async generators resume in the caller's context on every next/return.
    // Bind both operations so consumer awaits and early close cannot change
    // the runtime snapshot seen by kernels or their cleanup.
    const next = iter.next.bind(iter);
    const close = () => iter.return(undefined as unknown as GenerateStats);
    this.#next = () => withRuntimeConfig(runtime, next);
    this.#return = () => withRuntimeConfig(runtime, close);
  }

  async *[Symbol.asyncIterator](): AsyncGenerator<GeneratedToken> {
    try {
      while (true) {
        const r = await this.#next();
        if (r.done) {
          this.stats = r.value;
          return;
        }
        yield r.value;
      }
    } finally {
      // Consumer broke early (e.g. a decoded-text stop sequence fired):
      // drive the inner generator's shutdown so its finallys run (array
      // disposal, wired/adapter scopes) and capture the stats its
      // early-return path still reports.
      if (this.stats === null) {
        const r = await this.#return();
        if (r.done && r.value) this.stats = r.value;
      }
    }
  }
}
