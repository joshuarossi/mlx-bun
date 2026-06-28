// Text-embedding entry point. Wraps Qwen3Model.embedPooled (last-token hidden →
// L2-normalized vector) with the Qwen3-Embedding input convention so the CLI
// (`mlx-bun embed`), the server (`/v1/embeddings`), and in-repo experiments all
// produce the SAME vectors — the ones verified bit-exact vs mlx-lm in
// tests/qwen3-embed-parity.test.ts.

import { Qwen3Model } from "./model/qwen3";
import type { RuntimeModel } from "./model/factory";
import type { LoadedTokenizer } from "./tokenizer";
import * as ops from "./mlx/ops";

/** <|endoftext|> — the token Qwen3-Embedding terminates every input with and
 *  pools the last position of. */
export const EMBED_EOD = 151643;

/** Only plain-Qwen3 (the Qwen3-Embedding backbone) exposes a pooled-embedding
 *  path today. Narrow the served RuntimeModel before embedding. */
export function isEmbeddingModel(model: RuntimeModel): model is Qwen3Model {
  return model instanceof Qwen3Model;
}

/** Qwen3-Embedding query format: a task instruction steers WHICH similarity axis
 *  the geometry reflects ("represent this for topic routing" vs "...for
 *  sentiment"). Documents are embedded raw; only queries get an instruction. */
export function withInstruction(text: string, instruction?: string): string {
  return instruction ? `Instruct: ${instruction}\nQuery:${text}` : text;
}

/** Tripwire: counts embedOne invocations (embedMany accrues via embedOne) so
 *  callers can assert the pipeline embeds exactly as many times as expected. */
let embedCallCount = 0;

/** Reset the embed tripwire counter to 0. */
export function resetEmbedCounter(): void {
  embedCallCount = 0;
}

/** Read the embed tripwire counter (total embedOne calls since last reset). */
export function getEmbedCounter(): number {
  return embedCallCount;
}

export interface EmbedResult {
  /** L2-normalized embedding (length = model hidden size). */
  vector: Float32Array;
  /** Token count of the embedded input (incl. the EOD pooling token). */
  tokens: number;
}

/** Embed one text. `instruction` (optional) applies the query format. */
export function embedOne(
  model: Qwen3Model,
  tok: LoadedTokenizer,
  text: string,
  instruction?: string,
): EmbedResult {
  embedCallCount++;
  // addSpecialTokens=false matches the bit-exact parity path (Qwen3 has no BOS;
  // we append the EOD pooling token ourselves).
  const ids = [...tok.encode(withInstruction(text, instruction), false), EMBED_EOD];
  const idArr = ops.fromInt32(ids, [1, ids.length]);
  const vec = model.embedPooled(idArr);
  idArr.dispose();
  const out = vec.toFloat32();
  vec.dispose();
  return { vector: out, tokens: ids.length };
}

/** Embed many texts (one forward each — the runtime is single-sequence). */
export function embedMany(
  model: Qwen3Model,
  tok: LoadedTokenizer,
  texts: string[],
  instruction?: string,
): EmbedResult[] {
  return texts.map((t) => embedOne(model, tok, t, instruction));
}
