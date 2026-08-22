import type { JobStore } from "../jobs";

export interface LabRouteDeps {
  ensureJobs(): Promise<JobStore>;
  serverPort(): number | undefined;
  invalidateLibrary(): void;
}

export type LabRoute =
  | "dataset-templates"
  | "dataset-submit"
  | "quantize-inspect"
  | "model-resolve-folder"
  | "quantize-submit"
  | "finetune-inspect-dataset"
  | "finetune-submit"
  | "finetune-merge"
  | "finetune-export";

export function matchLabRoute(method: string, pathname: string): LabRoute | null {
  switch (`${method} ${pathname}`) {
    case "GET /api/dataset/templates": return "dataset-templates";
    case "POST /api/dataset/submit": return "dataset-submit";
    case "POST /api/quantize/inspect": return "quantize-inspect";
    case "POST /api/quantize/resolve-folder":
    case "POST /api/model/resolve-folder":
      return "model-resolve-folder";
    case "POST /api/quantize/submit": return "quantize-submit";
    case "POST /api/finetune/inspect-dataset": return "finetune-inspect-dataset";
    case "POST /api/finetune/submit": return "finetune-submit";
    case "POST /api/finetune/merge": return "finetune-merge";
    case "POST /api/finetune/export": return "finetune-export";
    default: return null;
  }
}

export async function handleLabRoute(
  url: URL,
  request: Request,
  deps: LabRouteDeps,
): Promise<Response | null> {
  switch (matchLabRoute(request.method, url.pathname)) {
    case "dataset-templates": {
      const { TEMPLATES } = await import("../dataset");
      return Response.json({ templates: TEMPLATES });
    }
    case "dataset-submit": {
      const body = (await request.json().catch(() => ({}))) as {
        template_id?: string;
        inputs?: Record<string, unknown>;
        model_name?: string;
      };
      const { getTemplate } = await import("../dataset");
      if (!body.template_id || !getTemplate(body.template_id)) {
        return Response.json(
          { ok: false, error: `unknown template ${body.template_id}` },
          { status: 400 },
        );
      }
      const store = await deps.ensureJobs();
      const { submitInProcess } = await import("../jobs");
      const { homedir } = await import("node:os");
      const safe = body.template_id.replace(/[^a-z0-9_-]/gi, "");
      const outDir = `${homedir()}/.cache/mlx-bun/datasets/dataset-${safe}-${Date.now()}`;
      const { jobId } = submitInProcess(store, "dataset", {
        template_id: body.template_id,
        inputs: body.inputs ?? {},
        output_dir: outDir,
        api_url: `http://127.0.0.1:${deps.serverPort()}`,
        model_name: body.model_name ?? "local",
      }, outDir);
      return Response.json({ ok: true, job_id: jobId, output_dir: outDir });
    }
    case "quantize-inspect": {
      const body = (await request.json().catch(() => ({}))) as { model_id?: string };
      const { inspectModel } = await import("../quantize");
      return Response.json(await inspectModel(body.model_id ?? ""));
    }
    case "model-resolve-folder":
      return resolveModelFolder(request);
    case "quantize-submit":
      return submitQuantize(request, deps);
    case "finetune-inspect-dataset": {
      const body = (await request.json().catch(() => ({}))) as { path?: string };
      const { inspectDataset } = await import("../train");
      return Response.json(await inspectDataset(body.path ?? ""));
    }
    case "finetune-submit": {
      const body = (await request.json().catch(() => ({}))) as Record<string, unknown>;
      if (!body.model_dir || !body.data_dir) {
        return Response.json(
          { ok: false, error: "model_dir and data_dir required" },
          { status: 400 },
        );
      }
      const store = await deps.ensureJobs();
      const { submitSubprocess } = await import("../jobs");
      const { homedir } = await import("node:os");
      const adapterPath = (body.adapter_path as string) ||
        `${homedir()}/.cache/mlx-bun/adapters/adapter-${Date.now()}`;
      const { jobId } = submitSubprocess(
        store,
        "finetune",
        { ...body, adapter_path: adapterPath },
        adapterPath,
      );
      return Response.json({ ok: true, job_id: jobId, adapter_path: adapterPath });
    }
    case "finetune-merge": {
      const body = (await request.json().catch(() => ({}))) as {
        adapter_a?: string;
        adapter_b?: string;
        scales?: number[];
      };
      if (!body.adapter_a || !body.adapter_b) {
        return Response.json(
          { ok: false, error: "adapter_a and adapter_b required" },
          { status: 400 },
        );
      }
      try {
        const { mergeAdapters } = await import("../train");
        const { homedir } = await import("node:os");
        const mergedPath = `${homedir()}/.cache/mlx-bun/adapters/merged-${Date.now()}`;
        const stats = await mergeAdapters(
          [body.adapter_a, body.adapter_b],
          mergedPath,
          body.scales,
        );
        return Response.json({ ok: true, merged_path: mergedPath, stats });
      } catch (error) {
        return Response.json({ ok: false, error: (error as Error).message }, { status: 400 });
      }
    }
    case "finetune-export": {
      const body = (await request.json().catch(() => ({}))) as {
        base_model?: string;
        adapter_path?: string;
        method?: string;
      };
      if (!body.base_model || !body.adapter_path) {
        return Response.json(
          { ok: false, error: "base_model and adapter_path required" },
          { status: 400 },
        );
      }
      try {
        const { exportAdapter } = await import("../train");
        const { homedir } = await import("node:os");
        const exportPath = `${homedir()}/.cache/mlx-bun/exports/export-${Date.now()}`;
        const manifest = await exportAdapter(
          exportPath,
          body.base_model,
          body.adapter_path,
          body.method,
        );
        return Response.json({ ok: true, export_path: exportPath, manifest });
      } catch (error) {
        return Response.json({ ok: false, error: (error as Error).message }, { status: 400 });
      }
    }
    default:
      return null;
  }
}

async function resolveModelFolder(request: Request): Promise<Response> {
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

  const { Registry } = await import("../registry");
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

async function submitQuantize(request: Request, deps: LabRouteDeps): Promise<Response> {
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
  const store = await deps.ensureJobs();
  const { submitSubprocess } = await import("../jobs");
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
  const { jobId } = submitSubprocess(store, "quantize", {
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
  }, outDir, {
    onComplete: () => deps.invalidateLibrary(),
  });
  return Response.json({ ok: true, job_id: jobId, output_dir: outDir });
}
