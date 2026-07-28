// Direct MLX tensor source for Colibri's out-*.safetensors artifact.
//
// The container catalog supplies logical tensor geometry and exact file
// ownership. Native MLX keeps each shard's tensors lazy. G2 uses an explicit
// dequantize→f32 matmul reference path; G3 replaces routed-expert materializing
// with the aligned slab/custom-Metal path without changing the model graph.

import { ptr, read } from "bun:ffi";
import { statSync } from "node:fs";
import { MlxArray, cpuStream, gpuStream } from "../mlx/array";
import { C, Dtype, synchronize } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  ColibriGlm52Container,
  type ColibriQuantTensorInfo,
} from "./glm52-container";

const cstr = (value: string): Buffer => Buffer.from(`${value}\0`, "utf8");

/**
 * Colibri writes four-bit weights as consecutive bytes (two input columns per
 * byte). MLX's affine dequantizer expects the same nibbles packed into uint32
 * words. Repack lazily with MLX ops so the direct artifact never round-trips
 * through a 100s-of-MiB JS buffer.
 */
function packInt4BytesForMlx(
  raw: MlxArray,
  outputRows: number,
  inputColumns: number,
): MlxArray {
  const rowBytes = Math.ceil(inputColumns / 2);
  const words = Math.ceil(rowBytes / 4);
  let bytes = ops.reshape(raw, [outputRows, rowBytes]);
  const paddedBytes = words * 4;
  if (paddedBytes !== rowBytes) {
    const padding = ops.zeros(
      [outputRows, paddedBytes - rowBytes],
      Dtype.uint8,
    );
    const padded = ops.concatAxis([bytes, padding], 1);
    bytes.dispose();
    padding.dispose();
    bytes = padded;
  }
  const lanes = ops.reshape(bytes, [outputRows, words, 4]);
  bytes.dispose();
  let packed = ops.zeros([outputRows, words], Dtype.uint32);
  for (let lane = 0; lane < 4; lane++) {
    const view = lanes.slice(
      [0, 0, lane],
      [outputRows, words, lane + 1],
    );
    const flat = ops.reshape(view, [outputRows, words]);
    view.dispose();
    const word = flat.astype(Dtype.uint32);
    flat.dispose();
    const shiftI32 = MlxArray.fromInt32(new Int32Array([lane * 8]), []);
    const shift = shiftI32.astype(Dtype.uint32);
    shiftI32.dispose();
    const shifted = ops.leftShift(word, shift);
    word.dispose();
    shift.dispose();
    const next = ops.bitwiseOr(packed, shifted);
    packed.dispose();
    shifted.dispose();
    packed = next;
  }
  lanes.dispose();
  return packed;
}

export class ColibriGlm52Weights {
  readonly container: ColibriGlm52Container;
  readonly weightsBytes: number;
  readonly #maps = new Map<string, bigint>();
  readonly #arrays = new Map<string, MlxArray>();

  private constructor(container: ColibriGlm52Container) {
    this.container = container;
    this.weightsBytes = container.files.reduce(
      (total, file) => total + statSync(file.path).size,
      0,
    );
  }

  static #openFiles(
    container: ColibriGlm52Container,
    paths: ReadonlySet<string>,
  ): ColibriGlm52Weights {
    const self = new ColibriGlm52Weights(container);
    try {
      for (const { path } of self.container.files) {
        if (!paths.has(path)) continue;
        const arraysOut = new BigUint64Array([C.mlx_map_string_to_array_new()]);
        const metadataOut = new BigUint64Array([C.mlx_map_string_to_string_new()]);
        const arraysPtr = ptr(arraysOut);
        const metadataPtr = ptr(metadataOut);
        const status = C.mlx_load_safetensors(
          arraysPtr,
          metadataPtr,
          ptr(cstr(path)),
          cpuStream,
        );
        const metadata = read.u64(metadataPtr, 0);
        C.mlx_map_string_to_string_free(metadata);
        const arrays = read.u64(arraysPtr, 0);
        if (status !== 0) {
          C.mlx_map_string_to_array_free(arrays);
          throw new Error(`mlx_load_safetensors(${path}) failed`);
        }
        self.#maps.set(path, arrays);
      }
      return self;
    } catch (error) {
      self.dispose();
      throw error;
    }
  }

  static open(modelDir: string): ColibriGlm52Weights {
    const container = ColibriGlm52Container.open(modelDir);
    return ColibriGlm52Weights.#openFiles(
      container,
      new Set(container.files.map(({ path }) => path)),
    );
  }

  /**
   * Open only the shards that own `tensorNames`.
   *
   * This is an explicit probe/tooling seam, not a partial-model constructor.
   * Quantized callers must include both the packed tensor and its `.qs`
   * companion. Accessing any catalogued tensor in an unopened shard fails.
   */
  static openSelected(
    modelDir: string,
    tensorNames: readonly string[],
  ): ColibriGlm52Weights {
    if (tensorNames.length === 0)
      throw new Error("selected Colibri weights require at least one tensor");
    const container = ColibriGlm52Container.open(modelDir);
    const paths = new Set(tensorNames.map((name) => container.info(name).file));
    return ColibriGlm52Weights.#openFiles(container, paths);
  }

  get mappedShardCount(): number {
    return this.#maps.size;
  }

  get mappedShardBytes(): number {
    let total = 0;
    for (const path of this.#maps.keys()) total += statSync(path).size;
    return total;
  }

  has(name: string): boolean {
    return this.container.has(name);
  }

  tensor(name: string): MlxArray {
    let array = this.#arrays.get(name);
    if (array) return array;
    const info = this.container.info(name);
    const map = this.#maps.get(info.file);
    if (map === undefined)
      throw new Error(`${name}: shard ${info.file} is not open`);
    const out = new BigUint64Array([C.mlx_array_new()]);
    const outPtr = ptr(out);
    if (C.mlx_map_string_to_array_get(outPtr, map, ptr(cstr(name))) !== 0)
      throw new Error(`${name}: missing from native safetensors map`);
    array = new MlxArray(read.u64(outPtr, 0));
    this.#arrays.set(name, array);
    return array;
  }

  quantized(name: string, outputRows: number, inputColumns: number): ColibriQuantTensorInfo {
    return this.container.quantized(name, outputRows, inputColumns);
  }

  /**
   * Materialize the logical [output,input] tensor as f32.
   *
   * This is intentionally the slow correctness path. Colibri int4 is
   * offset-binary (`nibble - 8`); int8 is signed two's-complement. Neither is
   * inferred from config.quantization_config, which still describes the
   * pre-conversion FP8 checkpoint.
   */
  dequantized(name: string, outputRows: number, inputColumns: number): MlxArray {
    const descriptor = this.quantized(name, outputRows, inputColumns);
    const raw = this.tensor(name);
    const scaleRaw = this.tensor(`${name}.qs`);
    const groups = descriptor.groupSize === null
      ? 1
      : Math.ceil(inputColumns / descriptor.groupSize);
    let scales = ops.reshape(scaleRaw, [outputRows, groups]);

    if (descriptor.bits === 4) {
      // MLX only instantiates affine-dequant Metal kernels for its supported
      // quantization group sizes. Colibri's ordinary Q4 tensors carry one
      // scale for the complete row, which would otherwise request kernels such
      // as `gs_6144`. Repeating that same scale over 32-value groups is exactly
      // value-preserving and selects MLX's production-supported kernel.
      let dequantGroupSize = descriptor.groupSize ?? inputColumns;
      if (
        descriptor.groupSize === null &&
        inputColumns > 32 &&
        inputColumns % 32 === 0
      ) {
        dequantGroupSize = 32;
        const expandedGroups = inputColumns / dequantGroupSize;
        const zeroGroups = ops.zeros(
          [outputRows, expandedGroups],
          Dtype.float32,
        );
        const expandedScales = ops.add(scales, zeroGroups);
        scales.dispose();
        zeroGroups.dispose();
        scales = expandedScales;
      }
      const packed = packInt4BytesForMlx(raw, outputRows, inputColumns);
      const minusEight = ops.mulScalar(scales, -8);
      const dequant = ops.dequantize(
        packed,
        scales,
        minusEight,
        {
          bits: 4,
          groupSize: dequantGroupSize,
          mode: "affine",
        },
      );
      packed.dispose();
      scales.dispose();
      minusEight.dispose();
      // MLX's packed shape can round the final lane for odd logical widths.
      // Full GLM dimensions are even; fixtures may deliberately exercise odd
      // tails through the host reference implementation instead.
      if (dequant.shape[1] !== inputColumns) {
        const sliced = dequant.slice([0, 0], [outputRows, inputColumns]);
        dequant.dispose();
        return sliced;
      }
      return dequant;
    }

    const bytes = ops.reshape(raw, [outputRows, inputColumns]);
    // Colibri stores the byte view of int8. Casting uint8→int8 restores the
    // two's-complement value before conversion to f32.
    const signed = bytes.astype(Dtype.int8);
    const values = signed.astype(Dtype.float32);
    const out = ops.mul(values, scales);
    bytes.dispose();
    signed.dispose();
    values.dispose();
    scales.dispose();
    return out;
  }

  /** Reference f32-MAC linear: x[...,I] × W[O,I]^T. */
  linear(
    x: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    const weights = this.dequantized(name, outputRows, inputColumns);
    const transposed = ops.transposeAxes(weights, [1, 0]);
    const xf32 = x.dtype === Dtype.float32 ? x : x.astype(Dtype.float32);
    const out = ops.matmul(xf32, transposed);
    if (xf32 !== x) xf32.dispose();
    transposed.dispose();
    weights.dispose();
    return out;
  }

  /**
   * MLX affine-Q4 linear for the streamed resident spine.
   *
   * Colibri stores already-packed nibbles but exposes them as uint8. Packing
   * those bytes into MLX's uint32 view is still far smaller than expanding the
   * complete matrix to f32, and preserves the exact `(nibble - 8) * scale`
   * affine values.
   */
  linearQ4(
    x: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    const descriptor = this.quantized(name, outputRows, inputColumns);
    if (descriptor.bits !== 4)
      throw new Error(`${name}: Q4 linear requires four-bit weights`);
    const raw = this.tensor(name);
    const scaleRaw = this.tensor(`${name}.qs`);
    const groups = descriptor.groupSize === null
      ? 1
      : Math.ceil(inputColumns / descriptor.groupSize);
    let scales = ops.reshape(scaleRaw, [outputRows, groups]);
    let groupSize = descriptor.groupSize ?? inputColumns;
    if (descriptor.groupSize === null && inputColumns > 32) {
      if (inputColumns % 32 !== 0)
        throw new Error(`${name}: per-row Q4 width must be divisible by 32`);
      groupSize = 32;
      const zeros = ops.zeros(
        [outputRows, inputColumns / groupSize],
        Dtype.float32,
      );
      const expanded = ops.add(scales, zeros);
      scales.dispose();
      zeros.dispose();
      scales = expanded;
    }
    const packed = packInt4BytesForMlx(raw, outputRows, inputColumns);
    const biases = ops.mulScalar(scales, -8);
    const xf32 = x.dtype === Dtype.float32 ? x : x.astype(Dtype.float32);
    const output = ops.quantizedMatmul(
      xf32,
      packed,
      scales,
      biases,
      { bits: 4, groupSize, mode: "affine" },
      true,
    );
    if (xf32 !== x) xf32.dispose();
    packed.dispose();
    scales.dispose();
    biases.dispose();
    return output;
  }

  /**
   * G2 reference embedding lookup. This intentionally materializes the
   * checkpoint-native quantized table through the same exact dequantizer as
   * linear weights; G3 replaces the full-table materialization with a
   * row-gather path.
   */
  embedding(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray {
    const table = this.dequantized(name, vocabSize, hiddenSize);
    const out = ops.takeAxis(table, ids, 0);
    table.dispose();
    return out;
  }

  /**
   * Gather only the requested embedding rows before dequantization.
   *
   * The production GLM table is signed int8 and expands to ~3.8 GiB as f32.
   * The streamed path must never create that full-table transient merely to
   * read a handful of token rows.
   */
  embeddingRows(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray {
    const descriptor = this.quantized(name, vocabSize, hiddenSize);
    const rowCount = ids.shape.reduce((product, value) => product * value, 1);
    const flatIds = ops.reshape(ids, [rowCount]);
    const raw = this.tensor(name);
    const scaleRaw = this.tensor(`${name}.qs`);
    const groups = descriptor.groupSize === null
      ? 1
      : Math.ceil(hiddenSize / descriptor.groupSize);
    const scaleTable = ops.reshape(scaleRaw, [vocabSize, groups]);
    const selectedScales = ops.takeAxis(scaleTable, flatIds, 0);
    scaleTable.dispose();
    let values: MlxArray | null = null;
    try {
      if (descriptor.bits === 8) {
        const byteTable = ops.reshape(raw, [vocabSize, hiddenSize]);
        const selectedBytes = ops.takeAxis(byteTable, flatIds, 0);
        byteTable.dispose();
        const signed = selectedBytes.astype(Dtype.int8);
        selectedBytes.dispose();
        const f32 = signed.astype(Dtype.float32);
        signed.dispose();
        values = ops.mul(f32, selectedScales);
        f32.dispose();
      } else if (descriptor.bits === 4) {
        const rowBytes = Math.ceil(hiddenSize / 2);
        const byteTable = ops.reshape(raw, [vocabSize, rowBytes]);
        const selectedBytes = ops.takeAxis(byteTable, flatIds, 0);
        byteTable.dispose();
        const packed = packInt4BytesForMlx(
          selectedBytes,
          rowCount,
          hiddenSize,
        );
        selectedBytes.dispose();
        let scales = selectedScales;
        let groupSize = descriptor.groupSize ?? hiddenSize;
        if (
          descriptor.groupSize === null &&
          hiddenSize > 32 &&
          hiddenSize % 32 === 0
        ) {
          groupSize = 32;
          const zeros = ops.zeros(
            [rowCount, hiddenSize / groupSize],
            Dtype.float32,
          );
          scales = ops.add(selectedScales, zeros);
          zeros.dispose();
        }
        const biases = ops.mulScalar(scales, -8);
        values = ops.dequantize(
          packed,
          scales,
          biases,
          { bits: 4, groupSize, mode: "affine" },
        );
        packed.dispose();
        biases.dispose();
        if (scales !== selectedScales) scales.dispose();
      } else {
        throw new Error(`${name}: unsupported embedding width ${descriptor.bits}`);
      }
      return ops.reshape(values, [...ids.shape, hiddenSize]);
    } finally {
      values?.dispose();
      selectedScales.dispose();
      flatIds.dispose();
    }
  }

  /**
   * Bounded signed-int8 linear used by the streamed production lm_head.
   *
   * Each output-row tile is fully evaluated before the next tile is built, so
   * MLX cannot retain a lazy graph containing the complete f32-expanded head.
   * Concatenation retains only the small materialized logits tiles.
   */
  linearInt8Tiled(
    x: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
    tileRows = 2048,
  ): MlxArray {
    const descriptor = this.quantized(name, outputRows, inputColumns);
    if (descriptor.bits !== 8 || descriptor.groupSize !== null)
      throw new Error(`${name}: tiled linear requires signed per-row int8`);
    if (!Number.isSafeInteger(tileRows) || tileRows < 1)
      throw new RangeError("tiled linear row count must be a positive integer");

    const byteTable = ops.reshape(
      this.tensor(name),
      [outputRows, inputColumns],
    );
    const scaleTable = ops.reshape(
      this.tensor(`${name}.qs`),
      [outputRows, 1],
    );
    const xf32 = x.dtype === Dtype.float32 ? x : x.astype(Dtype.float32);
    const tiles: MlxArray[] = [];
    try {
      for (let start = 0; start < outputRows; start += tileRows) {
        const stop = Math.min(outputRows, start + tileRows);
        const bytes = byteTable.slice(
          [start, 0],
          [stop, inputColumns],
        );
        const signed = bytes.astype(Dtype.int8);
        bytes.dispose();
        const f32 = signed.astype(Dtype.float32);
        signed.dispose();
        const scales = scaleTable.slice([start, 0], [stop, 1]);
        const weights = ops.mul(f32, scales);
        f32.dispose();
        scales.dispose();
        const transposed = ops.transposeAxes(weights, [1, 0]);
        weights.dispose();
        const output = ops.matmul(xf32, transposed);
        transposed.dispose();
        output.eval();
        synchronize(gpuStream);
        tiles.push(output);
      }
      if (tiles.length === 1) return tiles[0]!;
      return ops.concatAxis(tiles, x.shape.length - 1);
    } finally {
      byteTable.dispose();
      scaleTable.dispose();
      if (xf32 !== x) xf32.dispose();
      if (tiles.length > 1)
        for (const tile of tiles) tile.dispose();
    }
  }

  dispose(): void {
    for (const array of this.#arrays.values()) array.dispose();
    this.#arrays.clear();
    for (const map of this.#maps.values())
      C.mlx_map_string_to_array_free(map);
    this.#maps.clear();
  }
}
