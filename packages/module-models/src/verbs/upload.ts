import { existsSync, statSync } from "node:fs";
import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";
import { flag, gb, option, printer } from "./shared";

// mlx_lm.upload counterpart (same flag names: --path, --upload-repo) over the host's publisher. Everything before the
// upload is argument, directory, and token validation; nothing touches the network until those pass.

export interface UploadDependencies {
  isDirectory(path: string): boolean;
}
const defaults: UploadDependencies = { isDirectory: path => existsSync(path) && statSync(path).isDirectory() };

export const UPLOAD_USAGE = "usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]";

export async function runUpload(invocation: CliInvocation, catalog: Pick<ModelCatalog, "canPublish" | "publish">, supplied: Partial<UploadDependencies> = {}): Promise<number> {
  const deps = { ...defaults, ...supplied };
  const print = printer(invocation), { terminal } = invocation, { style } = terminal;
  // No working-directory default (mlx_lm.upload's `mlx_model`): the path is required.
  const dir = option(invocation, "path");
  const repoValue = option(invocation, "upload-repo");
  const repo = repoValue && !repoValue.startsWith("-") ? repoValue : null;
  if (!repo || !dir) throw new Error(UPLOAD_USAGE);
  if (!deps.isDirectory(dir)) throw new Error(`not a directory: ${dir} (pass the model directory via --path)`);
  if (!catalog.canPublish()) throw new Error([
    "no Hugging Face token found — uploading needs a WRITE token from one of:",
    "  hf auth login                  (~/.cache/huggingface/token)",
    "  export HF_TOKEN=hf_…",
    "  web UI Settings → Hugging Face (~/.mlx-bun/hf.json)",
  ].join("\n"));
  invocation.signal.throwIfAborted();
  const isPrivate = flag(invocation, "private");
  const step = terminal.step(`uploading ${dir} → ${repo}`);
  let result: { readonly url: string };
  try {
    result = await catalog.publish(dir, { repoId: repo, private: isPrivate, commitMessage: "Upload with mlx-bun", signal: invocation.signal,
      onProgress: (file, sent, total) => step.update(`${style.bold(repo)} ${style.dim(`· ${file} · ${gb(sent)} / ${gb(total)}`)}`) });
  } catch (error) {
    step.fail(`upload failed: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
  step.done(`uploaded ${style.bold(repo)}`);
  print();
  terminal.box([
    `${style.green("●")} ${style.bold("upload complete")}`,
    "",
    `source    ${style.dim(dir)}`,
    `repo      ${style.url(result.url)}${isPrivate ? style.dim(" · private") : ""}`,
    "",
    `get it back anywhere:  ${style.accent(`mlx-bun get ${repo}`)}`,
  ]);
  return 0;
}
