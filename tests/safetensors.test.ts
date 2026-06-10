// Unit tests for the safetensors parser — synthetic fixtures, fast tier.

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { SafetensorsFile } from "../src/safetensors";

const dir = mkdtempSync(join(tmpdir(), "mlx-bun-st-"));
afterAll(() => rmSync(dir, { recursive: true, force: true }));

function makeSafetensors(
  header: Record<string, unknown>,
  data: Uint8Array,
  file = `fixture-${Math.random().toString(36).slice(2)}.safetensors`,
): string {
  const headerBytes = new TextEncoder().encode(JSON.stringify(header));
  const buf = new Uint8Array(8 + headerBytes.length + data.length);
  new DataView(buf.buffer).setBigUint64(0, BigInt(headerBytes.length), true);
  buf.set(headerBytes, 8);
  buf.set(data, 8 + headerBytes.length);
  const path = join(dir, file);
  writeFileSync(path, buf);
  return path;
}

describe("SafetensorsFile", () => {
  test("parses tensors and reads exact bytes", () => {
    const a = new Float32Array([1.5, -2.25, 3.125, 0]);
    const b = new Uint16Array([0x3f80, 0x4000]); // bf16-ish raw
    const data = new Uint8Array(a.byteLength + b.byteLength);
    data.set(new Uint8Array(a.buffer), 0);
    data.set(new Uint8Array(b.buffer), a.byteLength);

    const path = makeSafetensors(
      {
        __metadata__: { format: "pt" },
        alpha: { dtype: "F32", shape: [2, 2], data_offsets: [0, 16] },
        beta: { dtype: "BF16", shape: [2], data_offsets: [16, 20] },
      },
      data,
    );

    const sf = SafetensorsFile.open(path);
    expect(sf.metadata.format).toBe("pt");
    expect([...sf.tensors.keys()].sort()).toEqual(["alpha", "beta"]);

    const alpha = sf.tensors.get("alpha")!;
    expect(alpha.dtype).toBe("F32");
    expect(alpha.shape).toEqual([2, 2]);

    const bytes = sf.view("alpha");
    const readBack = new Float32Array(bytes.buffer, bytes.byteOffset, 4);
    expect([...readBack]).toEqual([1.5, -2.25, 3.125, 0]);

    expect(sf.view("beta").length).toBe(4);
    sf.mmap.unmap();
  });

  test("rejects size mismatch between shape and byte range", () => {
    const path = makeSafetensors(
      { bad: { dtype: "F32", shape: [4], data_offsets: [0, 12] } },
      new Uint8Array(12),
    );
    expect(() => SafetensorsFile.open(path)).toThrow(/byte range/);
  });

  test("rejects unsupported dtype", () => {
    const path = makeSafetensors(
      { weird: { dtype: "F8_E4M3", shape: [4], data_offsets: [0, 4] } },
      new Uint8Array(4),
    );
    expect(() => SafetensorsFile.open(path)).toThrow(/unsupported dtype/);
  });

  test("rejects tensor extending past end of file", () => {
    const path = makeSafetensors(
      { huge: { dtype: "F32", shape: [100], data_offsets: [0, 400] } },
      new Uint8Array(8), // file too short
    );
    expect(() => SafetensorsFile.open(path)).toThrow(/past end of file/);
  });

  test("rejects header length exceeding file size", () => {
    const buf = new Uint8Array(16);
    new DataView(buf.buffer).setBigUint64(0, 9999n, true);
    const path = join(dir, "bad-header.safetensors");
    writeFileSync(path, buf);
    expect(() => SafetensorsFile.open(path)).toThrow(/exceeds file size/);
  });

  test("unknown tensor name throws", () => {
    const path = makeSafetensors(
      { x: { dtype: "U8", shape: [1], data_offsets: [0, 1] } },
      new Uint8Array(1),
    );
    const sf = SafetensorsFile.open(path);
    expect(() => sf.view("y")).toThrow(/no tensor named/);
    sf.mmap.unmap();
  });
});
