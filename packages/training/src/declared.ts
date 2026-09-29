import type { HeadQuant, TrainableGraph } from "@mlx-bun/inference/contracts/mlx";

/** The graph's declared training operations. The trainer consumes only these,
 *  never a model's class; a part the graph does not declare is refused by name. */
export function trainableOf(model: object): TrainableGraph {
  const trainable = (model as { trainable?: TrainableGraph }).trainable;
  if (!trainable) throw new Error("the graph does not declare training operations (trainable)");
  return trainable;
}

/** One declared part of the graph's training operations; `what` names it in the refusal. */
export function declaredTraining<K extends "segmented" | "prefixShared" | "gradCheckpoint" | "denoising" | "flashAttention">(
  model: object, part: K, what: string,
): NonNullable<TrainableGraph[K]> {
  const declared = trainableOf(model)[part];
  if (declared === undefined) throw new Error(`the graph does not declare ${what}`);
  return declared as NonNullable<TrainableGraph[K]>;
}

/** One declared part of the graph's training operations, or null when it declares
 *  none (for parts whose absence only forgoes an optimization, so a graph declaring no training operations at all is fine too). */
export function declaredTrainingOrNull<K extends "gradCheckpoint">(model: object, part: K): NonNullable<TrainableGraph[K]> | null {
  const trainable = (model as { trainable?: TrainableGraph }).trainable;
  return (trainable?.[part] ?? null) as NonNullable<TrainableGraph[K]> | null;
}

/** The quantized LM head for the fused/flash linear-CE heads. */
export function lmHeadOf(model: object): HeadQuant {
  const trainable = trainableOf(model);
  if (!trainable.lmHead) throw new Error("the graph does not declare a quantized LM head (lmHead) for the fused linear-CE head");
  return trainable.lmHead();
}
