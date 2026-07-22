import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { join, resolve } from "node:path";
import { tmpdir } from "node:os";

const ROOT = resolve(import.meta.dir, "..");
const FIXTURE_DIR = join(ROOT, "fixtures/colibri-glm52");
const PIN = "44e489b196c9b7876b3d37a0570ebf1c6f90f54c";
const manifestText = readFileSync(join(FIXTURE_DIR, "manifest.json"), "utf8");
const fixtureText = readFileSync(join(FIXTURE_DIR, "v1.json"), "utf8");
const captureText = readFileSync(join(FIXTURE_DIR, "oracle-capture.json"), "utf8");
const realModelOracleText = readFileSync(join(FIXTURE_DIR, "real-model-oracle.json"), "utf8");
const oraclePatchText = readFileSync(join(FIXTURE_DIR, "oracle-instrumentation.patch"), "utf8");
const manifest = JSON.parse(manifestText);
const fixture = JSON.parse(fixtureText);
const capture = JSON.parse(captureText);
const realModelOracle = JSON.parse(realModelOracleText);

function f32(value: number): number {
  return Math.fround(value);
}

function expectWithin(actual: number[], expected: number[], atol: number, rtol: number): void {
  expect(actual).toHaveLength(expected.length);
  for (let i = 0; i < actual.length; i++) {
    const error = Math.abs(actual[i]! - expected[i]!);
    const limit = atol + rtol * Math.abs(expected[i]!);
    expect(error).toBeLessThanOrEqual(limit);
  }
}

function rintEven(value: number): number {
  const lower = Math.floor(value);
  const fraction = value - lower;
  if (fraction < 0.5) return lower;
  if (fraction > 0.5) return lower + 1;
  return lower % 2 === 0 ? lower : lower + 1;
}

function clamp(value: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, value));
}

function matmul(inputs: number[][], weights: number[][]): number[][] {
  return inputs.map((input) => weights.map((weight) => {
    let accumulator = f32(0);
    for (let i = 0; i < input.length; i++) {
      accumulator = f32(accumulator + f32(input[i]! * weight[i]!));
    }
    return accumulator;
  }));
}

function sigmoid(value: number): number {
  const exponential = f32(Math.exp(f32(-value)));
  return f32(1 / f32(1 + exponential));
}

function lfruScore(heat: number, last: number, clock: number): number {
  const age = (clock - last) >>> 0;
  return heat * 256 + (age < 255 ? 255 - age : 0);
}

describe("Colibri GLM-5.2 fixture package", () => {
  test("is pinned exactly and its payload checksum is valid", () => {
    expect(manifest.oracle.commit).toBe(PIN);
    expect(fixture.oracle_commit).toBe(PIN);
    expect(capture.oracle.commit).toBe(PIN);
    expect(manifest.oracle.git_tree).toBe("faae3d9594319ab856a4c3dd3f69a3afdd71f348");
    expect(capture.oracle.git_tree).toBe(manifest.oracle.git_tree);
    expect(capture.oracle.source_files["c/glm.c"].git_blob).toBe("a3e7ab74560639d869f43f5bf3543643bd483c27");
    expect(capture.oracle.source_files["c/tier.h"].git_blob).toBe("859cacf6311d397db3927361b0a6cccda032bf69");
    expect(capture.oracle.source_files["c/tools/convert_fp8_to_int4.py"].git_blob).toBe("59c891bc0192820f7699c142e01fe8dd8cba7a28");
    expect(manifest.generator.seed).toBe("0x51a7c0de");
    expect(manifest.generator.deterministic).toBeUndefined();
    expect(manifest.generator.reproducibility_scope).toContain("Bun 1.3.14 macOS arm64");
    expect(manifest.integrity).toContain("Git is the authenticity and integrity root");
    expect(manifest.oracle.local_read_only_path).toBeUndefined();
    expect(manifest.schema_version).toBe(3);
    expect(manifest.files).toHaveLength(4);
    const payloads: Array<{ name: string; text: string }> = [
      { name: "oracle-capture.json", text: captureText },
      { name: "v1.json", text: fixtureText },
      { name: "real-model-oracle.json", text: realModelOracleText },
      { name: "oracle-instrumentation.patch", text: oraclePatchText },
    ];
    for (const { name, text } of payloads) {
      const entry = manifest.files.find((file: { path: string }) => file.path === name);
      expect(entry.bytes).toBe(Buffer.byteLength(text));
      expect(createHash("sha256").update(text).digest("hex")).toBe(entry.sha256);
    }
    expect(fixture.oracle_capture_sha256).toBe(createHash("sha256").update(captureText).digest("hex"));
    expect(capture.target).toMatchObject({ os: "darwin", arch: "arm64", chip: "Apple M1 Max" });
    expect(capture.toolchain.apple_clang).toContain("Apple clang version 21.0.0");
    expect(capture.toolchain.python.numpy).toBe("2.4.6");
    expect(capture.toolchain.bun.version).toBe("1.3.14");
    expect(realModelOracle.provenance.colibri_pin).toBe(PIN);
    expect(realModelOracle.manifest.record_count).toBe(140);
    expect(realModelOracle.evidence.main_next.token_id).toBe(16);
    expect(realModelOracle.evidence.mtp_draft.token_id).toBe(16);
    expect(realModelOracle.provenance.patch_sha256).toBe(createHash("sha256").update(oraclePatchText).digest("hex"));
  });

  test("regenerates byte-identically without Colibri or model dependencies", () => {
    const temp = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-fixtures-"));
    const first = join(temp, "first");
    const second = join(temp, "second");
    try {
      for (const out of [first, second]) {
        const processResult = Bun.spawnSync(
          [process.execPath, "scripts/gen-colibri-glm52-fixtures.ts", "--out", out],
          { cwd: ROOT, stdout: "pipe", stderr: "pipe" },
        );
        expect(processResult.exitCode).toBe(0);
      }
      for (const name of ["manifest.json", "oracle-capture.json", "v1.json", "real-model-oracle.json", "oracle-instrumentation.patch"]) {
        const tracked = readFileSync(join(FIXTURE_DIR, name), "utf8");
        expect(readFileSync(join(first, name), "utf8")).toBe(tracked);
        expect(readFileSync(join(second, name), "utf8")).toBe(tracked);
      }
    } finally {
      rmSync(temp, { recursive: true, force: true });
    }
  });

  test("locks int8 byte views, scale floors, dequantization, and matmul", () => {
    const data = fixture.quantization.int8_per_row;
    const rows = data.shape.output_rows as number;
    const columns = data.shape.input_columns as number;
    expect(data.qbytes_u8).toHaveLength(rows * columns);
    expect(data.scales_f32[0]).toBe(f32(1e-8));
    expect(data.qvalues_i8[0]).toEqual(Array<number>(columns).fill(0));

    const recomputedScales: number[] = [];
    const recomputedQ: number[][] = [];
    for (const weights of data.weights_f32 as number[][]) {
      const amax = Math.max(...weights.map(Math.abs));
      const scale = f32(Math.max(f32(amax / 127), 1e-8));
      recomputedScales.push(scale);
      recomputedQ.push(weights.map((weight) => clamp(rintEven(f32(weight / scale)), -128, 127)));
    }
    expectWithin(data.scales_f32, recomputedScales, data.atol, data.rtol);
    expect(data.qvalues_i8).toEqual(recomputedQ);
    expect(data.scales_f32).toEqual(capture.constants.python.int8_per_row.scales_f32);
    expect(data.qbytes_u8).toEqual(capture.constants.python.int8_per_row.qbytes_u8);
    expect(data.qvalues_i8[1]).toEqual([0, 2, 2, 0, -2, -2, -127, 127]);
    const clip = data.round_clip_edges;
    expect(clip.int8_input_f32.map((value: number) => clamp(rintEven(value), -128, 127))).toEqual(clip.int8_expected_i16);
    expect(clip.int8_expected_i16[0]).toBe(-128);
    expect(clip.int8_expected_i16.at(-1)).toBe(127);

    for (let output = 0; output < rows; output++) {
      for (let input = 0; input < columns; input++) {
        const byte = data.qbytes_u8[output * columns + input] as number;
        const signed = byte > 127 ? byte - 256 : byte;
        expect(signed).toBe(data.qvalues_i8[output][input]);
        expect(data.dequant_f32[output][input]).toBe(
          f32(signed * data.scales_f32[output]),
        );
      }
    }

    const recomputed = data.input_f32.map((input: number[]) =>
      data.qvalues_i8.map((weights: number[], output: number) => {
        let accumulator = f32(0);
        for (let i = 0; i < columns; i++) {
          accumulator = f32(accumulator + f32(input[i]! * weights[i]!));
        }
        return f32(accumulator * data.scales_f32[output]);
      }),
    );
    for (let row = 0; row < recomputed.length; row++) {
      expectWithin(data.matmul_f32[row], recomputed[row], data.atol, data.rtol);
    }
    expect(data.matmul_f32.flat()).toEqual(capture.constants.c.quantized_matmul.int8_f32);
  });

  test("locks grouped int4 low/high nibble layout and group-tail math", () => {
    const data = fixture.quantization.int4_grouped;
    const rows = data.shape.output_rows as number;
    const columns = data.shape.input_columns as number;
    const rowBytes = data.shape.row_bytes as number;
    const groups = data.shape.groups_per_row as number;
    const groupSize = data.group_size as number;
    expect(columns % 2).toBe(1);
    expect(columns % groupSize).not.toBe(0);
    expect(data.qbytes_u8).toHaveLength(rows * rowBytes);
    expect(data.scales_f32).toHaveLength(rows * groups);
    expect(data.scales_f32[0]).toBe(f32(1e-8));

    const recomputedScales: number[] = [];
    const recomputedQ: number[][] = [];
    for (const weights of data.weights_f32 as number[][]) {
      const qrow: number[] = [];
      for (let group = 0; group < groups; group++) {
        const start = group * groupSize;
        const end = Math.min(start + groupSize, columns);
        let amax = 0;
        for (let i = start; i < end; i++) amax = Math.max(amax, Math.abs(weights[i]!));
        const scale = f32(Math.max(f32(amax / 7), 1e-8));
        recomputedScales.push(scale);
        for (let i = start; i < end; i++) qrow.push(clamp(rintEven(f32(weights[i]! / scale)), -8, 7));
      }
      recomputedQ.push(qrow);
    }
    expectWithin(data.scales_f32, recomputedScales, data.atol, data.rtol);
    expect(data.qvalues_i4).toEqual(recomputedQ);
    expect(data.scales_f32).toEqual(capture.constants.python.int4_grouped.scales_f32);
    expect(data.qbytes_u8).toEqual(capture.constants.python.int4_grouped.qbytes_u8);
    expect(data.qvalues_i4[1].slice(0, 16)).toEqual([-7, -6, -6, -4, -4, -2, -2, 0, 0, 2, 2, 4, 4, 6, 6, 7]);
    const clip = data.round_clip_edges;
    expect(clip.int4_input_f32.map((value: number) => clamp(rintEven(value), -8, 7))).toEqual(clip.int4_expected_i16);
    expect(clip.int4_expected_i16[0]).toBe(-8);
    expect(clip.int4_expected_i16.at(-1)).toBe(7);

    for (let output = 0; output < rows; output++) {
      for (let input = 0; input < columns; input++) {
        const byte = data.qbytes_u8[output * rowBytes + (input >> 1)] as number;
        const nibble = input & 1 ? byte >> 4 : byte & 0xf;
        const quantized = nibble - 8;
        expect(quantized).toBe(data.qvalues_i4[output][input]);
        const scale = data.scales_f32[output * groups + Math.floor(input / groupSize)];
        expect(data.dequant_f32[output][input]).toBe(f32(quantized * scale));
      }
    }

    const recomputed = data.input_f32.map((input: number[]) =>
      Array.from({ length: rows }, (_, output) => {
        let result = 0;
        for (let group = 0; group < groups; group++) {
          let accumulator = f32(0);
          const start = group * groupSize;
          const end = Math.min(start + groupSize, columns);
          for (let i = start; i < end; i++) {
            accumulator = f32(accumulator + f32(data.qvalues_i4[output][i] * input[i]!));
          }
          result += accumulator * data.scales_f32[output * groups + group];
        }
        return f32(result);
      }),
    );
    for (let row = 0; row < recomputed.length; row++) {
      expectWithin(data.matmul_f32[row], recomputed[row], data.atol, data.rtol);
    }
    expect(data.matmul_f32.flat()).toEqual(capture.constants.c.quantized_matmul.int4_grouped_f32);
  });

  test("locks DSA threshold ties and the two position-order scans", () => {
    for (const data of fixture.dsa_selection.cases) {
      const sorted = [...data.scores].sort((a: number, b: number) => b - a);
      const threshold = sorted[data.keep - 1];
      const selected: number[] = [];
      for (let i = 0; i < data.scores.length && selected.length < data.keep; i++) {
        if (data.scores[i] > threshold) selected.push(i);
      }
      for (let i = 0; i < data.scores.length && selected.length < data.keep; i++) {
        if (data.scores[i] === threshold) selected.push(i);
      }
      expect(data.expected.threshold).toBe(threshold);
      expect(data.expected.selected).toEqual(selected);
    }
    expect(fixture.dsa_selection.cases[0].expected.selected).toEqual([1, 4, 2, 3]);
    expect(fixture.dsa_selection.cases[1].expected.selected).toEqual([0, 1, 2]);
  });

  test("locks the tiny GLM RMSNorm/SwiGLU/residual operator spine", () => {
    const data = fixture.glm_operator_spine;
    let meanSquare = 0;
    for (const value of data.input) meanSquare += value * value;
    const denominator = f32(f32(meanSquare / data.input.length) + f32(data.epsilon));
    const inverseRoot = f32(1 / f32(Math.sqrt(denominator)));
    const normalized = data.input.map((value: number, index: number) =>
      f32(f32(value * inverseRoot) * data.norm_weight[index]),
    );
    expect(data.provenance_kind).toBe("derived_canonical_spine_with_captured_rmsnorm");
    expect(data.normalized).toEqual(capture.constants.c.elementary.rmsnorm_f32);
    expectWithin(data.normalized, normalized, data.atol, data.rtol);

    const gate = matmul([normalized], data.gate_weight_output_major)[0]!;
    const up = matmul([normalized], data.up_weight_output_major)[0]!;
    const activated = gate.map((value, index) => {
      const silu = f32(value / f32(1 + f32(Math.exp(f32(-value)))));
      return f32(silu * up[index]!);
    });
    const mlp = matmul([activated], data.down_weight_output_major)[0]!;
    const residual = data.input.map((value: number, index: number) => f32(value + mlp[index]!));
    expectWithin(data.gate_output, gate, data.atol, data.rtol);
    expectWithin(data.up_output, up, data.atol, data.rtol);
    expectWithin(data.silu_gate_times_up, activated, data.atol, data.rtol);
    expectWithin(data.mlp_output, mlp, data.atol, data.rtol);
    expectWithin(data.residual_output, residual, data.atol, data.rtol);
  });

  test("locks true top-8 ranking and raw-sigmoid weighting", () => {
    const data = fixture.true_top8_router;
    const raw = capture.constants.c.elementary.sigmoidf_f32 as number[];
    const choice = raw.map((value: number, index: number) => f32(value + data.correction_bias_f32[index]));
    const selected: number[] = [];
    while (selected.length < data.top_k) {
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
    for (const expert of selected) sum = f32(sum + raw[expert]!);
    const weights = selected.map((expert) => f32(f32(raw[expert]! / sum) * data.routed_scale));
    expect(data.expected_indices).toEqual(selected);
    expect(data.expected_indices).toHaveLength(8);
    expect(data.expected_indices.slice(0, 2)).toEqual([0, 1]);
    expect(data.provenance_kind).toBe("derived_canonical_router_with_captured_sigmoidf");
    expect(data.expected_raw_sigmoid_f32).toEqual(raw);
    expectWithin(data.expected_choice_f32, choice, data.atol, data.rtol);
    expectWithin(data.expected_weights_f32, weights, data.atol, data.rtol);
  });

  test("locks LRU cache hits/evictions and heat clocks", () => {
    const data = fixture.cache_policy.lru;
    expect(data.provenance_kind).toBe("derived_canonical_trace");
    const slots: Array<{ eid: number | null; used: number }> = [];
    const trace = [];
    let clock = 0;
    for (const expert of data.accesses) {
      clock++;
      let slot = slots.findIndex((entry) => entry.eid === expert);
      const hit = slot >= 0;
      let evicted: number | null = null;
      if (!hit) {
        if (slots.length < data.capacity) {
          slot = slots.length;
          slots.push({ eid: null, used: 0 });
        } else {
          slot = 0;
          for (let i = 1; i < slots.length; i++) if (slots[i]!.used < slots[slot]!.used) slot = i;
          evicted = slots[slot]!.eid;
        }
      }
      slots[slot] = { eid: expert, used: clock };
      trace.push({ access: expert, clock, hit, evicted, slot, slots: slots.map((entry) => ({ ...entry })) });
    }
    expect(data.trace).toEqual(trace);
    expect(data.trace.filter((entry: { hit: boolean }) => entry.hit)).toHaveLength(3);
    expect(data.trace.filter((entry: { evicted: number | null }) => entry.evicted !== null).map((entry: { evicted: number }) => entry.evicted)).toEqual([2, 7]);
  });

  test("locks LFRU scoring, hysteresis, deterministic candidates, and decay", () => {
    for (const data of fixture.cache_policy.lfru.cases) {
      const scores = data.heat.map((heat: number, expert: number) => lfruScore(heat, data.last[expert], data.clock));
      let coldSlot = 0;
      for (let slot = 1; slot < data.pinned.length; slot++) {
        if (scores[data.pinned[slot]] < scores[data.pinned[coldSlot]]) coldSlot = slot;
      }
      let hot = -1;
      let hotScore = 0;
      for (let expert = 0; expert < scores.length; expert++) {
        if (!data.pinned.includes(expert) && (hot < 0 || scores[expert] > hotScore)) {
          hot = expert;
          hotScore = scores[expert];
        }
      }
      const coldScore = scores[data.pinned[coldSlot]];
      const threshold = coldScore + Math.floor(coldScore / 4) + 4 * 256;
      const swap = hotScore > threshold;
      expect(data.scores_u64).toEqual(scores);
      expect(data.swap).toBe(swap);
      expect(data.slot).toBe(swap ? coldSlot : -1);
      expect(data.eid).toBe(swap ? hot : -1);
      expect(data.gain).toBe(swap ? Math.floor((hotScore - coldScore) / 256) : 0);
    }
    expect(fixture.cache_policy.lfru.provenance_kind).toBe("direct_exact_pin_c_capture");
    expect(fixture.cache_policy.lfru.cases.map((data: { swap: boolean }) => data.swap)).toEqual([true, false, true]);
    const tie = fixture.cache_policy.lfru.cases[2];
    expect(tie.name).toBe("tie_prefers_lower_slot_and_eid");
    expect(tie.slot).toBe(0);
    expect(tie.eid).toBe(2);
    const wrap = fixture.cache_policy.lfru.wrap_score_case;
    expect(lfruScore(wrap.heat, wrap.last, wrap.clock)).toBe(wrap.score_u64);
    expect(wrap.score_u64).toBe(1532);
    expect(fixture.cache_policy.lfru.decay_expected).toEqual(
      fixture.cache_policy.lfru.decay_input.map((value: number) => value >> 1),
    );
  });

  test("locks greedy MTP accept/reject and logical KV rollback semantics", () => {
    const data = fixture.mtp_spec_decode;
    expect(data.fixture_kind).toBe("derived_semantic_contract");
    let kv = data.initial_kv_end_exclusive as number;
    let proposed = 0;
    let acceptedTotal = 0;
    const output: number[] = [];
    for (let roundIndex = 0; roundIndex < data.rounds.length; roundIndex++) {
      const round = data.rounds[roundIndex];
      if (roundIndex > 0) expect(round.next_token).toBe(data.rounds[roundIndex - 1].next_sampled_token);
      expect(round.kv_before).toBe(kv);
      let accepted = 0;
      while (accepted < round.draft.length && round.verifier_argmax_by_row[accepted] === round.draft[accepted]) accepted++;
      const prefix = round.draft.slice(0, accepted);
      expect(round.accepted_count).toBe(accepted);
      expect(round.accepted_prefix).toEqual(prefix);
      expect(round.rejected_draft).toBe(accepted < round.draft.length ? round.draft[accepted] : null);
      expect(round.next_logit_row).toBe(accepted);
      expect(round.hlast_row).toBe(accepted);
      expect(round.emitted).toEqual([round.next_token, ...prefix]);
      const after = kv + 1 + accepted;
      expect(round.kv_after).toBe(after);
      expect(round.main_kv_valid_end_exclusive).toBe(after);
      expect(round.stale_main_kv_rows_after_logical_rollback).toEqual(
        round.main_kv_rows_written.filter((row: number) => row >= after),
      );
      if (accepted === 0) expect(round.mtp_absorb).toBeNull();
      else {
        expect(round.mtp_absorb.pos_base).toBe(kv);
        expect(round.mtp_absorb.next_ids).toEqual(prefix);
      }
      output.push(...round.emitted);
      proposed += round.draft.length;
      acceptedTotal += accepted;
      kv = after;
    }
    expect(data.output_tokens).toEqual(output);
    expect(data.final_kv_end_exclusive).toBe(kv);
    expect(data.mtp_proposed).toBe(proposed);
    expect(data.mtp_accepted).toBe(acceptedTotal);
    expect(data.limitations.join(" ")).toContain("No teacher-forced logits");
    expect(data.known_gaps_not_captured).toEqual(expect.arrayContaining([
      expect.stringContaining("EOS"),
      expect.stringContaining("draft-length clamps"),
      expect.stringContaining("adaptive MTP guard"),
    ]));
  });
});
