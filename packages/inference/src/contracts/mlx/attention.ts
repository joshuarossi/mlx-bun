import type { MlxArray } from "@mlx-bun/mlx/array";

/** The graph borrows donor attention; storage owns validity and encoding. */
export interface AssistantAttention {
  attend(query: MlxArray, scale: number, window: number | null): MlxArray;
}

export interface AssistantDonors { sliding: AssistantAttention; full: AssistantAttention; }
