import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { hubCacheRoot } from "@mlx-bun/hub/registry";
import { inspectModel } from "../quantize/inspect";
import { quantizedModelName } from "../quantize/output-name";
import type { SubmitResult } from "../jobs/runner";
import { openRegistry, storagePath } from "../storage/paths";

export interface QuantizeRouteDeps {
  submit(kind: "quantize", config: Record<string, unknown>, outputPath: string): SubmitResult;
}
/** `outputRoot` is the storage root: quantized models land in its `models/`
 * (default ~/.mlx-bun/models) and the folder picker searches it beside the hub cache. */
export function createQuantizeRoutes(deps: QuantizeRouteDeps, options: { outputRoot?: string } = {}) {
  return { async handle(request: Request): Promise<Response | null> {
    const url = new URL(request.url);
    if (request.method !== "POST") return null;
    switch (url.pathname) {
      case "/api/quantize/inspect": {
        const body = await request.json().catch(() => ({}));
        return Response.json(await inspectModel(body?.model_id ?? ""));
      }
      case "/api/model/resolve-folder":
      case "/api/quantize/resolve-folder": return resolveModelFolder(request, options.outputRoot);
      case "/api/quantize/submit": return submitQuantize(request, deps, options.outputRoot);
      default: return null;
    }
  } };
}

export async function resolveModelFolder(request: Request, outputRoot?: string): Promise<Response> {
  const body = (await request.json().catch(() => ({}))) as {
    folder_name?: string;
    rel_path?: string;
  };
  const hubRoot = hubCacheRoot(), modelsRoot = storagePath("models", outputRoot);
  const hasConfig = (dir: string) => {
    try {
      return statSync(join(dir, "config.json")).isFile();
    } catch {
      return false;
    }
  };
  const folder = (body.folder_name ?? "")
    .replace(/\\/g, "/")
    .split("/")
    .filter(Boolean)
    .pop() ?? "";
  const relSegments = (body.rel_path ?? "")
    .replace(/\\/g, "/")
    .split("/")
    .filter(Boolean);
  const configDir = relSegments.length >= 2 ? relSegments[relSegments.length - 2] : "";
  const repoIdOf = (modelsDir: string) =>
    modelsDir.slice("models--".length).replaceAll("--", "/");
  const pickSnapshot = (repoDir: string): string | null => {
    const snapshots = join(repoDir, "snapshots");
    let head = "";
    try {
      head = readFileSync(join(repoDir, "refs", "main"), "utf8").trim();
    } catch {}
    if (head && hasConfig(join(snapshots, head))) return join(snapshots, head);
    try {
      for (const hash of readdirSync(snapshots)) {
        if (hasConfig(join(snapshots, hash))) return join(snapshots, hash);
      }
    } catch {}
    return null;
  };

  if (folder.startsWith("models--")) {
    const path = pickSnapshot(join(hubRoot, folder));
    if (path) return Response.json({ ok: true, path, repo_id: repoIdOf(folder) });
  }

  const hashDir = configDir || folder;
  if (hashDir) {
    try {
      for (const repo of readdirSync(hubRoot)) {
        if (!repo.startsWith("models--")) continue;
        const candidate = join(hubRoot, repo, "snapshots", hashDir);
        if (hasConfig(candidate)) {
          return Response.json({ ok: true, path: candidate, repo_id: repoIdOf(repo) });
        }
      }
    } catch {}
  }

  if (folder && hasConfig(join(hubRoot, folder))) return Response.json({ ok: true, path: join(hubRoot, folder) });
  // The app's own models are plain directories whose name is their id.
  if (folder && hasConfig(join(modelsRoot, folder))) return Response.json({ ok: true, path: join(modelsRoot, folder), repo_id: folder });

  const registry = openRegistry(outputRoot);
  try {
    await registry.scan();
    const all = registry.list();
    const record = (folder.startsWith("models--")
      ? all.find((model) => model.repoId === repoIdOf(folder))
      : undefined) ??
      all.find((model) => model.path.split("/").pop() === hashDir) ??
      all.find((model) => model.repoId.split("/").pop() === folder);
    if (record) {
      return Response.json({
        ok: true,
        path: record.path,
        repo_id: record.repoId,
        model_type: record.modelType,
      });
    }
  } finally {
    registry.close();
  }
  return Response.json({
    ok: false,
    error: "Couldn't locate this folder on disk — paste the path instead.",
  });
}

async function submitQuantize(request: Request, deps: QuantizeRouteDeps, outputRoot?: string): Promise<Response> {
  const body = (await request.json().catch(() => ({}))) as {
    model_id?: string;
    bits?: number;
    group_size?: number;
    target_bpw?: number;
    candidate_bits?: number[];
    reference?: string;
    calibration_mix?: string;
    n_calibration?: number;
    rotate_weights?: boolean;
    rotation_seed?: number;
  };
  if (!body.model_id)
    return Response.json({ ok: false, error: "model_id required" }, { status: 400 });
  const bits = body.bits ?? 4;
  const groupSize = body.group_size ?? 64;
  // A plain model directory; the same model and settings name the same
  // directory, which the producer refuses to overwrite.
  const outDir = join(storagePath("models", outputRoot), quantizedModelName(body.model_id, {
    bits, targetBpw: body.target_bpw, rotationSeed: body.rotate_weights ? body.rotation_seed ?? 42 : undefined }));
  const { jobId } = deps.submit("quantize", {
    model_id: body.model_id,
    out_dir: outDir,
    bits,
    group_size: groupSize,
    target_bpw: body.target_bpw,
    candidate_bits: body.candidate_bits,
    reference: body.reference,
    calibration_mix: body.calibration_mix,
    n_calibration: body.n_calibration,
    rotate_weights: body.rotate_weights,
    rotation_seed: body.rotation_seed,
  }, outDir);
  return Response.json({ ok: true, job_id: jobId, output_dir: outDir });
}
