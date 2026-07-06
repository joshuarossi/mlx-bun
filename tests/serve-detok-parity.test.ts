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
// 2. Gemma-4 reasoning channel (e4b): mlx-lm's think-start marker is exactly
//    `<|channel>thought` (`_infer_thinking`), and only MARKER tokens get
//    their text blanked (mlx_lm/server.py `_process_control_tokens`) — the
//    "\n" generated after the name is the FIRST byte of the reasoning
//    stream. ToolAwareStream#feedChannel must strip only the name word and
//    keep the "\n".

import { describe, expect, test } from "bun:test";
import {
  SNAPSHOT_E4B, SNAPSHOT_MINICPM5,
  snapshotE4bAvailable, snapshotMiniCPM5Available,
} from "./paths";
import { CHANNEL_END, CHANNEL_START } from "../src/tool-call";
import { loadTokenizer } from "../src/tokenizer";
import { StreamDecoder, ToolAwareStream } from "../src/server";

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

describe.skipIf(!haveE4b)("gemma-4 e4b (SPM, no Strip): no trim + reasoning keeps leading \\n", async () => {
  const tok = await loadTokenizer(SNAPSHOT_E4B);

  test("SPM-without-Strip decoder does NOT set trimsLeadingSpace (mlx-lm trim_space=False)", () => {
    expect(tok.trimsLeadingSpace).toBe(false);
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
