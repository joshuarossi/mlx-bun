// The panel's open popovers, for the host's Escape sweep: each registers how to close itself when its controls are
// wired, and `closeTopPopover` closes the first one open (in the order the host page's sweep always used).
const ORDER = ["chat-sampling-pop", "chat-sysprompt-pop", "adapters-overlay"] as const;
type PopoverId = (typeof ORDER)[number];
const closers: Partial<Record<PopoverId, () => void>> = {};

export function setPopoverClose(id: PopoverId, close: () => void): void { closers[id] = close; }

const isOpen = (id: PopoverId): boolean => !!closers[id] && !!document.getElementById(id)?.classList.contains("open");

export function hasOpenPopover(): boolean { return ORDER.some(isOpen); }

/** Closes the first open popover; false when none was open. */
export function closeTopPopover(): boolean {
  for (const id of ORDER) if (isOpen(id)) { closers[id]!(); return true; }
  return false;
}

/** Closes every open popover but `keep`, so opening one never stacks it on another. */
export function closeOtherPopovers(keep: PopoverId): void {
  for (const id of ORDER) if (id !== keep && isOpen(id)) closers[id]!();
}
