// P9-T2 — gate plumbing for the north-star acceptance harness.
//
// Proves, with NO GPU and NO cloud judge (a stub answerer), that the five-gate
// machinery is correct: the byte counters (read vs find bucketing + sizes), the
// embedding tripwire (no_vector), the no-network interceptor (local_only), and
// the silent-colleague leak regex. Also asserts the frozen Q1-Q6 query set is
// grounded in the smoke vault — every read step resolves to a real article +
// section. The full GPU + judge run is RunJudge; this is the structural proof.

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { beforeAll, describe, expect, it } from "bun:test";

import { getEmbedCounter, resetEmbedCounter } from "../src/embed";
import { extractSection } from "../src/memory/vault";
import {
  evaluateGates,
  InstrumentedReader,
  loadQueries,
  runQuery,
  smokeVaultRoot,
  stubAnswerer,
  toAnswerCase,
  violatesSilent,
  withNetworkGuard,
  type QueryOutcome,
  GATE_NAMES,
  MAX_READ_BYTES,
} from "../scripts/memory/eval-northstar";

const SMOKE = `${process.env.HOME}/.mlx-bun/wiki-smoke`;
const hasSmoke = existsSync(join(SMOKE, "articles"));

// ---- pure gate primitives (no vault, no model) ------------------------

describe("northstar — silent-colleague leak regex", () => {
  it("flags retrieval-report phrasings", () => {
    expect(violatesSilent("Per the wiki, the Sigma 150-600 is your pick.")).toBe(true);
    expect(violatesSilent("According to your notes, you adapt M42 glass.")).toBe(true);
    expect(violatesSilent("Your wiki says you own the Helios 44-2.")).toBe(true);
    expect(violatesSilent("Welcome back — I see you're shooting anamorphic.")).toBe(true);
  });
  it("passes a natural continuation answer", () => {
    expect(violatesSilent("For real reach on a budget the Sigma 150-600 is the sane pick.")).toBe(false);
    expect(violatesSilent("Yes — your M42 lenses adapt with an M42 to L-Mount adapter.")).toBe(false);
  });
});

describe("northstar — no-network interceptor (local_only)", () => {
  it("records and blocks any fetch escape", async () => {
    const guarded = await withNetworkGuard(async () => {
      await fetch("https://example.com/leak");
      return "unreachable";
    });
    expect(guarded.attempts.length).toBe(1);
    expect(guarded.attempts[0]).toContain("example.com");
    expect(guarded.error).toBeDefined();
  });
  it("leaves a purely-local phase with zero attempts and restores fetch", async () => {
    const before = globalThis.fetch;
    const guarded = await withNetworkGuard(async () => "local-only");
    expect(guarded.attempts.length).toBe(0);
    expect(guarded.result).toBe("local-only");
    expect(globalThis.fetch).toBe(before); // restored
  });
});

describe("northstar — embedding tripwire counter", () => {
  it("starts and stays at zero with no embed calls", () => {
    resetEmbedCounter();
    expect(getEmbedCounter()).toBe(0);
  });
});

describe("northstar — evaluateGates over synthetic outcomes", () => {
  const base: QueryOutcome = {
    id: "QX",
    question: "q",
    answer: "The Sigma 150-600 is the value pick for reach.",
    context: "x".repeat(1500),
    contextBytes: 1500,
    maxReadBytes: 1500,
    reads: [],
    finds: [],
    embedCalls: 0,
    networkAttempts: [],
  };

  it("passes the four mechanical gates on a clean local outcome; correctness pends without a judge", () => {
    const g = evaluateGates(base);
    expect(g.context_budget).toBe(true);
    expect(g.no_vector).toBe(true);
    expect(g.local_only).toBe(true);
    expect(g.silent).toBe(true);
    expect(g.correctness).toBeNull();
  });

  it("fails no_vector on any embedding call and local_only on a network attempt", () => {
    expect(evaluateGates({ ...base, embedCalls: 1 }).no_vector).toBe(false);
    expect(evaluateGates({ ...base, networkAttempts: ["https://x"] }).local_only).toBe(false);
  });

  it("fails context_budget when a single read busts the 2 KB cap", () => {
    expect(evaluateGates({ ...base, maxReadBytes: MAX_READ_BYTES + 1 }).context_budget).toBe(false);
  });

  it("fails silent on a 'per the wiki' answer", () => {
    expect(evaluateGates({ ...base, answer: "Per the wiki, it's the Sigma." }).silent).toBe(false);
  });

  it("derives correctness + silent from the cloud-judge verdict when present", () => {
    expect(evaluateGates(base, { id: "QX", correct: true, silentViolation: false, reason: "" }).correctness).toBe(true);
    expect(evaluateGates(base, { id: "QX", correct: false, silentViolation: false, reason: "" }).correctness).toBe(false);
    // The judge can catch a subtler silent leak the regex missed.
    expect(evaluateGates(base, { id: "QX", correct: true, silentViolation: true, reason: "" }).silent).toBe(false);
  });

  it("an errored outcome fails every mechanical gate", () => {
    const g = evaluateGates({ ...base, error: "boom" });
    expect(g.context_budget).toBe(false);
    expect(g.no_vector).toBe(false);
    expect(g.local_only).toBe(false);
    expect(g.silent).toBe(false);
  });

  it("exposes exactly the five named gates", () => {
    expect([...GATE_NAMES]).toEqual(["correctness", "context_budget", "no_vector", "local_only", "silent"]);
  });
});

// ---- frozen query set is grounded in the smoke vault ------------------

describe("northstar — frozen query set", () => {
  it("freezes Q1-Q6 with Q6 as the negative control", () => {
    const set = loadQueries();
    expect(set.frozen).toBe(true);
    expect(set.queries.map((q) => q.id)).toEqual(["Q1", "Q2", "Q3", "Q4", "Q5", "Q6"]);
    const q6 = set.queries.find((q) => q.id === "Q6")!;
    expect(q6.negative_control).toBe(true);
    expect(q6.retrieval.read.length).toBe(0); // nothing on file → no read
    // Every non-control query authors expected_points + a schematic gold answer.
    for (const q of set.queries) {
      expect(q.expected_points.length).toBeGreaterThan(0);
      expect(q.gold_answer.length).toBeGreaterThan(0);
      expect(q.question.length).toBeGreaterThan(0);
    }
  });

  it.skipIf(!hasSmoke)("grounds every read step in a real smoke-vault article + section", () => {
    const set = loadQueries();
    for (const q of set.queries) {
      for (const step of q.retrieval.read) {
        const stem = String(step.params.stem);
        const path = join(SMOKE, "articles", `${stem}.md`);
        expect(existsSync(path), `${q.id}: article ${stem} exists`).toBe(true);
        if (step.tool === "memory_section") {
          const content = readFileSync(path, "utf8");
          const anchor = String(step.params.anchor);
          expect(extractSection(content, anchor), `${q.id}: section ${stem}#${anchor} resolves`).not.toBeNull();
        }
      }
    }
  });
});

// ---- byte counters + tripwire through the real read tools -------------

describe.skipIf(!hasSmoke)("northstar — instrumented reader over the smoke vault", () => {
  beforeAll(() => {
    process.env.MLX_BUN_WIKI = SMOKE;
  });

  it("buckets context reads vs FIND navigation and counts bytes that match extractSection", async () => {
    const reader = new InstrumentedReader();
    await reader.call({ tool: "memory_resolve", params: { surface: "L-Mount" } });
    await reader.call({ tool: "memory_section", params: { stem: "L-Mount", anchor: "adapting-vintage-lenses" } });

    expect(reader.finds.length).toBe(1); // resolve = FIND
    expect(reader.reads.length).toBe(1); // section = context-bearing read
    expect(reader.finds[0]!.tool).toBe("memory_resolve");
    expect(reader.reads[0]!.tool).toBe("memory_section");

    const content = readFileSync(join(SMOKE, "articles", "L-Mount.md"), "utf8");
    const section = extractSection(content, "adapting-vintage-lenses")!;
    expect(reader.reads[0]!.bytes).toBe(Buffer.byteLength(section, "utf8"));
    expect(reader.maxReadBytes).toBe(reader.reads[0]!.bytes);
  });

  it("runs a real query through the stub answerer with zero embeddings and zero network", async () => {
    const set = loadQueries();
    const q3 = set.queries.find((q) => q.id === "Q3")!;
    const o = await runQuery(q3, stubAnswerer);
    expect(o.error).toBeUndefined();
    expect(o.embedCalls).toBe(0); // no_vector tripwire
    expect(o.networkAttempts.length).toBe(0); // local_only
    expect(o.maxReadBytes).toBeLessThanOrEqual(MAX_READ_BYTES); // no read > 2 KB
    expect(o.answer.length).toBeGreaterThan(0);

    const g = evaluateGates(o);
    expect(g.context_budget && g.no_vector && g.local_only && g.silent).toBe(true);
    expect(toAnswerCase(q3, o)).toMatchObject({ id: "Q3", question: q3.question, silentContract: true });
  });

  it("Q6 negative control retrieves no context and the stub declines without inventing", async () => {
    const set = loadQueries();
    const q6 = set.queries.find((q) => q.id === "Q6")!;
    const o = await runQuery(q6, stubAnswerer);
    expect(o.context).toBe("");
    expect(o.reads.length).toBe(0);
    expect(o.answer.toLowerCase()).toContain("on file");
    expect(violatesSilent(o.answer)).toBe(false);
  });
});
