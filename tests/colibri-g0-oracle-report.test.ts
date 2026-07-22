import { describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  analyzeOracleCapture,
  assertOutputOutsideCapture,
  type OracleGeometry,
  normalizeSourceLabel,
  parseOracleManifest,
  parseOracleReportOptions,
  writeOracleSummary,
  type OracleReportOptions,
} from "../scripts/colibri-g0-oracle-report";

const PREFIX_IDS = [
  154822, 154824, 154827, 7984, 264, 48520, 1140, 315,
  17054, 12454, 10245, 5109, 11, 448, 825, 2805,
  16134, 11646, 1283, 1817, 1372, 13, 3155, 537,
  2936, 1573, 17054, 3589, 13, 154828, 154841, 154842,
];
const H40 = "a".repeat(40);
const H64 = "b".repeat(64);
const GEOMETRY: OracleGeometry = {
  hidden: 4, q_lora: 3, heads: 2, q_head: 3, comp: 5,
  kv_lora: 3, rope: 2, experts: 16, topk: 8, vocab: 256,
};

interface SyntheticRecord {
  phase: string;
  stage: string;
  dtype: "f32" | "i32";
  shape: number[];
  values: number[];
}

function raw(dtype: "f32" | "i32", values: number[]): Buffer {
  const buffer = Buffer.alloc(values.length * 4);
  values.forEach((value, index) => dtype === "f32" ? buffer.writeFloatLE(value, index * 4) : buffer.writeInt32LE(value, index * 4));
  return buffer;
}

function logits(rows: number, cols: number, winners: Map<number, number>): number[] {
  const values = Array.from({ length: rows * cols }, (_, index) => (index % cols) * 0.01);
  for (const [row, token] of winners) {
    values[row * cols + token] = 5;
    values[row * cols + ((token + cols - 1) % cols)] = 4;
  }
  return values;
}

function product(shape: number[]): number {
  return shape.reduce((value, dimension) => value * dimension, 1);
}

function tensor(phase: string, stage: string, dtype: "f32" | "i32", shape: number[], values?: number[]): SyntheticRecord {
  return { phase, stage, dtype, shape, values: values ?? Array.from({ length: product(shape) }, (_, index) => (index % 17 - 8) / 8) };
}

function layerRecords(phase: string, layer: number, rows: number, sparse: boolean): SyntheticRecord[] {
  const prefix = `layer${layer}`;
  const result = [
    tensor(phase, `${prefix}.residual.entry`, "f32", [rows, GEOMETRY.hidden]),
    tensor(phase, `${prefix}.attn.norm`, "f32", [rows, GEOMETRY.hidden]),
    tensor(phase, `${prefix}.attn.qr_norm`, "f32", [rows, GEOMETRY.q_lora]),
    tensor(phase, `${prefix}.attn.q_roped`, "f32", [rows, GEOMETRY.heads, GEOMETRY.q_head]),
    tensor(phase, `${prefix}.attn.comp_raw`, "f32", [rows, GEOMETRY.comp]),
    tensor(phase, `${prefix}.kv.lc`, "f32", [rows, GEOMETRY.kv_lora]),
    tensor(phase, `${prefix}.kv.rc`, "f32", [rows, GEOMETRY.rope]),
    tensor(phase, `${prefix}.attn.output`, "f32", [rows, GEOMETRY.hidden]),
    tensor(phase, `${prefix}.attn.post_residual`, "f32", [rows, GEOMETRY.hidden]),
    tensor(phase, `${prefix}.ffn.norm`, "f32", [rows, GEOMETRY.hidden]),
  ];
  if (sparse) {
    const ids = Array.from({ length: rows * GEOMETRY.topk }, (_, index) => (Math.floor(index / GEOMETRY.topk) + index % GEOMETRY.topk) % GEOMETRY.experts);
    result.push(
      tensor(phase, `${prefix}.moe.sigmoid_scores`, "f32", [rows, GEOMETRY.experts], Array(rows * GEOMETRY.experts).fill(0.5)),
      tensor(phase, `${prefix}.moe.top_ids`, "i32", [rows, GEOMETRY.topk], ids),
      tensor(phase, `${prefix}.moe.top_weights`, "f32", [rows, GEOMETRY.topk], Array(rows * GEOMETRY.topk).fill(1 / GEOMETRY.topk)),
      tensor(phase, `${prefix}.moe.keff`, "i32", [rows], Array(rows).fill(GEOMETRY.topk)),
    );
  }
  result.push(
    tensor(phase, `${prefix}.ffn.output`, "f32", [rows, GEOMETRY.hidden]),
    tensor(phase, `${prefix}.residual.final`, "f32", [rows, GEOMETRY.hidden]),
  );
  return result;
}

function records(): SyntheticRecord[] {
  return [
    tensor("prefill", "main.input_ids", "i32", [32], PREFIX_IDS),
    ...layerRecords("prefill", 0, 32, false),
    ...layerRecords("prefill", 3, 32, true),
    ...layerRecords("prefill", 77, 32, true),
    tensor("prefill", "main.h_all", "f32", [32, GEOMETRY.hidden]),
    tensor("prefill", "main.logits", "f32", [32, GEOMETRY.vocab], logits(32, GEOMETRY.vocab, new Map([[31, 3]]))),
    tensor("prefill", "main.next_id", "i32", [1], [3]),

    tensor("mtp_absorb", "mtp_absorb.next_ids", "i32", [31], PREFIX_IDS.slice(1)),
    tensor("mtp_absorb", "mtp_absorb.eh_proj", "f32", [31, GEOMETRY.hidden]),
    ...layerRecords("mtp_absorb", 78, 31, true),
    tensor("mtp_absorb", "mtp_absorb.post_layer", "f32", [31, GEOMETRY.hidden]),

    tensor("mtp_draft", "mtp_draft.emb_norm", "f32", [GEOMETRY.hidden]),
    tensor("mtp_draft", "mtp_draft.hidden_norm", "f32", [GEOMETRY.hidden]),
    tensor("mtp_draft", "mtp_draft.concat", "f32", [GEOMETRY.hidden * 2]),
    tensor("mtp_draft", "mtp_draft.eh_proj", "f32", [GEOMETRY.hidden]),
    ...layerRecords("mtp_draft", 78, 1, true),
    tensor("mtp_draft", "mtp_draft.post_layer", "f32", [GEOMETRY.hidden]),
    tensor("mtp_draft", "mtp_draft.head_norm", "f32", [GEOMETRY.hidden]),
    tensor("mtp_draft", "mtp_draft.logits", "f32", [1, GEOMETRY.vocab], logits(1, GEOMETRY.vocab, new Map([[0, 4]]))),
    tensor("mtp_draft", "mtp_draft.draft_id", "i32", [1], [4]),
    tensor("mtp_draft", "mtp_draft.count", "i32", [1], [1]),

    tensor("decode32", "main.input_ids", "i32", [1], [16]),
    ...layerRecords("decode32", 0, 1, false),
    ...layerRecords("decode32", 3, 1, true),
    ...layerRecords("decode32", 77, 1, true),
    tensor("decode32", "main.hidden_prenorm", "f32", [1, GEOMETRY.hidden]),
    tensor("decode32", "main.head_norm", "f32", [GEOMETRY.hidden]),
    tensor("decode32", "main.logits", "f32", [1, GEOMETRY.vocab], logits(1, GEOMETRY.vocab, new Map([[0, 2]]))),
  ];
}

function writeCapture(dir: string, source = records()): void {
  const manifest = ["name\tdtype\tshape\tbytes"];
  source.forEach((record, sequence) => {
    const name = `${sequence.toString().padStart(4, "0")}.${record.phase}.${record.stage}.${record.dtype}`;
    const buffer = raw(record.dtype, record.values);
    writeFileSync(join(dir, name), buffer);
    manifest.push(`${name}\t${record.dtype}\t${record.shape.join("x")}\t${buffer.byteLength}`);
  });
  writeFileSync(join(dir, "manifest.tsv"), `${manifest.join("\n")}\n`);
}

function options(dir: string): OracleReportOptions {
  return {
    oracleDir: dir,
    out: join(dir, "summary.json"),
    sourceLabel: "runs/colibri-g0/synthetic-oracle",
    provenance: {
      colibri_pin: H40,
      snapshot_revision: H40,
      source_sha256: H64,
      patch_sha256: H64,
      binary_sha256: H64,
      tokenizer_sha256: H64,
    },
  };
}

describe("Colibri G0 numeric oracle report", () => {
  test("validates and deterministically reduces a synthetic capture", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-oracle-report-"));
    try {
      writeCapture(dir);
      const first = analyzeOracleCapture(options(dir), GEOMETRY);
      const second = analyzeOracleCapture(options(dir), GEOMETRY);
      expect(second).toEqual(first);
      expect(first).toMatchObject({
        schema_version: 1,
        capture_kind: "colibri_glm52_g0_numeric_oracle",
        source_label: "runs/colibri-g0/synthetic-oracle",
        manifest: { record_count: 140 },
        evidence: {
          teacher_decode_id: 16,
          main_next: { token_id: 3, logit_argmax: 3, margin_top1_top2: 1 },
          mtp_draft: { count: 1, token_id: 4, logit_argmax: 4, margin_top1_top2: 1 },
        },
      });
      expect(first.files).toHaveLength(140);
      expect(first.files.every((file) => file.sha256.length === 64)).toBe(true);
      expect(first.files.find((file) => file.source.includes("top_weights"))).toMatchObject({ row_sum_min: 1, row_sum_max: 1 });
      expect(first.logit_rows).toHaveLength(34);
      expect(first.logit_rows.find((row) => row.phase === "prefill" && row.row === 31)?.top128[0]).toEqual([3, 5]);
      expect(first.logit_rows.every((row) => row.top128.length === 128)).toBe(true);
      expect(first.files.every((file) => !file.source.startsWith("/"))).toBe(true);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });

  test("rejects malformed manifests, sequence gaps, and byte-count lies", () => {
    expect(() => parseOracleManifest("wrong\n")).toThrow("manifest header");
    expect(() => parseOracleManifest("name\tdtype\tshape\tbytes\n0001.prefill.main.input_ids.i32\ti32\t1\t4\n"))
      .toThrow("expected sequence 0000");
    expect(() => parseOracleManifest("name\tdtype\tshape\tbytes\n0000.prefill.main.input_ids.i32\ti32\t1\t8\n"))
      .toThrow("does not match");
  });

  test("rejects incomplete captures and semantic shape drift", () => {
    for (const mutation of ["missing", "scalar-shape"] as const) {
      const dir = mkdtempSync(join(tmpdir(), `mlx-bun-oracle-schema-${mutation}-`));
      try {
        const source = records();
        if (mutation === "missing") source.pop();
        else {
          const scalar = source.find((record) => record.stage === "main.next_id")!;
          scalar.shape = [2];
          scalar.values = [3, 3];
        }
        writeCapture(dir, source);
        expect(() => analyzeOracleCapture(options(dir), GEOMETRY)).toThrow(mutation === "missing" ? "expected 140 oracle records" : "expected shape 1");
      } finally {
        rmSync(dir, { recursive: true, force: true });
      }
    }
  });

  test("fails closed on non-finite floats and invalid router records", () => {
    for (const mutation of ["nan", "duplicate", "weights", "scores"] as const) {
      const dir = mkdtempSync(join(tmpdir(), `mlx-bun-oracle-${mutation}-`));
      try {
        const source = records();
        if (mutation === "nan") source.find((record) => record.stage === "layer3.residual.entry")!.values[1] = Number.NaN;
        if (mutation === "duplicate") source.find((record) => record.stage === "layer3.moe.top_ids")!.values[1] = 0;
        if (mutation === "weights") source.find((record) => record.stage === "layer3.moe.top_weights")!.values[0] = -0.1;
        if (mutation === "scores") source.find((record) => record.stage === "layer3.moe.sigmoid_scores")!.values[0] = 1.1;
        writeCapture(dir, source);
        expect(() => analyzeOracleCapture(options(dir), GEOMETRY)).toThrow(
          mutation === "nan" ? "non-finite" : mutation === "duplicate" ? "duplicate expert id" : mutation === "weights" ? "negative router weight" : "sigmoid score",
        );
      } finally {
        rmSync(dir, { recursive: true, force: true });
      }
    }
  });

  test("requires explicit validated provenance and normalized relative labels", () => {
    const args = [
      "--oracle-dir", "/tmp/oracle", "--out", "/tmp/out.json", "--source-label", "runs/oracle",
      "--colibri-pin", H40, "--snapshot-revision", H40,
      "--source-sha256", H64, "--patch-sha256", H64,
      "--binary-sha256", H64, "--tokenizer-sha256", H64,
    ];
    expect(parseOracleReportOptions(args)).toMatchObject({ sourceLabel: "runs/oracle", provenance: { binary_sha256: H64 } });
    expect(() => parseOracleReportOptions(args.slice(0, -2))).toThrow("--tokenizer-sha256 is required");
    expect(() => parseOracleReportOptions([...args, "--out", "again"])).toThrow("duplicate argument: --out");
    expect(() => normalizeSourceLabel("/absolute/capture")).toThrow("must be relative");
    expect(() => normalizeSourceLabel("runs/../capture")).toThrow("must be normalized");
  });

  test("rejects payload symlinks and atomically replaces an output symlink", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-oracle-symlink-"));
    const outside = mkdtempSync(join(tmpdir(), "mlx-bun-oracle-outside-"));
    try {
      writeCapture(dir);
      const payload = join(dir, "0000.prefill.main.input_ids.i32");
      const externalPayload = join(outside, "payload.bin");
      writeFileSync(externalPayload, raw("i32", PREFIX_IDS));
      rmSync(payload);
      symlinkSync(externalPayload, payload);
      expect(() => analyzeOracleCapture(options(dir), GEOMETRY)).toThrow("regular non-symlink file");

      const target = join(outside, "target.txt");
      const out = join(dir, "summary.json");
      writeFileSync(target, "do not overwrite\n");
      symlinkSync(target, out);
      writeOracleSummary(out, { safe: true });
      expect(readFileSync(target, "utf8")).toBe("do not overwrite\n");
      expect(JSON.parse(readFileSync(out, "utf8"))).toEqual({ safe: true });
    } finally {
      rmSync(dir, { recursive: true, force: true });
      rmSync(outside, { recursive: true, force: true });
    }
  });

  test("writes deterministic compact JSON atomically", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-oracle-cli-"));
    const reportDir = mkdtempSync(join(tmpdir(), "mlx-bun-oracle-report-out-"));
    try {
      writeCapture(dir);
      const out = join(reportDir, "report.json");
      const summary = analyzeOracleCapture({ ...options(dir), sourceLabel: "runs/synthetic" }, GEOMETRY);
      expect(() => assertOutputOutsideCapture(join(dir, "manifest.tsv"), dir)).toThrow("outside the raw oracle directory");
      expect(() => assertOutputOutsideCapture(join(dir, "nested", "summary.json"), dir)).toThrow();
      assertOutputOutsideCapture(out, dir);
      writeOracleSummary(out, summary);
      const text = readFileSync(out, "utf8");
      expect(text.endsWith("\n")).toBe(true);
      expect(JSON.parse(text)).toMatchObject({ source_label: "runs/synthetic", manifest: { record_count: 140 } });
      expect(text.length).toBeLessThan(200_000);
    } finally {
      rmSync(dir, { recursive: true, force: true });
      rmSync(reportDir, { recursive: true, force: true });
    }
  });
});
