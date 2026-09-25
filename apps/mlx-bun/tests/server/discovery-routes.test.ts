import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { matchDiscoveryRoute } from "../../src/server/discovery-routes";

test("discovery matches only its GET surfaces and leaves other requests to composition", () => {
  for (const [path, route] of [["/library", "library"], ["/downloads", "downloads"], ["/v1", "api-index"],
    ["/health", "health"], ["/v1/models", "models"], ["/v1/models/org/model", "models"]] as const) {
    expect(matchDiscoveryRoute("GET", path)).toBe(route);
    expect(matchDiscoveryRoute("POST", path)).toBeNull();
  }
  expect(matchDiscoveryRoute("GET", "/not-discovery")).toBeNull();
});

test("model discovery preserves batch vocabulary and binding capability flags in both wire locations", async () => {
  // Discovery also scans the cache. Isolate HOME and the HF cache before module
  // initialization so this test cannot read or update the developer's registry.
  const home = mkdtempSync(join(tmpdir(), "mlx-discovery-")), hub = join(home, "hub");
  mkdirSync(hub);
  const source = resolve(import.meta.dir, "../../src/server/discovery-routes.ts");
  try {
    const process = Bun.spawn([globalThis.process.execPath, "--no-env-file", "-e", `
      import { createDiscoveryRoutes } from ${JSON.stringify(source)};
      const records = [];
      for (const [modelType, adapters, training, dsa] of [["qwen3", true, true, false], ["glm5", false, false, true]]) {
        const context = { modelId: "test/" + modelType, model: { config: { modelType, text: { maxPositionEmbeddings: 8192 } } },
          template: { supportsThinking: false }, genDefaults: {}, draft: null };
        const routes = createDiscoveryRoutes(context, { discovery: { adapters, training, dsa, embeddings: false } }, 123000);
        const request = new Request("http://local/v1/models/" + context.modelId);
        records.push((await (await routes.handle(new URL(request.url), request)).json()).data[0]);
      }
      console.log(JSON.stringify(records));
    `], { env: { ...globalThis.process.env, HOME: home, HF_HUB_CACHE: hub, MLX_BUN_LIBMLXC: "/does-not-exist" }, stdout: "pipe", stderr: "pipe" });
    const [output, errors, code] = await Promise.all([new Response(process.stdout).text(), new Response(process.stderr).text(), process.exited]);
    expect(code).toBe(0); expect(errors).toBe("");
    const records = JSON.parse(output);
    for (const [index, supported] of [[0, true], [1, false]] as const) {
      expect(records[index]).toMatchObject({ batch_mode: "batch", adapters: supported, training: supported,
        capabilities: { adapters: supported, training: supported, anthropic_messages: false, responses: false } });
    }
    expect(records[0].dsa).toBe(false); expect(records[1].dsa).toBe(true);
  } finally { rmSync(home, { recursive: true, force: true }); }
});
