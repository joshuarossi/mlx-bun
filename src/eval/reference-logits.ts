// Reader for a saved bf16 TEACHER-LOGITS dump (format_version 1).
//
// Why the format exists: a bf16 teacher can never be resident on a 32 GB box
// alongside the candidate, so the teacher's distributions are computed ONCE
// (Python side, one model at a time) and written to disk as a top-k slice
// plus the full-vocab logsumexp. Any candidate loaded through OUR engine can
// then be scored against it (src/eval/kl.ts `evaluateKlVsReferenceLogits`)
// without the teacher ever being co-resident.
//
// On-disk contract (fixed — this module reads it, it does not negotiate it):
//
//   <dir>/manifest.json  { format_version: 1, model, corpus_sha256, ctx_len,
//                          n_seqs, top_k, positions_per_seq, created, notes }
//   <dir>/tokens.bin     int32 LE [n_seqs][ctx_len] — teacher-forced ids
//   <dir>/seq-<i>.bin    one record per r = 0..ctx_len-2; record r is the
//                        distribution over the token at index r+1, i.e. the
//                        distribution predicted from tokens[0..r] — so record
//                        r lines up with candidate logits at POSITION r:
//                          int32[top_k]   indices, descending by logit
//                          float16[top_k] reference logits at those indices
//                          float32        logsumexp over the FULL vocab
//
// Records are fixed-width (6·top_k + 4 bytes), so a range is one pread — the
// scorer streams a chunk of records at a time and never holds a whole
// sequence file (top_k 2048 × ctx 4096 ≈ 50 MB) in the JS heap.

import { closeSync, existsSync, openSync, readFileSync, readSync, statSync } from "node:fs";

export interface ReferenceLogitsManifest {
  format_version: number;
  model: string;
  corpus_sha256: string;
  ctx_len: number;
  n_seqs: number;
  top_k: number;
  positions_per_seq: number;
  created?: string;
  notes?: string;
}

/** A contiguous run of records, flattened: row i of `indices`/`logits` is
 *  `[i*topK, (i+1)*topK)`. Logits are decoded from float16 to float32. */
export interface ReferenceRecords {
  /** Absolute record index of row 0. */
  start: number;
  count: number;
  topK: number;
  indices: Int32Array;    // [count · topK]
  logits: Float32Array;   // [count · topK]
  logsumexp: Float32Array; // [count] — over the FULL teacher vocab
}

const SUPPORTED_FORMAT_VERSION = 1;

/** float16 bits → float32 (host-side; same expansion as MlxArray.toFloat32Host,
 *  kept local so reading a dump never touches the GPU). */
function decodeFloat16(bits: number): number {
  const sign = bits & 0x8000;
  const exponent = (bits >>> 10) & 0x1f;
  const fraction = bits & 0x03ff;
  let value: number;
  if (exponent === 0) value = fraction === 0 ? 0 : fraction * 2 ** -24;
  else if (exponent === 0x1f) value = fraction === 0 ? Infinity : NaN;
  else value = (1 + fraction / 1024) * 2 ** (exponent - 15);
  return sign ? -value : value;
}

export class ReferenceLogitsDump {
  readonly dir: string;
  readonly manifest: ReferenceLogitsManifest;
  readonly topK: number;
  readonly ctxLen: number;
  readonly nSeqs: number;
  /** Records per sequence file — derived from the file, cross-checked
   *  against the manifest. */
  readonly positionsPerSeq: number;
  readonly recordBytes: number;

  #tokens: Int32Array;
  #fd: number | null = null;
  #fdSeq = -1;

  private constructor(dir: string, manifest: ReferenceLogitsManifest, tokens: Int32Array, positionsPerSeq: number) {
    this.dir = dir;
    this.manifest = manifest;
    this.topK = manifest.top_k;
    this.ctxLen = manifest.ctx_len;
    this.nSeqs = manifest.n_seqs;
    this.positionsPerSeq = positionsPerSeq;
    this.recordBytes = manifest.top_k * 6 + 4;
    this.#tokens = tokens;
  }

  static open(dir: string): ReferenceLogitsDump {
    const manifestPath = `${dir}/manifest.json`;
    if (!existsSync(manifestPath))
      throw new Error(`reference-logits: no manifest.json in ${dir}`);
    const manifest = JSON.parse(readFileSync(manifestPath, "utf8")) as ReferenceLogitsManifest;
    if (manifest.format_version !== SUPPORTED_FORMAT_VERSION)
      throw new Error(
        `reference-logits: format_version ${manifest.format_version} unsupported ` +
        `(this reader implements ${SUPPORTED_FORMAT_VERSION})`,
      );
    for (const k of ["ctx_len", "n_seqs", "top_k"] as const)
      if (!Number.isInteger(manifest[k]) || manifest[k] <= 0)
        throw new Error(`reference-logits: manifest.${k} must be a positive integer (got ${manifest[k]})`);

    const tokensBytes = readFileSync(`${dir}/tokens.bin`);
    const wantTokenBytes = manifest.n_seqs * manifest.ctx_len * 4;
    if (tokensBytes.byteLength !== wantTokenBytes)
      throw new Error(
        `reference-logits: tokens.bin is ${tokensBytes.byteLength} B, expected ` +
        `${wantTokenBytes} B (n_seqs ${manifest.n_seqs} × ctx_len ${manifest.ctx_len} × int32)`,
      );
    // Copy: the Buffer's byteOffset need not be int32-aligned for a view.
    const tokens = new Int32Array(
      tokensBytes.buffer.slice(tokensBytes.byteOffset, tokensBytes.byteOffset + tokensBytes.byteLength),
    );

    const recordBytes = manifest.top_k * 6 + 4;
    const seq0 = `${dir}/seq-0.bin`;
    if (!existsSync(seq0)) throw new Error(`reference-logits: missing ${seq0}`);
    const size = statSync(seq0).size;
    if (size % recordBytes !== 0)
      throw new Error(
        `reference-logits: seq-0.bin is ${size} B, not a multiple of the ` +
        `${recordBytes} B record (top_k ${manifest.top_k})`,
      );
    const positions = size / recordBytes;
    if (positions > manifest.ctx_len - 1)
      throw new Error(
        `reference-logits: seq-0.bin holds ${positions} records but ctx_len ` +
        `${manifest.ctx_len} allows at most ${manifest.ctx_len - 1}`,
      );
    if (Number.isInteger(manifest.positions_per_seq) && manifest.positions_per_seq !== positions)
      console.warn(
        `[reference-logits] manifest.positions_per_seq=${manifest.positions_per_seq} but ` +
        `seq-0.bin holds ${positions} records — using the file`,
      );
    return new ReferenceLogitsDump(dir, manifest, tokens, positions);
  }

  /** Teacher-forced token ids of sequence `seq` (length ctx_len). */
  tokens(seq: number): number[] {
    this.#assertSeq(seq);
    const off = seq * this.ctxLen;
    return Array.from(this.#tokens.subarray(off, off + this.ctxLen));
  }

  /** Records [lo, hi) of sequence `seq` — one pread, decoded to float32. */
  readRecords(seq: number, lo: number, hi: number): ReferenceRecords {
    this.#assertSeq(seq);
    if (lo < 0 || hi > this.positionsPerSeq || hi <= lo)
      throw new Error(
        `reference-logits: record range [${lo},${hi}) out of bounds for ` +
        `${this.positionsPerSeq} records`,
      );
    const count = hi - lo;
    const K = this.topK;
    const buf = Buffer.allocUnsafe(count * this.recordBytes);
    const fd = this.#open(seq);
    const read = readSync(fd, buf, 0, buf.byteLength, lo * this.recordBytes);
    if (read !== buf.byteLength)
      throw new Error(`reference-logits: short read on seq-${seq}.bin (${read}/${buf.byteLength} B)`);

    const dv = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
    const indices = new Int32Array(count * K);
    const logits = new Float32Array(count * K);
    const logsumexp = new Float32Array(count);
    for (let r = 0; r < count; r++) {
      const base = r * this.recordBytes;
      const row = r * K;
      for (let j = 0; j < K; j++) indices[row + j] = dv.getInt32(base + j * 4, true);
      const lbase = base + K * 4;
      for (let j = 0; j < K; j++) logits[row + j] = decodeFloat16(dv.getUint16(lbase + j * 2, true));
      logsumexp[r] = dv.getFloat32(lbase + K * 2, true);
    }
    return { start: lo, count, topK: K, indices, logits, logsumexp };
  }

  close(): void {
    if (this.#fd !== null) closeSync(this.#fd);
    this.#fd = null;
    this.#fdSeq = -1;
  }

  #open(seq: number): number {
    if (this.#fdSeq === seq && this.#fd !== null) return this.#fd;
    if (this.#fd !== null) closeSync(this.#fd);
    const path = `${this.dir}/seq-${seq}.bin`;
    if (!existsSync(path)) throw new Error(`reference-logits: missing ${path}`);
    const size = statSync(path).size;
    if (size < this.positionsPerSeq * this.recordBytes)
      throw new Error(
        `reference-logits: seq-${seq}.bin is ${size} B, short of the ` +
        `${this.positionsPerSeq * this.recordBytes} B seq-0.bin defines`,
      );
    this.#fd = openSync(path, "r");
    this.#fdSeq = seq;
    return this.#fd;
  }

  #assertSeq(seq: number): void {
    if (!Number.isInteger(seq) || seq < 0 || seq >= this.nSeqs)
      throw new Error(`reference-logits: sequence ${seq} out of range (n_seqs ${this.nSeqs})`);
  }
}
