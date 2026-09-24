// Tokenizer: @huggingface/tokenizers (pure JS/TS — no native code, no
// WASM; embeds directly in `bun build --compile`). Decision spike result:
// see PLAN.md Phase 1 findings. Correctness contract: round-trip parity
// with the Python oracle's AutoTokenizer (goldens/tokenizer.json).

import { Tokenizer } from "@huggingface/tokenizers";

export interface LoadedTokenizer {
  /** Encode text → token ids. `addSpecialTokens` (default true) prepends the BOS;
   *  pass FALSE for chat-template output, which already emits the BOS as text (else
   *  you get a corrupting double-BOS `<s><s>…`). */
  encode(text: string, addSpecialTokens?: boolean): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
  /** Token id → raw vocab token string (mlx-lm's convert_ids_to_tokens —
   *  the undecoded piece, e.g. "▁Hello", used in logprobs responses).
   *  Falls back to decode() for ids outside the base vocab (added tokens). */
  idToToken(id: number): string;
  readonly bosTokenId: number | null;
  readonly eosTokenId: number | null;
  /** Absolute path to tokenizer.json (the model snapshot dir's copy). Set by
   *  loadTokenizer; read by src/grammar.ts to build the xgrammar TokenizerInfo
   *  (vocab extraction + vocab-type detection for constrained decoding). */
  readonly tokenizerJsonPath?: string;
  /** config.json vocab_size, may exceed the tokenizer vocab length when the
   *  embedding is padded to a power-of-two / 256. Read by src/grammar.ts to
   *  size the logit bitmask against the model's logit width, not the
   *  tokenizer's. Set by the server when it loads config; not set by the
   *  bare loadTokenizer() helper (callers that need it pass modelDir + config). */
  vocabSize?: number;
  /** mlx-lm streaming-detokenizer parity: true for ByteLevel-decoder (BPE)
   *  tokenizers, where mlx-lm's BPEStreamingDetokenizer drops ONE leading " "
   *  at the very start of a generated sequence (tokenizer_utils.py
   *  `_maybe_trim_space`: `elif not self.text: return current_text[1:]`).
   *  Our decode() delegates to @huggingface/tokenizers, whose ByteLevel
   *  decoder KEEPS that space — the serving StreamDecoder consults this flag
   *  to match mlx-lm's rendered bytes (e.g. MiniCPM5 /v1/completions:
   *  "2, 3, 5…" not " 2, 3, 5…"). SPM tokenizers need nothing: with a Strip
   *  decoder the strip already happens inside decode(); without one
   *  (gemma-4) mlx-lm uses trim_space=False and keeps the space too. */
  readonly trimsLeadingSpace?: boolean;
  /** mlx-lm streaming-detokenizer parity (companion to trimsLeadingSpace):
   *  for ByteLevel-decoder (BPE) tokenizers, the vocab id of the bare-space
   *  token "Ġ" — the ONLY token matching mlx-lm 0.31.3
   *  BPEStreamingDetokenizer.add_token's hold condition
   *  `len(v) == 1 and self._byte_decoder.get(v[0]) == 32`
   *  (tokenizer_utils.py:206-218, "For single spaces wait until the next
   *  token"). mlx_lm.server NEVER calls detokenizer.finalize() (grep: zero
   *  hits in server.py 0.31.3), so a generation ENDING on this token silently
   *  drops its space from the served bytes. The serving StreamDecoder
   *  consults this id to mirror both behaviors (MiniCPM5: id 242). */
  readonly bareSpaceTokenId?: number;
  /** Encode-path counters (memo hits / incremental splices / fallbacks /
   *  full encodes) — observability + test hook, no behavioral role. */
  readonly encodeStats?: EncodeStats;
}

// Exact-input encode memo. Our pure-JS encode costs ~90 ms per 9.6k tokens
// (vs Rust tokenizers ~15 ms) and the serving hot paths re-encode BYTE-
// IDENTICAL text constantly: warm/ctx repeats re-render the same
// conversation, and regenerate flows resend it. A string-keyed LRU makes
// those free and is exact by construction (no BPE boundary reasoning).
// Bounded: keys are capped by count and total chars, so at most a few MB.
// The append-only multi-turn path (turn N+1's rendered prompt = turn N's
// plus a suffix) goes through IncrementalEncoder below; the native port is
// the endgame.
const ENCODE_MEMO_MAX_ENTRIES = 16;
const ENCODE_MEMO_MAX_CHARS = 1 << 21; // ~2M chars ≈ 4 MB of keys
class EncodeMemo {
  #map = new Map<string, number[]>(); // Map preserves insertion order → LRU
  #chars = 0;
  get(key: string): number[] | undefined {
    const hit = this.#map.get(key);
    if (!hit) return undefined;
    this.#map.delete(key); // bump recency
    this.#map.set(key, hit);
    return hit;
  }
  set(key: string, ids: number[]): void {
    if (this.#map.has(key)) { this.#chars -= key.length; this.#map.delete(key); }
    this.#map.set(key, ids);
    this.#chars += key.length;
    while (this.#map.size > ENCODE_MEMO_MAX_ENTRIES || this.#chars > ENCODE_MEMO_MAX_CHARS) {
      const oldest = this.#map.keys().next().value as string | undefined;
      if (oldest === undefined) break;
      this.#chars -= oldest.length;
      this.#map.delete(oldest);
    }
  }
  /** Longest-common-string-prefix scan over memo entries with the same
   *  addSpecialTokens flag char ("S"/"s", the key's first char). ≤16 entries
   *  × O(commonLen) char compares — sub-ms at memo scale. `>=` keeps the most
   *  RECENT entry on common-length ties (Map iterates insertion order; recent
   *  entries are re-inserted last by get()). */
  findBestPrefix(
    flagChar: string,
    text: string,
  ): { text: string; ids: number[]; common: number } | null {
    let best: { text: string; ids: number[]; common: number } | null = null;
    for (const [key, ids] of this.#map) {
      if (key[0] !== flagChar) continue;
      const ptext = key.slice(2);
      const n = Math.min(ptext.length, text.length);
      let i = 0;
      while (i < n && ptext.charCodeAt(i) === text.charCodeAt(i)) i++;
      if (best === null || i >= best.common) best = { text: ptext, ids, common: i };
    }
    return best && best.common > 0 ? best : null;
  }
}

// ---------------------------------------------------------------------------
// Incremental encode for append-only conversations.
//
// The installed @huggingface/tokenizers (0.1.3) Encoding exposes NO per-token
// offsets (types/static/types.d.ts: `Encoding = { ids, tokens,
// attention_mask }`), so char positions of token boundaries are recovered by
// decoding token TAILS and checking them against the known source text:
// decode(ids[T..N]) must be a literal suffix of the cached text (both target
// decoders round-trip: cpm5's ByteLevel is pure byte-concat, e4b's
// Sequence[Replace ▁→" ", ByteFallback, Fuse] inverts its normalizer; a tail
// cut mid-UTF-8-char yields U+FFFD and simply fails endsWith → step back).
// clean_up_tokenization_spaces must be forced FALSE here — the lib defaults
// it to config??true (dist decode()), which mangles offsets.
//
// Exactness contract: the fast path returns cached[0..T] + encode(tail) only
// after a seam VERIFICATION — re-encode from an anchor K tokens before the
// cut and require the first K+min(K,|tail|) tokens to reproduce
// cached[T-K..T] + tail[0..K] exactly. Any mismatch (BPE merges crossing the
// cut, decoder round-trip failure, mid-char cut) falls back to a full
// encode, so every returned result is either a verified splice or a
// from-scratch encode. SLACK backs the cut off the divergence point for
// merge locality; K≈32 tokens (~130 chars) exceeds any pre-token span the
// target tokenizers produce.
const INC_MIN_TEXT = 4096; // same gate as the memo: short prompts encode <1 ms
const INC_MIN_COMMON = 1024; // shared-prefix chars below this: splice not worth it
const INC_SLACK = 64; // chars backed off from the divergence point
const INC_VERIFY_TOKENS = 32; // K: seam window re-encoded and compared
const INC_CUT_ATTEMPTS = 8;

export interface EncodeStats {
  memoHits: number;
  incremental: number;
  incrementalFallbacks: number; // splice attempted, verification/cut refused
  full: number;
}

/** The subset of @huggingface/tokenizers' Tokenizer we need (encode/decode). */
type RawTokenizer = Pick<Tokenizer, "encode" | "decode">;

export class IncrementalEncoder {
  readonly stats: EncodeStats = { memoHits: 0, incremental: 0, incrementalFallbacks: 0, full: 0 };
  #tok: RawTokenizer;
  #memo = new EncodeMemo();
  /** Whether the post_processor only PREPENDS specials (BOS). An APPENDED
   *  special (EOS suffix template) would sit past the spliced tail where the
   *  seam verification cannot see it, so such tokenizers get no incremental
   *  path for addSpecialTokens=true. Both targets are prefix-only: cpm5
   *  TemplateProcessing single=[<s>, A], e4b single=[A]. */
  #prefixOnlySpecials: boolean;

  constructor(tok: RawTokenizer, prefixOnlySpecials: boolean) {
    this.#tok = tok;
    this.#prefixOnlySpecials = prefixOnlySpecials;
  }

  /** Test hook: inject a memo entry as if `ids` were the encode of `text`. */
  seed(text: string, ids: number[], addSpecialTokens: boolean): void {
    this.#memo.set(`${addSpecialTokens ? "S" : "s"}|${text}`, ids.slice());
  }

  #rawEncode(text: string, special: boolean): number[] {
    return this.#tok.encode(text, { add_special_tokens: special }).ids.map(Number);
  }

  /** Raw tail decode for offset math: specials render as their literal vocab
   *  string (chat-template text contains them literally), cleanup forced off. */
  #decodeTail(ids: number[]): string {
    return this.#tok.decode(ids, {
      skip_special_tokens: false,
      clean_up_tokenization_spaces: false,
    });
  }

  encode(text: string, special: boolean): number[] {
    if (text.length < INC_MIN_TEXT) return this.#rawEncode(text, special);
    const key = `${special ? "S" : "s"}|${text}`;
    const hit = this.#memo.get(key);
    if (hit) {
      this.stats.memoHits++;
      return hit.slice();
    }
    if (!special || this.#prefixOnlySpecials) {
      const best = this.#memo.findBestPrefix(special ? "S" : "s", text);
      if (best && best.common >= INC_MIN_COMMON) {
        const inc = this.#tryIncremental(best.text, best.ids, best.common, text);
        if (inc) {
          this.stats.incremental++;
          this.#memo.set(key, inc);
          return inc.slice();
        }
        this.stats.incrementalFallbacks++;
      }
    }
    const ids = this.#rawEncode(text, special);
    this.stats.full++;
    this.#memo.set(key, ids);
    return ids.slice();
  }

  /** Splice cached prefix tokens with a fresh tail encode, or null to force
   *  the full-encode fallback. `common` = shared-prefix chars between ptext
   *  (the memoized source text of pids) and text. Cost is O(tail + seam), not
   *  O(text): two tail decodes + two suffix encodes. */
  #tryIncremental(
    ptext: string,
    pids: number[],
    common: number,
    text: string,
  ): number[] | null {
    const target = common - INC_SLACK; // keep cached tokens ending at/before here
    const N = pids.length;
    const K = INC_VERIFY_TOKENS;
    if (target <= 0 || N <= K + 2) return null;
    // Estimate the cut token index from mean chars/token, then correct by
    // decoding the actual tail. charStart(T) = ptext.length - |decode(T..N)|,
    // valid only when the decoded tail is a literal suffix of ptext.
    const avg = Math.max(ptext.length / N, 0.25);
    let T = Math.min(
      N - 1,
      Math.max(K + 1, N - Math.ceil((ptext.length - target) / avg) - 4),
    );
    let cutChar = -1;
    for (let attempt = 0; attempt < INC_CUT_ATTEMPTS; attempt++) {
      if (T <= K) return null;
      const d = this.#decodeTail(pids.slice(T));
      if (!ptext.endsWith(d)) {
        T = Math.max(K, T - 8); // mid-char cut (byte-fallback/ByteLevel) → back off
        continue;
      }
      const start = ptext.length - d.length;
      if (start > target) {
        T = Math.max(K, T - Math.ceil((start - target) / avg) - 2);
        continue;
      }
      cutChar = start;
      break;
    }
    if (cutChar < 0) return null;
    // Anchor K tokens before the cut; its char position via the same tail trick.
    const anchorTail = this.#decodeTail(pids.slice(T - K));
    if (!ptext.endsWith(anchorTail)) return null;
    const anchorChar = ptext.length - anchorTail.length;
    if (anchorChar >= cutChar) return null; // zero-width seam window: refuse
    const tailIds = this.#rawEncode(text.slice(cutChar), false);
    // Seam verification: a fresh encode from the anchor must reproduce the
    // cached tokens across the cut AND the spliced tail's start. When the
    // tail is shorter than K the verify encode covers the ENTIRE remainder,
    // so require full equality (no trailing extras).
    const verifyIds = this.#rawEncode(text.slice(anchorChar), false);
    const expectedLen = K + Math.min(K, tailIds.length);
    if (tailIds.length <= K ? verifyIds.length !== expectedLen : verifyIds.length < expectedLen)
      return null;
    for (let i = 0; i < K; i++) if (verifyIds[i] !== pids[T - K + i]) return null;
    for (let i = K; i < expectedLen; i++) if (verifyIds[i] !== tailIds[i - K]) return null;
    return pids.slice(0, T).concat(tailIds);
  }
}

/** True when the tokenizer.json post_processor adds specials only BEFORE the
 *  sequence (or adds none): null, ByteLevel (offset-only, adds no ids), or a
 *  TemplateProcessing whose `single` template ends with the Sequence slot.
 *  Unknown processor types conservatively return false. */
export function specialsArePrefixOnly(tokenizerJson: unknown): boolean {
  const pp = (tokenizerJson as { post_processor?: { type?: string; single?: unknown[] } })
    .post_processor;
  if (pp == null) return true;
  if (pp.type === "ByteLevel") return true;
  if (pp.type === "TemplateProcessing" && Array.isArray(pp.single)) {
    const single = pp.single as Record<string, unknown>[];
    const seqIdx = single.findIndex((item) => "Sequence" in item);
    return seqIdx >= 0 && seqIdx === single.length - 1;
  }
  return false;
}

export async function loadTokenizer(modelDir: string): Promise<LoadedTokenizer> {
  const [tokenizerJson, tokenizerConfig] = await Promise.all([
    Bun.file(`${modelDir}/tokenizer.json`).json(),
    Bun.file(`${modelDir}/tokenizer_config.json`).json(),
  ]);
  const tok = new Tokenizer(tokenizerJson, tokenizerConfig);
  const enc = new IncrementalEncoder(tok, specialsArePrefixOnly(tokenizerJson));

  const idOf = (key: string): number | null => {
    const t = tokenizerConfig[key];
    if (t == null) return null;
    const text = typeof t === "string" ? t : t.content;
    const enc = tok.encode(text, { add_special_tokens: false });
    return enc.ids.length === 1 ? Number(enc.ids[0]) : null;
  };

  // mirror mlx-lm's `_is_bpe_decoder` (tokenizer_utils.py): top-level
  // decoder type "ByteLevel" selects the BPE streaming detokenizer.
  const isByteLevel =
    (tokenizerJson as { decoder?: { type?: string } }).decoder?.type === "ByteLevel";
  // The bare-space token: in the GPT-2 ByteLevel byte-to-unicode map, byte 32
  // (space) renders as "Ġ" (U+0120) — the only single-char vocab entry whose
  // byte decodes to 32, i.e. the only token mlx-lm's BPEStreamingDetokenizer
  // withholds in _unflushed. Look it up straight in the BPE vocab.
  const bareSpaceTokenId = isByteLevel
    ? (tokenizerJson as { model?: { vocab?: Record<string, number> } }).model
        ?.vocab?.["Ġ"]
    : undefined;

  return {
    // Memo + incremental-splice path live in IncrementalEncoder; short
    // prompts (<4096 chars, <1 ms) bypass both inside it.
    encode: (text, addSpecialTokens = true) => enc.encode(text, addSpecialTokens),
    decode: (ids, skipSpecialTokens = false) =>
      // python's decode([]) === ""; the JS lib throws on empty input
      ids.length === 0 ? "" : tok.decode(ids, { skip_special_tokens: skipSpecialTokens }),
    idToToken: (id) =>
      (tok as unknown as { id_to_token(id: number): string | undefined })
        .id_to_token(id) ?? tok.decode([id], { skip_special_tokens: false }),
    bosTokenId: idOf("bos_token"),
    eosTokenId: idOf("eos_token"),
    tokenizerJsonPath: `${modelDir}/tokenizer.json`,
    // ByteLevel/BPE = the only detokenizer class with the sequence-start
    // space-trim and the bare-space hold-back our decode() lacks (see the
    // interface docs above).
    trimsLeadingSpace: isByteLevel,
    bareSpaceTokenId: typeof bareSpaceTokenId === "number" ? bareSpaceTokenId : undefined,
    encodeStats: enc.stats,
  };
}
