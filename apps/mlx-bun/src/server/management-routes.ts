import { listAlwaysAllowedTools, revokeToolAlwaysAllowed } from "../chat/tool-approvals";
import { errorResponse } from "./http";

export interface ManagementRouteOptions {
  /** Share this path with PiBackendOptions.paths.toolApprovalsFile. */
  toolApprovalsFile?: string;
}

/** HTTP policy over chat approval storage: the tools the user allowed for good, listed and revoked. */
export function createManagementRoutes(options: ManagementRouteOptions) {
  return { async handle(request: Request): Promise<Response | null> {
    const pathname = new URL(request.url).pathname;
    try {
      switch (`${request.method} ${pathname}`) {
        case "GET /api/settings/tool-approvals":
          return Response.json({ ok: true, alwaysAllow: listAlwaysAllowedTools(options.toolApprovalsFile) });
        case "DELETE /api/settings/tool-approvals": {
          const body: unknown = await request.json().catch(() => undefined);
          const tool = body && typeof body === "object" && !Array.isArray(body) && "tool" in body ? body.tool : undefined;
          if (typeof tool !== "string" || !tool)
            return Response.json({ ok: false, error: "tool required" }, { status: 400 });
          const file = revokeToolAlwaysAllowed(tool, options.toolApprovalsFile);
          return Response.json({ ok: true, alwaysAllow: Object.keys(file.allows).sort() });
        }
        default: return null;
      }
    } catch (error) {
      return errorResponse(error, `${request.method} ${pathname}`,
        (status, message) => Response.json({ ok: false, error: message }, { status }));
    }
  } };
}
