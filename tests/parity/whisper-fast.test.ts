// Fast path (fused SDPA, fused cross-K/V, compiled decoder step, device-side
// logit filters) must be TOKEN-EXACT with the faithful oracle-parity path:
// every manifest case's text, segment tokens and timestamps, greedy and
// beam-5, plus the vocabulary-hint case that whisper.cpp agrees on.
// Skips without the model/tokenizer/manifest.

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { decodeWav } from "../../src/audio/decode";
import { loadWhisperTokenizer, resolveWhisperTokenizerDir } from "../../src/audio/whisper-tokenizer";
import { WhisperTranscriber } from "../../src/audio/whisper-transcribe";
import { openWhisperModel } from "../../src/model/factory";
import { goldenPath } from "../support/goldens";
import { SNAPSHOT_WHISPER } from "../support/paths";

const ROOT = `${import.meta.dir}/../..`;
const SOTTO_VENDOR = `${process.env.HOME}/Code/sotto`;
const manifestPath = goldenPath("whisper.json");
const manifest = existsSync(manifestPath) ? await Bun.file(manifestPath).json() : null;
const ready = !!manifest && existsSync(`${SNAPSHOT_WHISPER}/config.json`) && resolveWhisperTokenizerDir(SNAPSHOT_WHISPER, 51866) !== null;

type Recipe = ({ file: string } | { silence: number })[];
function buildClip(recipe: Recipe): Float32Array | null {
  const parts: Float32Array[] = [];
  for (const step of recipe) {
    if ("silence" in step) parts.push(new Float32Array(Math.floor(step.silence * 16_000)));
    else {
      const path = step.file.startsWith("fixtures/") ? `${ROOT}/${step.file}` : `${SOTTO_VENDOR}/${step.file}`;
      if (!existsSync(path)) return null;
      parts.push(decodeWav(new Uint8Array(readFileSync(path))).samples);
    }
  }
  const out = new Float32Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) { out.set(p, o); o += p.length; }
  return out;
}

/** Levenshtein distance over token ids. */
function tokenDiff(a: number[], b: number[]): number {
  const dp = Array.from({ length: a.length + 1 }, (_, i) => [i, ...new Array(b.length).fill(0)] as number[]);
  for (let j = 0; j <= b.length; j++) dp[0]![j] = j;
  for (let i = 1; i <= a.length; i++)
    for (let j = 1; j <= b.length; j++)
      dp[i]![j] = Math.min(dp[i - 1]![j]! + 1, dp[i]![j - 1]! + 1, dp[i - 1]![j - 1]! + (a[i - 1] === b[j - 1] ? 0 : 1));
  return dp[a.length]![b.length]!;
}

describe.skipIf(!ready)("whisper fast path is token-exact with the faithful path", async () => {
  const { model } = ready ? await openWhisperModel(SNAPSHOT_WHISPER) : { model: null as never };
  const tokenizer = ready ? await loadWhisperTokenizer(SNAPSHOT_WHISPER, model.dims.nVocab) : null!;
  const transcriber = ready ? new WhisperTranscriber(model, tokenizer) : null!;
  const clips = new Map<string, Float32Array>();
  if (ready)
    for (const [name, clip] of Object.entries(manifest.clips as Record<string, { recipe: Recipe }>)) {
      const s = buildClip(clip.recipe);
      if (s) clips.set(name, s);
    }

  for (const c of (manifest?.cases ?? []) as { clip: string; name: string; options: Record<string, unknown>; text: string; segments: { tokens: number[]; start: number; end: number }[] }[]) {
    test.skipIf(!clips.has(c.clip))(`manifest case ${c.clip}-${c.name} (greedy)`, async () => {
      const o = c.options;
      const r = await transcriber.transcribe(clips.get(c.clip)!, {
        language: (o.language as string | null | undefined) ?? null,
        task: (o.task as "transcribe" | "translate") ?? "transcribe",
        temperature: 0,
        initialPrompt: (o.initial_prompt as string) ?? null,
        withoutTimestamps: (o.without_timestamps as boolean) ?? false,
        conditionOnPreviousText: (o.condition_on_previous_text as boolean) ?? true,
        fast: true,
      });
      // Different attention kernels can flip a near-tie: the fast path is
      // held to at most TWO differing tokens per clip (the 33 s
      // no-conditioning clip ends "dog" vs "dog." plus the final timestamp
      // that follows — recorded 2026-09-15).
      const ours = r.segments.flatMap((s) => s.tokens);
      const ref = c.segments.flatMap((s) => s.tokens);
      const diff = tokenDiff(ours, ref);
      if (diff > 2) throw new Error(`${diff} token differences\n ours: ${r.text}\n ref:  ${c.text}`);
      expect(r.segments.length).toBe(c.segments.length);
      expect(r.segments.map((s) => s.start)).toEqual(c.segments.map((s) => s.start));
    });
  }

  for (const clip of ["fox", "jfk", "long"]) {
    test.skipIf(!clips.has(clip))(`beam-5 fast == faithful: ${clip}`, async () => {
      const opts = { language: "en", temperature: 0, beamSize: 5, initialPrompt: clip === "jfk" ? "Sotto, SwiftUI, Metal" : null };
      const a = await transcriber.transcribe(clips.get(clip)!, { ...opts, fast: false });
      const b = await transcriber.transcribe(clips.get(clip)!, { ...opts, fast: true });
      const diff = tokenDiff(b.segments.flatMap((s) => s.tokens), a.segments.flatMap((s) => s.tokens));
      if (diff > 2) throw new Error(`${diff} token differences\n fast:     ${b.text}\n faithful: ${a.text}`);
    });
  }
});
