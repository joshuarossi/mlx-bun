// Browser entry, built by scripts/build-web.ts into apps/mlx-bun/dist/web/app.js, which apps/mlx-bun/src/web/assets.ts
// serves at GET /assets/app.js and app.html loads via <script defer src="/assets/app.js">.
//
// It composes the web shell (`@mlx-bun/web-shell`: navigation, routing, theme, palette chrome, panel mounting) over
// the web kit's tokens, the panels of the installed modules (installed-panels.ts, generated from the host's module
// list at build time: the chat is one, the workspace the shell opens on), and the host's own pages (status, the
// routes map) and chrome (settings, the status strip, the palette). The order below is load-bearing: controllers
// must be populated before the first navigation can dispatch to them.

import { appKeys, initDrawer, initRoutesProbe, mountPanels, registerOverlays, shell } from "./app-shell/shell";
import { initSettings } from "./app-shell/settings";
import { initServerStatus } from "./app-shell/server-status";
import { createAppPalette } from "./app-shell/palette";
import { registerMemoryOverlay } from "./memory-panel";
import { chatHost } from "./chat-host";
import { createStatusController } from "./status";
import { panels } from "./installed-panels";

// The settings dialog: appearance, agent tools, the Hugging Face token.
initSettings();

// One tab and one page per installed module panel, before the shell starts so the Developer switch sees the tabs. The
// chat panel is handed its host side (chat-host.ts): memory's chips and sidebar entry, the agent-tools settings.
mountPanels(panels.map(panel => panel.tag === "mlx-chat-panel" ? { ...panel, properties: { host: chatHost } } : panel));

registerMemoryOverlay();

// The top bar's drawer trigger delegates to the chat.
initDrawer();

// Command palette and the Escape overlay sweep, in priority order.
const palette = createAppPalette();
registerOverlays(palette);

// Theme, PWA service worker, shortcut sheet, global keys (Cmd/Ctrl+K, Cmd/Ctrl+/, the chat's bindings, Escape),
// hash routing, the Developer switch and the navigation sheet.
shell.start({ palette, keys: appKeys });

// Page controllers. Each init() is lazy (run on first visit to that route); only the factory call happens here. The
// chat is not one: its panel initializes itself when the shell first shows it.
shell.controllers.status = createStatusController();

if (!location.hash) location.replace("#/chat");
shell.navigate();

// The status strip: the served model, the server's reachability and background downloads, polled lightly.
initServerStatus();

// Routes tab feature-detection: probe /dag once; hides the tab (and bounces off #/routes if already there) on 404.
// Runs after the first navigation so a direct deep link to #/routes has already rendered its section.
void initRoutesProbe();
