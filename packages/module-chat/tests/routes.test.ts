// The tool-approval settings routes: the same approval store the chat's gate consumes, listed and revoked over HTTP.
import { afterEach, expect, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { isToolAlwaysAllowed, setToolAlwaysAllowed } from "../src/tool-approvals";
import { chatRoutes } from "./support";

const roots: string[] = [];
function temporary() { const root = mkdtempSync(join(tmpdir(), "mlx-chat-routes-")); roots.push(root); return root; }
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const request = (path: string, method = "GET", body?: unknown) => new Request(`http://local${path}`, {
  method, ...(body === undefined ? {} : { headers: { "content-type": "application/json" }, body: JSON.stringify(body) }),
});

test("tool settings list and revoke the same approval store consumed by chat", async () => {
  const root = temporary(), approvals = join(root, "settings/approvals.json"), other = join(root, "other.json");
  setToolAlwaysAllowed("write", approvals); setToolAlwaysAllowed("bash", approvals); setToolAlwaysAllowed("edit", other);
  const routes = chatRoutes({ sessionDir: join(root, "sessions"), toolApprovalsFile: approvals });
  expect(await (await routes.handle(request("/api/settings/tool-approvals")))!.json()).toEqual({ ok: true, alwaysAllow: ["bash", "write"] });
  expect(await (await routes.handle(request("/api/settings/tool-approvals", "DELETE", { tool: "bash" })))!.json())
    .toEqual({ ok: true, alwaysAllow: ["write"] });
  expect(isToolAlwaysAllowed("bash", approvals)).toBe(false);
  expect(isToolAlwaysAllowed("write", approvals)).toBe(true);
  expect(isToolAlwaysAllowed("edit", other)).toBe(true);
});

test("malformed settings reject without opening storage, and the routes answer only their declared methods", async () => {
  const root = temporary(), approvals = join(root, "absent/approvals.json");
  const routes = chatRoutes({ sessionDir: join(root, "sessions"), toolApprovalsFile: approvals });
  for (const body of [null, [], {}, { tool: 1 }, { tool: "" }]) expect((await routes.handle(request("/api/settings/tool-approvals", "DELETE", body)))!.status).toBe(400);
  expect((await routes.handle(new Request("http://local/api/settings/tool-approvals", { method: "DELETE", body: "{" })))!.status).toBe(400);
  expect(existsSync(approvals)).toBe(false);
  for (const [path, method] of [["/api/settings/tool-approvals", "POST"], ["/api/sessions/search", "POST"], ["/api/sessions/export", "DELETE"]] as const)
    expect(await routes.handle(request(path, method))).toBeNull();
});
