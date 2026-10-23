// The `image` verb: one prompt → the host's image model → a PNG on disk, no
// server. The same `ImageService.generate` call the route makes; this file
// only maps the parsed options to a request, prints progress on stderr, writes
// the file and reports it.
import { resolve } from "node:path";
import type { CliInvocation, ImageProgress, ImageRequest } from "@mlx-bun/app-core";
import type { ImageOutcome, ImageService } from "./service";

export interface ImageArgs {
  /** `--model`; undefined = the host's default for `image`. */
  model?: string;
  /** `--out`; undefined = `image-<seed>.png` in the current directory. */
  out?: string;
  request: ImageRequest;
  json: boolean;
}

/** The verb's arguments from what the host parsed against the manifest. Values are the service's to validate. */
export function parseImageArgs(invocation: Pick<CliInvocation, "values" | "positionals">): ImageArgs {
  const { values, positionals } = invocation;
  const text = (name: string) => { const value = values[name]; return typeof value === "string" ? value : undefined; };
  const number = (name: string) => { const value = values[name]; return typeof value === "number" ? value : undefined; };
  const set = <K extends keyof ImageRequest>(name: K, value: ImageRequest[K] | undefined) => value === undefined ? {} : { [name]: value };
  const model = text("model"), out = text("out");
  return {
    ...(model !== undefined ? { model } : {}),
    ...(out !== undefined ? { out } : {}),
    request: {
      prompt: positionals[0]!,
      ...set("negativePrompt", text("negative-prompt")),
      ...set("width", number("width")), ...set("height", number("height")), ...set("steps", number("steps")),
      ...set("guidance", number("guidance")), ...set("seed", number("seed")),
      ...(values["no-skip-layers"] === true ? { uncondSkipLayers: [] } : {}),
    },
    json: values.json === true,
  };
}

export interface ImageVerbDependencies {
  writeFile(path: string, bytes: Uint8Array): Promise<void>;
  stdout(text: string): void;
  /** Progress lines. */
  stderr(text: string): void;
}

const defaults: Pick<ImageVerbDependencies, "writeFile"> = {
  async writeFile(path, bytes) { await Bun.write(path, bytes); },
};

/** `conditioner`, `denoiser 3/28`, `decoder`. */
export function progressLine(progress: ImageProgress): string {
  return progress.step !== undefined && progress.steps !== undefined ? `${progress.stage} ${progress.step}/${progress.steps}` : progress.stage;
}

/** What `--json` prints. */
export function imageSummary(path: string, outcome: ImageOutcome) {
  const { image } = outcome;
  return { path, model: outcome.modelId, width: image.width, height: image.height, seed: image.seed, steps: image.steps, guidance: image.guidance, timings: outcome.timings };
}

/** Generate, write the PNG, print its path (or the JSON summary). Resolves to the path written. */
export async function runImage(service: Pick<ImageService, "generate">, args: ImageArgs,
  supplied: Pick<ImageVerbDependencies, "stdout" | "stderr"> & Partial<ImageVerbDependencies>, signal?: AbortSignal): Promise<string> {
  const deps = { ...defaults, ...supplied };
  const outcome = await service.generate({ ...(args.model !== undefined ? { model: args.model } : {}), request: args.request,
    ...(signal ? { signal } : {}), onProgress: progress => deps.stderr(progressLine(progress) + "\n") });
  signal?.throwIfAborted();
  const path = resolve(args.out ?? `image-${outcome.image.seed}.png`);
  await deps.writeFile(path, outcome.png);
  deps.stdout((args.json ? JSON.stringify(imageSummary(path, outcome)) : path) + "\n");
  return path;
}
