// Non-WAV audio containers → 16 kHz WAV via macOS `afconvert` (CoreAudio —
// built into darwin, our only platform; zero new dependencies). The serve
// layer runs every clip through ensureWav(): RIFF/WAVE bytes pass through
// untouched (decode.ts owns the parse), anything else (mp3/m4a/flac/ogg/
// aiff/…) round-trips through a temp file under os.tmpdir().
//
// Two deliberate choices:
//   - The WAV/non-WAV decision is CONTENT-based (RIFF magic), not
//     metadata-based — a mislabelled `format` field must not break a valid
//     WAV, and an mp3 labelled "wav" still transcodes.
//   - Channel count is preserved (decodeWav does the mono mixdown); the
//     sample rate converts here (`@16000`) because CoreAudio's resampler
//     beats decode.ts's documented linear interpolation for real
//     compressed sources.

import { randomUUID } from "node:crypto";
import { unlink } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

/** RIFF/WAVE magic sniff ("RIFF" at 0, "WAVE" at 8). */
export function isRiffWave(bytes: Uint8Array): boolean {
  return (
    bytes.length >= 12 &&
    bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[2] === 0x46 && bytes[3] === 0x46 &&
    bytes[8] === 0x57 && bytes[9] === 0x41 && bytes[10] === 0x56 && bytes[11] === 0x45
  );
}

/** Transcode any CoreAudio-readable container to 16 kHz PCM16 WAV. Throws
 *  with afconvert's diagnostic on failure — the serve layer surfaces it as
 *  a 400 ("prompt build failed: audio transcode failed …"). Temp files are
 *  cleaned up on every path. */
export async function transcodeToWav(bytes: Uint8Array): Promise<Uint8Array> {
  const base = join(tmpdir(), `mlx-bun-audio-${randomUUID()}`);
  const inPath = `${base}.in`;
  const outPath = `${base}.wav`;
  await Bun.write(inPath, bytes);
  try {
    const proc = Bun.spawn(
      ["afconvert", "-f", "WAVE", "-d", "LEI16@16000", inPath, outPath],
      { stdout: "ignore", stderr: "pipe" },
    );
    // ≤30 s clips convert in well under a second — a hung afconvert must
    // not pin the request forever. kill() → nonzero exit → the 400 below.
    const killer = setTimeout(() => proc.kill(), 30_000);
    const exit = await proc.exited;
    clearTimeout(killer);
    if (exit !== 0) {
      const err = (await new Response(proc.stderr).text()).trim();
      throw new Error(
        `audio transcode failed (afconvert exit ${exit}): ` +
          `${err.split("\n").at(-1) || "unknown error"} — ` +
          `supported containers: WAV (native), mp3/m4a/flac/ogg/aiff via CoreAudio`,
      );
    }
    return new Uint8Array(await Bun.file(outPath).arrayBuffer());
  } finally {
    await Promise.allSettled([unlink(inPath), unlink(outPath)]);
  }
}

/** WAV passthrough or afconvert transcode — every serve-side clip goes
 *  through here before decodeAudio. */
export async function ensureWav(bytes: Uint8Array): Promise<Uint8Array> {
  return isRiffWave(bytes) ? bytes : transcodeToWav(bytes);
}
