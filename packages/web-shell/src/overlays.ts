/** An open popover, drawer, sheet or modal the Escape key can close. */
export interface Overlay {
  isOpen(): boolean;
  close(): void;
}

/** The set of overlays Escape closes, checked in the order they were added (add the most recently opened kinds
 * first). One mechanism for every overlay, not a bespoke Escape listener per modal. */
export interface Overlays {
  add(overlay: Overlay): void;
  /** Closes the first open overlay; false when none was open. */
  closeTop(): boolean;
}

export function createOverlays(): Overlays {
  const list: Overlay[] = [];
  return {
    add(overlay) { list.push(overlay); },
    closeTop() {
      for (const overlay of list) if (overlay.isOpen()) { overlay.close(); return true; }
      return false;
    },
  };
}
