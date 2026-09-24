import type { Cancellation } from "../contracts/generation";
import type { DisposableResource } from "../contracts/resources";
import { throwIfCancelled } from "./cancellation";

export class AdmissionRejected extends Error {
  constructor() { super("admission queue is full"); this.name = "AdmissionRejected"; }
}

/** FIFO reservations. A cancelled waiter releases no active owner's capacity. */
export class AdmissionPool {
  #active = 0;
  #closed = false;
  #waiting: Array<{ resolve(lease: DisposableResource): void; reject(error: unknown): void; unsubscribe(): void }> = [];
  constructor(readonly capacity: number, readonly maxQueued = 64) {
    if (!Number.isSafeInteger(capacity) || capacity < 1 || !Number.isSafeInteger(maxQueued) || maxQueued < 0)
      throw new Error("invalid admission capacity");
  }
  get active(): number { return this.#active; }
  get queued(): number { return this.#waiting.length; }

  acquire(cancellation?: Cancellation): Promise<DisposableResource> {
    if (this.#closed) return Promise.reject(new Error("admission is closed"));
    try { if (cancellation) throwIfCancelled(cancellation); }
    catch (error) { return Promise.reject(error); }
    if (this.#active < this.capacity) return Promise.resolve(this.#lease());
    if (this.#waiting.length >= this.maxQueued) return Promise.reject(new AdmissionRejected());
    return new Promise((resolve, reject) => {
      const waiter = { resolve, reject, unsubscribe() {} };
      this.#waiting.push(waiter);
      waiter.unsubscribe = cancellation?.subscribe((reason) => {
        const index = this.#waiting.indexOf(waiter);
        if (index < 0) return;
        this.#waiting.splice(index, 1);
        waiter.unsubscribe();
        reject(new Error(`admission cancelled: ${reason}`));
      }) ?? (() => {});
      if (!this.#waiting.includes(waiter)) waiter.unsubscribe();
    });
  }

  #lease(): DisposableResource {
    this.#active++;
    let released = false;
    return { dispose: () => {
      if (released) return;
      released = true;
      this.#active--;
      const next = this.#waiting.shift();
      if (next) { next.unsubscribe(); next.resolve(this.#lease()); }
    } };
  }

  close(): void {
    this.#closed = true;
    for (const waiter of this.#waiting.splice(0)) {
      waiter.unsubscribe(); waiter.reject(new Error("admission is closed"));
    }
  }
}
