// Browser entry, built by scripts/build-web.ts into apps/mlx-bun/dist/web/app.js, which apps/mlx-bun/src/web/assets.ts
// serves at GET /assets/app.js and app.html loads via <script defer src="/assets/app.js">.
//
// It composes the web shell (`@mlx-bun/web-shell`: navigation, routing, theme, palette chrome, panel mounting), the
// panels of the installed modules (installed-panels.ts, generated from the host's module list at build time), and the
// legacy pages that have not moved into modules yet (chat, quantize, fine-tune, dataset, status, the hub and memory
// overlays), mounted as they always were. The order below is load-bearing: controllers must be populated before
// the first navigation can dispatch to them, and the tab row's fades are computed once at start so a row that already
// overflows on load gets its mask immediately.

import {
  appKeys, initDrawer, initHfSettings, initRoutesProbe, pollIdentity, registerOverlays, shell,
} from "./shell";
import { createChatController } from "./chat";
import { createQuantizeController } from "./quantize";
import { createFinetuneController } from "./finetune";
import { createDatasetController } from "./dataset";
import { createStatusController } from "./status";
import { initModelPicker } from "./model-picker";
import { initHubPanel } from "./hub";
import { createAppPalette } from "./palette";
import { panels } from "./installed-panels";

// Hugging Face nav gear + push-to-hub modal.
initHfSettings();

// One tab and one page per installed module panel, before the shell starts so the Developer switch sees the tabs.
shell.mountPanels(panels);

// Mobile drawer (chat sidebar slide-over), the model picker popover and the Model Hub panel register their overlay
// callbacks here; the hub's open callback exists before the picker's popover is ever opened.
initDrawer();
initModelPicker();
initHubPanel();

// Command palette and the Escape overlay sweep, in priority order.
const palette = createAppPalette();
registerOverlays(palette);

// Theme, PWA service worker, shortcut sheet, global keys (Cmd/Ctrl+K, Cmd/Ctrl+/, the chat's bindings, Escape),
// hash routing and the Developer switch.
shell.start({ palette, keys: appKeys });

// Page controllers, in the original declaration order. Each init() is lazy (run on first visit to that route); only
// the factory call happens here.
shell.controllers.chat = createChatController();
shell.controllers.quantize = createQuantizeController();
shell.controllers.finetune = createFinetuneController();
shell.controllers.dataset = createDatasetController();
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
