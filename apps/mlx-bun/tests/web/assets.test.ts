import { beforeAll, expect, test } from "bun:test";
import { mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { buildWebBundle, OUTFILE } from "../../scripts/build-web";
import { createWebHandler } from "../../src/web/assets";

let handle: Awaited<ReturnType<typeof createWebHandler>>;
beforeAll(async () => {
  const bundle = await buildWebBundle();
  await mkdir(dirname(OUTFILE), { recursive: true });
  await Bun.write(OUTFILE, bundle);
  handle = await createWebHandler();
});

test("the generated browser bundle and local shell assets resolve without native MLX", async () => {
  const shell = handle(new Request("http://local/"))!;
  const html = await shell.text();
  expect(shell.headers.get("content-type")).toBe("text/html; charset=utf-8");
  expect(html).not.toContain("pf-lane");
  for (const path of ["/assets/app.js", "/assets/hljs.js", "/assets/hljs.css", "/manifest.webmanifest", "/assets/icon.svg"]) {
    const asset = handle(new Request(`http://local${path}`))!;
    expect(asset.status).toBe(200); expect(asset.headers.get("cache-control")).toBe("public, max-age=3600");
    expect((await asset.text()).length).toBeGreaterThan(10);
  }
  for (const match of html.matchAll(/(?:src|href)="(\/(?:assets\/[^"?#]+|manifest\.webmanifest))"/g)) {
    expect(handle(new Request(`http://local${match[1]}`))?.status).toBe(200);
  }
  const app = await handle(new Request("http://local/assets/app.js"))!.text();
  expect(app).not.toContain("renderLane");
  expect(app).not.toContain("bun:ffi");
});

test("the worker keeps API traffic network-only; legacy pages redirect and unknown routes compose", async () => {
  const worker = handle(new Request("http://local/sw.js"))!;
  expect(worker.headers.get("cache-control")).toBe("no-store");
  const source = await worker.text();
  expect(source).toContain("!SHELL_FILES.includes(url.pathname)");
  for (const path of ["/chat", "/status", "/quantize", "/finetune", "/dataset"]) {
    const result = handle(new Request(`http://local${path}`))!;
    expect(result.status).toBe(302); expect(result.headers.get("location")).toBe(`/#${path}`);
  }
  for (const path of ["/v1/chat/completions", "/api/jobs", "/ws", "/not-a-file", "/curves", "/dag"]) {
    expect(handle(new Request(`http://local${path}`))).toBeNull();
  }
  expect(handle(new Request("http://local/", { method: "POST" }))).toBeNull();
});
