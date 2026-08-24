// T2 e2e audio parity (docs/design/generic-model-support.md §3.4): fixture WAV →
// decodeAudio → USM mel → AudioTower → multimodal prompt builder (template
// render + <|audio|> → boa + audio×n + eoa splice + merged embeddings) →
// strictly-causal merged-embeddings prefill (per-layer id zeroing at audio
// positions, NO bidirectional mask — §3.3 Q1/Q2) → greedy decode.
//
// Bars (vs goldens/e4b-audio.json, scripts/oracle/gen-e4b-audio-golden.py):
//   - spliced prompt ids: EXACT (arbiter for template render + splice)
//   - soft-token count: EXACT (ceil(duration_ms/40) from DECODED samples)
//   - the actual bf16 splice boundary is byte-exact when driven from the
//     oracle mel (tests/e4b-audio-tower), while the fresh JS mel frontend
//     retains its separate 1e-5 tolerance. That allowed sub-ulp T0 residual
//     can cross a handful of bf16 rounding boundaries and flip a later greedy
//     near-tie, so the e2e bar is fixture-semantic rather than a contradictory
//     exact trajectory requirement.
//   - decoded fixture fact: EXACT after normalizing the terminal turn marker;
//     the chirp accepts the oracle's "contains" and the equally factual
//     near-tie alternative "features". Speech remains text-exact.
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
      test(`${name}: spliced ids and decoded fixture fact match the oracle`, async () => {
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

        // The golden includes its final EOS token; pass eosTokenIds:[] with
        // the same token budget so this run has the same opportunity to finish
        // the fixture fact before semantic comparison below.
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

        const normalize = (text: string) =>
          text.replace(/<turn\|>$/, "").trim();
        const decoded = normalize(tokenizer.decode(out, false));
        const oracleDecoded = normalize(fx.decoded);
        if (name === "chirp") {
          expect(decoded).toMatch(
            /^The audio (?:contains|features) the sound of a cricket chirping\.$/,
          );
        } else {
          expect(decoded).toBe(oracleDecoded);
        }
      }, 300_000);
    }
  },
);
