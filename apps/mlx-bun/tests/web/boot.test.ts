// The browser bundle as a browser boots it: the real app.html markup, the bundle built from source (which carries the
// installed modules' panels), and happy-dom standing in for the browser. It proves the shell's pages and tabs, the
// module panel mounted through the shell, and the boot-time preference behavior; the page's own behavior is covered by
// browser.test.ts. fetch, EventSource and WebSocket are fakes that record what the page asks for.
import { afterAll, beforeAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
import { buildWebBundle, installedPanelsSource, panelModules } from "../../src/web/build";

class FakeEventSource {
  static urls: string[] = [];
  static closed: string[] = [];
  addEventListener() {}
  constructor(readonly url: string) { FakeEventSource.urls.push(url); }
  close() { FakeEventSource.closed.push(this.url); }
}
class FakeWebSocket {
  static opened = 0;
  static last: FakeWebSocket | undefined;
  static closed = 0;
  readyState = 0;
  sent: Record<string, unknown>[] = [];
  onmessage: ((event: { data: string }) => void) | null = null;
  constructor(readonly url: string) { FakeWebSocket.opened++; FakeWebSocket.last = this; }
  send(data: string) { this.sent.push(JSON.parse(data)); }
  close() { FakeWebSocket.closed++; }
  addEventListener() {}
  /** The server's frame, as the page's own handler receives it. */
  emit(frame: unknown) { this.onmessage?.({ data: JSON.stringify(frame) }); }
}
const requests: string[] = [];
const fakeFetch = (async (input: string | URL | Request) => {
  const url = String(typeof input === "object" && "url" in input ? input.url : input);
  requests.push(url);
  return new Response(url === "/v1/models" ? JSON.stringify({ data: [{ id: "test-model" }] }) : "{}", { status: url === "/dag" ? 404 : 200 });
}) as unknown as typeof fetch;

const GLOBALS = ["window", "document", "navigator", "location", "localStorage", "customElements", "HTMLElement", "Node", "Event", "KeyboardEvent",
  "MouseEvent", "CustomEvent", "MutationObserver", "requestAnimationFrame", "cancelAnimationFrame", "EventSource", "WebSocket", "fetch", "getComputedStyle"] as const;
const saved = new Map<string, PropertyDescriptor | undefined>();
/** The page polls on intervals of the runtime's own clock, which no window teardown stops: record them to clear them. */
const realSetInterval = globalThis.setInterval;
const intervals: ReturnType<typeof setInterval>[] = [];
const stopIntervals = () => { for (const id of intervals.splice(0)) clearInterval(id); };
let win: GlobalWindow;
let bundle: string;

const html = await Bun.file(new URL("../../src/web/public/app.html", import.meta.url)).text();

/** Boots the page in a fresh window: markup first, then the bundle, as the browser's deferred script would. */
function boot(hash: string, storage: Record<string, string> = {}): void {
  // Cancel the previous page's queued navigation and browser tasks before
  // swapping the globals its bundle reads from asynchronous callbacks.
  if (win) void win.happyDOM.abort();
  win = new GlobalWindow({ url: `http://localhost/${hash}`, settings: { disableCSSFileLoading: true, disableJavaScriptFileLoading: true, disableIframePageLoading: true } });
  win.document.documentElement.innerHTML = html.replace(/<script[\s\S]*?<\/script>/g, "").replace(/^[\s\S]*?<html[^>]*>/, "");
  for (const [key, value] of Object.entries(storage)) win.localStorage.setItem(key, value);
  Object.assign(globalThis, {
    window: win, document: win.document, navigator: win.navigator, location: win.location, localStorage: win.localStorage,
    customElements: win.customElements, HTMLElement: win.HTMLElement, Node: win.Node, Event: win.Event, KeyboardEvent: win.KeyboardEvent,
    MouseEvent: win.MouseEvent, CustomEvent: win.CustomEvent, MutationObserver: win.MutationObserver, getComputedStyle: win.getComputedStyle.bind(win),
    requestAnimationFrame: win.requestAnimationFrame.bind(win), cancelAnimationFrame: win.cancelAnimationFrame.bind(win),
    EventSource: FakeEventSource, WebSocket: FakeWebSocket, fetch: fakeFetch,
  });
  stopIntervals();
  requests.length = 0; FakeEventSource.urls.length = 0; FakeEventSource.closed.length = 0; FakeWebSocket.opened = 0; FakeWebSocket.closed = 0; FakeWebSocket.last = undefined;
  (0, eval)(bundle);
}

beforeAll(async () => {
  for (const name of GLOBALS) saved.set(name, Object.getOwnPropertyDescriptor(globalThis, name));
  globalThis.setInterval = ((...args: Parameters<typeof setInterval>) => { const id = realSetInterval(...args); intervals.push(id); return id; }) as typeof setInterval;
  bundle = await buildWebBundle();
});
afterAll(() => {
  stopIntervals();
  globalThis.setInterval = realSetInterval;
  for (const [name, descriptor] of saved) descriptor ? Object.defineProperty(globalThis, name, descriptor) : delete (globalThis as Record<string, unknown>)[name];
  // Timers the page started (identity polling) would keep the process alive.
  (win as unknown as { happyDOM: { abort(): Promise<void> } }).happyDOM.abort();
});

const tabs = () => [...document.querySelectorAll<HTMLElement>("#tabs .tab")].map(tab => tab.dataset.tab);
const shown = () => [...document.querySelectorAll<HTMLElement>("#tabs .tab")].filter(tab => tab.style.display !== "none").map(tab => tab.dataset.tab);
const activePages = () => [...document.querySelectorAll<HTMLElement>("section[data-route].active")].map(section => section.dataset.route);

test("the browser build takes the panels of the host's installed modules that export one, and no others", () => {
  expect(panelModules()).toEqual(["@mlx-bun/module-benchmarks", "@mlx-bun/module-chat", "@mlx-bun/module-datasets", "@mlx-bun/module-metrics", "@mlx-bun/module-models", "@mlx-bun/module-quantize", "@mlx-bun/module-train"]);
  const source = installedPanelsSource();
  expect(source).toContain('import "@mlx-bun/module-benchmarks/panel";');
  expect(source).toContain('import "@mlx-bun/module-chat/panel";');
  expect(source).toContain('import "@mlx-bun/module-metrics/panel";');
  expect(source).toContain('import "@mlx-bun/module-models/panel";');
  for (const id of ["datasets", "quantize", "train"]) expect(source).toContain(`import "@mlx-bun/module-${id}/panel";`);
  expect(installedPanelsSource([])).toBe('import { panelsFromManifests } from "@mlx-bun/web-shell";\nexport const panels = panelsFromManifests([]);\n');
});

test("the bundle boots app.html: the chat workspace panel leads, the legacy pages keep their tabs in order and the other module panel gets its own, after them", () => {
  boot("#/chat");
  expect(tabs()).toEqual(["chat", "quantize", "finetune", "dataset", "status", "routes", "benchmarks", "metrics", "models"]);
  expect(document.querySelector('#tabs .tab[data-tab="metrics"]')!.textContent).toBe("Metrics");
  expect(document.querySelector('#tabs .tab[data-tab="metrics"]')!.getAttribute("href")).toBe("#/metrics");
  expect(activePages()).toEqual(["chat"]);
  expect(document.querySelector('#tabs .tab[data-tab="chat"]')!.classList.contains("active")).toBe(true);
  expect(document.getElementById("bloom")!.style.opacity).toBe("0.55");
  expect(document.getElementById("chat-hamburger")!.style.display).toBe("");
  expect(FakeWebSocket.opened).toBe(1); // the chat page initialized on first entry, as before
  expect(document.getElementById("st-metrics-host")).toBeNull(); // the status page no longer hosts the panel
});

test("a fresh browser sees Chat and Models; the developer tabs, the panels among them, appear with the Developer switch", () => {
  boot("#/chat");
  // The Models panel is not a developer tool: every user reaches their models.
  expect(shown()).toEqual(["chat", "models"]);
  expect(localStorage.getItem("mlxbun.developer")).toBe("0");
  expect(document.getElementById("nav-developer")!.getAttribute("aria-checked")).toBe("false");
  document.getElementById("nav-developer")!.click();
  expect(shown()).toEqual(["chat", "quantize", "finetune", "dataset", "status", "routes", "benchmarks", "metrics", "models"]);
  expect(localStorage.getItem("mlxbun.developer")).toBe("1");
});

test("a returning browser keeps its saved preferences: developer tabs on, the saved theme applied", () => {
  boot("#/chat", { "mlxbun.theme": "light" });
  expect(document.documentElement.getAttribute("data-theme")).toBe("light");
  expect(document.querySelector('#theme-toggle button[data-theme-choice="light"]')!.classList.contains("active")).toBe(true);
  expect(localStorage.getItem("mlxbun.developer")).toBe("1");
  expect(shown()).toContain("metrics");
  boot("#/chat", { "mlxbun.developer": "0", "mlxbun.theme": "dark" });
  expect(shown()).toEqual(["chat", "models"]);
  expect(document.documentElement.getAttribute("data-theme")).toBe("dark");
});

test("opening the metrics route mounts the panel through the shell with its connection, and leaving it stops the stream", () => {
  boot("#/metrics");
  expect(activePages()).toEqual(["metrics"]);
  expect(localStorage.getItem("mlxbun.developer")).toBe("1"); // a deep link into a developer page turns the switch on
  const panel = document.querySelector("#s-metrics mlx-metrics-panel") as HTMLElement & { connection?: unknown };
  expect(panel).not.toBeNull();
  expect(panel.connection).toEqual({ apiBase: "/api/metrics", eventsUrl: "/api/metrics/stream" });
  expect(FakeEventSource.urls).toEqual(["/api/metrics/stream"]);
  expect(requests.filter(url => url.startsWith("/api/metrics/")).sort()).toEqual(["/api/metrics/bench", "/api/metrics/bench/profiles", "/api/metrics/history"]);
  expect(requests).not.toContain("/api/metrics/panel.js");
  location.hash = "#/status";
  window.dispatchEvent(new window.Event("hashchange"));
  expect(activePages()).toEqual(["status"]);
  expect(panel.isConnected).toBe(false);
  expect(FakeEventSource.closed).toEqual(["/api/metrics/stream"]);
  location.hash = "#/metrics";
  window.dispatchEvent(new window.Event("hashchange"));
  expect(document.querySelector("#s-metrics mlx-metrics-panel")).toBe(panel);
  expect(FakeEventSource.urls).toEqual(["/api/metrics/stream", "/api/metrics/stream"]);
});

test("opening the benchmarks route mounts its panel through the shell, which reads its tasks, history and jobs", () => {
  boot("#/benchmarks");
  expect(activePages()).toEqual(["benchmarks"]);
  const panel = document.querySelector("#s-benchmarks mlx-benchmarks-panel") as HTMLElement & { connection?: unknown };
  expect(panel).not.toBeNull();
  expect(panel.connection).toEqual({ apiBase: "/api/benchmarks", eventsUrl: "" }); // benchmarks serves no event stream
  expect(requests.filter(url => url.startsWith("/api/benchmarks/")).sort()).toEqual(["/api/benchmarks/jobs", "/api/benchmarks/runs", "/api/benchmarks/tasks"]);
  expect(requests).not.toContain("/api/benchmarks/panel.js");
});

test("Cmd+K opens the palette with the commands, the panel's among them, and Escape closes it", () => {
  boot("#/chat");
  document.dispatchEvent(new win.KeyboardEvent("keydown", { key: "k", metaKey: true, bubbles: true, cancelable: true }) as unknown as Event);
  const labels = () => [...document.querySelectorAll("#palette-overlay .prow-label")].map(node => node.textContent);
  expect(labels()).toEqual(["New chat", "Toggle thinking", "Toggle theme", "Toggle Developer mode", "Open Memory panel", "Browse models (Hub)",
    "Open shortcut sheet", "Export this chat", "Open Benchmarks", "Open Build Dataset", "Open Metrics", "Open Models", "Open Quantize", "Open Fine-tune"]);
  document.dispatchEvent(new win.KeyboardEvent("keydown", { key: "Escape", bubbles: true, cancelable: true }) as unknown as Event);
  expect(document.getElementById("palette-overlay")!.classList.contains("open")).toBe(false);
});

test("the nav's model label opens the Models panel through the shell, and a switch made there refreshes the label at once", async () => {
  boot("#/chat");
  await new Promise(resolve => setTimeout(resolve, 10));
  expect(document.querySelector("mlx-models-panel")).toBeNull(); // created on the first visit
  document.getElementById("nav-model")!.click();
  expect(location.hash).toBe("#/models");
  await new Promise(resolve => setTimeout(resolve, 10)); // the shell follows the hash change
  const panel = document.querySelector("#s-models mlx-models-panel") as HTMLElement & { connection?: { apiBase: string } };
  expect(panel).not.toBeNull();
  expect(panel.connection?.apiBase).toBe("/api/models");
  expect(document.getElementById("nav-model")!.getAttribute("aria-haspopup")).toBeNull(); // no popover: the page is the picker
  await new Promise(resolve => setTimeout(resolve, 10));
  expect(requests).toEqual(expect.arrayContaining(["/api/hub/local", "/library", "/v1/adapters/available"]));
  requests.length = 0;
  panel.dispatchEvent(new win.CustomEvent("mlx-models-changed", { bubbles: true, composed: true }) as unknown as Event);
  await new Promise(resolve => setTimeout(resolve, 10));
  expect(requests).toContain("/v1/models");
});

test("the routes tab hides itself when /dag is not served, as before", async () => {
  boot("#/routes");
  await new Promise(resolve => setTimeout(resolve, 10));
  expect(document.querySelector<HTMLElement>('#tabs .tab[data-tab="routes"]')!.style.display).toBe("none");
  expect(location.hash).toBe("#/chat");
});

test("the chat is a workspace panel: it fills the page without a card, and stays attached with its socket open while another page shows", () => {
  boot("#/chat");
  const section = document.getElementById("s-chat")!;
  const panel = section.querySelector("mlx-chat-panel")!;
  expect(panel.parentElement).toBe(section);
  expect(section.querySelector(".shell-panel-title")).toBeNull();
  expect(panel.querySelector("#chat-box")).not.toBeNull();
  expect("dev" in (document.querySelector('#tabs .tab[data-tab="chat"]') as HTMLElement).dataset).toBe(false);
  expect(document.querySelector("#tabs .tab")!.getAttribute("data-tab")).toBe("chat"); // it leads the tabs
  location.hash = "#/status";
  window.dispatchEvent(new window.Event("hashchange"));
  expect(activePages()).toEqual(["status"]);
  expect(panel.isConnected).toBe(true);
  expect(FakeWebSocket.closed).toBe(0);
  location.hash = "#/chat";
  window.dispatchEvent(new window.Event("hashchange"));
  expect(document.querySelector("mlx-chat-panel")).toBe(panel);
  expect(FakeWebSocket.opened).toBe(1);
});

test("the app's side of the chat panel is wired: memory attaches to its sidebar, memory tools draw as chips, and the settings dialog follows the server's reports", () => {
  boot("#/chat", { "mlxbun.codingTools": "1" });
  // The panel's markup exists, so the memory panel's status poll (its sidebar entry and consent card) ran.
  expect(requests).toContain("/api/memory/status");
  const socket = FakeWebSocket.last!;
  socket.readyState = 1;
  socket.emit({ type: "ready", model: "test-model", vision: false, audio: false, thinking: false, genDefaults: { temperature: null, topP: null, topK: null } });
  // The host's saved wish for file-changing tools is re-asserted on every connection.
  expect(socket.sent.find(frame => frame.type === "set_coding_tools")).toEqual({ type: "set_coding_tools", enabled: true });
  socket.emit({ type: "coding_tools", active: false, pending: true });
  expect((document.getElementById("settings-coding-tools") as HTMLInputElement).checked).toBe(true);
  expect(document.getElementById("settings-coding-tools-note")!.textContent).toContain("next new chat");
  socket.emit({ type: "tool_approvals", alwaysAllow: ["bash", "edit"] });
  expect([...document.querySelectorAll("#settings-approvals-list .satool")].map(node => node.textContent)).toEqual(["bash", "edit"]);
  // A memory tool is drawn by the host as a provenance chip; any other tool keeps the panel's own card.
  socket.emit({ type: "turn_start" });
  socket.emit({ type: "tool_start", callId: "m1", tool: "memory_read", args: { article: "Travel" } });
  socket.emit({ type: "tool_start", callId: "w1", tool: "web_search", args: { query: "x" } });
  expect(document.querySelectorAll("#chat-thread .memchip")).toHaveLength(1);
  expect(document.querySelectorAll("#chat-thread .tool")).toHaveLength(1);
  // The checkbox in the host's dialog reaches the panel's socket.
  const box = document.getElementById("settings-coding-tools") as HTMLInputElement;
  box.checked = false; box.dispatchEvent(new window.Event("change"));
  expect(socket.sent.at(-1)).toEqual({ type: "set_coding_tools", enabled: false });
});

test("the hamburger in the nav opens the panel's drawer, and Escape closes the drawer and the panel's popovers in turn", () => {
  boot("#/chat");
  const sidebar = document.getElementById("chat-sidebar")!, hamburger = document.getElementById("chat-hamburger")!;
  hamburger.click();
  expect(sidebar.classList.contains("drawer-open")).toBe(true);
  expect(hamburger.getAttribute("aria-expanded")).toBe("true");
  expect(document.getElementById("chat-drawer-backdrop")!.classList.contains("open")).toBe(true);
  document.getElementById("chat-sampling")!.click();
  expect(document.getElementById("chat-sampling-pop")!.classList.contains("open")).toBe(true);
  const escape = () => document.dispatchEvent(new win.KeyboardEvent("keydown", { key: "Escape", bubbles: true, cancelable: true }) as unknown as Event);
  escape();
  expect(document.getElementById("chat-sampling-pop")!.classList.contains("open")).toBe(false); // the popover first
  expect(sidebar.classList.contains("drawer-open")).toBe(true);
  escape();
  expect(sidebar.classList.contains("drawer-open")).toBe(false);
  expect(hamburger.getAttribute("aria-expanded")).toBe("false");
  hamburger.click();
  document.getElementById("chat-drawer-backdrop")!.click();
  expect(sidebar.classList.contains("drawer-open")).toBe(false);
});

test("the migrated wizards are lazy module panels with preserved routes, host hooks and their own layout", () => {
 boot("#/chat");
 for (const [route, tag, apiBase] of [["quantize","mlx-quantize-panel","/api/quantize"],["finetune","mlx-train-panel","/api/train"],["dataset","mlx-datasets-panel","/api/datasets"]]) {
   expect(document.querySelector(tag!)).toBeNull();location.hash = "#/"+route;win.dispatchEvent(new win.HashChangeEvent("hashchange"));
   const panel=document.querySelector(tag!) as HTMLElement & {connection: {apiBase:string;ui?:{notify?:unknown;publish?:unknown}}};
   expect(activePages()).toEqual([route!]);expect(panel).not.toBeNull();expect(panel.connection.apiBase).toBe(apiBase!);
   expect(typeof panel.connection.ui?.notify).toBe("function");expect(typeof panel.connection.ui?.publish).toBe("function");
   expect(panel.parentElement!.id).toBe("s-"+route);expect(panel.shadowRoot!.querySelector(".steps")).not.toBeNull();
   location.hash = "#/chat";win.dispatchEvent(new win.HashChangeEvent("hashchange"));expect(panel.isConnected).toBe(false);
 }
});

test("assistant spotlight navigation mounts an unvisited or detached job panel before resolving its shadow control", async () => {
  boot("#/chat");
  expect(document.querySelector("mlx-quantize-panel")).toBeNull();
  const socket = FakeWebSocket.last!;
  for (const navigateFirst of [false, true]) {
    if (navigateFirst) socket.emit({type:"ui_navigate", route:"quantize"});
    socket.emit({ type: "ui_spotlight", route: "quantize", target: "quantize-source", message: "Start here" });
    await new Promise(resolve => setTimeout(resolve, 30));
    expect(activePages()).toEqual(["quantize"]);
    expect(document.querySelector("mlx-quantize-panel")!.shadowRoot!.getElementById("q-model")).not.toBeNull();
    expect(document.getElementById("assistant-spotlight")!.classList.contains("show")).toBe(true);
    expect(document.getElementById("toasts")!.textContent).not.toContain("Couldn't find");
    location.hash = "#/chat"; win.dispatchEvent(new win.HashChangeEvent("hashchange"));
    expect(document.querySelector("mlx-quantize-panel")).toBeNull();
  }
});
