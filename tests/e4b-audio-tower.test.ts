// T1 audio-tower parity (docs/design/audio-input-plan.md §3.4): golden mel
// features → AudioTower (SSCP + 12 Conformer blocks + output_proj +
// embed_audio) → compare against the oracle's language-space embeddings.
//
// Inputs are the GOLDEN mel .bin blobs (not a fresh extraction) so the tower
// is gated in isolation from the 1-ulp mel noise (audio-features.test.ts owns
// that tier). The golden embed .bin is the embed_audio output in f32 BEFORE
// the /embed_scale pre-division (see scripts/oracle/gen-e4b-audio-golden.py — the
// divide happens at the T2 splice), while features() returns pre-divided
// (vision-tower convention), so the comparison re-multiplies by embedScale.
//
// Gate: rel-RMSE (‖got−want‖₂/‖want‖₂). Skips when the e4b snapshot, sidecar,
// or goldens (.bin blobs are untracked/regenerable) are absent.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import type { AudioTower as AudioTowerType } from "../src/audio/conformer";
import { goldenAt, goldenPath } from "./goldens";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "./paths";

interface AudioFixture {
  mel_bin: string;
  mel_shape: [number, number];
  embed_bin: string;
  embed_shape: [number, number];
  soft_tokens: number;
}
interface AudioGolden {
  fixtures: Record<string, AudioFixture>;
}

const haveWeights =
  (await snapshotE4bAvailable()) &&
  existsSync(`${SNAPSHOT_E4B}/optiq_vision.safetensors`);
const goldenFile = goldenAt("e4b-audio.json");
const haveGoldens = await goldenFile.exists();

// golden .bin blobs are machine-local and regenerable; resolve through the
// machine-override-aware goldenPath (manifest stores repo-relative paths).
const binPath = (p: string) => goldenPath(p.split("/").pop()!);
const golden = haveGoldens ? ((await goldenFile.json()) as AudioGolden) : null;
const haveBins =
  golden !== null &&
  Object.values(golden.fixtures).every(
    (f) => existsSync(binPath(f.mel_bin)) && existsSync(binPath(f.embed_bin)),
  );

// rel-RMSE achieved on the reference box (M4 Pro): ~2.4e-8 for BOTH fixtures
// — bit-exact vs the oracle up to the test's own /embedScale·embedScale f32
// roundtrip (maxAbsDiff ~1e-6 on O(10) values ≈ 1 f32 ulp). The audio tower
// runs f32 activations over bf16 weights (the oracle promotes), so unlike
// the vision encoder (~1%, bf16 activations + peaked softmax) there is no
// composition drift to absorb. Gate at 1e-6: ~40× margin over achieved,
// while any real divergence (wrong mask/layout/scale/op) lands at bf16 scale
// (≥1e-3) or worse.
const REL_RMSE_GATE = 1e-6;

function relRmse(got: Float32Array, want: Float32Array): number {
  let num = 0;
  let den = 0;
  for (let i = 0; i < want.length; i++) {
    const d = got[i]! - want[i]!;
    num += d * d;
    den += want[i]! * want[i]!;
  }
  return Math.sqrt(num / den);
}

function maxAbsDiff(got: Float32Array, want: Float32Array): number {
  let m = 0;
  for (let i = 0; i < want.length; i++)
    m = Math.max(m, Math.abs(got[i]! - want[i]!));
  return m;
}

describe.skipIf(!haveWeights || !haveGoldens || !haveBins)(
  "e4b audio tower parity (T1)",
  async () => {
    if (!haveWeights || !haveGoldens || !haveBins || !golden) return;

    const { AudioTower, parseAudioConfig } = await import("../src/audio/conformer");
    const ops = await import("../src/mlx/ops");

    const cfg = (await Bun.file(`${SNAPSHOT_E4B}/config.json`).json()) as {
      audio_config: Record<string, unknown>;
      text_config: { hidden_size: number };
    };
    const audioCfg = parseAudioConfig(cfg.audio_config);
    // embed_scale = sqrt(text hidden) — same value Gemma4Model.embedScale uses
    const embedScale = Math.sqrt(cfg.text_config.hidden_size);
    const tower = AudioTower.load(SNAPSHOT_E4B, audioCfg, embedScale);

    for (const [name, fx] of Object.entries(golden.fixtures)) {
      test(`${name}: tower output matches oracle embed_audio golden`, async () => {
        const mel = new Float32Array(
          await Bun.file(binPath(fx.mel_bin)).arrayBuffer(),
        );
        const want = new Float32Array(
          await Bun.file(binPath(fx.embed_bin)).arrayBuffer(),
        );
        const [frames, melBins] = fx.mel_shape;
        expect(mel.length).toBe(frames * melBins);

        const feats = tower.features(mel, frames); // [1, nSoft, 2560] /embedScale
        expect(feats.shape).toEqual([1, fx.embed_shape[0], fx.embed_shape[1]]);
        expect(feats.shape[1]).toBe(fx.soft_tokens);

        // golden reference point is BEFORE the embed_scale pre-division
        const unscaled = ops.mulScalar(feats, embedScale);
        feats.dispose();
        const got = unscaled.toFloat32();
        unscaled.dispose();

        const rms = relRmse(got, want);
        const mad = maxAbsDiff(got, want);
        console.log(
          `  ${name}: rel-RMSE ${rms.toExponential(3)}  maxAbsDiff ${mad.toExponential(3)}`,
        );
        expect(rms).toBeLessThan(REL_RMSE_GATE);
      }, 300_000);
    }

    test("chirp: bf16 splice features match the oracle tower output exactly", async () => {
      const fx = golden.fixtures.chirp!;
      const mel = new Float32Array(
        await Bun.file(binPath(fx.mel_bin)).arrayBuffer(),
      );
      const want = new Float32Array(
        await Bun.file(binPath(fx.embed_bin)).arrayBuffer(),
      );
      const { MlxArray } = await import("../src/mlx/array");
      const { Dtype } = await import("../src/mlx/ffi");

      // T2 consumes bf16(raw tower output) / bf16(embed_scale). Tiny f32
      // tower residuals are harmless only if they disappear at this actual
      // splice boundary; compare the bytes the language model receives.
      const gotRaw = tower.features(mel, fx.mel_shape[0], false);
      const gotBf = gotRaw.astype(Dtype.bfloat16);
      gotRaw.dispose();
      const refRaw = MlxArray.fromFloat32(want, [1, fx.embed_shape[0], fx.embed_shape[1]]);
      const refBf = refRaw.astype(Dtype.bfloat16);
      refRaw.dispose();
      const gotScale = ops.scalarLike(embedScale, gotBf);
      const refScale = ops.scalarLike(embedScale, refBf);
      const got = ops.div(gotBf, gotScale);
      const ref = ops.div(refBf, refScale);
      for (const a of [gotBf, refBf, gotScale, refScale]) a.dispose();

      const refRawBytes = ref.rawBytes();
      expect(got.rawBytes()).toEqual(refRawBytes);
      got.dispose();
      ref.dispose();
    }, 300_000);

    // A2 exit criterion: the clipped linears are load-bearing — running the
    // same weights with clipping disabled must diverge measurably MORE than
    // the clipped path (guards against silently never applying the stats).
    test("clipped linears are load-bearing (off → measurable divergence)", async () => {
      const [name, fx] = Object.entries(golden.fixtures)[0]!;
      const mel = new Float32Array(
        await Bun.file(binPath(fx.mel_bin)).arrayBuffer(),
      );
      const want = new Float32Array(
        await Bun.file(binPath(fx.embed_bin)).arrayBuffer(),
      );

      const run = (t: AudioTowerType): Float32Array => {
        const feats = t.features(mel, fx.mel_shape[0]);
        const unscaled = ops.mulScalar(feats, embedScale);
        feats.dispose();
        const got = unscaled.toFloat32();
        unscaled.dispose();
        return got;
      };

      const withClip = relRmse(run(tower), want);
      const noClipTower = AudioTower.load(
        SNAPSHOT_E4B, { ...audioCfg, useClippedLinears: false }, embedScale,
      );
      const noClip = relRmse(run(noClipTower), want);
      noClipTower.dispose();
      console.log(
        `  ${name}: rel-RMSE clipped ${withClip.toExponential(3)} vs unclipped ${noClip.toExponential(3)}`,
      );
      expect(noClip).toBeGreaterThan(withClip);
    }, 300_000);
  },
);
