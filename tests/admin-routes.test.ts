import { describe, expect, test } from "bun:test";
import { matchAdminRoute } from "../src/serve/admin-routes";

describe("admin route dispatch", () => {
  test("matches fixed settings, gc, and jobs routes", () => {
    expect(matchAdminRoute("GET", "/api/settings/hf-token")).toEqual({ kind: "hf-token-get" });
    expect(matchAdminRoute("POST", "/api/settings/hf-token")).toEqual({ kind: "hf-token-set" });
    expect(matchAdminRoute("GET", "/api/settings/tool-approvals")).toEqual({ kind: "tool-approvals-get" });
    expect(matchAdminRoute("DELETE", "/api/settings/tool-approvals")).toEqual({ kind: "tool-approvals-delete" });
    expect(matchAdminRoute("GET", "/api/gc/plan")).toEqual({ kind: "gc-plan" });
    expect(matchAdminRoute("POST", "/api/gc/execute")).toEqual({ kind: "gc-execute" });
    expect(matchAdminRoute("GET", "/api/jobs")).toEqual({ kind: "jobs-list" });
  });

  test("extracts push artifact kinds", () => {
    expect(matchAdminRoute("POST", "/api/quantize/push")).toEqual({
      kind: "push",
      artifactKind: "quantize",
    });
    expect(matchAdminRoute("POST", "/api/dataset/push")).toEqual({
      kind: "push",
      artifactKind: "dataset",
    });
  });

  test("extracts job ids and stream mode", () => {
    expect(matchAdminRoute("GET", "/api/jobs/job-12")).toEqual({
      kind: "job-get",
      jobId: "job-12",
      stream: false,
    });
    expect(matchAdminRoute("GET", "/api/jobs/job-12/stream")).toEqual({
      kind: "job-get",
      jobId: "job-12",
      stream: true,
    });
  });

  test("rejects wrong methods and unrelated paths", () => {
    expect(matchAdminRoute("GET", "/api/gc/execute")).toBeNull();
    expect(matchAdminRoute("POST", "/api/jobs/job-12")).toBeNull();
    expect(matchAdminRoute("GET", "/v1/models")).toBeNull();
  });
});
