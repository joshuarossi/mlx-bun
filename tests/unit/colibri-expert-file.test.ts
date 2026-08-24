import { afterEach, describe, expect, it } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, truncateSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  COLIBRI_EXPERT_ALIGNMENT, buildSyntheticExpertFile, validateSyntheticExpertFiles,
  validateSyntheticExpertManifest, writeSyntheticExpertFile,
} from "../../scripts/gen-colibri-expert-file";

const dirs: string[] = [];
afterEach(() => { for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true }); });
const config = { layers: 2, expertsPerLayer: 3, hiddenSize: 64, intermediateSize: 32, bits: 4 as const, groupSize: 16 };

describe("synthetic Colibri expert file", () => {
  it("is deterministic, aligned, contiguous, and checksummed", () => {
    const a = buildSyntheticExpertFile(config);
    const b = buildSyntheticExpertFile(config);
    expect(a.bytes).toEqual(b.bytes);
    expect(a.manifest).toEqual(b.manifest);
    expect(a.manifest.fileSize % COLIBRI_EXPERT_ALIGNMENT).toBe(0);
    for (const expert of a.manifest.experts) {
      expect(expert.weights.offset % COLIBRI_EXPERT_ALIGNMENT).toBe(0);
      expect(expert.weights.up.offset).toBe(expert.weights.gate.offset + expert.weights.gate.length);
      expect(expert.weights.down.offset).toBe(expert.weights.up.offset + expert.weights.up.length);
      expect(expert.scales.offset % COLIBRI_EXPERT_ALIGNMENT).toBe(0);
      expect(expert.scales.up.offset).toBe(expert.scales.gate.offset + expert.scales.gate.length);
      expect(expert.scales.down.offset).toBe(expert.scales.up.offset + expert.scales.up.length);
    }
    expect(() => validateSyntheticExpertManifest(a.manifest, a.bytes)).not.toThrow();
  });

  it("round-trips files and rejects truncation", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-colibri-experts-")); dirs.push(dir);
    const manifest = writeSyntheticExpertFile(dir, config);
    expect(validateSyntheticExpertFiles(dir)).toEqual(manifest);
    truncateSync(join(dir, manifest.file), manifest.fileSize - 1);
    expect(() => validateSyntheticExpertFiles(dir)).toThrow(/size/);
  });

  it("rejects invalid dimensions and corrupted bytes", () => {
    expect(() => buildSyntheticExpertFile({ ...config, hiddenSize: 63 })).toThrow(/divisible/);
    expect(() => buildSyntheticExpertFile({ ...config, alignment: 3 })).toThrow(/alignment/);
    const { bytes, manifest } = buildSyntheticExpertFile(config);
    const offset = manifest.experts[0]!.weights.offset;
    bytes[offset] = bytes[offset]! ^ 0xff;
    expect(() => validateSyntheticExpertManifest(manifest, bytes)).toThrow(/checksum/);
  });

  it("rejects projection metadata and identity corruption", () => {
    const { bytes, manifest } = buildSyntheticExpertFile(config);
    const badShape = structuredClone(manifest);
    badShape.experts[0]!.weights.gate.shape = [999, 999];
    expect(() => validateSyntheticExpertManifest(badShape, bytes)).toThrow(/shape/);
    const badDigest = structuredClone(manifest);
    badDigest.experts[0]!.weights.gate.sha256 = "0".repeat(64);
    expect(() => validateSyntheticExpertManifest(badDigest, bytes)).toThrow(/checksum/);
    const badIdentity = structuredClone(manifest);
    badIdentity.experts[0]!.expert = 99;
    expect(() => validateSyntheticExpertManifest(badIdentity, bytes)).toThrow(/identity/);
  });
});
