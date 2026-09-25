import { existsSync, statSync } from "node:fs";
import { uploadFolder } from "@mlx-bun/hub/upload";
import { createHfCredentials } from "../publishing/credentials";
import { usage, type CommandArgs } from "./args";
import { box, step, style } from "./terminal";

// mlx_lm.upload counterpart (same flag names: --path, --upload-repo) over the
// app's credential policy and the public hub uploader, the engine the web push
// routes use. Everything before the upload is argument, directory, and token
// validation; nothing touches the network until those pass.

export interface UploadDependencies {
  credentials: Pick<ReturnType<typeof createHfCredentials>, "get">;
  upload: typeof uploadFolder;
  isDirectory(path: string): boolean;
  step: typeof step;
  box: typeof box;
  log(line?: string): void;
}
const defaults: UploadDependencies = {
  credentials: createHfCredentials(),
  upload: uploadFolder,
  isDirectory: path => existsSync(path) && statSync(path).isDirectory(),
  step, box,
  log: line => { console.log(line ?? ""); },
};

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;
function option(args: CommandArgs, name: string): string | undefined {
  const value = args.values[name]; return typeof value === "string" ? value : undefined;
}

export async function runUpload(args: CommandArgs, supplied: Partial<UploadDependencies> = {}, signal?: AbortSignal): Promise<void> {
  const deps = { ...defaults, ...supplied };
  const dir = option(args, "path") || "mlx_model"; // mlx_lm.upload's --path default
  const repoValue = option(args, "upload-repo");
  const repo = repoValue && !repoValue.startsWith("-") ? repoValue : null;
  if (!repo) throw new Error(usage("upload"));
  if (!deps.isDirectory(dir)) throw new Error(`not a directory: ${dir} (pass the model directory via --path)`);
  const token = deps.credentials.get();
  if (!token) throw new Error([
    "no Hugging Face token found — uploading needs a WRITE token from one of:",
    "  hf auth login                  (~/.cache/huggingface/token)",
    "  export HF_TOKEN=hf_…",
    "  web UI Settings → Hugging Face (~/.mlx-bun/hf.json)",
  ].join("\n"));
  signal?.throwIfAborted();
  const isPrivate = args.values.private === true;
  const s = deps.step(`uploading ${dir} → ${repo}`);
  let result: Awaited<ReturnType<typeof uploadFolder>>;
  try {
    result = await deps.upload(dir, repo, {
      repoType: "model", private: isPrivate, token, commitMessage: "Upload with mlx-bun", signal,
      onProgress: (file, sent, total) => s.update(`${style.bold(repo)} ${style.dim(`· ${file} · ${gb(sent)} / ${gb(total)}`)}`),
    });
  } catch (error) {
    s.fail(`upload failed: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
  s.done(`uploaded ${style.bold(repo)}`);
  deps.log();
  deps.box([
    `${style.green("●")} ${style.bold("upload complete")}`,
    "",
    `source    ${style.dim(dir)}`,
    `repo      ${style.url(result.url)}${isPrivate ? style.dim(" · private") : ""}`,
    "",
    `get it back anywhere:  ${style.accent(`mlx-bun get ${repo}`)}`,
  ]);
}
