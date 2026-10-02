import { realpath } from "node:fs/promises";
import { sep } from "node:path";
import { uploadFolder } from "@mlx-bun/hub/upload";
import type { createHfCredentials } from "./credentials";

export interface PublishRequest {
  kind: "quantize" | "finetune" | "dataset";
  repoId: string;
  private?: boolean;
  sourcePath?: string;
  jobId?: string;
  commitMessage?: string;
  /** Bytes of `file` sent so far out of `total`. */
  onProgress?: (file: string, sent: number, total: number) => void;
  /** Cancels the upload; see `@mlx-bun/hub/upload` for what an abort can and cannot undo. */
  signal?: AbortSignal;
}

/** Whether `source` resolves, through any links, to one of `roots` or inside one. */
async function within(source: string, roots: readonly string[]): Promise<boolean> {
  const real = await realpath(source).catch(() => undefined);
  if (real === undefined) return false;
  for (const root of roots) {
    const realRoot = await realpath(root).catch(() => undefined);
    if (realRoot !== undefined && (real === realRoot || real.startsWith(realRoot.endsWith(sep) ? realRoot : realRoot + sep))) return true;
  }
  return false;
}

/** App policy chooses an artifact and credentials; hub owns the upload protocol.
 * The job lookup is borrowed and read-only. No model or execution lease is needed.
 * `sources`, when given, are the only directories a push may read: the source
 * (named or a job's output) must resolve to one of them or inside one. The
 * server passes the app's outputs and local models, so a request cannot upload
 * an arbitrary directory with the saved token; the CLI passes none. */
export function createPublisher(options: {
  credentials: Pick<ReturnType<typeof createHfCredentials>, "get">;
  getJob(id: string): { output_path: string | null } | null | undefined | Promise<{ output_path: string | null } | null | undefined>;
  upload?: typeof uploadFolder;
  sources?(): readonly string[] | Promise<readonly string[]>;
}) {
  return async (request: PublishRequest) => {
    const token = options.credentials.get();
    if (!token) throw new Error("no HF token saved — add one in Settings → Hugging Face");
    let source = request.sourcePath;
    if (!source && request.jobId) source = (await options.getJob(request.jobId))?.output_path ?? undefined;
    if (!source) throw new Error("no source dir (pass job_id or source_path)");
    if (options.sources && !await within(source, await options.sources()))
      throw new Error(`${source} is not an mlx-bun output (models, adapters, datasets) or a local model`);
    return (options.upload ?? uploadFolder)(source, request.repoId, {
      repoType: request.kind === "dataset" ? "dataset" : "model",
      private: !!request.private, token, ...(request.signal ? { signal: request.signal } : {}),
      ...(request.commitMessage !== undefined ? { commitMessage: request.commitMessage } : {}),
      ...(request.onProgress ? { onProgress: request.onProgress } : {}),
    });
  };
}
