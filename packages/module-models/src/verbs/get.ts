import { existsSync, readdirSync } from "node:fs";
import { basename, join } from "node:path";
import type { CliInvocation, ModelCatalog } from "@mlx-bun/app-core";
import { hubCacheRoot, planRepoGc } from "@mlx-bun/hub/registry";
import { gb, option, printer } from "./shared";

/** `get`: download a model (resumable, verified) into the Hub cache and index it. */
export async function runGet(invocation: CliInvocation, catalog: Pick<ModelCatalog, "find" | "download">): Promise<number> {
  const print = printer(invocation), { terminal } = invocation, { style } = terminal;
  let repoId = invocation.positionals[0];
  if (!repoId) throw new Error("usage: mlx-bun get <org/repo | substring> [--revision main]");
  if (!repoId.includes("/")) {
    // No org/name: a query over already-downloaded repos (re-get/refresh, e.g. `mlx-bun get 12B` after an upstream push).
    try { repoId = (await catalog.find(repoId)).id; }
    catch (error) {
      throw new Error(`${(error as Error).message}\nusage: mlx-bun get <org/repo> [--revision main] — or a substring of a downloaded repo (try \`mlx-bun ls ${repoId}\`)`);
    }
  }
  const repoDir = join(hubCacheRoot(), `models--${repoId.replaceAll("/", "--")}`);
  const priorSnapshots = existsSync(join(repoDir, "snapshots")) ? readdirSync(join(repoDir, "snapshots")) : [];
  const step = terminal.step(`downloading ${repoId}`);
  let entry: Awaited<ReturnType<ModelCatalog["download"]>>;
  try {
    entry = await catalog.download(repoId, { revision: option(invocation, "revision", "main")!, signal: invocation.signal,
      onProgress: (file, received, total) => {
        const percent = total ? Math.floor((received / total) * 100) : 0;
        step.update(`${style.bold(repoId!)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${percent}%)`)}`);
      } });
  } catch (error) { step.fail("download failed"); throw error; }
  step.done(`${style.bold(repoId)} ${style.dim("downloaded · verified")}`);
  // The download re-indexed the cache before it answered.
  terminal.step("updating registry").done(`registry updated ${style.dim(`· ${entry.directory}`)}`);
  // Upstream pushed a new revision, so this get created a NEW snapshots/<sha> dir; the old one stays on disk (that's how
  // ~25 GB of dead blobs pile up). Say so, with what `gc` would get back.
  if (priorSnapshots.length > 0 && !priorSnapshots.includes(basename(entry.directory))) {
    const plan = planRepoGc(repoDir);
    const note = plan.skippedSnapshots.length > 0 ? " (a previous snapshot has files this revision lacks — gc will warn; --force to prune it)" : "";
    print(style.dim(`  previous revision kept on disk — \`mlx-bun gc\` reclaims ~${gb(plan.reclaimBytes)}${note}`));
  }
  return 0;
}
