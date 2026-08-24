import { describe, expect, test } from "bun:test";
import { matchModelAdminRoute } from "../../src/serve/model-admin-routes";

describe("model admin route dispatch", () => {
  test("matches embeddings and adapter collection routes", () => {
    expect(matchModelAdminRoute("POST", "/v1/embeddings")).toEqual({ kind: "embeddings" });
    expect(matchModelAdminRoute("GET", "/v1/adapters/available")).toEqual({
      kind: "adapters-available",
    });
    expect(matchModelAdminRoute("GET", "/v1/adapters")).toEqual({ kind: "adapters-list" });
    expect(matchModelAdminRoute("POST", "/v1/adapters")).toEqual({ kind: "adapters-mount" });
  });

  test("extracts and decodes adapter ids", () => {
    expect(matchModelAdminRoute("DELETE", "/v1/adapters/team%2Fadapter")).toEqual({
      kind: "adapters-unmount",
      id: "team/adapter",
    });
  });

  test("rejects wrong methods and unrelated paths", () => {
    expect(matchModelAdminRoute("GET", "/v1/embeddings")).toBeNull();
    expect(matchModelAdminRoute("PATCH", "/v1/adapters/example")).toBeNull();
  });
});
