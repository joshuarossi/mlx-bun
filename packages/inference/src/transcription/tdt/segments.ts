import type { SpeechWord } from "../types";
export interface TimedTdtToken {
  id: number;
  piece: string;
  start: number;
  duration: number;
}
/** Find a low-energy cut in the 25–35 second band, nearest the longest pause.
 * No audio is removed. Short utterances are decoded whole. */
export function tdtWindowEnd(samples: Float32Array): number {
  const sr = 16000;
  if (samples.length <= 35 * sr) return samples.length;
  const block = 800,
    end = 35 * sr,
    rms: number[] = [];
  for (let start = 0; start < end; start += block) {
    let sum = 0;
    for (let i = start; i < start + block; i++) sum += samples[i]! ** 2;
    rms.push(Math.sqrt(sum / block));
  }
  const gate = Math.max(0.004, Math.max(...rms) * 0.18);
  let bestLength = 0,
    cut = 30 * sr;
  for (let i = (25 * sr) / block; i < rms.length; ) {
    if (rms[i]! > gate) {
      i++;
      continue;
    }
    const start = i;
    while (i < rms.length && rms[i]! <= gate) i++;
    const candidate = Math.floor(((start + i) / 2) * block),
      length = i - start;
    if (
      length > bestLength ||
      (length === bestLength &&
        Math.abs(candidate - 30 * sr) < Math.abs(cut - 30 * sr))
    ) {
      bestLength = length;
      cut = candidate;
    }
  }
  return cut;
}
/** SentencePiece word starts and punctuation attachment, with durations in
 * seconds. Native TDT supplies timing, without an invented confidence score. */
export function tdtWords(
  tokens: readonly TimedTdtToken[],
  limit: number,
): SpeechWord[] {
  const words: SpeechWord[] = [];
  let current: TimedTdtToken[] = [];
  const flush = () => {
    if (!current.length) return;
    const first = current[0]!,
      last = current.at(-1)!,
      word = current
        .map((t) => t.piece.replaceAll("▁", " "))
        .join("")
        .trim();
    if (word)
      words.push({
        word,
        start: first.start,
        end: Math.max(first.start, Math.min(limit, last.start + last.duration)),
      });
    current = [];
  };
  for (const token of tokens) {
    const piece = token.piece.replaceAll("▁", " ");
    if (piece.startsWith(" ") && /[\p{L}\p{N}]/u.test(piece)) flush();
    current.push(token);
  }
  flush();
  return words;
}
