import type { MlxArray } from "../mlx/array";
import type { Glm52WeightSource } from "./glm52";
import { ColibriGlm52Container } from "./glm52-container";
import { ColibriGlm52Weights } from "./glm52-weights";

const ROUTED_EXPERT = /\.mlp\.experts\.\d+\./;

/**
 * Dense/shared/router-only view of the direct Colibri artifact. Even if an
 * owning safetensors shard also contains routed tensors, this boundary refuses
 * their names so the streamed model cannot silently fall back to mmap.
 */
export class ColibriGlm52ResidentWeights implements Glm52WeightSource {
  readonly container: ColibriGlm52Container;
  readonly weightsBytes: number;
  readonly source: ColibriGlm52Weights;
  readonly #allowed: ReadonlySet<string>;

  private constructor(
    container: ColibriGlm52Container,
    source: ColibriGlm52Weights,
    allowed: ReadonlySet<string>,
    weightsBytes: number,
  ) {
    this.container = container;
    this.source = source;
    this.#allowed = allowed;
    this.weightsBytes = weightsBytes;
  }

  static open(
    modelDir: string,
    options: { includeMtp?: boolean } = {},
  ): ColibriGlm52ResidentWeights {
    const container = ColibriGlm52Container.open(modelDir);
    const names = [...container.tensors.values()]
      .filter((tensor) =>
        (options.includeMtp !== false || tensor.family !== "mtp") &&
        !ROUTED_EXPERT.test(tensor.name))
      .map((tensor) => tensor.name);
    const allowed = new Set(names);
    const weightsBytes = names.reduce(
      (total, name) => total + container.info(name).byteLength,
      0,
    );
    const source = ColibriGlm52Weights.openSelected(modelDir, names);
    return new ColibriGlm52ResidentWeights(
      container,
      source,
      allowed,
      weightsBytes,
    );
  }

  get mappedShardCount(): number {
    return this.source.mappedShardCount;
  }

  get mappedShardBytes(): number {
    return this.source.mappedShardBytes;
  }

  has(name: string): boolean {
    return this.#allowed.has(name);
  }

  tensor(name: string): MlxArray {
    this.#check(name);
    return this.source.tensor(name);
  }

  dequantized(
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    this.#check(name);
    return this.source.dequantized(name, outputRows, inputColumns);
  }

  linear(
    input: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray {
    this.#check(name);
    const info = this.container.info(name);
    const descriptor = info.dtype === "U8"
      ? this.source.quantized(name, outputRows, inputColumns)
      : null;
    if (name === "lm_head.weight" && descriptor?.bits === 8) {
      return this.source.linearInt8Tiled(
        input,
        name,
        outputRows,
        inputColumns,
      );
    }
    if (
      descriptor?.bits === 4 &&
      inputColumns >= 32 &&
      inputColumns % 32 === 0
    ) {
      return this.source.linearQ4(
        input,
        name,
        outputRows,
        inputColumns,
      );
    }
    return this.source.linear(input, name, outputRows, inputColumns);
  }

  embedding(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray {
    this.#check(name);
    return this.source.embeddingRows(ids, name, vocabSize, hiddenSize);
  }

  dispose(): void {
    this.source.dispose();
  }

  #check(name: string): void {
    if (ROUTED_EXPERT.test(name))
      throw new Error(`${name}: routed experts require the slab residency backend`);
    if (!this.#allowed.has(name))
      throw new Error(`${name}: tensor is outside the resident GLM weight set`);
  }
}
