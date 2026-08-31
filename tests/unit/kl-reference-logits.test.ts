// Saved-teacher KL (`kl --reference-logits`) — model-free tier.
//
// Writes a tiny synthetic dump in the real format_version 1 layout (small
// vocab, tiny top_k, 2 sequences) and scores it against a FAKE candidate
// forward (the `forward` seam of evaluateKlVsReferenceLogits), so the reader,
// the chunk↔record alignment and the KL/mass/top-1 math are all exercised
// without weights. Expected values are computed independently in plain JS
// from the same fp16-rounded teacher logits the reader will decode.

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { evaluateKlVsReferenceLogits, type TeacherForcedLogits } from "../../src/eval/kl";
import { ReferenceLogitsDump } from "../../src/eval/reference-logits";

const VOCAB = 12;
const TOP_K = 4;
const CTX = 6;
const N_SEQS = 2;
const RECORDS = CTX - 1; // record r = distribution over token r+1

/** Deterministic LCG — no RNG dependency. */
function lcg(seed: number): () => number {
  let s = seed >>> 0;
  return () => {
    s = (s * 1664525 + 1013904223) >>> 0;
    return s / 2 ** 32;
  };
}

/** Round a float32 vector through float16 exactly as the dump does. */
function throughFloat16(values: Float32Array): { bytes: Uint8Array; decoded: Float32Array } {
  const a = MlxArray.fromFloat32(values, [values.length]);
  const h = a.astype(Dtype.float16);
  try {
    return { bytes: h.rawBytes(), decoded: h.toFloat32Host() };
  } finally {
    h.dispose();
    a.dispose();
  }
}

function logsumexp(xs: ArrayLike<number>): number {
  let m = -Infinity;
  for (let i = 0; i < xs.length; i++) if (xs[i]! > m) m = xs[i]!;
  let s = 0;
  for (let i = 0; i < xs.length; i++) s += Math.exp(xs[i]! - m);
  return m + Math.log(s);
}

interface Dump {
  dir: string;
  tokens: number[][];
  /** [seq][record] top-k indices (descending by teacher logit). */
  indices: Int32Array[][];
  /** [seq][record] teacher logits at those indices, AFTER fp16 rounding. */
  refLogits: Float32Array[][];
  /** [seq][record] full-vocab teacher logsumexp. */
  refLse: number[][];
}

/** Write a format_version 1 dump from full-vocab teacher logits. */
function writeDump(teacher: Float32Array[][], tokens: number[][]): Dump {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-kl-teacher-"));
  const recordBytes = TOP_K * 6 + 4;

  const tokBuf = Buffer.alloc(N_SEQS * CTX * 4);
  for (let s = 0; s < N_SEQS; s++)
    for (let t = 0; t < CTX; t++) tokBuf.writeInt32LE(tokens[s]![t]!, (s * CTX + t) * 4);
  writeFileSync(join(dir, "tokens.bin"), tokBuf);

  const indices: Int32Array[][] = [];
  const refLogits: Float32Array[][] = [];
  const refLse: number[][] = [];
  for (let s = 0; s < N_SEQS; s++) {
    const buf = Buffer.alloc(RECORDS * recordBytes);
    indices.push([]);
    refLogits.push([]);
    refLse.push([]);
    for (let r = 0; r < RECORDS; r++) {
      const row = teacher[s]![r]!;
      const order = [...row.keys()].sort((a, b) => (row[b]! - row[a]!) || (a - b));
      const idx = Int32Array.from(order.slice(0, TOP_K));
      const top = Float32Array.from(idx, (v) => row[v]!);
      const { bytes, decoded } = throughFloat16(top);
      const lse = logsumexp(row);

      const base = r * recordBytes;
      for (let j = 0; j < TOP_K; j++) buf.writeInt32LE(idx[j]!, base + j * 4);
      buf.set(bytes, base + TOP_K * 4);
      buf.writeFloatLE(lse, base + TOP_K * 6);

      indices[s]!.push(idx);
      refLogits[s]!.push(decoded);
      refLse[s]!.push(lse);
    }
    writeFileSync(join(dir, `seq-${s}.bin`), buf);
  }

  writeFileSync(join(dir, "manifest.json"), JSON.stringify({
    format_version: 1,
    model: "synthetic/teacher-bf16",
    corpus_sha256: "0".repeat(64),
    ctx_len: CTX,
    n_seqs: N_SEQS,
    top_k: TOP_K,
    positions_per_seq: RECORDS,
    created: "2026-08-31T00:00:00Z",
    notes: "unit test",
  }));

  return { dir, tokens, indices, refLogits, refLse };
}

/** A candidate forward that replays a fixed [seq][pos][vocab] logit table in
 *  `chunk`-sized pieces — the shape the engine forward emits. */
function fakeForward(cand: Float32Array[][], tokens: number[][], chunk: number): TeacherForcedLogits {
  let seq = 0;
  return (ids, onChunk) => {
    const s = seq++;
    expect(ids).toEqual(tokens[s]!); // the reader must hand back this seq's tokens
    const flat = new Float32Array(CTX * VOCAB);
    for (let t = 0; t < CTX; t++) flat.set(cand[s]![t]!, t * VOCAB);
    for (let pos = 0; pos < CTX; pos += chunk) {
      const n = Math.min(chunk, CTX - pos);
      const a = MlxArray.fromFloat32(flat.subarray(pos * VOCAB, (pos + n) * VOCAB), [1, n, VOCAB]);
      try {
        onChunk(pos, a);
      } finally {
        a.dispose();
      }
    }
  };
}

function percentile(xs: number[], pct: number): number {
  const s = [...xs].sort((a, b) => a - b);
  return s[Math.min(s.length - 1, Math.max(0, Math.floor((pct / 100) * s.length)))]!;
}

function makeTables(): { teacher: Float32Array[][]; cand: Float32Array[][]; tokens: number[][] } {
  const rnd = lcg(20260831);
  const teacher: Float32Array[][] = [];
  const cand: Float32Array[][] = [];
  const tokens: number[][] = [];
  for (let s = 0; s < N_SEQS; s++) {
    teacher.push([]);
    cand.push([]);
    tokens.push(Array.from({ length: CTX }, (_, t) => (s * 7 + t * 3) % VOCAB));
    for (let t = 0; t < CTX; t++) {
      const ref = new Float32Array(VOCAB);
      const q = new Float32Array(VOCAB);
      for (let v = 0; v < VOCAB; v++) {
        ref[v] = (rnd() * 8) - 4;
        q[v] = ref[v]! + (rnd() * 2 - 1); // a drifted candidate
      }
      teacher[s]!.push(ref);
      cand[s]!.push(q);
    }
  }
  return { teacher, cand, tokens };
}

/** The independent oracle: KL, captured mass and top-1 straight from the
 *  tables, with no engine code involved. */
function expectedMetrics(dump: Dump, cand: Float32Array[][]): {
  perSeqMeans: number[]; pooled: number[]; mass: number[]; top1: number[];
} {
  const perSeqMeans: number[] = [];
  const pooled: number[] = [];
  const mass: number[] = [];
  const top1: number[] = [];
  for (let s = 0; s < N_SEQS; s++) {
    const kls: number[] = [];
    for (let r = 0; r < RECORDS; r++) {
      const idx = dump.indices[s]![r]!;
      const ref = dump.refLogits[s]![r]!;
      const lseRef = dump.refLse[s]![r]!;
      const row = cand[s]![r]!;           // candidate logits AT POSITION r
      const lseCand = logsumexp(row);
      let kl = 0;
      let m = 0;
      for (let j = 0; j < TOP_K; j++) {
        const logP = ref[j]! - lseRef;
        const p = Math.exp(logP);
        m += p;
        kl += p * (logP - (row[idx[j]!]! - lseCand));
      }
      kls.push(kl);
      pooled.push(kl);
      mass.push(m);
      let am = 0;
      for (let v = 1; v < VOCAB; v++) if (row[v]! > row[am]!) am = v;
      top1.push(am === idx[0]! ? 1 : 0);
    }
    perSeqMeans.push(kls.reduce((a, b) => a + b, 0) / kls.length);
  }
  return { perSeqMeans, pooled, mass, top1 };
}

describe("kl --reference-logits", () => {
  test("reader round-trips the format_version 1 layout", () => {
    const { teacher, tokens } = makeTables();
    const dump = writeDump(teacher, tokens);
    try {
      const d = ReferenceLogitsDump.open(dump.dir);
      expect(d.topK).toBe(TOP_K);
      expect(d.ctxLen).toBe(CTX);
      expect(d.nSeqs).toBe(N_SEQS);
      expect(d.positionsPerSeq).toBe(RECORDS);
      expect(d.tokens(1)).toEqual(tokens[1]!);

      const recs = d.readRecords(1, 2, RECORDS);
      expect(recs.count).toBe(RECORDS - 2);
      expect(Array.from(recs.indices.subarray(0, TOP_K))).toEqual(Array.from(dump.indices[1]![2]!));
      expect(Array.from(recs.logits.subarray(0, TOP_K))).toEqual(Array.from(dump.refLogits[1]![2]!));
      expect(recs.logsumexp[0]!).toBeCloseTo(dump.refLse[1]![2]!, 5);
      // indices are descending by teacher logit
      for (let j = 1; j < TOP_K; j++)
        expect(recs.logits[j]!).toBeLessThanOrEqual(recs.logits[j - 1]!);
      d.close();
    } finally {
      rmSync(dump.dir, { recursive: true, force: true });
    }
  });

  test("KL, captured mass and top-1 match an independent computation", async () => {
    const { teacher, cand, tokens } = makeTables();
    const dump = writeDump(teacher, tokens);
    try {
      // chunk 4 over ctx 6: the second chunk straddles the last position,
      // which has no teacher record and must be dropped.
      const res = await evaluateKlVsReferenceLogits({
        candidate: "unused-when-forward-is-injected",
        referenceDir: dump.dir,
        forward: fakeForward(cand, tokens, 4),
      });
      const want = expectedMetrics(dump, cand);

      expect(res.nPrompts).toBe(N_SEQS);
      expect(res.nPositions).toBe(N_SEQS * RECORDS);
      expect(res.seqLen).toBe(CTX);
      expect(res.topK).toBe(TOP_K);
      expect(res.refModel).toBe("synthetic/teacher-bf16");

      const wantMean = want.perSeqMeans.reduce((a, b) => a + b, 0) / N_SEQS;
      expect(res.meanKl).toBeCloseTo(wantMean, 5);
      expect(res.medianKl).toBeCloseTo(percentile(want.pooled, 50), 5);
      expect(res.p95Kl).toBeCloseTo(percentile(want.pooled, 95), 5);
      expect(res.meanCapturedMass).toBeCloseTo(
        want.mass.reduce((a, b) => a + b, 0) / want.mass.length, 5,
      );
      expect(res.top1Agreement).toBeCloseTo(
        want.top1.reduce((a, b) => a + b, 0) / want.top1.length, 10,
      );
      // the drifted candidate really does drift, and captures only part of p
      expect(res.meanKl).toBeGreaterThan(0);
      expect(res.meanCapturedMass).toBeLessThan(1);
      expect(res.meanCapturedMass).toBeGreaterThan(0);
    } finally {
      rmSync(dump.dir, { recursive: true, force: true });
    }
  });

  test("scoring a dump against its own logits gives KL 0 and top-1 1.0", async () => {
    const { teacher, tokens } = makeTables();
    // The candidate IS the teacher, fp16-rounded — so the dumped top-k logits
    // and the candidate's full-vocab logsumexp agree exactly.
    const rounded = teacher.map((seq) => seq.map((row) => throughFloat16(row).decoded));
    const dump = writeDump(rounded, tokens);
    try {
      const res = await evaluateKlVsReferenceLogits({
        candidate: "unused-when-forward-is-injected",
        referenceDir: dump.dir,
        forward: fakeForward(rounded, tokens, 3),
      });
      expect(Math.abs(res.meanKl)).toBeLessThan(1e-6);
      expect(Math.abs(res.p95Kl)).toBeLessThan(1e-6);
      expect(res.top1Agreement).toBe(1);
      expect(res.meanCapturedMass).toBeGreaterThan(0);
    } finally {
      rmSync(dump.dir, { recursive: true, force: true });
    }
  });

  test("a mismatched vocabulary is refused, not silently scored", async () => {
    const { teacher, cand, tokens } = makeTables();
    const dump = writeDump(teacher, tokens);
    try {
      const narrow = cand.map((seq) => seq.map((row) => row.subarray(0, 4)));
      await expect(evaluateKlVsReferenceLogits({
        candidate: "unused",
        referenceDir: dump.dir,
        forward: (ids, onChunk) => {
          const s = tokens.findIndex((t) => t[0] === ids[0]);
          for (let pos = 0; pos < CTX; pos++) {
            const a = MlxArray.fromFloat32(Float32Array.from(narrow[s]![pos]!), [1, 1, 4]);
            try { onChunk(pos, a); } finally { a.dispose(); }
          }
        },
      })).rejects.toThrow(/out of range for candidate vocab/);
    } finally {
      rmSync(dump.dir, { recursive: true, force: true });
    }
  });

  test("an unsupported format_version is refused", () => {
    const { teacher, tokens } = makeTables();
    const dump = writeDump(teacher, tokens);
    try {
      writeFileSync(join(dump.dir, "manifest.json"), JSON.stringify({
        format_version: 2, model: "x", corpus_sha256: "0", ctx_len: CTX,
        n_seqs: N_SEQS, top_k: TOP_K, positions_per_seq: RECORDS,
      }));
      expect(() => ReferenceLogitsDump.open(dump.dir)).toThrow(/format_version 2 unsupported/);
    } finally {
      rmSync(dump.dir, { recursive: true, force: true });
    }
  });
});
