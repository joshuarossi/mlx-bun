import { join } from "node:path";
import type { JobService, RouteHandler, StorageService } from "@mlx-bun/app-core";
import { getTemplate, TEMPLATES } from "./registry";

/** The job kind the manifest declares and the routes submit. */
export const DATASET_JOB = "dataset";

/** Template discovery and submission. Each submission gets its own directory under the module's `datasets` storage entry. */
export function createDatasetHandlers(deps: { jobs: Pick<JobService, "submit">; storage: Pick<StorageService, "path"> }):
  { templates: RouteHandler; submit: RouteHandler } {
  return {
    templates: () => Response.json({ templates: TEMPLATES }),
    async submit(request) {
      const body = await request.json().catch(() => ({}));
      const id = body?.template_id;
      if (typeof id !== "string" || !getTemplate(id))
        return Response.json({ ok: false, error: `unknown template ${JSON.stringify(id)}` }, { status: 400 });
      const outDir = join(deps.storage.path("datasets"),
        `dataset-${id.replace(/[^a-z0-9_-]/gi, "")}-${Date.now()}-${crypto.randomUUID()}`);
      const job = await deps.jobs.submit({ kind: DATASET_JOB, outputPath: outDir,
        config: { template_id: id, inputs: body.inputs ?? {}, output_dir: outDir, model_name: body.model_name ?? "local" } });
      return Response.json({ ok: true, job_id: job.id, output_dir: outDir });
    },
  };
}
