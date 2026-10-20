// A scripted walk through the browser app in headless Chromium, over the Chrome DevTools protocol and the model-free
// fake backend: every route at a desktop and a phone width, keyboard order, the palette and the overlays, the Models
// actions, each wizard end to end, the live streams, the chat's stream, Stop, failure and approval paths, going offline
// and recovering, then the failing and the empty scenarios. It records a pass or fail per check with console errors and
// page exceptions, writes a report and screenshots, and exits non-zero when a check fails. Nothing here loads a model.
//
//   bun apps/mlx-bun/scripts/web-walk.ts [--chromium <path>] [--out <dir>]
//
// Chromium comes from --chromium, $CHROMIUM, Playwright's install, or Google Chrome on a Mac. The report lands in
// <out>/report.md (default apps/mlx-bun/dist/web-walk) beside the screenshots.
import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { mkdir } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { createWebHandler } from "../src/web/assets";
import { buildWebBundle, OUTFILE } from "../src/web/build";
import { startFakeBackend } from "../tests/web/fake-backend";

const argv = process.argv.slice(2);
if (argv.includes("--help") || argv.includes("-h")) {
  console.log("Usage: bun apps/mlx-bun/scripts/web-walk.ts [--chromium <path>] [--out <dir>]\n\nDrives the browser app in headless Chromium over the fake backend and reports every UI check. No model loads.");
  process.exit(0);
}
const opt = (name: string) => { const i = argv.indexOf(name); return i >= 0 ? argv[i + 1] : undefined; };
const CANDIDATES = [opt("--chromium"), process.env.CHROMIUM, "/opt/pw-browsers/chromium", `${process.env.HOME}/Library/Caches/ms-playwright/chromium/chrome-mac/Chromium.app/Contents/MacOS/Chromium`,
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "/Applications/Chromium.app/Contents/MacOS/Chromium", "/usr/bin/chromium", "/usr/bin/google-chrome"];
const chromium = CANDIDATES.find((path): path is string => !!path && existsSync(path));
if (!chromium) throw new Error("No Chromium found; pass --chromium <path> or set CHROMIUM");
const OUT = resolve(opt("--out") ?? resolve(import.meta.dir, "../dist/web-walk"));
await mkdir(OUT, { recursive: true });

await mkdir(dirname(OUTFILE), { recursive: true });
await Bun.write(OUTFILE, await buildWebBundle());
const web = await createWebHandler();
const backends = {
  default: startFakeBackend({ scenario: "default", web }),
  failing: startFakeBackend({ scenario: "failing", web }),
  empty: startFakeBackend({ scenario: "empty", web }),
};
const base = backends.default.url, failingBase = backends.failing.url, emptyBase = backends.empty.url;

const ROUTES = ["chat", "models", "quantize", "finetune", "dataset", "benchmarks", "metrics", "status"];
const port = 9400 + Math.floor(Math.random() * 400);
const profile = `${OUT}/.chromium-profile-${process.pid}`;
const chrome = spawn(chromium, ["--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars", `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`, "about:blank"], { stdio: "ignore" });
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function version(): Promise<{ webSocketDebuggerUrl: string }> {
  for (let i = 0; i < 50; i++) { try { return await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); } catch { await sleep(200); } }
  throw new Error("chromium did not start");
}

class Cdp {
  #id = 0; #pending = new Map<number, (v: any) => void>(); #handlers = new Map<string, ((params: any, sessionId?: string) => void)[]>(); ws: WebSocket;
  constructor(url: string) {
    this.ws = new WebSocket(url);
    this.ws.onmessage = (e) => {
      const m = JSON.parse(String(e.data));
      if (m.id && this.#pending.has(m.id)) { this.#pending.get(m.id)!(m); this.#pending.delete(m.id); }
      else if (m.method) for (const h of this.#handlers.get(m.method) ?? []) h(m.params, m.sessionId);
    };
  }
  open() { return new Promise<void>((r) => { this.ws.onopen = () => r(); }); }
  on(method: string, handler: (params: any, sessionId?: string) => void) { this.#handlers.set(method, [...(this.#handlers.get(method) ?? []), handler]); }
  send(method: string, params: any = {}, sessionId?: string): Promise<any> {
    const id = ++this.#id;
    return new Promise((resolve, reject) => {
      this.#pending.set(id, (m) => m.error ? reject(new Error(`${method}: ${JSON.stringify(m.error)}`)) : resolve(m.result));
      this.ws.send(JSON.stringify({ id, method, params, ...(sessionId ? { sessionId } : {}) }));
    });
  }
}

const HELPERS = `
window.__q = (sel) => { let root = document, el = null; for (const part of sel.split('>>>').map(s => s.trim())) { el = root.querySelector(part); if (!el) return null; root = el.shadowRoot || el; } return el; };
window.__qa = (sel) => { const parts = sel.split('>>>').map(s => s.trim()); const last = parts.pop(); let root = document; for (const part of parts) { const el = root.querySelector(part); if (!el) return []; root = el.shadowRoot || el; } return [...root.querySelectorAll(last)]; };
window.__vis = (sel) => { const el = typeof sel === 'string' ? window.__q(sel) : sel; if (!el) return false; const r = el.getBoundingClientRect(); return r.width > 0 && r.height > 0 && getComputedStyle(el).visibility !== 'hidden'; };
window.__text = (sel) => { const el = window.__q(sel); return el ? (el.textContent || '').replace(/\\s+/g, ' ').trim() : null; };
window.__active = () => { let a = document.activeElement; while (a && a.shadowRoot && a.shadowRoot.activeElement) a = a.shadowRoot.activeElement; return a; };
window.__focus = () => { const a = window.__active(); if (!a || a === document.body) return { tag: 'BODY', id: '', name: '', ring: false };
  const cs = getComputedStyle(a); const name = a.getAttribute('aria-label') || a.getAttribute('title') || (a.labels && a.labels[0] && a.labels[0].textContent) || a.placeholder || (a.textContent || '').replace(/\\s+/g, ' ').trim();
  return { tag: a.tagName, id: a.id, cls: String(a.className).slice(0, 40), name: String(name || '').slice(0, 40), ring: (cs.outlineStyle !== 'none' && parseFloat(cs.outlineWidth) > 0) || (cs.boxShadow !== 'none' && cs.boxShadow.includes('px')) }; };
window.__overflow = () => Math.max(document.documentElement.scrollWidth, document.body.scrollWidth) - window.innerWidth;
window.__hash = () => location.hash;
window.__deepText = (sel) => { const s = window.__q(sel); if (!s) return ''; let t = s.textContent || ''; for (const el of s.querySelectorAll('*')) if (el.shadowRoot) t += ' ' + (el.shadowRoot.textContent || ''); return t.replace(/\s+/g, ' ').trim(); };
`;

interface Check { scope: string; name: string; ok: boolean; detail?: string }
const checks: Check[] = [];
let scope = "";
const check = (name: string, ok: boolean, detail = "") => { checks.push({ scope, name, ok, detail }); console.log(`${ok ? "  ok " : "FAIL "} [${scope}] ${name}${detail ? ` — ${detail}` : ""}`); return ok; };

const KEYS: Record<string, { code: string; vk: number; text?: string }> = {
  Tab: { code: "Tab", vk: 9 }, Enter: { code: "Enter", vk: 13, text: "\r" }, Escape: { code: "Escape", vk: 27 }, " ": { code: "Space", vk: 32, text: " " },
  ArrowDown: { code: "ArrowDown", vk: 40 }, ArrowUp: { code: "ArrowUp", vk: 38 }, k: { code: "KeyK", vk: 75 }, "/": { code: "Slash", vk: 191 }, o: { code: "KeyO", vk: 79 }, c: { code: "KeyC", vk: 67 },
};

class Page {
  errors: string[] = [];
  constructor(readonly cdp: Cdp, readonly session: string, readonly width: number, readonly tag: string) {}
  static async open(cdp: Cdp, width: number, height: number, tag: string): Promise<Page> {
    const { targetId } = await cdp.send("Target.createTarget", { url: "about:blank", width, height, newWindow: true });
    const { sessionId } = await cdp.send("Target.attachToTarget", { targetId, flatten: true });
    const page = new Page(cdp, sessionId, width, tag);
    await cdp.send("Page.enable", {}, sessionId);
    await cdp.send("Runtime.enable", {}, sessionId);
    await cdp.send("Network.enable", {}, sessionId);
    await cdp.send("Emulation.setDeviceMetricsOverride", { width, height, deviceScaleFactor: 1, mobile: width < 600 }, sessionId);
    await cdp.send("Page.addScriptToEvaluateOnNewDocument", { source: HELPERS }, sessionId);
    cdp.on("Runtime.consoleAPICalled", (p, s) => { if (s === sessionId && (p.type === "error" || p.type === "warning")) page.errors.push(`${p.type}: ${(p.args ?? []).map((a: any) => a.value ?? a.description ?? "").join(" ").slice(0, 200)}`); });
    cdp.on("Runtime.exceptionThrown", (p, s) => { if (s === sessionId) page.errors.push(`exception: ${(p.exceptionDetails?.exception?.description ?? p.exceptionDetails?.text ?? "").slice(0, 200)}`); });
    return page;
  }
  async eval<T = any>(expression: string): Promise<T> {
    const r = await this.cdp.send("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true }, this.session);
    if (r.exceptionDetails) throw new Error(`eval failed: ${r.exceptionDetails.exception?.description ?? r.exceptionDetails.text} in ${expression.slice(0, 80)}`);
    return r.result.value as T;
  }
  async goto(url: string) { await this.cdp.send("Page.navigate", { url }, this.session); await this.waitFor("document.readyState === 'complete' && !!window.__q", 10000); await this.eval(HELPERS + "true"); await sleep(400); }
  async waitFor(expression: string, timeout = 6000, step = 100): Promise<boolean> {
    const until = Date.now() + timeout;
    while (Date.now() < until) { try { if (await this.eval(`!!(${expression})`)) return true; } catch {} await sleep(step); }
    return false;
  }
  vis(sel: string) { return this.eval<boolean>(`window.__vis(${JSON.stringify(sel)})`); }
  text(sel: string) { return this.eval<string | null>(`window.__text(${JSON.stringify(sel)})`); }
  count(sel: string) { return this.eval<number>(`window.__qa(${JSON.stringify(sel)}).length`); }
  async click(sel: string) { const ok = await this.eval<boolean>(`(() => { const el = window.__q(${JSON.stringify(sel)}); if (!el) return false; el.scrollIntoView({ block: 'center' }); if (el.tabIndex >= 0 && typeof el.focus === 'function') el.focus(); el.click(); return true; })()`); if (!ok) throw new Error(`no element ${sel}`); await sleep(80); }
  async focus(sel: string) { const ok = await this.eval<boolean>(`(() => { const el = window.__q(${JSON.stringify(sel)}); if (!el) return false; el.focus(); return true; })()`); if (!ok) throw new Error(`no element ${sel}`); }
  async type(text: string) { await this.cdp.send("Input.insertText", { text }, this.session); await sleep(60); }
  async key(key: string, mods: { ctrl?: boolean; shift?: boolean } = {}) {
    const k = KEYS[key] ?? { code: key, vk: key.toUpperCase().charCodeAt(0) };
    const modifiers = (mods.ctrl ? 2 : 0) | (mods.shift ? 8 : 0);
    await this.cdp.send("Input.dispatchKeyEvent", { type: "keyDown", key, code: k.code, windowsVirtualKeyCode: k.vk, modifiers, ...(k.text && !mods.ctrl ? { text: k.text } : {}) }, this.session);
    await this.cdp.send("Input.dispatchKeyEvent", { type: "keyUp", key, code: k.code, windowsVirtualKeyCode: k.vk, modifiers }, this.session);
    await sleep(80);
  }
  focused() { return this.eval<{ tag: string; id: string; name: string; ring: boolean; cls?: string }>("window.__focus()"); }
  overflow() { return this.eval<number>("window.__overflow()"); }
  async shot(name: string) { const { data } = await this.cdp.send("Page.captureScreenshot", { format: "png" }, this.session); await Bun.write(`${OUT}/${this.tag}-${name}-${this.width}.png`, Buffer.from(data, "base64")); }
  async offline(on: boolean) { await this.cdp.send("Network.emulateNetworkConditions", { offline: on, latency: 0, downloadThroughput: -1, uploadThroughput: -1 }, this.session); }
  /** Opens the sheet first on a phone, then clicks the rail control. */
  async rail(sel: string) {
    if (this.width < 600 && !(await this.eval<boolean>("document.getElementById('nav').classList.contains('open')"))) { await this.click("#nav-menu"); await this.waitFor("document.getElementById('nav').classList.contains('open')", 2000); await sleep(150); }
    await this.click(sel);
  }
  async go(route: string) { await this.rail(`a.tab[data-tab="${route}"]`); await this.waitFor(`location.hash === '#/${route}'`, 2000); await sleep(300); }
  takeErrors(): string[] { const e = this.errors.splice(0); return e; }
}

async function step(name: string, fn: () => Promise<void>) {
  scope = name;
  try { await fn(); } catch (error) { check("step completed", false, String(error).slice(0, 200)); }
}

// ───────────────────────────── the default scenario ─────────────────────────────
async function walkDefault(page: Page) {
  const W = page.width, phone = W < 600;
  await step(`boot ${W}`, async () => {
    await page.goto(`${base}/#/chat`);
    await page.waitFor("(window.__text('#nav-model') || '').length > 0 && !/No model|unreachable/.test(window.__text('#nav-model'))", 8000);
    check("chat page shown", await page.vis('section[data-route="chat"]'));
    check("status strip names the served model", /Qwen3\.8/.test(await page.text("#nav-model") ?? ""), await page.text("#nav-model") ?? "");
    check("status strip says online", /^Online/.test(await page.text("#nav-conn-text") ?? ""), await page.text("#nav-conn-text") ?? "");
    check("download in flight is shown", /Downloading/.test(await page.text("#nav-download-text") ?? ""), await page.text("#nav-download-text") ?? "");
    check(phone ? "top bar shown, rail hidden" : "rail shown, top bar hidden", phone ? (await page.vis("#topbar") && !(await page.vis("#nav"))) : (await page.vis("#nav") && !(await page.vis("#topbar"))));
    check("no horizontal overflow", (await page.overflow()) <= 0, `${await page.overflow()}px`);
    await sleep(800);
    await page.shot("boot");
    const errors = page.takeErrors();
    check("no console errors at boot", errors.length === 0, errors.slice(0, 3).join(" | "));
  });

  await step(`routes ${W}`, async () => {
    for (const route of ROUTES) {
      await page.go(route);
      const shown = await page.vis(`section[data-route="${route}"]`);
      const current = await page.eval<string | null>(`(window.__q('a.tab[data-tab="${route}"]') || {getAttribute(){return null}}).getAttribute('aria-current')`);
      const closed = phone ? !(await page.eval<boolean>("document.getElementById('nav').classList.contains('open')")) : true;
      await sleep(route === "chat" ? 300 : 900);
      const overflow = await page.overflow();
      const words = (await page.eval<string>(`window.__deepText('section[data-route="${route}"]')`)).length;
      check(`${route}: page shown, tab current, sheet closed, content, no overflow`, shown && current === "page" && closed && overflow <= 0 && words > 20,
        `shown=${shown} aria-current=${current} closed=${closed} overflow=${overflow}px text=${words}ch`);
      await page.shot(route);
    }
    const errors = page.takeErrors();
    check("no console errors across routes", errors.length === 0, errors.slice(0, 3).join(" | "));
  });

  await step(`keyboard ${W}`, async () => {
    await page.go("models");
    await page.focus(phone ? "#nav-menu" : "#nav .tab");
    const seen: string[] = [];
    const record = async () => { const f = await page.focused(); seen.push(`${f.tag.toLowerCase()}${f.id ? "#" + f.id : ""}:${f.name || "(unnamed)"}${f.ring ? "" : " !ring"}`); };
    await record();
    for (let i = 0; i < 9; i++) { await page.key("Tab"); await record(); }
    const unnamed = seen.filter((s) => s.includes("(unnamed)") && !s.startsWith("body:"));
    check("every focus stop has an accessible name", unnamed.length === 0, seen.join(" → "));
    if (phone) check("the closed rail's tabs are out of the tab order", !seen.slice(1).some((s) => /^a:(Chat|Models|Quantize|Fine-tune|Build Dataset|Benchmarks|Metrics|Status)$/.test(s.replace(/ !ring$/, ""))), seen.join(" → "));
    else check("tab order runs down the rail's tabs", seen.slice(0, 4).every((s) => s.startsWith("a:")), seen.slice(0, 4).join(" → "));
    const rings = seen.filter((s) => s.includes("!ring") && !s.startsWith("body:"));
    check("keyboard focus is visible on every stop", rings.length === 0, rings.join(", "));
    if (phone) {
      // The open sheet is a dialog: Tab after its last control and Shift+Tab before its first stay inside it.
      await page.click("#nav-menu");
      await page.waitFor("document.getElementById('nav').classList.contains('open')", 2000);
      await sleep(150);
      const inside = () => page.eval<boolean>("document.getElementById('nav').contains(window.__active())");
      await page.eval("(() => { const items = [...document.querySelectorAll('#nav a[href], #nav button:not([disabled])')]; items[items.length - 1].focus(); })()");
      await page.key("Tab");
      check("Tab from the sheet's last control stays inside the sheet", await inside(), JSON.stringify(await page.focused()));
      await page.eval("document.querySelector('#nav .tab').focus()");
      await page.key("Tab", { shift: true });
      check("Shift+Tab from the sheet's first control stays inside the sheet", await inside(), JSON.stringify(await page.focused()));
      await page.key("Escape");
      check("Escape closes the sheet and focus returns to the menu button", await page.waitFor("!document.getElementById('nav').classList.contains('open')", 1500) && (await page.focused()).id === "nav-menu", JSON.stringify(await page.focused()));
    }
  });

  await step(`palette ${W}`, async () => {
    await page.go("models");
    await page.key("k", { ctrl: true });
    check("Ctrl+K opens the palette", await page.waitFor("window.__vis('#palette-overlay')", 2000));
    check("the palette input has focus", (await page.focused()).id === "palette-input");
    await page.type("open status");
    await sleep(400);
    const active = await page.text("#palette-overlay .palette-row.active");
    await page.key("Enter");
    check("Enter runs the matched command (Open Status)", await page.waitFor("location.hash === '#/status' && !window.__vis('#palette-overlay')", 2500), `active row: ${active} → ${await page.eval("location.hash")}`);
    await page.key("k", { ctrl: true });
    await page.waitFor("window.__vis('#palette-overlay')", 2000);
    await page.key("Escape");
    check("Escape closes the palette", await page.waitFor("!window.__vis('#palette-overlay')", 2000));
  });

  await step(`shortcuts ${W}`, async () => {
    await page.key("/", { ctrl: true });
    check("Ctrl+/ opens the shortcut sheet", await page.waitFor("window.__vis('#shortcut-overlay')", 2000));
    await page.key("Escape");
    check("Escape closes the shortcut sheet", await page.waitFor("!window.__vis('#shortcut-overlay')", 2000));
  });

  await step(`settings ${W}`, async () => {
    await page.go("models");
    await page.rail("#nav-settings");
    check("Settings opens as a dialog", await page.waitFor("window.__vis('#settings-dialog')", 2000));
    await sleep(120);
    check("focus moves into the dialog", (await page.focused()).id === "settings-close", JSON.stringify(await page.focused()));
    await page.click('#theme-toggle [data-theme-choice="dark"]');
    check("dark theme applies", await page.waitFor("document.documentElement.dataset.theme === 'dark'", 1000));
    await sleep(300);
    check("the chosen theme reads as pressed and looks different from the others", await page.eval<boolean>(`(() => { const dark = window.__q('#theme-toggle [data-theme-choice="dark"]'), light = window.__q('#theme-toggle [data-theme-choice="light"]');
      return dark.getAttribute('aria-pressed') === 'true' && light.getAttribute('aria-pressed') === 'false' && getComputedStyle(dark).backgroundColor !== getComputedStyle(light).backgroundColor; })()`));
    await page.shot("settings-dark");
    await page.click('#theme-toggle [data-theme-choice="light"]');
    check("light theme applies", await page.waitFor("document.documentElement.dataset.theme === 'light'", 1000));
    check("the Hugging Face token state is shown", ((await page.text("#hf-state")) ?? "").length > 0, await page.text("#hf-state") ?? "");
    await page.key("Escape");
    check("Escape closes Settings", await page.waitFor("!window.__vis('#settings-dialog')", 2000));
    const f = await page.focused();
    check("focus returns to the Settings control", f.id === "nav-settings" || (phone && f.id === "nav-menu"), JSON.stringify(f));
  });

  await step(`developer switch ${W}`, async () => {
    await page.rail("#nav-developer");
    check("switching developer tools off hides the Tools group", await page.waitFor("!window.__vis('a.tab[data-tab=\"status\"]') && !window.__vis('#tabs-tools')", 1500));
    await page.click("#nav-developer");
    check("switching it on shows them again", await page.waitFor("window.__vis('a.tab[data-tab=\"status\"]')", 1500));
    if (phone) { await page.key("Escape"); await page.waitFor("!document.getElementById('nav').classList.contains('open')", 1500); }
  });

  await step(`models ${W}`, async () => {
    await page.go("models");
    const P = "mlx-models-panel >>> ";
    check("downloaded models listed", await page.waitFor(`window.__qa('${P}#local .list-row').length > 1`, 5000), `${await page.count(P + "#local .list-row")} rows`);
    check("the serving block names the model", /Qwen3\.8/.test(await page.text(P + "#serving") ?? ""));
    await page.focus(P + "#query");
    await page.type("qwen");
    check("search shows Hub results", await page.waitFor(`window.__qa('${P}#results .hub-row').length > 0`, 5000), `${await page.count(P + "#results .hub-row")} results`);
    await page.click(P + "#results .hub-download-btn");
    check("Download starts and shows progress", await page.waitFor(`/downloading|preparing|%/.test(window.__text('${P}#results .hub-dl-tag') || '')`, 4000), await page.text(P + "#results .hub-dl-tag") ?? "");
    const before = await page.text(P + "#serving");
    await page.click(P + "#local .hub-serve-btn");
    const changed = await page.waitFor(`(window.__text('${P}#serving') || '') !== ${JSON.stringify(before)} || (window.__text('${P}#status') || '').length > 0`, 6000);
    check("Serve answers (serving block or status notice changes)", changed, (await page.text(P + "#status") ?? "").slice(0, 80));
    await page.shot("models-after-actions");
    const errors = page.takeErrors();
    check("no console errors on Models", errors.length === 0, errors.slice(0, 3).join(" | "));
  });

  await step(`quantize ${W}`, async () => {
    await page.go("quantize");
    const P = "mlx-quantize-panel >>> ";
    await page.focus(P + "#q-model");
    await page.type("mlx-community/Qwen3-8B-bf16");
    await page.click(P + "#q-inspect");
    check("Inspect offers Continue for a supported model", await page.waitFor(`window.__vis('${P}#q-continue')`, 4000));
    await page.click(P + "#q-continue");
    check("Configure step shown", await page.waitFor(`window.__vis('${P}[data-qstep="1"]')`, 2000));
    await page.shot("quantize-configure");
    await page.click(P + "#q-submit");
    check("Run step shown with a live log", await page.waitFor(`window.__vis('${P}[data-qstep="2"]') && (window.__text('${P}#q-log') || '').length > 0`, 5000));
    await page.shot("quantize-run");
    check("the job finishes on the Done step with an output path", await page.waitFor(`window.__vis('${P}[data-qstep="3"]') && (window.__text('${P}#q-out') || '').length > 0`, 20000), await page.text(P + "#q-out") ?? "");
    check("the step rail marks Done current", (await page.text(P + "#q-steps .step.current") ?? "") === "4 Done" || /Done/.test(await page.text(P + "#q-steps .step.current") ?? ""), await page.text(P + "#q-steps .step.current") ?? "");
    await page.shot("quantize-done");
  });

  await step(`finetune ${W}`, async () => {
    await page.go("finetune");
    const P = "mlx-train-panel >>> ";
    await page.focus(P + "#f-model");
    await page.type("mlx-community/Qwen3-8B-4bit");
    await page.click(P + "#f-next0");
    check("Dataset step shown", await page.waitFor(`window.__vis('${P}[data-fstep="1"]')`, 2000));
    await page.focus(P + "#f-data");
    await page.type("/Users/josh/data/support-tone");
    await page.click(P + "#f-inspect");
    check("inspecting the dataset enables Continue", await page.waitFor(`!window.__q('${P}#f-next1').disabled`, 4000), await page.text(P + "#f-inspect-out") ?? "");
    await page.click(P + "#f-next1");
    check("Hyperparameters step shown", await page.waitFor(`window.__vis('${P}[data-fstep="2"]')`, 2000));
    await page.shot("finetune-hyper");
    await page.click(P + "#f-submit");
    check("Train step shown with the loss chart filling", await page.waitFor(`window.__vis('${P}[data-fstep="3"]') && window.__qa('${P}#f-chart path').length > 0`, 8000));
    await page.shot("finetune-train");
    check("training finishes on the Done step", await page.waitFor(`window.__vis('${P}[data-fstep="4"]')`, 20000), await page.text(P + "#f-out") ?? "");
    await page.shot("finetune-done");
  });

  await step(`dataset ${W}`, async () => {
    await page.go("dataset");
    const P = "mlx-datasets-panel >>> ";
    check("templates load as buttons", await page.waitFor(`window.__qa('${P}#d-templates button.tpl').length > 2`, 5000), `${await page.count(P + "#d-templates button.tpl")} templates`);
    await page.click(P + "#d-templates button.tpl");
    check("Inputs step shown with its form", await page.waitFor(`window.__vis('${P}[data-dstep="1"]') && window.__qa('${P}#d-form textarea, #d-form input').length > 0`, 2000));
    await page.shot("dataset-inputs");
    await page.click(P + "#d-submit");
    check("Generate step shown with a live log", await page.waitFor(`window.__vis('${P}[data-dstep="2"]') && (window.__text('${P}#d-log') || '').length > 0`, 6000), await page.text(P + "#d-submit-out") ?? "");
    check("generation finishes on the Done step", await page.waitFor(`window.__vis('${P}[data-dstep="3"]')`, 20000), await page.text(P + "#d-out") ?? "");
    await page.shot("dataset-done");
  });

  await step(`benchmarks ${W}`, async () => {
    await page.go("benchmarks");
    const P = "mlx-benchmarks-panel >>> ";
    check("tasks listed", await page.waitFor(`window.__qa('${P}.task input').length > 1`, 5000));
    check("Run is disabled until a task is chosen", await page.eval<boolean>(`window.__q('${P}.evaluate .btn.primary').disabled`));
    await page.click(P + ".task input:not([disabled])");
    check("choosing a task enables Run", await page.waitFor(`!window.__q('${P}.evaluate .btn.primary').disabled`, 1000));
    check("a missing dataset is explained on its task", /Dataset missing/.test(await page.text(P + ".task.unavailable .hint") ?? ""));
    check("history and Compare are shown", (await page.count(P + ".table tbody tr")) > 0 && await page.vis(P + "#base"));
  });

  await step(`metrics ${W}`, async () => {
    await page.go("metrics");
    const P = "mlx-metrics-panel >>> ";
    check("the stream fills the stat cards", await page.waitFor(`window.__qa('${P}.stat b').length >= 4 && /tok\\/s/.test(window.__text('${P}.stat') || '')`, 6000), await page.text(P + ".stat") ?? "");
    check("the sparkline is drawn", (await page.count(P + ".spark svg polyline")) === 1);
    check("models, caches and timings are listed", (await page.count(P + ".table tbody tr")) >= 4 && (await page.count(P + ".meter")) >= 1);
    check("a benchmark plan can be run", await page.vis(P + ".bench-controls .btn.primary"));
  });

  await step(`status ${W}`, async () => {
    await page.go("status");
    check("the status page fills from the server", await page.waitFor("/Qwen/.test(window.__text('#st-model-id') || '') && (window.__text('#st-tps') || '').length > 0", 6000), `${await page.text("#st-model-id")} · ${await page.text("#st-tps")}`);
  });

  await step(`memory ${W}`, async () => {
    await page.go("chat");
    if (phone) { await page.click("#chat-hamburger"); await sleep(300); }
    await page.click("#chat-memory-entry");
    check("the memory drawer opens", await page.waitFor("window.__vis('#mem-panel')", 2000));
    await sleep(150);
    check("focus lands in the drawer's search", (await page.focused()).id === "mem-search", JSON.stringify(await page.focused()));
    check("articles and references are listed", (await page.count("#mem-body .mem-art")) >= 5);
    await page.click("#mem-body .mem-art");
    check("an article opens with Back", await page.waitFor("window.__vis('#mem-back') && (window.__text('.mem-article-render') || '').length > 40", 3000));
    await page.shot("memory-article");
    await page.key("Escape");
    check("Escape closes the drawer", await page.waitFor("!window.__vis('#mem-panel')", 2000));
    const f = await page.focused();
    check("focus returns to the memory entry", f.id === "chat-memory-entry", JSON.stringify(f));
    if (phone) { await page.key("Escape"); await sleep(200); }
  });

  await step(`chat ${W}`, async () => {
    await page.go("chat");
    await page.waitFor("window.__q('#chat-box') && !window.__q('#chat-box').disabled", 4000);
    const turns = () => page.count("#chat-thread .turn, #chat-thread .msg, #chat-thread [data-role]");
    const before = await turns();
    await page.focus("#chat-box");
    await page.type("Hello from the walkthrough");
    await page.key("Enter");
    check("Enter sends the prompt and the user turn appears", await page.waitFor(`/Hello from the walkthrough/.test(window.__text('#chat-thread') || '')`, 3000));
    check("Stop is offered while the reply streams", await page.waitFor("window.__vis('#chat-stop')", 3000));
    check("the reply finishes: Stop hidden, composer enabled", await page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled && (window.__q('#chat-send') ? !window.__q('#chat-send').disabled : true)", 25000));
    check("an assistant turn was added", (await turns()) >= before + 2, `${before} → ${await turns()}`);
    await page.shot("chat-reply");
    await page.focus("#chat-box");
    await page.type("/slow please");
    await page.key("Enter");
    check("a long reply streams", await page.waitFor("window.__vis('#chat-stop')", 3000));
    await sleep(900);
    await page.click("#chat-stop");
    check("Stop ends the stream and the composer is usable again", await page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 5000));
    check("no stale streaming state is left", !(await page.eval<boolean>("!!document.querySelector('#chat-thread .streaming, #chat-thread .typing, #chat-thread [aria-busy=\"true\"]')")));
    await page.focus("#chat-box");
    await page.type("/fail now");
    await page.key("Enter");
    check("an upstream failure shows an error notice in the thread", await page.waitFor("window.__vis('#chat-thread .notice.bad')", 10000));
    check("after the failure the composer is usable", await page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 5000));
    await page.shot("chat-error");
    await page.focus("#chat-box");
    await page.type("please approve this");
    await page.key("Enter");
    const approval = await page.waitFor("window.__qa('#chat-thread button').some(b => /^(Allow|Approve|Run|Yes)/i.test(b.textContent.trim()))", 10000);
    check("a tool approval card asks before running", approval);
    if (approval) {
      await page.eval("window.__qa('#chat-thread button').find(b => /^(Allow|Approve|Run|Yes)/i.test(b.textContent.trim())).click()");
      check("approving continues the turn to its end", await page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 25000));
    }
    await page.shot("chat-approved");
    const errors = page.takeErrors();
    check("no console errors in the chat", errors.length === 0, errors.slice(0, 3).join(" | "));
  });

  await step(`agent ${W}`, async () => {
    // The app-aware agent: the fake backend answers these prompts with the same frames the real tools send.
    await page.go("chat");
    await page.waitFor("window.__q('#chat-box') && !window.__q('#chat-box').disabled", 4000);
    const finished = () => page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 20000);
    const ask = async (text: string) => { await page.focus("#chat-box"); await page.type(text); await page.key("Enter"); };
    // The wizard sits on Done from the earlier steps: a hidden field cannot be pointed at, so start it over first.
    if (await page.vis('mlx-quantize-panel >>> #q-again')) { await page.go("quantize"); await page.click("mlx-quantize-panel >>> #q-again"); await page.go("chat"); }
    await ask("take me to quantize and show me where to start");
    check("the agent navigates to the page it was asked for", await page.waitFor("location.hash === '#/quantize'", 5000), await page.eval("location.hash"));
    check("and highlights where to start, with its hint", await page.waitFor("window.__vis('#assistant-spotlight') && document.getElementById('assistant-spotlight').classList.contains('show') && /Start here/.test(window.__text('#assistant-spotlight .asr-pop-text') || '')", 6000), await page.text("#assistant-spotlight .asr-pop-text") ?? "");
    await page.shot("agent-navigate");
    await page.go("chat");
    await finished();
    await ask("what am I looking at?");
    check("the agent answers from the page's context: the page and its controls", await page.waitFor("/looking at .*chat.* page/i.test(window.__text('#chat-thread') || '') && /controls, such as/.test(window.__text('#chat-thread') || '')", 15000));
    await finished();
    await ask("highlight the model picker");
    check("the agent highlights a control by its spotlight id", await page.waitFor("document.getElementById('assistant-spotlight')?.classList.contains('show') && /served model/i.test(window.__text('#assistant-spotlight .asr-pop-text') || '')", 6000), await page.text("#assistant-spotlight .asr-pop-text") ?? "");
    await page.shot("agent-spotlight");
    await finished();
  });

  if (!phone) await step(`offline ${W}`, async () => {
    await page.go("chat");
    await page.offline(true);
    check("losing the server shows in the status strip", await page.waitFor("/unreachable/i.test(window.__text('#nav-conn-text') || '')", 12000), await page.text("#nav-conn-text") ?? "");
    await sleep(500);
    await page.shot("offline");
    await page.offline(false);
    check("recovery shows Online again", await page.waitFor("/^Online/.test(window.__text('#nav-conn-text') || '')", 12000), await page.text("#nav-conn-text") ?? "");
    check("the chat socket reconnects", await page.waitFor("/connected|ready/i.test(window.__text('#chat-status-line') || '') || (window.__q('#chat-conn-dot') && /ok|on|live/.test(window.__q('#chat-conn-dot').className))", 12000), `${await page.text("#chat-status-line")}`);
    await page.focus("#chat-box");
    await page.type("after recovery");
    await page.key("Enter");
    check("a prompt after recovery streams and finishes", await page.waitFor("window.__vis('#chat-stop')", 4000) && await page.waitFor("!window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 25000));
  });
}

// ───────────────────────────── the failing scenario ─────────────────────────────
async function walkFailing(page: Page, url: string) {
  const W = page.width;
  await step(`failing: models ${W}`, async () => {
    await page.goto(`${url}/#/models`);
    const P = "mlx-models-panel >>> ";
    await page.waitFor(`window.__qa('${P}#local .list-row').length > 0`, 5000);
    await page.focus(P + "#query");
    await page.type("qwen");
    check("Hub offline is explained in the results", await page.waitFor(`/unreachable|offline/i.test(window.__text('${P}#results') || '')`, 5000), await page.text(P + "#results") ?? "");
    await page.click(P + "#local .hub-serve-btn");
    check("a refused Serve shows a notice", await page.waitFor(`window.__vis('${P}#status') && /fit|refused|could not/i.test(window.__text('${P}#status') || '')`, 5000), await page.text(P + "#status") ?? "");
    await page.shot("models");
  });
  await step(`failing: quantize ${W}`, async () => {
    await page.go("quantize");
    const P = "mlx-quantize-panel >>> ";
    await page.focus(P + "#q-model");
    await page.type("mlx-community/Qwen3-8B-bf16");
    await page.click(P + "#q-inspect");
    check("a failed inspection explains itself and withholds Continue", await page.waitFor(`window.__vis('${P}#q-inspect-out .notice.bad') && !window.__vis('${P}#q-continue')`, 4000), await page.text(P + "#q-inspect-out") ?? "");
    await page.shot("quantize-inspect");
  });
  await step(`failing: dataset job ${W}`, async () => {
    await page.go("dataset");
    const P = "mlx-datasets-panel >>> ";
    await page.waitFor(`window.__qa('${P}#d-templates button.tpl').length > 0`, 5000);
    await page.click(P + "#d-templates button.tpl");
    await page.waitFor(`window.__vis('${P}[data-dstep="1"]')`, 2000);
    await page.click(P + "#d-submit");
    check("a job that fails mid-stream shows the error with Try again", await page.waitFor(`window.__vis('${P}#d-fail') && (window.__text('${P}#d-fail-msg') || '').length > 0`, 15000), await page.text(P + "#d-fail-msg") ?? "");
    check("the progress bar turns bad and the rail marks the step failed", await page.eval<boolean>(`window.__q('${P}#d-bar').parentElement.classList.contains('bad') && !!window.__q('${P}#d-steps .step.failed')`));
    await page.shot("dataset-failed");
    await page.click(P + "#d-retry");
    check("Try again returns to Inputs", await page.waitFor(`window.__vis('${P}[data-dstep="1"]')`, 2000));
  });
  await step(`failing: chat ${W}`, async () => {
    await page.go("chat");
    await page.waitFor("window.__q('#chat-box') && !window.__q('#chat-box').disabled", 4000);
    await page.focus("#chat-box");
    await page.type("anything");
    await page.key("Enter");
    check("the error frame mid-reply is shown and the composer recovers", await page.waitFor("window.__vis('#chat-thread .notice.bad') && !window.__vis('#chat-stop') && !window.__q('#chat-box').disabled", 15000));
    await page.shot("chat");
  });
  await step(`failing: metrics ${W}`, async () => {
    await page.go("metrics");
    const P = "mlx-metrics-panel >>> ";
    check("the stream still fills the page", await page.waitFor(`window.__qa('${P}.stat b').length >= 4`, 6000));
    await page.click(P + ".bench-controls .btn.primary");
    check("a refused benchmark run is reported in a notice", await page.waitFor(`/did not start/i.test(window.__text('${P}.bench .notice.bad') || '')`, 6000), await page.text(P + ".bench .notice.bad") ?? "");
    await page.shot("metrics");
  });
}

// ───────────────────────────── the empty scenario ─────────────────────────────
async function walkEmpty(page: Page, url: string) {
  const W = page.width;
  await step(`empty: boot ${W}`, async () => {
    await page.goto(`${url}/#/chat`);
    check("no model is stated plainly", await page.waitFor("/No model/.test(window.__text('#nav-model') || '')", 8000), await page.text("#nav-model") ?? "");
    check("the chat greets a fresh install", await page.waitFor("window.__vis('#chat-hello')", 3000));
    await page.shot("chat");
  });
  await step(`empty: models ${W}`, async () => {
    await page.go("models");
    const P = "mlx-models-panel >>> ";
    check("the Models page shows an empty state and the search", await page.waitFor(`window.__vis('${P}.empty') && window.__vis('${P}#query')`, 5000), (await page.text(P + "#local") ?? "").slice(0, 100));
    await page.shot("models");
  });
  await step(`empty: metrics and benchmarks ${W}`, async () => {
    await page.go("metrics");
    const P = "mlx-metrics-panel >>> ";
    check("metrics explains there are no plans and no samples", await page.waitFor(`/No benchmark plans/.test(window.__text('${P}.bench') || '')`, 5000));
    await page.go("benchmarks");
    const B = "mlx-benchmarks-panel >>> ";
    check("benchmarks shows no finished runs", await page.waitFor(`/No finished runs/.test(window.__text('${B}.empty') || '')`, 5000));
    await page.shot("benchmarks");
  });
}

const { webSocketDebuggerUrl } = await version();
const cdp = new Cdp(webSocketDebuggerUrl);
await cdp.open();
for (const [width, height] of [[1440, 900], [390, 844]] as const) {
  const page = await Page.open(cdp, width, height, "default");
  await walkDefault(page);
  const failing = await Page.open(cdp, width, height, "failing");
  await walkFailing(failing, failingBase);
  const empty = await Page.open(cdp, width, height, "empty");
  await walkEmpty(empty, emptyBase);
}
const failed = checks.filter((c) => !c.ok);
const lines = ["| Scope | Check | Result | Detail |", "| --- | --- | --- | --- |", ...checks.map((c) => `| ${c.scope} | ${c.name} | ${c.ok ? "pass" : "FAIL"} | ${(c.detail ?? "").replace(/\|/g, "\\|").slice(0, 160)} |`)];
await Bun.write(`${OUT}/report.md`, `# Browser walkthrough\n\n${checks.length} checks, ${failed.length} failed. Screenshots beside this report.\n\n${lines.join("\n")}\n`);
console.log(`\n${checks.length} checks, ${failed.length} failed → ${OUT}/report.md`);
chrome.kill();
for (const backend of Object.values(backends)) backend.stop();
await Bun.$`rm -rf ${profile}`.quiet().nothrow();
process.exit(failed.length ? 1 : 0);
