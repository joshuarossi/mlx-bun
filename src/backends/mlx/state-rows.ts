import type { BatchableCache, Cache } from "../../model/gemma4-base";
import { applyStateChanges, cleanupFailure, disposeResources } from "../../engine/resources";
import type { PreparedStateChange } from "../../contracts/resources";

/** Preserve the graph's layout capabilities when an empty sibling is made. */
export interface MlxRowLayout<Layout extends BatchableCache> extends BatchableCache {
  makeEmptyBatch(): Layout;
}

/** Layer layouts own tensor geometry. This collection only applies the same
 * row membership operation to every layer. It has no scheduling, sampling,
 * checkpoint-key or persistence policy. */
export class MlxStateRows<Layout extends MlxRowLayout<Layout> = BatchableCache> {
  /** Borrowed by the bound target graph; collection ownership stays here. */
  readonly caches: Layout[];
  #rows = 0;

  /** Takes ownership of empty, compatible layer layouts. */
  constructor(layouts: readonly Layout[]) { this.caches = [...layouts]; }
  get rowCount(): number { return this.#rows; }
  /** Retain an immutable batch boundary without extracting or materializing
   * individual rows. Layer layouts decide how to share their backing arrays. */
  clone(): MlxStateRows<Layout> {
    const layouts: Layout[] = [];
    try {
      for (const source of this.caches) {
        const layout = source.makeEmptyBatch(); layouts.push(layout);
        layout.mergeRows([source]);
      }
      const result = new MlxStateRows(layouts); result.#rows = this.#rows;
      return result;
    } catch (error) { return cleanupFailure(error, () => disposeResources(layouts)); }
  }
  /** Prepare an initial cohort with one merge per layer. */
  mergeRows(rows: readonly (readonly Cache[])[]): void {
    const next: Layout[] = [];
    try {
      for (let layer = 0; layer < this.caches.length; layer++) {
        const layout = this.caches[layer]!.makeEmptyBatch(); next.push(layout);
        layout.mergeRows(rows.map(row => row[layer]!));
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    const previous = this.caches.splice(0, this.caches.length, ...next);
    this.#rows = rows.length; disposeResources(previous);
  }

  /** Borrow a prepared request's state. Build every replacement before
   * releasing the active group, so a failed admission leaves it intact. */
  append(row: readonly Cache[]): void {
    applyStateChanges([() => this.prepareAppend(row)]);
  }

  /** Stage membership so a method can compose it with companion-state admission. */
  prepareAppend(row: readonly Cache[]): PreparedStateChange {
    return this.prepareAppendMany([row]);
  }

  /** Stage several admissions with one membership operation per layer. */
  prepareAppendMany(rows: readonly (readonly Cache[])[]): PreparedStateChange {
    const next: Layout[] = [];
    try {
      for (let layer = 0; layer < this.caches.length; layer++) {
        const layout = this.caches[layer]!;
        const merged = layout.makeEmptyBatch();
        next.push(merged);
        merged.mergeRows([...(this.#rows ? [layout] : []), ...rows.map(row => row[layer]!)]);
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    return {
      commit: () => {
        const previous = this.caches.splice(0, this.caches.length, ...next.splice(0));
        this.#rows += rows.length;
        next.push(...previous);
      },
      dispose: () => disposeResources(next.splice(0)),
    };
  }

  /** The method calls this only between committed steps. A layer failure
   * invalidates the group; its caller discards the state. */
  filterRows(keep: readonly number[]): void {
    if (!keep.length) { this.clear(); return; }
    for (const layout of this.caches) layout.filterRows(keep);
    this.#rows = keep.length;
  }

  /** Returns independent request state for a cache publisher or a new group. */
  extractRow(row: number): Cache[] {
    const state: Cache[] = [];
    try { for (const layout of this.caches) state.push(layout.extractRow(row)); return state; }
    catch (error) { return cleanupFailure(error, () => disposeResources(state)); }
  }

  clear(): void {
    const next: Layout[] = [];
    try { for (const layout of this.caches) next.push(layout.makeEmptyBatch()); }
    catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    const previous = this.caches.splice(0, this.caches.length, ...next);
    this.#rows = 0;
    disposeResources(previous);
  }

  dispose(): void { this.#rows = 0; disposeResources(this.caches); }
}
