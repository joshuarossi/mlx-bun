// Opt-in with real weights: media prompt preparation through a loaded model
// context, the server's buildModelPrompt, and a warm encoder cache. Runs only
// with MLX_BUN_TEST_NATIVE=1; each family runs when its cached snapshot is
// named, and loads the model natively on the GPU:
//   MLX_BUN_APP_TEST_GEMMA4_AUDIO_MODEL    Gemma4 SigLIP + audio (e2b / e4b OptiQ)
//   MLX_BUN_APP_TEST_GEMMA4_UNIFIED_MODEL  Gemma4 unified (12B OptiQ with its sidecar)
//   MLX_BUN_APP_TEST_QWEN_VISION_MODEL     Qwen3.8 with vision tensors (Trellis q4b, TQ)
//   MLX_BUN_APP_TEST_DIFFUSION_MODEL       DiffusionGemma with its vision tower
// Media is synthesized here (PNG, a sine WAV, and an ffmpeg test clip for
// video, which is skipped when ffmpeg is not on PATH); nothing is committed.
// It checks prompt shape, token splicing, tensor geometry, the loaded tower
// kind, and that a warm encoder cache reproduces every prompt tensor exactly
// (ids, prefix identity, embeddings, masks, mRoPE positions and delta,
// diffusion pixels). It is not generated text or oracle parity.
import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { BuiltPrompt } from "../../src/server/prompt-contracts";
import { pngBase64, tone, wavBytes } from "../support/media";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const models = {
  gemma4Audio: process.env.MLX_BUN_APP_TEST_GEMMA4_AUDIO_MODEL,
  gemma4Unified: process.env.MLX_BUN_APP_TEST_GEMMA4_UNIFIED_MODEL,
  qwenVision: process.env.MLX_BUN_APP_TEST_QWEN_VISION_MODEL,
  diffusion: process.env.MLX_BUN_APP_TEST_DIFFUSION_MODEL,
};
const ffmpeg = Bun.which("ffmpeg");
const scratch = mkdtempSync(join(tmpdir(), "mlx-bun-media-native-"));
afterAll(() => rmSync(scratch, { recursive: true, force: true }));

const png = pngBase64;
/** One second of 16-bit mono PCM at 16 kHz. */
const wav = (hz = 440) => Buffer.from(wavBytes(tone(1, hz))).toString("base64");

function clip(): string {
  const path = join(scratch, "clip.mp4");
  const run = Bun.spawnSync([ffmpeg!, "-loglevel", "error", "-y", "-f", "lavfi", "-i", "testsrc=duration=1:size=96x64:rate=4",
    "-pix_fmt", "yuv420p", path]);
  if (run.exitCode !== 0) throw new Error(`ffmpeg failed: ${run.stderr.toString()}`);
  return readFileSync(path).toString("base64");
}

const text = { type: "text", text: "Describe the media briefly." };
const image = (seed: number) => ({ type: "image_url", image_url: { url: `data:image/png;base64,${png(seed)}` } });
const audio = () => ({ type: "input_audio", input_audio: { data: wav(), format: "wav" } });
const video = () => ({ type: "video_url", video_url: { url: `data:video/mp4;base64,${clip()}` } });

const sha = (data: Uint8Array) => new Bun.CryptoHasher("sha256").update(data).digest("hex");
/** Reads the tensor back; boolean masks are widened to uint8 first. */
async function bytes(tensor: MlxArray | null | undefined): Promise<string | null> {
  if (!tensor) return null;
  const { Dtype } = await import("@mlx-bun/mlx");
  if (tensor.dtype !== Dtype.bool) return sha(tensor.rawBytes());
  const widened = tensor.astype(Dtype.uint8);
  try { return sha(widened.rawBytes()); } finally { widened.dispose(); }
}
/** Everything a prepared prompt hands the engine, read back. */
async function fingerprint(built: BuiltPrompt) {
  const vision = built.vision;
  return {
    ids: built.promptIds, prefix: vision?.prefixIdentity ?? null,
    embeddings: await bytes(vision?.embeddings), imageMask: await bytes(vision?.imageMask),
    multimodalMask: await bytes(vision?.multimodalMask), pixels: await bytes(built.diffusionPixels),
    mrope: vision?.mrope ? { delta: vision.mrope.delta,
      positions: vision.mrope.positions.map(axis => sha(new Uint8Array(axis.buffer, axis.byteOffset, axis.byteLength))) } : null,
  };
}
const runs = (ids: number[], token: number) => ids.filter(id => id === token).length;

/** One loaded context per family, prepared through the server's builder with a
 * shared in-memory object store, so a repeated request reads the encoder cache. */
async function family(modelDir: string) {
  const { loadContext } = await import("../../src/engine/model-host");
  const { buildModelPrompt } = await import("../../src/server/media-prompt");
  const { createRequestPrep } = await import("../../src/server/request-prep");
  const { RequestOwnership } = await import("../../src/server/request-plan");
  const ctx: LoadedModelContext = await loadContext(modelDir);
  const prep = createRequestPrep({ ctx, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined });
  const store = new Map<string, import("@mlx-bun/inference/state").CheckpointAttachment[]>();
  let leases = 0, released = 0;
  const objects = {
    async take(key: string) { const value = store.get(key); if (!value) return null; leases++; return { value, dispose() { released++; } }; },
    put(key: string, value: import("@mlx-bun/inference/state").CheckpointAttachment[]) { store.set(key, value); },
  };
  return {
    ctx, store, cache: () => ({ leases, released }),
    /** Build, hand the tensors to `inspect`, then release them as the server would. */
    async build(content: unknown[], inspect: (built: BuiltPrompt) => void | Promise<void>) {
      const ownership = new RequestOwnership();
      try {
        const built = await buildModelPrompt(ctx, prep, { messages: [{ role: "user", content }] } as never, null, ownership, undefined, objects);
        ownership.own(built.vision?.embeddings); ownership.own(built.vision?.imageMask);
        ownership.own(built.vision?.multimodalMask); ownership.own(built.diffusionPixels);
        await inspect(built);
      } finally { ownership.dispose(); }
    },
    close() {
      for (const value of store.values()) for (const attachment of value) for (const tensor of attachment.tensors) tensor.dispose();
      ctx.dispose();
    },
  };
}

/** Cold then warm: the warm pass reads the encoder cache and reproduces every
 *  prompt tensor exactly, including masks and mRoPE positions. */
async function coldWarm(f: Awaited<ReturnType<typeof family>>, content: unknown[], check: (built: BuiltPrompt) => void) {
  let cold: Awaited<ReturnType<typeof fingerprint>> | undefined;
  await f.build(content, async built => { check(built); cold = await fingerprint(built); });
  const before = f.cache();
  await f.build(content, async built => { check(built); expect(await fingerprint(built)).toEqual(cold!); });
  const after = f.cache();
  expect(after.leases).toBeGreaterThan(before.leases);
  expect(after.released - before.released).toBe(after.leases - before.leases);
}

const embeddingShape = (built: BuiltPrompt) => {
  const shape = built.vision!.embeddings.shape;
  expect(shape.length).toBe(3);
  expect(shape[0]).toBe(1);
  expect(shape[1]).toBe(built.promptIds.length);
  expect(built.startInThinking).toBe(false);
  expect(built.probeStableLen).toBe(false);
  expect(built.vision!.prefixIdentity).toBeString();
};

describe.skipIf(!native || !models.gemma4Audio)("Gemma4 SigLIP and audio", () => {
  test("image, audio and mixed prompts splice their soft tokens and reuse the encoder cache", async () => {
    const f = await family(models.gemma4Audio!);
    try {
      const v = f.ctx.visionTokenIds!, a = f.ctx.audioTokenIds!;
      expect(a).not.toBeNull();
      expect(f.ctx.model.config.raw.vision_config).toMatchObject({ model_type: "gemma4_vision" });
      await coldWarm(f, [text, image(3)], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, v.boiTokenId)).toBe(1);
        expect(runs(built.promptIds, v.imageTokenId)).toBeGreaterThan(0);
        expect(built.vision!.imageMask!.shape).toEqual([built.promptIds.length]);
      });
      const { SiglipVisionTower } = await import("@mlx-bun/inference/models/vision/siglip");
      const { AudioTower } = await import("@mlx-bun/inference/models/audio/conformer");
      expect(f.ctx.vision).toBeInstanceOf(SiglipVisionTower);
      await coldWarm(f, [text, audio()], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, a.boaTokenId)).toBe(1);
        expect(runs(built.promptIds, a.audioTokenId)).toBeGreaterThan(0);
        expect(built.vision!.imageMask).toBeUndefined();
        expect(built.vision!.multimodalMask!.shape).toEqual([built.promptIds.length]);
      });
      expect(f.ctx.audio).toBeInstanceOf(AudioTower);
      await coldWarm(f, [text, image(3), audio()], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, v.boiTokenId)).toBe(1);
        expect(runs(built.promptIds, a.boaTokenId)).toBe(1);
        // Mixed prompts run fully causal: no bidirectional image mask.
        expect(built.vision!.imageMask).toBeUndefined();
      });
      await f.build([text, image(3), image(7)], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, v.boiTokenId)).toBe(2);
      });
    } finally { f.close(); }
  }, 600_000);
});

describe.skipIf(!native || !models.gemma4Unified)("Gemma4 unified vision", () => {
  test("images splice through the encoder-free tower and reuse the encoder cache", async () => {
    const f = await family(models.gemma4Unified!);
    try {
      const v = f.ctx.visionTokenIds!;
      expect(f.ctx.model.config.raw.vision_config).toMatchObject({ model_type: "gemma4_unified_vision" });
      await coldWarm(f, [text, image(3)], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, v.boiTokenId)).toBe(1);
        expect(built.vision!.imageMask!.shape).toEqual([built.promptIds.length]);
      });
      const { VisionTower } = await import("@mlx-bun/inference/models/vision/unified");
      expect(f.ctx.vision).toBeInstanceOf(VisionTower);
    } finally { f.close(); }
  }, 600_000);
});

describe.skipIf(!native || !models.qwenVision)("Qwen3.8 vision", () => {
  const ids = (ctx: LoadedModelContext) => {
    const raw = ctx.model.config.raw;
    return { image: (raw.image_token_id as number) ?? 248056, video: (raw.video_token_id as number) ?? 248057 };
  };
  const mrope = (built: BuiltPrompt) => {
    const state = built.vision!.mrope!;
    expect(state.positions).toHaveLength(3);
    for (const axis of state.positions) expect(axis.length).toBe(built.promptIds.length);
    expect(Number.isInteger(state.delta)).toBe(true);
  };

  test("images carry mRoPE positions and reuse the encoder cache", async () => {
    const f = await family(models.qwenVision!);
    try {
      const { image: imageToken } = ids(f.ctx);
      await coldWarm(f, [text, image(3)], built => {
        embeddingShape(built);
        mrope(built);
        expect(runs(built.promptIds, imageToken)).toBeGreaterThan(0);
      });
      const { Qwen3VLVisionTower } = await import("@mlx-bun/inference/models/vision/qwen3vl");
      expect(f.ctx.vision).toBeInstanceOf(Qwen3VLVisionTower);
    } finally { f.close(); }
  }, 600_000);

  test.skipIf(!ffmpeg)("video frames splice with mRoPE positions (needs ffmpeg to synthesize the clip)", async () => {
    const f = await family(models.qwenVision!);
    try {
      const { image: imageToken, video: videoToken } = ids(f.ctx);
      await coldWarm(f, [text, video()], built => {
        embeddingShape(built);
        mrope(built);
        expect(runs(built.promptIds, videoToken)).toBeGreaterThan(0);
      });
      await f.build([text, image(3), video()], built => {
        embeddingShape(built);
        expect(runs(built.promptIds, imageToken)).toBeGreaterThan(0);
        expect(runs(built.promptIds, videoToken)).toBeGreaterThan(0);
      });
    } finally { f.close(); }
  }, 600_000);
});

describe.skipIf(!native || !models.diffusion)("DiffusionGemma vision", () => {
  test("one image becomes owned pixels and a spliced soft-token run, reproduced exactly", async () => {
    const f = await family(models.diffusion!);
    try {
      const v = f.ctx.visionTokenIds!;
      const prepared: Awaited<ReturnType<typeof fingerprint>>[] = [];
      for (let pass = 0; pass < 2; pass++) await f.build([text, image(3)], async built => {
        expect(built.vision).toBeUndefined();
        expect(built.diffusionPixels!.shape.length).toBe(4);
        expect(built.diffusionPixels!.shape[0]).toBe(1);
        expect(runs(built.promptIds, v.boiTokenId)).toBe(1);
        expect(runs(built.promptIds, v.imageTokenId)).toBeGreaterThan(0);
        prepared.push(await fingerprint(built));
      });
      expect(prepared[0]!.pixels).toBeString();
      expect(prepared[1]).toEqual(prepared[0]!);
      await expect(f.build([text, image(3), image(7)], () => {})).rejects.toThrow("exactly one image");
    } finally { f.close(); }
  }, 900_000);
});
