# @mlx-bun/module-images

Text-to-image with a local image model, as an application module
(`AppModule<"modelHost" | "catalog">`, design: [Modular application](../../ARCHITECTURE.md#modular-application)).
It declares the `POST /v1/images/generations` route and the `image` verb, and
no jobs, sockets, storage entries or panel. Nothing here imports an app,
another module or model code. The host's `modelHost` service owns the weights,
their residency and the execution lock, and hands out leases that declare the
`image` operation; its `catalog` resolves model names.

## Image generation

The route and the verb both call `ImageService.generate({ model?, request,
signal?, onProgress? })` in `src/service.ts`. It validates the request,
resolves the model, leases it with `need: ["image"]` and calls
`operations.image.generate`. It releases the lease when the run settles,
whether it succeeded, failed or was cancelled, and then encodes the RGB pixels
as an 8-bit PNG with `fast-png` (`src/png.ts`).

A named model goes through `catalog.find`, so a directory, an id or a cached
query all work. An unknown one is a 404 `model_not_found` carrying the
catalog's message. With no name, the service asks `modelHost.defaultFor("image")`;
if the host has none, it answers 503 `model_unavailable` with the `mlx-bun get`
hint. Unset fields take the model's `ImageOperation.defaults`.

Validation happens before the lease where it can. The prompt must be a
non-empty string and the negative prompt a string. `width`, `height` and
`steps` must be positive integers, `guidance` finite and at least 0, `seed` an
integer in [0, 2^53), and skip layers non-negative integers. Two checks need
the model. Once leased, `width` and `height` must be multiples of the lease's
`pixelsPerLatent`. The operation itself throws a `RangeError` for what only the
model knows, such as a skip-layer block past its depth, and the service turns
that into a 400.

Stopping the module aborts the generations in flight, and `dispose` waits for
them, so every lease is back before the host releases the models. A request cut
short this way gets 503 `server_closing`.

`src/routes.ts` serves `POST /v1/images/generations` at the root, compatible
with OpenAI's Images API. The JSON body takes `prompt`, `n`, `size`,
`response_format` and an optional `model`. `n` must be 1, and any other value
is a 400 naming the limit. `size` is `"WIDTHxHEIGHT"` or `"auto"`.
`response_format` defaults to `"b64_json"`; `"url"` is a 400, because no image
URL host exists. The extensions are `negative_prompt`, `steps`, `guidance`,
`seed` and `uncond_skip_layers`, where an empty list turns skip-layer guidance
off.

The response is `{ created, data: [{ b64_json, revised_prompt: null }], mlx_bun }`.
`mlx_bun` holds `model`, `width`, `height`, `seed`, `steps`, `guidance` and
`timings`: `load_ms`, `encode_ms`, `denoise_ms`, `decode_ms`, `png_ms` and
`total_ms`. `load_ms` is non-zero exactly when the request waited for the model
to load. Errors use `{ error: { message, type, code? } }` with these statuses:

- 400 for a refused field, and for the host's residency failures other than the
  two below, with their `code`
- 404 for an unknown model
- 499 when the client disconnects; the request's signal cancels the run and the
  lease is released
- 502 `model_load_failed`
- 503 `model_unavailable` or `server_closing`
- 500 for anything else

A request the route does not match falls through to the host.

`image <prompt>` makes the same service call without a server. It takes
`--model`, `--out`, `--width`, `--height`, `--steps`, `--guidance`, `--seed`,
`--negative-prompt`, `--no-skip-layers` and `--json`. `--out` defaults to
`image-<seed>.png` in the current directory, using the seed the run used.
`--no-skip-layers` sends an empty skip list. `--json` prints
`{ path, model, width, height, seed, steps, guidance, timings }` instead of the
path. Progress lines go to stderr: `conditioner`, `denoiser <step>/<steps>`,
`decoder`. Give a negative number inline (`--seed=-1`), because the host's
parser reads `-1` as a flag. SIGINT cancels the run and releases the lease, and
the verb rejects with `image generation cancelled`.

## Tests

Every test is model-free. [`tests/support.ts`](tests/support.ts) supplies a
fake `modelHost` that records each acquire and release, and a fake `image`
operation that paints a known pixel pattern.

- The [service tests](tests/service.test.ts) cover model resolution, each check
  before the lease, the latent-grid check after it, the host's `RangeError`, a
  model without the operation, cancellation and stopping.
- The [route tests](tests/routes.test.ts) decode the returned PNG and compare
  its pixels. They also cover every refused field, `n`, `response_format: "url"`,
  the model and residency failures, and a client abort that releases the lease.
- The [verb tests](tests/image.test.ts) write and decode a PNG, check the
  default path and `--json`, and check the lease is released on failure.
- The [module test](tests/module.test.ts) loads the module through
  `@mlx-bun/app-host`. It requires only `modelHost` and `catalog`, mounts the
  route at the root, runs the verb, cancels it, and stops while a generation is
  in flight.
- The [PNG test](tests/png.test.ts) round-trips the encoder.
