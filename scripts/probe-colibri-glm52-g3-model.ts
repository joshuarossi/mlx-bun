#!/usr/bin/env bun

/**
 * Bounded G3 full-model correctness gate: one 32-token prefill and one decode
 * forward through the streamed pure-LRU model. No MTP and no performance
 * claim; G4 owns speculative execution and G5 owns the measured 25 GB run.
 */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import oracle from "../fixtures/colibri-glm52/real-model-oracle.json";
import { gpuStream } from "../src/mlx/array";
import {
  activeMemory,
  cacheMemory,
  clearCache,
  peakMemory,
  resetPeakMemory,
  setMemoryLimit,
  synchronize,
} from "../src/mlx/ffi";
import { Glm52Model } from "../src/model/glm52";
import {
  G3LiveGuard,
  G3SwapoutGuardError,
  parseSwapUsage,
  parseVmStat,
} from "./lib/g3-live-guard";

const GiB = 1024 ** 3;

function argumentsMap(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let index = 0; index < argv.length; index += 2) {
    const key = argv[index];
    const value = argv[index + 1];
    if (!key?.startsWith("--") || value === undefined)
      throw new Error(
        "usage: probe-colibri-glm52-g3-model.ts " +
        "--model DIR --library DYLIB --output FILE " +
        "[--trace FILE] [--max-swapout-mib N]",
      );
    out.set(key.slice(2), value);
  }
  return out;
}

function required(values: Map<string, string>, key: string): string {
  const value = values.get(key);
  if (!value) throw new Error(`missing --${key}`);
  return resolve(value);
}

function swap(): string {
  const result = Bun.spawnSync(["/usr/sbin/sysctl", "-n", "vm.swapusage"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout).trim();
}

function vmStat(): string {
  const result = Bun.spawnSync(["/usr/bin/vm_stat"], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0)
    throw new Error(new TextDecoder().decode(result.stderr));
  return new TextDecoder().decode(result.stdout);
}

function memory(model: Glm52Model | null) {
  return {
    processRssBytes: process.memoryUsage().rss,
    physicalFootprintBytes:
      model?.expertRuntime?.store.physicalFootprint() ?? null,
    mlxActiveBytes: activeMemory(),
    mlxCacheBytes: cacheMemory(),
    mlxPeakBytes: peakMemory(),
    swap: swap(),
  };
}

function lastPrediction(
  values: Float32Array,
  vocabulary: number,
): { token: number; margin: number } {
  if (values.length % vocabulary !== 0)
    throw new Error("logit payload is not row-aligned");
  const begin = values.length - vocabulary;
  let firstToken = 0;
  let first = values[begin]!;
  let second = Number.NEGATIVE_INFINITY;
  for (let token = 1; token < vocabulary; token++) {
    const value = values[begin + token]!;
    if (value > first) {
      second = first;
      first = value;
      firstToken = token;
    } else if (value > second) {
      second = value;
    }
  }
  return { token: firstToken, margin: first - second };
}

const cli = argumentsMap(Bun.argv.slice(2));
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const output = required(cli, "output");
const tracePath = cli.has("trace")
  ? resolve(cli.get("trace")!)
  : `${output}.live.jsonl`;
const maxSwapoutMiB = Number(cli.get("max-swapout-mib") ?? "64");
if (!Number.isFinite(maxSwapoutMiB) || maxSwapoutMiB <= 0)
  throw new RangeError("--max-swapout-mib must be a positive number");
const maxSwapoutDeltaBytes = Math.ceil(maxSwapoutMiB * 1024 ** 2);
mkdirSync(dirname(output), { recursive: true });

const prefix = oracle.evidence.teacher_forcing_prefix_ids;
const expected = [
  oracle.evidence.main_next.token_id,
  13,
];
const oldMemoryLimit = setMemoryLimit(4 * GiB);
resetPeakMemory();
let model: Glm52Model | null = null;
let currentForward = "startup";
const waveByForwardLayer = new Map<string, number>();
let pendingDiagnosticError: unknown = null;
let primaryError: unknown = null;
const before = memory(null);
const guard = new G3LiveGuard({
  tracePath,
  maxSwapoutDeltaBytes,
  sample: () => {
    const snapshot = model?.expertRuntime?.manager.snapshot();
    return {
      vm: parseVmStat(vmStat()),
      swapUsage: parseSwapUsage(swap()),
      processRssBytes: process.memoryUsage().rss,
      physicalFootprintBytes:
        model?.expertRuntime?.store.physicalFootprint() ?? null,
      mlxActiveBytes: activeMemory(),
      mlxCacheBytes: cacheMemory(),
      mlxPeakBytes: peakMemory(),
      residency: snapshot
        ? {
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
          }
        : null,
    };
  },
});
guard.record({ phase: "before_open", forward: currentForward }, true);
try {
  model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: 25 * GiB,
    reserveBytes: 4 * GiB,
    workingSlots: 64,
    maxSlotsPerLayer: 1,
    usagePath: false,
    workers: 2,
    libraryPath,
    decodeKernel: "stock",
  });
  guard.record({ phase: "opened", forward: currentForward }, true);
  const manager = model.expertRuntime!.manager;
  const originalAcquire = manager.acquireBlock.bind(manager);
  manager.acquireBlock = async (
    layer,
    expertIds,
    beforeMissSubmit,
  ) => {
    if (pendingDiagnosticError) throw pendingDiagnosticError;
    const key = `${currentForward}:${layer}`;
    const wave = waveByForwardLayer.get(key) ?? 0;
    waveByForwardLayer.set(key, wave + 1);
    const context = {
      forward: currentForward,
      layer,
      wave,
      requestedExperts: expertIds,
    };
    guard.record({ phase: "wave_before", ...context }, true);
    try {
      const lease = await originalAcquire(
        layer,
        expertIds,
        beforeMissSubmit,
      );
      guard.record({ phase: "wave_acquired", ...context });
      const originalRelease = lease.releaseFenced.bind(lease);
      let released = false;
      lease.releaseFenced = () => {
        if (released) return;
        originalRelease();
        released = true;
        try {
          guard.record({ phase: "wave_released", ...context });
        } catch (error) {
          // The slot is already safely released. Surface sampler failures at
          // the next pre-work boundary without provoking a double release in
          // the executor's cleanup path.
          pendingDiagnosticError = error;
        }
      };
      return lease;
    } catch (error) {
      guard.record({
        phase: "wave_error",
        ...context,
        note: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  };
  const opened = memory(model);
  const cache = model.makeCache();
  try {
    currentForward = "prefill";
    guard.record({ phase: "forward_before", forward: currentForward }, true);
    const prefillLogits = await model.forwardAsync(prefix, cache);
    const prefill = lastPrediction(
      prefillLogits.toFloat32(),
      model.glmConfig.vocabSize,
    );
    prefillLogits.dispose();
    synchronize(gpuStream);
    clearCache();
    guard.record({ phase: "forward_after", forward: currentForward }, true);
    const afterPrefill = memory(model);

    currentForward = "decode";
    guard.record({ phase: "forward_before", forward: currentForward }, true);
    const decodeLogits = await model.forwardAsync(
      [oracle.evidence.teacher_decode_id],
      cache,
    );
    const decode = lastPrediction(
      decodeLogits.toFloat32(),
      model.glmConfig.vocabSize,
    );
    decodeLogits.dispose();
    synchronize(gpuStream);
    clearCache();
    guard.record({ phase: "forward_after", forward: currentForward }, true);
    const afterDecode = memory(model);
    const snapshot = model.expertRuntime!.manager.snapshot();
    const actual = [prefill.token, decode.token];
    if (actual[0] !== expected[0] || actual[1] !== expected[1])
      throw new Error(`G3 streamed tokens ${actual} != Colibri ${expected}`);

    await Bun.write(output, JSON.stringify({
      schema_version: 1,
      gate: "G3 full streamed two-forward trajectory",
      scope: {
        mtp: false,
        performance_claim: false,
        prefix_tokens: prefix.length,
        forwards: 2,
        working_slots: 64,
        slots_per_sparse_layer: 1,
        allocator_limit_bytes: 4 * GiB,
        max_swapout_delta_bytes: maxSwapoutDeltaBytes,
        live_trace: tracePath,
      },
      provenance: {
        colibri_commit: oracle.provenance.colibri_pin,
        artifact_revision: oracle.provenance.snapshot_revision,
      },
      trajectory: {
        expected,
        actual,
        prefill_margin: prefill.margin,
        decode_margin: decode.margin,
      },
      residency_plan: model.expertRuntime!.plan,
      residency: {
        ...snapshot,
        clock: snapshot.clock.toString(),
        generation: snapshot.generation.toString(),
      },
      memory: { before, opened, after_prefill: afterPrefill, after_decode: afterDecode },
      result: "pass",
    }, null, 2) + "\n");
  } finally {
    for (const layer of cache) layer.dispose();
  }
} catch (error) {
  primaryError = error;
  const checkpoint = error instanceof G3SwapoutGuardError
    ? error.checkpoint
    : guard.tripped;
  await Bun.write(output, JSON.stringify({
    schema_version: 1,
    gate: "G3 full streamed two-forward trajectory",
    result: checkpoint ? "aborted_swapout_guard" : "error",
    error: error instanceof Error ? error.message : String(error),
    live_trace: tracePath,
    max_swapout_delta_bytes: maxSwapoutDeltaBytes,
    guard_checkpoint: checkpoint,
    memory: memory(model),
  }, null, 2) + "\n");
  throw error;
} finally {
  const cleanupErrors: unknown[] = [];
  try {
    guard.record(
      { phase: "cleanup_before_close", forward: currentForward },
      true,
    );
  } catch (error) {
    cleanupErrors.push(error);
  }
  const closingModel = model;
  model = null;
  try {
    closingModel?.dispose();
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    synchronize(gpuStream);
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    clearCache();
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    setMemoryLimit(oldMemoryLimit);
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    guard.record(
      { phase: "cleanup_after_close", forward: currentForward },
      true,
    );
  } catch (error) {
    cleanupErrors.push(error);
  }
  if (cleanupErrors.length) {
    const cleanupError = new AggregateError(
      cleanupErrors,
      "G3 probe teardown or teardown guard failed",
    );
    const combined = primaryError === null
      ? cleanupError
      : new AggregateError(
          [primaryError, cleanupError],
          "G3 probe and teardown both failed",
        );
    const checkpoint = cleanupErrors.find(
      (error): error is G3SwapoutGuardError =>
        error instanceof G3SwapoutGuardError,
    )?.checkpoint ?? guard.tripped;
    await Bun.write(output, JSON.stringify({
      schema_version: 1,
      gate: "G3 full streamed two-forward trajectory",
      result: checkpoint ? "aborted_swapout_guard" : "error",
      error: combined.message,
      live_trace: tracePath,
      max_swapout_delta_bytes: maxSwapoutDeltaBytes,
      guard_checkpoint: checkpoint,
      memory: memory(null),
    }, null, 2) + "\n");
    throw combined;
  }
}
