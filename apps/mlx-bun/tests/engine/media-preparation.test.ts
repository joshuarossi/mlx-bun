// Family media routes with tiny real MLX tensors and fake towers — no model.
// They run wherever the MLX library resolves (CI stages it). They skip only in
// the CPU-only mode (MLX_BUN_LIBMLXC names a missing file) or in a checkout
// without staged natives; import and runtime errors always fail.
import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import type { ChatMessage, ChatTemplate } from "@mlx-bun/inference/input";
import type { CheckpointAttachment } from "@mlx-bun/inference/state";
import type { MediaRequest, MediaSource } from "../../src/engine/media-preparation";

const library = process.env.MLX_BUN_LIBMLXC ||
  join(dirname(Bun.resolveSync("@mlx-bun/mlx", import.meta.dir)), "../dist/native/libmlxc.dylib");
const nativeMissing = !existsSync(library);
const native = nativeMissing ? null : {
  media: await import("../../src/engine/media-preparation"),
  mlx: await import("@mlx-bun/mlx"),
};

const ids = { imageTokenId: 100, boiTokenId: 101, eoiTokenId: 102 };
const png = Buffer.from("not decoded by fake towers").toString("base64");
const riff = Buffer.from("RIFF\0\0\0\0WAVEfmt ").toString("base64");
const image = (url = `data:image/png;base64,${png}`) => ({ type: "image_url", image_url: { url } });
const user = (...content: Record<string, unknown>[]): ChatMessage[] => [{ role: "user", content } as ChatMessage];

function source(overrides: Partial<MediaSource> = {}): MediaSource {
  return {
    modelId: "fake", visionTokenIds: ids, audioTokenIds: null,
    tokenizer: { encode: () => [5, 100, 6], decode: () => "", idToToken: () => "", bosTokenId: null, eosTokenId: null },
    template: { render: () => "rendered" } as unknown as ChatTemplate,
    visionTower: () => null, audioTower: () => null,
    ...overrides,
  };
}

function request(messages: ChatMessage[], overrides: Partial<MediaRequest> = {}): MediaRequest & { optionsRead: () => number } {
  let reads = 0;
  const has = (types: string[]) => messages.some(m => Array.isArray(m.content) && m.content.some(p => types.includes(String(p.type))));
  return {
    messages,
    parts: { images: has(["image_url", "image"]), audio: has(["input_audio", "audio"]), videos: has(["video_url", "video"]) },
    tools: null,
    templateOptions: () => { reads++; return {}; },
    nativeWork: work => work(),
    optionsRead: () => reads,
    ...overrides,
  };
}

describe.skipIf(nativeMissing)("media preparation routes", () => {
  // Bound for the tests below; a skipped suite never reads them.
  const media = native?.media!, mlx = native?.mlx!;

  test("the binder selects each family's route once, from the concrete model", async () => {
    const { DiffusionGemmaModel } = await import("@mlx-bun/inference/models/diffusion-gemma");
    const { Qwen35Model } = await import("@mlx-bun/inference/models/qwen3_5");
    const { Qwen38TrellisTQ } = await import("@mlx-bun/inference/models/qwen38-27b-trellis-tq");
    const { Gemma4Model } = await import("@mlx-bun/inference/models/gemma4");
    const bind = (prototype: object) => media.bindMediaPreparation(source(), Object.create(prototype));
    const unreachable = user(image("http://127.0.0.1:9/never-fetched.png"));

    const diffusion = await bind(DiffusionGemmaModel.prototype);
    expect(diffusion.video).toBe(false);
    // The tower check precedes extraction: a URL that would fail to fetch is never read.
    expect(await diffusion.prepare(request(unreachable))).toEqual({ rejected: "vision-tower-absent" });

    for (const prototype of [Qwen35Model.prototype, Qwen38TrellisTQ.prototype]) {
      const qwen = await bind(prototype);
      expect(qwen.video).toBe(true);
      const call = request(user(image()));
      expect(await qwen.prepare(call)).toEqual({ rejected: "vision-sidecar-unavailable" });
      expect(call.optionsRead()).toBe(0);
    }

    for (const prototype of [Gemma4Model.prototype, Object.prototype]) {
      const towers = await bind(prototype);
      expect(towers.video).toBe(false);
      expect(await towers.prepare(request(user(image())))).toEqual({ rejected: "vision-sidecar-unavailable" });
      const audio = request(user({ type: "input_audio", input_audio: { data: riff, format: "wav" } }));
      expect(await towers.prepare(audio)).toEqual({ rejected: "audio-tower-unavailable" });
    }
  });

  test("tower routes extract media before consulting the tower, as the server did", async () => {
    const unsupported = user(image("ftp://example.invalid/image.png"));
    await expect(media.prepareTowerImages(source(), null, request(unsupported))).rejects.toThrow();
    const qwen = Object.create((await import("@mlx-bun/inference/models/qwen3_5")).Qwen35Model.prototype);
    await expect(media.prepareQwenMedia(source(), qwen, request(unsupported))).rejects.toThrow();
  });

  test("the audio route reports a missing vision tower for mixed input only after the audio tower", async () => {
    const embed = { embed: { encode: () => { throw new Error("must not embed"); } } };
    const mixed = user(image(), { type: "input_audio", input_audio: { data: riff, format: "wav" } });
    const withAudio = source({
      audioTokenIds: { audioTokenId: 200, boaTokenId: 201, eoaTokenId: 202 },
      audioTower: () => ({ cacheIdentity: "audio", embedScale: 1, features(): never { throw new Error("must not encode"); } }),
    });
    expect(await media.prepareAudio(withAudio, embed, request(mixed))).toEqual({ rejected: "vision-sidecar-unavailable" });
    expect(await media.prepareAudio(source(), embed, request(mixed))).toEqual({ rejected: "audio-tower-unavailable" });
  });

  test("DiffusionGemma accepts exactly one image and returns owned pixels with spliced ids", async () => {
    let pixels: import("@mlx-bun/mlx").MlxArray | undefined;
    const tower = { async preprocess() { pixels = mlx.ops.zeros([1, 3, 4, 4], mlx.Dtype.float32); return { pixels, softTokens: 2 }; } };
    expect(await media.prepareDiffusionImage(source(), () => tower, request(user(image(), image()))))
      .toEqual({ rejected: "single-image-only" });
    expect(pixels).toBeUndefined();
    const prepared = await media.prepareDiffusionImage(source(), () => tower, request(user(image())));
    if ("rejected" in prepared) throw new Error(prepared.rejected);
    expect(prepared.promptIds).toEqual([5, 101, 100, 100, 102, 6]);
    expect(prepared.pixels).toBe(pixels!);
    prepared.pixels!.eval();
    prepared.pixels!.dispose();
  });

  test("a failure while splicing DiffusionGemma pixels disposes them before it propagates", async () => {
    let pixels: import("@mlx-bun/mlx").MlxArray | undefined;
    const tower = { async preprocess() { pixels = mlx.ops.zeros([1, 3, 4, 4], mlx.Dtype.float32); return { pixels, softTokens: 2 }; } };
    const failing = source({ visionTokenIds: { get imageTokenId(): number { throw new Error("token ids unavailable"); }, boiTokenId: 101, eoiTokenId: 102 } });
    await expect(media.prepareDiffusionImage(failing, () => tower, request(user(image())))).rejects.toThrow("token ids unavailable");
    expect(() => pixels!.eval()).toThrow("after dispose");
  });

  test("encoder cache entries are borrowed: leases are released and stored features survive success and failure", async () => {
    const stored = new Map<string, CheckpointAttachment[]>();
    let leases = 0, released = 0, encoded = 0;
    const objects = {
      async take(key: string) {
        const value = stored.get(key);
        if (!value) return null;
        leases++;
        return { value, dispose() { released++; } };
      },
      put(key: string, value: CheckpointAttachment[]) { stored.set(key, value); },
    };
    const tower = {
      cacheIdentity: "tower-v1",
      async preprocess() { return { softTokens: 2 }; },
      features() { encoded++; return mlx.ops.zeros([1, 2, 4], mlx.Dtype.float32); },
    };
    const model = { embed: { encode: (input: import("@mlx-bun/mlx").MlxArray) => mlx.ops.zeros([1, input.shape[1]!, 4], mlx.Dtype.bfloat16) } };
    const route = source({ visionTower: () => tower });
    const storedFeatures = () => [...stored.values()][0]![0]!.tensors[0]!;
    const release = (prepared: Awaited<ReturnType<typeof media.prepareTowerImages>>) => {
      if ("rejected" in prepared) throw new Error(prepared.rejected);
      expect(prepared.promptIds).toEqual([5, 101, 100, 100, 102, 6]);
      expect(prepared.vision!.prefixIdentity).toBeString();
      prepared.vision!.embeddings.eval();
      prepared.vision!.embeddings.dispose();
      prepared.vision!.imageMask!.dispose();
    };

    release(await media.prepareTowerImages(route, model, request(user(image()), { objects })));
    expect({ encoded, stored: stored.size, leases, released }).toEqual({ encoded: 1, stored: 1, leases: 0, released: 0 });

    release(await media.prepareTowerImages(route, model, request(user(image()), { objects })));
    expect({ encoded, leases, released }).toEqual({ encoded: 1, leases: 1, released: 1 });
    storedFeatures().eval();

    let calls = 0;
    const failing = request(user(image()), { objects, nativeWork: async work => {
      if (++calls === 2) throw new Error("aborted during encode");
      return work();
    } });
    await expect(media.prepareTowerImages(route, model, failing)).rejects.toThrow("aborted during encode");
    expect({ encoded, leases, released }).toEqual({ encoded: 1, leases: 2, released: 2 });
    storedFeatures().eval();
    expect(storedFeatures().shape).toEqual([1, 2, 4]);
    for (const attachments of stored.values()) for (const attachment of attachments) for (const tensor of attachment.tensors) tensor.dispose();
  });
});
