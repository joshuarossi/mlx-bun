import { beforeEach, describe, expect, it } from "bun:test";
import { GlobalWindow } from "happy-dom";
import { emitHostEvent, HOST_EVENTS, onHostEvent } from "../src/host";

describe("host events", () => {
  // The kit creates events with the page's CustomEvent, which under happy-dom is the window's.
  beforeEach(() => { const window = new GlobalWindow(); Object.assign(globalThis, { window, document: window.document, CustomEvent: window.CustomEvent, Event: window.Event }); });
  it("delivers a typed detail to a listener on the window and the remover stops it", () => {
    const seen: unknown[] = [];
    const stop = onHostEvent(HOST_EVENTS.serverStatus, (detail) => seen.push(detail), window);
    emitHostEvent(HOST_EVENTS.serverStatus, { model: "m", online: true, download: null }, window);
    stop();
    emitHostEvent(HOST_EVENTS.serverStatus, { model: "n", online: false, download: null }, window);
    expect(seen).toEqual([{ model: "m", online: true, download: null }]);
  });
  it("a panel's event bubbles out of its element to the document when emitted composed", () => {
    const element = window.document.createElement("div");
    window.document.body.append(element);
    let count = 0;
    onHostEvent(HOST_EVENTS.modelsChanged, () => { count++; }, window.document);
    emitHostEvent(HOST_EVENTS.modelsChanged, undefined, element, { bubbles: true, composed: true });
    expect(count).toBe(1);
  });
});
