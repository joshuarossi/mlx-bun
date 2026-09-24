import { describe, expect, test } from "bun:test";
import { formatTimestamp, toSrt, toVtt } from "../../src/transcription/whisper/format";

describe("whisper output formats", () => {
  test("timestamps: srt commas, vtt dots, hours", () => {
    expect(formatTimestamp(0)).toBe("00:00:00,000");
    expect(formatTimestamp(61.234, ".")).toBe("00:01:01.234");
    expect(formatTimestamp(3600 + 5.0005)).toBe("01:00:05,001");
  });
  test("empty segments are dropped and numbering stays dense", () => {
    const segs = [
      { id: 0, seek: 0, start: 0, end: 1, text: " a", tokens: [], temperature: 0, avgLogprob: 0, compressionRatio: 1, noSpeechProb: 0 },
      { id: 1, seek: 0, start: 1, end: 1, text: "", tokens: [], temperature: 0, avgLogprob: 0, compressionRatio: 1, noSpeechProb: 0 },
      { id: 2, seek: 0, start: 2, end: 3, text: " b", tokens: [], temperature: 0, avgLogprob: 0, compressionRatio: 1, noSpeechProb: 0 },
    ];
    expect(toSrt(segs)).toBe("1\n00:00:00,000 --> 00:00:01,000\na\n\n2\n00:00:02,000 --> 00:00:03,000\nb\n\n");
    expect(toVtt(segs)).toBe("WEBVTT\n\n00:00:00.000 --> 00:00:01.000\na\n\n00:00:02.000 --> 00:00:03.000\nb\n\n");
  });
});
