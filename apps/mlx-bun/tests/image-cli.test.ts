import { expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { tmpdir } from "node:os";
import { help } from "../src/cli/args";

const app = new URL("../", import.meta.url).pathname;
const entry = process.env.MLX_BUN_TEST_CLI ?? resolve(app, "src/cli/main.ts");
const offline = { ...process.env, HF_HUB_OFFLINE: "1", NO_COLOR: "1", MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" };

test("image help preserves the standalone command's flags without loading a model", async () => {
  expect(help()).toMatch(/\n  image +Text-to-image/);
  const child = Bun.spawn([process.execPath, "--no-env-file", entry, "image", "--help"], { stdout: "pipe", stderr: "pipe", env: offline });
  const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
  expect({ err, code }).toEqual({ err: "", code: 0 });
  for (const flag of ["--model", "--out", "--width", "--height", "--steps", "--guidance", "--seed", "--negative-prompt", "--no-skip-layers", "--json"])
    expect(out).toContain(flag);
});

test("the installed image verb composes its own host, writes a PNG, and closes on success, failure and SIGINT", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-image-cli-"));
  const lib = dirname(realpathSync(Bun.resolveSync("@mlx-bun/app-services", app))) + "/";
  const model = join(root, "pipeline"), output = join(root, "image.png");
  mkdirSync(model);
  writeFileSync(join(model, "model_index.json"), JSON.stringify({ _class_name: "MOSSImagePipeline" }));
  try {
    const script = `
      import { mock } from "bun:test";
      import { strict as assert } from "node:assert";
      import { totalmem } from "node:os";
      const app = ${JSON.stringify(app)}, lib = ${JSON.stringify(lib)}, model = ${JSON.stringify(model)};
      let mode = "success", opens = 0, disposals = 0;
      mock.module(lib + "host.ts", () => ({ createHostServices() { throw new Error("shared Whisper services were composed"); } }));
      mock.module(app + "src/jobs/host.ts", () => ({ createJobHost() { throw new Error("image command started a job host"); } }));
      mock.module(lib + "image-backend.ts", () => ({ nativeImageBackend: { async load(directory) {
        assert.equal(directory, model); opens++;
        return { defaults: { width: 16, height: 16, steps: 1, guidance: 1, negativePrompt: "", uncondSkipLayers: [] },
          pixelsPerLatent: 16, stageBytes: { conditioner: totalmem(), denoiser: 300, decoder: 100 },
          async generate(request, options) {
            assert.equal(options.releaseStages, true);
            if (mode === "failure") throw new Error("fake pipeline failed");
            if (mode === "cancel") return new Promise((_, reject) => {
              options.signal.addEventListener("abort", () => reject(options.signal.reason), { once: true });
              queueMicrotask(() => process.emit("SIGINT"));
            });
            assert.deepEqual(request, { prompt: "a cat", width: 32, height: 16, steps: 2, guidance: 1.5,
              seed: 7, negativePrompt: "rain", uncondSkipLayers: [] });
            options.onProgress({ stage: "denoiser", step: 2, steps: 2 });
            return { width: 32, height: 16, pixels: new Uint8Array(32 * 16 * 3).fill(23), seed: 7, steps: 2, guidance: 1.5,
              timings: { encodeMs: 1, denoiseMs: 2, decodeMs: 3 } };
          }, dispose() { disposals++; } };
      } } }));
      const { runInstalledVerb } = await import(app + "src/cli/module-verbs.ts");
      const signals = [process.listenerCount("SIGINT"), process.listenerCount("SIGTERM")];
      assert.equal(await runInstalledVerb("image", ["a cat", "--model", model, "--out", ${JSON.stringify(output)},
        "--width", "32", "--height", "16", "--steps", "2", "--guidance", "1.5", "--seed", "7", "--negative-prompt", "rain", "--no-skip-layers", "--json"]), 0);
      mode = "failure";
      await assert.rejects(runInstalledVerb("image", { values: { model, out: ${JSON.stringify(join(root, 'failed.png'))} }, positionals: ["fail"] }), /fake pipeline failed/);
      mode = "cancel";
      await assert.rejects(runInstalledVerb("image", ["cancel", "--model", model, "--out", ${JSON.stringify(join(root, 'cancelled.png'))}]), /image generation cancelled/);
      await assert.rejects(runInstalledVerb("image", []), /usage:/);
      assert.deepEqual([opens, disposals], [3, 3]);
      assert.deepEqual([process.listenerCount("SIGINT"), process.listenerCount("SIGTERM")], signals);
    `;
    const child = Bun.spawn([process.execPath, "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app, env: offline });
    const [out, err, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    expect({ err, code }).toEqual({ err: "denoiser 2/2\n", code: 0 });
    expect(JSON.parse(out)).toMatchObject({ path: output, model, width: 32, height: 16, seed: 7, steps: 2, guidance: 1.5 });
    const png = await Bun.file(output).arrayBuffer();
    expect([...new Uint8Array(png, 0, 8)]).toEqual([137, 80, 78, 71, 13, 10, 26, 10]);
    expect([new DataView(png).getUint32(16), new DataView(png).getUint32(20)]).toEqual([32, 16]);
    expect(existsSync(join(root, "failed.png"))).toBe(false);
    expect(existsSync(join(root, "cancelled.png"))).toBe(false);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("server module activation excludes images and does not expose an image operation or route", async () => {
  const { installedModules } = await import("../src/modules");
  const { activateModules, createHostServices, createModuleRoutes } = await import("@mlx-bun/app-services");
  const modules = await installedModules("model");
  expect(modules.map(module => module.id)).toEqual(["transcription"]);
  expect((await installedModules(manifest => manifest.verbs?.some(verb => verb.name === "image") ?? false)).map(module => module.id)).toEqual(["images"]);
  const services = createHostServices({ log() {} });
  const loaded = await activateModules(modules, services);
  try {
    expect(await services.whisper.defaultFor("image")).toBeUndefined();
    expect(loaded.routes.some(route => route.path.includes("/images/"))).toBe(false);
    expect(await createModuleRoutes(loaded.routes).handle(new Request("http://localhost/v1/images/generations", { method: "POST" }))).toBeNull();
  } finally {
    try { await loaded.stop(); } finally { await services.whisper.close(); services.events.close(); }
  }
});
