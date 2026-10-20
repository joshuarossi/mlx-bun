// DOM helpers under happy-dom, the formatters, the fake fetch, and that the entry imports without a document.
import { GlobalWindow } from "happy-dom";
import { beforeAll, describe, expect, it } from "bun:test";
import { bytes, createDisposer, esc, gb, h, injectStyles, listen, ms, num, percent, rate, relativeTime, shortName, tokens, trapFocus, uptime, TOKENS_CSS, BASE_CSS, TOKEN_NAMES } from "../src";
import { fakeFetch, installFakes } from "../src/testing";

let window: GlobalWindow;
beforeAll(() => {
  window = new GlobalWindow({ url: "http://localhost/" });
  Object.assign(globalThis, { window, document: window.document, HTMLElement: window.HTMLElement, KeyboardEvent: window.KeyboardEvent, Event: window.Event });
});

describe("dom", () => {
  it("h builds elements with attributes and children, skipping false and undefined attributes", () => {
    const node = h("button", { class: "btn", "aria-pressed": true, hidden: false, title: undefined, "data-id": 3 }, "Serve", h("span", {}, "!"));
    expect(node.outerHTML).toBe('<button class="btn" aria-pressed="" data-id="3">Serve<span>!</span></button>');
  });
  it("esc escapes the four significant characters", () => {
    expect(esc('<a href="x">&</a>')).toBe("&lt;a href=&quot;x&quot;&gt;&amp;&lt;/a&gt;");
    expect(esc(null)).toBe("");
  });
  it("injectStyles appends a style once per id", () => {
    injectStyles("kit-test", ".a{}"); injectStyles("kit-test", ".b{}");
    expect(document.querySelectorAll("#kit-test")).toHaveLength(1);
    expect(document.getElementById("kit-test")!.textContent).toBe(".a{}");
  });
  it("listen returns a remover and a disposer runs removers newest first", () => {
    const target = document.createElement("div");
    const order: string[] = [];
    const disposer = createDisposer();
    disposer.add(listen(target, "ping", () => order.push("a")));
    disposer.add(() => order.push("disposed-b"));
    disposer.add(listen(target, "ping", () => order.push("c")));
    const ping = () => target.dispatchEvent(new window.Event("ping") as unknown as Event);
    ping();
    expect(disposer.size).toBe(3);
    disposer.dispose();
    ping();
    expect(order).toEqual(["a", "c", "disposed-b"]);
    expect(disposer.size).toBe(0);
  });
  it("trapFocus restores focus to the trigger that opened the overlay", () => {
    document.body.innerHTML = '<button id="trigger">open</button><div id="dialog"><input id="first"><button id="last">x</button></div>';
    const trigger = document.getElementById("trigger")!;
    let open = false;
    const trap = trapFocus(document.getElementById("dialog")!, () => open);
    trigger.focus();
    trap.capture();
    open = true;
    document.getElementById("first")!.focus();
    expect(document.activeElement).toBe(document.getElementById("first"));
    open = false;
    trap.restore();
    expect(document.activeElement).toBe(trigger);
  });
  it("the tokens define every documented name for both themes", () => {
    for (const name of TOKEN_NAMES) expect(TOKENS_CSS.includes(`${name}:`)).toBe(true);
    expect(TOKENS_CSS).toContain('[data-theme="light"]');
    expect(BASE_CSS).not.toContain(":root");
    expect(BASE_CSS).not.toMatch(/\bbody\s*\{/);
  });
});

describe("format", () => {
  it("formats sizes, times, rates and counts, with an em dash for missing values", () => {
    expect([gb(12.25 * 2 ** 30), bytes(612 * 2 ** 20), bytes(41 * 1024), bytes(12), bytes(null)]).toEqual(["12.3 GB", "612 MB", "41 KB", "12 B", "—"]);
    expect([ms(410), ms(1250), ms(150_000), ms(undefined)]).toEqual(["410 ms", "1.25 s", "2.5 min", "—"]);
    expect([uptime(42), uptime(1800), uptime(5412), uptime(300_000)]).toEqual(["42 s", "30 min", "1.5 h", "3.5 d"]);
    expect([rate(31.24), rate(8.456), rate(null)]).toEqual(["31.2 tok/s", "8.46 tok/s", "—"]);
    expect([percent(0.62), percent(0.8123, 1), percent(null)]).toEqual(["62%", "81.2%", "—"]);
    expect([tokens(842), tokens(1204), tokens(32_768), tokens(1.5e6)]).toEqual(["842", "1.2k", "33k", "1.5M"]);
    expect([num(24576), num(1.5, 1), num(NaN)]).toEqual(["24,576", "1.5", "—"]);
    expect(shortName("mlx-community/Qwen3-8B-4bit")).toBe("Qwen3-8B-4bit");
  });
  it("relativeTime reads the way a sidebar expects", () => {
    const now = 1_000_000_000_000;
    expect(relativeTime(now - 10_000, now)).toBe("just now");
    expect(relativeTime(now - 600_000, now)).toBe("10 min ago");
    expect(relativeTime(now - 3 * 3_600_000, now)).toBe("3 h ago");
    expect(relativeTime(now - 36 * 3_600_000, now)).toBe("yesterday");
    expect(relativeTime(now - 5 * 86_400_000, now)).toBe("5 d ago");
    expect(relativeTime(null)).toBe("—");
  });
});

describe("testing fakes", () => {
  it("fakeFetch answers fixtures by method and path, records calls, and 404s the rest", async () => {
    const fetch = fakeFetch({ "/v1/models": { data: [] }, "POST /api/x": (request: Request) => ({ ok: true, echoed: request.method }) });
    expect(await (await fetch("/v1/models")).json()).toEqual({ data: [] });
    expect(await (await fetch("/api/x", { method: "POST", body: JSON.stringify({ a: 1 }) })).json()).toEqual({ ok: true, echoed: "POST" });
    expect((await fetch("/nope")).status).toBe(404);
    expect(fetch.calls).toEqual([{ method: "GET", url: "/v1/models", body: undefined }, { method: "POST", url: "/api/x", body: { a: 1 } }, { method: "GET", url: "/nope", body: undefined }]);
  });
  it("installFakes swaps globals and restores them", () => {
    const original = globalThis.fetch;
    const fake = fakeFetch({});
    const restore = installFakes({ fetch: fake });
    expect(globalThis.fetch).toBe(fake);
    restore();
    expect(globalThis.fetch).toBe(original);
  });
});
