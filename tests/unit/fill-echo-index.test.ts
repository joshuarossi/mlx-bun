// The echo source (K3c) — the growing k-gram index and, more importantly, the
// branch-point rule that decides how far a copied span may run.
//
// The index is checked against a brute-force oracle over random sequences: a
// hash bucket must find exactly the positions a full scan would, in the same
// nearest-first order, and hash collisions must be invisible (candidates are
// verified id-for-id).
//
// The stopping rule is the interesting half. A k-gram match says where this
// context occurred before; it says nothing about how far the future agrees
// with the past. So a span extends only while EVERY nearby occurrence
// continues the same way, and stops the moment the session's own history
// forks — which is exactly where old-query-vs-new-query divergence lives.
import { describe, expect, test } from "bun:test";
import { EchoIndex, EchoSource, type EchoConfig } from "../../src/fill/echo-index";
import type { TokenView } from "../../src/fill/proposal";

const K = 4;
const config = (over: Partial<EchoConfig> = {}): EchoConfig => ({
  k: K, maxSpan: 32, maxCandidates: 24, indexMax: 1 << 20,
  delimiters: new Set<number>(), ...over,
});

const view = (tail: number[], budget = 999): TokenView => ({
  length: tail.length,
  budget,
  tail: (n: number) => (n >= tail.length ? tail : tail.slice(tail.length - n)),
});

/** What a full scan would return: positions whose k-gram matches AND which
 *  have a continuation, most recent first, capped. */
function bruteCandidates(
  seq: readonly number[], gram: readonly number[], k: number, cap: number,
): number[] {
  const hits: number[] = [];
  for (let p = 0; p + k < seq.length; p++) {
    let ok = true;
    for (let j = 0; j < k; j++) if (seq[p + j] !== gram[j]) { ok = false; break; }
    if (ok) hits.push(p);
  }
  return hits.reverse().slice(0, cap);
}

describe("EchoIndex vs a brute-force scan", () => {
  test("finds exactly the positions a full scan finds, nearest first", () => {
    // A small alphabet guarantees plenty of repeated k-grams.
    let seed = 12345;
    const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) % 7;
    const seq = Array.from({ length: 400 }, rnd);
    const index = new EchoIndex(K, 1 << 20);
    index.append(seq);
    for (let i = 0; i + K <= seq.length; i++) {
      const gram = seq.slice(i, i + K);
      expect(index.candidates(gram, 24)).toEqual(bruteCandidates(seq, gram, K, 24));
    }
  });

  test("incremental appends match one bulk append", () => {
    const seq = [5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 9, 1, 2, 3, 4, 7];
    const bulk = new EchoIndex(K, 1 << 20);
    bulk.append(seq);
    const drip = new EchoIndex(K, 1 << 20);
    for (const id of seq) drip.append([id]);
    const gram = [1, 2, 3, 4];
    expect(drip.candidates(gram, 24)).toEqual(bulk.candidates(gram, 24));
    expect(drip.candidates(gram, 24).length).toBe(3);
  });

  test("the nearest occurrences win when the bucket is over the cap", () => {
    const seq: number[] = [];
    for (let i = 0; i < 10; i++) seq.push(1, 2, 3, 4, 100 + i);
    const index = new EchoIndex(K, 1 << 20);
    index.append(seq);
    const nearest = index.candidates([1, 2, 3, 4], 3);
    expect(nearest).toEqual([45, 40, 35]);            // most recent three
    expect(index.candidates([1, 2, 3, 4], 24).length).toBe(10);
  });

  test("a k-gram with no continuation yet is not a candidate", () => {
    const index = new EchoIndex(K, 1 << 20);
    index.append([1, 2, 3, 4]);
    expect(index.candidates([1, 2, 3, 4], 24)).toEqual([]);
    index.append([5]);
    expect(index.candidates([1, 2, 3, 4], 24)).toEqual([0]);
  });

  test("the memory cap freezes the index instead of growing forever", () => {
    const index = new EchoIndex(K, 8);
    index.append([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    expect(index.length).toBe(8);
    expect(index.frozen).toBe(true);
  });
});

describe("branch-point stopping", () => {
  const anchorsFor = (seq: number[], gram: number[]) => {
    const index = new EchoIndex(K, 1 << 20);
    index.append(seq);
    return { index, anchors: index.candidates(gram, 24) };
  };

  test("a single occurrence extends as far as history allows, uncorroborated", () => {
    const { index, anchors } = anchorsFor([1, 2, 3, 4, 7, 8, 9], [1, 2, 3, 4]);
    expect(index.extend(anchors, 32, new Set()))
      .toEqual({ ids: [7, 8, 9], branchStop: false, agreed: 1 });
  });

  test("agreeing occurrences extend and corroborate; the span stops where they fork", () => {
    // …1 2 3 4 | 7 8 then 9 in one history and 5 in the other.
    const seq = [1, 2, 3, 4, 7, 8, 9, 0, 1, 2, 3, 4, 7, 8, 5];
    const { index, anchors } = anchorsFor(seq, [1, 2, 3, 4]);
    expect(anchors.length).toBe(2);
    expect(index.extend(anchors, 32, new Set()))
      .toEqual({ ids: [7, 8], branchStop: true, agreed: 2 });
  });

  test("a fork at the very first position proposes nothing", () => {
    const seq = [1, 2, 3, 4, 7, 0, 1, 2, 3, 4, 9];
    const { index, anchors } = anchorsFor(seq, [1, 2, 3, 4]);
    expect(index.extend(anchors, 32, new Set()))
      .toEqual({ ids: [], branchStop: true, agreed: 0 });
  });

  test("an occurrence that runs out drops out — a prefix is not a disagreement", () => {
    const seq = [1, 2, 3, 4, 7, 8, 9, 0, 1, 2, 3, 4, 7];
    const { index, anchors } = anchorsFor(seq, [1, 2, 3, 4]);
    // The RECENT occurrence has only `7` before the sequence ends; the older
    // one continues 8, 9, … . Extension follows the survivor rather than
    // stopping — and it is not a branch stop, because nothing disagreed.
    expect(index.extend(anchors, 4, new Set()))
      .toEqual({ ids: [7, 8, 9, 0], branchStop: false, agreed: 1 });
  });

  test("a delimiter ENDS the span — it is injected, never passed", () => {
    const seq = [1, 2, 3, 4, 7, 55, 8, 9];
    const { index, anchors } = anchorsFor(seq, [1, 2, 3, 4]);
    expect(index.extend(anchors, 32, new Set([55])))
      .toEqual({ ids: [7, 55], branchStop: false, agreed: 1 });
  });

  test("maxSpan bounds the extension", () => {
    const seq = [1, 2, 3, 4, 7, 8, 9, 10, 11];
    const { index, anchors } = anchorsFor(seq, [1, 2, 3, 4]);
    expect(index.extend(anchors, 2, new Set()).ids).toEqual([7, 8]);
  });
});

describe("EchoSource policy assignment", () => {
  const sourceOver = (seq: number[], over: Partial<EchoConfig> = {}) =>
    new EchoSource(config(over), seq);

  test("CORROBORATED, unambiguous, ending at a delimiter ⇒ assert", () => {
    // The same context continued the same way TWICE — a pattern, not a copy.
    const src = sourceOver([1, 2, 3, 4, 7, 55, 0, 1, 2, 3, 4, 7, 55, 0],
      { delimiters: new Set([55]) });
    expect(src.propose(view([1, 2, 3, 4]))).toMatchObject({
      ids: [7, 55], policy: "assert", origin: "echo", branchStop: false,
    });
  });

  test("a SINGLE occurrence is a copy, not a pattern ⇒ verify", () => {
    // Uncorroborated copies happily replay whatever followed them in the
    // transcript — including another role's turn. The model decides.
    const src = sourceOver([1, 2, 3, 4, 7, 55], { delimiters: new Set([55]) });
    expect(src.propose(view([1, 2, 3, 4]))).toMatchObject({
      ids: [7, 55], policy: "verify",
    });
  });

  test("stopping at a fork ⇒ verify (the model decides)", () => {
    const src = sourceOver([1, 2, 3, 4, 7, 8, 55, 0, 1, 2, 3, 4, 7, 8, 9],
      { delimiters: new Set([55]) });
    expect(src.propose(view([1, 2, 3, 4]))).toMatchObject({
      ids: [7, 8], policy: "verify", branchStop: true,
    });
  });

  test("running out mid-value (no delimiter) ⇒ verify", () => {
    const src = sourceOver([1, 2, 3, 4, 7, 8, 9]);
    expect(src.propose(view([1, 2, 3, 4]))).toMatchObject({
      ids: [7, 8, 9], policy: "verify", branchStop: false,
    });
  });

  test("no anchor, a short tail, or a 1-token continuation propose nothing", () => {
    const src = sourceOver([1, 2, 3, 4, 7, 8]);
    expect(src.propose(view([9, 9, 9, 9]))).toBeNull();   // no such k-gram
    expect(src.propose(view([1, 2, 3]))).toBeNull();      // tail shorter than k
    expect(sourceOver([1, 2, 3, 4, 7]).propose(view([1, 2, 3, 4]))).toBeNull();
  });

  test("observe() grows the index, so a turn can echo itself", () => {
    const src = sourceOver([9, 9]);
    expect(src.propose(view([1, 2, 3, 4]))).toBeNull();
    src.observe([1, 2, 3, 4, 7, 8, 0]);
    expect(src.propose(view([1, 2, 3, 4]))!.ids).toEqual([7, 8, 0]);
  });
});

describe("the delimiter set is what makes an echo assertable", () => {
  test("with no delimiters configured, every echo span is a guess", () => {
    const seq = [1, 2, 3, 4, 7, 8, 0, 1, 2, 3, 4, 7, 8, 0];
    expect(new EchoSource(config({ delimiters: new Set() }), seq)
      .propose(view([1, 2, 3, 4]))!.policy).toBe("verify");
    expect(new EchoSource(config({ delimiters: new Set([8]) }), seq)
      .propose(view([1, 2, 3, 4]))!.policy).toBe("assert");
  });
});
