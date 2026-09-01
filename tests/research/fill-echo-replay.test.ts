// The fill A/B harness end to end (K3d) — recorded sessions in, verdict out,
// against a STUB server. No model, no weights: what is under test is the
// harness's reasoning, not a checkpoint's speed.
//
// REPLAY DOCTRINE: the transcript IS the environment. A model cannot tell an
// executed tool result from a recorded one, so replaying a session with its
// results mocked verbatim is deterministic and side-effect-free — which is
// what makes a whole-corpus A/B possible at all. The stub here stands in for
// the model exactly as the mocked results stand in for the world.
//
// The gate the echo tier has to pass (PLAN K3): task-output agreement must not
// drop within CI AND median wall clock must strictly improve. Both halves are
// exercised, including the ways they FAIL — a harness that can only produce
// PASS is not a gate.
import { afterAll, describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  apparentMultiplier, armRates, bandwidthCheck, byTool, fillVerdict,
  renderBandwidth, renderFillReport, type FillUsage, type TurnRecord,
} from "../../scripts/fill/metrics";
import {
  interleavedAb, prepareSession, replaySession, showcaseSession,
} from "../../scripts/fill/runner";
import type { ReplayTurn } from "../../scripts/fill/session-replay";

const FIXTURES = join(import.meta.dir, "..", "fixtures", "fill-sessions");
const session = (name: string) =>
  prepareSession(name, readFileSync(join(FIXTURES, `${name}.jsonl`), "utf8"));

const sse = (o: unknown) => `data: ${JSON.stringify(o)}\n\n`;

interface StubOptions {
  /** Per-turn think time, so one arm can be made faster than the other. */
  delayMs: number;
  /** Injected tokens to report as usage.fill (0 = no fill block). */
  injected: number;
  /** Turn indices (by message count) where the stub answers WRONGLY. */
  wrongAt?: Set<number>;
}

/** A stub /v1/chat/completions that replays the recording back — the perfect
 *  model — unless the test asks it to be wrong. */
function stubServer(turns: ReplayTurn[], options: StubOptions) {
  const byLen = new Map(turns.map((t) => [t.messages.length, t]));
  return Bun.serve({
    port: 0,
    async fetch(req) {
      const body = await req.json() as { messages: { role: string }[] };
      const turn = byLen.get(body.messages.length);
      const wrong = options.wrongAt?.has(body.messages.length) === true;
      const calls = (turn?.expected.toolCalls ?? []).map((c, index) => ({
        index,
        id: `call_stub_${index}`,
        type: "function" as const,
        function: {
          name: c.name,
          arguments: JSON.stringify(wrong ? { ...c.arguments, path: "WRONG" } : c.arguments),
        },
      }));
      const text = wrong ? "completely different" : (turn?.expected.text ?? "");
      const completion = 40;
      const fill: FillUsage | null = options.injected > 0
        ? {
          events: 2, injected: options.injected, strict: options.injected, echo: 0,
          spanLens: [options.injected], wastedSamples: 2, parseFallback: 0,
          indexTruncated: 0, decodeSteps: completion - options.injected,
          verifyEvents: 0, verifyAccepted: 0, verifyRejected: 0,
          verifyUnsupported: 0, checkpointMs: 0, branchStops: 0,
        }
        : null;
      const stream = new ReadableStream({
        async start(c) {
          const enc = new TextEncoder();
          c.enqueue(enc.encode(sse({ choices: [{ index: 0, delta: { role: "assistant", content: "" }, finish_reason: null }] })));
          await Bun.sleep(options.delayMs);
          if (text) c.enqueue(enc.encode(sse({ choices: [{ index: 0, delta: { content: text }, finish_reason: null }] })));
          if (calls.length)
            c.enqueue(enc.encode(sse({ choices: [{ index: 0, delta: { tool_calls: calls }, finish_reason: null }] })));
          c.enqueue(enc.encode(sse({
            choices: [{ index: 0, delta: {}, finish_reason: calls.length ? "tool_calls" : "stop" }],
            usage: {
              prompt_tokens: 100, completion_tokens: completion, total_tokens: 140,
              prompt_tokens_details: { cached_tokens: 0 }, lane: "serial",
              ...(fill ? { fill } : {}),
            },
          })));
          c.enqueue(enc.encode("data: [DONE]\n\n"));
          c.close();
        },
      });
      return new Response(stream, { headers: { "content-type": "text/event-stream" } });
    },
  });
}

const servers: { stop(): void }[] = [];
const serve = (turns: ReplayTurn[], o: StubOptions) => {
  const s = stubServer(turns, o);
  servers.push(s);
  return { label: o.injected > 0 ? "fill-echo" : "fill-off", url: `http://127.0.0.1:${s.port}` };
};
afterAll(() => { for (const s of servers) s.stop(); });

describe("replaying one session against one arm", () => {
  test("every recorded turn is replayed and scored", async () => {
    const s = session("read-edit-loop");
    const arm = serve(s.turns, { delayMs: 1, injected: 0 });
    const records = await replaySession(s, arm);
    expect(records).toHaveLength(s.turns.length);
    expect(records.every((r) => !r.error)).toBe(true);
    // The stub replays the recording, so every turn agrees.
    expect(records.every((r) => r.taskMatch)).toBe(true);
    expect(records.every((r) => r.completionTokens === 40)).toBe(true);
    expect(records.map((r) => r.toolName)).toEqual(["read", "edit", "read", null]);
  });

  test("a wrong answer is scored as a disagreement, with its divergence point", async () => {
    const s = session("grep-repeat");
    const wrongAt = new Set([s.turns[0]!.messages.length]);
    const arm = serve(s.turns, { delayMs: 1, injected: 0, wrongAt });
    const records = await replaySession(s, arm);
    expect(records[0]!.taskMatch).toBe(false);
    expect(records.slice(1).every((r) => r.taskMatch)).toBe(true);
    const prose = records[records.length - 1]!;
    expect(prose.firstDivergence).toBeNull(); // the prose turn matched exactly
  });

  test("a dead server is recorded on the turn, not thrown", async () => {
    const s = session("grep-repeat");
    const records = await replaySession(s, { label: "dead", url: "http://127.0.0.1:1" });
    expect(records).toHaveLength(s.turns.length);
    expect(records.every((r) => r.error && !r.taskMatch)).toBe(true);
    // Errored turns are excluded from the rates rather than poisoning them.
    expect(armRates(records).turns).toBe(0);
  });
});

describe("the paired verdict", () => {
  const sessions = () => [session("read-edit-loop"), session("grep-repeat")];

  test("PASS: same task outputs, faster median wall clock", async () => {
    const ss = sessions();
    const all = ss.flatMap((s) => s.turns);
    const a = serve(all, { delayMs: 25, injected: 0 });
    const b = serve(all, { delayMs: 4, injected: 16 });
    const { a: ra, b: rb } = await interleavedAb(ss, a, b, 1);
    const v = fillVerdict(ra, rb);
    expect(v.paired).toBe(all.length);
    expect(v.pass).toBe(true);
    expect(v.agreementHolds).toBe(true);
    expect(v.fasterOnMedian).toBe(true);
    expect(v.medianWallRatio).toBeLessThan(1);
    // The fill arm reports the token economics that justify the speedup.
    expect(v.b.fillFrac).toBeCloseTo(16 / 40, 6);
    expect(v.b.decodedTokens).toBe(v.b.completionTokens - v.b.injected);
    expect(renderFillReport("off", "echo", v)).toContain("PASS");
  });

  test("FAIL: faster but the agent stopped making the same calls", async () => {
    const ss = [session("read-edit-loop")];
    const all = ss.flatMap((s) => s.turns);
    const a = serve(all, { delayMs: 25, injected: 0 });
    const b = serve(all, {
      delayMs: 2, injected: 30,
      wrongAt: new Set(all.map((t) => t.messages.length)), // every turn wrong
    });
    const { a: ra, b: rb } = await interleavedAb(ss, a, b, 1);
    const v = fillVerdict(ra, rb);
    expect(v.fasterOnMedian).toBe(true);
    expect(v.agreementHolds).toBe(false);
    expect(v.pass).toBe(false);
    expect(v.verdict).toContain("task agreement dropped");
  });

  test("FAIL: agrees but is not faster", async () => {
    const ss = [session("grep-repeat")];
    const all = ss.flatMap((s) => s.turns);
    const a = serve(all, { delayMs: 2, injected: 0 });
    const b = serve(all, { delayMs: 30, injected: 20 });
    const { a: ra, b: rb } = await interleavedAb(ss, a, b, 1);
    const v = fillVerdict(ra, rb);
    expect(v.agreementHolds).toBe(true);
    expect(v.fasterOnMedian).toBe(false);
    expect(v.pass).toBe(false);
    expect(v.verdict).toContain("did not improve");
  });

  test("a single adverse turn inside the noise does NOT fail the gate", async () => {
    const ss = [session("read-edit-loop")];
    const all = ss.flatMap((s) => s.turns);
    const a = serve(all, { delayMs: 20, injected: 0 });
    const b = serve(all, {
      delayMs: 3, injected: 12,
      wrongAt: new Set([all[0]!.messages.length]), // one of four turns
    });
    const { a: ra, b: rb } = await interleavedAb(ss, a, b, 3);
    const v = fillVerdict(ra, rb);
    // 3 of 12 paired turns swing against B; the one-sided 95% bound still
    // covers zero, so the gate does not fire on noise.
    expect(v.aOnlyAgree).toBe(3);
    expect(v.agreementLowerBound).toBeLessThan(0);
    expect(v.pass).toBe(false);
    // …but a clean run of the same shape passes, which is what makes the
    // bound a gate rather than a rubber stamp.
    const clean = serve(all, { delayMs: 3, injected: 12 });
    const { a: ca, b: cb } = await interleavedAb(ss, a, clean, 3);
    expect(fillVerdict(ca, cb).pass).toBe(true);
  });

  test("interleaving alternates arms so drift lands on both", async () => {
    const ss = [session("grep-repeat")];
    const all = ss.flatMap((s) => s.turns);
    const order: string[] = [];
    const a = serve(all, { delayMs: 1, injected: 0 });
    const b = serve(all, { delayMs: 1, injected: 8 });
    await interleavedAb(ss, a, b, 2, { onTurn: (r) => order.push(r.arm) });
    expect(order).toEqual(Array(all.length * 2).fill(["fill-off", "fill-echo"]).flat());
  });
});

describe("rates, the apparent multiplier, and the bandwidth ceiling", () => {
  const record = (over: Partial<TurnRecord> = {}): TurnRecord => ({
    session: "s", turn: 0, arm: "b", rep: 0, wallMs: 1000, ttftMs: 10,
    toolCallMs: 20, promptTokens: 100, completionTokens: 100,
    fill: null, toolName: "read", taskMatch: true, firstDivergence: null, ...over,
  });
  const withFill = (injected: number) => record({
    fill: {
      events: 1, injected, strict: injected, echo: 0, spanLens: [injected],
      wastedSamples: 1, parseFallback: 0, indexTruncated: 0,
      decodeSteps: 100 - injected, verifyEvents: 0, verifyAccepted: 0,
      verifyRejected: 0, verifyUnsupported: 0, checkpointMs: 0, branchStops: 0,
    },
  });

  test("apparent = decoded / (1 − fillFrac) is an identity, not a claim", () => {
    const r = armRates([withFill(65)]);
    expect(r.fillFrac).toBeCloseTo(0.65, 6);
    expect(r.emittedTps).toBeCloseTo(100, 6);
    expect(r.decodedTps).toBeCloseTo(35, 6);
    expect(r.apparentTps).toBeCloseTo(r.emittedTps, 6);
    expect(apparentMultiplier(0.65)).toBeCloseTo(1 / 0.35, 6);
  });

  test("an emitted rate above the ceiling proves the tokens skipped the weights", () => {
    // 14 GiB of weights at 600 GB/s: ~39.9 forwards/s is the hard ceiling for
    // a decode that reads every weight once per token. The decoded rate sits
    // under it (as physics requires); the EMITTED rate does not.
    const weights = 14 * 2 ** 30;
    const rates = armRates([withFill(65)]);   // 100 emitted / 35 decoded tok/s
    const check = bandwidthCheck(weights, 600, rates);
    expect(check.ceilingTps).toBeCloseTo((600 * 1e9) / weights, 6);
    expect(check.decodedTps).toBeLessThan(check.ceilingTps);
    expect(check.exceedsCeiling).toBe(true);
    expect(renderBandwidth(check)).toContain("EXCEEDS THE CEILING");
    // With no fill the same stream sits under the ceiling and claims nothing.
    const plain = bandwidthCheck(weights, 600, armRates([record({ completionTokens: 20 })]));
    expect(plain.exceedsCeiling).toBe(false);
  });

  test("per-tool splits group by the recorded tool", () => {
    const split = byTool([
      withFill(10), record({ toolName: "edit" }), record({ toolName: null }),
    ]);
    expect([...split.keys()].sort()).toEqual(["(text)", "edit", "read"]);
    expect(split.get("read")!.fillFrac).toBeCloseTo(0.1, 6);
    expect(split.get("edit")!.fillFrac).toBe(0);
  });
});

describe("showcase mode", () => {
  test("one big prompt, repeated, reporting time to first tool call", async () => {
    const prompt = readFileSync(
      join(import.meta.dir, "..", "..", "fixtures", "showcase-silicon-exchange.txt"), "utf8");
    expect(prompt.length).toBeGreaterThan(2000);
    const s = showcaseSession("showcase", prompt);
    const a = serve(s.turns, { delayMs: 20, injected: 0 });
    const b = serve(s.turns, { delayMs: 5, injected: 24 });
    const { a: ra, b: rb } = await interleavedAb([s], a, b, 3);
    expect(ra).toHaveLength(3);
    expect(rb).toHaveLength(3);
    const v = fillVerdict(ra, rb);
    expect(v.paired).toBe(3);
    expect(v.b.fillFrac).toBeCloseTo(24 / 40, 6);
    // The showcase's headline latency number exists on every rep.
    expect(rb.every((r) => r.ttftMs !== null)).toBe(true);
  });
});
