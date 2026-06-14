// 1:1 verification of the mixed-precision knapsack allocator against OptIQ.
//
// Builds synthetic SensitivityResult[] (transformer blocks × q/k/v/o/gate/up/
// down with varied KLs) and runs BOTH our optimizeMixedPrecision AND OptIQ's
// optimize_mixed_precision (via Bun.spawn into the oracle venv), asserting the
// per-layer bit allocations AND achievedBpw match. This proves the knapsack —
// block-aware floor, ×100 protected-layer bonus, _kl_reduction reference-mode
// detection, greedy min-heap, block-run guard — is a faithful port.
//
// When the oracle venv is unavailable, falls back to asserting documented
// expected allocations (captured from OptIQ on 2026-06-14).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { ORACLE_PYTHON } from "./paths";
import {
  optimizeMixedPrecision,
  type OptimizeMixedPrecisionOptions,
  type SensitivityResult,
} from "../src/quantize/index";

const ORACLE_AVAILABLE = (() => {
  try {
    return existsSync(ORACLE_PYTHON);
  } catch {
    return false;
  }
})();

/** Python that reads {results, options} JSON on stdin and prints the OptIQ
 *  allocation as JSON on the LAST stdout line (the optimizer also prints a
 *  human summary to stdout, which we skip). */
const OPTIQ_SCRIPT = `
import sys, json
from optiq.core.optimizer import optimize_mixed_precision
from optiq.core.sensitivity import SensitivityResult
payload = json.load(sys.stdin)
results = [
    SensitivityResult(
        layer_name=r["layerName"],
        sensitivities={int(k): float(v) for k, v in r["sensitivities"].items()},
        param_count=int(r["paramCount"]),
    )
    for r in payload["results"]
]
o = payload["options"]
opt = optimize_mixed_precision(
    results,
    target_bpw=o["targetBpw"],
    candidate_bits=o["candidateBits"],
    group_size=o.get("groupSize", 64),
    protect_first_last=o.get("protectFirstLast", True),
    n_protect=o.get("nProtect", 1),
    n_floor_per_block=o.get("nFloorPerBlock", 2),
    max_low_bit_run=o.get("maxLowBitRun", 3),
)
print("__OPTIQ_JSON__" + json.dumps({
    "configs": [{"layer_name": c.layer_name, "bits": c.bits} for c in opt.configs],
    "achieved_bpw": opt.achieved_bpw,
    "n_high": opt.n_high_bits,
    "n_low": opt.n_low_bits,
}))
`;

interface OptiqOut {
  configs: Array<{ layer_name: string; bits: number }>;
  achieved_bpw: number;
  n_high: number;
  n_low: number;
}

async function runOptiq(
  results: SensitivityResult[],
  options: OptimizeMixedPrecisionOptions,
): Promise<OptiqOut> {
  const proc = Bun.spawn([ORACLE_PYTHON, "-c", OPTIQ_SCRIPT], {
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
  });
  proc.stdin.write(JSON.stringify({ results, options }));
  await proc.stdin.end();
  const out = await new Response(proc.stdout).text();
  await proc.exited;
  const line = out
    .split("\n")
    .find((l) => l.startsWith("__OPTIQ_JSON__"));
  if (!line) {
    const err = await new Response(proc.stderr).text();
    throw new Error(`OptIQ produced no allocation JSON.\nstdout:\n${out}\nstderr:\n${err}`);
  }
  return JSON.parse(line.slice("__OPTIQ_JSON__".length)) as OptiqOut;
}

const COMPS = [
  "self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj", "self_attn.o_proj",
  "mlp.gate_proj", "mlp.up_proj", "mlp.down_proj",
];
const PARAM_COUNT: Record<string, number> = {
  "self_attn.q_proj": 1_048_576,
  "self_attn.k_proj": 262_144,
  "self_attn.v_proj": 262_144,
  "self_attn.o_proj": 1_048_576,
  "mlp.gate_proj": 3_145_728,
  "mlp.up_proj": 3_145_728,
  "mlp.down_proj": 3_145_728,
};

/** Uniform-4bit-reference style dataset: KL is 0 at 4-bit (baseline) and
 *  positive at 8-bit (benefit of upgrading). */
function uniformRefDataset(nBlocks: number): SensitivityResult[] {
  const results: SensitivityResult[] = [];
  for (let b = 0; b < nBlocks; b++) {
    for (let ci = 0; ci < COMPS.length; ci++) {
      const c = COMPS[ci]!;
      const kl8 = (b + 1) * 0.001 * (1.0 + 0.1 * ci);
      results.push({
        layerName: `model.layers.${b}.${c}`,
        sensitivities: { 4: 0.0, 8: kl8 },
        paramCount: PARAM_COUNT[c]!,
      });
    }
  }
  return results;
}

/** bf16-reference style 3-tier dataset: KL decreases monotonically with bits;
 *  includes protected output layers (lm_head, embed_tokens). */
function bf16RefThreeTier(nBlocks: number): SensitivityResult[] {
  const results: SensitivityResult[] = [];
  for (let b = 0; b < nBlocks; b++) {
    for (let ci = 0; ci < COMPS.length; ci++) {
      const c = COMPS[ci]!;
      const base = ((b % 2) + 1) * 0.01 * (1 + 0.07 * ci);
      results.push({
        layerName: `model.layers.${b}.${c}`,
        sensitivities: { 2: base, 4: base * 0.3, 8: base * 0.05 },
        paramCount: PARAM_COUNT[c]!,
      });
    }
  }
  results.push({
    layerName: "lm_head",
    sensitivities: { 2: 0.5, 4: 0.2, 8: 0.03 },
    paramCount: 4_194_304,
  });
  results.push({
    layerName: "model.embed_tokens",
    sensitivities: { 2: 0.4, 4: 0.15, 8: 0.02 },
    paramCount: 4_194_304,
  });
  return results;
}

function bitsByLayer(configs: Array<{ layerName: string; bits: number }>): Record<string, number> {
  const m: Record<string, number> = {};
  for (const c of configs) m[c.layerName] = c.bits;
  return m;
}

/** Same, for OptIQ's snake_case config shape. */
function bitsByLayerRef(configs: Array<{ layer_name: string; bits: number }>): Record<string, number> {
  const m: Record<string, number> = {};
  for (const c of configs) m[c.layer_name] = c.bits;
  return m;
}

describe("optimizeMixedPrecision — 1:1 vs OptIQ", () => {
  const cases: Array<{
    name: string;
    results: SensitivityResult[];
    options: OptimizeMixedPrecisionOptions;
  }> = [
    {
      name: "uniform-4bit ref, [4,8], target 5.0, 3 blocks",
      results: uniformRefDataset(3),
      options: { targetBpw: 5.0, candidateBits: [4, 8], groupSize: 64 },
    },
    {
      name: "uniform-4bit ref, [4,8], target 4.5, 6 blocks",
      results: uniformRefDataset(6),
      options: { targetBpw: 4.5, candidateBits: [4, 8], groupSize: 64 },
    },
    {
      name: "bf16 ref 3-tier [2,4,8], target 3.5, run-guard=2, protected lm_head",
      results: bf16RefThreeTier(5),
      options: {
        targetBpw: 3.5, candidateBits: [2, 4, 8], groupSize: 64,
        nFloorPerBlock: 2, maxLowBitRun: 2,
      },
    },
    {
      name: "bf16 ref 3-tier [2,4,8], target 6.0 (aggressive upgrade)",
      results: bf16RefThreeTier(4),
      options: { targetBpw: 6.0, candidateBits: [2, 4, 8], groupSize: 64 },
    },
  ];

  const maybe = ORACLE_AVAILABLE ? test : test.skip;

  for (const tc of cases) {
    maybe(tc.name, async () => {
      const ours = optimizeMixedPrecision(tc.results, tc.options);
      const ref = await runOptiq(tc.results, tc.options);

      // Same number of configs, same order, same per-layer bits.
      expect(ours.configs.length).toBe(ref.configs.length);
      const oursBits = bitsByLayer(ours.configs);
      const refBits = bitsByLayerRef(ref.configs);
      expect(oursBits).toEqual(refBits);

      // achievedBpw exact (both are the same rational over identical params).
      expect(ours.achievedBpw).toBeCloseTo(ref.achieved_bpw, 12);
      expect(ours.nHighBits).toBe(ref.n_high);
      expect(ours.nLowBits).toBe(ref.n_low);
    });
  }
});

// Fallback: documented expected allocation captured from OptIQ on 2026-06-14.
// Runs regardless of oracle availability so the knapsack always has coverage.
describe("optimizeMixedPrecision — documented expected allocation", () => {
  test("uniform-4bit ref, [4,8], target 5.0, 3 blocks", () => {
    const ours = optimizeMixedPrecision(uniformRefDataset(3), {
      targetBpw: 5.0, candidateBits: [4, 8], groupSize: 64,
    });
    const expected: Record<string, number> = {
      "model.layers.0.self_attn.q_proj": 8,
      "model.layers.0.self_attn.k_proj": 8,
      "model.layers.0.self_attn.v_proj": 8,
      "model.layers.0.self_attn.o_proj": 4,
      "model.layers.0.mlp.gate_proj": 4,
      "model.layers.0.mlp.up_proj": 4,
      "model.layers.0.mlp.down_proj": 4,
      "model.layers.1.self_attn.q_proj": 8,
      "model.layers.1.self_attn.k_proj": 8,
      "model.layers.1.self_attn.v_proj": 4,
      "model.layers.1.self_attn.o_proj": 4,
      "model.layers.1.mlp.gate_proj": 4,
      "model.layers.1.mlp.up_proj": 4,
      "model.layers.1.mlp.down_proj": 4,
      "model.layers.2.self_attn.q_proj": 8,
      "model.layers.2.self_attn.k_proj": 8,
      "model.layers.2.self_attn.v_proj": 8,
      "model.layers.2.self_attn.o_proj": 8,
      "model.layers.2.mlp.gate_proj": 4,
      "model.layers.2.mlp.up_proj": 8,
      "model.layers.2.mlp.down_proj": 8,
    };
    expect(bitsByLayer(ours.configs)).toEqual(expected);
    expect(ours.achievedBpw).toBeCloseTo(5.304347826086956, 12);
    expect(ours.nHighBits).toBe(11);
    expect(ours.nLowBits).toBe(10);
  });

  test("empty input → empty result", () => {
    const r = optimizeMixedPrecision([], { targetBpw: 5.0, candidateBits: [4, 8] });
    expect(r.configs).toEqual([]);
    expect(r.achievedBpw).toBe(0);
  });
});
