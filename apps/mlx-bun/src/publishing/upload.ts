import { uploadFolder } from "@mlx-bun/hub/upload";
import type { createHfCredentials } from "./credentials";

export interface PublishRequest {
  kind: "quantize" | "finetune" | "dataset";
  repoId: string;
  private?: boolean;
  sourcePath?: string;
  jobId?: string;
}

/** App policy chooses an artifact and credentials; hub owns the upload protocol.
 * The job lookup is borrowed and read-only. No model or execution lease is needed. */
export function createPublisher(options: {
  credentials: Pick<ReturnType<typeof createHfCredentials>, "get">;
  getJob(id: string): { output_path: string | null } | null | undefined | Promise<{ output_path: string | null } | null | undefined>;
  upload?: typeof uploadFolder;
}) {
  return async (request: PublishRequest) => {
    const token = options.credentials.get();
    if (!token) throw new Error("no HF token saved — add one in Settings → Hugging Face");
    let source = request.sourcePath;
    if (!source && request.jobId) source = (await options.getJob(request.jobId))?.output_path ?? undefined;
    if (!source) throw new Error("no source dir (pass job_id or source_path)");
    return (options.upload ?? uploadFolder)(source, request.repoId, {
      repoType: request.kind === "dataset" ? "dataset" : "model",
      private: !!request.private, token,
    });
  };
}
