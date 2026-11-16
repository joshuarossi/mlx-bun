// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c),
// src/atif_scan/checks.py and src/atif_scan/detectors/text.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// The check contract and the reusable detector building blocks. A matched text pattern is a
// review signal, not a misconduct verdict.
import { TOOL_INPUT_CHANNELS, type Channel, type Locator, type Observation, type Span, type Step, type Surface, type ToolCall, type Trace } from "./model";
import { typesIntoTerminal } from "./tools";

export type Status = "match" | "no_match" | "unknown" | "not_applicable" | "error";

export const SEVERITY = { info: 0, low: 25, medium: 50, high: 75, critical: 100 } as const;
export type SeverityName = keyof typeof SEVERITY;
export const SEVERITY_NAMES = Object.keys(SEVERITY) as SeverityName[];

const IDENTIFIER = /^[a-zA-Z0-9][a-zA-Z0-9_.:/-]{0,127}$/;
const MAX_TITLE = 60;

/** A safe identifier (check IDs): logs and notices echo it, so its shape is validated. */
export function identifier(value: unknown): string {
  if (typeof value !== "string" || !IDENTIFIER.test(value)) throw new Error("invalid_identifier");
  return value;
}

export interface CheckSpec {
  readonly id: string;
  readonly severity: SeverityName;
  /** What a match means, in plain words. */
  readonly title: string;
}

/** A check's identity: an identifier and a short one-line title without a URL. */
export function checkSpec(id: string, severity: SeverityName = "info", title = ""): CheckSpec {
  identifier(id);
  if (!Object.hasOwn(SEVERITY, severity)) throw new Error("invalid_check_spec");
  // Printable text on one line: no control characters.
  if (typeof title !== "string" || title.length > MAX_TITLE || /[\p{Cc}\p{Cf}\p{Zl}\p{Zp}]/u.test(title) || title.includes("://"))
    throw new Error("invalid_check_title");
  return { id, severity, title };
}

/** Why a check could not read part of the trace (fixed codes). */
export type UnreadReason = "unreadable" | "undecidable" | "result_not_recorded" | "run_ended";

export interface Unread {
  readonly reason: UnreadReason;
  readonly at: Locator | null;
}

export interface Detection {
  readonly status: Status;
  readonly evidence: readonly Locator[];
  readonly complete: boolean;
  readonly unread: readonly Unread[];
}

const MAX_UNREAD = 10;

const locatorKey = (at: Locator): string =>
  `${at.step}|${at.channel}|${at.call ?? ""}|${at.observation ?? ""}|${at.field ?? ""}|${at.span ? at.span.join(",") : ""}`;

function unique<T>(values: Iterable<T>, key: (value: T) => string): T[] {
  const seen = new Map<string, T>();
  for (const value of values) if (!seen.has(key(value))) seen.set(key(value), value);
  return [...seen.values()];
}

export function detection(status: Status, evidence: readonly Locator[] = [], complete = status !== "unknown" && status !== "error",
  unread: readonly Unread[] = []): Detection {
  if (status === "no_match" && !complete) throw new Error("incomplete_negative_must_be_unknown");
  if ((status === "unknown" || status === "error") && complete) throw new Error("unknown_or_error_cannot_be_complete");
  return { status, evidence, complete, unread };
}

/** Match on any hit (deduplicated, order kept); otherwise no_match only when the search was complete, else unknown. */
export function detectionOf(hits: Iterable<Locator>, complete: boolean, unread: Iterable<Unread> = []): Detection {
  const evidence = unique(hits, locatorKey);
  const places = complete ? [] : unique(unread, item => `${item.reason}|${item.at ? locatorKey(item.at) : ""}`).slice(0, MAX_UNREAD);
  if (evidence.length) return detection("match", evidence, complete, places);
  return detection(complete ? "no_match" : "unknown", [], complete, places);
}

export interface Detector {
  readonly spec: CheckSpec;
  evaluate(trace: Trace): Detection;
}

/** What a predicate found in a surface: a regex match or [start, end] span to cite, or just truthy / falsy. */
export type Hit = RegExpExecArray | RegExpMatchArray | Span | boolean | null | undefined;
export type Predicate = (surface: Surface) => Hit;

/** `pattern.exec` from the start of `text`, whatever state a global or sticky pattern holds. */
export function search(pattern: RegExp, text: string): RegExpExecArray | null {
  pattern.lastIndex = 0;
  const found = pattern.exec(text);
  pattern.lastIndex = 0;
  return found;
}

/** A case-insensitive pattern behind a literal prefilter: for ASCII text, search only when some
 * lowercase hint occurs in it. Non-ASCII text always gets the full pattern. */
export interface Gated {
  search(text: string): RegExpExecArray | null;
  finditer(text: string): RegExpExecArray[];
}

export function gated(pattern: RegExp, hints: readonly string[]): Gated {
  if (!pattern.flags.includes("i") || hints.some(hint => hint !== hint.toLowerCase())) throw new Error("gated_pattern_needs_i_and_lowercase_hints");
  const all = new RegExp(pattern.source, pattern.flags.includes("g") ? pattern.flags : `${pattern.flags}g`);
  // eslint-disable-next-line no-control-regex
  const mayMatch = (text: string) => /[^\x00-\x7f]/.test(text) || hints.some(hint => text.toLowerCase().includes(hint));
  return {
    search: text => (mayMatch(text) ? search(pattern, text) : null),
    finditer: text => (mayMatch(text) ? [...text.matchAll(all)] : []),
  };
}

/** A predicate may return a boolean, a regex match or a [start, end] span. */
export function matched(surface: Surface, result: Hit): Locator | null {
  if (!result) return null;
  if (typeof result === "object" && "index" in result && typeof result.index === "number")
    return { ...surface.at, span: [result.index, result.index + result[0].length] };
  if (Array.isArray(result) && result.length === 2 && typeof result[0] === "number" && typeof result[1] === "number")
    return { ...surface.at, span: [result[0], result[1]] };
  return surface.at;
}

/** The call's results: linked ones, or for typed terminal input the step's results without a call ID. */
function recorded(step: Step, call: ToolCall): [number, Observation][] {
  const linked = step.resultsFor(call);
  if (linked.length || !(typesIntoTerminal(call.arguments) || call.tool === "inert")) return linked;
  return [];
}

/** Each agent call whose output is not in the conversation: the pending calls, and earlier calls a harness dropped. */
export function unrecordedResults(trace: Trace): Unread[] {
  const unread: Unread[] = [];
  const last = trace.steps.length - 1;
  for (const [step, call] of trace.agentCalls()) {
    if (recorded(step, call).length) continue;
    unread.push({ reason: step.index === last ? "run_ended" : "result_not_recorded", at: { step: step.index, channel: "metadata", call: call.index } });
  }
  return unread;
}

/** Apply a predicate to agent-authored surfaces on the given channels.
 *
 * Every tool call's arguments are classified generically, so an unrecognized tool name alone does
 * not reduce coverage. A detector is incomplete when a relevant surface isn't understood, or when
 * `undecidable` says the predicate can't judge a surface. */
export class SurfaceDetector implements Detector {
  constructor(
    readonly spec: CheckSpec,
    readonly channels: ReadonlySet<Channel>,
    readonly predicate: Predicate,
    readonly undecidable?: (surface: Surface) => boolean,
  ) {}

  evaluate(trace: Trace): Detection {
    const hits: Locator[] = [], unread: Unread[] = [];
    const readsToolInputs = [...this.channels].some(channel => TOOL_INPUT_CHANNELS.has(channel) || channel === "arguments");
    for (const surface of trace.agentSurfaces()) {
      const channel = surface.at.channel;
      if (channel === "arguments" && !surface.content.understood) {
        // Unparseable arguments matter only to checks that read tool inputs.
        if (readsToolInputs) unread.push({ reason: "unreadable", at: surface.at });
        continue;
      }
      if (!this.channels.has(channel)) continue;
      if (!surface.content.understood) unread.push({ reason: "unreadable", at: surface.at });
      const at = matched(surface, this.predicate(surface));
      if (at !== null) hits.push(at);
      else if (this.undecidable?.(surface)) unread.push({ reason: "undecidable", at: surface.at });
    }
    return detectionOf(hits, trace.agentSteps > 0 && !unread.length, unread);
  }
}

export const PROSE: ReadonlySet<Channel> = new Set(["message", "reasoning"]);
/** Unclassified argument strings are scanned wherever commands are. */
export const COMMAND: ReadonlySet<Channel> = new Set(["command", "arguments"]);
export const INPUT: ReadonlySet<Channel> = new Set(["command", "path", "query", "url", "arguments"]);
export const PATHS_TEXT: ReadonlySet<Channel> = new Set(["command", "path", "arguments"]);

/** Match a case-insensitive regex against agent-authored text on the given channels. */
export function regexDetector(spec: CheckSpec, pattern: string | RegExp, channels: ReadonlySet<Channel> = PROSE): SurfaceDetector {
  const source = typeof pattern === "string" ? pattern : pattern.source;
  const flags = typeof pattern === "string" ? "i" : [...new Set(`${pattern.flags.replace(/[gy]/g, "")}i`)].join("");
  const compiled = new RegExp(source, flags);
  return new SurfaceDetector(spec, channels, surface => compiled.exec(surface.content.text));
}
