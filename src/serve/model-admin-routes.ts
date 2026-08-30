import type { ServerContext } from "./model-host";
import type { GenerationGateway } from "./generation-gateway";
import { embedMany, isEmbeddingModel } from "../embed";
import { listAvailableAdapters } from "../lora";

export type ModelAdminRoute =
  | { kind: "embeddings" }
  | { kind: "adapters-available" }
  | { kind: "adapters-list" }
  | { kind: "adapters-mount" }
  | { kind: "adapters-unmount"; id: string };

export function matchModelAdminRoute(method: string, pathname: string): ModelAdminRoute | null {
  switch (`${method} ${pathname}`) {
    case "POST /v1/embeddings": return { kind: "embeddings" };
    case "GET /v1/adapters/available": return { kind: "adapters-available" };
    case "GET /v1/adapters": return { kind: "adapters-list" };
    case "POST /v1/adapters": return { kind: "adapters-mount" };
  }
  if (method === "DELETE" && pathname.startsWith("/v1/adapters/")) {
    return {
      kind: "adapters-unmount",
      id: decodeURIComponent(pathname.slice("/v1/adapters/".length)),
    };
  }
  return null;
}

export async function handleModelAdminRoute(
  url: URL,
  request: Request,
  ctx: ServerContext,
  gateway: Pick<GenerationGateway, "runExclusive">,
): Promise<Response | null> {
  const route = matchModelAdminRoute(request.method, url.pathname);
  if (!route) return null;

  switch (route.kind) {
    case "embeddings": {
      if (!isEmbeddingModel(ctx.model)) {
        return Response.json({
          error: {
            message: `served model "${ctx.modelId}" is not an embedding model; ` +
              "serve an embedding model (e.g. Qwen3-Embedding) to use /v1/embeddings",
            type: "invalid_request_error",
          },
        }, { status: 400 });
      }
      let body: { input?: string | string[]; instruction?: string };
      try {
        body = (await request.json()) as typeof body;
      } catch {
        return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
      }
      const inputs = Array.isArray(body.input)
        ? body.input
        : body.input != null
          ? [body.input]
          : [];
      if (inputs.length === 0 || !inputs.every((input) => typeof input === "string")) {
        return Response.json({
          error: {
            message: "`input` must be a string or array of strings",
            type: "invalid_request_error",
          },
        }, { status: 400 });
      }
      const instruction = typeof body.instruction === "string" ? body.instruction : undefined;
      const results = embedMany(ctx.model, ctx.tokenizer, inputs, instruction);
      let totalTokens = 0;
      const data = results.map((result, index) => {
        totalTokens += result.tokens;
        return { object: "embedding", index, embedding: Array.from(result.vector) };
      });
      return Response.json({
        object: "list",
        data,
        model: ctx.modelId,
        usage: { prompt_tokens: totalTokens, total_tokens: totalTokens },
      });
    }

    case "adapters-available": {
      const { homedir } = await import("node:os");
      const stores = [
        `${homedir()}/.cache/mlx-bun-finetunes`,
        `${homedir()}/.cache/mlx-bun/adapters`,
      ];
      const mounted = new Set(ctx.adapters.list().map((adapter) => adapter.id));
      const bareName = (value: string) => value.split("/").pop()!.toLowerCase();
      const servedName = bareName(ctx.modelId);
      const adapters = (await listAvailableAdapters(stores)).map((adapter) => ({
        id: adapter.id,
        path: adapter.path,
        rank: adapter.rank,
        scale: adapter.scale,
        base_model: adapter.baseModel,
        mounted: mounted.has(adapter.id),
        compatible: adapter.baseModel == null || bareName(adapter.baseModel) === servedName,
      }));
      return Response.json({ adapters });
    }

    case "adapters-list":
      return Response.json({
        adapters: ctx.adapters.list().map((adapter) => ({
          id: adapter.id,
          path: adapter.path,
          rank: adapter.rank,
          scale: adapter.scale,
          size_bytes: adapter.sizeBytes,
          mounted_layers: adapter.mountedLayers,
          ram_bytes: adapter.ramBytes,
        })),
      });

    case "adapters-mount": {
      let body: { id?: string; path?: string };
      try {
        body = (await request.json()) as typeof body;
      } catch {
        return Response.json({ error: { message: "invalid JSON body" } }, { status: 400 });
      }
      if (!body.id || !body.path) {
        return Response.json({ error: { message: "id and path required" } }, { status: 400 });
      }
      try {
        const info = await gateway.runExclusive(() =>
          ctx.adapters.mount(body.id!, body.path!),
        );
        return Response.json({
          id: info.id,
          mounted_layers: info.mountedLayers,
          rank: info.rank,
          scale: info.scale,
          ram_bytes: info.ramBytes,
        });
      } catch (error) {
        return Response.json({ error: { message: (error as Error).message } }, { status: 400 });
      }
    }

    case "adapters-unmount": {
      const removed = await gateway.runExclusive(async () => ctx.adapters.unmount(route.id));
      return removed > 0
        ? Response.json({ id: route.id, removed_layers: removed })
        : Response.json(
            { error: { message: `adapter ${route.id} not mounted` } },
            { status: 404 },
          );
    }
  }
}
