// Browser entry, built by scripts/build-web.ts into apps/mlx-bun/dist/web/app.js, which apps/mlx-bun/src/web/assets.ts
// serves at GET /assets/app.js and app.html loads via <script defer src="/assets/app.js">.
//
// It composes the web shell (`@mlx-bun/web-shell`: navigation, routing, theme, palette chrome, panel mounting), the
// panels of the installed modules (installed-panels.ts, generated from the host's module list at build time), and the
// legacy pages that have not moved into modules yet (chat, status, the memory overlay),
// mounted as they always were. The order below is load-bearing: controllers must be populated before
// the first navigation can dispatch to them, and the tab row's fades are computed once at start so a row that already
// overflows on load gets its mask immediately.

import {
  appKeys, mountPanels, initDrawer, initHfSettings, initModelLink, initRoutesProbe, pollIdentity, registerOverlays, shell,
} from "./shell";
import { createChatController } from "./chat";
import { createStatusController } from "./status";
import { createAppPalette } from "./palette";
import { panels } from "./installed-panels";

// Hugging Face nav gear + push-to-hub modal.
initHfSettings();

// One tab and one page per installed module panel, before the shell starts so the Developer switch sees the tabs.
mountPanels(panels);

// Mobile drawer (chat sidebar slide-over) registers its overlay callbacks here; the nav's model label opens the Models panel.
initDrawer();
initModelLink();

// Command palette and the Escape overlay sweep, in priority order.
const palette = createAppPalette();
registerOverlays(palette);

// Theme, PWA service worker, shortcut sheet, global keys (Cmd/Ctrl+K, Cmd/Ctrl+/, the chat's bindings, Escape),
// hash routing and the Developer switch.
shell.start({ palette, keys: appKeys });

// Page controllers, in the original declaration order. Each init() is lazy (run on first visit to that route); only
// the factory call happens here.
shell.controllers.chat = createChatController();
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
