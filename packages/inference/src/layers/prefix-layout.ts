import type { PrefixLayout } from "../contracts/mlx/trainable";

// Prefix-shared training: while a layout is active, attention ropes the
// concatenated [prompt(P); chosen(Rc); rejected(Rr)] sequence BLOCK-WISE (prompt
// at offset 0, each response reset to offset P) instead of at the uniform cache
// offset, so ONE forward over the concat equals the two separate [prompt;response]
// forwards. The matching block-sparse mask rides in through the training cache.
// Set around a single forward (single-threaded) and cleared after; null means
// the normal uniform-offset rope, so every other forward is untouched.
let active: PrefixLayout | null = null;

/** The layout attention must rope block-wise, or null. */
export function activePrefixLayout(): PrefixLayout | null {
  return active;
}

/** Only a graph's declared training operations set this (they clear it when
 *  their pass ends). */
export function setActivePrefixLayout(layout: PrefixLayout | null): void {
  active = layout;
}
