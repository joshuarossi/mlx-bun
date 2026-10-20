import { afterAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
const win = new GlobalWindow({ url: "http://localhost/" });
Object.assign(globalThis, { window: win, document: win.document, HTMLElement: win.HTMLElement, customElements: win.customElements, localStorage: win.localStorage, CustomEvent: win.CustomEvent, Event: win.Event });
const { MemoryPanel } = await import("../src/panel");
type ChatSlots = import("../src/panel").ChatSlots;
afterAll(async () => { await win.happyDOM.close(); });
const settle = () => new Promise(resolve => setTimeout(resolve, 40));
test("the persistent overlay honors its connection and reconnects without duplicate listeners", async () => {
  const requests: string[] = [];
  const saved = globalThis.fetch;
  globalThis.fetch = (async input => { requests.push(String(input)); return Response.json({ ok: false, enabled: false, root: "/absent" }); }) as typeof fetch;
  const panel = new MemoryPanel();
  panel.connection = { apiBase: "http://remote.test/prefix/api/memory", eventsUrl: "" };
  document.body.append(panel);
  try {
    const wizard = document.createElement("div");
    const input = document.createElement("input");
    wizard.attachShadow({ mode: "open" }).append(input); document.body.append(wizard); input.focus();
    // The host that describes the page hears the drawer open and close through the kit's panel-changed event.
    let changes = 0;
    document.addEventListener("mlx-panel-changed", () => { changes++; });
    await panel.open();
    expect(changes).toBe(1);
    expect(requests).toEqual(["http://remote.test/prefix/api/memory/status"]);
    expect(panel.isOpen()).toBe(true);
    expect(document.querySelector("#mem-empty-init")).not.toBeNull();
    panel.close();
    expect(changes).toBe(2);
    panel.close(); // already closed: nothing to report
    expect(changes).toBe(2);
    expect(wizard.shadowRoot!.activeElement).toBe(input);
    wizard.remove();
    panel.remove(); document.body.append(panel);
    const overlay = panel.querySelector("#mem-overlay")!;
    let closes = 0;
    const original = overlay.classList.remove.bind(overlay.classList);
    overlay.classList.remove = (...tokens: string[]) => { if (tokens.includes("open")) closes++; original(...tokens); };
    await panel.open();
    overlay.dispatchEvent(new win.MouseEvent("click", { bubbles: true }) as unknown as Event);
    expect(closes).toBe(1);
    expect(panel.isOpen()).toBe(false);
    expect(requests).toHaveLength(1);
  } finally { panel.remove(); globalThis.fetch = saved; }
});

test("the panel-changed event follows the view it describes: the article a chip opens, the list on reopen, a row and Back", async () => {
  const saved = globalThis.fetch;
  globalThis.fetch = (async (input: string) => {
    const url = String(input);
    if (url.endsWith("/status")) return Response.json({ ok: true, enabled: true, status: { root: "/vault", exists: true, articleCount: 1, referenceCount: 0, isGitRepo: true, recentArticles: [{ article: "Travel_plans", mtimeMs: Date.now() }] } });
    if (url.endsWith("/list")) return Response.json({ ok: true, articles: ["Travel_plans"], reference: [] });
    if (url.includes("/article?")) return Response.json({ ok: true, content: "# Travel plans\n\nLisbon in May." });
    if (url.includes("/links?")) return Response.json({ ok: true, outbound: [], inbound: [] });
    return Response.json({ ok: false });
  }) as typeof fetch;
  const panel = new MemoryPanel();
  panel.connection = { apiBase: "http://remote.test/api/memory", eventsUrl: "" };
  document.body.append(panel);
  // What the drawer shows at the moment each change is raised: that is what a host's snapshot describes.
  const seen: string[] = [];
  const showing = () => !panel.isOpen() ? "closed"
    : panel.querySelector("#mem-panel")!.classList.contains("reading") ? `article: ${panel.querySelector("#mem-title")!.textContent}`
    : `list${panel.querySelector("#mem-search") ? " with its search" : ""}`;
  const record = () => { seen.push(showing()); };
  document.addEventListener("mlx-panel-changed", record);
  try {
    await panel.open("Travel_plans"); // a provenance chip
    expect(seen).toEqual(["article: Travel plans"]);
    panel.close();
    await panel.open(); // the sidebar entry: the list, not the article the drawer last showed
    expect(seen).toEqual(["article: Travel plans", "closed", "list with its search"]);
    (panel.querySelector(".mem-art") as HTMLElement).click();
    await settle();
    expect(seen.at(-1)).toBe("article: Travel plans");
    (panel.querySelector("#mem-back") as HTMLElement).click();
    await settle();
    expect(seen.at(-1)).toBe("list with its search");
    expect(seen).toHaveLength(5);
  } finally { document.removeEventListener("mlx-panel-changed", record); panel.remove(); globalThis.fetch = saved; }
});

test("a slower earlier view never overwrites the newer one, and nothing renders or reports after the drawer closed", async () => {
  const saved = globalThis.fetch;
  // The slow article answers only when released; everything else answers at once.
  const gates = new Map<string, () => void>();
  const gated = (key: string, body: unknown) => new Promise<Response>((resolve) => { gates.set(key, () => resolve(Response.json(body))); });
  const release = (key: string) => { gates.get(key)!(); gates.delete(key); };
  globalThis.fetch = (async (input: string) => {
    const url = String(input);
    if (url.endsWith("/status")) return Response.json({ ok: true, enabled: true, status: { root: "/vault", exists: true, articleCount: 2, referenceCount: 0, isGitRepo: true, recentArticles: [] } });
    if (url.endsWith("/list")) return Response.json({ ok: true, articles: ["Slow_one", "Fast_one"], reference: [] });
    if (url.includes("/article?name=Slow_one")) return gated("slow", { ok: true, content: "# Slow one\n\nThe slow article's text." });
    if (url.includes("/article?")) return Response.json({ ok: true, content: "# Fast one\n\nThe fast article's text." });
    if (url.includes("/links?")) return Response.json({ ok: true, outbound: [], inbound: [] });
    return Response.json({ ok: false });
  }) as typeof fetch;
  const panel = new MemoryPanel();
  panel.connection = { apiBase: "http://remote.test/api/memory", eventsUrl: "" };
  document.body.append(panel);
  const seen: string[] = [];
  const title = () => panel.querySelector("#mem-title")!.textContent;
  const body = () => panel.querySelector("#mem-body")!.textContent ?? "";
  const record = () => { seen.push(panel.isOpen() ? `${panel.querySelector("#mem-panel")!.classList.contains("reading") ? "article" : "list"}: ${title()}` : "closed"); };
  document.addEventListener("mlx-panel-changed", record);
  try {
    // The slow article is asked for, then the fast one: the fast one shows and reports, and the slow answer,
    // arriving later, is dropped instead of replacing it.
    const slow = panel.open("Slow_one");
    await settle();
    expect(seen).toEqual([]);
    await panel.open("Fast_one");
    expect(seen).toEqual(["article: Fast one"]);
    expect(body()).toContain("The fast article's text.");
    release("slow");
    await slow;
    await settle();
    expect(seen).toEqual(["article: Fast one"]);
    expect(title()).toBe("Fast one");
    expect(body()).not.toContain("The slow article's text.");
    // Back to the list while the slow article is still loading: the list wins the same way.
    const slowAgain = panel.open("Slow_one");
    await settle();
    (panel.querySelector("#mem-back") as HTMLElement).click();
    await settle();
    expect(seen.at(-1)).toBe("list: Memory");
    release("slow");
    await slowAgain;
    await settle();
    expect(seen.at(-1)).toBe("list: Memory");
    expect(title()).toBe("Memory");
    expect(body()).not.toContain("The slow article's text.");
    // Closed while the slow article is still loading: closing reports once, and the late answer reports nothing.
    const slowClosed = panel.open("Slow_one");
    await settle();
    panel.close();
    expect(seen.at(-1)).toBe("closed");
    const reported = seen.length;
    release("slow");
    await slowClosed;
    await settle();
    expect(seen).toHaveLength(reported);
    expect(panel.isOpen()).toBe(false);
  } finally { document.removeEventListener("mlx-panel-changed", record); panel.remove(); globalThis.fetch = saved; }
});

test("attachChat works on the slots it is handed: memory's classes and wiring on them, its notices through ui.notify", async () => {
  const requests: string[] = [];
  let enabled = false;
  const saved = globalThis.fetch;
  globalThis.fetch = (async (input: string, init?: RequestInit) => {
    const url = String(input);
    requests.push(`${init?.method ?? "GET"} ${url}`);
    if (url.endsWith("/status")) return Response.json(enabled
      ? { ok: true, enabled: true, status: { root: "/vault", exists: true, articleCount: 3, referenceCount: 0, isGitRepo: true, recentArticles: [{ article: "Travel_plans", mtimeMs: Date.now() }] } }
      : { ok: true, enabled: false, root: "/absent" });
    if (url.endsWith("/init")) { enabled = true; return Response.json({ ok: true, result: { root: "/vault", gitInitialized: true } }); }
    if (url.endsWith("/list")) return Response.json({ ok: true, articles: ["Travel_plans"], reference: [] });
    return Response.json({ ok: true, adapters: [] });
  }) as typeof fetch;
  localStorage.clear();
  const notices: [string, string | undefined][] = [];
  const panel = new MemoryPanel();
  panel.connection = { apiBase: "/api/memory", eventsUrl: "", ui: { notify: (message, kind) => { notices.push([message, kind]); } } };
  document.body.append(panel);
  // The chat's elements as a chat hands them over: memory finds nothing by id, so these carry none.
  const slots: ChatSlots = {
    entry: document.createElement("button"), count: document.createElement("span"), consent: document.createElement("div"),
    consentYes: document.createElement("button"), consentSkip: document.createElement("button"), chips: document.createElement("div"),
  };
  slots.entry.style.display = "none";
  slots.entry.append(slots.count);
  slots.consent.append(slots.consentSkip, slots.consentYes);
  document.body.append(slots.entry, slots.consent, slots.chips);
  try {
    panel.attachChat(slots);
    expect([slots.entry.className, slots.count.className, slots.consent.className]).toEqual(["mem-entry", "mem-entry-count", "mem-consent"]);
    expect(slots.entry.getAttribute("aria-controls")).toBe("mem-overlay");
    await settle();
    expect(slots.entry.style.display).toBe("");
    expect(slots.count.textContent).toBe("Set up");
    expect(slots.consent.classList.contains("show")).toBe(true); // no vault yet, never dismissed
    expect(slots.chips.children).toHaveLength(0); // nothing to personalise with
    slots.consentYes.click();
    await settle();
    expect(requests).toContain("POST /api/memory/init");
    expect(notices).toEqual([["Memory vault created", "ok"]]);
    expect(slots.consent.classList.contains("show")).toBe(false);
    expect(slots.count.textContent).toBe("3");
    expect(panel.isOpen()).toBe(true);
    expect(slots.entry.getAttribute("aria-expanded")).toBe("true");
    panel.close();
    expect(slots.entry.getAttribute("aria-expanded")).toBe("false");
    slots.entry.click();
    await settle();
    expect(panel.isOpen()).toBe(true);
    panel.close();
    expect(document.getElementById("toasts")).toBeNull();
  } finally { panel.remove(); for (const element of [slots.entry, slots.consent, slots.chips]) element.remove(); globalThis.fetch = saved; }
});
