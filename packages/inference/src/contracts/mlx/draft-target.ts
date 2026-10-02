import type { MlxArray } from "@mlx-bun/mlx/array";
import type { AssistantDonors } from "./attention";
import type { DraftProjection } from "./draft-projection";

/** Read-only target state and embedding, independent of draft scheduling. */
export interface AssistantRowsTarget {
  readonly hiddenSize: number;
  embed(ids: MlxArray): MlxArray;
  readDonors(): AssistantDonors & {
    readonly positions: readonly number[];
    dispose(): void;
  };
}

/** What a recurrent multi-token-prediction head reads from its target: the
 *  final hidden layer's output (tapped before the final norm), the token
 *  embedding, and the output head. */
export interface RecurrentMtpTarget {
  readonly hiddenSize: number;
  readonly layerCount: number;
  embed(ids: MlxArray): MlxArray;
  logitsFromHidden(hidden: MlxArray): MlxArray;
  /** The untied quantized vocabulary projection, when the drafter may project
   *  onto a row subset of it (frequency-ranked draft vocabulary). Borrowed. */
  readonly vocabularyHead?: {
    readonly w: MlxArray; readonly scales: MlxArray; readonly biases: MlxArray | null;
    readonly spec: { bits: number; groupSize: number; mode: string };
    readonly vocabSize: number;
  };
}

/** Multi-layer hidden-state taps and the embedding/head projection a drafter
 *  conditions on. */
export interface HiddenLayerTapsTarget {
  readonly layerCount: number;
  readonly projection: DraftProjection;
}

/** Graph-declared ports over the target's live state, named for what they
 * provide. Sources request only the ports they consume and never inspect a
 * concrete model or cache; a source refuses a target that lacks one with
 * `targetLacks(port)` before any draft-side allocation. */
export interface TargetView {
  /** Opaque identity for providers borrowing weights from one exact target. */
  readonly identity: object;
  readonly assistantRows?: AssistantRowsTarget;
  readonly hiddenLayerTaps?: HiddenLayerTapsTarget;
  readonly recurrentMtp?: RecurrentMtpTarget;
}

export type TargetPort = "assistantRows" | "hiddenLayerTaps" | "recurrentMtp";

/** The refusal for a target graph that does not provide a requested port. */
export function targetLacks(port: TargetPort): Error {
  return new Error(`target graph does not provide ${port}`);
}

