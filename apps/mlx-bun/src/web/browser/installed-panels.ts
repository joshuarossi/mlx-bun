import type { ShellPanel } from "@mlx-bun/web-shell";

/** The panels of the modules this host installs, for the shell to mount. The browser build replaces this file's
 * source (`web/build.ts`): it imports the panel entry (which defines the custom element) and manifest of every
 * module the host's package.json lists that exports a panel. Loaded any other way it lists none. */
export const panels: readonly ShellPanel[] = [];
