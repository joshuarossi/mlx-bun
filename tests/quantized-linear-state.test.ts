import { describe, expect, test } from "bun:test";
import type { MlxArray } from "../src/mlx/array";
import {
  QuantizedLinear,
  type QuantizedLinearState,
} from "../src/model/gemma4-base";

function array(tag: string): MlxArray {
  return { tag } as unknown as MlxArray;
}

function state(tag: string, bits: number): QuantizedLinearState {
  return {
    w: array(`${tag}:w`),
    scales: array(`${tag}:scales`),
    biases: array(`${tag}:biases`),
    spec: { bits, groupSize: 64, mode: "affine" },
  };
}

describe("QuantizedLinear state exchange (model-free)", () => {
  test("installs one complete payload and returns the previous payload", () => {
    const original = state("original", 4);
    const probe = state("probe", 8);
    const layer = new QuantizedLinear(
      original.w,
      original.scales,
      original.biases,
      original.spec,
    );

    const previous = layer.exchangeQuantizedState(probe);
    expect(previous).toEqual(original);
    expect(layer.w).toBe(probe.w);
    expect(layer.scales).toBe(probe.scales);
    expect(layer.biases).toBe(probe.biases);
    expect(layer.spec).toBe(probe.spec);

    expect(layer.exchangeQuantizedState(previous)).toEqual(probe);
    expect(layer.w).toBe(original.w);
  });
});
