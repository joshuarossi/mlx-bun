// Transcription output formats shared by the CLI and /v1/audio/transcriptions:
// OpenAI `json` / `verbose_json` / `text` / `srt` / `vtt`.

import type { WhisperSegment } from "./types";
import type { WhisperTranscription } from "./transcribe";

export type TranscriptionFormat = "json" | "verbose_json" | "text" | "srt" | "vtt";

export const TRANSCRIPTION_FORMATS: readonly TranscriptionFormat[] =
  ["json", "verbose_json", "text", "srt", "vtt"];

function pad2(n: number): string {
  return n < 10 ? `0${n}` : String(n);
}

/** HH:MM:SS,mmm (srt) or HH:MM:SS.mmm (vtt). */
export function formatTimestamp(seconds: number, separator: "," | "." = ","): string {
  let ms = Math.round(seconds * 1000);
  const hours = Math.floor(ms / 3_600_000);
  ms -= hours * 3_600_000;
  const minutes = Math.floor(ms / 60_000);
  ms -= minutes * 60_000;
  const secs = Math.floor(ms / 1000);
  ms -= secs * 1000;
  return `${pad2(hours)}:${pad2(minutes)}:${pad2(secs)}${separator}${String(ms).padStart(3, "0")}`;
}

export function toSrt(segments: WhisperSegment[]): string {
  let out = "";
  let n = 1;
  for (const s of segments) {
    if (!s.text.trim()) continue;
    out += `${n++}\n${formatTimestamp(s.start, ",")} --> ${formatTimestamp(s.end, ",")}\n${s.text.trim()}\n\n`;
  }
  return out;
}

export function toVtt(segments: WhisperSegment[]): string {
  let out = "WEBVTT\n\n";
  for (const s of segments) {
    if (!s.text.trim()) continue;
    out += `${formatTimestamp(s.start, ".")} --> ${formatTimestamp(s.end, ".")}\n${s.text.trim()}\n\n`;
  }
  return out;
}

/** OpenAI verbose_json body (segments carry the openai-whisper fields). */
export function toVerboseJson(r: WhisperTranscription, durationSeconds: number, task: string): Record<string, unknown> {
  return {
    task,
    language: r.language,
    duration: durationSeconds,
    text: r.text.trim(),
    segments: r.segments.map((s) => ({
      id: s.id, seek: s.seek, start: s.start, end: s.end, text: s.text, tokens: s.tokens,
      temperature: s.temperature, avg_logprob: s.avgLogprob, compression_ratio: s.compressionRatio,
      no_speech_prob: s.noSpeechProb,
      ...(s.words ? { words: s.words } : {}),
    })),
    ...(r.segments.some((s) => s.words) ? { words: r.segments.flatMap((s) => s.words ?? []) } : {}),
  };
}

export function formatTranscription(
  r: WhisperTranscription, format: TranscriptionFormat, durationSeconds: number, task: string,
): string {
  switch (format) {
    case "text": return r.text.trim() + "\n";
    case "json": return JSON.stringify({ text: r.text.trim() }) + "\n";
    case "verbose_json": return JSON.stringify(toVerboseJson(r, durationSeconds, task)) + "\n";
    case "srt": return toSrt(r.segments);
    case "vtt": return toVtt(r.segments);
  }
}
