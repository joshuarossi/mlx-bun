import { KVCache, type Cache, type PaddedPrefillCache, type PrefillPadding } from "../../model/gemma4-base";
import { FullPrefillRow, fullRowInner } from "../../model/full-prefill-row";
import { cloneKvCaches } from "../../kv-store";
import { FullKvPositions, SpeculativeTransitioningKvRows, type KvRowTransition, type SpeculativeTransitionedKvLayout } from "./transitioning-kv-rows";

type FullLayout = SpeculativeTransitionedKvLayout & PaddedPrefillCache & {
  restorePrefillEnds(ends: readonly number[] | undefined): void;
}

class PrefillPositions extends FullKvPositions {
  override sync(rows: readonly Cache[], preserve: boolean): void {
    const offsets = rows.map(row => row instanceof FullPrefillRow ? row.positionOffset : row.offset);
    this.mergeRows(preserve
      ? [{ planes: [], rowOffsets: offsets, leftPad: [...this.leftPad] }]
      : rows.map((row, index) => ({ planes: [], rowOffsets: [offsets[index]!],
        leftPad: [row instanceof FullPrefillRow ? row.leftPadding : 0] })));
  }
}

/** Full-attention padding composes with the existing precision transition
 * and rollback lifecycle. Codec-specific attention stays in each adapter. */
export abstract class FullTransitioningKvRows<Layout extends FullLayout>
  extends SpeculativeTransitioningKvRows<Layout> implements PaddedPrefillCache {
  constructor(transition: KvRowTransition<Layout>, row?: Cache) {
    super({ ...transition,
      converted: row => transition.converted(fullRowInner(row)),
      extractRow: row => row instanceof FullPrefillRow ? row.extract() : cloneKvCaches([row])[0]!,
      packRows(layout, rows) {
        layout.mergeRows(rows.map(fullRowInner));
        if (rows.some(row => row instanceof FullPrefillRow)) {
          layout.preparePrefill({ lengths: rows.map(() => 0),
            leftPadding: rows.map(row => row instanceof FullPrefillRow ? row.leftPadding : 0) });
          const ends = rows.map(row => row instanceof FullPrefillRow ? row.padding.endOffsets?.[0] : undefined);
          layout.restorePrefillEnds(ends.some(end => end !== undefined) ? ends.map(end => end ?? Infinity) : undefined);
        }
      },
    }, row, new PrefillPositions());
  }
  preparePrefill(padding: PrefillPadding): void {
    if (this.packed) { this.packed.preparePrefill(padding); return; }
    if (!this.rows.length) this.rows = padding.lengths.map(() => new KVCache());
    this.rows = this.rows.map(row => row instanceof FullPrefillRow ? row : new FullPrefillRow(row as KVCache));
    for (const [index, row] of this.rows.entries()) (row as FullPrefillRow).preparePrefill({
      lengths: [padding.lengths[index]!],
      ...(padding.leftPadding ? { leftPadding: [padding.leftPadding[index]!] } : {}),
      ...(padding.rightPadding ? { rightPadding: [padding.rightPadding[index]!] } : {}),
    });
    this.syncPositions();
  }
  finalizePrefill(): void {
    if (this.packed) { this.packed.finalizePrefill(); return; }
    for (const row of this.rows) if (row instanceof FullPrefillRow) row.finalizePrefill();
    this.syncPositions();
  }
  override filterRows(keep: readonly number[]): void {
    if (!this.packed && keep.length) {
      const pads = [...this.leftPad], shared = Math.min(...keep.map(row => pads[row]!));
      for (const index of keep) {
        const row = this.rows[index]!;
        if (row instanceof FullPrefillRow) row.removeLeftPadding(Math.max(0, row.leftPadding - (pads[index]! - shared)));
      }
    }
    super.filterRows(keep);
  }
}
