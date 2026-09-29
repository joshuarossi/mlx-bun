import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { modelWeightsIdentity, type ArtifactIdentityStore } from "../../src/artifacts/identity";

const memory = (): ArtifactIdentityStore => {
  const map = new Map<string, string>();
  return { get: async key => map.get(key), put: (key, digest) => { map.set(key, digest); } };
};

test("model weights identity follows weight bytes and config, not the directory name or unrelated files", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-weights-id-")), store = memory();
  const model = (name: string, weights: string, config = "{}") => {
    const dir = join(root, name); mkdirSync(dir);
    writeFileSync(join(dir, "config.json"), config); writeFileSync(join(dir, "model.safetensors"), weights);
    writeFileSync(join(dir, "README.md"), name); return dir;
  };
  try {
    const a = await modelWeightsIdentity(model("a", "weights"), "arch", store);
    expect(await modelWeightsIdentity(model("copy", "weights"), "arch", store)).toBe(a);
    expect(await modelWeightsIdentity(model("changed", "weightz"), "arch", store)).not.toBe(a);
    expect(await modelWeightsIdentity(model("requantized", "weights", '{"bits":8}'), "arch", store)).not.toBe(a);
    expect(await modelWeightsIdentity(join(root, "a"), "other-arch", store)).not.toBe(a);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
