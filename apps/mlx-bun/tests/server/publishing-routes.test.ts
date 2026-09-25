import { afterEach, expect, test } from "bun:test";
import { chmodSync, mkdirSync, mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createHfCredentials } from "../../src/publishing/credentials";
import { createPublisher } from "../../src/publishing/upload";
import { createPublishingRoutes } from "../../src/server/publishing-routes";
import { pendingRoute } from "../../src/server/start";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function storage() {
  const root = mkdtempSync(join(tmpdir(), "mlx-publishing-")); roots.push(root);
  const environment = { HOME: root, HF_TOKEN: "" };
  const tokenFile = join(root, "app", "hf.json"), cacheTokenPath = join(root, "cache-token");
  return { root, environment, tokenFile, cacheTokenPath, credentials: createHfCredentials({ environment, tokenFile, cacheTokenPath }) };
}
const post = (path: string, body: unknown, signal?: AbortSignal) => new Request(`http://local${path}`, {
  method: "POST", body: JSON.stringify(body), signal,
});
const noUpload = async (): Promise<never> => { throw new Error("unexpected upload"); };

test("saved token wins over trimmed environment and shared HF cache without touching user storage", () => {
  const { credentials, environment, tokenFile, cacheTokenPath } = storage();
  expect(credentials.get()).toBeNull();
  writeFileSync(cacheTokenPath, " cache-secret \n");
  expect(credentials.get()).toBe("cache-secret");
  environment.HF_TOKEN = " env-secret \n";
  expect(credentials.get()).toBe("env-secret");
  credentials.save(" saved-secret \n");
  expect(credentials.get()).toBe("saved-secret");
  expect(statSync(tokenFile).mode & 0o777).toBe(0o600);
  const saved = JSON.parse(readFileSync(tokenFile, "utf8"));
  expect(saved.token).toBe("saved-secret"); expect(Number.isNaN(Date.parse(saved.savedAt))).toBe(false);
  chmodSync(tokenFile, 0o644);
  credentials.save("replacement");
  expect(statSync(tokenFile).mode & 0o777).toBe(0o600);
  expect(credentials.get()).toBe("replacement");
  for (const bad of ["{", "null", "[]", '{"token":4}', '{"token":" "}']) {
    writeFileSync(tokenFile, bad);
    expect(credentials.get()).toBe("env-secret");
  }
  environment.HF_TOKEN = " \n";
  expect(credentials.get()).toBe("cache-secret");
  expect(() => credentials.save("  ")).toThrow("token is empty");
});

test("injected environment supplies both default storage locations", () => {
  const { root, environment } = storage();
  const credentials = createHfCredentials({ environment });
  mkdirSync(join(root, ".cache", "huggingface"), { recursive: true });
  writeFileSync(join(root, ".cache", "huggingface", "token"), "cache-only");
  expect(credentials.get()).toBe("cache-only");
  credentials.save("app-only");
  expect(JSON.parse(readFileSync(join(root, ".mlx-bun", "hf.json"), "utf8")).token).toBe("app-only");
});

test("token settings return presence only, save trimmed tokens, and contain write failures", async () => {
  const { credentials, tokenFile } = storage();
  const routes = createPublishingRoutes({ credentials, publish: noUpload });
  const get = () => routes.handle(new Request("http://local/api/settings/hf-token"));
  expect(await (await get())!.json()).toEqual({ ok: true, hasToken: false });
  expect(await (await routes.handle(post("/api/settings/hf-token", { token: " secret " })))!.json()).toEqual({ ok: true });
  expect(await (await get())!.json()).toEqual({ ok: true, hasToken: true });
  expect(readFileSync(tokenFile, "utf8")).toContain('"token": "secret"');
  const broken = createPublishingRoutes({ credentials: { get: () => null, save: () => { throw new Error("disk full"); } }, publish: noUpload });
  const failed = await broken.handle(post("/api/settings/hf-token", { token: "secret" }));
  expect(failed!.status).toBe(400); expect(await failed!.json()).toEqual({ ok: false, error: "disk full" });
});

test("each push kind forwards its source, repo, privacy and resolved token using the public uploader", async () => {
  const { credentials } = storage(); credentials.save("write-secret");
  const calls: unknown[][] = [], lookups: string[] = [];
  const publish = createPublisher({ credentials, getJob: id => { lookups.push(id); return { output_path: "/job-output" }; },
    upload: async (...args) => { calls.push(args); return { ok: true, url: "https://huggingface.co/org/result", commitOid: "ignored-on-wire" }; } });
  const routes = createPublishingRoutes({ credentials, publish });
  for (const kind of ["quantize", "finetune", "dataset"] as const) {
    const response = await routes.handle(post(`/api/${kind}/push`, { repo_id: "org/result", source_path: "/explicit", job_id: "ignored", private: true }));
    expect(response!.status).toBe(200);
    expect(await response!.json()).toEqual({ ok: true, url: "https://huggingface.co/org/result" });
    expect(calls.at(-1)).toEqual(["/explicit", "org/result", { repoType: kind === "dataset" ? "dataset" : "model", private: true, token: "write-secret", signal: expect.any(AbortSignal) }]);
    expect(pendingRoute(`/api/${kind}/push`)).toBe(false);
  }
  expect(lookups).toEqual([]);
  await routes.handle(post("/api/finetune/push", { repo_id: "org/result", job_id: "job-1" }));
  expect(lookups).toEqual(["job-1"]);
  expect(calls.at(-1)).toEqual(["/job-output", "org/result", { repoType: "model", private: false, token: "write-secret", signal: expect.any(AbortSignal) }]);
});

test("a cancelled push request aborts the uploader through its signal and answers 499", async () => {
  const { credentials } = storage(); credentials.save("write-secret");
  const controller = new AbortController();
  let observed: AbortSignal | undefined;
  const publish = createPublisher({ credentials, getJob: () => null, upload: (_source, _repo, options) => new Promise((_, reject) => {
    observed = options.signal;
    options.signal!.addEventListener("abort", () => reject(options.signal!.reason), { once: true });
    controller.abort(new Error("client went away"));
  }) });
  const routes = createPublishingRoutes({ credentials, publish });
  const response = await routes.handle(post("/api/quantize/push", { repo_id: "org/result", source_path: "/explicit" }, controller.signal));
  expect(response!.status).toBe(499);
  expect(observed).toBe(controller.signal);
});

test("missing tokens, source outputs and upload failures preserve the error envelope", async () => {
  const { credentials } = storage();
  let lookedUp = false, uploaded = false;
  const publish = createPublisher({ credentials, getJob: () => { lookedUp = true; return null; },
    upload: async () => { uploaded = true; throw new Error("upload denied"); } });
  const routes = createPublishingRoutes({ credentials, publish });
  const invoke = (body: unknown) => routes.handle(post("/api/quantize/push", body));
  expect(await (await invoke({ repo_id: "org/result", job_id: "missing" }))!.json()).toEqual({ ok: false, error: "no HF token saved — add one in Settings → Hugging Face" });
  expect(lookedUp).toBe(false);
  credentials.save("secret");
  expect(await (await invoke({ repo_id: "org/result", job_id: "missing" }))!.json()).toEqual({ ok: false, error: "no source dir (pass job_id or source_path)" });
  expect(lookedUp).toBe(true); expect(uploaded).toBe(false);
  const failed = await invoke({ repo_id: "org/result", source_path: "/explicit" });
  expect(failed!.status).toBe(400); expect(await failed!.json()).toEqual({ ok: false, error: "upload denied" });
});

test("malformed and cancelled HTTP inputs never read credentials, jobs or start uploads", async () => {
  let accessed = false;
  const fail = (): never => { accessed = true; throw new Error("unexpected access"); };
  const routes = createPublishingRoutes({ credentials: { get: fail, save: fail }, publish: async () => fail() });
  for (const body of [null, [], {}, { token: 3 }, { token: "  " }])
    expect((await routes.handle(post("/api/settings/hf-token", body)))!.status).toBe(400);
  for (const body of [null, [], {}, { repo_id: 1 }, { repo_id: "org/model", job_id: {} },
    { repo_id: "org/model", source_path: [] }, { repo_id: "org/model", private: "false" }])
    expect((await routes.handle(post("/api/dataset/push", body)))!.status).toBe(400);
  expect((await routes.handle(new Request("http://local/api/dataset/push", { method: "POST", body: "{" })))!.status).toBe(400);
  const cancelled = new AbortController(); cancelled.abort();
  expect((await routes.handle(post("/api/finetune/push", { repo_id: "org/model", source_path: "/a" }, cancelled.signal)))!.status).toBe(499);
  expect(accessed).toBe(false);
  expect(await routes.handle(new Request("http://local/api/dataset/push"))).toBeNull();
  expect(await routes.handle(post("/api/unknown/push", {}))).toBeNull();
  expect(pendingRoute("/api/settings/hf-token")).toBe(false);
});
