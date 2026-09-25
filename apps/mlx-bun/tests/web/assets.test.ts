import { beforeAll, expect, test } from "bun:test";
import { cp, mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { pathToFileURL } from "node:url";
import { dirname, join } from "node:path";
import { buildWebBundle, OUTFILE } from "../../src/web/build";
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
  for (const path of ["/v1/chat/completions", "/api/jobs", "/ws", "/not-a-file", "/toString", "/constructor", "/__proto__", "/curves", "/dag"]) {
    expect(handle(new Request(`http://local${path}`))).toBeNull();
  }
  expect(handle(new Request("http://local/", { method: "POST" }))).toBeNull();
});


test("a source checkout builds a missing browser bundle without writing installation files", async () => {
  const root = await mkdtemp(join(tmpdir(), "mlx-web-source-"));
  try {
    await cp(new URL("../../src/web", import.meta.url), join(root, "src/web"), { recursive: true });
    await mkdir(join(root, "src/chat"), { recursive: true });
    await cp(new URL("../../src/chat/protocol.ts", import.meta.url), join(root, "src/chat/protocol.ts"));
    const { createWebHandler: sourceHandler } = await import(pathToFileURL(join(root, "src/web/assets.ts")).href);
    const source = await sourceHandler();
    const response = source(new Request("http://local/assets/app.js"))!;
    expect(response.status).toBe(200);
    const script = await response.text();
    expect(script.length).toBeGreaterThan(10000);
    expect(script).not.toContain("bun:ffi");
    expect(await Bun.file(join(root, "dist/web/app.js")).exists()).toBe(false);
    expect(source(new Request("http://local/"))?.status).toBe(200);
  } finally { await rm(root, { recursive: true, force: true }); }
});

test("a packaged browser bundle is served directly without invoking the source compiler", async () => {
  const root = await mkdtemp(join(tmpdir(), "mlx-web-packed-"));
  try {
    await cp(new URL("../../src/web", import.meta.url), join(root, "src/web"), { recursive: true });
    await mkdir(join(root, "src/chat"), { recursive: true });
    await cp(new URL("../../src/chat/protocol.ts", import.meta.url), join(root, "src/chat/protocol.ts"));
    await mkdir(join(root, "dist/web"), { recursive: true });
    const packed = "globalThis.packedBrowser = true;";
    await writeFile(join(root, "dist/web/app.js"), packed);
    // The packaged bundle must work even when its source entry cannot build.
    await writeFile(join(root, "src/web/browser/main.ts"), "this is invalid TypeScript {");
    const { createWebHandler: packedHandler } = await import(pathToFileURL(join(root, "src/web/assets.ts")).href);
    const source = await packedHandler();
    expect(await source(new Request("http://local/assets/app.js"))!.text()).toBe(packed);
  } finally { await rm(root, { recursive: true, force: true }); }
});
