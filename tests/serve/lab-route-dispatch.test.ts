import { describe, expect, test } from "bun:test";
import {
  handleLabRoute,
  matchLabRoute,
  type LabRoute,
} from "../../src/serve/lab-routes";

const routes: Array<[string, string, LabRoute]> = [
  ["GET", "/api/dataset/templates", "dataset-templates"],
  ["POST", "/api/dataset/submit", "dataset-submit"],
  ["POST", "/api/quantize/inspect", "quantize-inspect"],
  ["POST", "/api/quantize/resolve-folder", "model-resolve-folder"],
  ["POST", "/api/model/resolve-folder", "model-resolve-folder"],
  ["POST", "/api/quantize/submit", "quantize-submit"],
  ["POST", "/api/finetune/inspect-dataset", "finetune-inspect-dataset"],
  ["POST", "/api/finetune/submit", "finetune-submit"],
  ["POST", "/api/finetune/merge", "finetune-merge"],
  ["POST", "/api/finetune/export", "finetune-export"],
];

describe("Lab route dispatch", () => {
  test.each(routes)("matches %s %s", (method, pathname, expected) => {
    expect(matchLabRoute(method, pathname)).toBe(expected);
  });

  test("rejects wrong methods and unrelated paths", () => {
    expect(matchLabRoute("GET", "/api/quantize/submit")).toBeNull();
    expect(matchLabRoute("POST", "/v1/chat/completions")).toBeNull();
  });

  test("validates job submissions before opening the job store", async () => {
    const deps = {
      ensureJobs: async () => { throw new Error("job store should not open"); },
      serverPort: () => 8080,
      invalidateLibrary: () => {},
    };
    const request = new Request("http://localhost/api/quantize/submit", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{}",
    });
    const response = await handleLabRoute(new URL(request.url), request, deps);
    expect(response?.status).toBe(400);
    expect(await response?.json()).toEqual({ ok: false, error: "model_id required" });
  });
});
