import type { GraphDescriptor } from "./graph";

/** Denoising has canvas state and feedback, independent of AR token caches.
 * Returned tensors/state are owned by the run. Inputs remain borrowed. A
 * fused method may bypass this graph and implement InferenceMethod directly. */
export interface DenoisingGraph<Tensor, State> {
  readonly descriptor: GraphDescriptor;
  readonly vocabSize: number;
  readonly canvasLength: number;
  readonly embedScale: number;
  prefill(promptIds: number[], vision?: Tensor): State;
  extendPrefill(tokens: Tensor, state: State): void;
  decoderLogits(canvas: Tensor, state: State, feedback: Tensor | null): Tensor;
  dequantEmbedWeight(): Tensor;
  softEmbeddings(logits: Tensor, weight: Tensor): Tensor;
  closeState(state: State): void;
}
