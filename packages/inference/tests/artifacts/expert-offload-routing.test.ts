// Needs the native runtime: the offload runtime hands out MlxArray views.
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { activateExpertOffload, expertOffloadArray, isExpertOffload } from "../../src/artifacts/expert-offload";
import { buildOffloadFile } from "../../src/artifacts/expert-offload-build";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

function model(tensors: Record<string, number[]>) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-offload-routing-")); roots.push(dir);
  const header: Record<string, unknown> = {};
  const chunks: Uint8Array[] = [];
  let offset = 0;
  for (const [name, values] of Object.entries(tensors)) {
    const bytes = new Uint8Array(Float32Array.from(values).buffer);
    header[name] = { dtype: "F32", shape: [values.length], data_offsets: [offset, offset + bytes.length] };
    chunks.push(bytes); offset += bytes.length;
  }
  const json = new TextEncoder().encode(JSON.stringify(header));
  const length = new Uint8Array(8); new DataView(length.buffer).setBigUint64(0, BigInt(json.length), true);
  writeFileSync(join(dir, "model.safetensors"), Buffer.concat([length, json, ...chunks]));
  return dir;
}

test("activation routes expert weights through the file; restore returns the previous routing and never unmaps", async () => {
  const name = "model.layers.0.switch_glu.up";
  const a = model({ [name]: [1, 2, 3, 4] }), b = model({ [name]: [9, 9] });
  await buildOffloadFile(a, join(a, "offload")); await buildOffloadFile(b, join(b, "offload"));
  const before = isExpertOffload();
  const restoreA = activateExpertOffload(join(a, "offload"));
  const fromA = expertOffloadArray(name);
  expect(fromA?.shape).toEqual([4]);
  const restoreB = activateExpertOffload(join(b, "offload"));
  const fromB = expertOffloadArray(name);
  expect(fromB?.shape).toEqual([2]);
  restoreB();
  expect(expertOffloadArray(name)?.shape).toEqual([4]);
  // Views created under earlier routing keep their mapping.
  expect(fromA!.shape).toEqual([4]); expect(fromB!.shape).toEqual([2]);
  restoreA();
  expect(isExpertOffload()).toBe(before);
  if (!before) expect(expertOffloadArray(name)).toBeNull();
  fromA?.dispose(); fromB?.dispose();
});
