/** Backend-owned context shared by compatible requests. A key identifies
 * equivalent execution state; enter returns its scoped release. Scheduling
 * observes group readiness without inspecting this context. */
export interface ExecutionContext {
  readonly key: string;
  enter(): () => void;
}

/** A backend execution group exposes bounded work units and readiness. Queue
 * payloads, tensors, cache merging and sampling remain inside its adapter. */
export interface ExecutionGroup {
  readonly active: number;
  readonly queued: number;
  readonly preparing: boolean;
  readonly preparingRows?: number;
  /** The preparation owner can accept another row before its next work unit. */
  readonly canPrepareMore?: boolean;
  /** Work estimates affect grouping only. A request larger than this budget
   * still runs alone; it is never rejected or sent to another executor. */
  readonly preparingTokens?: number;
  readonly nextPreparationTokens?: number;
  readonly maxPreparationTokens?: number;
  /** The latest preparation published output that can be flushed by yielding. */
  readonly preparationPublishedOutput?: boolean;
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
