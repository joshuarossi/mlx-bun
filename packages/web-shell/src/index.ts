// @mlx-bun/web-shell: the web shell of mlx-bun applications. Browser code only, with no workspace dependencies:
// a host (the app's browser entry, a native app's webview) creates a shell over its page markup, mounts the panels
// of the modules it installs, and starts it. Importing this entry touches no DOM.
export { $, el, injectStyles, toast } from "./dom";
export { trapFocus, type FocusTrap } from "./focus";
export { createOverlays, type Overlay, type Overlays } from "./overlays";
export { actionSection, createPalette, fuzzyMatch, type Palette, type PaletteAction, type PaletteRow, type PaletteSection } from "./palette";
export { buildPanelPage, panelRouteId, panelsFromManifests, type PanelConnection, type PanelElement, type PanelManifest, type ShellPanel } from "./panels";
export { createShell, type RouteController, type Shell, type ShellOptions, type ShellRoute, type ShellStart } from "./shell";
export { createShortcutSheet, type ShortcutSheet } from "./shortcuts";
export { THEME_CHOICES, THEME_KEY, cycleTheme, initTheme, setTheme, themeChoice } from "./theme";
