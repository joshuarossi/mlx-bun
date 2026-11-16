// Ported from SafeAgents (https://github.com/huggingface/safeagents, commit a8ee22d), src/safeagents/scan.py and
// src/safeagents/utils.py. Copyright 2026 the HuggingFace Inc. team. Apache License 2.0.
// Step parsing follows atif-scan 0.8.23, src/atif_scan/data/loader.py. Copyright (c) 2026 Hugging Face. MIT License.
// Both license texts are in apps/mlx-bun/THIRD_PARTY_NOTICES.md.
//
// A conversation becomes a trace: its turns are the steps, the response's pending tool calls the
// last agent step. Reasoning is left out: a model's account of what it is doing is not evidence of
// what it does.
import { content, Step, Trace, type Observation, type ToolCall } from "./model";
import { callFields, normalizeTool } from "./tools";

/** A trace step before its tool calls are classified. */
export interface RawStep {
  source: "system" | "user" | "agent";
  message: string;
  toolCalls?: RawToolCall[];
  results?: { sourceCallId: string; content: string }[];
}

export interface RawToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

type Json = Record<string, unknown>;
const isObject = (value: unknown): value is Json => typeof value === "object" && value !== null && !Array.isArray(value);

/** Text of a message `content`: a string, or the text parts of a list. */
export function contentText(value: unknown): string {
  if (typeof value === "string") return value;
  if (!Array.isArray(value)) return "";
  const parts: string[] = [];
  for (const part of value)
    if (isObject(part) && (part.type === "text" || part.type === "input_text") && typeof part.text === "string") parts.push(part.text);
  return parts.join("\n");
}

/** A tool call; `args` may be a JSON string or an already parsed value. */
export function rawToolCall(id: unknown, name: unknown, args: unknown): RawToolCall {
  let parsed = args;
  if (typeof parsed === "string") {
    try { parsed = JSON.parse(parsed); } catch { parsed = { input: args }; }
  }
  if (!isObject(parsed)) parsed = { input: JSON.stringify(parsed) ?? "null" };
  return { id: String(id ?? ""), name: String(name ?? ""), arguments: parsed as Json };
}

/** The agent step holding a response's pending calls. */
export function callStep(calls: readonly { name: string; arguments: string }[]): RawStep {
  return { source: "agent", message: "", toolCalls: calls.map((call, index) => rawToolCall(`pending-${index}`, call.name, call.arguments)) };
}

/** Steps for a chat request's conversation, without reasoning. Reads OpenAI chat messages and
 * Anthropic content blocks; `system` is Anthropic's top-level system prompt. */
export function history(request: { messages?: unknown; system?: unknown }): RawStep[] {
  const steps: RawStep[] = [];
  const observe = (callId: unknown, value: unknown): void => {
    const agent = steps.findLast(step => step.source === "agent");
    if (!agent?.toolCalls?.length) return;
    (agent.results ??= []).push({ sourceCallId: String(callId ?? ""), content: contentText(value) });
  };
  const system = contentText(request.system);
  if (system) steps.push({ source: "system", message: system });
  for (const message of Array.isArray(request.messages) ? request.messages : []) {
    if (!isObject(message)) continue;
    const { role, content: value } = message;
    const blocks = Array.isArray(value) ? value : [];
    if (role === "system" || role === "developer") steps.push({ source: "system", message: contentText(value) });
    else if (role === "user") {
      for (const block of blocks) if (isObject(block) && block.type === "tool_result") observe(block.tool_use_id, block.content);
      const text = contentText(value);
      if (text) steps.push({ source: "user", message: text });
    } else if (role === "assistant") {
      const toolCalls: RawToolCall[] = [];
      for (const call of Array.isArray(message.tool_calls) ? message.tool_calls : [])
        if (isObject(call) && isObject(call.function)) toolCalls.push(rawToolCall(call.id, call.function.name, call.function.arguments));
      for (const block of blocks) if (isObject(block) && block.type === "tool_use") toolCalls.push(rawToolCall(block.id, block.name, block.input));
      steps.push({ source: "agent", message: contentText(value), ...(toolCalls.length ? { toolCalls } : {}) });
    } else if (role === "tool") observe(message.tool_call_id, value);
  }
  return steps;
}

/** `steps` with only the last `agentSteps` agent turns. Scan time grows with the trace and only
 * findings on the pending calls count, but what the user asked for can excuse them, so user and
 * system turns all stay. */
export function recent(steps: readonly RawStep[], agentSteps = 20): RawStep[] {
  const agents = steps.flatMap((step, index) => (step.source === "agent" ? [index] : []));
  const dropped = new Set(agents.length > agentSteps ? agents.slice(0, agents.length - agentSteps) : []);
  return steps.filter((_, index) => !dropped.has(index));
}

/** Classify every step's tool calls into channels. */
export function parseTrace(steps: readonly RawStep[]): Trace {
  return new Trace(steps.map((step, index) => {
    const calls = (step.toolCalls ?? []).map((call, callIndex): ToolCall => {
      const tool = normalizeTool(call.name, call.arguments);
      return { index: callIndex, tool, fields: callFields(tool, call.arguments, call.name), id: call.id, name: call.name, arguments: call.arguments };
    });
    const observations = (step.results ?? []).map((result): Observation =>
      ({ sourceCallId: result.sourceCallId === "" ? null : result.sourceCallId, content: content(result.content) }));
    return new Step(index, step.source, content(step.message), calls, observations);
  }));
}
