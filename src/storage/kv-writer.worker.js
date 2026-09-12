// CPU-only persistence worker. It deliberately imports no model, MLX,
// scheduler or cache manager. The sender owns all buffers through completion.
import { parentPort } from "node:worker_threads";
import { toArrayBuffer } from "bun:ffi";
import { openSync, writeSync, closeSync, fsyncSync, renameSync, rmSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

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

parentPort.on("message", data => {
  try {
    writeSnapshot(data);
    parentPort.postMessage({ id: data.id });
  } catch (error) {
    parentPort.postMessage({ id: data.id, error: String(error) });
  }
});
