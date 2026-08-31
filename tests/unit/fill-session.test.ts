// FillSession — the per-request proposal table's matching, clamping, and
// commit contract (K3a/K3c). Pure token ids: no model, no tokenizer, no
// template.
import { describe, expect, test } from "bun:test";
import {
  FillSession,
  fillEchoConfig,
  fillMaxSpan,
  resolveFillMode,
  StrictRowSource,
  type FillPlan,
  type FillRow,
  type Proposal,
  type ProposalSource,
} from "../../src/fill/fill-session";
import { configureRuntime } from "../../src/runtime-config";

const plan = (rows: FillRow[], extra: Partial<FillPlan> = {}): FillPlan => ({
  rows, echo: null, eos: [99], ...extra,
});
const row = (trigger: number[], emit: number[], kind: FillRow["kind"] = "scaffold"): FillRow =>
  ({ trigger, emit, kind });
/** push + commit-everything, the assert-policy caller's shape. */
const fill = (s: FillSession, token: number, budget?: number): number[] | null => {
  const p = budget === undefined ? s.push(token) : s.push(token, budget);
  if (!p) return null;
  s.commit(p, p.ids.length);
  return p.ids;
};

describe("MLX_BUN_FILL mode", () => {
  test("off by default; strict and echo opt in; anything else is an error", () => {
    let restore = configureRuntime({ MLX_BUN_FILL: undefined });
    try { expect(resolveFillMode()).toBe("off"); } finally { restore(); }
    restore = configureRuntime({ MLX_BUN_FILL: "strict" });
    try { expect(resolveFillMode()).toBe("strict"); } finally { restore(); }
    restore = configureRuntime({ MLX_BUN_FILL: "echo" });
    try { expect(resolveFillMode()).toBe("echo"); } finally { restore(); }
    restore = configureRuntime({ MLX_BUN_FILL: "greedy" });
    try {
      expect(() => resolveFillMode()).toThrow(/expected off\|strict\|echo/);
    } finally { restore(); }
  });

  test("span and echo knobs read their env overrides", () => {
    expect(fillMaxSpan()).toBe(32);
    expect(fillEchoConfig()).toMatchObject({ k: 8, maxCandidates: 24, indexMax: 131072 });
    const restore = configureRuntime({
      MLX_BUN_FILL_MAX_SPAN: "8", MLX_BUN_FILL_K: "4",
      MLX_BUN_FILL_CANDIDATES: "3", MLX_BUN_FILL_INDEX_MAX: "2048",
    });
    try {
      expect(fillMaxSpan()).toBe(8);
      expect(fillEchoConfig()).toMatchObject({
        k: 4, maxSpan: 8, maxCandidates: 3, indexMax: 2048,
      });
    } finally { restore(); }
  });
});

describe("strict rows as a ProposalSource", () => {
  test("a row fires on an exact history suffix and always asserts", () => {
    const s = new FillSession(plan([row([7], [11, 12, 13])]), [1, 2]);
    expect(s.push(3)).toBeNull();
    const p = s.push(7)!;
    expect(p).toMatchObject({ ids: [11, 12, 13], policy: "assert", origin: "template" });
    s.commit(p, p.ids.length);
    expect(s.stats).toMatchObject({
      events: 1, injected: 3, strict: 3, echo: 0, spanLens: [3], decodeSteps: 2,
    });
  });

  test("name and key rows are schema-origin; scaffold/close/turn-end are template", () => {
    const src = new StrictRowSource([row([1], [2, 3], "name"), row([4], [5, 6], "close")]);
    const view = (tail: number[]) => ({ length: tail.length, budget: 99, tail: () => tail });
    expect(src.propose(view([1]))!.origin).toBe("schema");
    expect(src.propose(view([4]))!.origin).toBe("template");
  });

  test("a multi-token trigger only fires on the full sequence", () => {
    const s = new FillSession(plan([row([4, 5, 6], [20, 21])]), []);
    expect(fill(s, 5)).toBeNull();
    expect(fill(s, 6)).toBeNull(); // 5,6 is not 4,5,6
    expect(fill(s, 4)).toBeNull();
    expect(fill(s, 5)).toBeNull();
    expect(fill(s, 6)).toEqual([20, 21]);
  });

  test("committed ids join the history, so a follow-on row can chain", () => {
    const s = new FillSession(plan([
      row([7], [11, 12]),
      row([7, 11, 12, 13], [30, 31], "name"),
    ]), []);
    expect(fill(s, 7)).toEqual([11, 12]);
    expect(fill(s, 13)).toEqual([30, 31]);
    expect(s.stats).toMatchObject({ events: 2, injected: 4 });
  });

  test("nothing enters the history until commit", () => {
    const s = new FillSession(plan([
      row([7], [11, 12]),
      row([7, 11, 12, 13], [30, 31], "name"),
    ]), []);
    const p = s.push(7)!;
    s.commit(p, 0);                 // engine declined
    expect(s.stats.events).toBe(0);
    expect(fill(s, 13)).toBeNull(); // the chain never happened
  });

  test("the prompt tail seeds the history (a turn re-rendered mid-scaffold)", () => {
    const s = new FillSession(plan([row([8, 9], [40, 41])]), [1, 2, 8]);
    expect(fill(s, 9)).toEqual([40, 41]);
  });

  test("the longest matching trigger wins", () => {
    const s = new FillSession(plan([
      row([5], [1, 1, 1]),
      row([3, 4, 5], [2, 2]),
    ]), []);
    fill(s, 3);
    fill(s, 4);
    expect(fill(s, 5)).toEqual([2, 2]);
  });
});

describe("clamping", () => {
  test("everything at or after the first EOS id is dropped", () => {
    const s = new FillSession(plan([row([7], [11, 12, 99, 13])]), []);
    expect(fill(s, 7)).toEqual([11, 12]);
    expect(s.stats.indexTruncated).toBe(1);
  });

  test("a span whose EOS leaves fewer than 2 ids does not fill at all", () => {
    const s = new FillSession(plan([row([7], [11, 99, 12, 13])]), []);
    expect(fill(s, 7)).toBeNull();
    expect(s.stats.events).toBe(0);
  });

  test("an ECHO span may END at a delimiter but never continues past one", () => {
    const echoish: ProposalSource = {
      name: "echoish",
      propose: () => ({ ids: [10, 11, 12, 13], policy: "assert", origin: "echo" }),
    };
    const s = new FillSession(
      plan([], { delimiters: new Set([12]) }), [], { sources: [echoish] });
    const p = s.push(7)!;
    expect(p.ids).toEqual([10, 11, 12]);
  });

  test("delimiters never clamp a STRICT row — a scaffold is full of quotes", () => {
    // The same ids as a template span like `{"name": "`: the delimiter token
    // is structure here, not the end of a value.
    const s = new FillSession(
      plan([row([7], [10, 11, 12, 13])], { delimiters: new Set([12]) }), []);
    expect(fill(s, 7)).toEqual([10, 11, 12, 13]);
  });

  test("the caller's token budget caps the span; a zero budget never fills", () => {
    const s = new FillSession(plan([row([7], [1, 2, 3, 4, 5])]), []);
    expect(fill(s, 7, 3)).toEqual([1, 2, 3]);
    expect(fill(s, 7, 0)).toBeNull();
    expect(fill(s, 7, 1)).toBeNull(); // a 1-token fill saves no forward
    expect(fill(s, 7, 2)).toEqual([1, 2]);
  });

  test("maxSpan caps the span independently of the budget", () => {
    const s = new FillSession(plan([row([7], [1, 2, 3, 4, 5])]), [], { maxSpan: 2 });
    expect(fill(s, 7)).toEqual([1, 2]);
  });

  test("a 1-id row can never fire (no forward is saved)", () => {
    const s = new FillSession(plan([row([7], [42])]), []);
    expect(fill(s, 7)).toBeNull();
    expect(s.stats.events).toBe(0);
  });

  test("the returned span is a copy — the caller cannot mutate the row", () => {
    const r = row([7], [1, 2, 3]);
    const s = new FillSession(plan([r]), []);
    fill(s, 7)!.push(4);
    expect(r.emit).toEqual([1, 2, 3]);
  });
});

describe("verify accounting", () => {
  const verifySource: ProposalSource = {
    name: "test",
    windowNeeded: 8,
    propose: (view) =>
      view.tail(1)[0] === 7
        ? { ids: [1, 2, 3, 4], policy: "verify", origin: "echo" } as Proposal
        : null,
  };

  test("a partial accept records accepted and rejected tokens", () => {
    const s = new FillSession(plan([]), [], { sources: [verifySource] });
    const p = s.push(7)!;
    expect(p.policy).toBe("verify");
    s.commit(p, 2);
    expect(s.stats).toMatchObject({
      events: 1, injected: 2, echo: 2, strict: 0,
      verifyAccepted: 2, verifyRejected: 2,
    });
    // Only the accepted ids are history: a follow-on match sees 7,1,2.
    expect(s.tail(4)).toEqual([7, 1, 2]);
  });

  test("a rejection at position 0 costs nothing and injects nothing", () => {
    const s = new FillSession(plan([]), [], { sources: [verifySource] });
    const p = s.push(7)!;
    s.commit(p, 0);
    expect(s.stats).toMatchObject({
      events: 0, injected: 0, verifyAccepted: 0, verifyRejected: 4,
    });
  });

  test("checkpoint time and unsupported-rewind drops are counted", () => {
    const s = new FillSession(plan([]), [], { sources: [verifySource] });
    s.noteVerifyEvent(1.5);
    s.noteVerifyUnsupported();
    expect(s.stats).toMatchObject({
      verifyEvents: 1, checkpointMs: 1.5, verifyUnsupported: 1,
    });
  });
});

describe("mismatch policy", () => {
  test("a rejected tool-call parse disarms strict rows for the rest of the request", () => {
    const s = new FillSession(plan([row([7], [11, 12])]), []);
    expect(fill(s, 7)).toEqual([11, 12]);
    s.noteParseFailure();
    expect(s.strictEnabled).toBe(false);
    expect(s.stats.parseFallback).toBe(1);
    expect(fill(s, 7)).toBeNull();
    // History still advances, so telemetry stays honest.
    expect(s.stats.decodeSteps).toBe(2);
  });

  test("a parse failure with no armed row is not a fill fallback", () => {
    const s = new FillSession(plan([row([7], [11, 12])]), []);
    fill(s, 3);
    s.noteParseFailure();
    expect(s.stats.parseFallback).toBe(0);
    expect(s.strictEnabled).toBe(true);
  });

  test("discarded pipeline samples are counted, not inferred", () => {
    const s = new FillSession(plan([row([7], [11, 12])]), []);
    fill(s, 7);
    s.noteWastedSample();
    expect(s.stats.wastedSamples).toBe(1);
  });
});
