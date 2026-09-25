import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { detectDraftKind, ownModelContext, getVisionTower, getAudioTower,
  type ModelContext, type ServedModelInfo } from "../../src/engine/model-host";
import { createAppEngine } from "../../src/engine/index";
import type { ModelBinding } from "../../src/engine/model-binding";
import { runtimeConfig } from "@mlx-bun/inference/runtime/config";

function context() {
  return { model: { config: {}, weightsBytes: 0 }, modelId: "fake", vision: null,
    audio: null, loadVision: null, loadAudio: null } as unknown as Omit<ModelContext<ServedModelInfo>, "dispose">;
}

test("model context releases every owned resource once, even if one release throws", () => {
  const released: string[] = []; const c = context();
  c.vision = { dispose() { released.push("vision"); } } as typeof c.vision;
  const host = ownModelContext(c, [
    { dispose() { released.push("draft"); throw new Error("draft cleanup failed"); } },
    { dispose() { released.push("weights"); } },
  ]);
  expect(() => host.dispose()).toThrow("draft cleanup failed"); host.dispose();
  expect(released).toEqual(["vision", "draft", "weights"]);
  expect(getVisionTower(host as ModelContext)).toBeNull();
  expect(getAudioTower(host as ModelContext)).toBeNull();
});

test("lazy towers are loaded once and owned by the model context", () => {
  let loads = 0, disposed = 0; const c = context();
  c.loadVision = () => { loads++; return { dispose() { disposed++; } } as NonNullable<typeof c.vision>; };
  const host = ownModelContext(c, []);
  expect(getVisionTower(host as ModelContext)).toBe(getVisionTower(host as ModelContext));
  expect(loads).toBe(1); host.dispose(); expect(disposed).toBe(1);
  expect(getVisionTower(host as ModelContext)).toBeNull();
});

test("draft detection preserves explicit artifact conventions without loading MLX", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-app-draft-"));
  try {
    for (const [config, expected] of [
      [{ architectures: ["Gemma4DSparkModel"] }, "deepspec"],
      [{ model_type: "gemma4_assistant" }, "assistant"],
      [{ model_type: "qwen3_5_mtp" }, "mtp"],
      [{ model_type: "qwen3" }, "two-model"],
    ] as const) {
      writeFileSync(join(dir, "config.json"), JSON.stringify(config));
      expect(await detectDraftKind(dir)).toBe(expected);
    }
    writeFileSync(join(dir, "dspark.json"), "{}"); expect(await detectDraftKind(dir)).toBe("dspark");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("an explicit replacement binding is used without inspecting a legacy model", async () => {
  let released = 0; const host = ownModelContext(context(), [{ dispose() { released++; } }]);
  const supplied = { gateway: { runtime: runtimeConfig() } } as ModelBinding;
  const engine = await createAppEngine(host, { capacity: 1, binding: supplied });
  expect(engine.binding).toBe(supplied); await engine.close(); await engine.close(); expect(released).toBe(1);
});

test("engine construction failure releases its transferred model context", async () => {
  let released = 0; const host = ownModelContext(context(), [{ dispose() { released++; } }]);
  const supplied = { gateway: { runtime: runtimeConfig() } } as ModelBinding;
  await expect(createAppEngine(host, { capacity: 0, binding: supplied })).rejects.toThrow("positive integer");
  expect(released).toBe(1);
});
