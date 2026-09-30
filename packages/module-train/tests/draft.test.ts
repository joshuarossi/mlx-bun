import { expect, test } from "bun:test";
import { join } from "node:path";
import { draftOutput, parseDraftArgs, runDraft, type DraftDependencies } from "../src";
import { fakeTerminal, strip, verbArgs } from "./support";

const args = verbArgs("draft");

const training = () => {
  const calls: { name: string; args: any[] }[] = [];
  const events: Record<string, unknown[]> = {
    regen: [{ type: "start", tapLayers: [20, 31, 41, 42], hiddenSize: 8, layers: 42, resumed: 0, nextShard: 0 }, { type: "shard", index: 0, sequences: 2, tokens: 90 }],
    train: [{ type: "start", shards: 5, train: 3, validation: 1, parameters: 56, resumed: false, config: { gamma: 5, dDraft: 1024, tapLayers: [20, 31, 41, 42] } },
      { type: "step", step: 1, iters: 2, lr: 1e-3, loss: 9.5 }, { type: "step", step: 2, iters: 2, lr: 1e-3, loss: 7.25 },
      { type: "eval", step: 2, tau: 1.5, perPosition: [0.5, 0.4], saved: true }],
  };
  let sts: unknown;
  const library = {
    DEFAULT_DRAFTER_TRAIN_CONFIG: { drafter: { gamma: 5, dDraft: 1024, nLayers: 5, nHeads: 8, markovRank: 256, ffMult: 2, tapLayers: [20, 31, 41, 42] },
      iters: 6000, batch: 8, maxCtx: 512, lr: 1.5e-3, warmup: 150, evalEvery: 500, evalAnchors: 256, seed: 0, usesPerShard: 200, resume: false },
    async regenDrafterData(...call: any[]) { calls.push({ name: "regen", args: call }); for (const e of events.regen!) call[4].onProgress(e); return { kept: 4, tokens: 200, shards: 2, skippedShort: 1 }; },
    async trainDrafter(...call: any[]) { calls.push({ name: "train", args: call }); for (const e of events.train!) call[2](e); return { bestTau: 1.5, steps: 2, outDir: call[1].outDir }; },
    async calibrateDrafter(...call: any[]) {
      calls.push({ name: "calibrate", args: call });
      call[4].onPrompt({ index: 0, promptTokens: 7, generated: 12, acceptance: 0.4 });
      return { sts: { thresholds: [0, 0.6], target: call[4].target, samples: 99 }, positionSamples: [50, 49], gamma: 2 };
    },
    readSts: (dir: string) => { calls.push({ name: "readSts", args: [dir] }); return sts; },
    writeSts(dir: string, value: unknown) { calls.push({ name: "writeSts", args: [dir, value] }); return join(dir, "dspark.json"); },
  };
  return { library, calls, setSts: (value: unknown) => { sts = value; } };
};

function harness(files: Record<string, string> = {}) {
  const lib = training(), logs: string[] = [], disposed: number[] = [], quantized: any[] = [];
  const target = { model: { config: { text: { hiddenSize: 2560, vocabSize: 262144 } } }, tokenizer: {}, template: {}, dispose: () => disposed.push(1) };
  const deps: DraftDependencies = {
    resolve: async query => ({ m: { path: `/models/${query}`, repoId: `org/${query}` } }),
    loadTarget: async () => target as never,
    training: async () => lib.library as never,
    quantizeDrafter: async () => (async (...call: any[]) => {
      quantized.push(call); call[2].onProgress?.("quantizing", "module", 0.5);
      return { nQuantized: 11, achievedBpw: 4.5, outDir: call[1], write: { totalSize: 1, shards: [] } };
    }) as never,
    exists: path => path in files || Object.keys(files).some(f => f.startsWith(path + "/")),
    readText: path => { const text = files[path]; if (text === undefined) throw new Error(`no fixture ${path}`); return text; },
    log: line => logs.push(line), terminal: fakeTerminal(logs), datasetsDir: () => "/store/datasets", modelsDir: () => "/store/models",
  };
  return { deps, lib, logs, disposed, quantized, text: () => strip(logs.join("\n")) };
}

test("draft validates action, subject, required flags and numbers before resolving anything", async () => {
  const cases: [string[], string][] = [
    [[], "usage: mlx-bun draft <regen|train|calibrate|quantize> <model|drafter-dir> [options]"],
    [["fly", "m"], "usage: mlx-bun draft <regen|train|calibrate|quantize>"],
    [["regen"], "usage: mlx-bun draft regen <model>"],
    [["regen", "m"], "draft regen: --topics is required"],
    [["train", "m"], "draft train: --data is required"],
    [["calibrate", "m", "--data", "p.jsonl"], "draft calibrate: --drafter is required"],
    [["train", "m", "--data", "d", "--iters", "many"], '--iters expects a number (got "many")'],
    [["train", "m", "--data", "d", "--iters", "0"], "--iters expects a positive integer"],
    [["train", "m", "--data", "d", "--lr", "0"], "--lr expects a positive number"],
    [["train", "m", "--data", "d", "--tap-layers", "20,x"], "--tap-layers must be non-negative integers"],
    [["train", "m", "--data", "d", "--seq-head", "gru"], "--seq-head expects markov|rnn"],
    [["quantize", "d", "--bits", "5"], "--bits expects 4 or 8"],
    [["quantize", "d", "--group-size", "16"], "--group-size expects 32 or 64"],
    [["calibrate", "m", "--drafter", "d", "--data", "p", "--precision", "1.5"], "--precision expects a value in (0, 1]"],
    [["calibrate", "m", "--drafter", "d", "--data", "p", "--tap-layers", "1"], "--tap-layers applies to regen and train"],
  ];
  const h = harness();
  for (const [argv, message] of cases) await expect((async () => runDraft(args(...argv), h.deps))()).rejects.toThrow(message);
  expect(h.lib.calls).toEqual([]);
  expect(() => args("regen", "m", "extra")).toThrow("Too many arguments");
  expect(parseDraftArgs(args("train", "--model", "m", "--data", "d")).subject).toBe("m");
});

test("regen reads the topics, defaults its output under the storage root and the e4b tap layers", async () => {
  const h = harness({ "/t.txt": "volcanoes\n\n  chess \n" });
  await runDraft(args("regen", "e4b", "--topics", "/t.txt", "--max-resp", "40", "--seqs-per-shard", "1"), h.deps);
  const [call] = h.lib.calls;
  expect(call!.name).toBe("regen");
  expect(call!.args[3]).toEqual(["volcanoes", "chess"]);
  expect(call!.args[4]).toMatchObject({ outDir: "/store/datasets/dspark-e4b", tapLayers: [20, 31, 41, 42], maxResponseTokens: 40, sequencesPerShard: 1, minResponseTokens: 6 });
  expect(h.disposed).toHaveLength(1);
  const text = h.text();
  expect(text).toContain("shard 0: 2 sequences, 90 tokens");
  expect(text).toContain("mlx-bun draft train e4b --data /store/datasets/dspark-e4b");
});

test("regen with explicit taps and out repeats the taps in the train hint and disposes the target when the stage fails", async () => {
  const h = harness({ "/t.txt": "a" });
  await runDraft(args("regen", "m", "--topics", "/t.txt", "--out", "/o", "--tap-layers", "5,17,29,41,46"), h.deps);
  expect(h.lib.calls[0]!.args[4]).toMatchObject({ outDir: "/o", tapLayers: [5, 17, 29, 41, 46] });
  expect(h.text()).toContain("--tap-layers 5,17,29,41,46");
  const failing = harness({ "/t.txt": "a" });
  failing.lib.library.regenDrafterData = async () => { throw new Error("gpu on fire"); };
  await expect(runDraft(args("regen", "m", "--topics", "/t.txt"), failing.deps)).rejects.toThrow("gpu on fire");
  expect(failing.disposed).toHaveLength(1);
  await expect(runDraft(args("regen", "m", "--topics", "/empty.txt"), harness({ "/empty.txt": "\n \n" }).deps)).rejects.toThrow("no topics");
});

test("train builds the drafter config from flags over the library defaults and stamps the target identity", async () => {
  const h = harness();
  await runDraft(args("train", "e4b", "--data", "/shards", "--iters", "2", "--batch", "4", "--gamma", "3", "--d-draft", "256", "--seq-head", "rnn", "--resume", "--seed", "9"), h.deps);
  const [, config] = h.lib.calls[0]!.args;
  expect(config).toMatchObject({ dataDir: "/shards", outDir: "/store/models/e4b-dspark", targetId: "org/e4b@2560x262144", iters: 2, batch: 4, seed: 9, resume: true,
    maxCtx: 512, lr: 1.5e-3, warmup: 150, evalEvery: 500, evalAnchors: 256 });
  expect(config.drafter).toEqual({ gamma: 3, dDraft: 256, nLayers: 5, nHeads: 8, markovRank: 256, ffMult: 2, tapLayers: [20, 31, 41, 42], seqHead: "rnn" });
  const text = h.text();
  expect(text).toContain("loss 9.5000");
  expect(text).toContain("9.5000 → 7.2500");
  expect(text).toContain("best τ     1.500");
  expect(text).toContain("mlx-bun serve org/e4b --draft-model /store/models/e4b-dspark");
  expect(h.disposed).toHaveLength(1);
  await runDraft(args("train", "e4b", "--data", "/shards"), h.deps);
  expect(h.lib.calls[1]!.args[1].drafter.seqHead).toBe("markov"); // the stamped default, as main's script did
});

test("calibrate refuses a calibrated drafter without --force, then writes the fit in place", async () => {
  const files = { "/d/dspark.json": "{}", "/p.jsonl": '{"prompt":"hi"}\n{"prompt":[{"role":"user","content":"yo"}]}\n' };
  const h = harness(files);
  h.lib.setSts({ thresholds: [0, 0.5], target: 0.5, samples: 10 });
  await expect(runDraft(args("calibrate", "m", "--drafter", "/d", "--data", "/p.jsonl"), h.deps)).rejects.toThrow("already has STS calibration (precision 0.5, samples 10) — pass --force");
  expect(h.lib.calls.some(c => c.name === "calibrate")).toBe(false);
  await runDraft(args("calibrate", "m", "--drafter", "/d", "--data", "/p.jsonl", "--force", "--precision", "0.8", "--n", "2"), h.deps);
  const calibrate = h.lib.calls.find(c => c.name === "calibrate")!;
  expect(calibrate.args[3]).toBe("/d");
  expect(calibrate.args[4]).toMatchObject({ prompts: ["hi", [{ role: "user", content: "yo" }]], count: 2, maxTokens: 128, target: 0.8, minSamples: 50 });
  expect(h.lib.calls.find(c => c.name === "writeSts")!.args).toEqual(["/d", { thresholds: [0, 0.6], target: 0.8, samples: 99 }]);
  expect(h.text()).toContain("pos 1: threshold 0.6000  n=49");
});

test("calibrate needs a dspark drafter, prompt rows with a prompt, and a copied checkpoint for --out", async () => {
  await expect(runDraft(args("calibrate", "m", "--drafter", "/d", "--data", "/p"), harness({ "/p": "{}" }).deps)).rejects.toThrow("/d has no dspark.json");
  await expect(runDraft(args("calibrate", "m", "--drafter", "/d", "--data", "/p"), harness({ "/d/dspark.json": "{}", "/p": '{"x":1}' }).deps)).rejects.toThrow('/p:1: each row needs a "prompt"');
  await expect(runDraft(args("calibrate", "m", "--drafter", "/d", "--data", "/p", "--out", "/copy"), harness({ "/d/dspark.json": "{}", "/p": '{"prompt":"a"}' }).deps))
    .rejects.toThrow("--out /copy has no dspark.json — copy the checkpoint directory first");
});

test("quantize defaults its output beside the models, passes bits and group, and refuses an existing output", async () => {
  const h = harness({ "/x/drafter/config.json": "{}" });
  await runDraft(args("quantize", "/x/drafter/", "--bits", "8", "--group-size", "32"), h.deps);
  expect(h.quantized[0].slice(0, 2)).toEqual(["/x/drafter", "/store/models/drafter-affine-q8-g32"]);
  expect(h.quantized[0][2]).toMatchObject({ bits: 8, groupSize: 32 });
  expect(h.text()).toContain("11 quantized · 4.50 bpw");
  expect(h.text()).toContain("bun scripts/drafter-ab.ts --target <model> --drafter-a /x/drafter --drafter-b /store/models/drafter-affine-q8-g32");
  await expect(runDraft(args("quantize", "/x/drafter", "--out", "/x/drafter"), h.deps)).rejects.toThrow("already exists");
  await expect(runDraft(args("quantize", "/nowhere"), h.deps)).rejects.toThrow("/nowhere has no config.json");
  expect(draftOutput("quantize", parseDraftArgs(args("quantize", "d")), "d", { datasets: () => "/store/datasets", models: () => "/store/models" })).toBe("/store/models/d-affine-q4-g64");
});

test("cancellation before any stage stops without loading a target", async () => {
  const h = harness({ "/t.txt": "a" });
  const controller = new AbortController();
  controller.abort(new Error("draft cancelled"));
  let loaded = 0;
  h.deps.loadTarget = async () => { loaded++; throw new Error("unreachable"); };
  await expect(runDraft(args("regen", "m", "--topics", "/t.txt"), h.deps, controller.signal)).rejects.toThrow("draft cancelled");
  expect(loaded).toBe(0);
});
