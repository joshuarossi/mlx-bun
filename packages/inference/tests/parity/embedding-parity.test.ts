// Qwen3-Embedding-4B-4bit-DWQ against two external references, with real weights:
//   - mlx-lm (main 02d723a:scripts/oracle/gen-qwen3-embed-golden.py, unchanged;
//     run with the mlx-lm reference environment for this MLX version): the
//     post-final-norm hidden states [L, H] and the last-token pooled, L2-normalized
//     vector for the golden token ids, bit for bit;
//   - pre-refactor main's own embedding path (scripts/main-speech-reference.ts run
//     in a main checkout): the vectors and token counts embedMany returns for four
//     texts, as documents and with a query instruction, bit for bit.
// It also checks the embed call counter. The model and references stay outside
// this repository; this test never starts Python or main. Opt in with all of
//   MLX_BUN_TEST_EMBED_MODEL=/Qwen3-Embedding snapshot
//   MLX_BUN_TEST_EMBED_REFERENCE=/dir (meta.json, hidden.bin, pooled.bin, main-embed.json)
//   MLX_BUN_TEST_EMBED_REFERENCE_SHA256=<meta.json SHA-256>
//   MLX_BUN_TEST_EMBED_MAIN_SHA256=<main-embed.json SHA-256>
// None set skips; any other combination fails. References, the weights and the
// config are verified against their pins before native libraries load.
import { afterAll, beforeAll, describe, expect, setDefaultTimeout, test } from "bun:test";
import { strict as assert } from "node:assert";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { fileSha256, optInAll, sha256 } from "./real-weight-inputs";
import { countMismatch, float32Of, readBlob, readPinnedJson } from "./speech-inputs";

const OPT_IN = ["MLX_BUN_TEST_EMBED_MODEL", "MLX_BUN_TEST_EMBED_REFERENCE", "MLX_BUN_TEST_EMBED_REFERENCE_SHA256",
  "MLX_BUN_TEST_EMBED_MAIN_SHA256"] as const;
const opted = optInAll(process.env, OPT_IN, "Embedding parity");

interface Meta {
  ids: number[]; seqLen: number; hidden: number; text: string; eod: number;
  oracle: { mlx: string; mlx_lm: string; config_sha256: string; blobs: Record<string, string> };
}
interface Main {
  mainRevision: string; weightsSha256: string; texts: string[]; instruction: string;
  documents: { tokens: number; vectorBase64: string }[]; queries: { tokens: number; vectorBase64: string }[]; counter: number;
}
const reference = opted?.MLX_BUN_TEST_EMBED_REFERENCE;
const meta = opted ? readPinnedJson<Meta>(join(reference!, "meta.json"), opted.MLX_BUN_TEST_EMBED_REFERENCE_SHA256, "oracle manifest") : null;
const main = opted ? readPinnedJson<Main>(join(reference!, "main-embed.json"), opted.MLX_BUN_TEST_EMBED_MAIN_SHA256, "main reference") : null;
const vectorOf = (base64: string) => float32Of(new Uint8Array(Buffer.from(base64, "base64")));

describe.skipIf(!opted)("qwen3-embedding vs mlx-lm and main", () => {
  setDefaultTimeout(600_000);
  let model: import("@mlx-bun/inference/embeddings").EmbeddingGraph & { forwardHidden(ids: import("@mlx-bun/mlx/array").MlxArray, cache: unknown[]): import("@mlx-bun/mlx/array").MlxArray; makeCache(): { dispose?(): void }[] };
  let tokenizer: Awaited<ReturnType<typeof import("@mlx-bun/inference").loadTokenizer>>;
  let terminator: number;
  let embeddings: typeof import("@mlx-bun/inference/embeddings");
  let ops: typeof import("@mlx-bun/mlx").ops;

  beforeAll(async () => {
    const dir = opted!.MLX_BUN_TEST_EMBED_MODEL;
    assert.equal(await fileSha256(join(dir, "model.safetensors")), main!.weightsSha256, "weights differ from main's reference");
    assert.equal(sha256(readFileSync(join(dir, "config.json"))), meta!.oracle.config_sha256, "config differs from the oracle's");
    const [inference, profiles, embedding, mlx] = await Promise.all([
      import("@mlx-bun/inference"), import("@mlx-bun/inference/models/profile"), import("@mlx-bun/inference/embeddings"),
      import("@mlx-bun/mlx"),
    ]);
    embeddings = embedding; ops = mlx.ops;
    const loaded = await inference.openModel(dir);
    assert(embedding.isEmbeddingModel(loaded), "the artifact's graph does not declare embeddings");
    model = loaded as typeof model;
    tokenizer = await inference.loadTokenizer(dir);
    const declaration = profiles.embeddingDeclarationFor(profiles.resolveModelProfile(await inference.loadModelConfig(dir)));
    assert(declaration, "the profile declares no embedding recipe");
    terminator = embedding.embeddingTerminatorId(tokenizer, declaration.terminator);
  });
  afterAll(() => (model as { dispose?(): void } | undefined)?.dispose?.());

  test("the oracle's hidden states and pooled vector are bit-exact", () => {
    expect(terminator).toBe(meta!.eod);
    const refHidden = float32Of(readBlob(reference!, "hidden.bin", meta!.oracle.blobs["hidden.bin"]));
    const refPooled = float32Of(readBlob(reference!, "pooled.bin", meta!.oracle.blobs["pooled.bin"]));
    const { seqLen: L, hidden: H } = meta!;
    expect(refHidden.length).toBe(L * H);
    expect(refPooled.length).toBe(H);
    // The tokenizer must produce the oracle's ids, so the text path is covered too.
    expect([...tokenizer.encode(meta!.text, false), terminator]).toEqual(meta!.ids);

    using ids = ops.fromInt32(meta!.ids, [1, meta!.ids.length]);
    const cache = model.makeCache();
    let ourHidden: Float32Array;
    try {
      using hidden = model.forwardHidden(ids, cache);
      expect(hidden.shape).toEqual([1, L, H]);
      ourHidden = hidden.toFloat32();
    } finally { for (const c of cache) c.dispose?.(); }
    using pooled = model.embedPooled(ids);
    expect(pooled.shape).toEqual([1, H]);
    const ourPooled = pooled.toFloat32();
    console.log(`[embedding] hidden mismatches ${countMismatch(ourHidden, refHidden).count}/${refHidden.length}, pooled ${countMismatch(ourPooled, refPooled).count}/${H}`);
    expect(countMismatch(ourHidden, refHidden)).toEqual({ count: 0, maxAbs: 0 });
    expect(countMismatch(ourPooled, refPooled)).toEqual({ count: 0, maxAbs: 0 });
  });

  for (const kind of ["documents", "queries"] as const) {
    test(`embedMany ${kind} are bit-exact with main and count once per text`, () => {
      const instruction = kind === "queries" ? main!.instruction : undefined;
      embeddings.resetEmbedCounter();
      const ours = embeddings.embedMany(model, tokenizer, terminator, main!.texts, instruction);
      expect(embeddings.getEmbedCounter()).toBe(main!.texts.length);
      expect(ours.map(r => r.tokens)).toEqual(main![kind].map(r => r.tokens));
      ours.forEach((r, i) => expect(countMismatch(r.vector, vectorOf(main![kind][i]!.vectorBase64))).toEqual({ count: 0, maxAbs: 0 }));
    });
  }

  test("the embed counter counts three texts as three and resets", () => {
    embeddings.resetEmbedCounter();
    expect(embeddings.getEmbedCounter()).toBe(0);
    embeddings.embedMany(model, tokenizer, terminator, ["a", "b", "c"]);
    expect(embeddings.getEmbedCounter()).toBe(3);
    embeddings.resetEmbedCounter();
    expect(embeddings.getEmbedCounter()).toBe(0);
  });
});
