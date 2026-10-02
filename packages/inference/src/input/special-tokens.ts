// Special tokens a model's generated text or media prompts depend on. The model
// profile declares them as token TEXT; the tokenizer in use resolves the ids, so
// no consumer carries a family's vocabulary ids.

import type { AudioTokenIds, VisionTokenIds } from "./vision/prompt";
import type { LoadedTokenizer } from "./tokenizer";

type Encoder = Pick<LoadedTokenizer, "encode">;

/** The id of `text` when the tokenizer encodes it as exactly one token. */
export function singleTokenId(tokenizer: Encoder, text: string): number | null {
  const ids = tokenizer.encode(text, false);
  return ids.length === 1 ? ids[0]! : null;
}

/** Markers that delimit tool calls and the reasoning channel in generated
 * text. They are special tokens the content decoder strips, so a router must
 * see them as ids. */
export interface SentinelTokenTexts {
  readonly toolCallStart: string;
  readonly toolCallEnd: string;
  readonly channelStart: string;
  readonly channelEnd: string;
}
export interface SentinelTokens {
  readonly toolCallStart: number;
  readonly toolCallEnd: number;
  readonly channelStart: number;
  readonly channelEnd: number;
}

/** Resolve declared sentinel texts against a tokenizer. A declared marker that
 * is not one token there means the declaration does not fit this tokenizer. */
export function resolveSentinelTokens(tokenizer: Encoder, texts: SentinelTokenTexts): SentinelTokens {
  const id = (text: string): number => {
    const found = singleTokenId(tokenizer, text);
    if (found === null) throw new Error(`declared sentinel ${JSON.stringify(text)} is not a single token in this tokenizer`);
    return found;
  };
  return { toolCallStart: id(texts.toolCallStart), toolCallEnd: id(texts.toolCallEnd),
    channelStart: id(texts.channelStart), channelEnd: id(texts.channelEnd) };
}

/** Soft-token markers of a graph's tower prompts, by role. */
export interface MediaTokenTexts {
  readonly vision: { readonly image: string; readonly begin: string; readonly end: string };
  readonly audio: { readonly audio: string; readonly begin: string; readonly end: string };
}

const configId = (raw: Record<string, unknown>, key: string): number | undefined =>
  typeof raw[key] === "number" ? raw[key] as number : undefined;

/** Image soft-token ids: the checkpoint's config wins, the declared token text
 * fills what it omits. Null when neither supplies all three. */
export function resolveVisionTokenIds(
  raw: Record<string, unknown>, tokenizer: Encoder, texts: MediaTokenTexts["vision"] | null,
): VisionTokenIds | null {
  const from = (key: string, text: string | undefined) =>
    configId(raw, key) ?? (text === undefined ? null : singleTokenId(tokenizer, text));
  const imageTokenId = from("image_token_id", texts?.image), boiTokenId = from("boi_token_id", texts?.begin),
    eoiTokenId = from("eoi_token_id", texts?.end);
  return imageTokenId == null || boiTokenId == null || eoiTokenId == null ? null : { imageTokenId, boiTokenId, eoiTokenId };
}

/** Audio soft-token ids, for a checkpoint that declares `audio_config`; same precedence as vision. */
export function resolveAudioTokenIds(
  raw: Record<string, unknown>, tokenizer: Encoder, texts: MediaTokenTexts["audio"] | null,
): AudioTokenIds | null {
  if (!raw.audio_config) return null;
  const from = (key: string, text: string | undefined) =>
    configId(raw, key) ?? (text === undefined ? null : singleTokenId(tokenizer, text));
  const audioTokenId = from("audio_token_id", texts?.audio), boaTokenId = from("boa_token_id", texts?.begin),
    eoaTokenId = from("eoa_token_id", texts?.end);
  return audioTokenId == null || boaTokenId == null || eoaTokenId == null ? null : { audioTokenId, boaTokenId, eoaTokenId };
}
