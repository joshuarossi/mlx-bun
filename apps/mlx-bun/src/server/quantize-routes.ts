import { inspectModel } from "../quantize/inspect";
import type { SubmitResult } from "../jobs/runner";

export interface QuantizeRouteDeps {
  submit(kind: "quantize", config: Record<string, unknown>, outputPath: string): SubmitResult;
}
export function createQuantizeRoutes(deps: QuantizeRouteDeps) {
  return { async handle(request: Request): Promise<Response | null> {
    const url = new URL(request.url);
    if (request.method !== "POST") return null;
    switch (url.pathname) {
      case "/api/quantize/inspect": {
        const body = await request.json().catch(() => ({}));
        return Response.json(await inspectModel(body?.model_id ?? ""));
      }
      case "/api/model/resolve-folder":
      case "/api/quantize/resolve-folder": return resolveModelFolder(request);
      case "/api/quantize/submit": return submitQuantize(request, deps);
      default: return null;
    }
  } };
}

export async function resolveModelFolder(request: Request): Promise<Response> {
  const body = (await request.json().catch(() => ({}))) as {
    folder_name?: string;
    rel_path?: string;
  };
  const { statSync, readdirSync, readFileSync } = await import("node:fs");
  const { join } = await import("node:path");
  const { homedir } = await import("node:os");
  const hubRoot = process.env.HF_HUB_CACHE ??
    (process.env.HF_HOME
      ? join(process.env.HF_HOME, "hub")
      : join(homedir(), ".cache/huggingface/hub"));
  const roots = [hubRoot, join(homedir(), ".cache/mlx-bun")];
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

  for (const root of roots) {
    if (folder && hasConfig(join(root, folder))) {
      return Response.json({ ok: true, path: join(root, folder) });
    }
  }

  const { Registry } = await import("@mlx-bun/hub/registry");
  const registry = new Registry();
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

async function submitQuantize(request: Request, deps: QuantizeRouteDeps): Promise<Response> {
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
  const { homedir } = await import("node:os");
  const { join } = await import("node:path");
  const { mkdirSync, writeFileSync } = await import("node:fs");
  const { createHash } = await import("node:crypto");
  const bits = body.bits ?? 4;
  const groupSize = body.group_size ?? 64;
  const snapshotMatch = body.model_id.match(/(models--[^/]+)\/snapshots\//);
  let org = "local";
  let name: string;
  if (snapshotMatch) {
    const parts = snapshotMatch[1]!.split("--");
    org = parts[1] ?? "local";
    name = parts.slice(2).join("--");
  } else if (
    body.model_id.includes("/") &&
    !body.model_id.startsWith("/") &&
    !body.model_id.startsWith("~")
  ) {
    const segments = body.model_id.split("/");
    org = segments[0]!;
    name = segments.slice(1).join("-");
  } else {
    name = body.model_id.split("/").filter(Boolean).at(-1) ?? "model";
  }
  name = (name || "model").replace(/[^a-z0-9_.-]/gi, "");
  org = (org || "local").replace(/[^a-z0-9_.-]/gi, "");
  const suffix = `${body.target_bpw ? `mixed-${body.target_bpw}bpw` : `${bits}bit`}` +
    `${body.rotate_weights ? `-rot${body.rotation_seed ?? 42}` : ""}`;
  const quantRepo = `${name}-OptiQ-${suffix}`;
  const hubRoot = process.env.HF_HUB_CACHE ??
    (process.env.HF_HOME
      ? join(process.env.HF_HOME, "hub")
      : join(homedir(), ".cache/huggingface/hub"));
  const repoDir = join(hubRoot, `models--${org}--${quantRepo}`);
  const snapshotHash = createHash("sha1").update(`${org}/${quantRepo}`).digest("hex");
  const outDir = join(repoDir, "snapshots", snapshotHash);
  try {
    mkdirSync(join(repoDir, "refs"), { recursive: true });
    writeFileSync(join(repoDir, "refs", "main"), snapshotHash);
  } catch {}
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
