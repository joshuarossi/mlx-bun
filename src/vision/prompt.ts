// Multimodal prompt assembly: OpenAI image_url content parts → spliced
// token ids + merged input embeddings + image-token mask.
//
// The chat template renders one <|image|> token (258880) per image part;
// we expand each into <boi> + image_token × softTokens + <eoi> (matching
// optiq's frontend), embed the full sequence, then overwrite the
// image-token rows with the vision tower's features.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Gemma4Model } from "../model/gemma4";
import type { ChatTemplate, ChatMessage, ToolDefinition } from "../chat-template";
import type { LoadedTokenizer } from "../tokenizer";

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

export interface VisionTokenIds {
  imageTokenId: number;
  boiTokenId: number;
  eoiTokenId: number;
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
        images.push(await fetchImageBytes(url));
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

async function fetchImageBytes(url: string): Promise<Uint8Array> {
  if (url.startsWith("data:")) {
    const comma = url.indexOf(",");
    if (comma === -1) throw new Error("malformed data: URL");
    const meta = url.slice(0, comma);
    const body = url.slice(comma + 1);
    if (!meta.includes("base64")) throw new Error("data: URL must be base64");
    return Uint8Array.from(Buffer.from(body, "base64"));
  }
  if (url.startsWith("http://") || url.startsWith("https://")) {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`image fetch failed: ${res.status} ${url}`);
    return new Uint8Array(await res.arrayBuffer());
  }
  throw new Error(`unsupported image url scheme: ${url.slice(0, 16)}`);
}

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
  const rendered = template.render(messages, { tools });
  let ids = tokenizer.encode(rendered);
  if (ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId) ids = ids.slice(1);

  // preprocess + embed every image (in order of appearance), via the
  // tower's own preprocessing (encoder-free vs SigLIP differ here).
  const pre = await Promise.all(images.map((bytes) => tower.preprocess(bytes)));

  // expand each <|image|> into <boi> + image_token×soft + <eoi>
  const spliced: number[] = [];
  const runs: { start: number; length: number }[] = [];
  let imgIdx = 0;
  for (const id of ids) {
    if (id === tokenIds.imageTokenId) {
      const p = pre[imgIdx];
      if (!p) throw new Error("more <|image|> markers than images");
      spliced.push(tokenIds.boiTokenId);
      runs.push({ start: spliced.length, length: p.softTokens });
      for (let k = 0; k < p.softTokens; k++) spliced.push(tokenIds.imageTokenId);
      spliced.push(tokenIds.eoiTokenId);
      imgIdx++;
    } else {
      spliced.push(id);
    }
  }
  if (imgIdx !== images.length)
    throw new Error(`${images.length} images but ${imgIdx} <|image|> markers`);

  // embed text tokens, then overwrite image-token rows with vision features
  const idsArr = ops.fromInt32(spliced, [1, spliced.length]);
  let embeds = model.embed.encode(idsArr);
  idsArr.dispose();
  const hidden = embeds.shape[2]!;
  for (let i = 0; i < runs.length; i++) {
    const { start, length } = runs[i]!;
    const feats = tower.features(pre[i]!); // [1, soft, hidden]
    const cast = feats.astype(embeds.dtype);
    feats.dispose();
    const updated = ops.sliceUpdate(embeds, cast, [0, start, 0], [1, start + length, hidden]);
    cast.dispose();
    embeds.dispose();
    embeds = updated;
  }

  const maskInts = new Int32Array(spliced.length);
  for (let i = 0; i < spliced.length; i++)
    maskInts[i] = spliced[i] === tokenIds.imageTokenId ? 1 : 0;
  const maskI32 = MlxArray.fromInt32(maskInts, [spliced.length]);
  const imageMask = maskI32.astype(Dtype.bool);
  maskI32.dispose();

  return { ids: spliced, embeddings: embeds, imageMask };
}
