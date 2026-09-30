import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { isToolAlwaysAllowed, setToolAlwaysAllowed } from "../../src/chat/tool-approvals";
import { createManagementRoutes } from "../../src/server/management-routes";

const roots: string[] = [];
function temporary() {
  const root = mkdtempSync(join(tmpdir(), "mlx-management-")); roots.push(root); return root;
}
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const request = (path: string, method = "GET", body?: unknown) => new Request(`http://local${path}`, {
  method, ...(body === undefined ? {} : { headers: { "content-type": "application/json" }, body: JSON.stringify(body) }),
});

test("tool settings list and revoke the same approval store consumed by chat", async () => {
  const root = temporary(), approvals = join(root, "settings/approvals.json"), other = join(root, "other.json");
  setToolAlwaysAllowed("write", approvals); setToolAlwaysAllowed("bash", approvals); setToolAlwaysAllowed("edit", other);
  const routes = createManagementRoutes({ toolApprovalsFile: approvals });
  expect(await (await routes.handle(request("/api/settings/tool-approvals")))!.json()).toEqual({ ok: true, alwaysAllow: ["bash", "write"] });
  expect(await (await routes.handle(request("/api/settings/tool-approvals", "DELETE", { tool: "bash" })))!.json())
    .toEqual({ ok: true, alwaysAllow: ["write"] });
  expect(isToolAlwaysAllowed("bash", approvals)).toBe(false);
  expect(isToolAlwaysAllowed("write", approvals)).toBe(true);
  expect(isToolAlwaysAllowed("edit", other)).toBe(true);
});

test("malformed tool-approval requests reject without opening storage", async () => {
  const root = temporary(), approvals = join(root, "absent/approvals.json");
  const routes = createManagementRoutes({ toolApprovalsFile: approvals });
  for (const body of [null, [], {}, { tool: 1 }, { tool: "" }]) expect((await routes.handle(request("/api/settings/tool-approvals", "DELETE", body)))!.status).toBe(400);
  expect((await routes.handle(new Request("http://local/api/settings/tool-approvals", { method: "DELETE", body: "{" })))!.status).toBe(400);
  expect(existsSync(approvals)).toBe(false);
});

test("management matches only its owned methods and leaves HF credentials and uploads to publishing", async () => {
  const routes = createManagementRoutes({ toolApprovalsFile: join(temporary(), "approvals.json") });
  // Cache cleanup belongs to the models module; credentials and uploads to publishing.
  for (const [path, method] of [["/api/settings/tool-approvals", "POST"], ["/api/gc/plan", "GET"],
    ["/api/gc/execute", "POST"], ["/api/settings/hf-token", "GET"], ["/api/quantize/push", "POST"]])
    expect(await routes.handle(request(path!, method))).toBeNull();
});
