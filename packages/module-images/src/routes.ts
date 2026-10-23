// The OpenAI Images-compatible route, declared in the manifest at its root path:
//   POST /v1/images/generations
// Body (JSON): OpenAI's `prompt`, `n` (1 only), `size` ("WIDTHxHEIGHT" or
// "auto"), `response_format` ("b64_json" only: no image URLs are hosted) and
// `model` (a catalog id or query; omitted = the host's image model), plus the
// extensions `negative_prompt`, `steps`, `guidance`, `seed` and
// `uncond_skip_layers` (an empty list disables skip-layer guidance).
// Response: `{ created, data: [{ b64_json, revised_prompt: null }], mlx_bun }`,
// `mlx_bun` carrying the model, size, seed, steps, guidance and timings.
//
// The handler borrows the service: it parses the wire shape, hands the request
// to `ImageService.generate` with the request's abort signal, and answers its
// outcome or failure. It never loads a model.

import type { ImageRequest, ModelHostError, ResidencyFailure, RouteHandler } from "@mlx-bun/app-core";
import { ImageRequestError, type ImageGeneration, type ImageOutcome, type ImageService } from "./service";

/** What the handler borrows from the service. */
export type GenerationService = Pick<ImageService, "generate">;

function errorJson(message: string, status: number, type = "invalid_request_error", code?: string): Response {
  return Response.json({ error: { message, type, ...(code ? { code } : {}) } }, { status });
}

const present = (value: unknown) => value !== undefined && value !== null;

/** A service call from the wire body, or the 400 for what the wire shape refuses. Field values are the service's to validate. */
export function parseGenerationBody(body: unknown): Pick<ImageGeneration, "model" | "request"> | Response {
  if (typeof body !== "object" || body === null || Array.isArray(body)) return errorJson("the body must be a JSON object", 400);
  const fields = body as Record<string, unknown>;
  if (present(fields.n) && fields.n !== 1) return errorJson(`n must be 1: this server generates one image per request, got ${JSON.stringify(fields.n)}`, 400);
  const format = fields.response_format ?? "b64_json";
  if (format === "url") return errorJson('response_format "url" is not supported: this server hosts no image URLs; use "b64_json"', 400);
  if (format !== "b64_json") return errorJson(`response_format must be "b64_json", got ${JSON.stringify(format)}`, 400);
  if (present(fields.model) && typeof fields.model !== "string") return errorJson("model must be a string", 400);
  let size: { width?: number; height?: number } = {};
  if (present(fields.size) && fields.size !== "auto") {
    const match = typeof fields.size === "string" ? /^(\d+)x(\d+)$/.exec(fields.size) : null;
    if (!match) return errorJson(`size must be "WIDTHxHEIGHT" (for example "1024x1024") or "auto", got ${JSON.stringify(fields.size)}`, 400);
    size = { width: Number(match[1]), height: Number(match[2]) };
  }
  const extension = (name: keyof ImageRequest, value: unknown) => present(value) ? { [name]: value } : {};
  const request = {
    prompt: fields.prompt, ...size,
    ...extension("negativePrompt", fields.negative_prompt), ...extension("steps", fields.steps), ...extension("guidance", fields.guidance),
    ...extension("seed", fields.seed), ...extension("uncondSkipLayers", fields.uncond_skip_layers),
  } as ImageRequest;
  return { ...(typeof fields.model === "string" && fields.model ? { model: fields.model } : {}), request };
}

/** OpenAI's Images response for one generated image, plus the `mlx_bun` block. `created` is Unix seconds. */
export function generationResponse(outcome: ImageOutcome, created: number) {
  const { image } = outcome;
  return {
    created,
    data: [{ b64_json: Buffer.from(outcome.png).toString("base64"), revised_prompt: null }],
    mlx_bun: { model: outcome.modelId, width: image.width, height: image.height, seed: image.seed, steps: image.steps, guidance: image.guidance,
      timings: outcome.timings },
  };
}

const residencyFailures = new Set<string>(["does-not-fit", "no-evictable-model", "load-failed", "aborted", "in-use", "closed", "not-switchable", "not-found"] satisfies ResidencyFailure[]);

/** The JSON error for a failed generation: the client's cancellation, the service's refusal, or the host's. */
function generationFailure(error: unknown, signal: AbortSignal): Response {
  if (signal.aborted) return errorJson("request cancelled", 499, "request_cancelled", "request_cancelled");
  if (error instanceof ImageRequestError) return errorJson(error.message, error.status, error.type);
  const message = (error as Error | undefined)?.message ?? String(error);
  const code = (error as Partial<ModelHostError> | undefined)?.code;
  if (typeof code === "string" && residencyFailures.has(code)) {
    if (code === "load-failed") return errorJson(message, 502, "model_load_failed", code);
    if (code === "closed") return errorJson(message, 503, "server_closing", code);
    return errorJson(message, 400, "invalid_request_error", code);
  }
  return errorJson(message, 500, "server_error");
}

/** Route handlers keyed by manifest route id, over one service. */
export function createImageHandlers(service: GenerationService, clock: () => number = Date.now): Record<"generations", RouteHandler> {
  return {
    async generations(request) {
      let body: unknown;
      try { body = await request.json(); }
      catch (error) { return request.signal.aborted ? generationFailure(error, request.signal) : errorJson("invalid JSON body", 400); }
      const parsed = parseGenerationBody(body);
      if (parsed instanceof Response) return parsed;
      try {
        const outcome = await service.generate({ ...parsed, signal: request.signal });
        return Response.json(generationResponse(outcome, Math.floor(clock() / 1000)));
      } catch (error) {
        return generationFailure(error, request.signal);
      }
    },
  };
}
