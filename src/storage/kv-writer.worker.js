// CPU-only persistence worker. It deliberately imports no model, MLX,
// scheduler or cache manager. The sender owns all buffers through completion.
import { parentPort } from "node:worker_threads";
import { toArrayBuffer, ptr } from "bun:ffi";
import { openSync, writeSync, closeSync, fsyncSync, renameSync, rmSync, mkdirSync, existsSync, readSync, readFileSync, readdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { dirname, join } from "node:path";

const MAGIC = "MLXBUNKV2\n";
const PREFIX_LEN = MAGIC.length + 16;
const alignUp = n => Math.ceil(n / 16384) * 16384;
const hash64 = bytes => Bun.hash(bytes).toString(16).padStart(16, "0");
let scratch = new Uint8Array(0);

function bytesOf(tensor) {
  const { pointer, shape, strides, itemSize } = tensor;
  const size = shape.reduce((a, b) => a * b, 1);
  if (!size) return new Uint8Array(0);
  // Coalesce the contiguous suffix. Most KV layouts need only a copy per
  // head to omit capacity padding, never a GPU contiguous() operation.
  let run = 1, axis = shape.length - 1;
  while (axis >= 0 && (shape[axis] === 1 || strides[axis] === run)) {
    run *= shape[axis--];
  }
  if (axis < 0) return new Uint8Array(toArrayBuffer(pointer, 0, size * itemSize));
  let lo = 0, hi = 0;
  for (let i = 0; i < shape.length; i++) {
    const end = (shape[i] - 1) * strides[i];
    lo += Math.min(0, end); hi += Math.max(0, end);
  }
  const source = new Uint8Array(toArrayBuffer(pointer + lo * itemSize, 0, (hi - lo + 1) * itemSize));
  if (scratch.length < size * itemSize) scratch = new Uint8Array(size * itemSize);
  const bytes = scratch.subarray(0, size * itemSize);
  const runBytes = run * itemSize;
  for (let row = 0; row < size / run; row++) {
    let index = row, offset = -lo;
    for (let i = axis; i >= 0; i--) {
      offset += (index % shape[i]) * strides[i];
      index = Math.floor(index / shape[i]);
    }
    bytes.set(source.subarray(offset * itemSize, offset * itemSize + runBytes), row * runBytes);
  }
  return bytes;
}

function writeAll(fd, bytes, position) {
  let offset = 0;
  while (offset < bytes.length) {
    const n = writeSync(fd, bytes, offset, bytes.length - offset, position + offset);
    if (!n) throw new Error("KV write made no progress");
    offset += n;
  }
}

function writeSnapshot({ path, header, tensors }) {
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  const headerLen = new TextEncoder().encode(JSON.stringify(header)).length;
  const dataStart = alignUp(PREFIX_LEN + headerLen);
  mkdirSync(dirname(path), { recursive: true });
  const tmp = `${path}.tmp`;
  const fd = openSync(tmp, "w");
  try {
    for (let i = 0; i < slots.length; i++) {
      const bytes = bytesOf(tensors[i]);
      if (bytes.length !== slots[i].bytes) throw new Error("KV tensor byte-length drift");
      slots[i].hash = hash64(bytes);
      writeAll(fd, bytes, dataStart + slots[i].off);
    }
    const json = new TextEncoder().encode(JSON.stringify(header));
    if (json.length !== headerLen) throw new Error("KV header byte-length drift");
    const prefix = new Uint8Array(dataStart);
    prefix.set(new TextEncoder().encode(MAGIC));
    const view = new DataView(prefix.buffer);
    view.setUint32(MAGIC.length, headerLen, true);
    view.setUint32(MAGIC.length + 4, dataStart, true);
    view.setBigUint64(MAGIC.length + 8, BigInt(Bun.hash(json)), true);
    prefix.set(json, PREFIX_LEN);
    writeAll(fd, prefix, 0);
    fsyncSync(fd);
  } catch (error) {
    closeSync(fd);
    rmSync(tmp, { force: true });
    throw error;
  }
  closeSync(fd);
  try { renameSync(tmp, path); }
  catch (error) { rmSync(tmp, { force: true }); throw error; }
}

// The block boundary resets for each leading row (e.g. attention head).
// Growing a token axis therefore leaves preceding blocks byte-identical.
function* segments(tensor, blockBytes, metrics) {
  const { pointer, shape, strides, itemSize } = tensor;
  const size = shape.reduce((a, b) => a * b, 1);
  const rowSize = shape.slice(-2).reduce((a, b) => a * b, 1);
  if (!size) return;
  let run = 1, axis = shape.length - 1;
  while (axis >= 0 && (shape[axis] === 1 || strides[axis] === run)) run *= shape[axis--];
  const limit = Math.max(1, Math.floor(blockBytes / itemSize));
  let packing = null;
  for (let start = 0; start < size;) {
    const count = Math.min(limit, rowSize - start % rowSize, size - start);
    let index = start, offset = 0;
    for (let i = shape.length - 1; i >= 0; i--) {
      offset += index % shape[i] * strides[i]; index = Math.floor(index / shape[i]);
    }
    if (count <= run - start % run) {
      yield new Uint8Array(toArrayBuffer(pointer + offset * itemSize, 0, count * itemSize));
    } else {
      if (!packing) packing = new Uint8Array(limit * itemSize);
      metrics.scratchPeak = Math.max(metrics.scratchPeak, packing.byteLength);
      const bytes = packing.subarray(0, count * itemSize);
      for (let copied = 0; copied < count;) {
        index = start + copied; offset = 0;
        for (let i = shape.length - 1; i >= 0; i--) {
          offset += index % shape[i] * strides[i]; index = Math.floor(index / shape[i]);
        }
        const n = Math.min(count - copied, run - (start + copied) % run);
        bytes.set(new Uint8Array(toArrayBuffer(pointer + offset * itemSize, 0, n * itemSize)), copied * itemSize);
        copied += n;
      }
      metrics.copiedBytes += bytes.length;
      yield bytes;
    }
    start += count;
  }
}

function writeHeader(path, header) {
  const json = new TextEncoder().encode(JSON.stringify(header));
  const prefix = new Uint8Array(PREFIX_LEN + json.length);
  prefix.set(new TextEncoder().encode(MAGIC));
  const view = new DataView(prefix.buffer);
  view.setUint32(MAGIC.length, json.length, true);
  view.setUint32(MAGIC.length + 4, prefix.length, true);
  view.setBigUint64(MAGIC.length + 8, BigInt(Bun.hash(json)), true);
  prefix.set(json, PREFIX_LEN);
  const tmp = path + ".tmp", fd = openSync(tmp, "w");
  try { writeAll(fd, prefix, 0); fsyncSync(fd); }
  finally { closeSync(fd); }
  renameSync(tmp, path);
  return prefix.length;
}

function writeBlocks({ path, header, tensors, blockBytes = 1024 * 1024, segmented = true }) {
  const metrics = { writtenBytes: 0, reusedBytes: 0, copiedBytes: 0, scratchPeak: 0 };
  const root = join(dirname(path), "blocks");
  mkdirSync(root, { recursive: true });
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  for (let i = 0; i < slots.length; i++) {
    const slot = slots[i]; slot.blocks = [];
    let bytes = 0;
    let source = tensors[i];
    let packed;
    if (!segmented) {
      packed = bytesOf(source);
      metrics.copiedBytes += packed.buffer === scratch.buffer ? packed.length : 0;
      metrics.scratchPeak = Math.max(metrics.scratchPeak, scratch.length);
      // Contiguous strides, but retain row boundaries for identical blocks.
      let stride = 1;
      const strides = Array(source.shape.length);
      for (let j = strides.length - 1; j >= 0; j--) { strides[j] = stride; stride *= source.shape[j]; }
      // No second copy; the pointer remains live until this tensor finishes.
      source = { ...source, pointer: packed.length ? Number(ptr(packed)) : 0, strides };
    }
    for (const chunk of segments(source, blockBytes, metrics)) {
      const hash = createHash("sha256").update(chunk).digest("hex");
      bytes += chunk.length;
      slot.blocks.push({ hash, bytes: chunk.length });
      const destination = join(root, hash);
      if (existsSync(destination)) { metrics.reusedBytes += chunk.length; continue; }
      const tmp = destination + ".tmp", fd = openSync(tmp, "w");
      try { writeAll(fd, chunk, 0); fsyncSync(fd); }
      finally { closeSync(fd); }
      renameSync(tmp, destination);
      metrics.writtenBytes += chunk.length;
    }
    if (bytes !== slot.bytes) throw new Error("KV tensor byte-length drift");
    // The header authenticates block order; each block authenticates bytes.
    // Avoid hashing the same tensor a second time.
    slot.hash = "";
  }
  header.formatVersion = 5;
  metrics.writtenBytes += writeHeader(path, header);
  return metrics;
}

function readAll(fd, bytes, position) {
  let offset = 0;
  while (offset < bytes.length) {
    const n = readSync(fd, bytes, offset, bytes.length - offset, position + offset);
    if (!n) throw new Error("truncated KV tensor");
    offset += n;
  }
}

// Destinations are unpublished, independently owned host allocations. No
// MLX API is called here, and the owner retains them until acknowledgement.
function readSnapshot({ path, header, pointers, verify }) {
  const slots = [...header.caches, ...(header.attachments ?? [])].flatMap(entry => entry.tensors);
  const fd = header.formatVersion === 5 ? null : openSync(path, "r");
  try {
    for (let i = 0; i < slots.length; i++) {
      const slot = slots[i];
      const bytes = slot.bytes ? new Uint8Array(toArrayBuffer(pointers[i], 0, slot.bytes)) : new Uint8Array(0);
      if (header.formatVersion === 5) {
        let offset = 0;
        for (const block of slot.blocks ?? []) {
          if (!/^[a-f0-9]{64}$/.test(block.hash) || block.bytes <= 0 || offset + block.bytes > bytes.length)
            throw new Error("invalid KV block reference");
          const blockFd = openSync(join(dirname(path), "blocks", block.hash), "r");
          const target = bytes.subarray(offset, offset + block.bytes);
          try { readAll(blockFd, target, 0); } finally { closeSync(blockFd); }
          if (verify && createHash("sha256").update(target).digest("hex") !== block.hash)
            throw new Error("KV block hash mismatch");
          offset += block.bytes;
        }
        if (offset !== bytes.length) throw new Error("incomplete KV tensor blocks");
      } else {
        readAll(fd, bytes, header.dataStart + slot.off);
        if (verify && hash64(bytes) !== slot.hash) throw new Error("KV tensor hash mismatch");
      }
    }
  } finally { if (fd !== null) closeSync(fd); }
}

// Serialized with writes: an in-flight manifest cannot lose its blocks.
// Only unreferenced content is collected; shared prefixes remain on SSD.
function collectBlocks({ root }) {
  if (!existsSync(root)) return;
  for (const ns of readdirSync(root, { withFileTypes: true })) {
    if (!ns.isDirectory()) continue;
    const dir = join(root, ns.name), blocks = join(dir, "blocks");
    if (!existsSync(blocks)) continue;
    const live = new Set();
    for (const file of readdirSync(dir)) {
      if (!file.endsWith(".mlxkv")) continue;
      const fd = openSync(join(dir, file), "r");
      try {
        const prefix = new Uint8Array(PREFIX_LEN); readAll(fd, prefix, 0);
        const view = new DataView(prefix.buffer), json = new Uint8Array(view.getUint32(MAGIC.length, true));
        readAll(fd, json, PREFIX_LEN);
        if (BigInt(Bun.hash(json)) !== view.getBigUint64(MAGIC.length + 8, true)) continue;
        const header = JSON.parse(new TextDecoder().decode(json));
        for (const entry of [...header.caches, ...(header.attachments ?? [])])
          for (const slot of entry.tensors) for (const block of slot.blocks ?? []) live.add(block.hash);
      } finally { closeSync(fd); }
    }
    for (const file of readdirSync(blocks))
      if (!live.has(file)) rmSync(join(blocks, file), { force: true });
  }
}

parentPort.on("message", data => {
  try {
    const started = performance.now();
    const metrics = data.operation === "read" ? readSnapshot(data)
      : data.operation === "collect" ? collectBlocks(data)
      : data.layout === "blocks" ? writeBlocks(data) : writeSnapshot(data);
    parentPort.postMessage({ id: data.id, metrics: { ...metrics, elapsedMs: performance.now() - started } });
  } catch (error) {
    parentPort.postMessage({ id: data.id, error: String(error) });
  }
});
