// Generate the small, dependency-free Colibri GLM-5.2 contract fixtures.
//
// This ordinary generator deliberately does not import, build, or execute
// Colibri. It consumes the tracked exact-pin oracle-capture.json constants and
// adds explicitly labeled derived operator/router/LRU/MTP scaffolding. The
// tracked compact real-model oracle is copied verbatim; regenerating its raw
// tensors remains a separate, explicit full-model capture operation.
//
// Regenerate:
//   bun scripts/gen-colibri-glm52-fixtures.ts
//   bun scripts/gen-colibri-glm52-fixtures.ts --out /tmp/colibri-glm52


import { createHash } from "node:crypto";
import { mkdirSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

const ORACLE_COMMIT = "44e489b196c9b7876b3d37a0570ebf1c6f90f54c";
const SEED_HEX = "0x51a7c0de";
const SEED = 0x51a7c0de;
const DEFAULT_OUT = resolve(import.meta.dir, "../fixtures/colibri-glm52");
const CAPTURE_PATH = resolve(DEFAULT_OUT, "oracle-capture.json");
const REAL_MODEL_ORACLE_PATH = resolve(DEFAULT_OUT, "real-model-oracle.json");
const ORACLE_PATCH_PATH = resolve(DEFAULT_OUT, "oracle-instrumentation.patch");
const captureText = readFileSync(CAPTURE_PATH, "utf8");
const realModelOracleText = readFileSync(REAL_MODEL_ORACLE_PATH, "utf8");
const oraclePatchText = readFileSync(ORACLE_PATCH_PATH, "utf8");
const capture = JSON.parse(captureText);
const realModelOracle = JSON.parse(realModelOracleText);
if (capture.oracle?.commit !== ORACLE_COMMIT) {
  throw new Error(`capture pin ${capture.oracle?.commit} != ${ORACLE_COMMIT}`);
}
if (realModelOracle.provenance?.colibri_pin !== ORACLE_COMMIT ||
    realModelOracle.manifest?.record_count !== 140) {
  throw new Error("real-model oracle has unexpected provenance or schema");
}

function outputDir(args: string[]): string {
  let out = DEFAULT_OUT;
  for (let i = 0; i < args.length; i++) {
    if (args[i] !== "--out") throw new Error(`unknown argument: ${args[i]}`);
    const value = args[++i];
    if (!value) throw new Error("--out requires a directory");
    out = resolve(value);
  }
  return out;
}

function f32(value: number): number {
  return Math.fround(value);
}

function xorshift32(seed: number): () => number {
  let state = seed >>> 0;
  return () => {
    state ^= state << 13;
    state ^= state >>> 17;
    state ^= state << 5;
    return state >>> 0;
  };
}

function seededWeights(rows: number, columns: number, seed: number, scale: number): number[][] {
  const next = xorshift32(seed);
  return Array.from({ length: rows }, () =>
    Array.from({ length: columns }, () => {
      const signed = (next() / 0xffff_ffff) * 2 - 1;
      return f32(signed * scale);
    }),
  );
}

function dequantInt8(qvalues: number[][], scales: number[]): number[][] {
  return qvalues.map((row, output) => row.map((value) => f32(value * scales[output]!)));
}

function dequantInt4Grouped(
  qbytes: number[],
  scales: number[],
  rows: number,
  columns: number,
  groupSize: number,
): number[][] {
  const rowBytes = Math.ceil(columns / 2);
  const groupsPerRow = Math.ceil(columns / groupSize);
  return Array.from({ length: rows }, (_, output) =>
    Array.from({ length: columns }, (_, input) => {
      const packed = qbytes[output * rowBytes + (input >> 1)]!;
      const nibble = input & 1 ? packed >> 4 : packed & 0xf;
      return f32((nibble - 8) * scales[output * groupsPerRow + Math.floor(input / groupSize)]!);
    }),
  );
}

function matmul(inputs: number[][], weightsOutputMajor: number[][]): number[][] {
  return inputs.map((input) =>
    weightsOutputMajor.map((weight) => {
      let accumulator = f32(0);
      for (let i = 0; i < input.length; i++) {
        accumulator = f32(accumulator + f32(input[i]! * weight[i]!));
      }
      return accumulator;
    }),
  );
}

function siluF32(value: number): number {
  return f32(value / f32(1 + f32(Math.exp(f32(-value)))));
}

function routeTopK(logits: number[], correctionBias: number[], topK: number, routedScale: number, capturedRaw: number[]) {
  const rawWeights = capturedRaw;
  const choice = rawWeights.map((value, index) => f32(value + correctionBias[index]!));
  const selected: number[] = [];
  for (let k = 0; k < topK; k++) {
    let best = -1;
    let bestValue = -1e30;
    for (let expert = 0; expert < choice.length; expert++) {
      if (!selected.includes(expert) && choice[expert]! > bestValue) {
        best = expert;
        bestValue = choice[expert]!;
      }
    }
    selected.push(best);
  }
  let sum = f32(1e-20);
  for (const expert of selected) sum = f32(sum + rawWeights[expert]!);
  const weights = selected.map((expert) => f32(f32(rawWeights[expert]! / sum) * routedScale));
  return { rawWeights, choice, selected, weights };
}

function makeNumericSpine(capturedNormalized: number[]) {
  const input = [0.5, -1, 2, -0.25].map(f32);
  const normWeight = [1, 0.75, 1.25, 0.5].map(f32);
  const epsilon = 1e-6;
  const normalized = capturedNormalized;
  const gate = seededWeights(3, 4, SEED ^ 0x11, 0.75);
  const up = seededWeights(3, 4, SEED ^ 0x22, 0.5);
  const down = seededWeights(4, 3, SEED ^ 0x33, 0.625);
  const gateOutput = matmul([normalized], gate)[0]!;
  const upOutput = matmul([normalized], up)[0]!;
  const activated = gateOutput.map((value, index) => f32(siluF32(value) * upOutput[index]!));
  const mlpOutput = matmul([activated], down)[0]!;
  const residual = input.map((value, index) => f32(value + mlpOutput[index]!));
  return {
    layer_order: [
      "rmsnorm(in_ln)",
      "MLA attention",
      "residual_add",
      "rmsnorm(post_ln)",
      "sparse_moe_or_dense_swiglu",
      "residual_add",
    ],
    tested_spine: "post_ln RMSNorm -> dense SwiGLU -> residual add",
    dtype: "captured Colibri ARM float32 RMSNorm followed by derived-canonical float32 SwiGLU",
    epsilon,
    input,
    norm_weight: normWeight,
    normalized,
    gate_weight_output_major: gate,
    up_weight_output_major: up,
    down_weight_output_major: down,
    gate_output: gateOutput,
    up_output: upOutput,
    silu_gate_times_up: activated,
    mlp_output: mlpOutput,
    residual_output: residual,
    atol: 1e-5,
    rtol: 1e-5,
  };
}

function simulateLru(accesses: number[], capacity: number) {
  const slots: Array<{ eid: number | null; used: number }> = [];
  const heat: Record<string, number> = {};
  const last: Record<string, number> = {};
  const trace = [];
  let clock = 0;
  for (const expert of accesses) {
    clock++;
    heat[String(expert)] = (heat[String(expert)] ?? 0) + 1;
    last[String(expert)] = clock;
    let slot = slots.findIndex((entry) => entry.eid === expert);
    let hit = slot >= 0;
    let evicted: number | null = null;
    if (!hit) {
      if (slots.length < capacity) {
        slot = slots.length;
        slots.push({ eid: null, used: 0 });
      } else {
        slot = 0;
        for (let i = 1; i < slots.length; i++) {
          if (slots[i]!.used < slots[slot]!.used) slot = i;
        }
        evicted = slots[slot]!.eid;
      }
    }
    slots[slot] = { eid: expert, used: clock };
    trace.push({
      access: expert,
      clock,
      hit,
      evicted,
      slot,
      slots: slots.map((entry) => ({ ...entry })),
    });
  }
  return { capacity, accesses, trace, final_heat: heat, final_last: last };
}

function makeCachePolicy(capturedLfru: any) {
  return {
    lru: {
      provenance_kind: "derived_canonical_trace",
      ...simulateLru([2, 4, 2, 7, 4, 9, 2, 9], 3),
    },
    lfru: {
      provenance_kind: "direct_exact_pin_c_capture",
      score_formula: "(heat << 8) | max(255 - (clock - last), 0)",
      hysteresis: "hot_score > cold_score + floor(cold_score / 4) + (4 << 8)",
      ...capturedLfru,
    },
  };
}

function makeMtpTrace() {
  const specifications = [
    { next_token: 10, draft: [11, 12, 13], verifier_argmax_by_row: [11, 99, 13, 50] },
    { next_token: 99, draft: [20, 21], verifier_argmax_by_row: [77, 21, 60] },
    { next_token: 77, draft: [30, 31], verifier_argmax_by_row: [30, 31, 88] },
  ];
  const rounds = [];
  const output: number[] = [];
  let kv = 5;
  let proposals = 0;
  let acceptedTotal = 0;
  for (const specification of specifications) {
    const before = kv;
    const accepted: number[] = [];
    let acceptedCount = 0;
    while (acceptedCount < specification.draft.length &&
           specification.verifier_argmax_by_row[acceptedCount] === specification.draft[acceptedCount]) {
      accepted.push(specification.draft[acceptedCount]!);
      acceptedCount++;
    }
    const stepRows = Array.from({ length: 1 + specification.draft.length }, (_, index) => before + index);
    const after = before + 1 + acceptedCount;
    const emitted = [specification.next_token, ...accepted];
    output.push(...emitted);
    proposals += specification.draft.length;
    acceptedTotal += acceptedCount;
    rounds.push({
      kv_before: before,
      next_token: specification.next_token,
      draft: specification.draft,
      step_batch: [specification.next_token, ...specification.draft],
      verifier_argmax_by_row: specification.verifier_argmax_by_row,
      accepted_prefix: accepted,
      accepted_count: acceptedCount,
      rejected_draft: acceptedCount < specification.draft.length ? specification.draft[acceptedCount] : null,
      emitted,
      main_kv_rows_written: stepRows,
      main_kv_valid_end_exclusive: after,
      stale_main_kv_rows_after_logical_rollback: stepRows.filter((row) => row >= after),
      next_logit_row: acceptedCount,
      next_sampled_token: specification.verifier_argmax_by_row[acceptedCount],
      hlast_row: acceptedCount,
      mtp_draft_kv_rows_written: specification.draft.map((_, index) => before - 1 + index),
      mtp_absorb: acceptedCount > 0 ? {
        pos_base: before,
        next_ids: accepted,
        rows_written: Array.from({ length: acceptedCount }, (_, index) => before + index),
      } : null,
      kv_after: after,
    });
    kv = after;
  }
  return {
    fixture_kind: "derived_semantic_contract",
    mode: "greedy deterministic verification",
    initial_kv_end_exclusive: 5,
    rounds,
    output_tokens: output,
    final_kv_end_exclusive: kv,
    mtp_proposed: proposals,
    mtp_accepted: acceptedTotal,
    acceptance_ratio: acceptedTotal / proposals,
    limitations: [
      "No GLM-5.2 MTP weights are executed.",
      "No teacher-forced logits, neural-head acceptance rate, or numeric MTP cache values are claimed.",
      "Sampling-mode carry_ban/rejection sampling is outside this greedy trace.",
    ],
    known_gaps_not_captured: [
      "EOS and tokenizer-special stop handling inside the draft verification loop",
      "n_new and max_t draft-length clamps",
      "24-proposal adaptive MTP guard pause and re-arm",
      "grammar-draft precedence and accounting",
      "temperature sampling, rejection probability, and carry_ban",
    ],
  };
}

const int8Captured = capture.constants.python.int8_per_row;
const int8Weights = int8Captured.weights_f32 as number[][];
const int8Inputs = int8Captured.input_f32 as number[][];
const int8 = {
  scales: int8Captured.scales_f32 as number[],
  qbytes: int8Captured.qbytes_u8 as number[],
  qvalues: int8Captured.qvalues_i8 as number[][],
};

const groupedCaptured = capture.constants.python.int4_grouped;
const groupedWeights = groupedCaptured.weights_f32 as number[][];
const groupedInputs = groupedCaptured.input_f32 as number[][];
const grouped = {
  groupsPerRow: Math.ceil(groupedWeights[0]!.length / groupedCaptured.group_size),
  rowBytes: Math.ceil(groupedWeights[0]!.length / 2),
  scales: groupedCaptured.scales_f32 as number[],
  qbytes: groupedCaptured.qbytes_u8 as number[],
  qvalues: groupedCaptured.qvalues_i4 as number[][],
};

function reshape(values: number[], rows: number, columns: number): number[][] {
  return Array.from({ length: rows }, (_, row) => values.slice(row * columns, (row + 1) * columns));
}

const dsaCases = capture.constants.c.dsa.map((data: any) => ({
  name: data.name,
  scores: data.scores_f32,
  keep: data.keep,
  expected: { threshold: data.threshold_f32, selected: data.selected },
}));

const routerLogits = [2, 1, 0.5, 0, -0.5, -1, -2, -3, 0.25, -0.25].map(f32);
const desiredChoice = [0.9, 0.9, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.4, 0.3].map(f32);
const routerRaw = capture.constants.c.elementary.sigmoidf_f32 as number[];
const routerBias = desiredChoice.map((target, index) => f32(target - routerRaw[index]!));
const router = routeTopK(routerLogits, routerBias, 8, 1.25, routerRaw);

const fixture = {
  schema_version: 1,
  oracle_commit: ORACLE_COMMIT,
  oracle_capture_sha256: createHash("sha256").update(captureText).digest("hex"),
  seed: SEED_HEX,
  quantization: {
    int8_per_row: {
      provenance_kind: "mixed_direct_capture_and_derived_dequant",
      component_provenance: {
        quantized_weights: "direct exact-pin Python quant_int8 capture",
        matmul_f32: "direct exact-pin Apple-ARM matmul_q capture",
        dequant_f32: "derived canonical q*scale expansion",
        round_clip_edges: "direct recorded NumPy execution of the pinned source expression",
      },
      bits: 8,
      shape: { output_rows: 3, input_columns: 8, input_batch_rows: 2 },
      storage: { qbytes: "uint8 view of int8, output-major", scales: "float32[output_rows]" },
      weights_f32: int8Weights,
      input_f32: int8Inputs,
      scales_f32: int8.scales,
      qbytes_u8: int8.qbytes,
      qvalues_i8: int8.qvalues,
      dequant_f32: dequantInt8(int8.qvalues, int8.scales),
      matmul_f32: reshape(capture.constants.c.quantized_matmul.int8_f32, 2, 3),
      round_clip_edges: capture.constants.python.round_clip_edges,
      atol: 1e-5,
      rtol: 1e-5,
    },
    int4_grouped: {
      provenance_kind: "mixed_direct_capture_and_derived_dequant",
      component_provenance: {
        quantized_weights: "direct exact-pin Python quant_int4_grouped capture",
        matmul_f32: "direct exact-pin Apple-ARM matmul_i4_grouped capture",
        dequant_f32: "derived canonical nibble/group-scale expansion",
        round_clip_edges: "direct recorded NumPy execution of the pinned source expression",
      },
      bits: 4,
      group_size: 16,
      shape: { output_rows: 3, input_columns: 19, groups_per_row: grouped.groupsPerRow, row_bytes: grouped.rowBytes, input_batch_rows: 2 },
      storage: { qbytes: "two offset-binary nibbles per byte, low input first", scales: "float32[output_rows, groups_per_row], row-major" },
      weights_f32: groupedWeights,
      input_f32: groupedInputs,
      scales_f32: grouped.scales,
      qbytes_u8: grouped.qbytes,
      qvalues_i4: grouped.qvalues,
      dequant_f32: dequantInt4Grouped(grouped.qbytes, grouped.scales, 3, 19, 16),
      matmul_f32: reshape(capture.constants.c.quantized_matmul.int4_grouped_f32, 2, 3),
      round_clip_edges: capture.constants.python.round_clip_edges,
      edge_cases: ["zero row and 1e-8 scale floor", "half-to-even ties", "clipping unit vectors", "partial final group", "odd input width and low-nibble tail", "signed cancellation"],
      atol: 1e-5,
      rtol: 1e-5,
    },
  },
  dsa_selection: {
    provenance_kind: "direct_exact_pin_c_capture",
    rule: "threshold is keep-th largest; scan > threshold by position, then == threshold by position",
    cases: dsaCases,
  },
  glm_operator_spine: {
    provenance_kind: "derived_canonical_spine_with_captured_rmsnorm",
    ...makeNumericSpine(capture.constants.c.elementary.rmsnorm_f32),
  },
  true_top8_router: {
    provenance_kind: "derived_canonical_router_with_captured_sigmoidf",
    expert_count: 10,
    top_k: 8,
    norm_topk: true,
    routed_scale: 1.25,
    logits_f32: routerLogits,
    correction_bias_f32: routerBias,
    expected_raw_sigmoid_f32: router.rawWeights,
    expected_choice_f32: router.choice,
    expected_indices: router.selected,
    expected_weights_f32: router.weights,
    tie_rule: "strict greater-than scan keeps the lower expert index first",
    weighting_rule: "rank on sigmoid(logit)+bias; normalize and scale the un-biased sigmoid weights",
    atol: 1e-6,
    rtol: 1e-6,
  },
  cache_policy: {
    provenance_kind: "mixed_derived_lru_and_direct_captured_lfru",
    ...makeCachePolicy(capture.constants.c.lfru),
  },
  mtp_spec_decode: makeMtpTrace(),
};

const dataText = `${JSON.stringify(fixture, null, 2)}\n`;
const dataBytes = new TextEncoder().encode(dataText);
const dataSha256 = createHash("sha256").update(dataBytes).digest("hex");
const captureBytes = new TextEncoder().encode(captureText);
const captureSha256 = createHash("sha256").update(captureBytes).digest("hex");
const realModelOracleBytes = new TextEncoder().encode(realModelOracleText);
const realModelOracleSha256 = createHash("sha256").update(realModelOracleBytes).digest("hex");
const oraclePatchBytes = new TextEncoder().encode(oraclePatchText);
const oraclePatchSha256 = createHash("sha256").update(oraclePatchBytes).digest("hex");
if (oraclePatchSha256 !== realModelOracle.provenance.patch_sha256) {
  throw new Error("real-model oracle patch hash does not match tracked patch");
}

const manifest = {
  schema_version: 3,
  fixture_set: "colibri-glm52",
  oracle: {
    repository: "https://github.com/JustVugg/colibri",
    commit: ORACLE_COMMIT,
    git_tree: capture.oracle.git_tree,
    source_files: capture.oracle.source_files,
  },
  capture: {
    path: "oracle-capture.json",
    command: "bun scripts/capture-colibri-glm52-oracle.ts",
    isolation: "validated git archive of the exact clean pin",
    recorded_capture_host_advisory: {
      target: capture.target,
      toolchain: capture.toolchain,
    },
  },
  generator: {
    path: "scripts/gen-colibri-glm52-fixtures.ts",
    command: "bun scripts/gen-colibri-glm52-fixtures.ts",
    seed: SEED_HEX,
    reproducibility_scope: "Byte-identical output is asserted on the recorded Bun 1.3.14 macOS arm64 runtime; cross-runtime JSON/Math byte identity is not claimed.",
  },
  integrity: "Git is the authenticity and integrity root. These SHA-256 values are reproducibility/drift checks, not signatures and not a replacement for Git object identity.",
  representation: {
    container: "UTF-8 JSON",
    byte_order: "little-endian for packed nibbles and int8 byte views",
    floats: "JSON numbers carrying float32-rounded values unless a field says double",
    integers: "JSON numbers; qbytes are uint8 in [0,255]",
  },
  files: [
    { path: "oracle-capture.json", bytes: captureBytes.byteLength, sha256: captureSha256 },
    { path: "v1.json", bytes: dataBytes.byteLength, sha256: dataSha256 },
    { path: "real-model-oracle.json", bytes: realModelOracleBytes.byteLength, sha256: realModelOracleSha256 },
    { path: "oracle-instrumentation.patch", bytes: oraclePatchBytes.byteLength, sha256: oraclePatchSha256 },
  ],
  provenance: [
    { section: "quantization.int8_per_row", kind: "mixed", source: "direct archived quant_int8 + Apple-ARM matmul_q captures; derived canonical dequant expansion" },
    { section: "quantization.int4_grouped", kind: "mixed", source: "direct archived quant_int4_grouped + Apple-ARM matmul_i4_grouped captures; derived canonical dequant expansion" },
    { section: "dsa_selection", kind: "direct_exact_pin_capture", source: "archived c/glm.c:partial_select_desc and production threshold/tie scans" },
    { section: "glm_operator_spine", kind: "derived_canonical", source: "captured archived c/glm.c:rmsnorm output; derived tiny dense SwiGLU/residual composition is not an executed Colibri layer" },
    { section: "true_top8_router", kind: "derived_canonical", source: "captured archived c/glm.c:sigmoidf outputs; derived ranking/normalization over canonical logits is not an executed moe()" },
    { section: "cache_policy.lru", kind: "derived_canonical", source: "canonical trace of c/glm.c LRU hit/promotion rules; moe() was not executed" },
    { section: "cache_policy.lfru", kind: "direct_exact_pin_capture", source: "archived c/tier.h:tier_lfru_score, tier_pick_lfru, tier_decay, including tie and uint32 wrap cases" },
    { section: "mtp_spec_decode", kind: "derived_canonical", source: "canonical greedy trace of c/glm.c:mtp_draft, mtp_absorb, spec_decode; no model/head executed" },
    { section: "real_model_glm_mla_router_mtp_kv", kind: "direct_instrumented_exact_pin_capture", source: "140 validated tensors from the exact public GLM-5.2 artifact; raw machine-local payloads reduced by scripts/colibri-g0-oracle-report.ts" },
  ],
  tolerances: {
    quantized_matmul: { atol: 1e-5, rtol: 1e-5 },
    glm_operator_spine: { atol: 1e-5, rtol: 1e-5 },
    router: { atol: 1e-6, rtol: 1e-6 },
    discrete_contracts: "exact",
  },
  g0_status: "complete: model-free fixtures plus validated real-model GLM/MLA/router/MTP/KV capture and same-machine runtime baseline",
};

const manifestText = `${JSON.stringify(manifest, null, 2)}\n`;
const out = outputDir(process.argv.slice(2));
mkdirSync(out, { recursive: true });
await Promise.all([
  Bun.write(resolve(out, "oracle-capture.json"), captureText),
  Bun.write(resolve(out, "v1.json"), dataText),
  Bun.write(resolve(out, "real-model-oracle.json"), realModelOracleText),
  Bun.write(resolve(out, "oracle-instrumentation.patch"), oraclePatchText),
  Bun.write(resolve(out, "manifest.json"), manifestText),
]);
console.log(`wrote ${resolve(out, "v1.json")} (${dataBytes.byteLength} bytes, sha256 ${dataSha256})`);
console.log(`wrote ${resolve(out, "manifest.json")}`);
