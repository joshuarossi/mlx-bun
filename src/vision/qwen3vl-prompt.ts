// Qwen3.8 vision prompt assembly (PLAN 14v) — mirrors mlx-vlm's processor +
// get_input_embeddings flow:
//
//   template renders each {type:"image"} part as
//   <|vision_start|><|image_pad|><|vision_end|>  →  every <|image_pad|>
//   is EXPANDED to gridT*(gridH/2)*(gridW/2) copies (the processor's
//   merge_length expansion)  →  embed_tokens(ids) with the tower's merged
//   features overwriting the image-token rows (masked_scatter ≡ segment
//   concat for contiguous spans)  →  get_rope_index positions + delta.
//
// One tower call per image — attention never crosses cu_seqlens boundaries
// and pos/rope embeds are per-grid, so per-image encoding is value-identical
// to the reference's single batched call.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { ChatMessage, ChatTemplate, ToolDefinition } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";
import type { Qwen35Model } from "../model/qwen3_5";
import { qwenRopeIndex, type MropeRequestState } from "../model/qwen3-mrope";
import { preprocessQwen3VLImage, preprocessQwen3VLVideoFrames, pyFixed1 } from "./qwen3vl-preprocess";
import { extractVideoFrames } from "./video-frames";
import { QWEN3VL_MERGE_SIZE } from "./qwen3vl-preprocess";
import type { Qwen3VLVisionTower } from "./qwen3vl-tower";

export interface Qwen3VLTokenIds {
  imageTokenId: number; // <|image_pad|>
  videoTokenId: number; // <|video_pad|>
  /** <|vision_start|> / <|vision_end|> — the per-frame-group wrappers the
   *  video expansion emits (defaults are the Qwen3.5 family ids). */
  visionStartId?: number;
  visionEndId?: number;
}

export interface Qwen3VLVisionPrompt {
  ids: number[];
  /** [1, L, H] bf16 spliced input embeddings (caller owns → generate()). */
  embeddings: MlxArray;
  /** Request mRoPE state for Qwen35Model.mrope. */
  mrope: MropeRequestState;
}

export async function buildQwen3VLVisionPrompt(
  model: Qwen35Model,
  tower: Qwen3VLVisionTower,
  tokenizer: LoadedTokenizer,
  template: ChatTemplate,
  messages: ChatMessage[],
  images: Uint8Array[],
  tokenIds: Qwen3VLTokenIds,
  renderOptions: Parameters<ChatTemplate["render"]>[1] = {},
  videos: Uint8Array[] = [],
): Promise<Qwen3VLVisionPrompt> {
  // The request's full template options (tools, enableThinking,
  // reasoningEffort, preserveThinking) flow through — a media prompt must
  // honor the same thinking controls as a text one.
  const rendered = template.render(messages, {
    ...renderOptions, addGenerationPrompt: true,
  });
  const rawIds = tokenizer.encode(rendered, /* addSpecialTokens */ false);
  const imagePads = rawIds.filter((t) => t === tokenIds.imageTokenId).length;
  const videoPads = rawIds.filter((t) => t === tokenIds.videoTokenId).length;
  if (imagePads !== images.length)
    throw new Error(
      `prompt renders ${imagePads} image slots but ${images.length} images were supplied`,
    );
  if (videoPads !== videos.length)
    throw new Error(
      `prompt renders ${videoPads} video slots but ${videos.length} videos were supplied`,
    );

  // Preprocess each medium in its own appearance order; videos decode to
  // sampled frames through the AVFoundation sidecar first.
  const imagePps = [];
  for (const img of images) imagePps.push(await preprocessQwen3VLImage(img));
  const videoPps = [];
  for (const vid of videos)
    videoPps.push(preprocessQwen3VLVideoFrames(await extractVideoFrames(vid)));

  // Expand each pad token; collect grids in PROMPT order (get_rope_index
  // consumes image/video grids interleaved). Images expand to one contiguous
  // run. Videos follow the TRAINING-TIME processor (transformers
  // replace_video_token — mlx-vlm 0.6.14 lacks this and is NOT the oracle
  // here): each temporal frame group renders as
  //   <{t:.1f} seconds><|vision_start|>{pads}<|vision_end|>
  // inside the template's outer vision wrappers, with a PER-GROUP t=1 grid
  // (the reference splits video_grid_thw per frame — "timestamps are used
  // to separate videos"). Timestamp text always sits between special
  // tokens, so per-segment encoding equals whole-string tokenization.
  const visionStartId = tokenIds.visionStartId ?? 248053;
  const visionEndId = tokenIds.visionEndId ?? 248054;
  const ids: number[] = [];
  const grids: [number, number, number][] = [];
  let imgIdx = 0;
  let vidIdx = 0;
  for (const t of rawIds) {
    if (t === tokenIds.imageTokenId) {
      const pp = imagePps[imgIdx++]!;
      grids.push(pp.gridThw);
      for (let i = 0; i < pp.imageTokens; i++) ids.push(tokenIds.imageTokenId);
    } else if (t === tokenIds.videoTokenId) {
      const pp = videoPps[vidIdx++]!;
      const [gridT, gridH, gridW] = pp.gridThw;
      const frameTokens = pp.imageTokens / gridT;
      const ts = pp.groupTimestamps ?? [];
      for (let g = 0; g < gridT; g++) {
        const header = `<${pyFixed1(ts[g] ?? g)} seconds>`;
        for (const tok of tokenizer.encode(header, false)) ids.push(tok);
        ids.push(visionStartId);
        grids.push([1, gridH, gridW]);
        for (let i = 0; i < frameTokens; i++) ids.push(tokenIds.videoTokenId);
        ids.push(visionEndId);
      }
    } else ids.push(t);
  }

  const mrope = qwenRopeIndex(
    ids, grids, QWEN3VL_MERGE_SIZE, tokenIds.imageTokenId, tokenIds.videoTokenId,
  );

  // Text embeddings, then splice the tower features over the media spans by
  // segment concatenation (spans are contiguous runs of their pad token).
  // Everything mlx-allocated here is owned by THIS function until the
  // final embeddings hand-off, so a throw mid-splice (tower.encode on media
  // 2 of 3, an mlx graph error) must dispose the lot — the caller's 400
  // path can't reach any of it (2026-08-18 review: repeated failing media
  // requests would otherwise strand un-admitted GPU memory on the GC
  // backstop).
  const idsArr = ops.fromInt32(ids, [1, ids.length]);
  const textEmb = model.embed.encode(idsArr); // [1, L, H]
  idsArr.dispose();
  const owned: MlxArray[] = [];
  try {
    const H = textEmb.shape[2]!;
    const segments: MlxArray[] = [];
    let cursor = 0;
    imgIdx = 0;
    vidIdx = 0;
    // A video's tower features cover ALL its frame groups; consecutive pad
    // RUNS consume consecutive feature-row windows.
    let vidFeat: MlxArray | null = null;
    let vidRow = 0;
    for (let i = 0; i < ids.length; ) {
      const isImage = ids[i] === tokenIds.imageTokenId;
      const isVideo = ids[i] === tokenIds.videoTokenId;
      if (isImage || isVideo) {
        // Measure this contiguous pad run.
        let runEnd = i;
        while (runEnd < ids.length && ids[runEnd] === ids[i]) runEnd++;
        const runLen = runEnd - i;
        if (cursor < i) {
          const seg = textEmb.slice([0, cursor, 0], [1, i, H]);
          segments.push(seg);
          owned.push(seg);
        }
        let rows: MlxArray;
        if (isImage) {
          const feat = tower.encode(imagePps[imgIdx++]!); // [runLen, H]
          owned.push(feat);
          rows = feat;
        } else {
          if (!vidFeat) {
            vidFeat = tower.encode(videoPps[vidIdx]!); // [imageTokens, H]
            owned.push(vidFeat);
            vidRow = 0;
          }
          const sl = vidFeat.slice([vidRow, 0], [vidRow + runLen, H]);
          owned.push(sl);
          rows = sl;
          vidRow += runLen;
          if (vidRow >= videoPps[vidIdx]!.imageTokens) {
            vidFeat = null;
            vidIdx++;
          }
        }
        const feat3 = ops.reshape(rows, [1, runLen, H]);
        segments.push(feat3);
        owned.push(feat3);
        cursor = runEnd;
        i = cursor;
      } else i++;
    }
    if (cursor < ids.length) {
      const seg = textEmb.slice([0, cursor, 0], [1, ids.length, H]);
      segments.push(seg);
      owned.push(seg);
    }
    const embeddings = segments.length === 1
      ? ops.contiguous(segments[0]!)
      : ops.concatAxis(segments, 1);
    return { ids, embeddings, mrope };
  } finally {
    for (const s of owned) s.dispose();
    textEmb.dispose();
  }
}
