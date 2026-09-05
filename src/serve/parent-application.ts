import { handleStaticRoute } from "./static-routes";
import { STATIC_ROUTE_ASSETS } from "../web-assets";
import { createResponsesClient } from "./responses-client";
import type { DisposableResource } from "../contracts/resources";
import type { JobStore } from "../jobs/db";
import { handleLabRoute, matchLabRoute } from "./lab-routes";
import { handleAdminRoute, matchAdminRoute } from "./admin-routes";

/** CPU application state stays in the parent when model workers restart/evict.
 * Native inspection/merge/export routes still execute inside a model worker. */
export function createParentApplication(options: {
  acquireGpu(signal: AbortSignal): Promise<DisposableResource>;
  serverPort(): number | undefined;
  invalidateLibrary(): void;
  createJobStore?(): Promise<JobStore>;
}) {
  const responses = createResponsesClient();
  let jobs: Promise<JobStore> | undefined;
  let closed = false;
  const ensureJobs = () => {
    if (closed) return Promise.reject(new Error("application host is closed"));
    return jobs ??= (async () => {
      const { JobStore, registerRunner } = await import("../jobs");
      const store = options.createJobStore ? await options.createJobStore() : new JobStore();
      store.markZombies();
      const { datasetRunner } = await import("../dataset/job");
      registerRunner("dataset", datasetRunner);
      return store;
    })();
  };
  return {
    get responseStats() { return responses.stats; },
    async handle(request: Request, forward?: (request: Request) => Promise<Response>): Promise<Response | null> {
      const url = new URL(request.url);
      const staticResponse = handleStaticRoute(url, request, STATIC_ROUTE_ASSETS);
      if (staticResponse) return staticResponse;
      if (forward && request.method === "POST" && url.pathname === "/v1/responses")
        return responses.forward(request, forward);
      const admin = matchAdminRoute(request.method, url.pathname);
      if (admin) return handleAdminRoute(url, request, { ensureJobs, invalidateLibrary: options.invalidateLibrary });
      const route = matchLabRoute(request.method, url.pathname);
      if (route !== "quantize-submit" && route !== "finetune-submit" &&
          route !== "dataset-submit" && route !== "dataset-templates") return null;
      return handleLabRoute(url, request, { ensureJobs, acquireGpu: options.acquireGpu,
        serverPort: options.serverPort, invalidateLibrary: options.invalidateLibrary });
    },
    async close() {
      closed = true;
      if (!jobs) return;
      const store = await jobs;
      const { closeSubprocessJobs, closeInProcessJobs } = await import("../jobs");
      await Promise.all([closeSubprocessJobs(store), closeInProcessJobs(store)]);
      store.close();
    },
  };
}
