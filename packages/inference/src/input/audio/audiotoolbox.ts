// In-process audio decoding through macOS AudioToolbox (ExtAudioFile) over
// bun:ffi — every container/codec CoreAudio reads (mp3, m4a/aac, flac, ogg,
// aiff, caf, wav, mov/mp4 audio tracks…) straight to 16 kHz mono float32,
// with CoreAudio's own resampler. Replaces the `afconvert` subprocess of
// transcode.ts (no process spawn, no WAV re-parse); the bytes still touch a
// temp file because ExtAudioFile opens URLs.

import { dlopen, FFIType, ptr, read } from "bun:ffi";
import { randomUUID } from "node:crypto";
import { unlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const { ptr: P, i32, u32, u64, i64 } = FFIType;

function openLibs() {
  const at = dlopen("/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox", {
    ExtAudioFileOpenURL: { args: [u64, P], returns: i32 },
    ExtAudioFileSetProperty: { args: [u64, u32, u32, P], returns: i32 },
    ExtAudioFileGetProperty: { args: [u64, u32, P, P], returns: i32 },
    ExtAudioFileRead: { args: [u64, P, P], returns: i32 },
    ExtAudioFileDispose: { args: [u64], returns: i32 },
  }).symbols;
  const cf = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", {
    CFURLCreateFromFileSystemRepresentation: { args: [u64, P, i64, FFIType.bool], returns: u64 },
    CFRelease: { args: [u64], returns: i32 },
  }).symbols;
  return { at, cf };
}

let libs: ReturnType<typeof openLibs> | null = null;
const load = () => (libs ??= openLibs());

const fourcc = (s: string) => (s.charCodeAt(0) << 24 | s.charCodeAt(1) << 16 | s.charCodeAt(2) << 8 | s.charCodeAt(3)) >>> 0;
const kExtAudioFileProperty_ClientDataFormat = fourcc("cfmt");
const kExtAudioFileProperty_FileLengthFrames = fourcc("#frm");
const kAudioFormatLinearPCM = fourcc("lpcm");
const kAudioFormatFlagIsFloat = 1;
const kAudioFormatFlagIsPacked = 8;

export const AUDIOTOOLBOX_SAMPLE_RATE = 16_000;

/** Decode a file to 16 kHz mono float32 with CoreAudio. Throws on undecodable input. */
export function decodeFileWithAudioToolbox(path: string, sampleRate = AUDIOTOOLBOX_SAMPLE_RATE): Float32Array {
  const { at, cf } = load();
  const pathBuf = Buffer.from(path, "utf8");
  const url = cf.CFURLCreateFromFileSystemRepresentation(0n, ptr(pathBuf), BigInt(pathBuf.length), false) as bigint;
  if (!url) throw new Error("AudioToolbox: cannot build file URL");
  const refSlot = new BigUint64Array(1);
  try {
    let st = at.ExtAudioFileOpenURL(url, ptr(refSlot)) as number;
    if (st !== 0) throw new Error(`AudioToolbox: unrecognized or undecodable audio (ExtAudioFileOpenURL ${st})`);
    const ref = read.u64(ptr(refSlot), 0);
    try {
      // AudioStreamBasicDescription: 40 bytes
      const asbd = Buffer.alloc(40);
      asbd.writeDoubleLE(sampleRate, 0);
      asbd.writeUInt32LE(kAudioFormatLinearPCM, 8);
      asbd.writeUInt32LE(kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked, 12);
      asbd.writeUInt32LE(4, 16); // bytes per packet
      asbd.writeUInt32LE(1, 20); // frames per packet
      asbd.writeUInt32LE(4, 24); // bytes per frame
      asbd.writeUInt32LE(1, 28); // channels
      asbd.writeUInt32LE(32, 32); // bits per channel
      st = at.ExtAudioFileSetProperty(ref, kExtAudioFileProperty_ClientDataFormat, 40, ptr(asbd)) as number;
      if (st !== 0) throw new Error(`AudioToolbox: cannot set client format (${st})`);
      // frame count hint (source rate), used only to size the first buffer
      const lenSlot = new BigInt64Array(1);
      const lenSize = new Uint32Array([8]);
      at.ExtAudioFileGetProperty(ref, kExtAudioFileProperty_FileLengthFrames, ptr(lenSize), ptr(lenSlot));
      const chunkFrames = 1 << 16;
      const chunk = new Float32Array(chunkFrames);
      // AudioBufferList { UInt32 mNumberBuffers; [pad 4]; AudioBuffer { UInt32 mNumberChannels; UInt32 mDataByteSize; void* mData } }
      const abl = Buffer.alloc(24);
      const frames = new Uint32Array(1);
      const parts: Float32Array[] = [];
      let total = 0;
      for (;;) {
        abl.writeUInt32LE(1, 0);
        abl.writeUInt32LE(1, 8);
        abl.writeUInt32LE(chunkFrames * 4, 12);
        abl.writeBigUInt64LE(BigInt(ptr(chunk)), 16);
        frames[0] = chunkFrames;
        st = at.ExtAudioFileRead(ref, ptr(frames), ptr(abl)) as number;
        if (st !== 0) throw new Error(`AudioToolbox: decode failed (ExtAudioFileRead ${st})`);
        const n = frames[0]!;
        if (n === 0) break;
        parts.push(chunk.slice(0, n));
        total += n;
      }
      const out = new Float32Array(total);
      let o = 0;
      for (const p of parts) { out.set(p, o); o += p.length; }
      return out;
    } finally {
      at.ExtAudioFileDispose(ref);
    }
  } finally {
    cf.CFRelease(url);
  }
}

/** Decode in-memory bytes (any CoreAudio-readable container) via a temp file. */
export function decodeBytesWithAudioToolbox(bytes: Uint8Array, sampleRate = AUDIOTOOLBOX_SAMPLE_RATE): Float32Array {
  const path = join(tmpdir(), `mlx-bun-audio-${randomUUID()}`);
  writeFileSync(path, bytes);
  try {
    return decodeFileWithAudioToolbox(path, sampleRate);
  } finally {
    try { unlinkSync(path); } catch { /* already gone */ }
  }
}
