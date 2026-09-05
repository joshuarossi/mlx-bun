import type { Cancellation } from "./generation";

/** Application-facing calls. The implementation owns tokenization, numerical
 * method and transport; callers provide request data and consume results. */
export interface CompletionClient<Request, Result> {
  complete(request: Request): Promise<Result>;
}

export interface BatchCompletionClient<Request, Result> extends CompletionClient<Request, Result> {
  /** Results preserve input order; the implementation chooses execution groups. */
  completeBatch(requests: readonly Request[]): Promise<Result[]>;
}

export interface TaskClient<Request, Progress, Result> {
  run(request: Request, report: (progress: Progress) => void, cancellation?: Cancellation): Promise<Result>;
}
