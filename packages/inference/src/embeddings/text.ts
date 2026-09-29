// Text-embedding entry point. Wraps a graph's `embedPooled` (last-token hidden,
// L2-normalized vector) with the input convention its profile declares, so the
// CLI (`mlx-bun embed`), the server (`/v1/embeddings`), and in-repo experiments
// all produce the SAME vectors — the ones verified bit-exact vs mlx-lm and main in
// tests/parity/embedding-parity.test.ts (opt-in) for the Qwen3-Embedding backbone.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { declaredGraph } from "../models/capabilities";
import type { LoadedTokenizer } from "../input/tokenizer";
import * as ops from "@mlx-bun/mlx/ops";

/** The operation behind a graph's `embeddings` capability. */
export interface EmbeddingGraph { embedPooled(ids: MlxArray): MlxArray }

/** A graph declares the pooled-embedding path. */
export function isEmbeddingModel(model: object): model is EmbeddingGraph {
  return declaredGraph(model).graphCapabilities.embeddings;
}

/** The token id of the profile's declared pooling terminator in this tokenizer. */
export function embeddingTerminatorId(tok: Pick<LoadedTokenizer, "encode">, terminator: string): number {
  const ids = tok.encode(terminator, false);
  if (ids.length !== 1) throw new Error(`embedding terminator ${JSON.stringify(terminator)} is not a single token in this tokenizer`);
  return ids[0]!;
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
  /** Token count of the embedded input (incl. the pooling token). */
  tokens: number;
}

/** Embed one text. `terminator` is the pooling token id from
 * `embeddingTerminatorId`; `instruction` (optional) applies the query format. */
export function embedOne(
  model: EmbeddingGraph,
  tok: LoadedTokenizer,
  terminator: number,
  text: string,
  instruction?: string,
): EmbedResult {
  embedCallCount++;
  // addSpecialTokens=false matches the bit-exact parity path (no BOS;
  // we append the pooling token ourselves).
  const ids = [...tok.encode(withInstruction(text, instruction), false), terminator];
  const idArr = ops.fromInt32(ids, [1, ids.length]);
  const vec = model.embedPooled(idArr);
  idArr.dispose();
  const out = vec.toFloat32();
  vec.dispose();
  return { vector: out, tokens: ids.length };
}

/** Embed many texts (one forward each — the runtime is single-sequence). */
export function embedMany(
  model: EmbeddingGraph,
  tok: LoadedTokenizer,
  terminator: number,
  texts: string[],
  instruction?: string,
): EmbedResult[] {
  return texts.map((t) => embedOne(model, tok, terminator, t, instruction));
}
