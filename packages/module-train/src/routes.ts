import { lstat, realpath } from "node:fs/promises";
import { dirname, join, resolve, sep } from "node:path";
import type { JobService, RouteHandler, StorageService } from "@mlx-bun/app-core";
import { inspectDataset } from "./inspect";

export interface TrainRouteServices {
  readonly jobs: Pick<JobService, "submit">;
  readonly storage: Pick<StorageService, "path">;
}

const inside = (path: string, root: string) => path.startsWith(root.endsWith(sep) ? root : root + sep);

/** An `adapter_path` a request names, kept strictly inside the adapters store: a relative path is taken under it,
 * and the deepest part that already exists must resolve inside the store through any links. Undefined otherwise. */
async function containedAdapterPath(store: string, requested: string): Promise<string | undefined> {
  const root = resolve(store), target = resolve(root, requested);
  if (!inside(target, root)) return undefined;
  let existing = target;
  while (existing !== root && !await lstat(existing).then(() => true, () => false)) existing = dirname(existing);
  // Nothing of the store exists yet: the trainer creates the whole path.
  if (existing === root && !await lstat(root).then(() => true, () => false)) return target;
  try {
    const [real, realRoot] = await Promise.all([realpath(existing), realpath(root)]);
    return real === realRoot || inside(real, realRoot) ? target : undefined;
  } catch { return undefined; }
}

/** The two POST routes the browser's fine-tune wizard calls. HTTP owns the request and output-path policy; the job
 * child owns training. An explicit `adapter_path` must lie inside the `adapters` storage entry (a relative one is
 * taken under it); otherwise a fresh directory there. The `train` verb's `--adapter-path` is not limited. */
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
      let adapterPath: string;
      if (config.adapter_path) {
        const store = services.storage.path("adapters");
        const contained = await containedAdapterPath(store, config.adapter_path as string);
        if (!contained) return Response.json({ ok: false, error: `adapter_path must be inside the adapters directory (${store})` }, { status: 400 });
        adapterPath = contained;
      } else adapterPath = defaultAdapterPath();
      const job = await services.jobs.submit({ kind: "finetune", config: { ...config, adapter_path: adapterPath }, outputPath: adapterPath });
      return Response.json({ ok: true, job_id: job.id, adapter_path: adapterPath });
    },
  };
}
