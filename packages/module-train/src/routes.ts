import { join } from "node:path";
import type { JobService, RouteHandler, StorageService } from "@mlx-bun/app-core";
import { inspectDataset } from "./inspect";

export interface TrainRouteServices {
  readonly jobs: Pick<JobService, "submit">;
  readonly storage: Pick<StorageService, "path">;
}

/** The two POST routes the browser's fine-tune wizard calls. HTTP owns the request and output-path policy; the job
 * child owns training. An explicit `adapter_path` wins; otherwise a fresh directory in the `adapters` storage entry. */
export function createTrainHandlers(services: TrainRouteServices,
  defaultAdapterPath = () => join(services.storage.path("adapters"), `adapter-${Date.now()}-${crypto.randomUUID()}`),
): Record<"inspect-dataset" | "submit", RouteHandler> {
  const object = async (request: Request): Promise<Record<string, unknown> | Response> => {
    const body: unknown = await request.json().catch(() => null);
    return body && typeof body === "object" && !Array.isArray(body) ? body as Record<string, unknown>
      : Response.json({ ok: false, error: "expected a JSON object" }, { status: 400 });
  };
  return {
    async "inspect-dataset"(request) {
      const config = await object(request);
      if (config instanceof Response) return config;
      if (config.path !== undefined && typeof config.path !== "string")
        return Response.json({ ok: false, error: "path must be a string" }, { status: 400 });
      return Response.json(await inspectDataset(config.path as string ?? ""));
    },
    async submit(request) {
      const config = await object(request);
      if (config instanceof Response) return config;
      if (typeof config.model_dir !== "string" || !config.model_dir || typeof config.data_dir !== "string" || !config.data_dir)
        return Response.json({ ok: false, error: "model_dir and data_dir required" }, { status: 400 });
      if (config.adapter_path != null && typeof config.adapter_path !== "string")
        return Response.json({ ok: false, error: "adapter_path must be a string" }, { status: 400 });
      const adapterPath = config.adapter_path as string || defaultAdapterPath();
      const job = await services.jobs.submit({ kind: "finetune", config: { ...config, adapter_path: adapterPath }, outputPath: adapterPath });
      return Response.json({ ok: true, job_id: job.id, adapter_path: adapterPath });
    },
  };
}
