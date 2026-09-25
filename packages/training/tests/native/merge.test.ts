import { afterEach, beforeAll, describe, expect, spyOn, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";

describe.skipIf(process.env.MLX_BUN_TEST_NATIVE !== "1")("adapter merge ownership", () => {
  let ArrayClass: typeof import("@mlx-bun/mlx/array").MlxArray;
  let ops: typeof import("@mlx-bun/mlx/ops");
  let C: typeof import("@mlx-bun/mlx/ffi").C;
  let mergeAdapters: typeof import("../../src/merge").mergeAdapters;
  let loadAdapterTensors: typeof import("@mlx-bun/inference/adapters").loadAdapterTensors;
  beforeAll(async () => {
    ({ MlxArray: ArrayClass } = await import("@mlx-bun/mlx/array"));
    ops = await import("@mlx-bun/mlx/ops");
    ({ C } = await import("@mlx-bun/mlx/ffi"));
    ({ mergeAdapters } = await import("../../src/merge"));
    ({ loadAdapterTensors } = await import("@mlx-bun/inference/adapters"));
  });
  const roots: string[] = [];
  const restores: (() => void)[] = [];
  afterEach(() => {
    for (const restore of restores.splice(0).reverse()) restore();
    for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
  });
  function fixture() {
    const root = mkdtempSync(join(tmpdir(), "mlx-training-merge-")); roots.push(root);
    return { root, one: join(root, "one"), two: join(root, "two"), output: join(root, "output") };
  }
  // Small generated safetensors inputs, with no native allocations or cached model.
  function adapter(directory: string, tensors: Record<string, { shape: number[]; values: number[] }>, scale = 1) {
    mkdirSync(directory, { recursive: true });
    let offset = 0;
    const data: Buffer[] = [], header: Record<string, unknown> = {};
    for (const [name, tensor] of Object.entries(tensors)) {
      const bytes = Buffer.from(new Float32Array(tensor.values).buffer);
      header[name] = { dtype: "F32", shape: tensor.shape, data_offsets: [offset, offset + bytes.length] };
      data.push(bytes); offset += bytes.length;
    }
    const json = JSON.stringify(header), padded = Buffer.from(json.padEnd(Math.ceil(json.length / 8) * 8));
    const length = Buffer.alloc(8); length.writeBigUInt64LE(BigInt(padded.length));
    writeFileSync(join(directory, "adapters.safetensors"), Buffer.concat([length, padded, ...data]));
    writeFileSync(join(directory, "adapter_config.json"), JSON.stringify({ lora_parameters: { rank: 1, scale } }));
  }
  const pair = (name: string, a: number[], b: number[]) => ({
    [`${name}.lora_a`]: { shape: [2, 1], values: a },
    [`${name}.lora_b`]: { shape: [1, 2], values: b },
  });
  function observeEval(failAt?: number) {
    const arrays = new Set<MlxArray>(), original = ArrayClass.prototype.eval;
    const hook = spyOn(ArrayClass.prototype, "eval").mockImplementation(function(this: MlxArray) {
      arrays.add(this);
      if (arrays.size === failAt) throw new Error("injected materialization failure");
      return original.call(this);
    });
    restores.push(() => hook.mockRestore());
    return arrays;
  }
  function expectDisposed(arrays: Iterable<MlxArray>) {
    for (const array of arrays) expect(() => array.handle).toThrow("used after dispose");
  }

  test("a later source failure releases every earlier source tensor", async () => {
    const f = fixture(); adapter(f.one, pair("shared", [1, 2], [3, 4]));
    const arrays = observeEval();
    await expect(mergeAdapters([f.one, f.two], f.output, [1, 1])).rejects.toThrow("no adapters.safetensors");
    expect(arrays.size).toBe(2); expectDisposed(arrays);
  });

  test("scaled concatenation saves exact tensors and releases scaled intermediates and source aliases", async () => {
    const f = fixture();
    adapter(f.one, { ...pair("shared", [1, 2], [3, 4]), ...pair("unique", [9, 10], [11, 12]) }, 2);
    adapter(f.two, pair("shared", [5, 6], [7, 8]), -0.5);
    const evaluated = observeEval(), scaled: MlxArray[] = [], multiply = ops.mulScalar;
    const hook = spyOn(ops, "mulScalar").mockImplementation((...args) => {
      const array = multiply(...args); scaled.push(array); return array;
    });
    restores.push(() => hook.mockRestore());
    expect(await mergeAdapters([f.one, f.two], f.output)).toEqual({
      layersMerged: 1, layersOnlyInOne: 1, totalKeysOut: 4, sources: [f.one, f.two], scales: [2, -0.5],
    });
    expect(scaled).toHaveLength(3); expectDisposed(scaled); expectDisposed(evaluated);
    for (const restore of restores.splice(0).reverse()) restore();
    const output = loadAdapterTensors(join(f.output, "adapters.safetensors"));
    try {
      expect(output.get("shared.lora_a")!.shape).toEqual([2, 2]);
      expect([...output.get("shared.lora_a")!.toFloat32()]).toEqual([1, 5, 2, 6]);
      expect(output.get("shared.lora_b")!.shape).toEqual([2, 2]);
      expect([...output.get("shared.lora_b")!.toFloat32()]).toEqual([6, 8, -3.5, -4]);
      expect([...output.get("unique.lora_a")!.toFloat32()]).toEqual([9, 10]);
      expect([...output.get("unique.lora_b")!.toFloat32()]).toEqual([22, 24]);
    } finally { for (const array of output.values()) array.dispose(); }
    expect((await Bun.file(join(f.output, "adapter_config.json")).json()).lora_parameters).toEqual({ rank: 2, scale: 1 });
  });

  test("failure building the second concatenation releases the first output", async () => {
    const f = fixture(); adapter(f.one, pair("shared", [1, 2], [3, 4])); adapter(f.two, pair("shared", [5, 6], [7, 8]));
    const evaluated = observeEval(), outputs: MlxArray[] = [], concat = ops.concatAxis;
    const hook = spyOn(ops, "concatAxis").mockImplementation((...args) => {
      if (outputs.length) throw new Error("injected concat failure");
      const array = concat(...args); outputs.push(array); return array;
    });
    restores.push(() => hook.mockRestore());
    await expect(mergeAdapters([f.one, f.two], f.output)).rejects.toThrow("injected concat failure");
    expect(outputs).toHaveLength(1); expectDisposed(outputs); expectDisposed(evaluated);
  });

  test("source materialization failure releases the current and earlier tensors", async () => {
    const f = fixture(); adapter(f.one, pair("shared", [1, 2], [3, 4]));
    const evaluated = observeEval(2);
    await expect(mergeAdapters([f.one, f.two], f.output, [1, 1])).rejects.toThrow("injected materialization failure");
    expect(evaluated.size).toBe(2); expectDisposed(evaluated);
  });

  for (const phase of ["load", "save"] as const) test(`metadata allocation failure during ${phase} releases array maps`, async () => {
    const f = fixture(); adapter(f.one, pair("shared", [1, 2], [3, 4])); adapter(f.two, pair("shared", [5, 6], [7, 8]));
    const created: bigint[] = [], released: bigint[] = [];
    // Keep the same symbols object, with ordinary callable types for JS spies.
    const maps: {
      mlx_map_string_to_array_new(): bigint;
      mlx_map_string_to_array_free(handle: bigint): number;
      mlx_map_string_to_string_new(): bigint;
    } = C;
    const newArrayMap = C.mlx_map_string_to_array_new, freeArrayMap = C.mlx_map_string_to_array_free;
    const newMetadata = C.mlx_map_string_to_string_new;
    const create = spyOn(maps, "mlx_map_string_to_array_new").mockImplementation(() => {
      const handle = newArrayMap(); created.push(handle); return handle;
    });
    const free = spyOn(maps, "mlx_map_string_to_array_free").mockImplementation(handle => {
      released.push(handle); return freeArrayMap(handle);
    });
    let allocations = 0;
    const metadata = spyOn(maps, "mlx_map_string_to_string_new").mockImplementation(() => {
      if (++allocations === (phase === "load" ? 1 : 3)) throw new Error("injected metadata allocation failure");
      return newMetadata();
    });
    restores.push(() => create.mockRestore(), () => free.mockRestore(), () => metadata.mockRestore());
    await expect(mergeAdapters([f.one, f.two], f.output)).rejects.toThrow("injected metadata allocation failure");
    expect(released).toEqual(created);
  });
});
