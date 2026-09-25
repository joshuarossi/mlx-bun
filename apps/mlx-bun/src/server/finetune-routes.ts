import { homedir } from "node:os";
import { join } from "node:path";
import { inspectDataset } from "../finetune/inspect";
import type { SubmitResult } from "../jobs/runner";

export interface FinetuneRouteDeps {
  submit(kind: "finetune", config: Record<string, unknown>, outputPath: string): SubmitResult;
}

/** HTTP owns request/output-path policy; the job child owns training. */
export function createFinetuneRoutes(deps: FinetuneRouteDeps,
  defaultAdapterPath = () => join(homedir(), ".cache/mlx-bun/adapters", `adapter-${Date.now()}-${crypto.randomUUID()}`)) {
  return { async handle(request: Request): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    if (request.method !== "POST" || !["/api/finetune/inspect-dataset", "/api/finetune/submit"].includes(path)) return null;
    const body: unknown = await request.json().catch(() => null);
    if (!body || typeof body !== "object" || Array.isArray(body))
      return Response.json({ ok: false, error: "expected a JSON object" }, { status: 400 });
    const config = body as Record<string, unknown>;
    if (path.endsWith("/inspect-dataset")) {
      if (config.path !== undefined && typeof config.path !== "string")
        return Response.json({ ok: false, error: "path must be a string" }, { status: 400 });
      return Response.json(await inspectDataset(config.path as string ?? ""));
    }
    if (typeof config.model_dir !== "string" || !config.model_dir || typeof config.data_dir !== "string" || !config.data_dir)
      return Response.json({ ok: false, error: "model_dir and data_dir required" }, { status: 400 });
    if (config.adapter_path != null && typeof config.adapter_path !== "string")
      return Response.json({ ok: false, error: "adapter_path must be a string" }, { status: 400 });
    const adapterPath = config.adapter_path as string || defaultAdapterPath();
    const { jobId } = deps.submit("finetune", { ...config, adapter_path: adapterPath }, adapterPath);
    return Response.json({ ok: true, job_id: jobId, adapter_path: adapterPath });
  } };
}
