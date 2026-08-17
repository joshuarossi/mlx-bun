#!/usr/bin/env bun

/**
 * Bounded Stage-0 DSA gate: prefill exactly index_topk tokens, then run one
 * greedy decode input so every FULL indexer selects from index_topk + 1 keys.
 * The prompt is tokenizer-stable across mlx-bun and Colibri:
 *   [gMASK]<sop> + " a" repeated (index_topk - 2) times.
 */

import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
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
import type { Glm52DsaLayerSelection } from "../src/model/glm52-dsa";
import { loadTokenizer } from "../src/tokenizer";
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
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error(
        "usage: probe-colibri-glm52-dsa-long.ts " +
        "--model DIR --library DYLIB --output FILE " +
        "[--trace FILE] [--logits FILE] [--max-swapout-mib N]",
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

function sparseSelections(
  selections: readonly Glm52DsaLayerSelection[],
  expectedLayers: readonly number[],
  contextLength: number,
  topK: number,
): void {
  if (selections.length !== expectedLayers.length) {
    throw new Error(
      `observed ${selections.length} FULL selections, expected ${expectedLayers.length}`,
    );
  }
  for (let index = 0; index < selections.length; index++) {
    const selection = selections[index]!;
    if (selection.layer !== expectedLayers[index])
      throw new Error(`FULL selection ${index} came from layer ${selection.layer}`);
    if (
      selection.mode !== "sparse" ||
      selection.contextLength !== contextLength ||
      selection.positions.length !== topK
    ) {
      throw new Error(
        `layer ${selection.layer} did not produce sparse ${topK}-of-${contextLength}`,
      );
    }
  }
}

const cli = argumentsMap(Bun.argv.slice(2));
const modelDir = required(cli, "model");
const libraryPath = required(cli, "library");
const output = required(cli, "output");
const tracePath = cli.has("trace")
  ? resolve(cli.get("trace")!)
  : `${output}.live.jsonl`;
const logitsPath = cli.has("logits")
  ? resolve(cli.get("logits")!)
  : `${output}.decode-logits.f32`;
const maxSwapoutMiB = Number(cli.get("max-swapout-mib") ?? "64");
if (!Number.isFinite(maxSwapoutMiB) || maxSwapoutMiB <= 0)
  throw new RangeError("--max-swapout-mib must be a positive number");
const maxSwapoutDeltaBytes = Math.ceil(maxSwapoutMiB * 1024 ** 2);
mkdirSync(dirname(output), { recursive: true });
mkdirSync(dirname(logitsPath), { recursive: true });

const oldMemoryLimit = setMemoryLimit(4 * GiB);
resetPeakMemory();
let model: Glm52Model | null = null;
let currentForward = "startup";
const selections = new Map<string, Glm52DsaLayerSelection[]>([
  ["prefill", []],
  ["decode", []],
]);
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
    enableMtp: false,
  });
  if (!model.capabilities.dsa)
    throw new Error("model opened without DSA capability");
  guard.record({ phase: "opened", forward: currentForward }, true);

  const manager = model.expertRuntime!.manager;
  const originalAcquire = manager.acquireBlock.bind(manager);
  manager.acquireBlock = async (layer, expertIds, beforeMissSubmit) => {
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
      const lease = await originalAcquire(layer, expertIds, beforeMissSubmit);
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

  model.setDsaSelectionObserver((selection) => {
    selections.get(currentForward)?.push(selection);
  });
  const tokenizer = await loadTokenizer(modelDir);
  const contextTokens = model.glmConfig.indexTopk;
  const prompt = "[gMASK]<sop>" + " a".repeat(contextTokens - 2);
  const prefix = tokenizer.encode(prompt, false);
  if (prefix.length !== contextTokens) {
    throw new Error(
      `deterministic prompt encoded to ${prefix.length}, expected ${contextTokens}`,
    );
  }
  const fullLayers = model.glmConfig.indexerTypes
    .map((kind, layer) => kind === "full" ? layer : -1)
    .filter((layer) => layer >= 0);
  const opened = memory(model);
  const cache = model.makeCache();
  try {
    currentForward = "prefill";
    guard.record({ phase: "forward_before", forward: currentForward }, true);
    const prefillLogits = await model.forwardAsync(prefix, cache);
    const prefillValues = prefillLogits.toFloat32();
    const prefill = lastPrediction(prefillValues, model.glmConfig.vocabSize);
    prefillLogits.dispose();
    synchronize(gpuStream);
    clearCache();
    guard.record({ phase: "forward_after", forward: currentForward }, true);
    const afterPrefill = memory(model);

    currentForward = "decode";
    guard.record({ phase: "forward_before", forward: currentForward }, true);
    const decodeLogits = await model.forwardAsync([prefill.token], cache);
    const decodeValues = decodeLogits.toFloat32();
    const decode = lastPrediction(decodeValues, model.glmConfig.vocabSize);
    await Bun.write(
      logitsPath,
      new Uint8Array(
        decodeValues.buffer,
        decodeValues.byteOffset,
        decodeValues.byteLength,
      ),
    );
    decodeLogits.dispose();
    synchronize(gpuStream);
    clearCache();
    guard.record({ phase: "forward_after", forward: currentForward }, true);
    const afterDecode = memory(model);

    const prefillSelections = selections.get("prefill")!;
    if (
      prefillSelections.length !== fullLayers.length ||
      prefillSelections.some((selection) =>
        selection.mode !== "dense" ||
        selection.contextLength !== contextTokens)
    ) {
      throw new Error("prefill did not observe the expected dense FULL selections");
    }
    const decodeSelections = selections.get("decode")!;
    sparseSelections(
      decodeSelections,
      fullLayers,
      contextTokens + 1,
      contextTokens,
    );

    const snapshot = model.expertRuntime!.manager.snapshot();
    await Bun.write(output, JSON.stringify({
      schema_version: 1,
      gate: "GLM-5.2 DSA first sparse decode",
      scope: {
        mtp: false,
        performance_claim: false,
        prompt: "[gMASK]<sop> + repeated single-token space-a",
        prefix_tokens: contextTokens,
        sparse_context_tokens: contextTokens + 1,
        full_layers: fullLayers,
        working_slots: 64,
        slots_per_sparse_layer: 1,
        allocator_limit_bytes: 4 * GiB,
        max_swapout_delta_bytes: maxSwapoutDeltaBytes,
        live_trace: tracePath,
        decode_logits_f32le: logitsPath,
      },
      prompt_token_ids: prefix,
      trajectory: {
        greedy_token_ids: [prefill.token, decode.token],
        prefill_margin: prefill.margin,
        sparse_decode_margin: decode.margin,
      },
      dsa: {
        prefill: prefillSelections,
        sparse_decode: decodeSelections,
      },
      residency: {
        ...snapshot,
        clock: snapshot.clock.toString(),
        generation: snapshot.generation.toString(),
      },
      memory: {
        before,
        opened,
        after_prefill: afterPrefill,
        after_decode: afterDecode,
      },
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
    gate: "GLM-5.2 DSA first sparse decode",
    result: checkpoint ? "aborted_swapout_guard" : "error",
    error: error instanceof Error ? error.message : String(error),
    live_trace: tracePath,
    guard_checkpoint: checkpoint,
    memory: memory(model),
  }, null, 2) + "\n");
  throw error;
} finally {
  const cleanupErrors: unknown[] = [];
  try {
    guard.record({ phase: "cleanup_before_close", forward: currentForward }, true);
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
    clearCache();
    setMemoryLimit(oldMemoryLimit);
  } catch (error) {
    cleanupErrors.push(error);
  }
  try {
    guard.record({ phase: "cleanup_after_close", forward: currentForward }, true);
  } catch (error) {
    cleanupErrors.push(error);
  }
  if (cleanupErrors.length) {
    const cleanupError = new AggregateError(
      cleanupErrors,
      "DSA long-context probe teardown failed",
    );
    if (primaryError === null) throw cleanupError;
  }
}
