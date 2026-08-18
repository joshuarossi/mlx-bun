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
import { preprocessQwen3VLImage, preprocessQwen3VLVideoFrames } from "./qwen3vl-preprocess";
import { extractVideoFrames } from "./video-frames";
import { QWEN3VL_MERGE_SIZE } from "./qwen3vl-preprocess";
import type { Qwen3VLVisionTower } from "./qwen3vl-tower";

export interface Qwen3VLTokenIds {
  imageTokenId: number; // <|image_pad|>
  videoTokenId: number; // <|video_pad|>
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

  // Expand each pad token to its medium's token count; collect grids in
  // PROMPT order (get_rope_index consumes image/video grids interleaved).
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
      grids.push(pp.gridThw);
      for (let i = 0; i < pp.imageTokens; i++) ids.push(tokenIds.videoTokenId);
    } else ids.push(t);
  }

  const mrope = qwenRopeIndex(
    ids, grids, QWEN3VL_MERGE_SIZE, tokenIds.imageTokenId, tokenIds.videoTokenId,
  );

  // Text embeddings, then splice the tower features over the media spans by
  // segment concatenation (spans are contiguous runs of their pad token).
  const idsArr = ops.fromInt32(ids, [1, ids.length]);
  const textEmb = model.embed.encode(idsArr); // [1, L, H]
  idsArr.dispose();
  const H = textEmb.shape[2]!;
  const segments: MlxArray[] = [];
  const owned: MlxArray[] = [];
  let cursor = 0;
  imgIdx = 0;
  vidIdx = 0;
  for (let i = 0; i < ids.length; ) {
    const isImage = ids[i] === tokenIds.imageTokenId;
    const isVideo = ids[i] === tokenIds.videoTokenId;
    if (isImage || isVideo) {
      const pp = isImage ? imagePps[imgIdx++]! : videoPps[vidIdx++]!;
      const count = pp.imageTokens;
      if (cursor < i) {
        const seg = textEmb.slice([0, cursor, 0], [1, i, H]);
        segments.push(seg);
        owned.push(seg);
      }
      const feat = tower.encode(pp); // [count, H] bf16
      const feat3 = ops.reshape(feat, [1, count, H]);
      feat.dispose();
      segments.push(feat3);
      owned.push(feat3);
      cursor = i + count;
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
  for (const s of owned) s.dispose();
  textEmb.dispose();
  return { ids, embeddings, mrope };
}
