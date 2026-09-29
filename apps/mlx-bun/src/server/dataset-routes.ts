import { join } from "node:path";
import { getTemplate, TEMPLATES } from "../dataset/registry";
import type { SubmitResult } from "../jobs/runner";
import { storagePath } from "../storage/paths";

export function createDatasetRoutes(deps: {
  submit(config: Record<string, unknown>, outputPath: string): SubmitResult;
  serverPort(): number;
  outputRoot?: string; // storage root; datasets land in its datasets/ (default ~/.mlx-bun/datasets)
}) {
  return { async handle(request: Request): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    if (request.method === "GET" && path === "/api/dataset/templates") return Response.json({ templates: TEMPLATES });
    if (request.method !== "POST" || path !== "/api/dataset/submit") return null;
    const body = await request.json().catch(() => ({}));
    const id = body?.template_id;
    if (typeof id !== "string" || !getTemplate(id))
      return Response.json({ ok: false, error: `unknown template ${JSON.stringify(id)}` }, { status: 400 });
    const outDir = join(storagePath("datasets", deps.outputRoot),
      `dataset-${id.replace(/[^a-z0-9_-]/gi, "")}-${Date.now()}-${crypto.randomUUID()}`);
    const result = deps.submit({ template_id: id, inputs: body.inputs ?? {}, output_dir: outDir,
      api_url: `http://127.0.0.1:${deps.serverPort()}`, model_name: body.model_name ?? "local" }, outDir);
    return Response.json({ ok: true, job_id: result.jobId, output_dir: outDir });
  } };
}
