import { mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export const COLIBRI_EXPERT_ALIGNMENT = 16 * 1024;
export const COLIBRI_EXPERT_FORMAT = "mlx-bun-colibri-expert-v1";

export interface SyntheticExpertConfig {
  layers: number;
  expertsPerLayer: number;
  hiddenSize: number;
  intermediateSize: number;
  bits: 4 | 8;
  groupSize: number;
  alignment?: number;
}

export interface Region {
  offset: number;
  length: number;
  sha256: string;
}

export interface ProjectionRegion extends Region {
  shape: [number, number];
}

export interface SyntheticExpertEntry {
  layer: number;
  expert: number;
  weights: Region & {
    gate: ProjectionRegion;
    up: ProjectionRegion;
    down: ProjectionRegion;
  };
  scales: Region & {
    gate: ProjectionRegion;
    up: ProjectionRegion;
    down: ProjectionRegion;
  };
}

export interface SyntheticExpertManifest {
  format: typeof COLIBRI_EXPERT_FORMAT;
  version: 1;
  alignment: number;
  file: "experts.bin";
  fileSize: number;
  fileSha256: string;
  config: Required<SyntheticExpertConfig>;
  experts: SyntheticExpertEntry[];
}

function integer(name: string, value: number): void {
  if (!Number.isSafeInteger(value) || value <= 0) throw new Error(`${name} must be a positive safe integer`);
}

function align(value: number, alignment: number): number {
  const result = Math.ceil(value / alignment) * alignment;
  if (!Number.isSafeInteger(result)) throw new Error("expert layout exceeds safe integer range");
  return result;
}

function add(a: number, b: number): number {
  const result = a + b;
  if (!Number.isSafeInteger(result)) throw new Error("expert layout exceeds safe integer range");
  return result;
}

function digest(bytes: Uint8Array): string {
  return new Bun.CryptoHasher("sha256").update(bytes).digest("hex");
}

function pattern(length: number, seed: number): Uint8Array {
  const bytes = new Uint8Array(length);
  let x = seed >>> 0;
  for (let i = 0; i < length; i++) {
    x = (Math.imul(x, 1664525) + 1013904223) >>> 0;
    bytes[i] = x >>> 24;
  }
  return bytes;
}

function projection(offset: number, bytes: Uint8Array, shape: [number, number]): ProjectionRegion {
  return { offset, length: bytes.length, shape, sha256: digest(bytes) };
}

export function normalizeSyntheticExpertConfig(config: SyntheticExpertConfig): Required<SyntheticExpertConfig> {
  const out = { ...config, alignment: config.alignment ?? COLIBRI_EXPERT_ALIGNMENT };
  for (const key of ["layers", "expertsPerLayer", "hiddenSize", "intermediateSize", "groupSize", "alignment"] as const)
    integer(key, out[key]);
  if (out.bits !== 4 && out.bits !== 8) throw new Error("bits must be 4 or 8");
  if (out.hiddenSize % out.groupSize !== 0 || out.intermediateSize % out.groupSize !== 0)
    throw new Error("hiddenSize and intermediateSize must be divisible by groupSize");
  if (out.alignment !== COLIBRI_EXPERT_ALIGNMENT) throw new Error(`alignment must be ${COLIBRI_EXPERT_ALIGNMENT}`);
  if (!Number.isSafeInteger(out.layers * out.expertsPerLayer)) throw new Error("expert count exceeds safe integer range");
  return out;
}

export function buildSyntheticExpertFile(config: SyntheticExpertConfig): {
  bytes: Uint8Array;
  manifest: SyntheticExpertManifest;
} {
  const c = normalizeSyntheticExpertConfig(config);
  const weightElements = c.hiddenSize * c.intermediateSize;
  if (!Number.isSafeInteger(weightElements)) throw new Error("projection size exceeds safe integer range");
  const weightBytes = weightElements * c.bits / 8;
  const gateScaleCount = weightElements / c.groupSize;
  const downScaleCount = weightElements / c.groupSize;
  const scaleBytes = gateScaleCount * 2; // f16 scales
  for (const [name, value] of [["weightBytes", weightBytes], ["scaleBytes", scaleBytes]] as const)
    integer(name, value);

  const chunks: Array<{ offset: number; bytes: Uint8Array }> = [];
  const experts: SyntheticExpertEntry[] = [];
  let cursor = 0;
  for (let layer = 0; layer < c.layers; layer++) {
    for (let expert = 0; expert < c.expertsPerLayer; expert++) {
      const seed = 1 + layer * c.expertsPerLayer + expert;
      cursor = align(cursor, c.alignment);
      const weightOffset = cursor;
      const gateW = pattern(weightBytes, seed * 11 + 1);
      const upW = pattern(weightBytes, seed * 11 + 2);
      const downW = pattern(weightBytes, seed * 11 + 3);
      const gate = projection(cursor, gateW, [c.intermediateSize, c.hiddenSize]); cursor = add(cursor, gateW.length);
      const up = projection(cursor, upW, [c.intermediateSize, c.hiddenSize]); cursor = add(cursor, upW.length);
      const down = projection(cursor, downW, [c.hiddenSize, c.intermediateSize]); cursor = add(cursor, downW.length);
      chunks.push({ offset: gate.offset, bytes: gateW }, { offset: up.offset, bytes: upW }, { offset: down.offset, bytes: downW });
      const weightLength = cursor - weightOffset;

      cursor = align(cursor, c.alignment);
      const scaleOffset = cursor;
      const gateS = pattern(scaleBytes, seed * 17 + 1);
      const upS = pattern(scaleBytes, seed * 17 + 2);
      const downS = pattern(scaleBytes, seed * 17 + 3);
      const gateScale = projection(cursor, gateS, [c.intermediateSize, c.hiddenSize / c.groupSize]); cursor = add(cursor, gateS.length);
      const upScale = projection(cursor, upS, [c.intermediateSize, c.hiddenSize / c.groupSize]); cursor = add(cursor, upS.length);
      const downScale = projection(cursor, downS, [c.hiddenSize, c.intermediateSize / c.groupSize]); cursor = add(cursor, downS.length);
      chunks.push({ offset: gateScale.offset, bytes: gateS }, { offset: upScale.offset, bytes: upS }, { offset: downScale.offset, bytes: downS });
      const scaleLength = cursor - scaleOffset;
      experts.push({
        layer, expert,
        weights: { offset: weightOffset, length: weightLength, sha256: "", gate, up, down },
        scales: { offset: scaleOffset, length: scaleLength, sha256: "", gate: gateScale, up: upScale, down: downScale },
      });
    }
  }
  const fileSize = align(cursor, c.alignment);
  const bytes = new Uint8Array(fileSize);
  for (const chunk of chunks) bytes.set(chunk.bytes, chunk.offset);
  for (const entry of experts) {
    entry.weights.sha256 = digest(bytes.subarray(entry.weights.offset, entry.weights.offset + entry.weights.length));
    entry.scales.sha256 = digest(bytes.subarray(entry.scales.offset, entry.scales.offset + entry.scales.length));
  }
  const manifest: SyntheticExpertManifest = {
    format: COLIBRI_EXPERT_FORMAT, version: 1, alignment: c.alignment, file: "experts.bin", fileSize,
    fileSha256: digest(bytes), config: c, experts,
  };
  validateSyntheticExpertManifest(manifest, bytes);
  return { bytes, manifest };
}

export function validateSyntheticExpertManifest(manifest: SyntheticExpertManifest, bytes?: Uint8Array): void {
  if (manifest.format !== COLIBRI_EXPERT_FORMAT) throw new Error(`unsupported expert format: ${manifest.format}`);
  if (manifest.version !== 1) throw new Error(`unsupported expert manifest version: ${manifest.version}`);
  const c = normalizeSyntheticExpertConfig(manifest.config);
  if (manifest.alignment !== c.alignment || manifest.file !== "experts.bin") throw new Error("manifest storage contract mismatch");
  if (manifest.experts.length !== c.layers * c.expertsPerLayer) throw new Error("expert count does not match config");
  if (!Number.isSafeInteger(manifest.fileSize) || manifest.fileSize <= 0) throw new Error("invalid file size");
  let previousEnd = 0;
  const weightElements = c.hiddenSize * c.intermediateSize;
  const weightBytes = weightElements * c.bits / 8;
  const scaleBytes = weightElements / c.groupSize * 2;
  const shapes = {
    gate: [c.intermediateSize, c.hiddenSize] as [number, number],
    up: [c.intermediateSize, c.hiddenSize] as [number, number],
    down: [c.hiddenSize, c.intermediateSize] as [number, number],
    gateScale: [c.intermediateSize, c.hiddenSize / c.groupSize] as [number, number],
    upScale: [c.intermediateSize, c.hiddenSize / c.groupSize] as [number, number],
    downScale: [c.hiddenSize, c.intermediateSize / c.groupSize] as [number, number],
  };
  const sameShape = (a: [number, number], b: [number, number]) => a[0] === b[0] && a[1] === b[1];
  for (let index = 0; index < manifest.experts.length; index++) {
    const entry = manifest.experts[index]!;
    if (entry.layer !== Math.floor(index / c.expertsPerLayer) || entry.expert !== index % c.expertsPerLayer)
      throw new Error("expert identity/order does not match config");
    for (const region of [entry.weights, entry.scales]) {
      if (region.offset % c.alignment !== 0) throw new Error("expert region is not aligned");
      const end = add(region.offset, region.length);
      if (region.offset < previousEnd || end > manifest.fileSize) throw new Error("expert regions overlap or exceed file");
      previousEnd = end;
    }
    if (entry.weights.up.offset !== entry.weights.gate.offset + entry.weights.gate.length ||
        entry.weights.down.offset !== entry.weights.up.offset + entry.weights.up.length ||
        entry.weights.length !== entry.weights.gate.length + entry.weights.up.length + entry.weights.down.length)
      throw new Error("gate/up/down weights are not contiguous");
    if (entry.scales.up.offset !== entry.scales.gate.offset + entry.scales.gate.length ||
        entry.scales.down.offset !== entry.scales.up.offset + entry.scales.up.length ||
        entry.scales.length !== entry.scales.gate.length + entry.scales.up.length + entry.scales.down.length)
      throw new Error("gate/up/down scales are not contiguous");
    const projections: Array<[ProjectionRegion, number, [number, number], Region]> = [
      [entry.weights.gate, weightBytes, shapes.gate, entry.weights],
      [entry.weights.up, weightBytes, shapes.up, entry.weights],
      [entry.weights.down, weightBytes, shapes.down, entry.weights],
      [entry.scales.gate, scaleBytes, shapes.gateScale, entry.scales],
      [entry.scales.up, scaleBytes, shapes.upScale, entry.scales],
      [entry.scales.down, scaleBytes, shapes.downScale, entry.scales],
    ];
    for (const [projection, expectedLength, expectedShape, parent] of projections) {
      if (projection.length !== expectedLength || !sameShape(projection.shape, expectedShape))
        throw new Error("projection length/shape does not match config");
      if (projection.offset < parent.offset || add(projection.offset, projection.length) > add(parent.offset, parent.length))
        throw new Error("projection exceeds parent region");
    }
  }
  if (manifest.fileSize !== align(previousEnd, c.alignment)) throw new Error("file size does not match aligned layout end");
  if (bytes) {
    if (bytes.length !== manifest.fileSize) throw new Error("expert file size does not match manifest");
    if (digest(bytes) !== manifest.fileSha256) throw new Error("expert file checksum mismatch");
    for (const entry of manifest.experts) for (const region of [
      entry.weights, entry.weights.gate, entry.weights.up, entry.weights.down,
      entry.scales, entry.scales.gate, entry.scales.up, entry.scales.down,
    ])
      if (digest(bytes.subarray(region.offset, region.offset + region.length)) !== region.sha256)
        throw new Error("expert region checksum mismatch");
  }
}

export function writeSyntheticExpertFile(outDir: string, config: SyntheticExpertConfig): SyntheticExpertManifest {
  const { bytes, manifest } = buildSyntheticExpertFile(config);
  mkdirSync(outDir, { recursive: true });
  writeFileSync(join(outDir, manifest.file), bytes);
  writeFileSync(join(outDir, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  return manifest;
}

export function validateSyntheticExpertFiles(outDir: string): SyntheticExpertManifest {
  const manifest = JSON.parse(readFileSync(join(outDir, "manifest.json"), "utf8")) as SyntheticExpertManifest;
  if (statSync(join(outDir, manifest.file)).size !== manifest.fileSize) throw new Error("expert file size does not match manifest");
  validateSyntheticExpertManifest(manifest, new Uint8Array(readFileSync(join(outDir, manifest.file))));
  return manifest;
}

if (import.meta.main) {
  const outDir = process.argv[2];
  if (!outDir) throw new Error("usage: bun scripts/experiments/gen-colibri-expert-file.ts <out-dir> [config.json]");
  const defaults: SyntheticExpertConfig = {
    layers: 2, expertsPerLayer: 4, hiddenSize: 64, intermediateSize: 32, bits: 4, groupSize: 16,
  };
  const config = process.argv[3] ? JSON.parse(readFileSync(process.argv[3], "utf8")) as SyntheticExpertConfig : defaults;
  const manifest = writeSyntheticExpertFile(outDir, config);
  console.log(`${join(outDir, manifest.file)} ${manifest.fileSize} bytes ${manifest.fileSha256}`);
}
