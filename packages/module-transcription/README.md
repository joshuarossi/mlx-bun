# @mlx-bun/module-transcription

Speech-to-text with a local Whisper model, as an application module
(`AppModule<"modelHost" | "catalog">`, design: [Modular application](../../ARCHITECTURE.md#modular-application)).
It declares the audio routes, the `transcribe` and `dictate` verbs and no jobs,
sockets, storage entries or panel. The mlx-bun app installs it beside its other
features; `apps/transcribe` installs it alone. Nothing here imports an app or
another module: the Whisper weights, their residency and the execution lock come
from the host's `modelHost` service, and model names from its `catalog`.

## Audio transcription

`src/service.ts` is main's `TranscriptionService` over a Whisper model the host
leases: each take leases it for as long as it runs, requests queue FIFO, and
every decode call runs under the host's execution lock (the full app passes the
generation gateway's), so decoding never overlaps chat generation. Residency is
the host's `modelHost` policy: the weights load on the first lease and, by
default, are released right after the last one; `--whisper-idle-unload <s>`
keeps them that long, `--whisper-resident` pins them, and the next take pages
them back in from the OS file cache. `mlx_bun.timings.load_ms` in every response
is non-zero exactly when that request paged the weights in. The Whisper model
host (lazy load, idle timer, pinning, unload, close) is
`@mlx-bun/app-services`' `createWhisperModelHost`, over the library's public
`openWhisperModel`, `loadWhisperTokenizer` and `WhisperTranscriber`; the
service keeps request admission, the Silero speech gate, vocabulary hints and
streaming sessions. The speech gate and audio decoding are `MediaRuntime`,
which the [service tests](tests/service.test.ts) replace, over the real model
host and a fake backend, to prove the lifecycle (lazy load, idle timer,
resident mode, unload-after-take, FIFO takes, sessions, close) with a fake clock
and no weights. The module also loads the Silero gate (about 1 MB, resident once
loaded) itself through the inference library, as it decodes audio, rather than
leasing it.

`src/routes.ts` handles main's speech-to-text surface, declared in `src/manifest.ts` at their exact shipped paths (`mount: "root"`):
`POST /v1/audio/transcriptions` and `POST /v1/audio/translations` (multipart
`file` or JSON base64/`data:` URL; `language`, `prompt`, `response_format`
`json` | `verbose_json` | `text` | `srt` | `vtt`, `temperature`, `stream`
server-sent events, `timestamp_granularities[]`, and main's non-standard
`beam_size`, `vocabulary`, `condition_on_previous_text`, `no_speech_threshold`,
`without_timestamps`, `vad`/`vad_threshold`/`vad_min_speech_ms`/`vad_trim`,
`faithful`, `audio_ctx`); streaming dictation sessions (`POST /v1/audio/sessions`,
`POST /v1/audio/sessions/<id>/audio` with `audio/pcm;rate=16000` float32 or any
CoreAudio container, `POST /v1/audio/sessions/<id>/finish`,
`DELETE /v1/audio/sessions/<id>`; unknown ids 404, a finished session 409, more
than 64 open sessions 429); and `POST /admin/transcription/unload`, which pages
the weights out and returns `unloaded` with the stats block (`resident`, `loads`,
`unloads`, `requests`, `last_load_ms`, `idle_unload_sec`). Errors keep main's
statuses: 400 for fields, undecodable audio, and clips under 0.1 s; 415 for the
content type; 499 on client cancel; 503 `model_unavailable` with the
`mlx-bun get` hint when no Whisper checkpoint is on disk. The host mounts the
routes; a request none of them matches falls through to the host's own.

The host resolves the checkpoint: the model host's default for `transcribe` is
the `--whisper-model <path|query>` checkpoint (refused before loading if it is
not a Whisper model), else the first downloaded `whisper` checkpoint, looked up
once, on the first audio request (as in main, a checkpoint downloaded later
needs a restart). The transcription-only server (`mlx-bun serve <whisper
checkpoint>`, and `apps/transcribe`'s `serve`) is the audio routes plus `/v1`,
`/v1/models`, `/health` and `/stats` (`createCompanionInfoRoutes`; the last two
carry the `transcription` stats block: residency counters from the model host,
`requests` and `sessions` from the module's `status()`), with no chat model,
prompt cache, jobs or web app; `--preload` loads the weights before the
listener binds. The [route tests](tests/routes.test.ts) cover parsing, every
response format, streaming and sessions over the real service with a fake
runtime; the [module test](tests/module.test.ts) loads the manifest through
`@mlx-bun/app-host` (requires only `modelHost` and `catalog`, routes at the
root, verbs, counters). The opt-in [transcription
test](../../apps/mlx-bun/tests/engine/transcription.test.ts)
(`MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_WHISPER_MODEL=<snapshot directory>`)
serves a real checkpoint through the app, transcribes a synthesized tone, and
pages the weights out through the unload route; transcript parity against
mlx-whisper is the library's contract, not this app check. The opt-in
[transcription parity test](../../apps/mlx-bun/tests/engine/transcription-parity.test.ts)
repeats the served surface on real speech and requires the oracle's transcripts
for the same audio; its references and results are in the
[inference README](../inference/README.md#speech-and-embedding-parity), which
also covers the `/v1/embeddings` counterpart.

`transcribe <audio-file> [query]` is main's one-shot speech-to-text verb over
the same service, no server; the host parses its options against the manifest
and the verb releases the weights right after the take. The clip is read and decoded (WAV
through the exact PCM parser, anything CoreAudio reads through AudioToolbox)
before any model is resolved, so a bad file never opens the registry. The
model is `--model`, else the second positional, else `--query`, else the first
downloaded `whisper` checkpoint (the `mlx-bun get` hint when none).
`--language`, `--task translate`, `--beam-size`, `--temperature`,
`--no-fallback`, `--prompt`, `--no-timestamps`, `--no-condition`,
`--word-timestamps`, `--faithful`, and `--audio-ctx` keep main's decoding
policy (the `(0, 0.2, …, 1.0)` fallback ladder unless a temperature or
`--no-fallback` is given). `--vad` (with `--vad-threshold` and `--vad-model`)
prints an empty result and never loads Whisper when the Silero gate finds no
speech; `--vad-trim` is accepted without cropping, as in main. `--format` is
`text` (default) | `json` | `verbose_json` | `srt` | `vtt`; `--verbose` prints
each segment as it decodes and a realtime summary on stderr. SIGINT aborts the
decode or the take, releases the weights, and exits 1. The file CLI accepts
clips under 0.1 s, as main did; HTTP keeps its existing minimum duration.

`dictate [query]` is main's push-to-talk loop. `src/mic-capture.ts` spawns the
AVAudioEngine sidecar (`native/mic-capture.swift` →
`mlx-bun-mic-capture`: 16 kHz mono float32 PCM on stdout; `ready`, `hotkey
down`, `hotkey up`, and `error:` lines on stderr; macOS asks for Microphone
permission on first use), resolved from `MLX_BUN_MIC_CAPTURE`, beside the
standalone executable, or this package's `dist/native/`. Source checkouts stage it
explicitly with `bun run --filter @mlx-bun/module-transcription build:native`
(requires swiftc); `prepack` builds it into the published artifact and the
standalone bundle copies it beside the executable. Runtime never compiles helpers.
Enter starts and stops a take (`q` or
Ctrl-C quits); `--hotkey [keycode]` holds a key instead (default 61, Right
Option; needs Input Monitoring). Every 250 ms of audio feeds a transcription
session while you speak, so the text lands about one window after the take
ends, and the Silero gate keeps silence from running Whisper (`--no-vad` skips
it and, unlike main, does not load its weights). The transcript prints;
`--copy` pipes it to `pbcopy`; `--type` sends System Events keystrokes after
`--type-delay` (1 s in Enter mode, 0 with `--hotkey`; needs Accessibility).
The backend is the in-process service with `--idle-unload <s>` (default 30;
0 = release after every take; the weights stay loaded from `ready` until the first
take holds them) and `--resident`, or `--server <url>` for a
running server's `/v1/audio/sessions`. Stopping ends the sidecar's stdin,
terminates it, joins it (SIGKILL after two seconds), and only then releases
the weights. It cancels and joins session requests and active transcription,
cleans up the open session, and prevents delayed copying or typing after
cancellation. Ctrl-C exits 0, as in main.

The [transcribe tests](tests/transcribe.test.ts) and
[dictate tests](tests/dictate.test.ts) run both verbs over the real service
with a fake runtime and a fake capture source (generated WAV and PCM,
every format, chunked feeding, the VAD gate, residency, delivery, the server
backend, cancellation joining the capture before the weights release); the
app's spawned-CLI tests (`apps/mlx-bun/tests/transcribe-cli.test.ts`,
`dictate-cli.test.ts`) cover help and error paths, and run against the
installed artifact in `verify-packages --app-only`. The
[mic capture tests](tests/mic-capture.test.ts) cover resolution, the
sidecar protocol, and the terminate-and-join with shell stand-ins. A real
microphone is exercised only by hand; package and relocated-bundle verification
resolve the shipped helper and run `--help` before any audio initialization.
The opt-in [voice test](../../apps/mlx-bun/tests/engine/voice.test.ts) (`MLX_BUN_TEST_NATIVE=1`,
`MLX_BUN_APP_TEST_WHISPER_MODEL`, optionally `MLX_BUN_APP_TEST_MODEL`) runs both
verbs as spawned CLIs on real Whisper weights with speech synthesized by
macOS `say`, `dictate` through a stand-in sidecar that follows the capture
protocol, and a chat server with the companion: the mic probe, idle unload,
transcription while a reply streams, a voice session, unload, and `dictate
--server`. The physical microphone, key tap, clipboard and typing stay manual.

## Not in the module yet

The browser's hold-to-talk mic (`apps/mlx-bun/src/web/browser/voice.ts`, used by the
chat composer) stays with chat until the chat module lands; the module has no panel.
It declares no storage entries: nothing it does writes under `MLX_BUN_HOME`.
