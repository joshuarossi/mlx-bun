# mlx-bun v0.5.0

Whisper speech-to-text: transcription, dictation and voice input, bit-exact
against mlx-whisper and faster than both mlx-whisper and whisper.cpp on the
same clips.

- `mlx-community/whisper-large-v3-turbo` (any fp16 `mlx-community/whisper-*`)
  loads as a new encoder-decoder family. The oracle-parity graph matches
  mlx-whisper 0.4.3 bit-exactly on the mel spectrogram, the encoder output and
  every decoder logit; the default fast path (fused attention, fused cross-K/V,
  a compiled decoder step with device-side logit filters, pipelined greedy,
  in-graph beam top-k) is held to at most two differing tokens per clip. M1 Max,
  11 s clip: 340 ms greedy (mlx-whisper 371), 424 ms beam-5 (whisper.cpp 499).
- Decoding: greedy, sampling with the temperature fallback ladder, beam search
  (mlx-whisper has none; matches whisper.cpp's beam-5 transcripts), prompts and
  vocabulary hints fitted to the 223-token budget, language detection,
  translation, >30 s seek loop, word-level timestamps.
- `POST /v1/audio/transcriptions` and `/v1/audio/translations` (OpenAI shape,
  multipart or JSON, json/verbose_json/text/srt/vtt, SSE streaming) on every
  server, with Whisper loaded per take beside the chat model and released right
  after it; `mlx-bun serve <whisper model>` runs a transcription-only server.
- Streaming sessions (`/v1/audio/sessions`): audio uploaded while recording,
  every finished 30 s window transcribed during capture — a 62 s take returns
  327 ms after its last chunk.
- Silero VAD v6.2 gate (ported from the reference graph, verified against the
  pip package): silence returns an empty transcript without running Whisper;
  runs on the stream inside sessions.
- In-process audio decoding through AudioToolbox (3.7 ms for an 11 s mp3 vs
  72 ms via afconvert); any CoreAudio-readable container.
- `mlx-bun transcribe <file>` and `mlx-bun dictate` (push-to-talk from the
  microphone, print / clipboard / typed keystrokes; new `mlx-bun-mic-capture`
  sidecar), and a hold-to-talk mic in the web composer for any chat model.
- Measured and shelved: a Core ML encoder on the Neural Engine (3.3× slower
  than the GPU on the M1 Max); whisper.cpp-style encoder context truncation
  ships as an off-by-default Lab option.

Native pack `native-v0.5.0` adds the `mlx-bun-mic-capture` helper.
