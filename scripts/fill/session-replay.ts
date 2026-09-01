// Agent-session reader + turn reconstruction for the fill A/B harness (K3d).
//
// PORTED, not re-derived: this is the TS port of `load_session` /
// `serialize_tool_call` from the corpus study (reports/k3-replication/
// analyze.py) — same record filter, same block handling, same
// excludeFromContext rule, same corrupt-line tolerance (a line that does not
// parse is skipped, not fatal). Keeping the two readers in lockstep is what
// lets the measured corpus rates in PLAN K3 be compared with what the harness
// actually replays.
//
// REPLAY DOCTRINE: the transcript IS the environment. A model cannot tell an
// executed tool result from a mocked one, so a recorded session replays
// deterministically and side-effect-free by feeding back the RECORDED result
// text verbatim. Nothing is executed; nothing outside the process is touched.
//
// DEVIATION (recorded in PLAN K3): the JSONL carries no `tools` array — the
// corpus study says so explicitly — so the harness SYNTHESIZES one from the
// tool calls a session actually made (see `inferTools`). Strict fill rows are
// compiled from that array, so a synthesized schema is part of what the A/B
// measures; it is a reconstruction, not ground truth.

export type AssistantBlock =
  | { btype: "thinking"; text: string }
  | { btype: "text"; text: string }
  | {
      btype: "toolcall";
      text: string;
      toolName: string;
      arguments: Record<string, unknown>;
      keysSeen: KeySpan[];
    };

/** (key, path, charStart, charEnd) — the bare identifier's bounds inside the
 *  serialized call, so a caller can map it onto tokenizer offsets instead of
 *  re-encoding the key in isolation (which can disagree with how BPE merges it
 *  inside the full string, e.g. a fused `{"` or `":` token). */
export interface KeySpan {
  key: string;
  path: (string | number)[];
  start: number;
  end: number;
}

export type SessionEvent =
  | { kind: "user"; text: string }
  | { kind: "tool_result"; text: string; toolName: string | null }
  | { kind: "assistant"; blocks: AssistantBlock[]; model?: string; provider?: string };

/** Canonical compact serialization used as a proxy for the literal text the
 *  model generated for a tool call (analyze.py `serialize_tool_call`). */
export function serializeToolCall(
  name: string, args: unknown,
): { text: string; keysSeen: KeySpan[] } {
  const parts: string[] = [name, "("];
  const keysSeen: KeySpan[] = [];
  const curLen = () => parts.reduce((n, p) => n + p.length, 0);

  const ser = (obj: unknown, path: (string | number)[]): void => {
    if (obj !== null && typeof obj === "object" && !Array.isArray(obj)) {
      parts.push("{");
      const items = Object.entries(obj as Record<string, unknown>);
      items.forEach(([k, v], idx) => {
        parts.push('"');
        const start = curLen();
        parts.push(k);
        const end = curLen();
        keysSeen.push({ key: k, path: [...path], start, end });
        parts.push('"');
        parts.push(":");
        ser(v, [...path, k]);
        if (idx !== items.length - 1) parts.push(",");
      });
      parts.push("}");
    } else if (Array.isArray(obj)) {
      parts.push("[");
      obj.forEach((v, idx) => {
        ser(v, [...path, idx]);
        if (idx !== obj.length - 1) parts.push(",");
      });
      parts.push("]");
    } else {
      parts.push(JSON.stringify(obj));
    }
  };

  ser(args, []);
  parts.push(")");
  return { text: parts.join(""), keysSeen };
}

/** One record per non-empty, parseable line (analyze.py
 *  `iter_session_messages`: a JSONDecodeError is skipped, not fatal). */
export function iterSessionMessages(jsonl: string): Record<string, unknown>[] {
  const out: Record<string, unknown>[] = [];
  for (const raw of jsonl.split("\n")) {
    const line = raw.trim();
    if (!line) continue;
    try {
      const rec = JSON.parse(line);
      if (rec && typeof rec === "object") out.push(rec as Record<string, unknown>);
    } catch {
      continue; // corrupt line — skipped, exactly as the corpus reader does
    }
  }
  return out;
}

const textOf = (content: unknown): string =>
  Array.isArray(content)
    ? content
      .filter((b) => b && typeof b === "object" && (b as { type?: string }).type === "text")
      .map((b) => String((b as { text?: string }).text ?? ""))
      .join("")
    : "";

/** File order == chronological order (verified in the corpus study: linear
 *  parentId chain, monotonic timestamps, no branching). */
export function loadSession(jsonl: string): SessionEvent[] {
  const events: SessionEvent[] = [];
  for (const rec of iterSessionMessages(jsonl)) {
    if (rec.type !== "message") continue;
    const msg = (rec.message ?? {}) as Record<string, unknown>;
    const role = msg.role;
    if (role === "user") {
      events.push({ kind: "user", text: textOf(msg.content) });
    } else if (role === "toolResult") {
      events.push({
        kind: "tool_result",
        text: textOf(msg.content),
        toolName: (msg.toolName as string | undefined) ?? null,
      });
    } else if (role === "bashExecution") {
      if (msg.excludeFromContext) continue;
      events.push({
        kind: "tool_result",
        text: `${String(msg.command ?? "")}\n${String(msg.output ?? "")}`,
        toolName: "bashExecution",
      });
    } else if (role === "assistant") {
      const blocks: AssistantBlock[] = [];
      for (const b of (Array.isArray(msg.content) ? msg.content : []) as Record<string, unknown>[]) {
        if (b?.type === "thinking") {
          blocks.push({ btype: "thinking", text: String(b.thinking ?? "") });
        } else if (b?.type === "text") {
          blocks.push({ btype: "text", text: String(b.text ?? "") });
        } else if (b?.type === "toolCall") {
          const name = String(b.name ?? "");
          const args = (b.arguments ?? {}) as Record<string, unknown>;
          const { text, keysSeen } = serializeToolCall(name, args);
          blocks.push({ btype: "toolcall", text, toolName: name, arguments: args, keysSeen });
        }
      }
      events.push({
        kind: "assistant",
        blocks,
        ...(typeof msg.model === "string" ? { model: msg.model } : {}),
        ...(typeof msg.provider === "string" ? { provider: msg.provider } : {}),
      });
    }
    // else: model_change / thinking_level_change / session -> ignored
  }
  return events;
}

// --- turn reconstruction ---------------------------------------------------

export interface WireToolCall {
  id: string;
  type: "function";
  function: { name: string; arguments: string };
}

export interface WireMessage {
  role: "user" | "assistant" | "tool";
  content?: string | null;
  tool_calls?: WireToolCall[];
  tool_call_id?: string;
}

export interface ToolSchema {
  type: "function";
  function: {
    name: string;
    description?: string;
    parameters: {
      type: "object";
      properties: Record<string, { type: string }>;
      required: string[];
      additionalProperties: false;
    };
  };
}

/** The recorded assistant output for one turn, normalized for comparison. */
export interface ExpectedOutput {
  toolCalls: { name: string; arguments: Record<string, unknown> }[];
  text: string;
}

export interface ReplayTurn {
  /** Index of the assistant event within the session. */
  index: number;
  /** The conversation as the harness would have sent it. */
  messages: WireMessage[];
  /** What the model actually produced at this point in the recording. */
  expected: ExpectedOutput;
  /** First tool name of the recorded output (per-tool splits in the report). */
  toolName: string | null;
}

const jsonType = (v: unknown): string =>
  typeof v === "number" ? (Number.isInteger(v) ? "integer" : "number")
    : typeof v === "boolean" ? "boolean"
      : Array.isArray(v) ? "array"
        : v !== null && typeof v === "object" ? "object"
          : "string";

/** Synthesize the `tools` array the recording never carried: every tool the
 *  session called, with the union of observed argument keys and the keys that
 *  appeared in EVERY call marked required. `additionalProperties: false`
 *  matches how agent harnesses declare tools and is what makes a single
 *  required key a determined fill row. */
export function inferTools(events: SessionEvent[]): ToolSchema[] {
  const seen = new Map<string, { props: Map<string, string>; counts: Map<string, number>; calls: number }>();
  for (const ev of events) {
    if (ev.kind !== "assistant") continue;
    for (const b of ev.blocks) {
      if (b.btype !== "toolcall" || !b.toolName) continue;
      let entry = seen.get(b.toolName);
      if (!entry) {
        entry = { props: new Map(), counts: new Map(), calls: 0 };
        seen.set(b.toolName, entry);
      }
      entry.calls++;
      for (const [k, v] of Object.entries(b.arguments)) {
        if (!entry.props.has(k)) entry.props.set(k, jsonType(v));
        entry.counts.set(k, (entry.counts.get(k) ?? 0) + 1);
      }
    }
  }
  return [...seen].map(([name, entry]) => ({
    type: "function" as const,
    function: {
      name,
      description: `Replayed tool ${name} (schema reconstructed from ${entry.calls} recorded calls)`,
      parameters: {
        type: "object" as const,
        properties: Object.fromEntries(
          [...entry.props].map(([k, t]) => [k, { type: t }]),
        ),
        required: [...entry.counts]
          .filter(([, n]) => n === entry.calls)
          .map(([k]) => k),
        additionalProperties: false as const,
      },
    },
  }));
}

const normalizeText = (s: string): string => s.replace(/\s+/g, " ").trim();

/** One replayable request per assistant message: the conversation up to that
 *  point (tool results mocked verbatim from the recording) plus what the model
 *  actually produced. */
export function replayTurns(events: SessionEvent[]): ReplayTurn[] {
  const turns: ReplayTurn[] = [];
  const history: WireMessage[] = [];
  let callSeq = 0;
  /** Ids of the tool calls the previous assistant message opened, in order —
   *  the following tool_result events answer them one for one. */
  let pendingCallIds: string[] = [];

  for (let i = 0; i < events.length; i++) {
    const ev = events[i]!;
    if (ev.kind === "user") {
      history.push({ role: "user", content: ev.text });
      pendingCallIds = [];
      continue;
    }
    if (ev.kind === "tool_result") {
      const id = pendingCallIds.shift();
      history.push({
        role: "tool",
        content: ev.text,
        tool_call_id: id ?? `call_orphan_${callSeq++}`,
      });
      continue;
    }
    const toolCalls = ev.blocks.filter((b) => b.btype === "toolcall") as Extract<
      AssistantBlock, { btype: "toolcall" }
    >[];
    const text = ev.blocks
      .filter((b) => b.btype === "text")
      .map((b) => b.text)
      .join("");
    // A turn is only replayable if something precedes it.
    if (history.length > 0) {
      turns.push({
        index: i,
        messages: history.map((m) => ({ ...m })),
        expected: {
          toolCalls: toolCalls.map((b) => ({ name: b.toolName, arguments: b.arguments })),
          text: normalizeText(text),
        },
        toolName: toolCalls[0]?.toolName ?? null,
      });
    }
    const wireCalls: WireToolCall[] = toolCalls.map((b) => ({
      id: `call_${callSeq++}`,
      type: "function" as const,
      function: { name: b.toolName, arguments: JSON.stringify(b.arguments) },
    }));
    history.push({
      role: "assistant",
      content: text || null,
      ...(wireCalls.length ? { tool_calls: wireCalls } : {}),
    });
    pendingCallIds = wireCalls.map((c) => c.id);
  }
  return turns;
}

/** Normalized task-output comparison: the tool the model chose and the
 *  arguments it passed, or — for a prose turn — its whitespace-normalized
 *  text. Deliberately NOT token identity: at temperature > 0 the echo tier
 *  never promised that, and the thing an agent loop cares about is whether the
 *  same call was made. */
export function taskOutputsAgree(a: ExpectedOutput, b: ExpectedOutput): boolean {
  if (a.toolCalls.length !== b.toolCalls.length) return false;
  for (let i = 0; i < a.toolCalls.length; i++) {
    const x = a.toolCalls[i]!;
    const y = b.toolCalls[i]!;
    if (x.name !== y.name) return false;
    if (canonicalJson(x.arguments) !== canonicalJson(y.arguments)) return false;
  }
  if (a.toolCalls.length === 0) return normalizeText(a.text) === normalizeText(b.text);
  return true;
}

/** Key-order-independent JSON (argument key order is the model's choice). */
export function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value !== null && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>)
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));
    return `{${entries.map(([k, v]) => `${JSON.stringify(k)}:${canonicalJson(v)}`).join(",")}}`;
  }
  return JSON.stringify(value) ?? "null";
}

/** Character index where two strings first differ, or null if one is a prefix
 *  of the other (or they are equal). Token-level divergence would need the
 *  server to expose token ids, which the OpenAI wire does not. */
export function firstDivergence(a: string, b: string): number | null {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return a.length === b.length ? null : n;
}
