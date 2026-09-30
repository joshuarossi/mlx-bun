/** A dedicated task-model call supplied by a host; the module renders its stage input,
 * while the host owns tokenization, numerics, lifetime and transport. */
export interface TaskCompletionRequest {
  readonly stage: string;
  readonly input: { system?: string; user: string };
  readonly maxTokens: number;
}
export interface TaskCompletionClient {
  complete(request: TaskCompletionRequest): Promise<string>;
  /** Ordered raw outputs; the host chooses execution groups. */
  completeBatch(requests: readonly TaskCompletionRequest[]): Promise<string[]>;
}
