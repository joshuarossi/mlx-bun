// T2 e2e audio parity (docs/design/audio-input-plan.md §3.4): fixture WAV →
// decodeAudio → USM mel → AudioTower → multimodal prompt builder (template
// render + <|audio|> → boa + audio×n + eoa splice + merged embeddings) →
// strictly-causal merged-embeddings prefill (per-layer id zeroing at audio
// positions, NO bidirectional mask — §3.3 Q1/Q2) → greedy decode.
//
// Bars (vs goldens/e4b-audio.json, scripts/gen-e4b-audio-golden.py):
//   - spliced prompt ids: EXACT (arbiter for template render + splice)
//   - soft-token count: EXACT (ceil(duration_ms/40) from DECODED samples)
//   - 32-token greedy stream: EXACT (unlike vision, the audio tower is
//     bit-exact — f32 activations over bf16 weights, tests/e4b-audio-tower —
//     so the full greedy stream must match, not just a prefix). The golden
//     generator prefills the whole prompt in ONE forward and reads the last
//     position's logits — exactly generate()'s promptEmbeddings path (no
//     tail split there), so no prefill-convention gap exists to absorb.
//   - decoded text: EXACT (specials kept, mirroring the oracle tok.decode)
//
// The merge numerics are oracle-mirrored in the builder: raw f32 embed_audio
// output → astype(bf16) → divide by a weak (bf16) embed_scale scalar — see
// src/vision/prompt.ts + AudioTower.features(preDivide).
//
// Skips without the e4b snapshot + sidecar or the golden manifest (the .bin
// blobs are NOT needed here — this tier runs our own decode→mel→tower chain).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { goldenAt } from "./goldens";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "./paths";

interface AudioFixture {
  wav: string;
  text: string;
  soft_tokens: number;
  input_ids: number[];
  greedy_ids: number[];
  decoded: string;
}
interface AudioGolden {
  token_ids: { boa: number; audio: number; eoa: number };
  fixtures: Record<string, AudioFixture>;
}

const haveWeights =
  (await snapshotE4bAvailable()) &&
  existsSync(`${SNAPSHOT_E4B}/optiq_vision.safetensors`);
const goldenFile = goldenAt("e4b-audio.json");
const haveGoldens = await goldenFile.exists();
const golden = haveGoldens ? ((await goldenFile.json()) as AudioGolden) : null;
const haveFixtures =
  golden !== null &&
  Object.values(golden.fixtures).every((f) => existsSync(f.wav));

describe.skipIf(!haveWeights || !haveGoldens || !haveFixtures)(
  "e4b audio parity (T2)",
  async () => {
    if (!haveWeights || !haveGoldens || !haveFixtures || !golden) return;

    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { Gemma4Model } = await import("../src/model/gemma4");
    const { AudioTower, parseAudioConfig } = await import("../src/audio/conformer");
    const { buildMultimodalPrompt } = await import("../src/vision/prompt");
    const { ChatTemplate } = await import("../src/chat-template");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { generate } = await import("../src/generate");

    const config = await loadModelConfig(SNAPSHOT_E4B);
    const weights = await Weights.open(SNAPSHOT_E4B);
    const model = new Gemma4Model(weights, config);
    const audioCfg = parseAudioConfig(config.raw.audio_config as Record<string, unknown>);
    const tower = AudioTower.load(SNAPSHOT_E4B, audioCfg, model.embedScale);
    const tokenizer = await loadTokenizer(SNAPSHOT_E4B);
    const template = await ChatTemplate.load(SNAPSHOT_E4B);
    const tokenIds = {
      audioTokenId: golden.token_ids.audio, // 258881
      boaTokenId: golden.token_ids.boa,     // 256000
      eoaTokenId: golden.token_ids.eoa,     // 258883
    };

    for (const [name, fx] of Object.entries(golden.fixtures)) {
      test(`${name}: spliced ids, greedy stream, and decode match oracle exactly`, async () => {
        const audioBytes = new Uint8Array(await Bun.file(fx.wav).arrayBuffer());
        const mp = await buildMultimodalPrompt(
          model, { audio: { tower, tokenIds } }, tokenizer, template,
          [{
            role: "user",
            content: [
              { type: "audio" as const },
              { type: "text" as const, text: fx.text },
            ],
          }] as never,
          [], [audioBytes],
        );

        // §3.3 Q1: audio prompts are strictly causal — no bidirectional mask
        expect(mp.bidirMask).toBeNull();
        // soft-token count exact (ceil(duration_ms/40), from decoded samples)
        const softCount = mp.ids.filter((id) => id === tokenIds.audioTokenId).length;
        expect(softCount).toBe(fx.soft_tokens);
        // spliced prompt ids bit-exact (template render + splice arbiter)
        expect(mp.ids).toEqual(fx.input_ids);

        // Greedy decode, gated EXACTLY against the oracle stream. The golden
        // includes its final EOS token; pass eosTokenIds:[] with maxTokens =
        // |golden| so generate() emits that token too instead of eating it —
        // greedy is deterministic, so equality over the full stream is the
        // same gate the oracle's stop-on-EOS loop produced.
        const gen = generate(model, mp.ids, {
          maxTokens: fx.greedy_ids.length,
          temperature: 0,
          eosTokenIds: [],
          promptEmbeddings: mp.embeddings,
          multimodalMask: mp.multimodalMask,
        });
        const out: number[] = [];
        for await (const t of gen) out.push(t.token);
        mp.embeddings.dispose();
        mp.multimodalMask.dispose();

        expect(out).toEqual(fx.greedy_ids);
        // decoded text exact (specials kept — the oracle used plain decode)
        expect(tokenizer.decode(out, false)).toBe(fx.decoded);
      }, 300_000);
    }
  },
);
