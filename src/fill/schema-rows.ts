// Strict fill rows (K3b) — the chat template is its own oracle.
//
// Nothing here knows what a tool-call format looks like. We render the SAME
// conversation several ways, tokenize each rendering, and diff the token id
// sequences: what does NOT change is, by construction, the template's fixed
// scaffold — the tokens the model must emit no matter what it decides. Those
// become rows. Same technique as request-prep.ts::stableLenFor's primer probe,
// applied to the assistant turn instead of the generation prompt.
//
// TWO RULES, both learned the hard way.
//
// 1. EVERY SPAN IS SLICED FROM A RENDERING THE MODEL COULD ACTUALLY PRODUCE —
//    real tool names, real schema keys. Never `encode(fragment)` in isolation,
//    and never a rendering built from placeholder names. BPE merges across the
//    template's own punctuation: Qwen3.5 renders `<function=get_weather>` as
//    `< function =get _weather >` — `=get` is ONE token. A probe named
//    `zzalphatoolqq` instead splits as `… = zzalpha…`, inventing a boundary
//    after `=` that the real stream never has. A scaffold row ending at that
//    boundary injects a bare `=`, and the model then emits `get` where it would
//    have emitted `=get`: byte-identical text, DIVERGENT token ids, KV that no
//    longer matches what a plain decode would have written (caught on
//    Qwen3.5-0.8B, 2026-08-31). So the diff's role is only to decide WHERE to
//    cut; the ids always come from the real-name rendering, which makes every
//    cut a token boundary of a stream the model can produce.
// 2. Every span is anchored at a DISTINCTIVE token (one carrying letters or
//    markup, e.g. `<tool_call>` or `function`), with leading whitespace-only
//    tokens dropped from the trigger. The engine only fills after the model has
//    itself committed to something unambiguous — a bare `}` or `"` never arms a
//    row.
//
// Safety is structural: a template that does not render `tool_calls` (or
// renders them without the name/arguments) produces IDENTICAL probes, the diff
// is empty, and no rows are compiled — degrade to no-fill, never wrong output.
import type { ChatMessage, RenderOptions, ToolDefinition } from "../chat-template";
import type { FillRow } from "./fill-session";

/** The template surface row compilation needs (ChatTemplate satisfies it). */
export interface FillTemplateLike {
  render(messages: ChatMessage[], options: RenderOptions): string;
}

/** The tokenizer surface row compilation needs (LoadedTokenizer satisfies it). */
export interface FillTokenizerLike {
  encode(text: string, addSpecialTokens?: boolean): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
  readonly bosTokenId: number | null;
}

// Probe literals. Chosen so no two share a first OR last character run: the
// diff is taken from both ends, and a shared suffix like "…probe" would make
// the call-close span look longer than it is.
//
// NAME_GUARD and KEY_ALT are DIAGNOSTIC ONLY — they answer "does this template
// render the name / the argument keys at all?". Nothing is ever sliced out of
// a rendering that carries them (see rule 1 in the file header).
const NAME_GUARD = "zzalphatoolqq";
const KEY_ALT = "zzalphakeyqq";
const VALUE_A = "zzalphavalqq";
const VALUE_B = "wwbetavalmm";
const VALUE_NUM = 987654;
const CONTENT_A = "zzalphatextqq";
const CONTENT_B = "wwbetatextmm";
// Call ids differ per probe too: a template that renders `tool_calls[].id`
// would otherwise bake a probe id into the "fixed" scaffold and we would
// inject an id the model never chose. Differing ids make that span diverge,
// so the diff stops before it.
const ID_A = "call_zzalphaidqq";
const ID_B = "call_wwbetaidmm";
const ID_N = "call_vvgammaidkk";

/** Tools compiled per plan (a pathological request with hundreds of tools
 *  would otherwise pay hundreds of renders). */
const MAX_TOOLS = 32;
/** A "scaffold" longer than this is a diff that went wrong, not punctuation. */
const MAX_SPAN_TOKENS = 64;
/** Cap on a name row's disambiguating token run (tools whose names tokenize
 *  alike for longer than this get no row). */
const MAX_NAME_TRIGGER = 8;

export interface CompileStrictRowsInput {
  template: FillTemplateLike;
  tokenizer: FillTokenizerLike;
  /** The conversation to render around. Row ids are assumed independent of it
   *  (the assistant turn opens with a special token, and special tokens break
   *  BPE merges) — the same assumption stableLenFor's memoized primer length
   *  already makes, which is why callers may cache rows per (mode, tools). */
  messages: ChatMessage[];
  tools: ToolDefinition[];
  /** Template options for this request mode (tools, thinking, effort …).
   *  `addGenerationPrompt` is set per probe and ignored here. */
  renderOptions: Omit<RenderOptions, "addGenerationPrompt">;
}

export interface StrictRowPlan {
  rows: FillRow[];
  /** Token ids that legitimately END an argument value in this template — the
   *  closing quote (JSON) or the markup that follows a value (`</parameter`).
   *  Read off the diff between two value probes: the first non-whitespace
   *  token their renderings share AFTER the value is what terminates it. The
   *  echo tier uses these to decide where a copied span may stop (and, with a
   *  clean stop, may be asserted rather than verified). */
  delimiters: number[];
}

/** Compile the request's strict rows, or an empty plan when the template gives
 *  no determined span. Never throws: a template that raises on a probe render
 *  degrades to no rows. */
export function compileStrictFillRows(input: CompileStrictRowsInput): StrictRowPlan {
  try {
    return compile(input);
  } catch {
    return { rows: [], delimiters: [] };
  }
}

function compile(input: CompileStrictRowsInput): StrictRowPlan {
  const { template, tokenizer, messages, tools, renderOptions } = input;
  const empty: StrictRowPlan = { rows: [], delimiters: [] };
  if (!tools.length) return empty;

  const encode = (text: string): number[] => {
    const ids = tokenizer.encode(text);
    // The template emits the BOS as text and the post-processor prepends one:
    // same de-duplication as request-prep.promptIdsFor.
    return ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids;
  };
  const distinctive = distinctiveTest(tokenizer);
  const whitespace = whitespaceTest(tokenizer);

  // The generation prompt — everything after it is what the model produces.
  const baseText = template.render(messages, { ...renderOptions, addGenerationPrompt: true });
  const base = encode(baseText);
  // A suffix tokenized on its own may get the post-processor's BOS prepended
  // (llama-style tokenizers); Qwen-style ones yield [] for "".
  const bosPrepended = (() => { const e = tokenizer.encode(""); return e.length === 1 && e[0] === tokenizer.bosTokenId; })();
  const encodeSuffix = (text: string): number[] => {
    const ids = tokenizer.encode(text);
    return bosPrepended && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids;
  };

  /** Token ids of the assistant turn that follows the generation prompt.
   *  Preferred: the whole rendering tokenized once, sliced past the primer's
   *  ids. When the primer's last token MERGES with the reply's first (Qwen3.x
   *  thinking templates end the primer in `<think>\n` and the reply opens with
   *  `\n</think>`, so `\n`+`\n` becomes one `\n\n` token and the primer is no
   *  longer a token prefix), fall back to the TEXT boundary and tokenize the
   *  reply on its own — that is the stream the model produces after the
   *  prompt ids anyway. Only a rendering that does not extend the primer text
   *  at all bails. */
  const after = (rendered: string): number[] | null => {
    const ids = encode(rendered);
    if (startsWith(ids, base)) return ids.slice(base.length);
    if (!rendered.startsWith(baseText)) return null; // primer is not a prefix — bail
    return encodeSuffix(rendered.slice(baseText.length));
  };
  const callProbe = (
    name: string, args: Record<string, unknown>, id: string,
  ): number[] | null =>
    after(template.render(
      [...messages, {
        role: "assistant",
        content: "",
        tool_calls: [{ id, type: "function", function: { name, arguments: args } }],
      }],
      { ...renderOptions, addGenerationPrompt: false },
    ));
  const contentProbe = (text: string): number[] | null =>
    after(template.render(
      [...messages, { role: "assistant", content: text }],
      { ...renderOptions, addGenerationPrompt: false },
    ));

  // --- per-tool determined spans, each sliced from its OWN real rendering ---
  // `determinedSpan` cuts where a variant diverges, but the ids it returns
  // always come from a rendering with this tool's real name and real keys —
  // so every cut is a token boundary of a stream the model can produce.
  const spans: { name: string; span: number[] }[] = [];
  for (const tool of tools.slice(0, MAX_TOOLS)) {
    const name = tool.function?.name;
    if (typeof name !== "string" || !name) continue;
    const span = determinedSpan(tool, name, callProbe);
    if (span && span.length && span.length <= MAX_SPAN_TOKENS)
      spans.push({ name, span });
  }
  if (!spans.length) return empty;
  // Does the template render the NAME at all? Diagnostic only — a rendering
  // carrying NAME_GUARD is never sliced. Identical ⇒ nothing is determined by
  // the model's choice of tool, so there is nothing safe to fill.
  const first = spans[0]!;
  const guard = callProbe(NAME_GUARD, { [KEY_ALT]: VALUE_A }, ID_A);
  const real = callProbe(first.name, { [KEY_ALT]: VALUE_A }, ID_A);
  if (!guard || !real || sameIds(guard, real)) return empty;

  // Scaffold = what every tool's rendering shares. With ONE tool that is the
  // whole determined span (call open + name + fixed structure up to the first
  // free value position); with several it ends exactly where the real, merged
  // name tokens diverge — `=get` vs `=search`, the only boundary the model's
  // own greedy stream can respect.
  let scaffold = first.span;
  for (const other of spans.slice(1)) scaffold = commonPrefix(scaffold, other.span);
  if (scaffold.length === 0) return empty;
  // Every trigger is expressed from the SAME anchor as the scaffold row's, so
  // the rows chain: after the scaffold fires, the history tail is exactly the
  // scaffold, and a name row's trigger (scaffold + disambiguating run) matches.
  const anchor = leadingSkip(scaffold, whitespace);

  const rows: FillRow[] = [];
  const openRow = anchoredRow(scaffold, "scaffold", distinctive, whitespace);
  if (openRow) rows.push(openRow);

  // --- per-tool name completion ----------------------------------------
  // Fires on the shortest run of tokens after the scaffold that identifies ONE
  // tool (a trie over the real name tokenizations), then carries the rest of
  // that tool's determined span — for a sole-required-key schema, all the way
  // through the key to where the value's own content begins.
  for (const { name, span } of spans) {
    if (span.length <= scaffold.length) continue;
    const k = disambiguationLength(span, scaffold.length, spans);
    if (k === null) continue;
    const emit = span.slice(scaffold.length + k);
    if (emit.length < 2) continue;
    rows.push({
      trigger: [
        ...scaffold.slice(anchor),
        ...span.slice(scaffold.length, scaffold.length + k),
      ],
      emit,
      kind: "name",
    });
  }

  // --- value delimiters, call close, turn end ---------------------------
  // Two renderings of the SAME real tool differing only in the VALUE: their
  // shared tail is [what closes the value, call close, turn end], sliced from
  // a real rendering. (Differing the KEY instead would put the value itself in
  // the "shared" tail, and the value is the model's to choose.)
  const closeKey = firstKeyOf(tools[0]!) ?? KEY_ALT;
  const a = callProbe(first.name, { [closeKey]: VALUE_A }, ID_A);
  const b = callProbe(first.name, { [closeKey]: VALUE_B }, ID_B);
  if (!a || !b || sameIds(a, b)) return { rows, delimiters: [] };
  const sharedTail = commonSuffix(a, b);
  // The first NON-whitespace token after the value is what terminates it.
  // Whitespace is excluded on purpose: a newline ends nothing in particular,
  // and treating it as a delimiter would let the echo tier assert on it.
  const delimiters: number[] = [];
  const valueEnd = sharedTail.find((id) => !whitespace(id));
  if (valueEnd !== undefined) delimiters.push(valueEnd);

  // A close row fires after the FIRST argument value ends, so it is only
  // determined when the call must end there: EVERY tool in the request takes
  // exactly one, required argument. Otherwise the model may still be about to
  // write a second `<parameter=…>` and injecting the close would silently drop
  // it — the request's own schema decides whether this row exists at all.
  const singleArgRequest = tools.slice(0, MAX_TOOLS).every((tool) => {
    const { keys, required } = keysOf(tool);
    return keys.length === 1 && required.includes(keys[0]!);
  });
  if (!singleArgRequest) return { rows, delimiters };
  // The shared tail of two plain-content probes is the turn end alone.
  const ca = contentProbe(CONTENT_A);
  const cb = contentProbe(CONTENT_B);
  const turnEnd = ca && cb && !sameIds(ca, cb) ? commonSuffix(ca, cb) : [];
  let callClose = sharedTail;
  if (scaffold.length + callClose.length >= Math.min(a.length, b.length)) callClose = [];
  if (turnEnd.length && endsWith(callClose, turnEnd))
    callClose = callClose.slice(0, callClose.length - turnEnd.length);
  if (callClose.length && callClose.length <= MAX_SPAN_TOKENS) {
    const row = anchoredRow(callClose, "close", distinctive, whitespace);
    if (row) rows.push(row);
  }
  if (turnEnd.length && turnEnd.length <= MAX_SPAN_TOKENS) {
    // Usually inert: a turn end starts at EOS, and FillSession cuts every span
    // at the first EOS id. Compiled anyway for templates whose turn end is
    // ordinary markup followed by the stop token.
    const row = anchoredRow(turnEnd, "turn-end", distinctive, whitespace);
    if (row) rows.push(row);
  }
  return { rows, delimiters };
}

type CallProbe = (
  name: string, args: Record<string, unknown>, id: string,
) => number[] | null;

/** Schema keys, in declaration order. */
function keysOf(tool: ToolDefinition): { keys: string[]; required: string[]; closed: boolean } {
  const params = tool.function?.parameters as Record<string, unknown> | undefined;
  const props = params?.properties as Record<string, unknown> | undefined;
  const keys = props && typeof props === "object" ? Object.keys(props) : [];
  const required = (Array.isArray(params?.required) ? params!.required : [])
    .filter((k): k is string => typeof k === "string");
  return { keys, required, closed: params?.additionalProperties === false };
}

function firstKeyOf(tool: ToolDefinition): string | null {
  return keysOf(tool).keys[0] ?? null;
}

/** The key the SCHEMA determines: the only property, and required (so the
 *  model cannot legally omit it). A lone optional property is NOT determined —
 *  the model may emit empty arguments — so the span stops before it. */
function determinedKeyOf(tool: ToolDefinition): string | null {
  const { keys, required, closed } = keysOf(tool);
  if (keys.length === 1 && required.includes(keys[0]!)) return keys[0]!;
  if (required.length === 1 && closed && keys.includes(required[0]!)) return required[0]!;
  return null;
}

/** How much of ONE tool's rendering is determined once the model has committed
 *  to that tool: everything from the call opening through the name, plus the
 *  template's fixed structure, up to the first position whose content the model
 *  chooses. The returned ids are ALWAYS a prefix of the real-name rendering
 *  `a` — variants only decide where to cut (file header, rule 1). */
function determinedSpan(
  tool: ToolDefinition, name: string, probe: CallProbe,
): number[] | null {
  const key = determinedKeyOf(tool);
  if (key) {
    // Real name AND real key: the span runs through the key to where the
    // value's own content starts. The NUMBER variant keeps it type-agnostic —
    // a string value opens with a quote, an integer does not.
    const a = probe(name, { [key]: VALUE_A }, ID_A);
    const b = probe(name, { [key]: VALUE_B }, ID_B);
    const n = probe(name, { [key]: VALUE_NUM }, ID_N);
    if (!a || !b || !n || sameIds(a, b) || sameIds(a, n)) return null;
    return commonPrefix(commonPrefix(a, b), n);
  }
  const { keys } = keysOf(tool);
  if (keys.length >= 2) {
    // Two REAL keys: the cut lands where the model's own choice of first key
    // diverges, whichever way the tokenizer merges the key into the markup.
    const a = probe(name, { [keys[0]!]: VALUE_A }, ID_A);
    const b = probe(name, { [keys[1]!]: VALUE_A }, ID_B);
    if (!a || !b || sameIds(a, b)) return null;
    return commonPrefix(a, b);
  }
  // One optional key, or none: cut at the key boundary using a diagnostic
  // alternative. `a` (the real rendering) is still what gets sliced.
  const a = keys.length === 1
    ? probe(name, { [keys[0]!]: VALUE_A }, ID_A)
    : probe(name, {}, ID_A);
  const b = probe(name, { [KEY_ALT]: VALUE_A }, ID_B);
  if (!a || !b || sameIds(a, b)) return null;
  return commonPrefix(a, b);
}

/** Length of the shortest token run after `at` that no OTHER tool's span
 *  shares — the trie disambiguation for a name row. null when this tool is
 *  still ambiguous within the cap (e.g. two tools whose names tokenize alike
 *  for many tokens): no row rather than a row that could fire for the wrong
 *  tool. */
function disambiguationLength(
  span: readonly number[],
  at: number,
  all: readonly { span: number[] }[],
): number | null {
  const cap = Math.min(MAX_NAME_TRIGGER, span.length - at);
  for (let k = 1; k <= cap; k++) {
    let unique = true;
    for (const other of all) {
      if (other.span === span) continue;
      if (other.span.length < at + k) continue;
      let same = true;
      for (let i = 0; i < k; i++) {
        if (other.span[at + i] !== span[at + i]) { same = false; break; }
      }
      if (same) { unique = false; break; }
    }
    if (unique) return k;
  }
  return null;
}

/** Split a determined span into (trigger the model must produce itself,
 *  tokens we append). Two rules:
 *   - LEADING WHITESPACE IS DROPPED. A template's determined span often opens
 *     with the newline that JOINS the previous message, which the model does
 *     not emit; keeping it in the trigger would mean the row never fires.
 *   - The trigger runs through the first DISTINCTIVE token, so a span opening
 *     with bare punctuation can never fire on a coincidental `}` or `"` in the
 *     middle of an arguments object.
 *  Returns null when the span carries no distinctive token, or when nothing is
 *  left to save. */
function anchoredRow(
  span: number[],
  kind: FillRow["kind"],
  distinctive: (id: number) => boolean,
  whitespace: (id: number) => boolean,
): FillRow | null {
  const rest = span.slice(leadingSkip(span, whitespace));
  const k = rest.findIndex(distinctive);
  if (k === -1) return null;
  const emit = rest.slice(k + 1);
  if (emit.length < 2) return null;
  return { trigger: rest.slice(0, k + 1), emit, kind };
}

/** Count of leading whitespace-only tokens. */
function leadingSkip(span: readonly number[], whitespace: (id: number) => boolean): number {
  let j = 0;
  while (j < span.length && whitespace(span[j]!)) j++;
  return j;
}

/** A token is distinctive when its piece carries letters or markup — i.e. it
 *  is content, not JSON punctuation the model could emit anywhere. */
function distinctiveTest(tokenizer: FillTokenizerLike): (id: number) => boolean {
  // A LETTER, not merely markup. `</` is markup and passes a `[<>]` test, but
  // it is also the first token of every closing tag the model might write in
  // ordinary prose or a code block — arming a row on it would inject tool-call
  // markup into an HTML snippet. `</parameter` (two tokens, letters in the
  // second) is specific to the template's tool syntax.
  return pieceTest(tokenizer, (piece) => /[A-Za-z]/.test(piece));
}

/** A token whose piece is nothing but whitespace (template joins). */
function whitespaceTest(tokenizer: FillTokenizerLike): (id: number) => boolean {
  return pieceTest(tokenizer, (piece) => piece.length > 0 && /^\s+$/.test(piece));
}

function pieceTest(
  tokenizer: FillTokenizerLike,
  predicate: (piece: string) => boolean,
): (id: number) => boolean {
  const memo = new Map<number, boolean>();
  return (id: number): boolean => {
    const hit = memo.get(id);
    if (hit !== undefined) return hit;
    let value = false;
    try {
      value = predicate(tokenizer.decode([id], false));
    } catch { value = false; }
    memo.set(id, value);
    return value;
  };
}

function commonPrefix(a: readonly number[], b: readonly number[]): number[] {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[i] === b[i]) i++;
  return a.slice(0, i);
}

function commonSuffix(a: readonly number[], b: readonly number[]): number[] {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[a.length - 1 - i] === b[b.length - 1 - i]) i++;
  return a.slice(a.length - i);
}

function startsWith(ids: readonly number[], prefix: readonly number[]): boolean {
  if (prefix.length > ids.length) return false;
  for (let i = 0; i < prefix.length; i++) if (ids[i] !== prefix[i]) return false;
  return true;
}

function endsWith(ids: readonly number[], suffix: readonly number[]): boolean {
  if (suffix.length > ids.length) return false;
  const base = ids.length - suffix.length;
  for (let i = 0; i < suffix.length; i++) if (ids[base + i] !== suffix[i]) return false;
  return true;
}

function sameIds(a: readonly number[], b: readonly number[]): boolean {
  return a.length === b.length && a.every((v, i) => v === b[i]);
}
