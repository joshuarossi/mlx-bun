// The replay engine shared by `fill replay` and `fill ab` (K3d): turn a
// recorded session into requests, send them to an arm, and score what came
// back. Pure of CLI concerns so the tests can drive it against a stub server.
import { streamChat, type Arm, type ChatBody } from "./client";
import type { TurnRecord } from "./metrics";
import {
  firstDivergence,
  inferTools,
  loadSession,
  replayTurns,
  taskOutputsAgree,
  type ReplayTurn,
  type SessionEvent,
  type ToolSchema,
} from "./session-replay";

export interface ReplayOptions {
  model?: string;
  maxTokens?: number;
  temperature?: number;
  /** Cap on replayed turns per session (0 = all). */
  maxTurns?: number;
  rep?: number;
  fetchImpl?: (url: string, init: RequestInit) => Promise<Response>;
  onTurn?: (record: TurnRecord) => void;
}

export interface LoadedSession {
  name: string;
  events: SessionEvent[];
  tools: ToolSchema[];
  turns: ReplayTurn[];
}

export function prepareSession(name: string, jsonl: string): LoadedSession {
  const events = loadSession(jsonl);
  return { name, events, tools: inferTools(events), turns: replayTurns(events) };
}

/** Replay one session against one arm. Tool results are already in the
 *  reconstructed messages, mocked verbatim from the recording — nothing is
 *  executed, so a replay is deterministic and side-effect-free. */
export async function replaySession(
  session: LoadedSession, arm: Arm, options: ReplayOptions = {},
): Promise<TurnRecord[]> {
  const records: TurnRecord[] = [];
  const limit = options.maxTurns && options.maxTurns > 0
    ? Math.min(options.maxTurns, session.turns.length)
    : session.turns.length;
  for (let i = 0; i < limit; i++) {
    const turn = session.turns[i]!;
    const body: ChatBody = {
      ...(options.model ? { model: options.model } : {}),
      messages: turn.messages,
      ...(session.tools.length ? { tools: session.tools } : {}),
      ...(options.maxTokens ? { max_tokens: options.maxTokens } : {}),
      temperature: options.temperature ?? 0,
    };
    const res = await streamChat(arm, body, options.fetchImpl);
    const served = { toolCalls: res.toolCalls, text: res.text };
    const record: TurnRecord = {
      session: session.name,
      turn: turn.index,
      arm: arm.label,
      rep: options.rep ?? 0,
      wallMs: res.wallMs,
      ttftMs: res.ttftMs,
      toolCallMs: res.toolCallMs,
      promptTokens: res.promptTokens,
      completionTokens: res.completionTokens,
      fill: res.fill,
      toolName: turn.toolName,
      taskMatch: !res.error && taskOutputsAgree(turn.expected, served),
      firstDivergence: firstDivergence(turn.expected.text, res.text),
      ...(res.error ? { error: res.error } : {}),
    };
    records.push(record);
    options.onTurn?.(record);
  }
  return records;
}

/** Paired interleaving: A, B, A, B … turn by turn, so machine-load drift and
 *  thermal state land on BOTH arms instead of on whichever ran second. The
 *  pairing unit is (session, turn, rep) — the same unit `fillVerdict` pairs
 *  on. */
export async function interleavedAb(
  sessions: LoadedSession[],
  armA: Arm,
  armB: Arm,
  reps: number,
  options: ReplayOptions = {},
): Promise<{ a: TurnRecord[]; b: TurnRecord[] }> {
  const a: TurnRecord[] = [];
  const b: TurnRecord[] = [];
  for (let rep = 0; rep < reps; rep++) {
    for (const session of sessions) {
      const limit = options.maxTurns && options.maxTurns > 0
        ? Math.min(options.maxTurns, session.turns.length)
        : session.turns.length;
      for (let i = 0; i < limit; i++) {
        const one: LoadedSession = { ...session, turns: [session.turns[i]!] };
        const [ra] = await replaySession(one, armA, { ...options, rep });
        const [rb] = await replaySession(one, armB, { ...options, rep });
        if (ra) a.push(ra);
        if (rb) b.push(rb);
      }
    }
  }
  return { a, b };
}

/** The showcase: ONE large tool-dense prompt, no recorded session — the
 *  measurement is throughput, not agreement, so there is nothing to mock. */
export function showcaseSession(name: string, prompt: string): LoadedSession {
  const events: SessionEvent[] = [{ kind: "user", text: prompt }];
  return {
    name,
    events,
    tools: [],
    turns: [{
      index: 0,
      messages: [{ role: "user", content: prompt }],
      expected: { toolCalls: [], text: "" },
      toolName: null,
    }],
  };
}
