import type { ToolDefinition } from "../chat-template";
import { parseStrictToolCall } from "../tool-call";
import type { FillRow, StrictFillContext } from "./fill-session";

const OPEN = "<tool_call>", CLOSE = "</tool_call>";
const THINK_OPEN = "<think>", THINK_CLOSE = "</think>";
const MAX_CONTEXT_TOKENS = 65_536;

/** Conservative for raw XML argument text. An unfinished literal can still
 * contain a closing-tag example; leaving it to generation loses only a fill. */
function literalsClosed(text: string): boolean {
  let quote = "", escaped = false;
  for (const c of text) {
    if (escaped) { escaped = false; continue; }
    if (c === "\\" && quote !== "'") { escaped = true; continue; }
    if (quote) { if (c === quote) quote = ""; }
    else if (c === '"' || c === "'" || c === "`") quote = c;
  }
  return quote === "" && !escaped;
}

function reasoningClosed(text: string): boolean {
  if (text.includes(THINK_OPEN)) return false;
  let fence = "", prose = "";
  for (const line of text.split("\n")) {
    const marker = /^\s*(`{3,}|~{3,})(.*)$/.exec(line);
    if (fence) {
      if (marker && marker[1]![0] === fence[0] &&
          marker[1]!.length >= fence.length && !marker[2]!.trim()) fence = "";
    } else if (marker) fence = marker[1]!;
    else prose += line + "\n";
  }
  return !fence && literalsClosed(prose);
}

/** Request-local proof for template-derived rows. Only a tool-only assistant
 * turn, optionally following its reasoning block, qualifies. Prose, quoted
 * examples and unsupported formats retain ordinary generation. Decode runs
 * only when a full token trigger matches, not for every generated token. */
export class ToolCallFillContext implements StrictFillContext {
  #ids: number[] = [];
  #overflow = false;
  readonly #startsInReasoning: boolean;

  constructor(
    readonly decode: (ids: readonly number[]) => string,
    readonly tools: ToolDefinition[],
    promptText: string,
  ) {
    this.#startsInReasoning = /<think>\s*$/.test(promptText);
  }

  observe(ids: readonly number[]): void {
    if (this.#overflow) return;
    if (this.#ids.length + ids.length > MAX_CONTEXT_TOKENS) {
      this.#overflow = true;
      this.#ids = [];
      return;
    }
    for (const id of ids) this.#ids.push(id);
  }

  allows(row: FillRow): boolean {
    if (this.#overflow) return false;
    let text = this.decode(this.#ids);
    if (this.#startsInReasoning) {
      const end = text.indexOf(THINK_CLOSE);
      if (end < 0 || !reasoningClosed(text.slice(0, end))) return false;
      text = text.slice(end + THINK_CLOSE.length);
    }
    text = text.trimStart();
    if (text.startsWith(THINK_OPEN)) {
      const end = text.indexOf(THINK_CLOSE, THINK_OPEN.length);
      if (end < 0 || !reasoningClosed(text.slice(THINK_OPEN.length, end))) return false;
      text = text.slice(end + THINK_CLOSE.length).trimStart();
    }
    // Earlier calls must be complete and valid before another can open.
    for (;;) {
      if (!text.startsWith(OPEN)) return false;
      const end = text.indexOf(CLOSE, OPEN.length);
      if (end < 0) break;
      const stop = end + CLOSE.length;
      if (!parseStrictToolCall(text.slice(0, stop), this.tools)) return false;
      text = text.slice(stop).trimStart();
    }
    if (text.indexOf(OPEN, OPEN.length) !== -1) return false;
    if (row.kind === "scaffold" || row.kind === "name" || row.kind === "key") {
      const trigger = this.decode(row.trigger);
      const start = trigger.indexOf(OPEN);
      return start >= 0 && text === trigger.slice(start);
    }
    if (row.kind !== "close") return false;
    const call = parseStrictToolCall(text + this.decode(row.emit), this.tools);
    if (!call) return false;
    const tool = this.tools.find(tool => tool.function?.name === call.name);
    const schema = tool?.function?.parameters;
    const required = schema?.required;
    if (!Array.isArray(required) || required.length !== 1 ||
        Object.keys(call.arguments).length !== 1 || !Object.hasOwn(call.arguments, required[0])) return false;
    const value = call.arguments[required[0]];
    return typeof value !== "string" || literalsClosed(value);
  }
}
