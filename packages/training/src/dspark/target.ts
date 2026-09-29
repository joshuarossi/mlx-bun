// What the drafter pipeline reads from its frozen target: the embedding and LM
// head the graph declares for drafts. The target is any graph that declares
// them (and hidden-layer taps for regen); nothing here names a model class.

import type { RuntimeModel } from "@mlx-bun/inference/models";
import { bindLegacyDraftTarget } from "@mlx-bun/inference/generation/speculative/binding";
import { targetLacks, type DraftProjection } from "@mlx-bun/inference/generation/speculative";

/** The target's draft projection: `embed` and `logitsFromHidden`. Borrowed from the model. */
export function draftProjection(model: RuntimeModel): DraftProjection {
  const taps = bindLegacyDraftTarget(model, []).hiddenLayerTaps;
  if (!taps) throw targetLacks("hiddenLayerTaps");
  return taps.projection;
}
