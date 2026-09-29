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

export interface QwenMtpTarget {
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

/** Graph-declared extensions over the target's live state. Sources request
 * only the ports they consume; they never inspect a concrete model or cache.
 * Absence refuses an unsupported pairing before draft-side allocation. */
export interface TargetView {
  /** Opaque identity for providers borrowing weights from one exact target. */
  readonly identity: object;
  readonly assistantRows?: AssistantRowsTarget;
  readonly gemmaTaps?: { readonly layerCount: number; readonly projection: DraftProjection };
  readonly qwenMtp?: QwenMtpTarget;
}

