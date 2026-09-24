/** Transport-specific request/response values stay outside portable policy. */
export interface EngineHost<Request, Response> {
  readonly ready: Promise<void>;
  forward(request: Request): Promise<Response>;
  /** Stop accepting work and wait until the owned worker has exited. */
  close(): Promise<void>;
}
