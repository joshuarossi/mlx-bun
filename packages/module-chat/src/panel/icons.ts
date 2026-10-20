// The panel's icons: inline SVG (the app runs offline, so no icon font or CDN), drawn on a 24-unit grid with the
// current text colour. Every one is decorative (`aria-hidden`); the control that carries it names itself with text or
// an `aria-label`.
const svg = (body: string, fill = "none"): string =>
  `<svg viewBox="0 0 24 24" width="16" height="16" fill="${fill}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">${body}</svg>`;

export const ICON = {
  plus: svg('<path d="M12 5v14M5 12h14"/>'),
  search: svg('<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>'),
  attach: svg('<path d="m21 11-8.6 8.6a6 6 0 0 1-8.5-8.5l8.6-8.6a4 4 0 0 1 5.7 5.7l-8.6 8.6a2 2 0 0 1-2.8-2.8l8-8"/>'),
  mic: svg('<rect x="9" y="2.5" width="6" height="12" rx="3"/><path d="M19 10.5a7 7 0 0 1-14 0M12 17.5V21"/>'),
  send: svg('<path d="M12 19V5M5.5 11.5 12 5l6.5 6.5"/>'),
  stop: svg('<rect x="6.5" y="6.5" width="11" height="11" rx="2"/>', "currentColor"),
  gear: svg('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>'),
  close: svg('<path d="M18 6 6 18M6 6l12 12"/>'),
  chevron: svg('<path d="m9 6 6 6-6 6"/>'),
  download: svg('<path d="M12 4v11M7 10.5l5 5 5-5M5 20h14"/>'),
  branch: svg('<circle cx="6" cy="5.5" r="2.5"/><circle cx="6" cy="18.5" r="2.5"/><circle cx="18" cy="8" r="2.5"/><path d="M6 8v8M18 10.5c0 4-5 4-11 6"/>'),
  trash: svg('<path d="M4 7h16M9 7V4.5h6V7M18 7l-.9 12.5a1.5 1.5 0 0 1-1.5 1.5H8.4a1.5 1.5 0 0 1-1.5-1.5L6 7"/>'),
  copy: svg('<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M15 9V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h3"/>'),
  regenerate: svg('<path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"/>'),
  edit: svg('<path d="M12 20h8M16.5 3.5a2.1 2.1 0 0 1 3 3L7.5 18.5 3.5 19.5l1-4z"/>'),
  file: svg('<path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/>'),
  memory: svg('<path d="M5 19.5A2.5 2.5 0 0 1 7.5 17H19V3H7.5A2.5 2.5 0 0 0 5 5.5z"/><path d="M5 19.5A2.5 2.5 0 0 0 7.5 22H19v-5"/>'),
  tool: svg('<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.8-3.8a6 6 0 0 1-7.9 7.9l-6.9 6.9a2.1 2.1 0 0 1-3-3l6.9-6.9a6 6 0 0 1 7.9-7.9z"/>'),
  warning: svg('<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0zM12 9v4M12 17h.01"/>'),
  check: svg('<path d="M20 6 9 17l-5-5"/>'),
  deny: svg('<circle cx="12" cy="12" r="9"/><path d="m15 9-6 6M9 9l6 6"/>'),
} as const;
