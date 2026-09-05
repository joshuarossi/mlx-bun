/** Host-side admission before grammar/media preparation can allocate native
 * resources. The implementation shares the generation execution domain. */
export interface PreparationExecutor {
  run<T>(prepare: () => Promise<T>, signal?: AbortSignal): Promise<T>;
}
