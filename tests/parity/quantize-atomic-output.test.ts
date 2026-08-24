import { describe, expect, test } from "bun:test";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { writeAtomicDirectory } from "../../src/quantize/atomic-output";

describe("quantizer atomic output", () => {
  test("publishes a complete staged directory at the requested path", async () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-atomic-output-"));
    const outDir = join(root, "model");
    let stagingDir = "";
    try {
      const value = await writeAtomicDirectory(outDir, async (staging) => {
        stagingDir = staging;
        writeFileSync(join(staging, "model.safetensors"), "weights");
        writeFileSync(join(staging, "config.json"), "config");
        expect(existsSync(outDir)).toBe(false);
        return 7;
      });

      expect(value).toBe(7);
      expect(existsSync(stagingDir)).toBe(false);
      expect(readFileSync(join(outDir, "model.safetensors"), "utf8")).toBe("weights");
      expect(readFileSync(join(outDir, "config.json"), "utf8")).toBe("config");
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  test("writer failure removes staging and never exposes a partial destination", async () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-atomic-output-"));
    const outDir = join(root, "model");
    let stagingDir = "";
    try {
      await expect(writeAtomicDirectory(outDir, async (staging) => {
        stagingDir = staging;
        writeFileSync(join(staging, "model.safetensors"), "partial");
        throw new Error("interrupted");
      })).rejects.toThrow("interrupted");

      expect(existsSync(stagingDir)).toBe(false);
      expect(existsSync(outDir)).toBe(false);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  test("publishes into a caller-created empty destination directory", async () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-atomic-output-"));
    const outDir = join(root, "model");
    mkdirSync(outDir);
    try {
      await writeAtomicDirectory(outDir, async (staging) => {
        writeFileSync(join(staging, "config.json"), "new-config");
      });
      expect(readFileSync(join(outDir, "config.json"), "utf8")).toBe("new-config");
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  test("refuses to mix a new artifact into an existing directory", async () => {
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-atomic-output-"));
    const outDir = join(root, "model");
    try {
      await Bun.write(outDir + "/config.json", "old-config");
      await expect(writeAtomicDirectory(outDir, async () => {
        throw new Error("writer must not run");
      })).rejects.toThrow("output directory already exists");
      expect(readFileSync(join(outDir, "config.json"), "utf8")).toBe("old-config");
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
});
