// Token → text streaming stages shared by every completion surface:
// StreamDecoder (mlx-lm byte-parity incremental detokenizer), ToolAwareStream
// (tool-call / reasoning-channel routing), StopMatcher (decoded-text stop
// sequences), ThinkingTagSplitter (<think> markup → reasoning deltas).
// Extracted from src/server.ts (repo-taming Phase 4).
import type { ToolDefinition } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";
import {
  CHANNEL_END, CHANNEL_START, parseGeneratedToolCalls, parseToolCalls,
  TOOL_CALL_END, TOOL_CALL_START,
} from "../tool-call";

export interface OpenAIToolCall {
  id: string;
  type: "function";
  function: { name: string; arguments: string };
}

export type ToolStreamMode = "gemma-sentinel" | "plain" | "buffered-text";

/** Pick the stream router for a model family. The token-id sentinel router is
 *  Gemma-4-ONLY: ids 48/49 (<|tool_call>/<tool_call|>) and 100/101
 *  (<|channel>/<channel|>) are special tokens of that tokenizer family
 *  (src/tool-call.ts). On every other tokenizer — MiniCPM5, Qwen3/3.5, and
 *  the Tier-0 generics (llama, qwen2, phi3, …) — those ids are ordinary
 *  low-id vocab, so the sentinel router would silently swallow output into a
 *  phantom tool/reasoning segment. Everyone else parses tool calls from
 *  decoded text (buffered-text; parseGeneratedToolCalls covers the
 *  OpenAI-JSON <tool_call>, Qwen <function=…>, and MiniCPM5 <function name=…>
 *  shapes) when tools are present, and streams plain otherwise. Models whose
 *  markup isn't covered fail soft: the markup stays in content. */
export function selectToolStreamMode(modelType: string, hasTools: boolean): ToolStreamMode {
  if (modelType.startsWith("gemma4")) return "gemma-sentinel";
  return hasTools ? "buffered-text" : "plain";
}

/** Routes generated tokens. Gemma uses family-specific sentinel token ids;
 *  MiniCPM5 and other text-template models use decoded-text parsing so
 *  ordinary tokenizer ids like "<" are never swallowed globally. Exported for
 *  unit tests (gemma-channel reasoning split). */
export class ToolAwareStream {
  readonly #decoder: StreamDecoder;
  #inTool = false;
  #toolTokens: number[] = [];
  #text = "";
  /** Chars of #text already returned as content. */
  #sent = 0;
  /** Index where tool markup starts; content emission stops there. */
  #frozen = -1;
  #textToolCalls: OpenAIToolCall[] | null = null;
  #textToolParseFailed = false;
  readonly toolSegments: number[][] = [];

  /** Gemma reasoning-channel state (gemma-sentinel mode). The model wraps
   *  chain-of-thought as `<|channel>thought\n…<channel|>` using special tokens
   *  100/101 that the content decoder strips, so reasoning is captured here at
   *  the token level. A SEPARATE decoder keeps the reasoning byte-stream's
   *  incremental state independent of content's. The `thought` channel-name
   *  word is stripped before the reasoning text (mlx-lm's think-start marker
   *  is `<|channel>thought`; the "\n" after it is reasoning content). */
  readonly #channelDecoder: StreamDecoder;
  #inChannel = false;
  #channelNamePending = "";
  #channelNameDone = false;
  #reasoning = "";

  /** Decoded-text markers that open tool markup (oracle: the streaming
   *  parser buffers from `<tool_call`/`<function` on, never the whole
   *  response — content before a tool call still streams live). */
  static readonly TOOL_MARKERS = ["<tool_call>", "<function"];

  constructor(
    readonly tokenizer: LoadedTokenizer,
    readonly mode: ToolStreamMode,
    readonly tools: ToolDefinition[] | null,
    /** Fired when parseGeneratedToolCalls rejects the emitted markup. The
     *  fill table (src/fill/) subscribes: a request whose tool call the
     *  parser refuses is a request whose template rendering disagreed with
     *  what the model emits, so its strict rows are disarmed. */
    private readonly onParseFailure?: () => void,
  ) {
    this.#decoder = new StreamDecoder(tokenizer, mode !== "buffered-text");
    this.#channelDecoder = new StreamDecoder(tokenizer, true);
  }

  /** Feed decoded channel text, stripping the leading `thought` channel-name
   *  word (which may arrive across tokens). Returns the reasoning delta.
   *  mlx-lm parity: its think-start marker is exactly `<|channel>thought`
   *  (tokenizer_utils.py `_infer_thinking`) and only the MARKER tokens get
   *  their text blanked (server.py `_process_control_tokens`) — the "\n"
   *  after the name is an ordinary generated token, so it is the FIRST byte
   *  of the reasoning stream and must be kept, not swallowed with the name. */
  #feedChannel(text: string): string {
    if (this.#channelNameDone) return text;
    this.#channelNamePending += text;
    const nl = this.#channelNamePending.indexOf("\n");
    if (nl === -1) return ""; // still inside the channel-name word
    this.#channelNameDone = true;
    const rest = this.#channelNamePending.slice(nl); // keep the "\n" (mlx-lm does)
    this.#channelNamePending = "";
    return rest;
  }

  /** Drain reasoning captured since the last call (gemma-channel thinking). */
  takeReasoning(): string {
    const r = this.#reasoning;
    this.#reasoning = "";
    return r;
  }

  /** Emit the longest #text prefix that cannot be (the start of) tool
   *  markup; hold back ambiguous tails until disambiguated. */
  #textDelta(): string {
    if (this.#frozen >= 0) return "";
    let markerAt = -1;
    for (const mk of ToolAwareStream.TOOL_MARKERS) {
      const i = this.#text.indexOf(mk, this.#sent);
      if (i !== -1 && (markerAt === -1 || i < markerAt)) markerAt = i;
    }
    if (markerAt !== -1) {
      this.#frozen = markerAt;
      const out = this.#text.slice(this.#sent, markerAt);
      this.#sent = markerAt;
      return out;
    }
    let hold = 0;
    for (const mk of ToolAwareStream.TOOL_MARKERS) {
      const max = Math.min(mk.length - 1, this.#text.length - this.#sent);
      for (let k = max; k > hold; k--) {
        if (this.#text.endsWith(mk.slice(0, k))) { hold = k; break; }
      }
    }
    const limit = this.#text.length - hold;
    if (limit <= this.#sent) return "";
    const out = this.#text.slice(this.#sent, limit);
    this.#sent = limit;
    return out;
  }

  /** Returns the content text delta for this token ("" while capturing). */
  push(token: number): string {
    if (this.mode !== "gemma-sentinel") {
      this.#text += this.#decoder.push(token);
      if (this.mode === "plain") {
        const out = this.#text.slice(this.#sent);
        this.#sent = this.#text.length;
        return out;
      }
      return this.#textDelta();
    }
    if (this.#inTool) {
      if (token === TOOL_CALL_END) {
        this.#inTool = false;
        this.toolSegments.push(this.#toolTokens);
        this.#toolTokens = [];
      } else {
        this.#toolTokens.push(token);
      }
      return "";
    }
    // Reasoning channel: tokens between <|channel> and <channel|> are thought,
    // captured to #reasoning (drained via takeReasoning), never content. An
    // empty block (<|channel>thought\n<channel|>, emitted by larger Gemmas even
    // with thinking off) yields only the "\n" as reasoning (mlx-lm parity) and
    // leaks nothing into content.
    if (this.#inChannel) {
      if (token === CHANNEL_END) {
        this.#inChannel = false;
        this.#reasoning += this.#feedChannel(this.#channelDecoder.flush());
      } else {
        this.#reasoning += this.#feedChannel(this.#channelDecoder.push(token));
      }
      return "";
    }
    if (token === CHANNEL_START) {
      this.#inChannel = true;
      this.#channelNameDone = false;
      this.#channelNamePending = "";
      return "";
    }
    if (token === TOOL_CALL_START) {
      this.#inTool = true;
      return "";
    }
    return this.#decoder.push(token);
  }

  flush(): string {
    if (this.mode !== "gemma-sentinel") {
      this.#text += this.#decoder.flush();
      if (this.mode === "buffered-text") {
        const calls = this.toolCalls();
        if (calls.length && !this.#textToolParseFailed && this.#frozen >= 0) {
          // markup parsed into tool_calls — emit any prose still held
          // before it; the markup itself never reaches content
          const out = this.#text.slice(this.#sent, this.#frozen);
          this.#sent = this.#text.length;
          return out;
        }
        // no tool call (or parse fallback): release everything withheld
        const out = this.#text.slice(this.#sent);
        this.#sent = this.#text.length;
        return out;
      }
      const out = this.#text.slice(this.#sent);
      this.#sent = this.#text.length;
      return out;
    }
    if (this.#inChannel) {
      // truncated mid-reasoning (hit max_tokens); surface the partial thought
      this.#reasoning += this.#feedChannel(this.#channelDecoder.flush());
      this.#inChannel = false;
      return "";
    }
    if (this.#inTool && this.#toolTokens.length) {
      // truncated mid-tool-call (hit max_tokens); surface what we have
      this.toolSegments.push(this.#toolTokens);
      this.#toolTokens = [];
    }
    return this.#decoder.flush();
  }

  toolCalls(): OpenAIToolCall[] {
    if (this.mode !== "gemma-sentinel") {
      if (this.#textToolCalls) return this.#textToolCalls;
      try {
        this.#textToolCalls = parseGeneratedToolCalls(this.#text, this.tools ?? []).map((c) => ({
          id: `call_${crypto.randomUUID().slice(0, 8)}`,
          type: "function",
          function: { name: c.name, arguments: JSON.stringify(c.arguments) },
        }));
      } catch {
        this.#textToolParseFailed = true;
        this.#textToolCalls = [];
        this.onParseFailure?.();
      }
      return this.#textToolCalls;
    }
    const out: OpenAIToolCall[] = [];
    for (const seg of this.toolSegments) {
      const text = this.tokenizer.decode(seg, false); // keep <|"|> markers
      for (const c of parseToolCalls(text)) {
        out.push({
          id: `call_${crypto.randomUUID().slice(0, 8)}`,
          type: "function",
          function: { name: c.name, arguments: JSON.stringify(c.arguments) },
        });
      }
    }
    return out;
  }
}

/** Decoded-text stop-sequence matcher with streaming hold-back. Matching
 *  on text (not token ids) catches sequences that span token boundaries
 *  or tokenize differently in context; current mlx-lm uses token-id
 *  state machines and misses those. Text that could be the start of a
 *  stop sequence is withheld until disambiguated, so SSE clients never
 *  see any part of the stop sequence itself. */
export class StopMatcher {
  #pending = "";
  stopped = false;

  constructor(readonly sequences: string[]) {}

  /** Feed a text delta; returns the prefix that is now safe to emit.
   *  After a match fires (`stopped`), text before the match is returned
   *  and everything from the match on is discarded. */
  push(text: string): string {
    if (this.stopped) return "";
    if (this.sequences.length === 0) return text;
    this.#pending += text;
    // earliest full match wins
    let cut = -1;
    for (const seq of this.sequences) {
      const i = this.#pending.indexOf(seq);
      if (i !== -1 && (cut === -1 || i < cut)) cut = i;
    }
    if (cut !== -1) {
      this.stopped = true;
      const out = this.#pending.slice(0, cut);
      this.#pending = "";
      return out;
    }
    // hold back the longest tail that is a proper prefix of any sequence
    let hold = 0;
    for (const seq of this.sequences) {
      const max = Math.min(seq.length - 1, this.#pending.length);
      for (let k = max; k > hold; k--) {
        if (this.#pending.endsWith(seq.slice(0, k))) {
          hold = k;
          break;
        }
      }
    }
    if (hold === 0) {
      const out = this.#pending;
      this.#pending = "";
      return out;
    }
    const out = this.#pending.slice(0, -hold);
    this.#pending = this.#pending.slice(-hold);
    return out;
  }

  /** Generation ended without a match — release any held-back text. */
  flush(): string {
    const out = this.#pending;
    this.#pending = "";
    return out;
  }
}

/** Split Qwen-style inline <think>...</think> markup into OpenAI reasoning
 *  deltas/content. This keeps raw tags out of normal chat text while giving
 *  pi (TUI + web) proper thinking_delta events. It is streaming-safe: partial
 *  tag prefixes are held until disambiguated. */
export class ThinkingTagSplitter {
  #pending = "";
  #inThinking: boolean;
  reasoning = "";
  content = "";

  /** `startInThinking` seeds the parser INSIDE a <think> block. Needed for
   *  templates (Qwen3.5, MiniCPM5) that prime an OPEN `<think>` in the
   *  generation prompt when thinking is enabled: the model's output then
   *  starts mid-reasoning and emits only the closing `</think>`, never an
   *  opening tag. Without this seed the whole chain-of-thought leaks into
   *  `content` and the `reasoning` field stays empty. */
  constructor(private readonly enabled: boolean, startInThinking = false) {
    this.#inThinking = startInThinking;
  }

  #safePrefixUntilTag(tag: string): string {
    const i = this.#pending.indexOf(tag);
    if (i !== -1) return this.#pending.slice(0, i);
    let hold = 0;
    for (let k = Math.min(tag.length - 1, this.#pending.length); k > 0; k--) {
      if (this.#pending.endsWith(tag.slice(0, k))) { hold = k; break; }
    }
    return this.#pending.slice(0, this.#pending.length - hold);
  }

  push(text: string): { content: string; reasoning: string } {
    if (!this.enabled) {
      this.content += text;
      return { content: text, reasoning: "" };
    }
    this.#pending += text;
    let content = "";
    let reasoning = "";
    while (this.#pending) {
      const tag = this.#inThinking ? "</think>" : "<think>";
      const i = this.#pending.indexOf(tag);
      const emit = i === -1 ? this.#safePrefixUntilTag(tag) : this.#pending.slice(0, i);
      if (!emit && i === -1) break;
      if (emit) {
        if (this.#inThinking) reasoning += emit;
        else content += emit;
        this.#pending = this.#pending.slice(emit.length);
      }
      if (i !== -1 && this.#pending.startsWith(tag)) {
        this.#pending = this.#pending.slice(tag.length);
        this.#inThinking = !this.#inThinking;
        continue;
      }
      if (i === -1) break;
    }
    this.content += content;
    this.reasoning += reasoning;
    return { content, reasoning };
  }

  flush(): { content: string; reasoning: string } {
    if (!this.enabled) return { content: "", reasoning: "" };
    const out = this.#inThinking
      ? { content: "", reasoning: this.#pending }
      : { content: this.#pending, reasoning: "" };
    this.#pending = "";
    this.content += out.content;
    this.reasoning += out.reasoning;
    return out;
  }
}

/** Incremental detokenizer: emits the longest stable decoded prefix.
 *
 *  Byte parity with mlx-lm's streaming detokenizers (the drop-in contract is
 *  rendered BYTES, not just token ids). For BPE/ByteLevel tokenizers, two
 *  mlx-lm 0.31.3 BPEStreamingDetokenizer behaviors our full-sequence decode
 *  lacks (tokenizer_utils.py:195-226):
 *
 *  1. `trimsLeadingSpace` — mlx-lm drops ONE leading " " at the start of the
 *     generated sequence (`_maybe_trim_space`); trim it here. SPM decode
 *     already matches (see LoadedTokenizer.trimsLeadingSpace).
 *  2. `bareSpaceTokenId` — add_token WITHHOLDS a single-char byte-32 token
 *     ("Ġ") in `_unflushed` ("For single spaces wait until the next token"),
 *     flushing it together with the NEXT token — and mlx_lm.server NEVER
 *     calls detokenizer.finalize() (zero hits in server.py 0.31.3), so a
 *     generation ENDING on bare-space token(s) silently drops their spaces
 *     from the served bytes. push() withholds those spaces; flush() drops a
 *     trailing bare-space run (the held text dies with the request, exactly
 *     like mlx-lm serve). Re-check both if upstream ever adds a finalize()
 *     call. LATENT HAZARD (deliberately not emulated): models with
 *     clean_up_tokenization_spaces=true get an ADDITIONAL mid-stream rule
 *     (`_space_matches`: held space dropped before "." "," "'s" …) — both
 *     current BPE targets have it false (MiniCPM5), so it never fires here.
 *
 *  Exported for unit tests (serve-detok mlx-lm byte parity). */
export class StreamDecoder {
  static readonly #WINDOW_TOKENS = 32;
  #ids: number[] = [];
  #emitted = "";
  #warnedRevision = false;
  /** Token index where the bounded decode suffix begins. */
  #windowStart = 0;
  /** Exact decoded text before #windowStart, established by suffix matching. */
  #windowPrefix = "";
  readonly #trimLeadingSpace: boolean;
  readonly #bareSpaceId: number | undefined;

  constructor(
    readonly tokenizer: LoadedTokenizer,
    readonly skipSpecialTokens = true,
  ) {
    this.#trimLeadingSpace = tokenizer.trimsLeadingSpace === true;
    this.#bareSpaceId = tokenizer.bareSpaceTokenId;
  }

  #decode(ids: number[]): string {
    const full = this.#decodeRaw(ids);
    return this.#trimLeadingSpace && full.startsWith(" ") ? full.slice(1) : full;
  }

  #decodeRaw(ids: number[]): string {
    return this.tokenizer.decode(ids, this.skipSpecialTokens);
  }

  /** Decode only a bounded suffix once an exact text anchor can be proven.
   *
   * At each rebase, decode a candidate suffix independently and accept it only
   * when it is literally the suffix of the exact text decoded so far. This
   * preserves ByteLevel/SPM boundary behavior while reducing steady-state
   * decode work from the whole generation to 32–64 tokens. If no suffix can be
   * anchored (an unusual/global decoder), leave #windowStart at zero and keep
   * the full-history correctness path. */
  #decodeIncremental(): string {
    const full = this.#windowStart === 0
      ? this.#decode(this.#ids)
      : this.#windowPrefix + this.#decodeRaw(this.#ids.slice(this.#windowStart));

    if (this.#ids.length - this.#windowStart < StreamDecoder.#WINDOW_TOKENS * 2)
      return full;

    const preferred = this.#ids.length - StreamDecoder.#WINDOW_TOKENS;
    const oldest = Math.max(this.#windowStart, preferred - StreamDecoder.#WINDOW_TOKENS);
    for (let start = preferred; start >= oldest; start--) {
      const tail = this.#decodeRaw(this.#ids.slice(start));
      if ((tail.length > 0 || full.length === 0) && full.endsWith(tail)) {
        this.#windowStart = start;
        this.#windowPrefix = full.slice(0, full.length - tail.length);
        break;
      }
    }
    return full;
  }

  push(token: number): string {
    this.#ids.push(token);
    // Bare-space hold-back (mlx-lm add_token keeps "Ġ" in _unflushed): don't
    // advance #emitted; the held space(s) flush as part of the next
    // non-bare-space token's delta — consecutive bare spaces accumulate.
    if (token === this.#bareSpaceId) return "";
    const full = this.#decodeIncremental();
    // hold back a trailing replacement char (partial multi-byte sequence)
    const stable = full.endsWith("�") ? full.slice(0, -1) : full;
    if (!stable.startsWith(this.#emitted)) {
      // The decoder revised already-streamed text (cleanup rules — never
      // fires for the shipped tokenizers, which all have
      // clean_up_tokenization_spaces=false; see the LATENT HAZARD note in
      // the class doc). An SSE client cannot un-receive bytes, so the old
      // "re-emit from scratch" answer DUPLICATED the whole stream
      // (2026-07-07 review). Truncate-safe resync instead: emit only the
      // length-extension and keep the emitted watermark monotone — byte
      // drift is confined to the revised span, and the once-per-stream
      // warning makes the tokenizer that needs real _space_matches
      // emulation loud instead of silently wrong.
      if (!this.#warnedRevision) {
        this.#warnedRevision = true;
        console.warn(
          "[detok] decoder revised already-streamed text (clean_up_tokenization_spaces?) — " +
            "resyncing without re-emit; add mlx-lm's cleanup-rule emulation for this tokenizer",
        );
      }
      if (stable.length <= this.#emitted.length) return "";
      const out = stable.slice(this.#emitted.length);
      this.#emitted = stable;
      return out;
    }
    const delta = stable.slice(this.#emitted.length);
    this.#emitted = stable;
    return delta;
  }

  flush(): string {
    // mlx_lm.server never finalize()s: a trailing bare-space run stays
    // withheld forever, so its text is dropped from the served bytes.
    let ids = this.#ids;
    if (this.#bareSpaceId !== undefined) {
      let n = ids.length;
      while (n > 0 && ids[n - 1] === this.#bareSpaceId) n--;
      if (n < ids.length) ids = ids.slice(0, n);
    }
    const full = this.#decode(ids);
    const delta = full.slice(this.#emitted.length);
    this.#emitted = full;
    return delta;
  }
}
