// The push to the Hugging Face Hub that follows a finished model write (`fuse`,
// `upload`): the write token is resolved before any work, the push is an owned
// step, and on failure a hint names the retry command. `convert` does the same
// through the model catalog (`@mlx-bun/module-quantize`).
import { createHfCredentials } from "../publishing/credentials";
import type { PublishRequest } from "../publishing/upload";
import { style, type Step } from "./terminal";

const message = (error: unknown) => (error instanceof Error ? error.message : String(error));

export interface UploadDependencies {
  credentials(): Pick<ReturnType<typeof createHfCredentials>, "get">;
  publish(request: PublishRequest): Promise<{ url: string }>;
  step: (text: string) => Step;
  log(line?: string): void;
}

/** The Hub credentials and publisher behind `--upload-repo`. */
export const uploadDefaults: Pick<UploadDependencies, "credentials" | "publish"> = {
  credentials: () => createHfCredentials(),
  async publish(request) {
    const { createPublisher } = await import("../publishing/upload");
    return createPublisher({ credentials: createHfCredentials(), getJob: () => null })(request);
  },
};

/** The write-token check `--upload-repo` runs before any work. */
export function requireWriteToken(credentials: Pick<ReturnType<typeof createHfCredentials>, "get">): void {
  if (!credentials.get())
    throw new Error("--upload-repo needs a Hugging Face WRITE token and none was found —\n" +
      "run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
}

/** The push after a successful `fuse`: an owned step, then, on failure, a
 * hint naming the retry command; the model on disk is complete either way. */
export async function publishModel(deps: Pick<UploadDependencies, "step" | "publish" | "log">,
  request: { kind: PublishRequest["kind"]; repoId: string; dir: string; what: string }, signal?: AbortSignal): Promise<void> {
  signal?.throwIfAborted();
  const { repoId, dir } = request;
  const uploading = deps.step(`uploading ${dir} → ${repoId}`);
  let uploaded: { url: string };
  try { uploaded = await deps.publish({ kind: request.kind, repoId, sourcePath: dir, signal }); }
  catch (error) {
    // The model is complete either way; only the push is undone or unfinished.
    const hint = `the ${request.what} model is intact at ${dir} — retry with: mlx-bun upload --path ${dir} --upload-repo ${repoId}`;
    if (signal?.aborted) { uploading.fail("upload cancelled"); deps.log(hint); throw signal.reason; }
    uploading.fail(`upload failed: ${message(error)}`);
    throw new Error(hint);
  }
  uploading.done(`uploaded ${style.bold(uploaded.url)}`);
}
