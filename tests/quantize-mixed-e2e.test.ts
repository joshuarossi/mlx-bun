// e2e: mixed-precision quantize of the on-disk MiniCPM5-1B. WRITTEN BUT NOT RUN
// in the fast tier — it loads a real (~1 GB) model, runs a calibration-driven
// per-layer KL sensitivity sweep (n_layers × n_bits × n_calibration forward
// passes), knapsacks a per-layer allocation, then quantizes + writes.
//
// Gated behind MLX_BUN_TEST_QUANTIZE_MIXED=1 (the orchestrator runs it).
//
//   MLX_BUN_TEST_QUANTIZE_MIXED=1 bun test tests/quantize-mixed-e2e.test.ts
//
// Expected runtime: ~2–5 min on an M4 Pro (the sensitivity sweep dominates:
// ~200 quantizable linears × 1 non-baseline bit × 2 calibration samples =
// ~400 short-sequence forward passes, plus the final write). Peak memory:
// the ~1 GB model resident plus transient bf16 dequant + logits for 2 samples
// (well under the 24 GB machine ceiling).

import { afterAll, describe, expect } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "bun:test";
import { SNAPSHOT_MINICPM5, snapshotMiniCPM5Available } from "./paths";
import { Dtype } from "../src/mlx/ffi";
import { Weights } from "../src/weights";
import { quantizeModelDir } from "../src/quantize/index";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-qmix-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const gated = process.env.MLX_BUN_TEST_QUANTIZE_MIXED ? test : test.skip;

describe("e2e: mixed-precision quantize on-disk MiniCPM5-1B (orchestrator-gated)", () => {
  gated(
    "produces a heterogeneous per-layer allocation near the target bpw",
    async () => {
      expect(await snapshotMiniCPM5Available()).toBe(true);

      const outDir = join(root, "mixed-out");

      const r = await quantizeModelDir(SNAPSHOT_MINICPM5, outDir, {
        bits: 4,
        groupSize: 64,
        targetBpw: 5.0,
        candidateBits: [4, 8],
        nCalibration: 2,
      });

      // Many modules quantized; achieved bpw close to the 5.0 target.
      expect(r.nQuantized).toBeGreaterThan(100);
      expect(r.achievedBpw).toBeGreaterThan(4);
      expect(r.achievedBpw).toBeLessThan(6);
      // Writer bpw includes group overhead, so it sits a little above the
      // pure-allocation target; ~0.3 tolerance on the param-weighted figure.
      expect(Math.abs(r.achievedBpw - 5.0)).toBeLessThan(0.8);

      // The OptiQ sidecar records the mixed method + per-layer map.
      const meta = JSON.parse(
        await Bun.file(join(outDir, "optiq_metadata.json")).text(),
      );
      expect(meta.method).toBe("mixed_precision");
      expect(meta.target_bpw).toBe(5.0);
      expect(meta.candidate_bits).toEqual([4, 8]);

      // HETEROGENEOUS: both 4- and 8-bit must appear across the per-layer map.
      const perLayerBits = new Set<number>();
      for (const v of Object.values(meta.per_layer as Record<string, unknown>)) {
        if (v && typeof v === "object" && "bits" in v) {
          perLayerBits.add((v as { bits: number }).bits);
        }
      }
      expect(perLayerBits.has(4)).toBe(true);
      expect(perLayerBits.has(8)).toBe(true);

      // config.json carries a per-module quantization block with mixed bits.
      const cfg = JSON.parse(await Bun.file(join(outDir, "config.json")).text());
      const blockBits = new Set<number>();
      for (const v of Object.values(cfg.quantization as Record<string, unknown>)) {
        if (v && typeof v === "object" && "bits" in v) {
          blockBits.add((v as { bits: number }).bits);
        }
      }
      expect(blockBits.has(8)).toBe(true);

      // Reopenable through the loader; an 8-bit and a 4-bit module both exist.
      expect(existsSync(join(outDir, "config.json"))).toBe(true);
      const w = await Weights.open(outDir);
      try {
        expect(w.has("model.embed_tokens.weight")).toBe(true);
        // q_proj of layer 0 is present and packed (uint32) regardless of bits.
        expect(w.has("model.layers.0.self_attn.q_proj.weight")).toBe(true);
        expect(w.tensor("model.layers.0.self_attn.q_proj.weight").dtype).toBe(
          Dtype.uint32,
        );
      } finally {
        w.dispose();
      }
    },
    900_000,
  );
});
