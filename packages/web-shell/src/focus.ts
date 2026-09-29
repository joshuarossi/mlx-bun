/** A reusable focus trap: Tab and Shift+Tab cycle within the container while `isOpen()` is true, and focus returns
 * to whatever triggered the overlay when it closes. Every overlay and popover uses this one mechanism. */
export interface FocusTrap {
  /** Call right before opening: remembers the trigger to restore focus to. */
  capture(): void;
  /** Call right after closing. */
  restore(): void;
}

export function trapFocus(container: HTMLElement, isOpen: () => boolean): FocusTrap {
  let lastFocused: HTMLElement | null = null;
  const focusables = (): HTMLElement[] => [...container.querySelectorAll(
    'a[href],button:not([disabled]),textarea,input:not([disabled]),select,[tabindex]:not([tabindex="-1"])'
  )].filter((e) => (e as HTMLElement).offsetParent !== null || e === document.activeElement) as HTMLElement[];
  container.addEventListener("keydown", (e) => {
    const ke = e as KeyboardEvent;
    if (ke.key !== "Tab" || !isOpen()) return;
    const items = focusables();
    if (!items.length) return;
    const first = items[0]!, last = items[items.length - 1]!;
    if (ke.shiftKey && document.activeElement === first) { ke.preventDefault(); last.focus(); }
    else if (!ke.shiftKey && document.activeElement === last) { ke.preventDefault(); first.focus(); }
  });
  return {
    capture() { lastFocused = document.activeElement as HTMLElement | null; },
    restore() { if (lastFocused && lastFocused.focus) lastFocused.focus(); lastFocused = null; },
  };
}
