// Video file → RGB frames via the AVFoundation sidecar (PLAN 14w) — the
// video twin of the audio path's afconvert doctrine: macOS-native codecs
// (H.264/HEVC/ProRes/…), zero vendored decoders. The sidecar
// (src/native/frame_extract.swift, shipped as `mlx-bun-frame-extract` beside
// the binary and in the native pack) samples frames at fps=2 with
// zero-tolerance timestamps — mirroring mlx-vlm's do_sample_frames — and
// writes PNGs that decode through the SAME fast-png path as image inputs.
//
// Resolution order (afconvert needs none of this because /usr/bin ships it;
// our extractor is the missing CLI face on Apple's decoder):
//   MLX_BUN_FRAME_EXTRACT env → beside the executable (release bundle) →
//   the native-pack cache → dist-native (dev tree) → compile-on-demand from
//   src/native (from-source installs with Xcode CLT; cached in dist-native).

import { existsSync, mkdirSync } from "node:fs";
import { rm } from "node:fs/promises";
import { randomUUID } from "node:crypto";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { nativePackDir } from "../native-pack";
import { decodeImage, type RGBImage } from "./preprocess";
import { runtimeValue } from "../runtime-config";

export const VIDEO_SAMPLE_FPS = 2;
export const VIDEO_MAX_FRAMES = 768; // Qwen3VLVideoProcessor max_frames

const BIN = "mlx-bun-frame-extract";

/** Memoize the PROMISE, not the result: a second video request arriving
 *  while the first compile is in flight must await the same compile, not
 *  observe a half-set cache and spuriously report the sidecar missing. */
let devCompile: Promise<string | null> | null = null;

/** Compile the sidecar from the repo tree (dev/from-source convenience —
 *  needs swiftc from the Xcode CLT). Null when the source or toolchain is
 *  unavailable. */
function compileFromSource(): Promise<string | null> {
  devCompile ??= (async () => {
    const src = join(import.meta.dir, "..", "native", "frame_extract.swift");
    if (!existsSync(src)) return null;
    const out = join(import.meta.dir, "..", "..", "dist-native", BIN);
    try {
      mkdirSync(dirname(out), { recursive: true });
      const proc = Bun.spawn(["swiftc", "-O", src, "-o", out], {
        stdout: "ignore", stderr: "pipe",
      });
      if ((await proc.exited) === 0 && existsSync(out)) return out;
    } catch {
      // no swiftc — resolver returns null and serving 400s with the reason
    }
    return null;
  })();
  return devCompile;
}

/** Locate (or dev-compile) the extractor; null ⟹ video input unavailable
 *  on this install (surfaced as a clear 400, never a crash). */
export async function resolveFrameExtract(): Promise<string | null> {
  const explicit = runtimeValue("MLX_BUN_FRAME_EXTRACT");
  if (explicit) return explicit;
  const candidates = [
    join(dirname(process.execPath), BIN),
    join(nativePackDir(), BIN),
    join(import.meta.dir, "..", "..", "dist-native", BIN),
  ];
  for (const c of candidates) if (existsSync(c)) return c;
  return compileFromSource();
}

/** Decode a video container to sampled RGB frames. Throws with the
 *  sidecar's diagnostic on failure (the serve layer surfaces it as a 400,
 *  the afconvert pattern — timeout kill included). */
export async function extractVideoFrames(
  bytes: Uint8Array,
  opts: { fps?: number; maxFrames?: number } = {},
): Promise<RGBImage[]> {
  const bin = await resolveFrameExtract();
  if (!bin)
    throw new Error(
      "video input needs the frame-extraction sidecar (mlx-bun-frame-extract) " +
      "— ships beside the release binary and in the native pack; from a " +
      "source tree it compiles on first use via the Xcode CLT (swiftc)",
    );
  const base = join(tmpdir(), `mlx-bun-video-${randomUUID()}`);
  // AVFoundation infers the container from the path EXTENSION — sniff the
  // ISO-BMFF `ftyp` box (mp4/mov share it; the `qt  ` major brand is
  // QuickTime) so the temp file opens. Unknown magic defaults to .mp4.
  const isFtyp = bytes.length >= 12 &&
    bytes[4] === 0x66 && bytes[5] === 0x74 && bytes[6] === 0x79 && bytes[7] === 0x70;
  const brand = isFtyp
    ? String.fromCharCode(bytes[8]!, bytes[9]!, bytes[10]!, bytes[11]!)
    : "";
  const ext = brand.startsWith("qt") ? "mov" : "mp4";
  const inPath = `${base}.${ext}`;
  const outDir = `${base}.frames`;
  try {
    // Inside the try so a part-way write failure (ENOSPC on a large clip)
    // still hits the finally's cleanup instead of stranding the temp file.
    await Bun.write(inPath, bytes);
    const proc = Bun.spawn(
      [
        bin, inPath, outDir,
        String(opts.fps ?? VIDEO_SAMPLE_FPS),
        String(opts.maxFrames ?? VIDEO_MAX_FRAMES),
      ],
      { stdout: "pipe", stderr: "pipe" },
    );
    // Decoding is fast (hardware) but long clips take real time; a hung
    // decoder must not pin the request forever — kill → nonzero → 400.
    const killer = setTimeout(() => proc.kill(), 120_000);
    const exit = await proc.exited;
    clearTimeout(killer);
    if (exit !== 0) {
      const err = (await new Response(proc.stderr).text()).trim();
      throw new Error(
        `video decode failed (frame-extract exit ${exit}): ` +
        `${err.split("\n").at(-1) || "unknown error"} — supported containers: ` +
        `whatever AVFoundation decodes on this macOS (mp4/mov H.264/HEVC/ProRes/…)`,
      );
    }
    const head = (await new Response(proc.stdout).text()).trim();
    const n = Number(/^N (\d+)/.exec(head)?.[1] ?? 0);
    if (!n) throw new Error(`video decode produced no frames (${head})`);
    // Aggregate decoded-RGB budget (belt over the sidecar's 1024px
    // longest-edge cap): a valid low-bitrate clip must not balloon into
    // gigabytes of frame buffers before preprocessing.
    const w = Number(/W (\d+)/.exec(head)?.[1] ?? 0);
    const hh = Number(/H (\d+)/.exec(head)?.[1] ?? 0);
    const DECODED_BUDGET = 1536 * 1024 * 1024; // 1.5 GiB
    if (n * w * hh * 3 > DECODED_BUDGET)
      throw new Error(
        `video decodes to ${(n * w * hh * 3 / 1024 / 1024).toFixed(0)} MB of ` +
        `frames (${n} × ${w}x${hh}) — over the ${DECODED_BUDGET / 1024 / 1024} MB ` +
        `budget; send a shorter or smaller clip`,
      );
    const frames: RGBImage[] = [];
    for (let i = 0; i < n; i++) {
      const f = join(outDir, `frame-${String(i).padStart(4, "0")}.png`);
      frames.push(await decodeImage(new Uint8Array(await Bun.file(f).arrayBuffer())));
    }
    return frames;
  } finally {
    await Promise.allSettled([
      rm(inPath, { force: true }),
      rm(outDir, { recursive: true, force: true }),
    ]);
  }
}
