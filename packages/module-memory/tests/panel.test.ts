import { expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
const win = new GlobalWindow({ url: "http://localhost/" });
Object.assign(globalThis, { window: win, document: win.document, HTMLElement: win.HTMLElement, customElements: win.customElements, localStorage: win.localStorage });
const { MemoryPanel } = await import("../src/panel");
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
    await panel.open();
    expect(requests).toEqual(["http://remote.test/prefix/api/memory/status"]);
    expect(panel.isOpen()).toBe(true);
    expect(document.querySelector("#mem-empty-init")).not.toBeNull();
    panel.close();
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
  } finally { panel.remove(); globalThis.fetch = saved; await win.happyDOM.close(); }
});
