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
