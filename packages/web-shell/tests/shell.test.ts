// The shell against a happy-dom page shaped like a host's markup: routing, the Developer switch, two fake module
// panels mounted through their manifests, the Escape sweep, theme, and the palette's sections.
import { beforeAll, beforeEach, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
import type { Palette, PaletteSection, Shell, ShellPanel } from "../src";

let window: GlobalWindow;
let api: typeof import("../src");

/** A new window per test: a shell registers window and document listeners for its lifetime, so tests must not share one. */
function freshWindow(): void {
  window = new GlobalWindow({ url: "http://localhost/" });
  Object.assign(globalThis, {
    window, document: window.document, navigator: window.navigator, location: window.location, localStorage: window.localStorage,
    HTMLElement: window.HTMLElement, customElements: window.customElements, Event: window.Event, KeyboardEvent: window.KeyboardEvent,
  });
}

beforeAll(async () => { freshWindow(); api = await import("../src"); });

const PAGE = `
<nav>
  <div id="tabs">
    <a class="tab" href="#/home" data-tab="home">Home</a>
    <a class="tab" href="#/tools" data-tab="tools" data-dev>Tools</a>
    <a class="tab" href="#/map" data-tab="map" data-dev>Map</a>
  </div>
  <button id="nav-developer" role="switch" aria-checked="false"><span id="nav-developer-dot"></span></button>
  <button id="nav-shortcuts" aria-expanded="false"></button>
  <div id="theme-toggle"><button data-theme-choice="auto"></button><button data-theme-choice="dark"></button><button data-theme-choice="light"></button></div>
</nav>
<div id="shortcut-overlay"><button id="sk-close"></button><span class="sk-mod"></span></div>
<div id="app">
  <section data-route="home" id="s-home"></section>
  <section data-route="tools" id="s-tools"></section>
  <section data-route="map" id="s-map"></section>
</div>
<div id="toasts"></div>`;

let shell: Shell;
const events: string[] = [];

/** A fake module panel: a custom element that records its lifecycle. */
const created: Record<string, HTMLElement[]> = {};
function defineFake(tag: string): void {
  customElements.define(tag, class extends window.HTMLElement {
    connection: unknown;
    constructor() { super(); (created[tag] ??= []).push(this as unknown as HTMLElement); }
    connectedCallback() { events.push(`connect ${tag}`); }
    disconnectedCallback() { events.push(`disconnect ${tag}`); }
  } as unknown as CustomElementConstructor);
}
const alpha: ShellPanel = { tag: "mlx-alpha-panel", title: "Alpha", path: "/alpha", connection: { apiBase: "/api/alpha", eventsUrl: "/api/alpha/stream" } };
const beta: ShellPanel = { tag: "mlx-beta-panel", title: "Beta", path: "/beta", connection: { apiBase: "/api/beta", eventsUrl: "" }, developer: false };

function go(hash: string): void {
  location.hash = hash;
  window.dispatchEvent(new window.Event("hashchange"));
}
const active = () => [...document.querySelectorAll("section[data-route].active")].map(s => (s as HTMLElement).dataset.route);
const tab = (id: string) => document.querySelector<HTMLElement>(`nav .tab[data-tab="${id}"]`)!;
const press = (init: { key: string; metaKey?: boolean; shiftKey?: boolean }) => document.dispatchEvent(new window.KeyboardEvent("keydown", { bubbles: true, cancelable: true, ...init }) as unknown as Event);

beforeEach(() => {
  freshWindow();
  document.body.innerHTML = PAGE;
  events.length = 0;
  for (const key of Object.keys(created)) delete created[key];
  shell = api.createShell({ routes: [{ id: "home" }, { id: "tools", developer: true }, { id: "map", developer: true }], home: "home",
    onRoute: route => events.push(`route ${route}`) });
});

test("navigation shows the page the hash names, falls back to the home page, and runs controllers lazily once", () => {
  const log: string[] = [];
  for (const id of ["home", "tools"]) shell.controllers[id] = { init() { log.push(`init ${id}`); }, enter() { log.push(`enter ${id}`); }, leave() { log.push(`leave ${id}`); } };
  shell.start();
  shell.navigate();
  expect(active()).toEqual(["home"]);
  go("#/tools");
  expect(active()).toEqual(["tools"]);
  go("#/nowhere");
  expect(active()).toEqual(["home"]);
  go("#/tools?x=1");
  expect(active()).toEqual(["tools"]);
  // Pages are visited in document order: the one turning on runs before a later one turning off.
  expect(log).toEqual(["init home", "enter home", "leave home", "init tools", "enter tools", "enter home", "leave tools", "leave home", "enter tools"]);
  expect(tab("tools").classList.contains("active")).toBe(true);
  expect(tab("home").classList.contains("active")).toBe(false);
  expect(events.filter(e => e.startsWith("route "))).toEqual(["route home", "route tools", "route home", "route tools"]);
});

test("the Developer switch hides developer tabs, defaults on only for a returning user, and a deep link turns it on", () => {
  shell.start();
  expect(shell.isDeveloperMode()).toBe(false);
  expect(tab("tools").style.display).toBe("none");
  expect(tab("home").style.display).toBe("");
  expect(document.getElementById("nav-developer")!.getAttribute("aria-checked")).toBe("false");
  go("#/map");
  expect(shell.isDeveloperMode()).toBe(true);
  expect(localStorage.getItem("mlxbun.developer")).toBe("1");
  expect(tab("map").style.display).toBe("");
  document.getElementById("nav-developer")!.click();
  expect(shell.isDeveloperMode()).toBe(false);
  expect(tab("map").style.display).toBe("none");

  freshWindow();
  localStorage.setItem("mlxbun.theme", "dark"); // another mlxbun.* key: a returning user
  document.body.innerHTML = PAGE;
  const returning = api.createShell({ routes: [{ id: "home" }], home: "home" });
  expect(returning.isDeveloperMode()).toBe(true);
  expect(localStorage.getItem("mlxbun.developer")).toBe("1");
});

test("a tab marked unavailable stays hidden whatever the Developer switch says", () => {
  shell.start();
  shell.setDeveloperMode(true);
  expect(tab("map").style.display).toBe("");
  shell.markUnavailable("map");
  shell.setDeveloperMode(false);
  shell.setDeveloperMode(true);
  expect(tab("map").style.display).toBe("none");
  expect(tab("tools").style.display).toBe("");
});

test("two fake panels mount through their manifests: a tab and a page each, created on first visit and attached only while shown", () => {
  defineFake(alpha.tag); defineFake(beta.tag);
  shell.mountPanels([alpha, beta]);
  expect([...document.querySelectorAll("#tabs .tab")].map(t => (t as HTMLElement).dataset.tab)).toEqual(["home", "tools", "map", "alpha", "beta"]);
  expect(tab("alpha").getAttribute("href")).toBe("#/alpha");
  expect(tab("alpha").textContent).toBe("Alpha");
  expect("dev" in tab("alpha").dataset).toBe(true);
  expect("dev" in tab("beta").dataset).toBe(false);
  expect(document.querySelector("#app > section[data-route=alpha]")).not.toBeNull();
  expect(created["mlx-alpha-panel"] ?? []).toEqual([]); // nothing is created before a visit
  shell.start();
  shell.navigate();
  expect(tab("alpha").style.display).toBe("none"); // a developer tool while the switch is off
  expect(tab("beta").style.display).toBe("");

  go("#/alpha");
  expect(shell.isDeveloperMode()).toBe(true); // opening a developer panel turns the switch on
  expect(active()).toEqual(["alpha"]);
  const first = created["mlx-alpha-panel"]!;
  expect(first).toHaveLength(1);
  expect((first[0] as unknown as { connection: unknown }).connection).toEqual(alpha.connection);
  expect(document.querySelector("#s-alpha .shell-panel-title")!.textContent).toBe("Alpha");
  expect(first[0]!.parentElement!.classList.contains("shell-panel-body")).toBe(true);
  expect(document.querySelector("#s-alpha")!.contains(first[0]!)).toBe(true);

  go("#/beta");
  expect(active()).toEqual(["beta"]);
  expect(first[0]!.isConnected).toBe(false); // left: detached, so its streams stop
  expect(created["mlx-beta-panel"]).toHaveLength(1);
  expect((created["mlx-beta-panel"]![0] as unknown as { connection: unknown }).connection).toEqual(beta.connection);

  go("#/alpha");
  expect(created["mlx-alpha-panel"]).toHaveLength(1); // the same instance comes back
  expect(first[0]!.isConnected).toBe(true);
  expect(events.filter(e => e.startsWith("connect") || e.startsWith("disconnect"))).toEqual(
    ["connect mlx-alpha-panel", "disconnect mlx-alpha-panel", "connect mlx-beta-panel", "connect mlx-alpha-panel", "disconnect mlx-beta-panel"]);
  expect(shell.panelTargets()).toEqual([{ id: "alpha", title: "Alpha" }, { id: "beta", title: "Beta" }]);
});

test("a panel whose element is not defined shows a note instead of failing, and a taken route is refused", () => {
  const missing: ShellPanel = { tag: "mlx-missing-panel", title: "Missing", path: "/missing", connection: { apiBase: "/api/missing", eventsUrl: "" } };
  shell.mountPanels([missing]);
  shell.start();
  go("#/missing");
  expect(document.querySelector("#s-missing .shell-panel-note")!.textContent).toContain("<mlx-missing-panel> is not defined");
  expect(() => shell.mountPanels([{ ...missing, tag: "mlx-other-panel" }])).toThrow("Panel route /missing is already taken");
  expect(() => shell.mountPanels([{ ...missing, path: "/tools" }])).toThrow("already taken");
});

test("Escape closes the first open overlay in the order they were added, one per press, and never when none is open", () => {
  const open = { a: true, b: true };
  shell.overlays.add({ isOpen: () => open.a, close: () => { open.a = false; } });
  shell.overlays.add({ isOpen: () => open.b, close: () => { open.b = false; } });
  shell.start();
  press({ key: "Escape" });
  expect(open).toEqual({ a: false, b: true });
  press({ key: "Escape", shiftKey: true }); // Shift+Escape is the host's
  expect(open).toEqual({ a: false, b: true });
  press({ key: "Escape" });
  expect(open).toEqual({ a: false, b: false });
  expect(shell.overlays.closeTop()).toBe(false);
});

test("the shortcut sheet opens on Cmd+/ and closes on Escape, and the host's keys run after the shell's", () => {
  const seen: string[] = [];
  shell.start({ keys: e => { seen.push(e.key); return e.key === "x"; } });
  const sheet = document.getElementById("shortcut-overlay")!;
  press({ key: "/", metaKey: true });
  expect(sheet.classList.contains("open")).toBe(true);
  expect(document.getElementById("nav-shortcuts")!.getAttribute("aria-expanded")).toBe("true");
  press({ key: "Escape" });
  expect(sheet.classList.contains("open")).toBe(false);
  press({ key: "x" });
  expect(seen).toEqual(["Escape", "x"]); // the palette and sheet keys never reach the host
});

test("theme: the saved choice is applied, choices persist, and cycling goes auto, dark, light", () => {
  localStorage.setItem("mlxbun.theme", "light");
  shell.start();
  expect(document.documentElement.getAttribute("data-theme")).toBe("light");
  expect(api.themeChoice()).toBe("light");
  api.cycleTheme();
  expect([api.themeChoice(), localStorage.getItem("mlxbun.theme")]).toEqual(["auto", "auto"]);
  api.cycleTheme();
  expect([api.themeChoice(), document.documentElement.getAttribute("data-theme")]).toEqual(["dark", "dark"]);
  (document.querySelector('#theme-toggle button[data-theme-choice="light"]') as HTMLElement).click();
  expect(localStorage.getItem("mlxbun.theme")).toBe("light");
});

const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
const rows = () => [...document.querySelectorAll("#palette-overlay .palette-list > div")].map(node => {
  const cls = (node as HTMLElement).className;
  if (cls.includes("hdr")) return `# ${node.textContent}`;
  if (cls.includes("empty")) return node.textContent!;
  const snippet = node.querySelector(".prow-snippet")?.textContent;
  return node.querySelector(".prow-label")!.textContent + (snippet ? ` / ${snippet}` : "");
});

test("the palette lists sections in order, filters commands by subsequence, runs the chosen row and adds remote rows after the debounce", async () => {
  const ran: string[] = [];
  let remote = 0;
  const sections: PaletteSection[] = [
    api.actionSection("Commands", () => [
      { label: "New chat", run() { ran.push("new"); } },
      { label: "Toggle theme", hint: "⌘T", run() { ran.push("theme"); } },
      { label: "Hidden here", when: () => false, run() { ran.push("hidden"); } },
    ]),
    { title: "Chats", rows: q => q ? [{ label: `chat about ${q}`, run() { ran.push("chat"); } }] : [] },
    { title: "In messages", rows: () => [], async remote(q) { remote++; return [{ label: "Session", snippet: `hit for ${q}`, run() { ran.push("hit"); } }]; } },
  ];
  const palette: Palette = api.createPalette({ sections });
  shell.overlays.add(palette);
  shell.start({ palette });
  expect(document.getElementById("palette-overlay")).toBeNull(); // nothing is built until the first open
  press({ key: "k", metaKey: true });
  expect(palette.isOpen()).toBe(true);
  expect(rows()).toEqual(["# Commands", "New chat", "Toggle theme"]);
  expect(document.querySelector(".prow-hint")!.textContent).toBe("⌘T");

  const input = document.getElementById("palette-input") as HTMLInputElement;
  input.value = "tt";
  input.dispatchEvent(new Event("input"));
  await sleep(260);
  expect(rows()).toEqual(["# Commands", "Toggle theme", "# Chats", "chat about tt", "# In messages", "Session / hit for tt"]);
  expect(remote).toBe(1);

  input.dispatchEvent(new window.KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true }) as unknown as Event);
  input.dispatchEvent(new window.KeyboardEvent("keydown", { key: "Enter", bubbles: true }) as unknown as Event);
  expect(ran).toEqual(["chat"]);
  expect(palette.isOpen()).toBe(false);

  press({ key: "k", metaKey: true });
  expect(palette.isOpen()).toBe(true);
  press({ key: "Escape" });
  expect(palette.isOpen()).toBe(false);
});

test("a remote result for a superseded query is dropped, and an empty result renders nothing", async () => {
  const asked: string[] = [];
  const palette = api.createPalette({ sections: [
    { title: "Found", rows: () => [], async remote(q) { asked.push(q); await sleep(q === "ab" ? 80 : 0); return q === "abc" ? [] : [{ label: `for ${q}`, run() {} }]; } },
  ] });
  palette.open();
  const input = document.getElementById("palette-input") as HTMLInputElement;
  input.value = "ab"; input.dispatchEvent(new Event("input"));
  await sleep(230); // the slow lookup for "ab" is in flight
  input.value = "abc"; input.dispatchEvent(new Event("input"));
  await sleep(330);
  expect(asked).toEqual(["ab", "abc"]);
  expect(rows()).toEqual(["No matching commands or chats."]); // "ab" arrived late and was dropped; "abc" found nothing
});
