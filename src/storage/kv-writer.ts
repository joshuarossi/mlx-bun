import { Worker } from "node:worker_threads";
import workerSource from "./kv-writer.worker.js" with { type: "text" };
import type { KvFileHeader } from "../kv-store";

/** Immutable, evaluated host-visible storage. The owner retains the native
 * buffers until write() settles. No MLX handles cross the worker boundary. */
export interface StoredTensorView {
  pointer: number;
  shape: number[];
  strides: number[];
  itemSize: number;
}

export interface KvWriteRequest {
  layout?: "whole" | "blocks";
  blockBytes?: number;
  segmented?: boolean;
  path: string;
  header: KvFileHeader;
  tensors: StoredTensorView[];
}

/** Hashing, layout packing and atomic disk writes run on a dedicated CPU
 * worker. Only metadata and pointers are posted; tensor bytes are not copied
 * through structured clone. The RAM cache remains an independent owner. */
export class KvWriter {
  #worker: Worker | null = null;
  #next = 0;
  #pending = new Map<number, { resolve(): void; reject(error: Error): void }>();

  lastMetrics: { elapsedMs: number; writtenBytes?: number; reusedBytes?: number; copiedBytes?: number; scratchPeak?: number } | null = null;

  write(request: KvWriteRequest): Promise<void> { return this.#send(request); }

  read(request: { path: string; header: KvFileHeader & { dataStart: number }; pointers: number[]; verify?: boolean }): Promise<void> {
    return this.#send({ ...request, operation: "read" });
  }

  collect(root: string): Promise<void> { return this.#send({ root, operation: "collect" }); }

  #send(request: object): Promise<void> {
    const worker = this.#worker ?? this.#start();
    worker.ref();
    const id = ++this.#next;
    return new Promise<void>((resolve, reject) => {
      this.#pending.set(id, { resolve, reject });
      try { worker.postMessage({ id, ...request }); }
      catch (error) {
        this.#pending.delete(id);
        if (!this.#pending.size) worker.unref();
        reject(error);
      }
    });
  }

  #start(): Worker {
    // Embed the worker in the single-file executable as well as source runs.
    const worker = new Worker(workerSource, { eval: true });
    worker.on("message", (message: { id: number; error?: string; metrics?: KvWriter["lastMetrics"] }) => {
      const result = this.#pending.get(message.id);
      if (!result) return;
      this.#pending.delete(message.id);
      if (message.error) result.reject(new Error(message.error));
      else { this.lastMetrics = message.metrics ?? null; result.resolve(); }
      if (!this.#pending.size) worker.unref();
    });
    // Job failures are acknowledged by the worker. A worker-level failure
    // settles only at exit, after it can no longer read borrowed buffers.
    worker.on("error", () => {});
    worker.on("exit", () => {
      for (const job of this.#pending.values()) job.reject(new Error("KV persistence worker exited"));
      this.#pending.clear();
      this.#worker = null;
    });
    this.#worker = worker;
    return worker;
  }
}

export const kvWriter = new KvWriter();

/** Reads have their own queue: a restore never waits behind persistence. */
export const kvReader = new KvWriter();
