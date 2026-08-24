// Multimodal prompt assembly: OpenAI image/audio content parts → spliced
// token ids + merged input embeddings + attention/zeroing masks.
//
// The chat template renders one <|image|> token (258880) per image part and
// one <|audio|> token (258881) per audio part; we expand each in document
// order — <boi> + image_token × softTokens + <eoi> (matching optiq's vision
// frontend) and <boa> + audio_token × n + <eoa> with
// n = min(ceil(duration_ms/40), 750) (processing_gemma4.py) — embed the full
// sequence, then overwrite the soft-token rows with the towers' features.
//
// Attention semantics (docs/design/generic-model-support.md §3.3, resolved vs the oracle):
//   - image runs attend bidirectionally among themselves (bidirMask), BUT
//     any audio token in the prompt disables the vision overlay entirely —
//     mixed image+audio prompts run fully causal (bidirMask = null);
//   - audio runs are strictly causal, always;
//   - per-layer-input id zeroing (e2b/e4b) applies to the UNION of
//     multimodal soft tokens (image | audio) — multimodalMask, decoupled
//     from the bidirectional mask.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Gemma4Model } from "../model/gemma4";
import type { ChatTemplate, ChatMessage, ToolDefinition } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";
import type { AudioTower } from "../audio/conformer";
import { audioSoftTokenCount, decodeAudio } from "../audio/decode";
import { extractMelFeatures } from "../audio/features";
import { fetchMediaBytes, videoMediaFetchPolicy } from "../media-fetch";

/** Common contract for both vision towers (encoder-free gemma4_unified in
 *  ./embedder.ts and the SigLIP encoder in ./siglip.ts): preprocess image
 *  bytes into a tower-specific representation, then turn it into
 *  language-space soft tokens [1, softTokens, hidden] (pre-divided by
 *  embed_scale). The two own different preprocessing, so the tower carries
 *  its own. */
export interface VisionEncoder<P extends { softTokens: number } = { softTokens: number }> {
  preprocess(bytes: Uint8Array): Promise<P>;
  features(pre: P): MlxArray;
  dispose?(): void;
}

export interface VisionPrompt {
  ids: number[];
  /** Unscaled merged embeddings [1, L, hidden] — caller disposes. */
  embeddings: MlxArray;
  /** bool [L] image-token mask — caller disposes. */
  imageMask: MlxArray;
}

export interface MultimodalPrompt {
  ids: number[];
  /** Unscaled merged embeddings [1, L, hidden] — caller disposes. */
  embeddings: MlxArray;
  /** bool [L] image-token mask for the bidirectional attention overlay.
   *  null when the prompt contains ANY audio (§3.3 Q1: mixed image+audio
   *  runs fully causal) or no images. Caller disposes when non-null. */
  bidirMask: MlxArray | null;
  /** bool [L] union multimodal soft-token mask (image | audio) for
   *  per-layer-input id zeroing (§3.3 Q2). Caller disposes. */
  multimodalMask: MlxArray;
}

export interface VisionTokenIds {
  imageTokenId: number;
  boiTokenId: number;
  eoiTokenId: number;
}

export interface AudioTokenIds {
  audioTokenId: number;
  boaTokenId: number;
  eoaTokenId: number;
}

/** The towers a multimodal prompt may need; pass only what the request uses
 *  (vision-only and audio-only fall out as special cases). */
export interface MultimodalTowers<P extends { softTokens: number }> {
  vision?: { tower: VisionEncoder<P>; tokenIds: VisionTokenIds };
  audio?: { tower: AudioTower; tokenIds: AudioTokenIds };
}

/** Extract image bytes from OpenAI-style content parts, rewriting the
 *  parts to the template's {type:"image"} form. */
export async function extractImages(
  messages: ChatMessage[],
): Promise<{ messages: ChatMessage[]; images: Uint8Array[] }> {
  const images: Uint8Array[] = [];
  const out: ChatMessage[] = [];
  for (const m of messages) {
    if (!Array.isArray(m.content)) {
      out.push(m);
      continue;
    }
    const parts: Array<Record<string, unknown>> = [];
    for (const part of m.content) {
      if (part.type === "image_url") {
        const url = (part.image_url as { url: string } | undefined)?.url
          ?? (part.image_url as unknown as string);
        if (typeof url !== "string") throw new Error("image_url part missing url");
        images.push(await fetchMediaBytes(url, "image"));
        parts.push({ type: "image" });
      } else if (part.type === "image") {
        // already template-form: expect base64 `data` or pass-through marker
        if (typeof part.data === "string") {
          images.push(Uint8Array.from(Buffer.from(part.data, "base64")));
          parts.push({ type: "image" });
        } else {
          throw new Error("image part requires base64 `data`");
        }
      } else {
        parts.push(part);
      }
    }
    out.push({ ...m, content: parts });
  }
  return { messages: out, images };
}

/** Extract video bytes from content parts, rewriting to the template's
 *  {type:"video"} form. Accepts {type:"video_url", video_url:{url}} (data:
 *  or http(s), same SSRF guard as images with the larger video body cap)
 *  and {type:"video"} with base64 `data`. Decode to frames happens later
 *  (vision/video-frames.ts — the AVFoundation sidecar). */
export async function extractVideos(
  messages: ChatMessage[],
): Promise<{ messages: ChatMessage[]; videos: Uint8Array[] }> {
  const videos: Uint8Array[] = [];
  const out: ChatMessage[] = [];
  for (const m of messages) {
    if (!Array.isArray(m.content)) {
      out.push(m);
      continue;
    }
    const parts: Array<Record<string, unknown>> = [];
    for (const part of m.content) {
      if (part.type === "video_url") {
        const url = (part.video_url as { url: string } | undefined)?.url
          ?? (part.video_url as unknown as string);
        if (typeof url !== "string") throw new Error("video_url part missing url");
        videos.push(await fetchMediaBytes(url, "video"));
        parts.push({ type: "video" });
      } else if (part.type === "video") {
        if (typeof part.data === "string") {
          // Same cap as fetched/data:-URL video bodies — the inline base64
          // form must not be the uncapped route.
          const cap = videoMediaFetchPolicy().maxBytes;
          if (part.data.length * 0.75 > cap)
            throw new Error(
              `video part exceeds the ${Math.round(cap / 1024 / 1024)} MB cap`,
            );
          videos.push(Uint8Array.from(Buffer.from(part.data, "base64")));
          parts.push({ type: "video" });
        } else {
          throw new Error("video part requires base64 `data`");
        }
      } else {
        parts.push(part);
      }
    }
    out.push({ ...m, content: parts });
  }
  return { messages: out, videos };
}

/** Extract audio bytes from OpenAI-style content parts, rewriting the parts
 *  to the template's {type:"audio"} form. Accepts the OpenAI-canonical
 *  {type:"input_audio", input_audio:{data:<b64>, format:...}} plus optiq's
 *  {type:"audio"} (base64 `data`) and {type:"audio_url"} aliases. */
export async function extractAudio(
  messages: ChatMessage[],
): Promise<{ messages: ChatMessage[]; audio: Uint8Array[] }> {
  const audio: Uint8Array[] = [];
  const out: ChatMessage[] = [];
  for (const m of messages) {
    if (!Array.isArray(m.content)) {
      out.push(m);
      continue;
    }
    const parts: Array<Record<string, unknown>> = [];
    for (const part of m.content) {
      if (part.type === "input_audio") {
        const data = (part.input_audio as { data?: string } | undefined)?.data;
        if (typeof data !== "string")
          throw new Error("input_audio part requires base64 `input_audio.data`");
        audio.push(Uint8Array.from(Buffer.from(data, "base64")));
        parts.push({ type: "audio" });
      } else if (part.type === "audio") {
        if (typeof part.data === "string") {
          audio.push(Uint8Array.from(Buffer.from(part.data, "base64")));
          parts.push({ type: "audio" });
        } else {
          throw new Error("audio part requires base64 `data`");
        }
      } else if (part.type === "audio_url") {
        const url = (part.audio_url as { url: string } | undefined)?.url
          ?? (part.audio_url as unknown as string);
        if (typeof url !== "string") throw new Error("audio_url part missing url");
        audio.push(await fetchMediaBytes(url, "audio"));
        parts.push({ type: "audio" });
      } else {
        parts.push(part);
      }
    }
    out.push({ ...m, content: parts });
  }
  return { messages: out, audio };
}

/** Decoded + featurized audio clip, ready to splice. */
interface PreparedAudio {
  mel: Float32Array;
  frames: number;
  softTokens: number;
}

export async function buildMultimodalPrompt<P extends { softTokens: number }>(
  model: Gemma4Model,
  towers: MultimodalTowers<P>,
  tokenizer: LoadedTokenizer,
  template: ChatTemplate,
  messages: ChatMessage[],
  images: Uint8Array[],
  audio: Uint8Array[],
  tools: ToolDefinition[] | null = null,
): Promise<MultimodalPrompt> {
  if (images.length > 0 && !towers.vision)
    throw new Error("images present but no vision tower configured");
  if (audio.length > 0 && !towers.audio)
    throw new Error("audio present but no audio tower configured");

  const rendered = template.render(messages, { tools });
  let ids = tokenizer.encode(rendered);
  if (ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId) ids = ids.slice(1);

  // preprocess every clip/image up front (splice lengths depend on them);
  // audio soft-token counts come from the DECODED samples, never metadata.
  const pre = await Promise.all(
    images.map((bytes) => towers.vision!.tower.preprocess(bytes)),
  );
  const clips: PreparedAudio[] = audio.map((bytes) => {
    const samples = decodeAudio(bytes);
    const softTokens = audioSoftTokenCount(samples.length);
    const m = extractMelFeatures(samples);
    return { mel: m.features, frames: m.frames, softTokens };
  });

  const vIds = towers.vision?.tokenIds;
  const aIds = towers.audio?.tokenIds;

  // expand each <|image|> into <boi> + image_token×soft + <eoi> and each
  // <|audio|> into <boa> + audio_token×n + <eoa>, in document order
  const spliced: number[] = [];
  const runs: { start: number; length: number; kind: "image" | "audio"; index: number }[] = [];
  let imgIdx = 0;
  let audIdx = 0;
  for (const id of ids) {
    if (vIds && id === vIds.imageTokenId) {
      const p = pre[imgIdx];
      if (!p) throw new Error("more <|image|> markers than images");
      spliced.push(vIds.boiTokenId);
      runs.push({ start: spliced.length, length: p.softTokens, kind: "image", index: imgIdx });
      for (let k = 0; k < p.softTokens; k++) spliced.push(vIds.imageTokenId);
      spliced.push(vIds.eoiTokenId);
      imgIdx++;
    } else if (aIds && id === aIds.audioTokenId) {
      const clip = clips[audIdx];
      if (!clip) throw new Error("more <|audio|> markers than audio clips");
      spliced.push(aIds.boaTokenId);
      runs.push({ start: spliced.length, length: clip.softTokens, kind: "audio", index: audIdx });
      for (let k = 0; k < clip.softTokens; k++) spliced.push(aIds.audioTokenId);
      spliced.push(aIds.eoaTokenId);
      audIdx++;
    } else {
      spliced.push(id);
    }
  }
  if (imgIdx !== images.length)
    throw new Error(`${images.length} images but ${imgIdx} <|image|> markers`);
  if (audIdx !== audio.length)
    throw new Error(`${audio.length} audio clips but ${audIdx} <|audio|> markers`);

  // embed text tokens, then overwrite soft-token rows with tower features
  const idsArr = ops.fromInt32(spliced, [1, spliced.length]);
  let embeds = model.embed.encode(idsArr);
  idsArr.dispose();
  const hidden = embeds.shape[2]!;
  for (const run of runs) {
    let cast: MlxArray;
    if (run.kind === "image") {
      // vision towers return pre-divided by embed_scale (their oracle's
      // frontend convention) — cast to the embedding dtype and splice.
      const feats = towers.vision!.tower.features(pre[run.index]!); // [1, soft, hidden]
      cast = feats.astype(embeds.dtype);
      feats.dispose();
    } else {
      // audio mirrors gen-e4b-audio-golden.py EXACTLY:
      //   features.astype(embeds.dtype) / embed_scale
      // — raw f32 embed_audio output, cast to bf16 FIRST, then divided by a
      // weak (dtype-following, i.e. bf16) embed_scale scalar. The order is
      // load-bearing for the bit-exact greedy gate (see AudioTower.features).
      const clip = clips[run.index]!;
      const raw = towers.audio!.tower.features(clip.mel, clip.frames, false); // [1, n, hidden] f32
      if (raw.shape[1] !== clip.softTokens) {
        const n = raw.shape[1];
        raw.dispose();
        embeds.dispose();
        throw new Error(`audio tower produced ${n} frames but splice expects ${clip.softTokens}`);
      }
      const bf = raw.astype(embeds.dtype);
      raw.dispose();
      const scale = ops.scalarLike(towers.audio!.tower.embedScale, bf);
      cast = ops.div(bf, scale);
      bf.dispose();
      scale.dispose();
    }
    const { start, length } = run;
    const updated = ops.sliceUpdate(embeds, cast, [0, start, 0], [1, start + length, hidden]);
    cast.dispose();
    embeds.dispose();
    embeds = updated;
  }

  // masks over the spliced sequence: union multimodal soft tokens (per-layer
  // id zeroing) always; image-only bidirectional overlay only when NO audio
  // is present (§3.3 Q1).
  const mmInts = new Int32Array(spliced.length);
  for (let i = 0; i < spliced.length; i++) {
    const id = spliced[i]!;
    mmInts[i] = (vIds && id === vIds.imageTokenId) || (aIds && id === aIds.audioTokenId) ? 1 : 0;
  }
  const mmI32 = MlxArray.fromInt32(mmInts, [spliced.length]);
  const multimodalMask = mmI32.astype(Dtype.bool);
  mmI32.dispose();

  let bidirMask: MlxArray | null = null;
  if (images.length > 0 && audio.length === 0) {
    const imgInts = new Int32Array(spliced.length);
    for (let i = 0; i < spliced.length; i++)
      imgInts[i] = spliced[i] === vIds!.imageTokenId ? 1 : 0;
    const imgI32 = MlxArray.fromInt32(imgInts, [spliced.length]);
    bidirMask = imgI32.astype(Dtype.bool);
    imgI32.dispose();
  }

  return { ids: spliced, embeddings: embeds, bidirMask, multimodalMask };
}

/** Vision-only prompt (back-compat wrapper over buildMultimodalPrompt —
 *  behavior byte-identical to the pre-audio builder: the returned imageMask
 *  serves as BOTH the bidirectional-attention mask and the per-layer-input
 *  zeroing mask, which forwardEmbeddings derives from `bidir` when no
 *  separate multimodal mask is passed). */
export async function buildVisionPrompt<P extends { softTokens: number }>(
  model: Gemma4Model,
  tower: VisionEncoder<P>,
  tokenizer: LoadedTokenizer,
  template: ChatTemplate,
  messages: ChatMessage[],
  images: Uint8Array[],
  tokenIds: VisionTokenIds,
  tools: ToolDefinition[] | null = null,
): Promise<VisionPrompt> {
  const mp = await buildMultimodalPrompt(
    model, { vision: { tower, tokenIds } }, tokenizer, template,
    messages, images, [], tools,
  );
  // no audio was passed, so the union mask IS the image mask — reuse it for
  // the zero-image edge (the original builder returned an all-false mask).
  const imageMask = mp.bidirMask ?? mp.multimodalMask;
  if (mp.bidirMask) mp.multimodalMask.dispose();
  return { ids: mp.ids, embeddings: mp.embeddings, imageMask };
}
