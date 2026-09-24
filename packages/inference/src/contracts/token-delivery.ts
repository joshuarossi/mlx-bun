import type { TokenLogprobs } from "./generation";

/** Returning false stops delivery after the current token. */
export type OnToken = (token: number, logprobs?: TokenLogprobs) => void | boolean | Promise<void | boolean>;
