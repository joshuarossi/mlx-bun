import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { ColibriGlm52Container } from "../../src/model/glm52-container";
import {
  buildGlm52ExpertSlotLayout,
  GLM52_EXPERT_SLOT_ALIGNMENT,
} from "../../src/model/glm52-expert-layout";

interface TensorSpec {
  readonly name: string;
  readonly dtype: "U8" | "F32";
  readonly bytes: number;
}

const roots: string[] = [];

function tempDir(): string {
  const root = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-expert-layout-"));
  roots.push(root);
  return root;
}

function writeShard(path: string, tensors: readonly TensorSpec[]): void {
  let cursor = 0;
  const header: Record<string, {
    dtype: "U8" | "F32";
    shape: number[];
    data_offsets: [number, number];
  }> = {};
  for (const tensor of tensors) {
    const end = cursor + tensor.bytes;
    header[tensor.name] = {
      dtype: tensor.dtype,
      shape: [tensor.dtype === "F32" ? tensor.bytes / 4 : tensor.bytes],
      data_offsets: [cursor, end],
    };
    cursor = end;
  }
  const encoded = Buffer.from(JSON.stringify(header));
  const prefix = Buffer.alloc(8);
  prefix.writeBigUInt64LE(BigInt(encoded.byteLength));
  writeFileSync(path, Buffer.concat([prefix, encoded, Buffer.alloc(cursor)]));
}

function names(layer: number, expert: number) {
  const prefix = `model.layers.${layer}.mlp.experts.${expert}`;
  return {
    downW: `${prefix}.down_proj.weight`,
    gateW: `${prefix}.gate_proj.weight`,
    upW: `${prefix}.up_proj.weight`,
    downS: `${prefix}.down_proj.weight.qs`,
    gateS: `${prefix}.gate_proj.weight.qs`,
    upS: `${prefix}.up_proj.weight.qs`,
  };
}

afterEach(() => {
  while (roots.length > 0) rmSync(roots.pop()!, { recursive: true, force: true });
});

describe("GLM-5.2 canonical expert slot layout", () => {
  test("page-aligns every directly wrapped Q4 weight and scale component", () => {
    const root = tempDir();
    const n = names(3, 0);
    writeShard(join(root, "out-00000.safetensors"), [
      { name: n.downS, dtype: "F32", bytes: 8 * 4 },
      { name: n.gateS, dtype: "F32", bytes: 4 * 4 },
      { name: n.upS, dtype: "F32", bytes: 4 * 4 },
      { name: n.downW, dtype: "U8", bytes: 8 * Math.ceil(4 / 2) },
      { name: n.gateW, dtype: "U8", bytes: 4 * Math.ceil(8 / 2) },
      { name: n.upW, dtype: "U8", bytes: 4 * Math.ceil(8 / 2) },
    ]);
    const container = ColibriGlm52Container.open(root);
    const layout = buildGlm52ExpertSlotLayout(
      container,
      { hiddenSize: 8, moeIntermediateSize: 4, numRoutedExperts: 2 },
      3,
      0,
    );

    expect(layout.bits).toBe(4);
    expect(layout.groupSize).toBeNull();
    expect(layout.weightBytes).toBe(48);
    expect(layout.scaleBytes).toBe(64);
    expect(layout.scaleOffset).toBe(3 * GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.payloadBytes).toBe(5 * GLM52_EXPERT_SLOT_ALIGNMENT + 16);
    expect(layout.slotBytes).toBe(6 * GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.projections.down.weightOffset).toBe(0);
    expect(layout.projections.gate.weightOffset).toBe(GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.projections.up.weightOffset).toBe(2 * GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.projections.down.scaleOffset).toBe(3 * GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.projections.gate.scaleOffset).toBe(4 * GLM52_EXPERT_SLOT_ALIGNMENT);
    expect(layout.projections.up.scaleOffset).toBe(5 * GLM52_EXPERT_SLOT_ALIGNMENT);
    for (const projection of Object.values(layout.projections)) {
      expect(projection.weightOffset % GLM52_EXPERT_SLOT_ALIGNMENT).toBe(0);
      expect(projection.scaleOffset % GLM52_EXPERT_SLOT_ALIGNMENT).toBe(0);
    }
    expect(layout.segments).toHaveLength(6);
    expect(layout.segments.map((segment) => ({
      destinationOffset: segment.destinationOffset,
      length: segment.length,
    }))).toEqual([
      { destinationOffset: 0, length: 16 },
      { destinationOffset: GLM52_EXPERT_SLOT_ALIGNMENT, length: 16 },
      { destinationOffset: 2 * GLM52_EXPERT_SLOT_ALIGNMENT, length: 16 },
      { destinationOffset: 3 * GLM52_EXPERT_SLOT_ALIGNMENT, length: 32 },
      { destinationOffset: 4 * GLM52_EXPERT_SLOT_ALIGNMENT, length: 16 },
      { destinationOffset: 5 * GLM52_EXPERT_SLOT_ALIGNMENT, length: 16 },
    ]);
  });

  test("keeps cross-shard components inside the eight-segment native bound", () => {
    const root = tempDir();
    const n = names(7, 1);
    writeShard(join(root, "out-00000.safetensors"), [
      { name: n.downS, dtype: "F32", bytes: 8 * 4 },
      { name: n.gateS, dtype: "F32", bytes: 4 * 4 },
      { name: n.downW, dtype: "U8", bytes: 16 },
      { name: n.gateW, dtype: "U8", bytes: 16 },
    ]);
    writeShard(join(root, "out-00001.safetensors"), [
      { name: n.upS, dtype: "F32", bytes: 4 * 4 },
      { name: n.upW, dtype: "U8", bytes: 16 },
    ]);
    const container = ColibriGlm52Container.open(root);
    const layout = buildGlm52ExpertSlotLayout(
      container,
      { hiddenSize: 8, moeIntermediateSize: 4, numRoutedExperts: 2 },
      7,
      1,
    );

    expect(layout.segments).toHaveLength(6);
    expect(layout.segments.map((segment) => [
      segment.file.split("/").at(-1),
      segment.destinationOffset,
      segment.length,
    ])).toEqual([
      ["out-00000.safetensors", 0, 16],
      ["out-00000.safetensors", GLM52_EXPERT_SLOT_ALIGNMENT, 16],
      ["out-00001.safetensors", 2 * GLM52_EXPERT_SLOT_ALIGNMENT, 16],
      ["out-00000.safetensors", 3 * GLM52_EXPERT_SLOT_ALIGNMENT, 32],
      ["out-00000.safetensors", 4 * GLM52_EXPERT_SLOT_ALIGNMENT, 16],
      ["out-00001.safetensors", 5 * GLM52_EXPERT_SLOT_ALIGNMENT, 16],
    ]);
  });

  test("derives Q8 and grouped-Q4 scale geometry from descriptor bytes", () => {
    const root = tempDir();
    const q8 = names(78, 0);
    writeShard(join(root, "out-mtp-00000.safetensors"), [
      { name: q8.downS, dtype: "F32", bytes: 8 * 4 },
      { name: q8.gateS, dtype: "F32", bytes: 4 * 4 },
      { name: q8.upS, dtype: "F32", bytes: 4 * 4 },
      { name: q8.downW, dtype: "U8", bytes: 8 * 4 },
      { name: q8.gateW, dtype: "U8", bytes: 4 * 8 },
      { name: q8.upW, dtype: "U8", bytes: 4 * 8 },
    ]);

    const grouped = names(3, 0);
    writeShard(join(root, "out-00000.safetensors"), [
      { name: grouped.downS, dtype: "F32", bytes: 64 * 2 * 4 },
      { name: grouped.gateS, dtype: "F32", bytes: 32 * 4 * 4 },
      { name: grouped.upS, dtype: "F32", bytes: 32 * 4 * 4 },
      { name: grouped.downW, dtype: "U8", bytes: 64 * 16 },
      { name: grouped.gateW, dtype: "U8", bytes: 32 * 32 },
      { name: grouped.upW, dtype: "U8", bytes: 32 * 32 },
    ]);
    const container = ColibriGlm52Container.open(root);

    const q8Layout = buildGlm52ExpertSlotLayout(
      container,
      { hiddenSize: 8, moeIntermediateSize: 4, numRoutedExperts: 1 },
      78,
      0,
    );
    expect(q8Layout.bits).toBe(8);
    expect(q8Layout.groupSize).toBeNull();
    expect(q8Layout.weightBytes).toBe(96);

    const groupedLayout = buildGlm52ExpertSlotLayout(
      container,
      { hiddenSize: 64, moeIntermediateSize: 32, numRoutedExperts: 1 },
      3,
      0,
    );
    expect(groupedLayout.bits).toBe(4);
    expect(groupedLayout.groupSize).toBe(16);
    expect(groupedLayout.weightBytes).toBe(3_072);
    expect(groupedLayout.scaleBytes).toBe(1_536);
  });
});
