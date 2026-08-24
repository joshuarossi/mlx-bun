// Incremental tokenizer encode (append-only conversations): the spliced
// fast path must be BIT-IDENTICAL to a from-scratch encode — exactness is
// the product (CLAUDE.md fidelity contract). Tokenizer-only: loads real
// tokenizer.json from the HF snapshots, never touches weights or the GPU.

import { describe, expect, test } from "bun:test";
import { Tokenizer } from "@huggingface/tokenizers";
import {
  IncrementalEncoder,
  loadTokenizer,
  specialsArePrefixOnly,
} from "../../src/tokenizer";
import {
  SNAPSHOT_E4B,
  SNAPSHOT_MINICPM5,
  snapshotE4bAvailable,
  snapshotMiniCPM5Available,
} from "../support/paths";

const haveCpm = await snapshotMiniCPM5Available();
const haveE4b = await snapshotE4bAvailable();

// ~40k chars ≈ 9-10k tokens: a multi-turn conversation with the chat
// markers as literal text (that's what chat templates emit — specials are
// text at this layer). Deterministic, no RNG.
function buildBase(userMark: string, endMark: string, modelMark: string): string {
  const para =
    "The quick brown fox jumps over the lazy dog, while seventeen quarks " +
    "entangle across 42 nanometers of doped silicon. Ces phrases mélangent " +
    "des accents, ümlauts, and even 中文字符 to exercise the byte fallback. " +
    "Numbers like 1234567 and 3.14159 split differently than words do.\n";
  let text = "";
  for (let turn = 0; turn < 18; turn++) {
    text += `${userMark}Question ${turn}: please summarize the following.\n`;
    for (let i = 0; i < 8; i++) text += para;
    text += `${endMark}${modelMark}Answer ${turn}: the passage discusses foxes and quarks.\n${endMark}`;
  }
  return text;
}

// 20 append-only growth steps hitting the nasty boundaries: emoji (incl. ZWJ
// families split across tokens), "\n\n", MID-WORD growth, literal special
// tokens in content, digit runs, CJK, quotes, \r\n, long repeated-char runs.
function growthSteps(userMark: string, endMark: string, modelMark: string): string[] {
  return [
    `${userMark}Next question about tokens.\n${endMark}`,
    "\n\n",
    "ing", // mid-word growth: glues onto the previous token
    "🚀🔥 emoji at the seam ",
    "👩‍👩‍👧‍👦 zwj family ",
    `${modelMark}An answer begins here`,
    "...", // punctuation run continuing the previous word
    "1234567890123456789", // long digit run
    "42", // extends the digit run — regrouping hazard
    " 中文续写测试字符串 ",
    "naïve façade coöperation ", // combining/accented forms
    "\r\nwindows line endings\r\n",
    `"quoted text" and 'apostrophes' `,
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", // repeated-char BPE run
    "aaaa", // extends the run — merge-restructuring hazard
    `${endMark}${userMark}Another turn\n`,
    "word", // bare word, no leading space
    " trailing spaces   ",
    "final tail with mixed 内容 and 🎉",
    `${endMark}${modelMark}`,
  ];
}

interface Target {
  name: string;
  dir: string;
  have: boolean;
  userMark: string;
  endMark: string;
  modelMark: string;
}

const targets: Target[] = [
  {
    name: "cpm5",
    dir: SNAPSHOT_MINICPM5,
    have: haveCpm,
    userMark: "<|im_start|>user\n",
    endMark: "<|im_end|>\n",
    modelMark: "<|im_start|>assistant\n",
  },
  {
    name: "e4b",
    dir: SNAPSHOT_E4B,
    have: haveE4b,
    userMark: "<start_of_turn>user\n",
    endMark: "<end_of_turn>\n",
    modelMark: "<start_of_turn>model\n",
  },
];

for (const t of targets) {
  describe.skipIf(!t.have)(`incremental encode: ${t.name}`, async () => {
    if (!t.have) return;
    const [tokenizerJson, tokenizerConfig] = await Promise.all([
      Bun.file(`${t.dir}/tokenizer.json`).json(),
      Bun.file(`${t.dir}/tokenizer_config.json`).json(),
    ]);
    // Oracle for this suite: a bare Tokenizer with no memo — every call is a
    // from-scratch encode of the full text.
    const raw = new Tokenizer(tokenizerJson, tokenizerConfig);
    const fromScratch = (text: string): number[] =>
      raw.encode(text, { add_special_tokens: true }).ids.map(Number);

    const base = buildBase(t.userMark, t.endMark, t.modelMark);
    const steps = growthSteps(t.userMark, t.endMark, t.modelMark);

    test("append-only growth matches from-scratch exactly across 20 variants", async () => {
      const tok = await loadTokenizer(t.dir);
      const stats = tok.encodeStats!;
      expect(tok.encode(base)).toEqual(fromScratch(base));
      expect(stats.full).toBe(1); // cold: nothing to splice from

      let text = base;
      for (const [i, step] of steps.entries()) {
        text += step;
        const got = tok.encode(text);
        expect(got, `variant ${i} (${JSON.stringify(step.slice(0, 20))})`).toEqual(
          fromScratch(text),
        );
      }
      // Every encode ends in exactly one of memoHit / incremental / full (a
      // refused splice ALSO counts a full — incrementalFallbacks overlaps
      // full). The splice must WIN on the clear majority — exactness alone
      // is vacuous if nothing splices.
      expect(stats.memoHits).toBe(0);
      expect(stats.incremental + stats.full).toBe(1 + steps.length);
      expect(stats.incremental).toBeGreaterThanOrEqual(15);
    });

    test("byte-identical repeat still hits the exact memo", async () => {
      const tok = await loadTokenizer(t.dir);
      const a = tok.encode(base);
      const b = tok.encode(base);
      expect(b).toEqual(a);
      expect(tok.encodeStats!.memoHits).toBe(1);
    });

    test("seam verification rejects a corrupted cached prefix", () => {
      const enc = new IncrementalEncoder(raw, specialsArePrefixOnly(tokenizerJson));
      const ids = fromScratch(base);
      // Corrupt a token inside the seam window (cut ≈ 64 chars ≈ ~16 tokens
      // from the end; anchor 32 tokens further back): the verify re-encode
      // must catch the lie and fall back to a full encode → exact result.
      const corrupted = ids.slice();
      corrupted[ids.length - 30] = corrupted[ids.length - 30]! + 1;
      enc.seed(base, corrupted, true);
      const grown = `${base}${t.userMark}One more question\n${t.endMark}`;
      expect(enc.encode(grown, true)).toEqual(fromScratch(grown));
      expect(enc.stats.incremental).toBe(0);
      expect(enc.stats.incrementalFallbacks).toBe(1);
    });

    test("speedup on 9.6k-token base + 200-char append", async () => {
      const tok = await loadTokenizer(t.dir);
      tok.encode(base); // warm the memo with the base conversation
      const append =
        `${t.userMark}Given all of the above, what single conclusion holds? ` +
        `Answer briefly, cite the fox, the quark, and 中文 once each, then ` +
        `explain in one sentence why the seventeen entangled quarks matter ` +
        `for the doped silicon measurement. 🚀${t.endMark}`;
      const grown = base + append;
      expect(append.length).toBeGreaterThan(180);

      let fullMs = Infinity;
      let incMs = Infinity;
      for (let rep = 0; rep < 3; rep++) {
        let t0 = performance.now();
        const want = fromScratch(grown);
        fullMs = Math.min(fullMs, performance.now() - t0);
        t0 = performance.now();
        const got = tok.encode(grown);
        incMs = Math.min(incMs, performance.now() - t0);
        expect(got).toEqual(want);
      }
      // Reps after the first hit the exact memo; the printed incremental
      // number is the FIRST rep's splice. Re-measure splice-only by seeding
      // a fresh encoder each rep.
      const enc = new IncrementalEncoder(raw, specialsArePrefixOnly(tokenizerJson));
      const baseIds = fromScratch(base);
      let spliceMs = Infinity;
      for (let rep = 0; rep < 3; rep++) {
        const fresh = new IncrementalEncoder(raw, specialsArePrefixOnly(tokenizerJson));
        fresh.seed(base, baseIds, true);
        const t0 = performance.now();
        fresh.encode(grown, true);
        spliceMs = Math.min(spliceMs, performance.now() - t0);
        expect(fresh.stats.incremental).toBe(1);
      }
      void enc;
      console.log(
        `[${t.name}] base=${baseIds.length} tokens, append=${append.length} chars: ` +
          `full=${fullMs.toFixed(2)}ms splice=${spliceMs.toFixed(2)}ms ` +
          `(${(fullMs / spliceMs).toFixed(1)}x)`,
      );
      expect(spliceMs).toBeLessThan(fullMs);
    });
  });
}

describe("specialsArePrefixOnly", () => {
  test("null / ByteLevel / prefix-only templates pass", () => {
    expect(specialsArePrefixOnly({})).toBe(true);
    expect(specialsArePrefixOnly({ post_processor: { type: "ByteLevel" } })).toBe(true);
    expect(
      specialsArePrefixOnly({
        post_processor: {
          type: "TemplateProcessing",
          single: [{ SpecialToken: { id: "<s>" } }, { Sequence: { id: "A" } }],
        },
      }),
    ).toBe(true);
  });
  test("appended-EOS template and unknown processors refuse", () => {
    expect(
      specialsArePrefixOnly({
        post_processor: {
          type: "TemplateProcessing",
          single: [
            { SpecialToken: { id: "<s>" } },
            { Sequence: { id: "A" } },
            { SpecialToken: { id: "</s>" } },
          ],
        },
      }),
    ).toBe(false);
    expect(specialsArePrefixOnly({ post_processor: { type: "RobertaProcessing" } })).toBe(false);
  });
});
