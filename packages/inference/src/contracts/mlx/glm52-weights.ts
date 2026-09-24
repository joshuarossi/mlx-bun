import { MlxArray } from "@mlx-bun/mlx/array";


/** Structural seam used by tiny fixtures as well as ColibriGlm52Weights. */
export interface Glm52MlaWeightSource {
  tensor(name: string): MlxArray;
  dequantized(name: string, outputRows: number, inputColumns: number): MlxArray;
  linear(
    x: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray;
}

export interface Glm52WeightSource extends Glm52MlaWeightSource {
  readonly weightsBytes: number;
  has(name: string): boolean;
  embedding(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray;
  dispose(): void;
}
