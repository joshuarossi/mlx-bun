// Browser entry, built by scripts/build-web.ts into apps/mlx-bun/dist/web/app.js, which apps/mlx-bun/src/web/assets.ts
// serves at GET /assets/app.js and app.html loads via <script defer src="/assets/app.js">.
//
// It composes the web shell (`@mlx-bun/web-shell`: navigation, routing, theme, palette chrome, panel mounting), the
// panels of the installed modules (installed-panels.ts, generated from the host's module list at build time: the chat
// is one, the workspace the shell opens on) and the legacy pages that have not moved into modules yet (quantize,
// fine-tune, dataset, status and memory overlays), mounted as they always were. The order below is load-bearing: controllers must be populated before
// the first navigation can dispatch to them, and the tab row's fades are computed once at start so a row that already
// overflows on load gets its mask immediately.

import {
  appKeys, mountPanels, initDrawer, initHfSettings, initModelLink, initRoutesProbe, pollIdentity, registerOverlays, shell,
} from "./shell";
import { registerMemoryOverlay } from "./memory-panel";
import { chatHost } from "./chat-host";
import { createStatusController } from "./status";
import { createAppPalette } from "./palette";
import { panels } from "./installed-panels";

// Hugging Face nav gear + push-to-hub modal.
initHfSettings();

// One tab and one page per installed module panel, before the shell starts so the Developer switch sees the tabs. The
// chat panel is handed its host side (chat-host.ts): memory's chips and sidebar entry, the agent-tools settings.
mountPanels(panels.map(panel => panel.tag === "mlx-chat-panel" ? { ...panel, properties: { host: chatHost } } : panel));

registerMemoryOverlay();

// The mobile drawer delegates to chat; the model label opens the Models panel.
initDrawer();
initModelLink();

// Command palette and the Escape overlay sweep, in priority order.
const palette = createAppPalette();
registerOverlays(palette);

// Theme, PWA service worker, shortcut sheet, global keys (Cmd/Ctrl+K, Cmd/Ctrl+/, the chat's bindings, Escape),
// hash routing and the Developer switch.
shell.start({ palette, keys: appKeys });

// Page controllers, in the original declaration order. Each init() is lazy (run on first visit to that route); only
// the factory call happens here. The chat is not one: its panel initializes itself when the shell first shows it.
shell.controllers.status = createStatusController();

/* ════════════════════════════════════════════════════════════════════
   BOOT
   ════════════════════════════════════════════════════════════════════ */
if (!location.hash) location.replace("#/chat");
shell.navigate();
pollIdentity();
setInterval(pollIdentity, 4000);

// Routes tab feature-detection: probe /dag once; hides the tab (and bounces off #/routes if already there) on 404.
// Runs after the first navigation so a direct deep link to #/routes has already rendered its section.
initRoutesProbe();
