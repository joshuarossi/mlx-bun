import type { Cancellation } from "../contracts/generation";
import type { DisposableResource } from "../contracts/resources";
import { AdmissionRejected } from "./admission";
import { throwIfCancelled } from "./cancellation";

type Mode = "shared" | "exclusive";
interface Waiter {
  mode: Mode;
  resolve(lease: DisposableResource): void;
  reject(error: unknown): void;
  unsubscribe(): void;
}

/** Shared worker activity; exclusive managed jobs. FIFO writers cannot starve
 * behind newly arriving inference. This coordinates execution, not memory size. */
export class ExecutionCoordinator {
  #readers = 0;
  #writer = false;
  #closed = false;
  #queue: Waiter[] = [];
  constructor(readonly maxQueued = 64) {
    if (!Number.isSafeInteger(maxQueued) || maxQueued < 0) throw new Error("invalid coordination queue bound");
  }
  acquire(mode: Mode, cancellation?: Cancellation): Promise<DisposableResource> {
    if (this.#closed) return Promise.reject(new Error("execution coordinator is closed"));
    try { if (cancellation) throwIfCancelled(cancellation); }
    catch (error) { return Promise.reject(error); }
    if (!this.#queue.length && !this.#writer && (mode === "shared" || this.#readers === 0))
      return Promise.resolve(this.#lease(mode));
    if (this.#queue.length >= this.maxQueued) return Promise.reject(new AdmissionRejected());
    return new Promise((resolve, reject) => {
      const waiter: Waiter = { mode, resolve, reject, unsubscribe() {} };
      this.#queue.push(waiter);
      waiter.unsubscribe = cancellation?.subscribe((reason) => {
        const index = this.#queue.indexOf(waiter);
        if (index < 0) return;
        this.#queue.splice(index, 1);
        waiter.unsubscribe();
        reject(new Error(`execution admission cancelled: ${reason}`));
        this.#drain();
      }) ?? (() => {});
      if (!this.#queue.includes(waiter)) waiter.unsubscribe();
    });
  }
  #lease(mode: Mode): DisposableResource {
    if (mode === "shared") this.#readers++;
    else this.#writer = true;
    let disposed = false;
    return { dispose: () => {
      if (disposed) return;
      disposed = true;
      if (mode === "shared") this.#readers--;
      else this.#writer = false;
      this.#drain();
    } };
  }
  #drain(): void {
    while (!this.#writer && this.#queue.length) {
      const next = this.#queue[0]!;
      if (next.mode === "exclusive" && this.#readers > 0) return;
      this.#queue.shift(); next.unsubscribe(); next.resolve(this.#lease(next.mode));
    }
  }
  close(): void {
    this.#closed = true;
    for (const next of this.#queue.splice(0)) {
      next.unsubscribe(); next.reject(new Error("execution coordinator is closed"));
    }
  }
}
