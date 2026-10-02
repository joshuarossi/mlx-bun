// Server media policy over a fake family capability: which requests reach it,
// what it receives, the HTTP errors for its refusals, and the prompt shape.
// Family routes and their tensor ownership are covered in tests/engine/media-preparation.test.ts.
import { expect, test } from "bun:test";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { ChatRequestParams } from "../../src/server/chat-request";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { MediaPreparation, MediaRejection, MediaRequest } from "../../src/engine/media-preparation";
import type { RequestPrep } from "../../src/server/request-prep";
import type { RequestOwnership } from "../../src/server/request-plan";
import { buildModelPrompt } from "../../src/server/media-prompt";
import { RequestError } from "../../src/server/pipeline";

function fixture(media: Partial<MediaPreparation> = {}, template: unknown = { render: () => "" }) {
  const calls: MediaRequest[] = [];
  let optionReads = 0;
  const ctx = {
    modelId: "fake/model", template,
    media: { video: false, async prepare(request: MediaRequest) { calls.push(request); return { promptIds: [1] }; }, ...media },
  } as unknown as LoadedModelContext;
  const prep = {
    templateOptionsFor: () => { optionReads++; return { enableThinking: true }; },
    promptIdsFor: () => ({ ids: [9, 9], startInThinking: true }),
  } as unknown as RequestPrep;
  const build = (messages: unknown[], nativeWork?: Parameters<typeof buildModelPrompt>[5], objects?: Parameters<typeof buildModelPrompt>[6]) =>
    buildModelPrompt(ctx, prep, { messages } as ChatRequestParams, null, {} as RequestOwnership, nativeWork, objects);
  return { calls, build, optionReads: () => optionReads };
}

const part = (type: string) => ({ role: "user", content: [{ type, [type]: { url: "data:," } }] });

test("a model without a chat template fails before any media policy", async () => {
  const f = fixture({ video: true }, null);
  await expect(f.build([part("video_url")])).rejects.toThrow("model fake/model has no chat template");
  expect(f.calls).toHaveLength(0);
});

test("video is refused before the family route unless the model accepts it, and never with audio", async () => {
  const refuse = async (f: ReturnType<typeof fixture>, messages: unknown[], message: string) => {
    const error = await f.build(messages).catch((e: unknown) => e);
    expect(error).toBeInstanceOf(RequestError);
    expect((error as RequestError).status).toBe(400);
    expect((error as RequestError).message).toBe(message);
    expect(f.calls).toHaveLength(0);
  };
  await refuse(fixture(), [part("video_url")],
    "model fake/model does not accept video input — video content parts need a Qwen3.5-family model (e.g. Qwen3.8-27B)");
  await refuse(fixture({ video: true }), [part("video"), part("input_audio")], "video and audio content parts cannot be combined");
  const accepted = fixture({ video: true });
  await accepted.build([part("video_url")]);
  expect(accepted.calls[0]!.parts).toEqual({ images: false, audio: false, videos: true });
});

test("the family route receives normalized messages, the request's parts and the preparation seams", async () => {
  const f = fixture();
  const nativeWork = async <T>(work: () => Promise<T>) => work();
  const objects = { take: async () => null, put() {} };
  await f.build([{ role: "developer", content: "rules" }, part("image_url"), part("input_audio")], nativeWork, objects);
  const [call] = f.calls;
  expect(call!.messages[0]!.role).toBe("system");
  expect(call!.parts).toEqual({ images: true, audio: true, videos: false });
  expect(call!.tools).toBeNull();
  expect(call!.nativeWork).toBe(nativeWork);
  expect(call!.objects).toBe(objects);
  expect(f.optionReads()).toBe(0);
  expect(call!.templateOptions()).toEqual({ enableThinking: true });
  expect(f.optionReads()).toBe(1);
});

test("each family refusal answers with the server's 400 text", async () => {
  const expected: Record<MediaRejection, string> = {
    "audio-tower-unavailable": "model fake/model has no audio tower — audio input needs a model whose config.json " +
      "carries audio_config and whose sidecar ships the audio tensors (e.g. gemma-4 e4b OptiQ)",
    "vision-sidecar-unavailable": "model has no vision sidecar",
    "vision-tower-absent": "this checkpoint has no vision tower",
    "single-image-only": "DiffusionGemma image input supports exactly one image",
    "vision-tokens-undeclared": "model fake/model declares no image soft tokens",
  };
  for (const [rejected, message] of Object.entries(expected)) {
    const f = fixture({ async prepare() { return { rejected: rejected as MediaRejection }; } });
    const error = await f.build([part("image_url")]).catch((e: unknown) => e);
    expect(error).toBeInstanceOf(RequestError);
    expect({ status: (error as RequestError).status, message: (error as RequestError).message }).toEqual({ status: 400, message });
  }
});

test("prepared media becomes a non-probing prompt; pixels travel as diffusion pixels", async () => {
  const embeddings = {} as MlxArray, pixels = {} as MlxArray;
  const vision = fixture({ async prepare() { return { promptIds: [4, 5], vision: { embeddings } }; } });
  expect(await vision.build([part("image_url")])).toEqual({
    promptIds: [4, 5], vision: { embeddings }, startInThinking: false, probeStableLen: false, diffusionPixels: null,
  });
  const diffusion = fixture({ async prepare() { return { promptIds: [6], pixels }; } });
  const built = await diffusion.build([part("image_url")]);
  expect(built.vision).toBeUndefined();
  expect(built.diffusionPixels).toBe(pixels);
});

test("content parts that are not media keep the text path", async () => {
  const f = fixture();
  expect(await f.build([{ role: "user", content: [{ type: "text", text: "hi" }, { type: "refusal" }] }])).toEqual({
    promptIds: [9, 9], vision: undefined, startInThinking: true, probeStableLen: true, diffusionPixels: null,
  });
  expect(f.calls).toHaveLength(0);
});
