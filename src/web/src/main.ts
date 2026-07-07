// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built by scripts/build-web.ts into src/web/app.js, which
// server.ts serves at GET /assets/app.js and app.html loads via
// <script defer src="/assets/app.js"></script>.
//
// Entrypoint: imports and initializes every module in the EXACT order the
// original monolithic inline <script> in app.html ran its top-level
// statements. This ordering is load-bearing — see the design doc
// (docs/design/web-chat-redesign.md §7) and the original file's own
// section comments for why (controllers object populated before router()
// can dispatch to it; updateTabFades() needs to run once at parse time so
// a tab row that's already overflowing on load gets its fade mask
// immediately, not just after the first scroll/resize event).

import {
  controllers, initDeveloperToggle, initDrawer, initGlobalKeydown, initHfSettings,
  initRouter, initRoutesProbe, initServiceWorker, initShortcutSheet, initTheme, pollIdentity, router,
} from "./shell";
import { createChatController } from "./chat";
import { createQuantizeController } from "./quantize";
import { createFinetuneController } from "./finetune";
import { createDatasetController } from "./dataset";
import { createStatusController } from "./status";
import { initModelPicker } from "./model-picker";
import { initHubPanel } from "./hub";
import { initPalette } from "./palette";

// — Hugging Face nav gear + push-to-hub modal (original: an IIFE right
//   after mdToHtml/markdown helpers were declared) —
initHfSettings();

// — Theme: auto/dark/light, prefers-color-scheme —
initTheme();

// — PWA service worker (plan §9 Phase 3): shell-only cache-first, guarded
//   to secure contexts / localhost. Registration is fire-and-forget and
//   never blocks boot —
initServiceWorker();

// — Keyboard shortcut sheet (Cmd/Ctrl+/) —
initShortcutSheet();

// — Mobile drawer (chat sidebar slide-over) —
initDrawer();

// — Model picker (plan §5.6/§9 Phase 2): #nav-model click -> /library popover —
initModelPicker();

// — Model Hub (plan §9 Phase 3): panel chrome + the model picker's "Browse
//   models…" entry. Registers its open callback before initModelPicker's
//   popover is ever opened, so the first click already has a live target —
//   order here doesn't actually matter (both are registered-callback
//   indirections, not direct DOM lookups), but this keeps the two model-
//   surface inits visually adjacent in the boot sequence. —
initHubPanel();

// — Command palette (plan §9 Phase 3): Cmd/Ctrl+K, registers its
//   open/close/isOpen callbacks (shell.ts's registered-callback pattern)
//   before initGlobalKeydown()'s binding below can ever fire —
initPalette();

// — Global Escape/shortcut keydown sweep (closeTopOverlay + shortcuts) —
initGlobalKeydown();

// — Router: hashchange listener + tab-fade scroll/resize listeners, and
//   run updateTabFades() once immediately (original ran it at parse time,
//   not just on first scroll/resize) —
initRouter();

// — Developer toggle (plan §8/§9 Phase 2): apply saved/first-run state to
//   the tab row before router() below reads it for the deep-link check —
initDeveloperToggle();

// — Controller registration, in the original declaration order: chat,
//   quantize, finetune, dataset, status. Each controller's own init() is
//   still lazy (invoked by router() on first visit to that route) — only
//   the outer factory call (equivalent to the original IIFE body running)
//   happens here, matching the original's controllers.chat = (() => {...})()
//   eager-closure-body / lazy-init() split exactly. —
controllers.chat = createChatController();
controllers.quantize = createQuantizeController();
controllers.finetune = createFinetuneController();
controllers.dataset = createDatasetController();
controllers.status = createStatusController();

/* ════════════════════════════════════════════════════════════════════
   BOOT
   ════════════════════════════════════════════════════════════════════ */
if (!location.hash) location.replace("#/chat");
router();
pollIdentity();
setInterval(pollIdentity, 4000);

// — Routes tab feature-detection (web-ui-pass-plan.md #17): probe /dag once;
//   hides the tab (and bounces off #/routes if already there) on 404. Runs
//   after the initial router() so a direct deep link to #/routes has
//   already rendered its section before this decides whether to keep it. —
initRoutesProbe();
