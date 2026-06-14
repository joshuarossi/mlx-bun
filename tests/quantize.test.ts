// Unit tests for native model quantization (fast tier — no multi-GB model).
//
// Covers the safetensors writer (round-trip + sharding/index behavior), the
// config-block + config-file writers, and the quantize→dequantize numerical
// pipeline on a small synthetic tensor. The full on-disk model e2e is written
// but guarded behind MLX_BUN_TEST_QUANTIZE — the orchestrator runs it.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT_MINICPM5 } from "./paths";
import { existsSync, mkdtempSync, mkdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import { quantize, dequantize } from "../src/mlx/ops";
import { Weights } from "../src/weights";
import {
  writeShardedSafetensors,
  buildQuantizationBlock,
  writeQuantizedConfig,
  quantizeModelDir,
  inspectModel,
} from "../src/quantize/index";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-quant-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

/** Make a fresh tmp subdir. */
function tmpDir(tag: string): string {
  const d = join(root, `${tag}-${Math.random().toString(36).slice(2)}`);
  mkdirSync(d, { recursive: true });
  return d;
}

/** Build a bf16 MlxArray from row-major float data. */
function bf16(data: number[], shape: number[]): MlxArray {
  const f = MlxArray.fromFloat32(new Float32Array(data), shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
}

/** bf16 rounding tolerance for a value of magnitude ~|v| (8-bit mantissa). */
function bf16Tol(v: number): number {
  return Math.max(Math.abs(v) / 128, 1e-3);
}

describe("writeShardedSafetensors", () => {
  test("single shard → model.safetensors, no index, round-trips values", async () => {
    const dir = tmpDir("single");
    const alpha = bf16([1.5, -2.25, 3.125, 0, 7, -8], [2, 3]);
    const beta = bf16([0.5, 1.0, 2.0, 4.0], [4]);

    const res = writeShardedSafetensors(dir, [
      { name: "alpha", array: alpha },
      { name: "beta", array: beta },
    ]);
    alpha.dispose();
    beta.dispose();

    expect(res.shards.length).toBe(1);
    expect(res.shards[0]!.file).toBe("model.safetensors");
    expect(res.totalParams).toBe(6 + 4);
    expect(existsSync(join(dir, "model.safetensors"))).toBe(true);
    // Single shard ⇒ NO index file (matches the loader's expectation).
    expect(existsSync(join(dir, "model.safetensors.index.json"))).toBe(false);

    const w = await Weights.open(dir);
    try {
      expect(w.tensorNames.sort()).toEqual(["alpha", "beta"]);
      const a = [...w.tensor("alpha").toFloat32()];
      const b = [...w.tensor("beta").toFloat32()];
      const expA = [1.5, -2.25, 3.125, 0, 7, -8];
      const expB = [0.5, 1.0, 2.0, 4.0];
      a.forEach((v, i) => expect(Math.abs(v - expA[i]!)).toBeLessThan(bf16Tol(expA[i]!)));
      b.forEach((v, i) => expect(Math.abs(v - expB[i]!)).toBeLessThan(bf16Tol(expB[i]!)));
      expect(w.info("alpha").shape).toEqual([2, 3]);
    } finally {
      w.dispose();
    }
  });

  test("forced tiny shard ceiling → multiple shards + index with weight_map", async () => {
    const dir = tmpDir("multi");
    // Three tensors; force a ceiling so each lands in its own shard.
    const t0 = bf16([1, 2, 3, 4], [2, 2]); // 8 bytes
    const t1 = bf16([5, 6, 7, 8], [2, 2]);
    const t2 = bf16([9, 10, 11, 12], [2, 2]);

    const res = writeShardedSafetensors(
      dir,
      [
        { name: "t0", array: t0 },
        { name: "t1", array: t1 },
        { name: "t2", array: t2 },
      ],
      { shardBytes: 8 }, // each tensor is 8 bytes ⇒ one per shard
    );
    t0.dispose();
    t1.dispose();
    t2.dispose();

    expect(res.shards.length).toBe(3);
    expect(res.shards.map((s) => s.file)).toEqual([
      "model-00001-of-00003.safetensors",
      "model-00002-of-00003.safetensors",
      "model-00003-of-00003.safetensors",
    ]);
    const indexPath = join(dir, "model.safetensors.index.json");
    expect(existsSync(indexPath)).toBe(true);

    const index = JSON.parse(await Bun.file(indexPath).text());
    expect(index.metadata.total_parameters).toBe(12);
    expect(index.weight_map).toEqual({
      t0: "model-00001-of-00003.safetensors",
      t1: "model-00002-of-00003.safetensors",
      t2: "model-00003-of-00003.safetensors",
    });

    // Reopen through the sharded loader (uses the index).
    const w = await Weights.open(dir);
    try {
      expect(w.tensorNames.sort()).toEqual(["t0", "t1", "t2"]);
      expect([...w.tensor("t2").toFloat32()]).toEqual([9, 10, 11, 12]);
    } finally {
      w.dispose();
    }
  });
});

describe("buildQuantizationBlock", () => {
  test("default + per-layer overrides, false = unquantized", () => {
    const perLayer = new Map<string, { bits: number; groupSize: number } | false>([
      ["model.embed_tokens", { bits: 8, groupSize: 64 }],
      ["model.layers.0.self_attn.q_proj", { bits: 4, groupSize: 64 }],
      ["model.norm", false],
    ]);
    const block = buildQuantizationBlock({ bits: 4, groupSize: 64 }, perLayer);
    expect(block.group_size).toBe(64);
    expect(block.bits).toBe(4);
    expect(block.mode).toBe("affine");
    expect(block["model.embed_tokens"]).toEqual({ bits: 8, group_size: 64 });
    expect(block["model.layers.0.self_attn.q_proj"]).toEqual({ bits: 4, group_size: 64 });
    expect(block["model.norm"]).toBe(false);
  });
});

describe("writeQuantizedConfig", () => {
  test("sets both quantization keys, deep-copies, copies an aux file", async () => {
    const srcDir = tmpDir("cfgsrc");
    const outDir = tmpDir("cfgout");
    // Aux file to copy through.
    await Bun.write(join(srcDir, "tokenizer.json"), '{"tok":true}');

    const srcRaw = {
      model_type: "llama",
      hidden_size: 1536,
      nested: { a: 1 },
    };
    const block = buildQuantizationBlock(
      { bits: 4, groupSize: 64 },
      new Map([["model.embed_tokens", { bits: 8, groupSize: 64 }]]),
    );

    await writeQuantizedConfig(srcRaw, outDir, block, {
      srcDir,
      optiq: {
        method: "uniform_affine",
        base_model: srcDir,
        bits: 4,
        group_size: 64,
        achieved_bpw: 4.5,
        per_layer_count: 1,
      },
    });

    // srcRaw must be untouched (deep copy).
    expect((srcRaw as Record<string, unknown>).quantization).toBeUndefined();

    const written = JSON.parse(await Bun.file(join(outDir, "config.json")).text());
    expect(written.quantization).toEqual(block);
    expect(written.quantization_config).toEqual(block);
    expect(written.model_type).toBe("llama");
    expect(written.nested).toEqual({ a: 1 });

    // Aux file copied.
    expect(await Bun.file(join(outDir, "tokenizer.json")).text()).toBe('{"tok":true}');

    // OptiQ sidecar written.
    const meta = JSON.parse(await Bun.file(join(outDir, "optiq_metadata.json")).text());
    expect(meta.method).toBe("uniform_affine");
    expect(meta.achieved_bpw).toBe(4.5);
    expect(meta.per_layer_count).toBe(1);
  });
});

describe("quantize → dequantize pipeline", () => {
  test("[64,256] bf16 tensor reconstructs with small affine error", () => {
    const rows = 64;
    const cols = 256;
    const data = new Array(rows * cols);
    // A smooth-ish signal so groups have meaningful dynamic range.
    for (let i = 0; i < data.length; i++) {
      data[i] = Math.sin(i * 0.013) * 3 + Math.cos(i * 0.007);
    }
    const w = bf16(data, [rows, cols]);
    const orig = [...w.toFloat32()];

    const q = quantize(w, 64, 4, "affine");
    const deq = dequantize(q.packed, q.scales, q.biases, {
      bits: 4,
      groupSize: 64,
      mode: "affine",
    });
    const recon = [...deq.toFloat32()];

    // Mean absolute error should be a small fraction of the signal RMS.
    let sqErr = 0;
    let sqSig = 0;
    for (let i = 0; i < orig.length; i++) {
      sqErr += (orig[i]! - recon[i]!) ** 2;
      sqSig += orig[i]! ** 2;
    }
    const relRmse = Math.sqrt(sqErr / sqSig);
    expect(relRmse).toBeLessThan(0.1); // 4-bit affine on smooth data

    // packed weight is uint32; scales/biases sized [rows, cols/groupSize].
    expect(q.packed.dtype).toBe(Dtype.uint32);
    expect(q.scales.shape).toEqual([rows, cols / 64]);

    w.dispose();
    q.packed.dispose();
    q.scales.dispose();
    q.biases.dispose();
    deq.dispose();
  });
});

// ---------------------------------------------------------------------------
// e2e: quantize the on-disk MiniCPM5-1B. WRITTEN BUT NOT RUN in the fast tier
// — loads a real (~1 GB) model. The orchestrator runs this with
// MLX_BUN_TEST_QUANTIZE=1.
// ---------------------------------------------------------------------------

const e2e = process.env.MLX_BUN_TEST_QUANTIZE ? test : test.skip;

describe("e2e: quantize on-disk MiniCPM5-1B (orchestrator-gated)", () => {
  e2e("quantizes to a tmp dir and produces a reopenable snapshot", async () => {
    const outDir = tmpDir("e2e-out");

    // inspect first: confirm the model resolves and is supported.
    const info = await inspectModel("MiniCPM5-1B-OptiQ-4bit");
    expect(info.ok).toBe(true);
    expect(info.support).toBe(true);

    // Re-quantize the (already-quantized) MiniCPM5 to uniform 4-bit g64.
    // inspectModel echoes the id, not the path — quantize the resolved snapshot.
    const r = await quantizeModelDir(SNAPSHOT_MINICPM5, outDir, { bits: 4, groupSize: 64 });
    expect(r.nQuantized).toBeGreaterThan(100);
    expect(r.achievedBpw).toBeGreaterThan(4);
    expect(r.achievedBpw).toBeLessThan(6);

    // config.json carries both quantization keys.
    const cfg = JSON.parse(await Bun.file(join(outDir, "config.json")).text());
    expect(cfg.quantization.bits).toBe(4);
    expect(cfg.quantization_config.bits).toBe(4);

    // model.safetensors written and reopenable through the loader.
    expect(existsSync(join(outDir, "model.safetensors"))).toBe(true);
    const w = await Weights.open(outDir);
    try {
      expect(w.has("model.embed_tokens.weight")).toBe(true);
      expect(w.has("model.embed_tokens.scales")).toBe(true);
      expect(w.tensor("model.embed_tokens.weight").dtype).toBe(Dtype.uint32);
    } finally {
      w.dispose();
    }
  }, 600_000);
});
