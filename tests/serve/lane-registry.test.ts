// FAST: the in-process lane registry (src/serve/lane-registry.ts) — the
// correlation channel between server.ts's per-turn lane decision and
// pi-web.ts's turn_end mapping (docs/design/web-chat-redesign.md §2.3 caveat
// / risk #5). Pure Map wrapper, no model/server needed.

import { beforeEach, describe, expect, it } from "bun:test";
import { clearLaneRegistry, getLane, recordLane } from "../../src/serve/lane-registry";

describe("lane-registry", () => {
  beforeEach(() => {
    clearLaneRegistry();
  });

  it("returns undefined for an id that was never recorded", () => {
    expect(getLane("never-seen")).toBeUndefined();
  });

  it("round-trips a recorded lane", () => {
    recordLane("chatcmpl-1", "serial");
    expect(getLane("chatcmpl-1")).toBe("serial");
  });

  it("lets a later record refine an earlier one for the same id (serial -> serial+spec)", () => {
    recordLane("chatcmpl-2", "serial");
    expect(getLane("chatcmpl-2")).toBe("serial");
    recordLane("chatcmpl-2", "serial+spec");
    expect(getLane("chatcmpl-2")).toBe("serial+spec");
  });

  it("keeps distinct ids independent", () => {
    recordLane("a", "serial");
    recordLane("b", "batched");
    recordLane("c", "serial+spec");
    expect(getLane("a")).toBe("serial");
    expect(getLane("b")).toBe("batched");
    expect(getLane("c")).toBe("serial+spec");
  });

  it("evicts the oldest entry once the bounded cap is exceeded", () => {
    // The cap is an internal implementation constant (512); recording well
    // past it must evict the earliest entries first (insertion-order LRU-ish,
    // not a crash or unbounded growth) while the most recent stay resident.
    for (let i = 0; i < 600; i++) recordLane(`id-${i}`, "serial");
    expect(getLane("id-0")).toBeUndefined(); // evicted
    expect(getLane("id-599")).toBe("serial"); // still resident
  });

  it("clearLaneRegistry drops everything", () => {
    recordLane("x", "batched");
    clearLaneRegistry();
    expect(getLane("x")).toBeUndefined();
  });
});
