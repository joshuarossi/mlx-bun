// Model-free: the `image` verb parsed against its manifest and run over the
// real service with a fake `modelHost`: the PNG on disk, the default path,
// the JSON summary, progress on stderr, and the lease on failure.
import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { decode } from "fast-png";
import { parseVerb } from "@mlx-bun/app-services";
import { parseImageArgs, runImage } from "../src/image";
import { manifest } from "../src/manifest";
import { ImageService } from "../src/service";
import { DEFAULTS, fakeCatalog, fakeHost, fakeOperation, MODEL_ID, OTHER_ID, pattern } from "./support";

const spec = manifest.verbs.find(verb => verb.name === "image")!;
/** Arguments as the host parses them against the manifest. */
const parse = (...argv: string[]) => parseImageArgs(parseVerb("mlx-bun", spec, argv));

function setup(input: Parameters<typeof fakeOperation>[0] = {}) {
  const { operation, requests } = fakeOperation(input);
  const { host, events, held } = fakeHost(operation, { defaultId: MODEL_ID });
  const service = new ImageService({ modelHost: host, catalog: fakeCatalog() });
  const stdout: string[] = [], stderr: string[] = [];
  return { service, requests, events, held, stdout, stderr, io: { stdout: (text: string) => { stdout.push(text); }, stderr: (text: string) => { stderr.push(text); } } };
}

test("options map to the request; --no-skip-layers sends an empty skip list; the prompt is required", () => {
  expect(parse("a cat")).toEqual({ request: { prompt: "a cat" }, json: false });
  expect(parse("a cat", "--model", OTHER_ID, "--out", "cat.png", "--width", "48", "--height", "32", "--steps", "4", "--guidance", "2.5",
    "--seed", "11", "--negative-prompt", "blur", "--no-skip-layers", "--json")).toEqual({
    model: OTHER_ID, out: "cat.png", json: true,
    request: { prompt: "a cat", negativePrompt: "blur", width: 48, height: 32, steps: 4, guidance: 2.5, seed: 11, uncondSkipLayers: [] },
  });
  expect(() => parse()).toThrow(spec.usage);
  expect(() => parse("a", "cat")).toThrow("Too many arguments for image");
  expect(() => parse("a cat", "--steps", "many")).toThrow("invalid --steps: many");
});

test("writes a valid PNG to --out, prints its path, and reports progress on stderr", async () => {
  const directory = mkdtempSync(join(tmpdir(), "mlx-image-verb-"));
  try {
    const { service, io, stdout, stderr, events, held } = setup();
    const out = join(directory, "nested.png");
    const path = await runImage(service, parse("a cat", "--out", out, "--width", "32", "--height", "16", "--steps", "2", "--seed", "5"), io);
    expect(path).toBe(out);
    expect(stdout).toEqual([`${out}\n`]);
    expect(stderr).toEqual(["conditioner\n", "denoiser 1/2\n", "denoiser 2/2\n", "decoder\n"]);
    const png = decode(readFileSync(out));
    expect([png.width, png.height, png.channels]).toEqual([32, 16, 3]);
    expect(png.data).toEqual(pattern(32, 16, 5));
    expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
    expect(held()).toBe(0);
  } finally { rmSync(directory, { recursive: true, force: true }); }
});

test("the default path is image-<seed>.png in the current directory, with the seed the run used; --json prints the summary", async () => {
  const { service, io, stdout } = setup();
  const written: [string, number][] = [];
  const path = await runImage(service, parse("a cat", "--json"), { ...io, writeFile: async (to, bytes) => { written.push([to, bytes.length]); } });
  expect(path).toBe(resolve("image-1234.png"));
  expect(written.map(([to]) => to)).toEqual([path]);
  expect(written[0]![1]).toBeGreaterThan(0);
  expect(JSON.parse(stdout.join(""))).toEqual({ path, model: MODEL_ID, width: DEFAULTS.width, height: DEFAULTS.height, seed: 1234,
    steps: DEFAULTS.steps, guidance: DEFAULTS.guidance, timings: { load_ms: 7, encode_ms: 11, denoise_ms: 22, decode_ms: 33, png_ms: expect.any(Number), total_ms: expect.any(Number) } });
});

test("a failed run writes nothing, prints no path and releases the lease", async () => {
  const { service, io, stdout, events, held } = setup({ generate: async () => { throw new Error("decoder exploded"); } });
  const written: string[] = [];
  await expect(runImage(service, parse("a cat"), { ...io, writeFile: async to => { written.push(to); } })).rejects.toThrow("decoder exploded");
  expect(written).toEqual([]);
  expect(stdout).toEqual([]);
  expect(events).toEqual([`acquire ${MODEL_ID} need=image`, `release ${MODEL_ID}`]);
  expect(held()).toBe(0);
});

test("an invalid option is refused before any lease", async () => {
  const { service, io, events } = setup();
  await expect(runImage(service, parse("a cat", "--seed=-1"), io)).rejects.toThrow("seed must be an integer in [0, 2^53), got -1");
  await expect(runImage(service, parse("a cat", "--width", "10.5"), io)).rejects.toThrow("width must be a positive integer, got 10.5");
  expect(events).toEqual([]);
});
