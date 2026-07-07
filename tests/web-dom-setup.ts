// DOM environment bootstrap for tests/web-app.test.ts (plan §7/§9 Phase 2
// test harness). MUST be imported before any src/web/src/*.ts module — some
// of them do DOM/window lookups at module scope (e.g. shell.ts's
// `window.matchMedia(...)` for the theme media query), so `document`/
// `window` need to exist as globals before those modules' top-level code
// runs, not just before individual test bodies execute.
//
// happy-dom chosen over jsdom: it installs cleanly under bun:test with no
// extra shims (verified — jsdom's usual Node-only globals patching wasn't
// needed here), and GlobalWindow is a drop-in globalThis populator.
import { GlobalWindow } from "happy-dom";

const win = new GlobalWindow({ url: "http://localhost/" }) as unknown as Window & typeof globalThis;

// Assign the properties tests/modules actually touch. happy-dom's
// GlobalWindow already patches most standard globals onto itself; we copy
// the ones this codebase uses onto Bun's real globalThis so `document`,
// `window`, etc. resolve the same way they would in a browser <script>.
Object.assign(globalThis, {
  window: win,
  document: win.document,
  navigator: win.navigator,
  location: win.location,
  localStorage: win.localStorage,
  requestAnimationFrame: win.requestAnimationFrame.bind(win),
  cancelAnimationFrame: win.cancelAnimationFrame.bind(win),
  HTMLElement: win.HTMLElement,
  HTMLButtonElement: win.HTMLButtonElement,
  HTMLInputElement: win.HTMLInputElement,
  HTMLSelectElement: win.HTMLSelectElement,
  HTMLTextAreaElement: win.HTMLTextAreaElement,
  HTMLDetailsElement: win.HTMLDetailsElement,
  Node: win.Node,
  Event: win.Event,
  KeyboardEvent: win.KeyboardEvent,
  MouseEvent: win.MouseEvent,
  CustomEvent: win.CustomEvent,
  DragEvent: win.DragEvent,
});

export { win as testWindow };
