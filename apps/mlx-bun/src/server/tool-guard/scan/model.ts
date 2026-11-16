// Ported from atif-scan 0.8.23 (https://github.com/huggingface/atif-scan, commit 3bbaf3c), src/atif_scan/data/model.py.
// Copyright (c) 2026 Hugging Face. MIT License; the full text is in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// The projection of a conversation the checks read: steps, the agent's tool calls with each
// argument routed to a channel, and the results it received. Only what a pending tool call's
// review reads is kept; atif-scan's usage, timestamp and recording-integrity fields are not.

export type Channel =
  | "message"
  | "reasoning"
  | "command"
  | "path"
  | "query"
  | "url"
  | "observation"
  /** Tool-argument strings no rule classified (any tool). Still scanned by text checks. */
  | "arguments"
  /** Argument data that is not an action target: file contents, edits, prose, search patterns. */
  | "payload"
  | "metadata";

/** Channels whose meaning depends on recognizing the tool that produced them. */
export const TOOL_INPUT_CHANNELS: ReadonlySet<Channel> = new Set(["command", "path", "query", "url"]);

export type Span = readonly [number, number];

export interface Locator {
  readonly step: number;
  readonly channel: Channel;
  readonly call?: number;
  readonly observation?: number;
  /** Which classified argument of the call (index into `ToolCall.fields`). */
  readonly field?: number;
  /** Offsets of the match within the surface text (JavaScript string offsets). */
  readonly span?: Span;
}

export interface Content {
  readonly text: string;
  readonly understood: boolean;
  /** Built at run time by a tool program; never set here (tool programs are not read). */
  readonly computed: boolean;
}

export const content = (text = "", understood = true): Content => ({ text, understood, computed: false });

export type Field = readonly [Channel, Content];

export interface Surface {
  readonly at: Locator;
  readonly content: Content;
  /** Normalized tool category. */
  readonly tool?: string;
  /** Tool name as the model wrote it. */
  readonly toolName?: string;
}

export interface ToolCall {
  readonly index: number;
  /** shell, read, write, search_files, web_fetch, web_search, inert or other. */
  readonly tool: string;
  readonly fields: readonly Field[];
  readonly id: string;
  readonly name: string;
  readonly arguments: Readonly<Record<string, unknown>> | null;
}

export interface Observation {
  readonly sourceCallId: string | null;
  readonly content: Content;
}

export class Step {
  constructor(
    readonly index: number,
    readonly source: "system" | "user" | "agent",
    readonly message: Content,
    readonly calls: readonly ToolCall[] = [],
    readonly observations: readonly Observation[] = [],
  ) {}

  /** The agent's own step. */
  get authored(): boolean {
    return this.source === "agent";
  }

  /** Message and action arguments. Reasoning is never part of a guard trace. */
  *authoredSurfaces(): Generator<Surface> {
    yield { at: { step: this.index, channel: "message" }, content: this.message };
    yield { at: { step: this.index, channel: "reasoning" }, content: content() };
    for (const call of this.calls) {
      for (const [field, [channel, value]] of call.fields.entries())
        yield { at: { step: this.index, channel, call: call.index, field }, content: value, tool: call.tool, toolName: call.name };
    }
  }

  *observationSurfaces(): Generator<Surface> {
    for (const [observation, value] of this.observations.entries())
      yield { at: { step: this.index, channel: "observation", observation }, content: value.content };
  }

  /** Results linked to `call` by its recorded ID; a step's lone call also takes results recorded without one. */
  resultsFor(call: ToolCall): [number, Observation][] {
    const linked = [...this.observations.entries()].filter(([, o]) => call.id !== "" && o.sourceCallId === call.id);
    if (linked.length || this.calls.length !== 1) return linked;
    return [...this.observations.entries()].filter(([, o]) => o.sourceCallId === null);
  }
}

export class Trace {
  constructor(readonly steps: readonly Step[]) {}

  /** Never walks a step recursively: results and prompt text stay separate. */
  *agentSurfaces(): Generator<Surface> {
    for (const step of this.steps) if (step.authored) yield* step.authoredSurfaces();
  }

  *agentCalls(): Generator<[Step, ToolCall]> {
    for (const step of this.steps) if (step.authored) for (const call of step.calls) yield [step, call];
  }

  *observationSurfaces(): Generator<Surface> {
    for (const step of this.steps) yield* step.observationSurfaces();
  }

  get agentSteps(): number {
    return this.steps.filter(step => step.authored).length;
  }

  get toolCalls(): number {
    return this.steps.reduce((sum, step) => sum + (step.authored ? step.calls.length : 0), 0);
  }

  /** The first step is the agent's: the prompt is not part of the conversation. */
  get headMissing(): boolean {
    return this.steps[0]?.source === "agent";
  }
}
