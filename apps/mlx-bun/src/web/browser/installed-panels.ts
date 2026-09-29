import type { ShellPanel } from "@mlx-bun/web-shell";

/** The panels of the modules this host installs, for the shell to mount. The browser build replaces this file's
 * source (`web/build.ts`): it imports each installed module's panel entry, which defines its custom element, and
 * lists the panel with its connection, all from the modules `src/modules.ts` names. Loaded any other way it lists none. */
export const panels: readonly ShellPanel[] = [];
