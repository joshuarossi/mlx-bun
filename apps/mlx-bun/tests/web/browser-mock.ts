// The fake backend inside the page: `installBrowserMock` replaces `fetch`, `WebSocket` and `EventSource` with
// stand-ins that answer from `createFakeBackend` without a network, so the real browser app runs as a single static
// HTML file (a design review, a hosted preview) with its inference, downloads and jobs mocked. Going offline (the
// browser's own switch, or a devtools emulation) makes every request fail the way a dead server would, and the
// socket closes, so the app's unreachable and recovery states can be seen too. `scripts/web-static.ts` bundles this
// ahead of the app's bundle.
import { createFakeBackend, type FakeBackendOptions, type PageContext } from "./fake-backend";

const ORIGIN = "http://mlx-bun.mock";
const SCENARIO_KEY = "mlxbun.mock.scenario";

type Handler = ((event: Event) => void) | null;

/** The scenario named in the page's query (`?scenario=failing`), else the one the switch last chose, else the build's. */
export function chosenScenario(fallback: FakeBackendOptions["scenario"] = "default"): FakeBackendOptions["scenario"] {
  const valid = (value: string | null): value is "default" | "empty" | "failing" => value === "default" || value === "empty" || value === "failing";
  try {
    const query = new URLSearchParams(location.search).get("scenario");
    if (valid(query)) return query;
    const saved = localStorage.getItem(SCENARIO_KEY);
    if (valid(saved)) return saved;
  } catch { /* storage may be unavailable */ }
  return fallback;
}

export function installBrowserMock(options: FakeBackendOptions & { switcher?: boolean } = {}): void {
  const backend = createFakeBackend({ ...options, scenario: chosenScenario(options.scenario) });
  const offline = () => typeof navigator !== "undefined" && navigator.onLine === false;
  const absolute = (url: string | URL) => new URL(String(url), ORIGIN);
  const server = { upgrade: () => false };

  // ── fetch: every JSON route, answered from the fake's handlers; 404 for what it does not know.
  const nativeFetch = globalThis.fetch;
  globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
    if (offline()) throw new TypeError("Failed to fetch");
    const url = input instanceof Request ? input.url : String(input);
    if (/^(data|blob):/.test(url)) return nativeFetch(input, init);
    const request = input instanceof Request ? new Request(absolute(input.url), input) : new Request(absolute(url), init);
    const answer = await backend.fetch(request, server);
    return answer ?? new Response("not found", { status: 404 });
  }) as typeof fetch;

  // ── WebSocket: the chat socket, driven by the fake's open/message/close handlers.
  const sockets = new Set<MockWebSocket>();
  class MockWebSocket extends EventTarget {
    static readonly CONNECTING = 0; static readonly OPEN = 1; static readonly CLOSING = 2; static readonly CLOSED = 3;
    readonly CONNECTING = 0; readonly OPEN = 1; readonly CLOSING = 2; readonly CLOSED = 3;
    readyState = 0;
    onopen: Handler = null; onmessage: Handler = null; onclose: Handler = null; onerror: Handler = null;
    readonly url: string;
    #peer: { send(data: string): void; readyState?: number; data: { turn: AbortController | null; session: string | null; context: PageContext | null } };
    constructor(url: string | URL) {
      super();
      this.url = String(url);
      const self = this;
      this.#peer = {
        data: { turn: null, session: null, context: null },
        send(data: string) { setTimeout(() => { if (self.readyState === 1) self.#fire("message", new MessageEvent("message", { data })); }, 0); },
      };
      setTimeout(() => {
        if (this.readyState !== 0) return;
        if (offline()) { this.#fire("error", new Event("error")); this.#end(1006); return; }
        this.readyState = 1;
        sockets.add(this);
        this.#fire("open", new Event("open"));
        backend.websocket.open(this.#peer);
      }, 0);
    }
    send(data: string) { if (this.readyState === 1) backend.websocket.message(this.#peer, String(data)); }
    close() { if (this.readyState < 2) this.#end(1000); }
    #end(code: number) {
      this.readyState = 3;
      sockets.delete(this);
      backend.websocket.close(this.#peer);
      this.#fire("close", new CloseEvent("close", { code, wasClean: code === 1000 }));
    }
    #fire(type: "open" | "message" | "close" | "error", event: Event) {
      (this[`on${type}`] as Handler)?.call(this, event);
      this.dispatchEvent(event);
    }
    /** A dead server: what going offline does to an open socket. */
    drop() { if (this.readyState === 1) this.#end(1006); }
  }
  (globalThis as unknown as { WebSocket: unknown }).WebSocket = MockWebSocket;
  window.addEventListener("offline", () => { for (const socket of [...sockets]) socket.drop(); });

  // ── EventSource: the job and metrics streams, parsed from the fake's text/event-stream responses, with the
  // browser's own retry behaviour when a stream ends without the client closing it.
  class MockEventSource extends EventTarget {
    static readonly CONNECTING = 0; static readonly OPEN = 1; static readonly CLOSED = 2;
    readyState = 0;
    onopen: Handler = null; onmessage: Handler = null; onerror: Handler = null;
    readonly url: string;
    readonly withCredentials = false;
    #retry = 1500;
    #reader: ReadableStreamDefaultReader<Uint8Array> | null = null;
    constructor(url: string | URL) { super(); this.url = String(url); void this.#connect(); }
    close() { this.readyState = 2; void this.#reader?.cancel(); this.#reader = null; }
    async #connect() {
      if (this.readyState === 2) return;
      let response: Response | null = null;
      try { if (!offline()) response = await backend.fetch(new Request(absolute(this.url)), server); } catch { response = null; }
      if (this.readyState === 2) return;
      if (!response || !response.ok || !response.body) { this.#fail(); return; }
      this.readyState = 1;
      this.#fire("open", new Event("open"));
      const reader = response.body.getReader();
      this.#reader = reader;
      const decoder = new TextDecoder();
      let buffer = "";
      try {
        for (;;) {
          const { value, done } = await reader.read();
          if (done || this.readyState === 2) break;
          buffer += decoder.decode(value, { stream: true });
          let cut: number;
          while ((cut = buffer.indexOf("\n\n")) >= 0) {
            const block = buffer.slice(0, cut);
            buffer = buffer.slice(cut + 2);
            this.#dispatch(block);
          }
        }
      } catch { /* cancelled */ }
      if (this.readyState !== 2) this.#fail();
    }
    #dispatch(block: string) {
      let type = "message";
      const data: string[] = [];
      for (const line of block.split("\n")) {
        if (!line || line.startsWith(":")) continue;
        const colon = line.indexOf(":");
        const field = colon < 0 ? line : line.slice(0, colon);
        const value = colon < 0 ? "" : line.slice(colon + 1).replace(/^ /, "");
        if (field === "event") type = value;
        else if (field === "data") data.push(value);
        else if (field === "retry" && /^\d+$/.test(value)) this.#retry = Number(value);
      }
      if (data.length) this.#fire(type, new MessageEvent(type, { data: data.join("\n") }));
    }
    #fail() {
      this.readyState = 0;
      this.#reader = null;
      this.#fire("error", new Event("error"));
      setTimeout(() => { void this.#connect(); }, this.#retry);
    }
    #fire(type: string, event: Event) {
      if (type === "open" || type === "message" || type === "error") (this[`on${type}` as "onopen"] as Handler)?.call(this, event);
      this.dispatchEvent(event);
    }
  }
  (globalThis as unknown as { EventSource: unknown }).EventSource = MockEventSource;

  if (options.switcher !== false) addSwitcher(backend.scenario);
}

/** A small control in the page's corner to pick the scenario; the choice is kept per browser and the page reloads. */
function addSwitcher(current: string): void {
  const mount = () => {
    const wrap = document.createElement("div");
    wrap.id = "mock-switch";
    wrap.setAttribute("role", "group");
    wrap.setAttribute("aria-label", "Preview scenario");
    wrap.innerHTML = '<style>#mock-switch{position:fixed;right:12px;bottom:12px;z-index:2000;display:flex;align-items:center;gap:2px;padding:3px;border-radius:999px;' +
      'background:var(--panel,#fff);border:1px solid var(--line-strong,#ccc);box-shadow:var(--shadow-lg,0 8px 24px rgba(0,0,0,.2));font:12px/1 var(--font,system-ui)}' +
      '#mock-switch span{padding:0 8px 0 10px;color:var(--dimmer,#777)}#mock-switch button{appearance:none;border:0;background:none;color:var(--dim,#555);font:inherit;padding:6px 10px;border-radius:999px;cursor:pointer}' +
      '#mock-switch button[aria-pressed="true"]{background:var(--accent,#2f6fed);color:var(--accent-ink,#fff)}#mock-switch button:focus-visible{outline:2px solid var(--accent,#2f6fed);outline-offset:1px}' +
      '@media (max-width:760px){#mock-switch{bottom:auto;top:52px;right:8px}}</style><span>Mock</span>';
    for (const name of ["default", "empty", "failing"] as const) {
      const button = document.createElement("button");
      button.type = "button";
      button.textContent = name === "default" ? "Served model" : name === "empty" ? "Fresh install" : "Failing server";
      button.setAttribute("aria-pressed", String(name === current));
      button.onclick = () => { try { localStorage.setItem(SCENARIO_KEY, name); } catch { /* ignore */ } location.reload(); };
      wrap.append(button);
    }
    document.body.append(wrap);
  };
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", mount); else mount();
}
