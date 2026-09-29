import type { ModelCatalog } from "@mlx-bun/app-core";

/** `POST /api/model/resolve-folder`: where a folder the browser's picker selected lives on disk. The fine-tune wizard's picker uses it; the quantize module answers the same question at its own path. */
export function createModelFolderRoutes(catalog: Pick<ModelCatalog, "locate">) {
  return { async handle(request: Request): Promise<Response | null> {
    if (request.method !== "POST" || new URL(request.url).pathname !== "/api/model/resolve-folder") return null;
    const body = (await request.json().catch(() => ({}))) as { folder_name?: string; rel_path?: string };
    const found = await catalog.locate({ name: body.folder_name ?? "", relPath: body.rel_path ?? "" });
    if (!found) return Response.json({ ok: false, error: "Couldn't locate this folder on disk — paste the path instead." });
    return Response.json({ ok: true, path: found.directory, ...(found.id !== undefined ? { repo_id: found.id } : {}),
      ...(found.type !== undefined ? { model_type: found.type } : {}) });
  } };
}
