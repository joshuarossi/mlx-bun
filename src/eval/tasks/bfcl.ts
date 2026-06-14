// BFCL-V3 (Berkeley Function Calling Leaderboard) — "simple" category.
// Port of optiq/eval/bfcl.py. Single-turn function calling: from a user
// query + tool schema(s), generate the model's function call, parse it,
// and score AST-equivalence against the possible answer(s).
//
// Note on the prompt path: bfcl.py prefers tokenizer.apply_chat_template
// with a `tools=` kwarg; if the template rejects tools (or there is no
// chat template) it falls back to a textual prompt that embeds the tools
// JSON and asks for a <tool_call>...</tool_call> block. The mlx-bun eval
// harness exposes generation only through generateText(), which wraps the
// body as a single user turn and does NOT forward `tools` to the chat
// template. We therefore use bfcl.py's textual-fallback prompt verbatim,
// rendered through the chat template via useChat:true. This is a faithful
// reproduction of bfcl.py's fallback branch; the AST matcher — the heart
// of the task — is ported exactly. (See summary for this one note.)

import { generateText, loadJsonl, sampleIndices, type TaskModel } from "../runner";

// ---------------------------------------------------------------------------
// Data shapes (the merged jsonl: each line = {query, answer}).
// ---------------------------------------------------------------------------

interface ChatTurn { role: string; content: string }

interface ToolDef {
  name?: string;
  description?: string;
  parameters?: unknown;
  function?: unknown;
  [k: string]: unknown;
}

interface BfclQuery {
  id: string;
  question: ChatTurn[][] | ChatTurn[] | string;
  function: ToolDef[] | string;
}

interface BfclAnswer {
  id: string;
  ground_truth: Record<string, unknown>[] | Record<string, unknown> | string;
}

interface BfclRow {
  query: BfclQuery;
  answer: BfclAnswer;
}

export interface BfclResult {
  nCorrect: number;
  nTotal: number;
  accuracy: number; // 0..1
  nNoCall: number; // model didn't emit a parseable call
  nWrongName: number; // right shape, wrong function name
  nWrongArgs: number; // right name, wrong arguments
}

type ToolCall = { name: string; arguments: Record<string, unknown> };

// ---------------------------------------------------------------------------
// _extract_tool_call — recognize the four emit formats from bfcl.py.
// ---------------------------------------------------------------------------

/** Extract a single tool call from a model response, or null. */
export function extractToolCall(response: string): ToolCall | null {
  // Strip thinking blocks if present.
  let text = response;
  if (text.includes("</think>")) text = text.split("</think>").slice(1).join("</think>");
  if (text.includes("<channel|>")) text = text.split("<channel|>").slice(1).join("<channel|>");

  // Format 1: <tool_call>...</tool_call>  (Hermes / Qwen3 / Gemma-4 textual)
  {
    const m = text.match(/<tool_call>\s*([\s\S]+?)\s*<\/tool_call>/);
    if (m) {
      try {
        const obj = JSON.parse(m[1]!) as Record<string, unknown>;
        const call = toolCallFromJsonObject(obj);
        if (call) return call;
      } catch { /* fall through */ }
    }
  }

  // Format 2: <function=NAME><parameter=K>V</parameter>...</function>  (Qwen3.6)
  {
    const m = text.match(/<function=([^>\s]+)>([\s\S]*?)<\/function>/);
    if (m) {
      const name = m[1]!.trim();
      const body = m[2]!;
      const args: Record<string, unknown> = {};
      const pre = /<parameter=([^>\s]+)>\s*([\s\S]*?)\s*<\/parameter>/g;
      let pm: RegExpExecArray | null;
      while ((pm = pre.exec(body)) !== null) {
        args[pm[1]!.trim()] = pm[2]!.trim();
      }
      return { name, arguments: args };
    }
  }

  // Format 3: Gemma-4 — <|tool_call>call:NAME{k:v,...}<tool_call|>
  {
    const m = text.match(/<\|tool_call>\s*call:(\S+?)\s*(?:\{([\s\S]*?)\})?\s*<tool_call\|>/);
    if (m) {
      const name = m[1]!.trim().replace(/\{+$/, "");
      const body = (m[2] ?? "").split('<|"|>').join('"');
      return { name, arguments: parseGemmaArgs(body) };
    }
  }

  // Format 4: bare JSON {"name": ..., "arguments": ...} (or "function"/"args").
  {
    const re = /\{[^{]*"(?:name|function)"[^{]*"(?:arguments|args)"[^{]*\}/g;
    let m: RegExpExecArray | null;
    while ((m = re.exec(text)) !== null) {
      try {
        const obj = JSON.parse(m[0]) as Record<string, unknown>;
        const call = toolCallFromJsonObject(obj);
        if (call) return call;
      } catch { /* continue */ }
    }
  }

  return null;
}

/** Recognize a tool call inside a parsed JSON object, tolerating the key
 *  variants Gemma-4 emits under the textual prompt:
 *    {"name"|"function": <str>, "arguments"|"args"|"parameters": <obj|str>}
 *  Also accepts the BFCL-native single-entry mapping {funcName: {args}},
 *  where the lone key is the function name and its object value is the args. */
function toolCallFromJsonObject(obj: unknown): ToolCall | null {
  if (!obj || typeof obj !== "object" || Array.isArray(obj)) return null;
  const o = obj as Record<string, unknown>;

  // Name under "name" or "function" (when "function" holds a string, not a
  // nested {name, arguments} object).
  let nameRaw: unknown = undefined;
  if (typeof o.name === "string") nameRaw = o.name;
  else if (typeof o.function === "string") nameRaw = o.function;

  if (nameRaw !== undefined) {
    let args = (o.arguments ?? o.args ?? o.parameters ?? {}) as unknown;
    if (typeof args === "string") {
      try { args = JSON.parse(args); } catch { /* leave as-is */ }
    }
    return {
      name: String(nameRaw),
      arguments: (args && typeof args === "object" && !Array.isArray(args)
        ? args
        : {}) as Record<string, unknown>,
    };
  }

  // OpenAI-nested: {"function": {"name": ..., "arguments": ...}}.
  if (o.function && typeof o.function === "object" && !Array.isArray(o.function)) {
    const inner = toolCallFromJsonObject(o.function);
    if (inner) return inner;
  }

  // BFCL-native mapping: exactly one key whose value is an args object, and
  // none of the reserved call keys are present.
  const keys = Object.keys(o);
  if (keys.length === 1) {
    const k = keys[0]!;
    const v = o[k];
    if (v && typeof v === "object" && !Array.isArray(v)) {
      return { name: k, arguments: v as Record<string, unknown> };
    }
  }

  return null;
}

/** Parse Gemma-4's flat `key:value, key:value` argument body. Char-walk to
 *  respect string quotes and bracket nesting, then JSON-decode each value. */
function parseGemmaArgs(body: string): Record<string, unknown> {
  const args: Record<string, unknown> = {};
  let i = 0;
  const n = body.length;
  const isWs = (c: string): boolean => c === " " || c === "\t" || c === "\n";
  while (i < n) {
    // Skip whitespace + leading commas.
    while (i < n && (body[i] === "," || isWs(body[i]!))) i++;
    if (i >= n) break;
    // Read key (up to colon).
    const kStart = i;
    while (i < n && body[i] !== ":") i++;
    if (i >= n) break;
    let key = body.slice(kStart, i).trim();
    key = stripQuotes(key);
    i++; // skip ':'
    while (i < n && isWs(body[i]!)) i++;
    // Read value — respect quotes and bracket nesting.
    const vStart = i;
    let depth = 0;
    let inStr = false;
    let strQ = "";
    while (i < n) {
      const c = body[i]!;
      if (inStr) {
        if (c === "\\" && i + 1 < n) { i += 2; continue; }
        if (c === strQ) inStr = false;
        i++;
        continue;
      }
      if (c === '"' || c === "'") { inStr = true; strQ = c; i++; continue; }
      if (c === "[" || c === "{") { depth++; i++; continue; }
      if (c === "]" || c === "}") {
        if (depth === 0) break;
        depth--; i++; continue;
      }
      if (c === "," && depth === 0) break;
      i++;
    }
    const vStr = body.slice(vStart, i).trim();
    try {
      args[key] = JSON.parse(vStr);
    } catch {
      args[key] = stripQuotes(vStr);
    }
  }
  return args;
}

/** Mirror Python's `.strip('"').strip("'")` — strip leading/trailing of each
 *  quote char in turn (NOT a balanced-pair strip). */
function stripQuotes(s: string): string {
  let r = s.replace(/^"+/, "").replace(/"+$/, "");
  r = r.replace(/^'+/, "").replace(/'+$/, "");
  return r;
}

// ---------------------------------------------------------------------------
// AST-equivalence matcher — the correctness core, ported from bfcl.py.
// ---------------------------------------------------------------------------

/** Normalize a value for comparison: int/float-coerce numeric strings, parse
 *  bool strings, JSON-decode array/object strings, recurse into containers. */
function canonicalizeValue(v: unknown): unknown {
  if (typeof v === "string") {
    const s = v.trim();
    // Try numeric (matching Python int()/float() semantics, best-effort).
    const num = pyNumeric(s);
    if (num !== null) return num;
    // Try bool.
    const lower = s.toLowerCase();
    if (lower === "true" || lower === "false") return lower === "true";
    // Try JSON for arrays/objects.
    if (s.startsWith("[") || s.startsWith("{")) {
      try { return canonicalizeValue(JSON.parse(s)); } catch { /* keep string */ }
    }
    return s.trim();
  }
  if (Array.isArray(v)) return v.map(canonicalizeValue);
  if (v && typeof v === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, x] of Object.entries(v as Record<string, unknown>)) out[k] = canonicalizeValue(x);
    return out;
  }
  return v;
}

/** Best-effort port of Python's int()/float() coercion used in bfcl.py's
 *  _canonicalize_value: if the string contains '.' or 'e', try float; else
 *  try int. Returns null if not a clean number (so callers keep the string). */
function pyNumeric(s: string): number | null {
  if (s.length === 0) return null;
  const hasDotOrE = s.includes(".") || s.toLowerCase().includes("e");
  if (hasDotOrE) {
    // Python float(): accepts leading/trailing space (already trimmed),
    // optional sign, decimal, exponent. Reject anything else.
    if (/^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$/.test(s) || /^[+-]?\d+[eE][+-]?\d+$/.test(s)) {
      const f = Number(s);
      return Number.isFinite(f) ? f : null;
    }
    return null;
  }
  // Python int(): plain optional-sign digit string (base 10).
  if (/^[+-]?\d+$/.test(s)) {
    const n = Number(s);
    return Number.isFinite(n) ? n : null;
  }
  return null;
}

/** Equality with int/float tolerance and case-insensitive string compare. */
function looseEq(a: unknown, b: unknown): boolean {
  if (typeof a === "string" && typeof b === "string") {
    return a.trim().toLowerCase() === b.trim().toLowerCase();
  }
  const aNum = typeof a === "number" || typeof a === "boolean";
  const bNum = typeof b === "number" || typeof b === "boolean";
  // Python: bool is a subclass of int, so True == 1. Mirror numeric path for
  // number/bool combos.
  if ((typeof a === "number" || typeof a === "boolean") &&
      (typeof b === "number" || typeof b === "boolean") &&
      !(typeof a === "boolean" && typeof b === "boolean")) {
    if (aNum && bNum) return Number(a) === Number(b);
  }
  if (typeof a === "number" && typeof b === "number") return a === b;
  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) return false;
    return a.every((x, i) => looseEq(x, b[i]));
  }
  if (a && b && typeof a === "object" && typeof b === "object" && !Array.isArray(a) && !Array.isArray(b)) {
    const ak = Object.keys(a as Record<string, unknown>);
    const bk = Object.keys(b as Record<string, unknown>);
    if (ak.length !== bk.length) return false;
    const bset = new Set(bk);
    if (!ak.every((k) => bset.has(k))) return false;
    return ak.every((k) => looseEq((a as Record<string, unknown>)[k], (b as Record<string, unknown>)[k]));
  }
  return a === b;
}

/** Compare predicted call against ground truth. Ground truth may be a
 *  `{name: {arg: value}}` mapping (BFCL native) or a `{name, arguments}` dict. */
export function callsMatch(predicted: ToolCall | null, groundTruth: Record<string, unknown>): boolean {
  if (!predicted) return false;

  const predName = String(predicted.name ?? "").trim();
  const predArgs = canonicalizeValue(predicted.arguments ?? {});

  let gtName: string;
  let gtArgsRaw: unknown;
  if ("name" in groundTruth && "arguments" in groundTruth) {
    gtName = String(groundTruth.name).trim();
    gtArgsRaw = groundTruth.arguments ?? {};
  } else {
    const keys = Object.keys(groundTruth);
    if (keys.length === 0) return false;
    gtName = keys[0]!.trim();
    gtArgsRaw = groundTruth[keys[0]!] ?? {};
  }
  const gtArgs = canonicalizeValue(gtArgsRaw);

  if (predName !== gtName) return false;
  if (!isPlainObject(predArgs) || !isPlainObject(gtArgs)) return false;

  // Each ground-truth arg must be present and match. BFCL stores acceptable
  // values as a list [primary, alt1, ...]; prediction may match ANY element.
  // An arg is optional if its list includes '' (or null) — then a missing
  // prediction is acceptable too.
  for (const [k, gtV] of Object.entries(gtArgs)) {
    const isList = Array.isArray(gtV);
    const isOptional = isList && (gtV as unknown[]).some((x) => (typeof x === "string" && x === "") || x === null);
    if (!(k in predArgs)) {
      if (isOptional) continue;
      return false;
    }
    const pv = predArgs[k];
    if (isList && !Array.isArray(pv)) {
      const ok = (gtV as unknown[]).some((gv) => looseEq(pv, gv));
      if (!ok) return false;
    } else {
      if (!looseEq(pv, gtV)) return false;
    }
  }
  return true;
}

function isPlainObject(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

// ---------------------------------------------------------------------------
// Prompt construction — bfcl.py's textual-fallback branch.
// ---------------------------------------------------------------------------

/** Wrap BFCL tool defs into the OpenAI/Anthropic chat-template tools schema. */
function wrapToolsForChat(raw: ToolDef[] | string | undefined): unknown[] {
  let tools: ToolDef[];
  if (typeof raw === "string") {
    try { tools = JSON.parse(raw) as ToolDef[]; } catch { tools = []; }
  } else {
    tools = raw ?? [];
  }
  const out: unknown[] = [];
  for (const t of tools) {
    if (!t || typeof t !== "object") continue;
    if ("function" in t) { out.push(t); continue; }
    out.push({
      type: "function",
      function: {
        name: t.name ?? "",
        description: t.description ?? "",
        parameters: t.parameters ?? { type: "object", properties: {} },
      },
    });
  }
  return out;
}

/** Extract the single user turn from BFCL's nested `question` shape. */
function userText(question: BfclQuery["question"]): string {
  if (Array.isArray(question) && question.length > 0) {
    const first = question[0];
    if (Array.isArray(first)) {
      // list-of-list: [[{role,content}, ...]]
      return first.length > 0 ? (first[first.length - 1]!.content ?? "") : "";
    }
    if (first && typeof first === "object") {
      // list-of-dict: [{role,content}, ...]
      const turns = question as ChatTurn[];
      return turns[turns.length - 1]!.content ?? "";
    }
  }
  return question ? String(question) : "";
}

/** Build the textual prompt body (bfcl.py fallback branch). Rendered as a
 *  single user turn by generateText(useChat:true). */
function buildPrompt(text: string, tools: unknown[]): string {
  const toolsJson = JSON.stringify(tools, null, 2);
  return (
    `Available tools:\n${toolsJson}\n\n` +
    `User: ${text}\n\n` +
    `To call a tool, respond with a single <tool_call>...</tool_call> block ` +
    `containing one JSON object with exactly two keys: "name" (the tool name) ` +
    `and "arguments" (an object of argument name -> value). ` +
    `Use the exact key names "name" and "arguments". For example:\n` +
    `<tool_call>{"name": "the_tool_name", "arguments": {"arg1": "value1", "arg2": 2}}</tool_call>\n`
  );
}

// ---------------------------------------------------------------------------
// Ground-truth extraction.
// ---------------------------------------------------------------------------

function parseGroundTruth(raw: BfclAnswer["ground_truth"]): Record<string, unknown> {
  let gt: unknown = raw;
  if (typeof gt === "string") {
    try { gt = JSON.parse(gt); } catch { /* leave */ }
  }
  if (Array.isArray(gt) && gt.length > 0) return (gt[0] ?? {}) as Record<string, unknown>;
  if (gt && typeof gt === "object" && !Array.isArray(gt)) return gt as Record<string, unknown>;
  return {};
}

function gtName(gt: Record<string, unknown>): string {
  if ("name" in gt) return String(gt.name);
  const keys = Object.keys(gt);
  return keys.length ? keys[0]! : "";
}

// ---------------------------------------------------------------------------
// Eval loop.
// ---------------------------------------------------------------------------

export async function evaluateBfcl(
  tm: TaskModel,
  opts: { nSamples?: number; maxTokens?: number; seed?: number } = {},
): Promise<BfclResult> {
  const maxTokens = opts.maxTokens ?? 512;
  const rows = loadJsonl<BfclRow>("bfcl");
  const idx = sampleIndices(rows.length, opts.nSamples ?? 200, opts.seed ?? 42);

  let nCorrect = 0;
  let nNoCall = 0;
  let nWrongName = 0;
  let nWrongArgs = 0;

  for (let k = 0; k < idx.length; k++) {
    const row = rows[idx[k]!]!;
    const q = row.query;
    const text = userText(q.question);
    const tools = wrapToolsForChat(q.function);
    const prompt = buildPrompt(text, tools);

    const out = await generateText(tm, prompt, { maxTokens, useChat: true });
    const predicted = extractToolCall(out);
    const gt = parseGroundTruth(row.answer.ground_truth);

    if (predicted === null) {
      nNoCall++;
    } else if (!callsMatch(predicted, gt)) {
      const predName = String(predicted.name ?? "").trim();
      if (predName !== gtName(gt).trim()) nWrongName++;
      else nWrongArgs++;
    } else {
      nCorrect++;
    }

    if ((k + 1) % 10 === 0 || k + 1 === idx.length) {
      process.stderr.write(
        `\r  bfcl ${k + 1}/${idx.length}  acc=${((nCorrect / (k + 1)) * 100).toFixed(1)}%`,
      );
    }
  }
  process.stderr.write("\n");

  const nTotal = idx.length;
  return {
    nCorrect,
    nTotal,
    accuracy: nTotal ? nCorrect / nTotal : 0,
    nNoCall,
    nWrongName,
    nWrongArgs,
  };
}
