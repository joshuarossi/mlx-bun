import { downloadModel, downloadsSnapshot, type DownloadOptions, type DownloadStatus } from "@mlx-bun/hub/download";

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
  /** Rows the hub package records once a listing exists; the default is its process tracker. */
  tracker?: () => readonly DownloadStatus[];
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
  /** One row per transfer for its whole lifecycle: the admission row until the
   * hub tracker publishes its live row (after listing and preflight), which
   * then replaces it in place; a transfer that fails or is cancelled before
   * that keeps its own terminal row. Tracker rows this owner did not start are
   * included unchanged. */
  snapshot(): DownloadStatus[];
  /** Aborts every transfer and waits for each to settle its partial on disk.
   * Idempotent; later `start` calls are refused. */
  close(): Promise<void>;
}

/** Terminal rows retained for the progress surface, matching the hub tracker's window. */
const RETAINED_ROWS = 5;

/** Owns background Hugging Face transfers started from the web: admission,
 * the progress surface before and after the hub tracker has a row, completion
 * side effects, and cancel-and-join at shutdown. */
export function createDownloadOwner(options: DownloadOwnerOptions = {}): DownloadOwner {
  const transfers = new Map<string, { controller: AbortController; settled: Promise<void> }>();
  const rows: DownloadStatus[] = [];
  let closing: Promise<void> | undefined;
  const message = (error: unknown) => error instanceof Error ? error.message : String(error);
  /** The tracker settles its own row before the transfer resolves; only an
   * admission row that never received one still needs a terminal state. */
  const settle = (row: DownloadStatus, state: "done" | "error", error?: string) => {
    if (row.state !== "active") return;
    row.state = state; row.bytesPerSec = 0; row.finishedAt = Date.now();
    if (error !== undefined) row.error = error;
  };
  const retain = () => {
    while (rows.length > RETAINED_ROWS) {
      const oldest = rows.findIndex(row => row.state !== "active");
      if (oldest < 0) break;
      rows.splice(oldest, 1);
    }
  };
  return {
    get active() { return [...transfers.keys()]; },
    start(repoId) {
      if (closing) throw new Error("downloads are closed");
      if (transfers.has(repoId) || options.active?.(repoId)) throw new DuplicateDownloadError(repoId);
      const controller = new AbortController();
      let row: DownloadStatus = { repoId, state: "active", currentFile: null, receivedBytes: 0, totalBytes: 0,
        filesDone: 0, filesTotal: 0, bytesPerSec: 0, startedAt: Date.now(), finishedAt: null };
      rows.push(row); retain();
      const entry = { controller, settled: Promise.resolve() };
      transfers.set(repoId, entry);
      entry.settled = (async () => {
        try {
          const path = await (options.download ?? downloadModel)(repoId, { ...options.transfer, signal: controller.signal,
            onStatus: status => { rows[rows.indexOf(row)] = status; row = status; } });
          if (controller.signal.aborted) { settle(row, "error", message(controller.signal.reason)); return; }
          settle(row, "done");
          await options.onComplete?.(repoId, path);
        } catch (error) {
          settle(row, "error", message(controller.signal.aborted ? controller.signal.reason : error));
          if (!controller.signal.aborted) options.onFailure?.(repoId, error);
        } finally { transfers.delete(repoId); }
      })();
    },
    snapshot() {
      const tracked = (options.tracker ?? downloadsSnapshot)();
      const known = new Set<DownloadStatus>(tracked);
      return [...tracked, ...rows.filter(row => !known.has(row))].sort((a, b) => a.startedAt - b.startedAt);
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
