interface Task {
  run(): Promise<void>;
  reject(error: unknown): void;
}

/** Work whose owner requires an execution boundary, without owning a decode
 * row. The driver supplies the lease; this queue owns waiting and cancellation.
 * Once started, work settles before its caller can release native resources. */
export class ExecutionTasks {
  #pending: Task[] = [];
  get pending(): number { return this.#pending.length; }

  enqueue<T>(work: () => Promise<T>, cancellation?: Cancellation): Promise<T> {
    if (cancellation?.reason !== undefined) return Promise.reject(new GenerationCancelled(cancellation.reason));
    return new Promise<T>((resolve, reject) => {
      let unsubscribe = () => {};
      const cleanup = () => unsubscribe();
      const task: Task = {
        async run() {
          cleanup();
          try { resolve(await work()); } catch (error) { reject(error); }
        },
        reject(error) { cleanup(); reject(error); },
      };
      this.#pending.push(task);
      unsubscribe = cancellation?.subscribe(reason => {
        const index = this.#pending.indexOf(task);
        if (index < 0) return;
        this.#pending.splice(index, 1);
        task.reject(new GenerationCancelled(reason));
      }) ?? (() => {});
      if (!this.#pending.includes(task)) unsubscribe();
    });
  }

  async advance(): Promise<void> { await this.#pending.shift()?.run(); }

  rejectAll(error: unknown): void {
    const tasks = this.#pending; this.#pending = [];
    for (const task of tasks) task.reject(error);
  }
}
import type { Cancellation } from "../contracts/generation";
import { GenerationCancelled } from "./cancellation";
