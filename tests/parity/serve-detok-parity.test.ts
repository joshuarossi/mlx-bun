// Serving detokenizer byte-parity with mlx-lm (fast tier, tokenizer-only —
// no weights, no GPU). The drop-in contract is rendered BYTES: given the
// SAME greedy token stream, our /v1 text must match mlx_lm.server
// byte-for-byte. Two rules pinned here (2026-07-06b serve-bench parity
// probes caught both as char-0 divergences):
//
// 1. BPE/ByteLevel tokenizers (MiniCPM5): mlx-lm's BPEStreamingDetokenizer
//    drops ONE leading " " at the very start of the generated sequence
//    (mlx_lm/tokenizer_utils.py `_maybe_trim_space`: `elif not self.text:
//    return current_text[1:]`); our raw decode keeps it. StreamDecoder now
//    trims it via LoadedTokenizer.trimsLeadingSpace (set iff tokenizer.json
//    decoder.type === "ByteLevel", mirroring mlx-lm's `_is_bpe_decoder`).
//
// 2. BPE bare-space hold-back + never-finalize (MiniCPM5, 2026-07-07 bench):
//    mlx-lm's BPEStreamingDetokenizer.add_token WITHHOLDS a single-char
//    byte-32 token ("Ġ", id 242) in `_unflushed` ("For single spaces wait
//    until the next token", tokenizer_utils.py:206-218) and mlx_lm.server
//    0.31.3 NEVER calls finalize() — so a generation ENDING on bare-space
//    token(s) drops their spaces from the served bytes. StreamDecoder now
//    mirrors both: push(bareSpace) emits nothing, the next token's delta
//    carries the held spaces, flush() drops a trailing bare-space run.
//
// 3. Gemma-4 reasoning channel (e4b): mlx-lm's think-start marker is exactly
//    `<|channel>thought` (`_infer_thinking`), and only MARKER tokens get
//    their text blanked (mlx_lm/server.py `_process_control_tokens`) — the
//    "\n" generated after the name is the FIRST byte of the reasoning
//    stream. ToolAwareStream#feedChannel must strip only the name word and
//    keep the "\n".

import { describe, expect, test } from "bun:test";
import {
  SNAPSHOT_E4B, SNAPSHOT_MINICPM5,
  snapshotE4bAvailable, snapshotMiniCPM5Available,
} from "../support/paths";
import { CHANNEL_END, CHANNEL_START } from "../../src/tool-call";
import { loadTokenizer } from "../../src/tokenizer";
import { StreamDecoder, ToolAwareStream } from "../../src/server";

const haveCpm = await snapshotMiniCPM5Available();
const haveE4b = await snapshotE4bAvailable();

/** Stream ids through a StreamDecoder like the /v1/completions handler does. */
const streamAll = (dec: StreamDecoder, ids: number[]): string => {
  let out = "";
  for (const id of ids) out += dec.push(id);
  return out + dec.flush();
};

describe.skipIf(!haveCpm)("MiniCPM5 (ByteLevel/BPE): sequence-start space trim", async () => {
  const tok = await loadTokenizer(SNAPSHOT_MINICPM5);

  test("tokenizer.json ByteLevel decoder sets trimsLeadingSpace", () => {
    expect(tok.trimsLeadingSpace).toBe(true);
  });

  test("/v1/completions first-token leading space is stripped (bench 2026-07-06b)", () => {
    // The observed greedy continuation of "The first eight prime numbers are":
    // mlx-lm renders "2, 3, 5, 7, 11, 13, …", ours rendered " 2, 3, 5, …".
    const ids = tok.encode(" 2, 3, 5, 7, 11, 13,", false);
    expect(tok.decode(ids, true)).toBe(" 2, 3, 5, 7, 11, 13,"); // raw decode keeps it
    expect(streamAll(new StreamDecoder(tok), ids)).toBe("2, 3, 5, 7, 11, 13,");
  });

  test("only ONE space, only at sequence start — interior spaces untouched", () => {
    const ids = tok.encode("  twice leading, interior stays intact", false);
    // mlx-lm trims exactly one char (current_text[1:]).
    expect(streamAll(new StreamDecoder(tok), ids)).toBe(
      " twice leading, interior stays intact",
    );
    const noLead = tok.encode("no leading space here", false);
    expect(streamAll(new StreamDecoder(tok), noLead)).toBe("no leading space here");
  });

  test("chat path (ToolAwareStream plain mode) applies the same trim", () => {
    const ids = tok.encode(" Hello there, world.", false);
    const r = new ToolAwareStream(tok, "plain", null);
    let content = "";
    for (const id of ids) content += r.push(id);
    content += r.flush();
    expect(content).toBe("Hello there, world.");
  });
});

describe.skipIf(!haveCpm)("MiniCPM5 (ByteLevel/BPE): bare-space hold-back + never-finalize", async () => {
  const tok = await loadTokenizer(SNAPSHOT_MINICPM5);
  const bare = tok.bareSpaceTokenId!;

  test('vocab["Ġ"] resolves the bare-space id (mlx-lm hold condition, cpm5 id 242)', () => {
    expect(bare).toBe(242);
    expect(tok.decode([bare], true)).toBe(" ");
  });

  test("a max_tokens-final bare-space token is dropped (bench 2026-07-07 char 249)", () => {
    const ids = [...tok.encode("numbers greater than", false), bare];
    // raw decode keeps the space; mlx_lm.server (no finalize) drops it.
    expect(tok.decode(ids, true)).toBe("numbers greater than ");
    expect(streamAll(new StreamDecoder(tok), ids)).toBe("numbers greater than");
  });

  test("a trailing bare-space RUN is dropped entirely (consecutive holds accumulate)", () => {
    const ids = [...tok.encode("greater than", false), bare, bare];
    expect(streamAll(new StreamDecoder(tok), ids)).toBe("greater than");
  });

  test("mid-stream bare-space tokens flush with the NEXT token, byte-exactly", () => {
    // "7" alone (no leading space) so the interior space comes ONLY from Ġ.
    const seven = tok.encode("7", false);
    const ids = [...tok.encode("greater than", false), bare, ...seven];
    const dec = new StreamDecoder(tok);
    let out = "";
    const deltas: string[] = [];
    for (const id of ids) {
      const d = dec.push(id);
      deltas.push(d);
      out += d;
    }
    out += dec.flush();
    expect(out).toBe("greater than 7");
    // the bare-space push itself emits NOTHING (mlx-lm holds it in _unflushed)
    expect(deltas[deltas.length - 1 - seven.length]).toBe("");
    // the held space rides the next token's delta (mlx-lm flushes held+next)
    expect(deltas[deltas.length - seven.length]!.startsWith(" ")).toBe(true);
  });

  test("golden: the 2026-07-07 completion-probe greedy stream renders mlx-lm's served bytes", () => {
    // The SERVED-path greedy stream (our server, both lanes — verified
    // 2026-07-07 to render byte-identical text to a live mlx_lm.server
    // 0.31.3 on the same snapshot; prompt "The first eight prime numbers
    // are", max_tokens=64, temperature 0): ids[0] and ids[63] are both the
    // bare-space token — the leading one exercises rule 1 (sequence-start
    // trim), the trailing one rule 2 (never-finalize drop). NOTE: mlx-lm's
    // CLI route (stream_generate, full-prompt GEMM step 0) flips a step-50
    // near-tie to [18975, 376] "focuses on" — route-dependent bf16 noise
    // WITHIN mlx-lm itself; serve-vs-serve is the contract and matches.
    const ids = [
      242, 39, 33, 242, 40, 33, 242, 42, 33, 242, 44, 33, 242, 682, 33, 242,
      732, 33, 242, 777, 33, 316, 242, 456, 35, 2658, 4330, 457, 7829, 317,
      1471, 3261, 316, 558, 799, 7176, 374, 13387, 35, 416, 2244, 304, 9793,
      4330, 357, 280, 11618, 304, 16348, 380, 19746, 401, 285, 4706, 304,
      9793, 4330, 33, 617, 457, 4330, 4406, 848, 242,
    ];
    expect(ids[0]).toBe(bare);
    expect(ids[ids.length - 1]).toBe(bare);
    expect(streamAll(new StreamDecoder(tok), ids)).toBe(
      "2, 3, 5, 7, 11, 13, 17, and 19. These numbers are fundamental to " +
        "number theory and have been studied for centuries. The study of " +
        "prime numbers is a branch of mathematics that deals with the " +
        "properties of prime numbers, which are numbers greater than",
    );
  });
});

describe.skipIf(!haveE4b)("gemma-4 e4b (SPM, no Strip): no trim + reasoning keeps leading \\n", async () => {
  const tok = await loadTokenizer(SNAPSHOT_E4B);

  test("SPM-without-Strip decoder does NOT set trimsLeadingSpace (mlx-lm trim_space=False)", () => {
    expect(tok.trimsLeadingSpace).toBe(false);
    expect(tok.bareSpaceTokenId).toBeUndefined(); // hold-back is BPE-only
    const ids = tok.encode(" hello", false);
    expect(streamAll(new StreamDecoder(tok), ids)).toBe(" hello");
  });

  test("reasoning stream starts with the \\n after <|channel>thought (bench 2026-07-06b)", () => {
    // The model generates <|channel> thought \n Here's a thinking process …
    // mlx-lm blanks only the [<|channel>, thought] marker tokens; its
    // reasoning delta stream begins "\nHere's a thinking p…".
    const thought = tok.encode("thought", false);
    const body = tok.encode("\nHere's a thinking process", false);
    const answer = tok.encode("The answer is 42.", false);
    const r = new ToolAwareStream(tok, "gemma-sentinel", null);
    let content = "";
    let reasoning = "";
    for (const id of [CHANNEL_START, ...thought, ...body, CHANNEL_END, ...answer]) {
      content += r.push(id);
      reasoning += r.takeReasoning();
    }
    content += r.flush();
    reasoning += r.takeReasoning();
    expect(reasoning).toBe("\nHere's a thinking process");
    expect(content).toBe("The answer is 42.");
  });

  test("empty thought block yields exactly the \\n as reasoning (mlx-lm parity)", () => {
    // mlx-lm: markers blanked, the lone "\n" is a reasoning-state token.
    const empty = tok.encode("thought\n", false);
    const answer = tok.encode("Hi.", false);
    const r = new ToolAwareStream(tok, "gemma-sentinel", null);
    let content = "";
    let reasoning = "";
    for (const id of [CHANNEL_START, ...empty, CHANNEL_END, ...answer]) {
      content += r.push(id);
      reasoning += r.takeReasoning();
    }
    content += r.flush();
    reasoning += r.takeReasoning();
    expect(reasoning).toBe("\n");
    expect(content).toBe("Hi.");
  });
});

// ---------------------------------------------------------------------------
// Revised-text resync (2026-07-07 review): when a decoder REVISES earlier
// text (clean_up_tokenization_spaces-style rules — no shipped tokenizer does
// this), the old path re-emitted the whole stream from scratch, so an SSE
// client concatenating deltas duplicated everything already received. The
// truncate-safe resync emits only the length-extension.
// ---------------------------------------------------------------------------

describe("StreamDecoder — revised-text truncate-safe resync", () => {
  const { StreamDecoder } = require("../src/server");

  // Fake cleanup-rule tokenizer: once token 3 arrives, the earlier "hello ,"
  // collapses to "hello," (the _space_matches shape).
  const fakeTok = {
    trimsLeadingSpace: false,
    bareSpaceTokenId: undefined,
    decode(ids: number[]): string {
      const key = ids.join(",");
      if (key === "1") return "hello";
      if (key === "1,2") return "hello ,";
      if (key === "1,2,3") return "hello, world";
      throw new Error(`unexpected ids ${key}`);
    },
  };

  test("a revision emits only the length-extension — no whole-stream duplication", () => {
    const d = new StreamDecoder(fakeTok as never);
    let client = "";
    client += d.push(1); // "hello"
    client += d.push(2); // " ,"
    client += d.push(3); // revision fires: "hello, world" !startsWith "hello ,"
    // Pre-fix the third delta was ALL of "hello, world" → client saw
    // "hello ,hello, world". Post-fix: only the extension past the emitted
    // watermark ("world"); drift is confined to the revised span.
    expect(client).toBe("hello ,world");
    expect(client.match(/hello/g)!.length).toBe(1); // no duplication
  });

  test("a shrinking revision emits nothing and keeps the watermark monotone", () => {
    const tok = {
      trimsLeadingSpace: false,
      bareSpaceTokenId: undefined,
      decode(ids: number[]): string {
        return ids.length === 1 ? "abcdef" : "abcxy"; // revised AND shorter
      },
    };
    const d = new StreamDecoder(tok as never);
    let client = "";
    client += d.push(1); // "abcdef"
    client += d.push(2); // shrunk revision → nothing new to send
    expect(client).toBe("abcdef");
  });

  test("long additive streams decode a bounded suffix after exact anchoring", () => {
    let maxPushDecodeIds = 0;
    let inPush = true;
    const tok = {
      trimsLeadingSpace: false,
      bareSpaceTokenId: undefined,
      decode(ids: number[]): string {
        if (inPush) maxPushDecodeIds = Math.max(maxPushDecodeIds, ids.length);
        return ids.map((id) => String.fromCharCode(96 + id)).join("");
      },
    };
    const ids = Array.from({ length: 512 }, (_, i) => (i % 26) + 1);
    const d = new StreamDecoder(tok as never);
    const chunks = ids.map((id) => d.push(id));
    inPush = false;
    const text = chunks.join("") + d.flush();

    expect(text).toBe(ids.map((id) => String.fromCharCode(96 + id)).join(""));
    expect(chunks).toEqual(ids.map((id) => String.fromCharCode(96 + id)));
    expect(maxPushDecodeIds).toBeLessThanOrEqual(64);
  });
});
