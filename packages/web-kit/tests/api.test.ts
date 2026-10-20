// The JSON client over a fixture fetch: envelope unwrapping, root and module paths, absolute bases, and transport failure.
import { describe, expect, it } from "bun:test";
import { createApi, errorOf, requestJson, UNREACHABLE } from "../src";
import { fakeFetch } from "../src/testing";

describe("requestJson", () => {
  it("unwraps a nested {error:{message}} object to a plain string", async () => {
    const fetch = fakeFetch({ "/v1/x": () => Response.json({ error: { message: "model not found", code: 404 } }, { status: 404 }) });
    const d = await requestJson("/v1/x", {}, fetch);
    expect(d).toEqual({ ok: false, error: "model not found" });
  });
  it("falls back to a stringified error object when no message field exists", async () => {
    const fetch = fakeFetch({ "/v1/x": () => Response.json({ error: { code: 500 } }, { status: 500 }) });
    const d = await requestJson("/v1/x", {}, fetch);
    expect(d.error).toBe('{"code":500}');
  });
  it("passes a plain string error through and keeps a success envelope's fields", async () => {
    const fetch = fakeFetch({ "/a": () => Response.json({ ok: false, error: "plain" }, { status: 400 }), "/b": { ok: true, job_id: "j1" } });
    expect((await requestJson("/a", {}, fetch)).error).toBe("plain");
    expect(await requestJson("/b", {}, fetch)).toEqual({ ok: true, job_id: "j1" });
  });
  it("synthesizes an HTTP-status error when the body is empty or unparseable and the response was not ok", async () => {
    const fetch = fakeFetch({ "/empty": () => new Response("", { status: 503 }), "/html": () => new Response("<h1>Bad gateway</h1>", { status: 502 }) });
    expect(await requestJson("/empty", {}, fetch)).toEqual({ ok: false, error: "HTTP 503" });
    expect(await requestJson("/html", {}, fetch)).toEqual({ ok: false, error: "<h1>Bad gateway</h1>" });
  });
  it("sends JSON bodies with POST by default and the method given otherwise", async () => {
    const fetch = fakeFetch({ "POST /p": { ok: true }, "DELETE /d": { ok: true } });
    await requestJson("/p", { body: { a: 1 } }, fetch);
    await requestJson("/d", { method: "DELETE", body: { tool: "bash" } }, fetch);
    expect(fetch.calls).toEqual([{ method: "POST", url: "/p", body: { a: 1 } }, { method: "DELETE", url: "/d", body: { tool: "bash" } }]);
  });
  it("throws on transport failure", async () => {
    const fetch = (async () => { throw new TypeError("Failed to fetch"); }) as unknown as typeof globalThis.fetch;
    await expect(requestJson("/x", {}, fetch)).rejects.toThrow("Failed to fetch");
  });
});

describe("createApi", () => {
  it("resolves module paths under the base and root paths on the base's origin", async () => {
    const fetch = fakeFetch({ "/api/metrics/history": { runs: [] }, "/library": { models: [] } });
    const api = createApi("/api/metrics", { fetch });
    expect(api.url("history")).toBe("/api/metrics/history");
    expect(api.url("/library")).toBe("/library");
    await api.get("history"); await api.get("/library");
    expect(fetch.calls.map((call) => call.url)).toEqual(["/api/metrics/history", "/library"]);
  });
  it("keeps an absolute base's origin for root paths (a native webview over a remote server)", () => {
    const api = createApi("http://10.0.0.12:8080/api/models/");
    expect(api.url("/library")).toBe("http://10.0.0.12:8080/library");
    expect(api.url("local")).toBe("http://10.0.0.12:8080/api/models/local");
  });
  it("answers a transport failure as an envelope instead of throwing", async () => {
    const fetch = (async () => { throw new TypeError("Failed to fetch"); }) as unknown as typeof globalThis.fetch;
    const api = createApi("/api/x", { fetch });
    const d = await api.get("y");
    expect(d.ok).toBe(false);
    expect(d.error).toBe(UNREACHABLE);
    expect(errorOf(d)).toBe(UNREACHABLE);
  });
  it("reports a cancelled request as cancelled, not unreachable", async () => {
    const controller = new AbortController();
    const fetch = (async (_url: string, init?: RequestInit) => { init?.signal?.throwIfAborted(); return Response.json({ ok: true }); }) as unknown as typeof globalThis.fetch;
    const api = createApi("/api/x", { fetch });
    controller.abort();
    expect((await api.get("y", { signal: controller.signal })).error).toBe("cancelled");
  });
  it("post sends an empty object when no body is given, del sends one only when given", async () => {
    const fetch = fakeFetch({ "POST /api/x/go": { ok: true }, "DELETE /api/x/one": { ok: true } });
    const api = createApi("/api/x", { fetch });
    await api.post("go"); await api.del("one");
    expect(fetch.calls).toEqual([{ method: "POST", url: "/api/x/go", body: {} }, { method: "DELETE", url: "/api/x/one", body: undefined }]);
  });
  it("errorOf prefers error, then message, then the fallback", () => {
    expect(errorOf({ error: "a", message: "b" })).toBe("a");
    expect(errorOf({ message: "b" })).toBe("b");
    expect(errorOf({}, "fallback")).toBe("fallback");
  });
});
