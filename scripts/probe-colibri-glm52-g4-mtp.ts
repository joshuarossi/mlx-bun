#!/usr/bin/env bun

/**
 * Bounded G4 full-model gate for serial native GLM-5.2 MTP.
 *
 * Run MTP-on and MTP-off in separate processes so teardown and allocator
 * state cannot bias the comparison. The on lane additionally checks the
 * direct-Colibri token and acceptance trace.
 */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import directTrace from "../fixtures/colibri-glm52/g4-direct-mtp-trace.json";
import oracle from "../fixtures/colibri-glm52/real-model-oracle.json";
import { gpuStream, type MlxArray } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  peakMemory,
  resetPeakMemory,
  setMemoryLimit,
  synchronize,
} from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { argmaxLastPosition } from "../src/model/gemma4-base";
import { Glm52Model } from "../src/model/glm52";
import { Glm52NativeMtpProvider } from "../src/spec/glm52-mtp-source";
import { specServeRun } from "../src/spec/serve-loop";

const GiB = 1024 ** 3;

type Mode = "on" | "off";

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: probe-colibri-glm52-g4-mtp.ts " +
        "--mode on|off --model DIR --library DYLIB --output FILE " +
        "[--max-tokens N]",
      );
    }
    out.set(key.slice(2), value);
  }
  return out;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

function swapUsage(): string {
  const result = Bun.spawnSync(["/usr/sbin/sysctl", "-n", "vm.swapusage"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout).trim();
}

function managerSnapshot(
  manager: NonNullable<Glm52Model["expertRuntime"]>["manager"],
) {
  const snapshot = manager.snapshot();
  return {
    working: snapshot.working,
    resident: snapshot.resident,
    pinned: snapshot.pinned,
    disabled: snapshot.disabled,
    loading: snapshot.loading,
    leased: snapshot.leased,
    hits: snapshot.hits,
    misses: snapshot.misses,
    evictions: snapshot.evictions,
    pressureEvictions: snapshot.pressureEvictions,
    clock: snapshot.clock.toString(),
    generation: snapshot.generation.toString(),
  };
}

function memory(model: Glm52Model | null) {
  const runtime = model?.expertRuntime;
  const mainFootprint = runtime?.store.physicalFootprint() ?? 0;
  const mtpFootprint = runtime?.mtp?.store.physicalFootprint() ?? 0;
  return {
    processRssBytes: process.memoryUsage().rss,
    // The native store API reports task-wide physical footprint, not bytes
    // attributable to one slab. Both stores therefore return the same value.
    processPhysicalFootprintBytes: runtime ? mainFootprint : null,
    mtpStorePhysicalFootprintSampleBytes:
      runtime?.mtp ? mtpFootprint : null,
    mainExpertSlabBytes: runtime?.plan.slabBytes ?? null,
    mtpExpertSlabBytes: runtime?.mtp?.plan.slabBytes ?? null,
    mlxActiveBytes: activeMemory(),
    mlxCacheBytes: cacheMemory(),
    mlxPeakBytes: peakMemory(),
    swap: swapUsage(),
  };
}

async function serialTarget(
  model: Glm52Model,
  prompt: readonly number[],
  maxTokens: number,
): Promise<{ tokens: number[]; prefillMs: number; decodeMs: number }> {
  const cache = model.makeCache();
  const tokens: number[] = [];
  try {
    const promptIds = ops.fromInt32([...prompt], [1, prompt.length]);
    const prefillStart = performance.now();
    let hidden: MlxArray;
    try {
      hidden = await model.forwardHiddenAsync(promptIds, cache);
    } finally {
      promptIds.dispose();
    }
    let logits: MlxArray;
    try {
      logits = model.logitsFromHidden(hidden);
    } finally {
      hidden.dispose();
    }
    let pending = argmaxLastPosition(logits);
    logits.dispose();
    synchronize(gpuStream);
    clearCache();
    const prefillMs = performance.now() - prefillStart;
    tokens.push(pending);

    const decodeStart = performance.now();
    while (tokens.length < maxTokens) {
      const ids = ops.fromInt32([pending], [1, 1]);
      let nextHidden: MlxArray;
      try {
        nextHidden = await model.forwardHiddenAsync(ids, cache);
      } finally {
        ids.dispose();
      }
      let nextLogits: MlxArray;
      try {
        nextLogits = model.logitsFromHidden(nextHidden);
      } finally {
        nextHidden.dispose();
      }
      pending = argmaxLastPosition(nextLogits);
      nextLogits.dispose();
      tokens.push(pending);
      synchronize(gpuStream);
      clearCache();
      if (tokens.length % 8 === 0)
        console.log(`target-only: ${tokens.length}/${maxTokens} tokens`);
    }
    return {
      tokens,
      prefillMs,
      decodeMs: performance.now() - decodeStart,
    };
  } finally {
    for (const layer of cache) layer.dispose();
  }
}

const cli = argumentsMap(Bun.argv.slice(2));
const mode = cli.get("mode") as Mode | undefined;
if (mode !== "on" && mode !== "off")
  throw new Error("--mode must be on or off");
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const output = required(cli, "output");
const maxTokens = Number(cli.get("max-tokens") ?? directTrace.request.max_tokens);
if (!Number.isSafeInteger(maxTokens) || maxTokens < 1)
  throw new RangeError("--max-tokens must be a positive safe integer");
if (maxTokens > directTrace.token_ids.length)
  throw new RangeError(
    `--max-tokens exceeds the ${directTrace.token_ids.length}-token oracle`,
  );
mkdirSync(dirname(output), { recursive: true });

const expectedTokens = directTrace.token_ids.slice(0, maxTokens);
const oldMemoryLimit = setMemoryLimit(4 * GiB);
resetPeakMemory();
let model: Glm52Model | null = null;
const before = memory(null);
let primaryError: unknown = null;
try {
  const openStart = performance.now();
  model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: 25 * GiB,
    reserveBytes: 4 * GiB,
    workingSlots: 64,
    maxSlotsPerLayer: 1,
    usagePath: false,
    workers: 2,
    libraryPath,
    decodeKernel: "metal",
    enableMtp: mode === "on",
    mtpDraftTokens: directTrace.request.draft_tokens,
  });
  const openMs = performance.now() - openStart;
  const opened = memory(model);
  const wallStart = performance.now();
  let tokens: number[];
  let timing: {
    prefillMs: number;
    decodeMs: number;
    decodeTps: number;
    wallMs: number;
  };
  let speculation: null | {
    drafted: number;
    accepted: number;
    rejected: number;
    verifyForwards: number;
    acceptanceLengths: number[];
    tokensPerForward: number;
    forwardsSaved: number;
  } = null;

  if (mode === "on") {
    const provider = new Glm52NativeMtpProvider(model);
    tokens = [];
    const stats = await specServeRun(
      model,
      provider,
      directTrace.request.draft_tokens,
      [...oracle.evidence.teacher_forcing_prefix_ids],
      {
        maxTokens,
        temperature: 0,
        eosTokenIds: [],
      },
      (token) => {
        tokens.push(token);
        if (tokens.length % 8 === 0)
          console.log(`native-mtp: ${tokens.length}/${maxTokens} tokens`);
      },
    );
    const spec = stats.spec;
    if (!spec) throw new Error("native MTP run returned no speculation stats");
    speculation = {
      drafted: spec.drafted,
      accepted: spec.accepted,
      rejected: spec.rejected ?? spec.drafted - spec.accepted,
      verifyForwards: spec.rounds ?? spec.targetCalls - 1,
      acceptanceLengths: [...(spec.acceptanceLengths ?? [])],
      tokensPerForward: spec.tokensPerForward ?? 0,
      forwardsSaved: spec.forwardsSaved ?? 0,
    };
    timing = {
      prefillMs: stats.prefillMs,
      decodeMs: stats.decodeMs,
      decodeTps: stats.decodeTps,
      wallMs: performance.now() - wallStart,
    };
  } else {
    const serial = await serialTarget(
      model,
      oracle.evidence.teacher_forcing_prefix_ids,
      maxTokens,
    );
    tokens = serial.tokens;
    timing = {
      prefillMs: serial.prefillMs,
      decodeMs: serial.decodeMs,
      decodeTps:
        maxTokens > 1
          ? ((maxTokens - 1) / Math.max(serial.decodeMs, 1e-6)) * 1000
          : 0,
      wallMs: performance.now() - wallStart,
    };
  }

  const mismatch = tokens.findIndex(
    (token, index) => token !== expectedTokens[index],
  );
  if (tokens.length !== expectedTokens.length || mismatch >= 0) {
    throw new Error(
      `G4 ${mode} token mismatch at ${mismatch >= 0 ? mismatch : tokens.length}: ` +
      `${tokens[mismatch] ?? "<missing>"} != ` +
      `${expectedTokens[mismatch] ?? "<end>"}`,
    );
  }

  if (
    mode === "on" &&
    maxTokens >= directTrace.request.acceptance_oracle_tokens
  ) {
    const allActual = speculation!.acceptanceLengths;
    const expected = directTrace.acceptance_lengths;
    const actual = allActual.slice(0, expected.length);
    const acceptMismatch = actual.findIndex(
      (length, index) => length !== expected[index],
    );
    if (actual.length !== expected.length || acceptMismatch >= 0) {
      throw new Error(
        `G4 acceptance mismatch at ` +
        `${acceptMismatch >= 0 ? acceptMismatch : Math.min(actual.length, expected.length)}: ` +
        `${actual[acceptMismatch] ?? "<missing>"} != ` +
        `${expected[acceptMismatch] ?? "<end>"}`,
      );
    }
  }

  synchronize(gpuStream);
  clearCache();
  const completed = memory(model);
  const runtime = model.expertRuntime!;
  await Bun.write(output, JSON.stringify({
    schema_version: 1,
    gate: "G4 serial native MTP",
    mode,
    result: "pass",
    scope: {
      max_tokens: maxTokens,
      prompt_tokens: oracle.evidence.teacher_forcing_prefix_ids.length,
      draft_tokens: directTrace.request.draft_tokens,
      allocator_limit_bytes: 4 * GiB,
      budget_bytes: 25 * GiB,
      reserve_bytes: 4 * GiB,
    },
    provenance: directTrace.provenance,
    trajectory: {
      expected: expectedTokens,
      actual: tokens,
    },
    timing: {
      openMs,
      ...timing,
    },
    speculation,
    residency: {
      main_plan: runtime.plan,
      main: managerSnapshot(runtime.manager),
      mtp_plan: runtime.mtp?.plan ?? null,
      mtp: runtime.mtp ? managerSnapshot(runtime.mtp.manager) : null,
    },
    memory: { before, opened, completed },
  }, null, 2) + "\n");
  console.log(`G4 ${mode}: PASS (${timing.decodeTps.toFixed(3)} tok/s decode)`);
} catch (error) {
  primaryError = error;
  await Bun.write(output, JSON.stringify({
    schema_version: 1,
    gate: "G4 serial native MTP",
    mode,
    result: "error",
    error: error instanceof Error ? error.message : String(error),
    memory: memory(model),
  }, null, 2) + "\n");
  throw error;
} finally {
  const cleanupErrors: unknown[] = [];
  try {
    model?.dispose();
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    synchronize(gpuStream);
    clearCache();
    setMemoryLimit(oldMemoryLimit);
  } catch (error) {
    cleanupErrors.push(error);
  }
  if (cleanupErrors.length) {
    throw new AggregateError(
      primaryError === null
        ? cleanupErrors
        : [primaryError, ...cleanupErrors],
      "G4 probe teardown failed",
    );
  }
}
