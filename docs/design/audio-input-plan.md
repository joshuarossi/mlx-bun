# Audio input — design & implementation plan (gemma-4 audio tower)

Status: **PLANNED** (survey done 2026-07-06, no code yet).
Scope: audio **understanding** — audio-in, text-out through the chat API.
TTS / STT-as-an-endpoint / STS stay out of scope (see
docs/design/omlx-adoption-map.md); §5 lists non-goals explicitly.

## 0. TL;DR

e4b ships a 12-block Conformer audio tower that we already have on disk —
the `optiq_vision.safetensors` sidecar in the local e4b OptiQ-4bit snapshot
contains 752 `audio_tower.*`/`embed_audio.*` tensors, and its `config.json`
carries the full `audio_config` plus the audio token ids. mlx-lm strips all
of this and rejects audio requests, so (as with vision) **the oracle is
optiq's internal machinery**, which is complete end-to-end but not exposed
by optiq's own serve frontend. The implementation is a fourth tower next to
`src/vision/{siglip,embedder,diffusion-vision}.ts`, reusing every existing
multimodal seam: sidecar lazy-load, `<|placeholder|>` splice, merged
embeddings into `forwardEmbeddings`, serial-lane routing. New primitives
needed: a `mlx_conv2d` binding (SSCP subsampler) and a small TS-side
mel-spectrogram extractor (USM pipeline). Everything else is pattern-match
on the vision port.

## 1. What the ancestors do (surveyed 2026-07-06, pinned oracle venv)

### mlx-lm 0.31.3 — nothing, and actively strips

- `models/gemma3n.py:602` and `models/gemma4.py:55` `sanitize()` pop
  `audio_tower`, `embed_audio` (and the vision keys) from the weights at
  load. The upstream capability is deliberately discarded.
- `server.py:118–150` `process_message_content()` raises
  `ValueError("Only 'text' content type is supported.")` for any non-text
  content part — `input_audio` requests hard-fail.
- No mel/spectrogram/feature code anywhere in the package; no mlx-vlm /
  mlx-audio / mlx-whisper installed in the oracle venv.

**Parity-tree consequence:** there is no mlx-lm arm for audio. Like the
vision port, correctness gates come from optiq's internals; anything no
ancestor does (e.g. ever batching audio requests) is novel territory →
KL + quality gates, not bit-parity (see three-tier doctrine in PLAN.md).

### mlx-optiq — complete machinery, unexposed at the serve layer

All under `optiq/vlm/_mlxvlm/models/gemma4/` in the oracle venv:

- **Feature extraction** (`audio_feature_extractor.py`,
  `Gemma4AudioFeatureExtractor`) — USM pipeline: 16 kHz mono input,
  frame 20 ms / hop 10 ms, magnitude STFT, 128 HTK-scale mel bins over
  0–8 kHz, `log(mel + 1e-3)` floor, optional per-bin mean/stddev
  normalization; `preemphasis=0.0`, `fft_overdrive=False`, `dither=0.0`
  by default. Runs CPU-side (numpy). Output
  `input_features [B,T,128]` + validity mask.
- **Tower** (`audio.py`, `AudioEncoder`) —
  `SubSampleConvProjection`: two Conv2d stages (channels `(128, 32)`,
  each 2× time stride) then linear to `hidden_size=1024`; then
  **12 Conformer blocks**: FF (residual_weight 0.5) → chunked local
  attention (chunk 12, left context 13 chunks, right 0, logit softcap
  50.0, invalid logits −1e9) → depthwise light Conv1d (kernel 5) → FF →
  clamp + RMSNorm; then output projection to `output_proj_dims=1536`.
  `use_clipped_linears=True`: linears clamp activations to recorded
  per-tensor `input_min/max`/`output_min/max` ranges (those stats ship in
  the sidecar — confirmed present in our local e4b sidecar).
- **Embedder** (`merge.py`, `MultimodalEmbedder`) — RMSNormNoScale +
  bias-free Linear into text hidden size; embeddings scattered into the
  input sequence at `audio_token_id` positions via `masked_scatter`
  (`gemma4.py get_input_embeddings`).
- **Tokens & splicing** (`processing_gemma4.py:264–299`) —
  `<|audio|>` expands to `boa + audio_token×n + eoa` with
  `n = min(ceil(duration_ms / 40), 750)` (40 ms/token, ≤30 s ≙ 750 soft
  tokens). Ids (confirmed in our local e4b config.json):
  `boa=256000`, `audio=258881`, `eoa=258883`.
- **Request parsing** (`processing_gemma4.py:690`) — accepts OpenAI-style
  parts `{"audio", "input_audio", "audio_url"}`.
- **Sidecar & quant policy** — `vlm/sidecar.py` extracts
  `audio_tower.*`/`embed_audio.*` into the same `optiq_vision.safetensors`
  as vision, kept **bf16**; `backends/mlx_backend.py:491` skips
  `audio_tower.` in the quantization predicate. Calibration recipe (and a
  worked example of driving the audio path programmatically):
  `calibration/datasets.py load_audio_calibration` (LibriSpeech clean).
- **The gap:** `vlm/gemma4/frontend.py` only wires **vision** into optiq
  serve; audio works only through the internal model class. Golden
  generation therefore scripts the internal model directly (the
  calibration loader shows exactly how) — same move as the vision port.

## 2. What we already have (verified on this machine, 2026-07-06)

- **e4b OptiQ-4bit** (snapshot `fcdb12…`): sidecar contains **752 audio
  tensors** (`audio_tower.*` + `embed_audio.*`, incl. clipped-linear
  min/max stats); `config.json` has `audio_config`
  (`model_type=gemma4_audio`, 12 layers, hidden 1024, heads 8, conv
  kernel 5, subsampling channels (128,32), logit cap 50, residual 0.5,
  `output_proj_dims=1536`, `use_clipped_linears=true`) plus
  `audio_token_id/boa_token_id/eoa_token_id`; `tokenizer_config.json` has
  `audio_token: "<|audio|>"`. **No download needed — audio-ready today.**
- **12B OptiQ-4bit**: `audio_config` present but the local sidecar holds
  only **1** audio tensor → needs a sidecar rebuild via optiq's
  `build_vision_sidecar` (its selective-download path pulls only the
  audio shards, not the full base model).
- **26B-A4B, DiffusionGemma, bf16 assistants**: no `audio_config` — no
  audio for these, ever (architecture, not a porting gap).
- **Vision pipeline is the template** — every seam already exists:
  content-part detection `src/server.ts:2234`, extraction + splice + merge
  `src/vision/prompt.ts`, lazy tower `src/server.ts:326–350`, sidecar
  detection `src/registry.ts:487` / `src/config.ts:287`, embeddings
  prefill `src/generate.ts:468` → `forwardEmbeddings`
  `src/model/gemma4.ts:876–896` (per-layer-input id zeroing + bidir mask).
- **FFI gaps**: `mlx_conv1d` is bound (`src/mlx/ffi.ts:173`, Qwen3.5
  DeltaNet, depthwise) but there is **no conv2d and no FFT** binding.
  SSCP needs conv2d; mel extraction needs an FFT (resolved TS-side, §3.1).

## 3. Design

### 3.1 New files (mirror of `src/vision/`)

- **`src/audio/decode.ts`** — WAV parser (PCM16/24/32/float32) → mono
  mix-down → resample to 16 kHz (windowed-sinc or linear; gate vs oracle
  resampler on the fixture). Non-WAV formats (mp3/m4a/flac/ogg): shell out
  to macOS `afconvert` (built into darwin, our only platform) to produce
  WAV — zero new dependencies. **Duration (and thus soft-token count) is
  computed from decoded samples**, so format never affects splicing.
- **`src/audio/features.ts`** — USM mel extractor, verbatim-semantics port
  of `audio_feature_extractor.py` (megakernel copy-verbatim methodology:
  match first, optimize never — this is ~100×128 floats, not a perf
  path). STFT frame 320 samples / hop 160 / FFT 512
  (`fft_overdrive=False`), 128 HTK mel bins 0–8 kHz, `log(x + 1e-3)`,
  per-bin normalization from shipped stats (open Q3). Implemented as a
  small radix-2 real FFT in TS, f64 accumulate → f32 out, CPU-side —
  exactly where optiq does it (numpy), keeping the mlx graph clean.
  *Considered and rejected for v1*: binding `mlx_fft_rfft` and doing it
  on-device — new binding surface for no perf need.
- **`src/audio/conformer.ts`** — the tower, bf16 mlx graph:
  - **needs `mlx_conv2d` binding** — read the full mlx.h signature first
    (trailing-optional-param → shifted stream arg hazard, CLAUDE.md).
  - SSCP: Conv2d(1→128) → Conv2d(128→32), each 2× time stride → linear
    to 1024 (exact shapes read from the sidecar weights).
  - 12 × ConformerBlock as in §1; chunked local attention implemented as
    an explicit dense additive mask (≤750 frames pre-subsample, ~188
    post — dense is trivially cheap at this size) with logit softcap 50
    and −1e9 invalid fill.
  - Clipped linears: clamp to shipped `input_min/max`/`output_min/max` —
    parity depends on this, port exactly (toggle test in A2).
  - Output proj → 1536, then `embed_audio` (RMSNormNoScale + Linear →
    text hidden), **pre-divided by embed_scale** — same convention as
    vision towers (`forwardEmbeddings` re-multiplies).
- **`src/audio/prompt.ts` folded into a shared multimodal prompt
  builder** — recommendation: generalize `src/vision/prompt.ts`
  (`buildVisionPrompt` → `buildMultimodalPrompt`) rather than add a
  parallel audio-only path, because one message can legally carry images
  AND audio and both must splice in document order. Vision-only and
  audio-only fall out as special cases; the vision goldens gate the
  refactor (spliced ids must stay byte-identical).

### 3.2 Server surface

- Accept OpenAI content parts:
  `{"type":"input_audio","input_audio":{"data":"<b64>","format":"wav"|"mp3"}}`
  (OpenAI canonical) plus optiq's `{"type":"audio"}` / `{"type":"audio_url"}`
  aliases. `hasAudio` detection lands next to `hasImages`
  (`src/server.ts:2234`).
- `getAudioTower(ctx)` lazy-loads next to `getVisionTower`
  (`src/server.ts:326–350`) — same sidecar file, separate tower object;
  text-only sessions never pay for it. Auto-enable on
  `audio_config` + sidecar audio tensors present, mirroring vision —
  **no new flags** (target surface: zero CLI delta).
- Routing: audio requests take the **serial lane**, same rule as vision —
  embeddings-prefill doesn't batch, and `promptEmbeddings` already
  excludes the pre-warmed prompt cache (`src/generate.ts:468`). Batching
  is a mode, not a fallback; batched audio has no oracle → if we ever
  want it, it goes through KL + quality gates as new territory.
- Anthropic-protocol endpoint: the Anthropic messages API has no audio
  input block type → clean 400 with a pointer to the OpenAI endpoint;
  documented.
- **Docs land in the SAME commit** (standing rule):
  `docs/reference/server-api.md` (content-part schema, ≤30 s / 750
  soft-token cap, 16 kHz mono internal format),
  `docs/reference/features-matrix.md` (audio row incl. serial-lane
  note), README capability line, `cli.md` only if a flag appears
  (target: none).

### 3.3 Open questions — RESOLVED against the oracle sources (2026-07-07)

1. **LM attention semantics for audio tokens: strictly CAUSAL.**
   `language.py:484–545 _make_masks`: the blockwise bidirectional overlay
   keys off `is_vision = (mm_token_type_ids == 1) | (== 2)` only — audio
   (type 3) never enters a block. Stronger: `use_bidirectional_vision`
   requires `not has_audio_tokens`, so **any audio token in the prompt
   disables the vision overlay entirely** (oracle comment: "Audio spans
   are sequential; keep mixed image+audio prompts causal"). mlx-bun rule:
   audio runs get NO bidir mask, and a mixed image+audio request drops
   the image bidir mask too — pass no bidir mask at all in that case.
2. **Per-layer-input zeroing: yes, audio included.** `gemma4.py:92–99`
   zeroes per-layer ids for the union mask
   `(ids==image_token) | (ids==audio_token) | (ids==video_token)`.
   Extend the existing image-mask zeroing in
   `src/model/gemma4.ts:876–896` to the combined multimodal mask.
3. **Per-bin mel stats: constructor defaults, no normalization.**
   `processing_gemma4.py:919–934`: standard HF checkpoints ship no
   `feature_extractor` key (our e4b snapshot has no
   processor_config.json at all) → `Gemma4AudioFeatureExtractor()` with
   defaults; "the USM parameters are fixed for all Gemma 4 models".
   `per_bin_mean/stddev = None` → that branch is dead for us. Also
   pinned there: `audio_seq_length` default 750, `audio_ms_per_token`
   default 40.
4. **boa/eoa are splice-side.** e4b `chat_template.jinja:301,334` emits
   bare `<|audio|>` for audio parts (both content shapes); the
   boa + audio×n + eoa expansion is processor-side — same ownership as
   vision's boi/eoi. Splice in our prompt builder, not the template.

### 3.4 Parity strategy (tree doctrine)

Oracle = optiq internal gemma4 model in the pinned venv, driven by
`scripts/regen-audio-goldens.py` (modeled on their calibration loader;
remember `enable_thinking` pinning for any templated prompt). Tiers follow
the e4b vision precedent exactly:

- **T0 model-free** (CI, no weights): WAV decode + mel features vs
  oracle-dumped golden (f32 tolerance ~1e-5 — DSP is deterministic);
  spliced ids **exact**; soft-token count **exact**.
- **T1 golden tower**: `audio_tower`+`embed_audio` output vs oracle,
  rel-RMSE gate (expect vision-like ~1% from bf16 composition; calibrate
  the threshold from the first honest run, don't invent it).
- **T2 e2e greedy** (`tests/e4b-audio.test.ts`): first-N greedy prefix
  match vs oracle + grounded-output check (speech fixture → transcript
  keyword present; chirp fixture → tone/beep mentioned).
- **T3 serve**: curl e2e with base64 `input_audio` against a running
  server (manual/gated; Josh runs servers).

Fixtures (tracked in `fixtures/`, tiny): (a) 1.6 s synthesized chirp WAV
(~50 KB, generated by a checked-in deterministic script), (b) ~2 s public
domain speech clip (LibriSpeech clean sample, ~64 KB). Goldens:
`goldens/e4b-audio.json` manifest tracked, `.bin` blobs regenerable and
untracked (goldens/README.md convention).

### 3.5 Perf & memory

Expectation (to be *measured*, not asserted): the tower is tiny —
≤750 mel frames → ~≤188 post-subsample positions × 12 layers × hidden
1024 bf16 — so added TTFT should be dominated by CPU feature extraction
plus one extra graph eval; sidecar RSS delta is the 752 bf16 tensors.
Every number that gets quoted comes from preflight-gated `benchmark.sh`
cells (tower ms, TTFT delta vs text-only, peak RSS delta) and lands in
`benchmarks/RESULTS.md`.

## 4. Work plan

**Phase A0 — groundwork**
- [ ] Bind `mlx_conv2d` (full header signature; CPU/GPU sanity test vs
      oracle conv output)
- [ ] `scripts/regen-audio-goldens.py` + fixtures; dump mel golden,
      tower-output golden, spliced ids, greedy ids
- [ ] Resolve open questions §3.3 (write the answers into this doc)
- Exit: goldens on disk; masking/zeroing semantics documented.

**Phase A1 — decode + features**
- [ ] `src/audio/decode.ts` (WAV + mono + resample; `afconvert` fallback)
- [ ] `src/audio/features.ts` USM mel port
- Exit: T0 green (mel within tolerance; token counts + spliced ids exact).

**Phase A2 — tower**
- [ ] `src/audio/conformer.ts` loads `audio_tower.*`/`embed_audio.*` from
      `optiq_vision.safetensors`; forward matches golden
- [ ] Clipped-linear toggle test (off → measurable divergence, on → gate)
- Exit: T1 rel-RMSE gate green.

**Phase A3 — prompt + LM integration**
- [ ] Generalize prompt builder (images + audio, document order);
      `<|audio|>` → `boa + audio×n + eoa`; vision goldens prove no
      regression
- [ ] Merged embeddings + mask; per-layer id zeroing per Q2;
      `forwardEmbeddings` path
- Exit: T2 green (`tests/e4b-audio.test.ts` greedy prefix + grounded).

**Phase A4 — serve + docs**
- [ ] `src/server.ts` audio branch, lazy tower, serial-lane routing,
      mixed image+audio request handled
- [ ] server-api.md / features-matrix.md / README same commit; Anthropic
      endpoint 400 documented
- Exit: T3 curl e2e; docs-map hygiene green.

**Phase A5 — bench + coverage**
- [ ] benchmark.sh cells → RESULTS.md (tower ms, TTFT delta, RSS delta)
- [ ] 12B audio cell: rebuild its sidecar via optiq `build_vision_sidecar`
      (selective download), own goldens — per-model doctrine, every
      (model, quant) cell gets its own validation or an explicit deferral
- [ ] features-matrix: audio×batching = serial documented
- Exit: numbers curated; e4b cell validated; 12B validated or deferred
  with reason.

Sizing: A0–A4 ≈ 3–4 focused sessions (the tower is the only genuinely new
model code; everything else is seam reuse); A5 ≈ 1.

## 5. Non-goals (v1)

- TTS, STS, and `/v1/audio/transcriptions`-style endpoints — a
  transcription shim over this same path is a cheap follow-up, noted, not
  committed.
- Streaming/real-time audio input.
- >30 s audio: cap at 750 soft tokens exactly as the oracle does.
- Video (`mm_token_type_ids=2`) — same seams, explicitly later.
- Audio for 26B-A4B / DiffusionGemma / bf16 assistants (no
  `audio_config` in those snapshots — architectural, not deferred work).
- Batched audio prefill (novel territory; serial lane only in v1).
