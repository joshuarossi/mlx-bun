import { downloadModel, type DownloadOptions } from "@mlx-bun/hub/download";

export class DuplicateDownloadError extends Error {
  constructor(repoId: string) {
    super(`a download for ${repoId} is already in progress`);
    this.name = "DuplicateDownloadError";
  }
}

export interface DownloadOwnerOptions {
  /** Transfer implementation; the default is the hub package downloader. */
  download?: (repoId: string, options: DownloadOptions) => Promise<string>;
  /** Process-wide activity for transfers this owner did not start. */
  active?: (repoId: string) => boolean;
  /** Runs after a transfer completes; never after cancellation or failure. */
  onComplete?: (repoId: string, snapshotPath: string) => void | Promise<void>;
  /** Failures the hub tracker cannot show, such as a metadata request that
   * fails before any tracker row exists. Never called for cancellation. */
  onFailure?: (repoId: string, error: unknown) => void;
  transfer?: Pick<DownloadOptions, "cacheDir" | "endpoint" | "token">;
}

export interface DownloadOwner {
  /** Repos with a transfer this owner has admitted and not yet joined. */
  readonly active: readonly string[];
  /** Admits synchronously, before any network request, so a duplicate submit
   * is refused even while the metadata request is still pending. */
  start(repoId: string): void;
  /** Aborts every transfer and waits for each to settle its partial on disk.
   * Idempotent; later `start` calls are refused. */
  close(): Promise<void>;
}

/** Owns background Hugging Face transfers started from the web. Progress
 * remains visible through the hub tracker (`GET /downloads`); this owner adds
 * admission, completion side effects, and cancel-and-join at shutdown. */
export function createDownloadOwner(options: DownloadOwnerOptions = {}): DownloadOwner {
  const transfers = new Map<string, { controller: AbortController; settled: Promise<void> }>();
  let closing: Promise<void> | undefined;
  return {
    get active() { return [...transfers.keys()]; },
    start(repoId) {
      if (closing) throw new Error("downloads are closed");
      if (transfers.has(repoId) || options.active?.(repoId)) throw new DuplicateDownloadError(repoId);
      const controller = new AbortController();
      const entry = { controller, settled: Promise.resolve() };
      transfers.set(repoId, entry);
      entry.settled = (async () => {
        try {
          const path = await (options.download ?? downloadModel)(repoId, { ...options.transfer, signal: controller.signal });
          if (controller.signal.aborted) return;
          await options.onComplete?.(repoId, path);
        } catch (error) {
          if (!controller.signal.aborted) options.onFailure?.(repoId, error);
        } finally { transfers.delete(repoId); }
      })();
    },
    close() {
      return closing ??= (async () => {
        const pending = [...transfers.values()];
        for (const { controller } of pending) controller.abort(new Error("server is shutting down"));
        await Promise.all(pending.map(({ settled }) => settled));
      })();
    },
  };
}
