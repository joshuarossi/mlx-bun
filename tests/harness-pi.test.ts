// Phase 16 P1: `mlx-bun harness pi` — extension generation, install /
// remove round-trip, and live discovery against a stub /v1/models.

import { describe, expect, it, afterAll } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  detectPi,
  fetchServerModels,
  installPiExtension,
  probeServer,
  removePiExtension,
  renderPiExtension,
  PI_EXTENSION_FILENAME,
} from "../src/harness-pi";

const tmp = mkdtempSync(join(tmpdir(), "mlx-bun-harness-"));
afterAll(() => rmSync(tmp, { recursive: true, force: true }));

// Stub of the mlx-bun /v1/models surface.
const stub = Bun.serve({
  port: 0,
  fetch(req) {
    if (new URL(req.url).pathname === "/v1/models") {
      return Response.json({
        object: "list",
        data: [{ id: "test/model-4bit", object: "model", created: 0, owned_by: "mlx-bun", context_window: 131072 }],
      });
    }
    return new Response("not found", { status: 404 });
  },
});
afterAll(() => stub.stop(true));
const baseUrl = `http://localhost:${stub.port}/v1`;

describe("renderPiExtension", () => {
  const src = renderPiExtension("http://localhost:9999/v1", [
    { id: "org/some-model", contextWindow: 65536, maxTokens: 8192, reasoning: false },
  ]);

  it("registers the mlx-bun provider with an openai-completions API", () => {
    expect(src).toContain('pi.registerProvider("mlx-bun"');
    expect(src).toContain('"openai-completions"');
    expect(src).toContain('"http://localhost:9999/v1"');
  });

  it("bakes the fallback under a stable local id, real model in the name", () => {
    expect(src).toContain('"id": "local"'); // mlx-bun/local handle, survives swaps
    expect(src).toContain("org/some-model"); // real model rides in `name`
    expect(src).toContain('"contextWindow": 65536');
  });

  it("discovers live models from /v1/models at pi startup", () => {
    expect(src).toContain("${BASE_URL}/models");
    expect(src).toContain("m.context_window");
  });

  it("is self-contained (no imports — pi loads it with jiti)", () => {
    expect(src).not.toContain("import ");
    expect(src).toContain("export default async function");
  });
});

describe("fetchServerModels", () => {
  it("maps /v1/models including context_window", async () => {
    const models = await fetchServerModels(baseUrl);
    expect(models).toEqual([{ id: "test/model-4bit", contextWindow: 131072, maxTokens: 8192, reasoning: false }]);
  });

  it("returns [] for an unreachable server", async () => {
    const models = await fetchServerModels("http://localhost:1/v1", 300);
    expect(models).toEqual([]);
  });
});

describe("probeServer", () => {
  it("returns models when a server answers /v1/models", async () => {
    expect(await probeServer(baseUrl)).toEqual([
      { id: "test/model-4bit", contextWindow: 131072, maxTokens: 8192, reasoning: false },
    ]);
  });

  it("returns null when nothing is listening", async () => {
    expect(await probeServer("http://localhost:1/v1", 300)).toBeNull();
  });
});

describe("installPiExtension / removePiExtension", () => {
  it("installs into the extensions dir, baking discovered models", async () => {
    const result = await installPiExtension(baseUrl, tmp);
    expect(result.path).toBe(join(tmp, PI_EXTENSION_FILENAME));
    expect(result.serverReachable).toBe(true);
    expect(result.bakedModels).toEqual(["test/model-4bit"]);
    const written = readFileSync(result.path, "utf8");
    expect(written).toContain("test/model-4bit"); // real model in `name`; id is stable "local"
    expect(written).toContain('"contextWindow": 131072');
  });

  it("installs with an empty fallback when the server is down", async () => {
    const dir = join(tmp, "down");
    const result = await installPiExtension("http://localhost:1/v1", dir);
    expect(result.serverReachable).toBe(false);
    expect(existsSync(result.path)).toBe(true);
  });

  it("remove deletes the file once and is a no-op after", () => {
    expect(removePiExtension(tmp)).toBe(true);
    expect(existsSync(join(tmp, PI_EXTENSION_FILENAME))).toBe(false);
    expect(removePiExtension(tmp)).toBe(false);
  });
});

describe("generated extension behaves like pi would run it", () => {
  it("registers live-discovered models when the server is up", async () => {
    const dir = join(tmp, "exec");
    const { path } = await installPiExtension(baseUrl, dir);
    const mod = await import(path);
    const calls: Array<[string, any]> = [];
    await mod.default({ registerProvider: (id: string, cfg: any) => calls.push([id, cfg]) });
    expect(calls).toHaveLength(1);
    const [id, cfg] = calls[0]!;
    expect(id).toBe("mlx-bun");
    expect(cfg.api).toBe("openai-completions");
    expect(cfg.models).toEqual([
      expect.objectContaining({
        id: "local",
        name: "test/model-4bit (mlx-bun local)",
        contextWindow: 131072,
      }),
    ]);
  });
});

describe("detectPi", () => {
  it("returns a structured result without throwing", () => {
    const d = detectPi();
    expect(typeof d.found).toBe("boolean");
    if (d.found) expect(d.binPath).toBeTruthy();
  });
});
