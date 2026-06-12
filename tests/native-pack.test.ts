// Native runtime pack: download + verify + atomic extract (the
// "one binary" option-3 flow). Uses a tiny fake pack served locally.

import { describe, expect, it, beforeAll, afterAll } from "bun:test";
import { existsSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { ensureNativeRuntime, nativePackDir, nativePackUrl, NATIVE_PACK_FILES } from "../src/native-pack";

const tmp = mkdtempSync(join(tmpdir(), "mlx-bun-native-"));
let tarBytes: Uint8Array;
let tarSha256: string;
let stub: ReturnType<typeof Bun.serve>;

beforeAll(async () => {
  // Build a tiny fake pack with the right file names.
  const stage = join(tmp, "stage");
  mkdirSync(stage, { recursive: true });
  for (const f of NATIVE_PACK_FILES) writeFileSync(join(stage, f), `fake ${f}\n`);
  const tarPath = join(tmp, "pack.tar.gz");
  const proc = Bun.spawn(["tar", "-czf", tarPath, "-C", stage, "."]);
  await proc.exited;
  tarBytes = new Uint8Array(await Bun.file(tarPath).arrayBuffer());
  tarSha256 = new Bun.CryptoHasher("sha256").update(tarBytes).digest("hex");
  stub = Bun.serve({ port: 0, fetch: () => new Response(tarBytes) });
});
afterAll(() => {
  stub.stop(true);
  rmSync(tmp, { recursive: true, force: true });
});

describe("ensureNativeRuntime", () => {
  it("downloads, verifies, and extracts the pack atomically", async () => {
    const dest = join(tmp, "cache", "native-vX-arm64");
    const dir = await ensureNativeRuntime({
      url: `http://localhost:${stub.port}/pack.tar.gz`,
      sha256: tarSha256, sizeBytes: tarBytes.length, destDir: dest,
    });
    expect(dir).toBe(dest);
    for (const f of NATIVE_PACK_FILES) {
      expect(existsSync(join(dest, f))).toBe(true);
      expect(readFileSync(join(dest, f), "utf8")).toBe(`fake ${f}\n`);
    }
    expect(existsSync(`${dest}.staging-${process.pid}`)).toBe(false);
  });

  it("is a no-op when the dest already has the runtime", async () => {
    const dest = join(tmp, "cache", "native-vX-arm64");
    const dir = await ensureNativeRuntime({
      url: "http://localhost:1/unreachable", sha256: "0".repeat(64),
      sizeBytes: 1, destDir: dest,
    });
    expect(dir).toBe(dest); // no fetch attempted — would have thrown
  });

  it("rejects a checksum mismatch and leaves no cache dir", async () => {
    const dest = join(tmp, "cache", "native-bad");
    await expect(ensureNativeRuntime({
      url: `http://localhost:${stub.port}/pack.tar.gz`,
      sha256: "f".repeat(64), sizeBytes: tarBytes.length, destDir: dest,
    })).rejects.toThrow(/checksum/);
    expect(existsSync(dest)).toBe(false);
  });
});

describe("constants", () => {
  it("pack url and cache dir are versioned and arch-specific", () => {
    expect(nativePackUrl("arm64")).toContain("native-v");
    expect(nativePackUrl("arm64")).toContain("arm64.tar.gz");
    expect(nativePackDir("arm64")).toContain("Library/Caches/mlx-bun/native-v");
  });
});
