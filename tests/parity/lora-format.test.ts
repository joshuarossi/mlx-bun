// Fast, tiny-tensor coverage for adapter interchange and save durability.
// No model weights are loaded: AdapterManager only needs a model-shaped target
// map, and the safetensors fixtures contain one 3x4 LoRA delta.

import { afterAll, describe, expect, test } from "bun:test";
import {
  existsSync,
  mkdtempSync,
  mkdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { AdapterManager } from "../../src/lora";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import {
  disposeLora,
  saveAdapter,
  type TrainableLora,
} from "../../src/train/lora-params";
import type { LoraWeights } from "../../src/model/gemma4";
import type { RuntimeModel } from "../../src/model/factory";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-lora-format-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const MODULE = "model.layers.0.self_attn.q_proj";

test("adapter cache identity survives remounts and changes with weights or scale", async () => {
  const dir = join(root, "cache-identity");
  const manager = new AdapterManager(stubModel().model);
  const a = { shape: [2, 3], values: [1, 2, 3, 4, 5, 6] };
  const b = { shape: [4, 2], values: [1, 2, 3, 4, 5, 6, 7, 8] };
  writePeftAdapter(dir, a, b);
  try {
    await manager.mount("same-name", dir);
    const original = manager.cacheNamespace(["same-name"]);
    manager.unmount("same-name");
    expect(() => manager.cacheNamespace(["same-name"])).toThrow("no longer mounted");
    await manager.mount("same-name", dir);
    expect(manager.cacheNamespace(["same-name"])).toBe(original);
    manager.unmount("same-name");
    writePeftAdapter(dir, a, b, { alpha: 8 });
    await manager.mount("same-name", dir);
    expect(manager.cacheNamespace(["same-name"])).not.toBe(original);
    const scaled = manager.cacheNamespace(["same-name"]);
    manager.unmount("same-name");
    writePeftAdapter(dir, a, { ...b, values: b.values.map((v) => v + 1) }, { alpha: 8 });
    await manager.mount("same-name", dir);
    expect(manager.cacheNamespace(["same-name"])).not.toBe(scaled);
    expect(manager.cacheNamespace([])).toBe("");
  } finally { manager.unmount("same-name"); }
});

interface StubLinear {
  inFeatures: number;
  outFeatures: number;
  adapters: Map<string, LoraWeights> | null;
  loraState: { active: string[] } | null;
}

function stubModel(): {
  model: RuntimeModel;
  linear: StubLinear;
} {
  const state = { active: [] as string[] };
  const linear: StubLinear = {
    inFeatures: 3,
    outFeatures: 4,
    adapters: null,
    loraState: null,
  };
  const targets = new Map([[MODULE, linear]]);
  const model = {
    prefixBase: "model",
    loraState: state,
    loraTargets: () => targets,
  } as unknown as RuntimeModel;
  return { model, linear };
}

function writeF32Safetensors(
  file: string,
  tensors: Record<string, { shape: number[]; values: number[] }>,
): void {
  let offset = 0;
  const header: Record<string, unknown> = { __metadata__: { format: "pt" } };
  const parts: Uint8Array[] = [];
  for (const [name, tensor] of Object.entries(tensors)) {
    const values = new Float32Array(tensor.values);
    const bytes = new Uint8Array(values.buffer);
    header[name] = {
      dtype: "F32",
      shape: tensor.shape,
      data_offsets: [offset, offset + bytes.byteLength],
    };
    parts.push(bytes);
    offset += bytes.byteLength;
  }

  const json = new TextEncoder().encode(JSON.stringify(header));
  const paddedLength = Math.ceil(json.byteLength / 8) * 8;
  const out = new Uint8Array(8 + paddedLength + offset);
  new DataView(out.buffer).setBigUint64(0, BigInt(paddedLength), true);
  out.fill(0x20, 8, 8 + paddedLength);
  out.set(json, 8);
  let dataOffset = 8 + paddedLength;
  for (const part of parts) {
    out.set(part, dataOffset);
    dataOffset += part.byteLength;
  }
  writeFileSync(file, out);
}

function writePeftAdapter(
  dir: string,
  a: { shape: number[]; values: number[] },
  b: { shape: number[]; values: number[] },
  options: { alpha?: number; rank?: number; useRslora?: boolean } = {},
): void {
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "adapter_config.json"), JSON.stringify({
    base_model_name_or_path: "example/base",
    lora_alpha: options.alpha ?? 4,
    peft_type: "LORA",
    r: options.rank ?? 2,
    target_modules: ["q_proj"],
    use_rslora: options.useRslora ?? false,
  }));
  writeF32Safetensors(join(dir, "adapter_model.safetensors"), {
    [`base_model.model.${MODULE}.lora_A.weight`]: a,
    [`base_model.model.${MODULE}.lora_B.weight`]: b,
  });
}

describe("AdapterManager PEFT layout", () => {
  test("mounts standard PEFT names/orientation and produces the expected delta", async () => {
    const dir = join(root, "peft-valid");
    // PEFT/PyTorch layout: A [rank,in], B [out,rank].
    writePeftAdapter(
      dir,
      { shape: [2, 3], values: [1, 2, 3, 4, 5, 6] },
      { shape: [4, 2], values: [7, 8, 9, 10, 11, 12, 13, 14] },
    );
    const { model, linear } = stubModel();
    const manager = new AdapterManager(model);

    const info = await manager.mount("peft", dir);
    expect(info.mountedLayers).toBe(1);
    expect(info.rank).toBe(2);
    expect(info.scale).toBe(2);

    const mounted = linear.adapters!.get("peft")!;
    expect(mounted.a.shape).toEqual([3, 2]);
    expect(mounted.b.shape).toEqual([2, 4]);

    const x = MlxArray.fromFloat32(new Float32Array([1, 0, -1]), [1, 3]);
    const xa = ops.matmul(x, mounted.a);
    const delta = ops.matmul(xa, mounted.b);
    const scaled = ops.mulScalar(delta, mounted.scale);
    expect([...scaled.toFloat32()]).toEqual([-60, -76, -92, -108]);
    x.dispose();
    xa.dispose();
    delta.dispose();
    scaled.dispose();
    expect(manager.unmount("peft")).toBe(1);
  });

  test("mounts PEFT use_rslora with alpha/sqrt(rank) applied exactly once", async () => {
    const dir = join(root, "peft-rslora");
    writePeftAdapter(
      dir,
      { shape: [2, 3], values: [1, 2, 3, 4, 5, 6] },
      { shape: [4, 2], values: [7, 8, 9, 10, 11, 12, 13, 14] },
      { alpha: 4, rank: 2, useRslora: true },
    );
    const { model, linear } = stubModel();
    const manager = new AdapterManager(model);

    const info = await manager.mount("peft-rslora", dir);
    const mounted = linear.adapters!.get("peft-rslora")!;
    expect(info.rank).toBe(2);
    expect(info.scale).toBe(4);
    expect(mounted.scale).toBeCloseTo(4 / Math.sqrt(2), 6);

    const x = MlxArray.fromFloat32(new Float32Array([1, 0, -1]), [1, 3]);
    const xa = ops.matmul(x, mounted.a);
    const delta = ops.matmul(xa, mounted.b);
    const scaled = ops.mulScalar(delta, mounted.scale);
    const expected = [-30, -38, -46, -54].map((v) => v * 4 / Math.sqrt(2));
    const actual = [...scaled.toFloat32()];
    for (let i = 0; i < expected.length; i++)
      expect(actual[i]).toBeCloseTo(expected[i]!, 4);
    x.dispose();
    xa.dispose();
    delta.dispose();
    scaled.dispose();
    expect(manager.unmount("peft-rslora")).toBe(1);
  });

  test("rejects tensors matching neither mlx-lm nor PEFT orientation", async () => {
    const dir = join(root, "peft-mismatch");
    writePeftAdapter(
      dir,
      { shape: [2, 5], values: new Array(10).fill(1) },
      { shape: [4, 2], values: new Array(8).fill(1) },
    );
    const { model } = stubModel();
    const manager = new AdapterManager(model);

    await expect(manager.mount("bad", dir)).rejects.toThrow(
      "Expected mlx-lm [in, rank] + [rank, out] or PEFT [rank, in] + [out, rank]",
    );
    expect(manager.list()).toEqual([]);
  });
});

describe("saveAdapter durability", () => {
  test("does not resolve until both configs are written, then mounts immediately", async () => {
    const dir = join(root, "saved");
    const { model, linear } = stubModel();
    const lora: TrainableLora = {
      adapterId: "train",
      scale: 2,
      targets: [{
        modulePath: MODULE,
        linear: linear as never,
        lw: {
          a: MlxArray.fromFloat32(new Float32Array([1, 4, 2, 5, 3, 6]), [3, 2]),
          b: MlxArray.fromFloat32(new Float32Array([7, 9, 11, 13, 8, 10, 12, 14]), [2, 4]),
          rank: 2,
          scale: 2 / Math.sqrt(2),
        },
      }],
    };

    let releaseWrites!: () => void;
    const writesReleased = new Promise<void>((resolve) => { releaseWrites = resolve; });
    let writesStarted = 0;
    let settled = false;
    const saving = saveAdapter(
      lora,
      dir,
      {
        rank: 2,
        scale: 2,
        rankScaling: "constant",
        targetModules: ["q_proj"],
        numLayers: 1,
        method: "sft",
        baseModel: "example/base",
        rsLora: true,
      },
      { [MODULE]: 2 },
      {
        writeFile: async (path, data) => {
          writesStarted++;
          await writesReleased;
          return Bun.write(path, data);
        },
      },
    );
    void saving.then(() => { settled = true; });

    await Bun.sleep(0);
    expect(writesStarted).toBe(2);
    expect(settled).toBe(false);
    expect(existsSync(join(dir, "adapters.safetensors"))).toBe(true);
    expect(existsSync(join(dir, "optiq_lora_config.json"))).toBe(false);
    expect(existsSync(join(dir, "adapter_config.json"))).toBe(false);

    releaseWrites();
    await saving;
    expect(settled).toBe(true);
    expect(existsSync(join(dir, "optiq_lora_config.json"))).toBe(true);
    expect(existsSync(join(dir, "adapter_config.json"))).toBe(true);
    const peftConfig = await Bun.file(join(dir, "adapter_config.json")).json();
    expect(peftConfig.use_rslora).toBe(true);
    expect(peftConfig.lora_alpha).toBe(2);
    expect(peftConfig.lora_alpha / Math.sqrt(peftConfig.r))
      .toBeCloseTo(lora.targets[0]!.lw.scale, 6);

    const manager = new AdapterManager(model);
    const info = await manager.mount("saved", dir);
    expect(info.mountedLayers).toBe(1);
    expect(info.rank).toBe(2);
    const mounted = linear.adapters!.get("saved")!;
    expect(mounted.scale).toBeCloseTo(2 / Math.sqrt(2), 6);
    expect(mounted.scale).toBeCloseTo(lora.targets[0]!.lw.scale, 6);
    expect(manager.unmount("saved")).toBe(1);
    disposeLora(lora);
  });
});
