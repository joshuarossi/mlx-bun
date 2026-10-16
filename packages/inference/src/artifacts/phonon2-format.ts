// Phonon-2 container layout: Fermion Research, Apache-2.0.
// Adapted from FermionResearch/Phonon-2/fermion_container.py (revision
// 7e153e4054c0a10db6d47d6fff5c062d4c77c154). See THIRD_PARTY_NOTICES.md.
import { createHash } from "node:crypto";

export interface FermionRecord {
  n: string;
  k: "five_value" | "int6" | "fp16";
  shape: number[];
  b: number;
  data: Uint8Array;
}
export interface FiveValueData {
  base: Uint32Array;
  residual: Uint32Array;
  lo: Float32Array;
  delta: Float32Array;
}
export function halfFloat(bits: number): number {
  const sign = bits & 0x8000 ? -1 : 1,
    exp = (bits >>> 10) & 31,
    frac = bits & 1023;
  return (
    sign *
    (exp === 31
      ? frac
        ? NaN
        : Infinity
      : exp
        ? (1 + frac / 1024) * 2 ** (exp - 15)
        : frac * 2 ** -24)
  );
}
export function fermionRecords(bytes: Uint8Array): Map<string, FermionRecord> {
  if (bytes.length < 8) throw new Error("Phonon-2: truncated container");
  const n = Number(
    new DataView(bytes.buffer, bytes.byteOffset, 8).getBigUint64(0, true),
  );
  if (!Number.isSafeInteger(n) || n <= 0 || n > bytes.length - 8)
    throw new Error("Phonon-2: invalid header length");
  const header = JSON.parse(new TextDecoder().decode(bytes.subarray(8, 8 + n)));
  if (
    header.format !== "fermion-five-value-parakeet-v1" ||
    !Array.isArray(header.index)
  )
    throw new Error("Phonon-2: unsupported container");
  const records = new Map<string, FermionRecord>();
  let offset = 8 + n;
  for (const e of header.index) {
    if (
      typeof e.n !== "string" ||
      records.has(e.n) ||
      !["five_value", "int6", "fp16"].includes(e.k) ||
      !Array.isArray(e.shape) ||
      !e.shape.every((d: number) => Number.isSafeInteger(d) && d > 0) ||
      !Number.isSafeInteger(e.b) ||
      e.b <= 0 ||
      offset + e.b > bytes.length
    )
      throw new Error("Phonon-2: invalid tensor record");
    records.set(e.n, { ...e, data: bytes.subarray(offset, offset + e.b) });
    offset += e.b;
  }
  if (offset !== bytes.length)
    throw new Error("Phonon-2: trailing container bytes");
  return records;
}
// One byte holds five base-three signs. Decode with small tables rather than
// dividing every one of the 604 million weights twice during cold loading.
const SIGN_WORDS = new Uint16Array(243);
const NONZERO = new Uint8Array(243 * 6);
const HIGH_WORDS = new Uint16Array(243 * 32);
for (let byte = 0; byte < 243; byte++) {
  const codes: number[] = [];
  let value = byte,
    count = 0;
  for (let i = 0; i < 5; i++) {
    const code = value % 3;
    value = Math.floor(value / 3);
    codes.push(code);
    SIGN_WORDS[byte]! |= code << (2 * i);
    if (code !== 1) count++;
    NONZERO[byte * 6 + i + 1] = count;
  }
  for (let mask = 0; mask < 32; mask++) {
    let bit = 0,
      word = 0;
    for (let i = 0; i < 5; i++) {
      const code = codes[i]!;
      const high = code !== 1 && (mask >>> bit++) & 1;
      word |= (high ? code : 1) << (2 * i);
    }
    HIGH_WORDS[byte * 32 + mask] = word;
  }
}
export function unpackFiveValue(record: FermionRecord): FiveValueData {
  const [rows, cols] = record.shape;
  if (
    record.k !== "five_value" ||
    record.shape.length !== 2 ||
    !rows ||
    !cols ||
    cols % 16
  )
    throw new Error("Phonon-2: invalid five-value shape");
  const stride = Math.ceil(cols / 5),
    signsBytes = rows * stride,
    bytes = record.data;
  const base = new Uint32Array((rows * cols) / 16),
    residual = new Uint32Array(base.length);
  let nonzero = 0;
  const tail = cols - (stride - 1) * 5;
  for (let r = 0; r < rows; r++)
    for (let j = 0; j < stride; j++) {
      const byte = bytes[r * stride + j];
      if (byte === undefined || byte >= 243)
        throw new Error("Phonon-2: invalid ternary code");
      nonzero += NONZERO[byte * 6 + (j === stride - 1 ? tail : 5)]!;
    }
  const maskBytes = Math.ceil(nonzero / 8),
    scaleOffset = signsBytes + maskBytes;
  if (scaleOffset + 4 * rows !== bytes.length)
    throw new Error(`Phonon-2: invalid five-value payload ${record.n}`);
  const lo = new Float32Array(rows),
    delta = new Float32Array(rows);
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let bit = 0;
  for (let r = 0; r < rows; r++) {
    lo[r] = halfFloat(view.getUint16(scaleOffset + r * 2, true));
    delta[r] =
      halfFloat(view.getUint16(scaleOffset + rows * 2 + r * 2, true)) - lo[r]!;
    if (!Number.isFinite(lo[r]) || !Number.isFinite(delta[r]))
      throw new Error("Phonon-2: non-finite palette");
    const rowWord = (r * cols) / 16;
    for (let j = 0; j < stride; j++) {
      const byte = bytes[r * stride + j]!,
        length = j === stride - 1 ? tail : 5;
      const bits =
        ((bytes[signsBytes + (bit >>> 3)]! |
          ((bytes[signsBytes + (bit >>> 3) + 1] ?? 0) << 8)) >>>
          (bit & 7)) &
        31;
      const mask = (1 << (2 * length)) - 1;
      const a = SIGN_WORDS[byte]! & mask,
        b = HIGH_WORDS[byte * 32 + bits]! & mask;
      const shift = (j * 10) & 31,
        at = rowWord + ((j * 10) >>> 5);
      base[at]! |= a << shift;
      residual[at]! |= b << shift;
      if (shift + 2 * length > 32) {
        base[at + 1]! |= a >>> (32 - shift);
        residual[at + 1]! |= b >>> (32 - shift);
      }
      bit += NONZERO[byte * 6 + length]!;
    }
  }
  return { base, residual, lo, delta };
}
export function unpackDense(record: FermionRecord): Float32Array {
  const count = record.shape.reduce((a, b) => a * b, 1),
    out = new Float32Array(count),
    bytes = record.data;
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (record.k === "fp16") {
    if (bytes.length !== count * 2)
      throw new Error("Phonon-2: invalid fp16 tensor");
    for (let i = 0; i < count; i++)
      out[i] = halfFloat(view.getUint16(i * 2, true));
  } else if (record.k === "int6") {
    const rows = record.shape[0]!,
      cols = count / rows,
      packedBytes = Math.ceil(count / 4) * 3;
    if (bytes.length !== packedBytes + rows * 2)
      throw new Error("Phonon-2: invalid int6 tensor");
    const scales = Float32Array.from({ length: rows }, (_, r) =>
      halfFloat(view.getUint16(packedBytes + r * 2, true)),
    );
    for (let i = 0; i < count; i++) {
      const offset = Math.floor(i / 4) * 3,
        word =
          bytes[offset]! |
          (bytes[offset + 1]! << 8) |
          (bytes[offset + 2]! << 16);
      out[i] =
        (((word >>> ((i % 4) * 6)) & 63) - 32) * scales[Math.floor(i / cols)]!;
    }
  } else throw new Error("Phonon-2: expected dense tensor");
  return out;
}
/** The published archive stores plain files, with SHA256 and size in its first member.
 * Reads only those members; never extracts paths onto the filesystem. */
export function readPhononArchive(tar: Uint8Array): Map<string, Uint8Array> {
  const files = new Map<string, Uint8Array>(),
    decoder = new TextDecoder();
  let offset = 0;
  while (offset + 512 <= tar.length && tar[offset] !== 0) {
    const header = tar.subarray(offset, offset + 512),
      name = decoder.decode(header.subarray(0, 100)).replace(/\0.*$/s, "");
    const size = parseInt(
      decoder.decode(header.subarray(124, 136)).replace(/\0.*$/s, "").trim(),
      8,
    );
    if (
      !Number.isSafeInteger(size) ||
      size < 0 ||
      offset + 512 + size > tar.length ||
      files.has(name) ||
      name.includes("/") ||
      name.includes("\\")
    )
      throw new Error("Phonon-2: invalid archive member");
    files.set(name, tar.subarray(offset + 512, offset + 512 + size));
    offset += 512 + Math.ceil(size / 512) * 512;
  }
  const manifestBytes = files.get("bps_manifest.json");
  if (!manifestBytes) throw new Error("Phonon-2: missing archive manifest");
  const manifest = JSON.parse(decoder.decode(manifestBytes));
  if (manifest.release_format !== "phonon-byteplane-tar-zstd-v1")
    throw new Error("Phonon-2: unsupported archive format");
  for (const row of manifest.files) {
    const data = files.get(row.path);
    if (
      row.transform ||
      !data ||
      data.length !== row.original_bytes ||
      createHash("sha256").update(data).digest("hex") !== row.original_sha256
    )
      throw new Error(
        `Phonon-2: archive checksum or encoding mismatch: ${row.path}`,
      );
  }
  return files;
}
