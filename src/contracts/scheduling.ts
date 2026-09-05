/** A backend execution group exposes bounded work units and readiness. Queue
 * payloads, tensors, cache merging and sampling remain inside its adapter. */
export interface ExecutionGroup {
  readonly active: number;
  readonly queued: number;
  readonly preparing: boolean;
  readonly maxActive: number;
  readonly admissionHeld: boolean;
  readonly closed: boolean;
  pruneCancelled(): void;
  /** May reject/remove an impossible queued request before returning false. */
  admitNext(): boolean;
  /** Read-only budget check used to preserve admission before decode. */
  canBurst(): boolean;
  advancePreparation(): Promise<void>;
  advance(): Promise<void>;
  failActive(error: unknown): void;
  failAll(error: unknown): void;
  reserveResidency(): () => void;
  acquireExecution?(): Promise<() => void>;
  waitForWork(): Promise<void>;
}

export interface SchedulingClock {
  now(): number;
  yield(): Promise<void>;
}
