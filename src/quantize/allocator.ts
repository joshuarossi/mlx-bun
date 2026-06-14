// Mixed-precision quantization optimizer: select per-layer bit-widths.
//
// 1:1 port of optiq/core/optimizer.py `optimize_mixed_precision` (the pure
// data-logic knapsack). Every helper is faithful to the Python:
//
//   - greedy min-heap knapsack with `(-efficiency, layerName, old, new, klRed)`
//     ordering (Python heapq tuple comparison, reproduced exactly)
//   - block-aware floor with the attention-reserve carve-out
//   - protected-layer ×100 KL bonus (output / MoE-router / boundary layers)
//   - `_kl_reduction` uniform-vs-bf16 reference-mode sign detection
//   - NaN-sensitivity handling (treat as maximally sensitive)
//   - post-greedy block-run guard
//
// Verified bit-for-bit against the Python via tests/quantize-allocator.test.ts.
//
// The latency-aware variants (`optimize_latency_aware`,
// `optimize_for_latency_budget`) are intentionally NOT ported — they pull in
// optiq's hardware/latency model, which is out of scope for this port (the
// quality-only knapsack is the sensitivity-driven core).

import type { SensitivityResult } from "./sensitivity";

/** Per-layer chosen bit-width (port of optiq LayerQuantConfig). */
export interface LayerQuantConfig {
  layerName: string;
  bits: number;
  groupSize: number;
  paramCount: number;
}

/** Result of the knapsack (port of optiq OptimizationResult, quality fields). */
export interface OptimizationResult {
  configs: LayerQuantConfig[];
  targetBpw: number;
  achievedBpw: number;
  /** Kept for parity with the Python type; always 0 for multi-tier. */
  threshold: number;
  nHighBits: number;
  nLowBits: number;
  totalParams: number;
  estimatedSizeMb: number;
}

export interface OptimizeMixedPrecisionOptions {
  targetBpw?: number;
  candidateBits?: number[];
  groupSize?: number;
  protectFirstLast?: boolean;
  nProtect?: number;
  nFloorPerBlock?: number;
  maxLowBitRun?: number;
  /** Pre-N-tier shims; ignored when candidateBits is set explicitly. */
  lowBits?: number;
  highBits?: number;
}

// --------------------------------------------------------------------------
// Min-heap matching Python heapq's ordering on the upgrade tuple.
// --------------------------------------------------------------------------

/** Upgrade-candidate tuple, in Python heapq comparison order:
 *  (-efficiency, layerName, oldBits, newBits, klReduction). */
export type UpgradeEntry = [number, string, number, number, number];

/** Lexicographic comparison of two upgrade tuples, mirroring Python's tuple
 *  comparison used by heapq (numeric fields numerically, the name lexically).
 *  Returns <0 if a < b, >0 if a > b, 0 if equal. */
function compareUpgrade(a: UpgradeEntry, b: UpgradeEntry): number {
  if (a[0] !== b[0]) return a[0] < b[0] ? -1 : 1; // -efficiency
  if (a[1] !== b[1]) return a[1] < b[1] ? -1 : 1; // layerName (string)
  if (a[2] !== b[2]) return a[2] < b[2] ? -1 : 1; // oldBits
  if (a[3] !== b[3]) return a[3] < b[3] ? -1 : 1; // newBits
  if (a[4] !== b[4]) return a[4] < b[4] ? -1 : 1; // klReduction
  return 0;
}

/** Binary min-heap over UpgradeEntry with Python-heapq tuple ordering.
 *  Dependency-free; sift-up/sift-down identical in behavior to heapq. */
export class UpgradeHeap {
  private readonly data: UpgradeEntry[] = [];

  get length(): number {
    return this.data.length;
  }

  push(entry: UpgradeEntry): void {
    const d = this.data;
    d.push(entry);
    let i = d.length - 1;
    while (i > 0) {
      const parent = (i - 1) >> 1;
      if (compareUpgrade(d[i]!, d[parent]!) < 0) {
        const tmp = d[i]!;
        d[i] = d[parent]!;
        d[parent] = tmp;
        i = parent;
      } else break;
    }
  }

  pop(): UpgradeEntry | undefined {
    const d = this.data;
    if (d.length === 0) return undefined;
    const top = d[0]!;
    const last = d.pop()!;
    if (d.length > 0) {
      d[0] = last;
      let i = 0;
      const n = d.length;
      for (;;) {
        const l = 2 * i + 1;
        const r = 2 * i + 2;
        let smallest = i;
        if (l < n && compareUpgrade(d[l]!, d[smallest]!) < 0) smallest = l;
        if (r < n && compareUpgrade(d[r]!, d[smallest]!) < 0) smallest = r;
        if (smallest === i) break;
        const tmp = d[i]!;
        d[i] = d[smallest]!;
        d[smallest] = tmp;
        i = smallest;
      }
    }
    return top;
  }
}

// --------------------------------------------------------------------------
// compute_bpw / _compute_allocation_bpw
// --------------------------------------------------------------------------

/** Average bits-per-weight from layer configs (port of compute_bpw). */
export function computeBpw(configs: LayerQuantConfig[]): number {
  let totalBits = 0;
  let totalParams = 0;
  for (const c of configs) {
    totalBits += c.bits * c.paramCount;
    totalParams += c.paramCount;
  }
  if (totalParams === 0) return 0;
  return totalBits / totalParams;
}

/** BPW from a layer->bits allocation map (port of _compute_allocation_bpw). */
function computeAllocationBpw(
  allocation: Map<string, number>,
  results: SensitivityResult[],
): number {
  let totalBits = 0;
  let totalParams = 0;
  for (const r of results) {
    totalBits += allocation.get(r.layerName)! * r.paramCount;
    totalParams += r.paramCount;
  }
  return totalBits / Math.max(totalParams, 1);
}

// --------------------------------------------------------------------------
// KL-reduction (reference-mode autodetect) + heap push
// --------------------------------------------------------------------------

/** Quality benefit of upgrading current→next bits (port of _kl_reduction).
 *
 *  Two reference-mode semantics, autodetected by the sign of (kl_next - kl_cur):
 *   - bf16 reference: sensitivities[b] = KL(bf16 || b-bit); upgrading reduces
 *     KL → benefit = kl_current - kl_next.
 *   - uniform-N reference: sensitivities[baseline_bit] ≈ 0; sensitivities[b>base]
 *     measures how much upgrading moves output back toward bf16 (the benefit
 *     directly). Treat kl_next > kl_current as the uniform-mode signal. */
export function klReduction(
  r: SensitivityResult,
  currentBits: number,
  nextBits: number,
): number {
  const klCurrent = r.sensitivities[currentBits] ?? 0;
  const klNext = r.sensitivities[nextBits] ?? 0;
  if (nextBits > currentBits && klNext > klCurrent) {
    return klNext - klCurrent;
  }
  return klCurrent - klNext;
}

/** Push the next upgrade step for a layer (port of _push_next_upgrade). */
function pushNextUpgrade(
  heap: UpgradeHeap,
  r: SensitivityResult,
  currentBits: number,
  candidateBits: number[],
): void {
  const idx = candidateBits.indexOf(currentBits);
  if (idx < 0 || idx >= candidateBits.length - 1) return; // already at max

  const nextBits = candidateBits[idx + 1]!;
  const klRed = klReduction(r, currentBits, nextBits);
  if (klRed <= 0) return; // no benefit

  const bitCost = (nextBits - currentBits) * r.paramCount;
  const efficiency = klRed / Math.max(bitCost, 1);

  // max-heap via negative efficiency
  heap.push([-efficiency, r.layerName, currentBits, nextBits, klRed]);
}

// --------------------------------------------------------------------------
// Protected-layer identification (output / MoE / boundary)
// --------------------------------------------------------------------------

/** Output-projection layers that always get high bits (port of
 *  _identify_output_layers). lm_head, embeddings, output proj, plus any layer
 *  not inside a "layers.N" block. */
function identifyOutputLayers(layerNames: string[]): Set<string> {
  const protectedSet = new Set<string>();
  const outputKeywords = [
    "lm_head", "embed_tokens", "wte", "wpe", "output_proj", "embed_out", "head",
  ];
  for (const name of layerNames) {
    const nameLower = name.toLowerCase();
    const parts = nameLower.split(".");
    const last = parts[parts.length - 1] ?? "";
    const lastTwo = parts.slice(-2);
    for (const kw of outputKeywords) {
      // Python: `kw in name_lower.split(".")[-1]` (substring of last segment)
      //         OR `kw in name_lower.split(".")[-2:]` (membership in last two)
      if (last.includes(kw) || lastTwo.includes(kw)) {
        protectedSet.add(name);
        break;
      }
    }
    // Also protect if the layer is NOT inside a "layers.N" block.
    if (!name.split(".").includes("layers")) {
      protectedSet.add(name);
    }
  }
  return protectedSet;
}

/** MoE router projections and shared-expert MLPs to protect (port of
 *  _identify_moe_protected_layers). */
function identifyMoeProtectedLayers(layerNames: string[]): Set<string> {
  const protectedSet = new Set<string>();
  for (const name of layerNames) {
    const parts = name.split(".");
    if (parts.length === 0) continue;
    const last = parts[parts.length - 1]!;
    const prev = parts.length >= 2 ? parts[parts.length - 2]! : "";

    // Router patterns: mlp.gate (Qwen3 MoE router, distinct from mlp.gate_proj),
    // router, router.proj (Gemma-style).
    if (
      (last === "gate" && prev === "mlp") ||
      last === "router" ||
      (last === "proj" && prev === "router")
    ) {
      protectedSet.add(name);
      continue;
    }

    // Shared-expert MLPs (any segment).
    if (name.includes(".shared_experts.") || name.includes(".shared_expert.")) {
      protectedSet.add(name);
      continue;
    }
  }
  return protectedSet;
}

/** First and last transformer block layers to protect (port of
 *  _identify_boundary_layers). */
function identifyBoundaryLayers(
  layerNames: string[],
  nProtect: number,
): Set<string> {
  const layerIndices = new Map<number, string[]>();
  for (const name of layerNames) {
    const parts = name.split(".");
    for (let i = 0; i < parts.length; i++) {
      if (parts[i] === "layers" && i + 1 < parts.length) {
        const idx = Number.parseInt(parts[i + 1]!, 10);
        if (!Number.isNaN(idx)) {
          if (!layerIndices.has(idx)) layerIndices.set(idx, []);
          layerIndices.get(idx)!.push(name);
        }
      }
    }
  }

  if (layerIndices.size === 0) return new Set();

  const sortedIndices = [...layerIndices.keys()].sort((a, b) => a - b);
  const protectedSet = new Set<string>();
  for (const idx of sortedIndices.slice(0, nProtect)) {
    for (const n of layerIndices.get(idx)!) protectedSet.add(n);
  }
  for (const idx of sortedIndices.slice(-nProtect)) {
    for (const n of layerIndices.get(idx)!) protectedSet.add(n);
  }
  return protectedSet;
}

// --------------------------------------------------------------------------
// Block helpers (floor + run-guard)
// --------------------------------------------------------------------------

/** Extract transformer block index from a layer name (port of _block_index).
 *  e.g. "...layers.7.mlp.up_proj" → 7. */
function blockIndex(layerName: string): number | null {
  const m = /layers\.(\d+)/.exec(layerName);
  return m ? Number.parseInt(m[1]!, 10) : null;
}

const ATTENTION_TOKENS: ReadonlySet<string> = new Set([
  // Full-attention (Qwen, Llama, Gemma): q/k/v/o
  "q_proj", "k_proj", "v_proj", "o_proj",
  // Linear-attention / GatedDeltaNet (Qwen3.5/3.6 hybrid)
  "in_proj_qkv", "in_proj_a", "in_proj_b", "in_proj_z", "out_proj",
  // MoE attention variants and generic fall-throughs
  "qkv_proj", "wqkv", "Wqkv", "attn_qkv",
]);

/** Does this linear sit inside attention? (port of _is_attention_component) */
function isAttentionComponent(layerName: string): boolean {
  const idx = layerName.lastIndexOf(".");
  const last = idx >= 0 ? layerName.slice(idx + 1) : layerName;
  return ATTENTION_TOKENS.has(last);
}

/** Pre-upgrade per-block components lowest_bit → second_lowest_bit (port of
 *  _apply_block_aware_floor). Returns the number of upgrades applied. */
function applyBlockAwareFloor(
  allocation: Map<string, number>,
  sensitivityResults: SensitivityResult[],
  lowestBit: number,
  secondLowestBit: number,
  nFloor: number,
): number {
  const blockLayers = new Map<number, Array<[number, string]>>();
  for (const r of sensitivityResults) {
    const idx = blockIndex(r.layerName);
    if (idx === null) continue;
    const klLow = r.sensitivities[lowestBit] ?? 0;
    if (!blockLayers.has(idx)) blockLayers.set(idx, []);
    blockLayers.get(idx)!.push([klLow, r.layerName]);
  }

  let upgrades = 0;
  for (const layers of blockLayers.values()) {
    if (layers.length === 0) continue;
    // most-sensitive first (stable like Python's Timsort on key=-x[0])
    stableSort(layers, (a, b) => b[0] - a[0]);

    const attn = layers.filter(([, n]) => isAttentionComponent(n));

    // Reserve attention slots first. Full-attention blocks (q/k/v/o all
    // present) get 2 reserved; single-projection blocks get 1.
    let nAttnReserve = attn.length >= 4 ? 2 : attn.length > 0 ? 1 : 0;
    nAttnReserve = Math.min(nAttnReserve, nFloor);

    const isFullAttnBlock = attn.length >= 4;
    const blockFloor = isFullAttnBlock ? nFloor : Math.min(nFloor, 1);

    const picks: string[] = [];
    for (const [, name] of attn.slice(0, nAttnReserve)) picks.push(name);

    const pickedSet = new Set<string>(picks);
    for (const [, name] of layers) {
      if (picks.length >= blockFloor) break;
      if (pickedSet.has(name)) continue;
      picks.push(name);
      pickedSet.add(name);
    }

    for (const name of picks) {
      if ((allocation.get(name) ?? lowestBit) < secondLowestBit) {
        allocation.set(name, secondLowestBit);
        upgrades++;
      }
    }
  }
  return upgrades;
}

/** Scan for runs of consecutive low-bit-dominated blocks and upgrade their
 *  worst components (port of _enforce_block_run_limit). */
function enforceBlockRunLimit(
  allocation: Map<string, number>,
  sensitivityResults: SensitivityResult[],
  lowestBit: number,
  secondLowestBit: number,
  maxRun: number,
): number {
  const byBlock = new Map<number, string[]>();
  const sensMap = new Map<string, SensitivityResult>();
  for (const r of sensitivityResults) sensMap.set(r.layerName, r);
  for (const name of allocation.keys()) {
    const idx = blockIndex(name);
    if (idx === null) continue;
    if (!byBlock.has(idx)) byBlock.set(idx, []);
    byBlock.get(idx)!.push(name);
  }

  const blockIndices = [...byBlock.keys()].sort((a, b) => a - b);
  const lowDom = new Map<number, boolean>();
  for (const idx of blockIndices) {
    const layers = byBlock.get(idx)!;
    let low = 0;
    for (const n of layers) if (allocation.get(n) === lowestBit) low++;
    lowDom.set(idx, low / Math.max(layers.length, 1) > 0.5);
  }

  let upgrades = 0;
  let runStart: number | null = null;
  for (let i = 0; i < blockIndices.length; i++) {
    const idx = blockIndices[i]!;
    if (lowDom.get(idx)) {
      if (runStart === null) runStart = i;
    }
    if (!lowDom.get(idx) || i === blockIndices.length - 1) {
      const runEnd = !lowDom.get(idx) ? i : i + 1;
      if (runStart !== null && runEnd - runStart > maxRun) {
        const middle = blockIndices.slice(runStart, runEnd);
        const stride = Math.max(1, maxRun);
        for (let m = 0; m < middle.length; m += stride) {
          const blk = middle[m]!;
          const candidates: Array<[number, string]> = [];
          for (const n of byBlock.get(blk)!) {
            if (allocation.get(n) === lowestBit) {
              candidates.push([sensMap.get(n)!.sensitivities[lowestBit] ?? 0, n]);
            }
          }
          stableSort(candidates, (a, b) => b[0] - a[0]);
          for (const [, name] of candidates.slice(0, 1)) {
            allocation.set(name, secondLowestBit);
            upgrades++;
          }
        }
      }
      runStart = null;
    }
  }
  return upgrades;
}

/** Stable sort in place — Python's list.sort is stable; JS Array.sort is
 *  spec-stable since ES2019 (and in Bun's JSC), but we keep an explicit
 *  stable sort to be bit-exact regardless of engine. */
function stableSort<T>(arr: T[], cmp: (a: T, b: T) => number): void {
  const indexed = arr.map((v, i) => [v, i] as [T, number]);
  indexed.sort((a, b) => {
    const c = cmp(a[0], b[0]);
    return c !== 0 ? c : a[1] - b[1];
  });
  for (let i = 0; i < arr.length; i++) arr[i] = indexed[i]![0];
}

// --------------------------------------------------------------------------
// Public entry: optimize_mixed_precision
// --------------------------------------------------------------------------

/** Select per-layer bit-widths via greedy knapsack (1:1 port of
 *  optiq.core.optimizer.optimize_mixed_precision). */
export function optimizeMixedPrecision(
  sensitivityResults: SensitivityResult[],
  options: OptimizeMixedPrecisionOptions = {},
): OptimizationResult {
  const targetBpw = options.targetBpw ?? 4.0;
  const groupSize = options.groupSize ?? 64;
  const protectFirstLast = options.protectFirstLast ?? true;
  const nProtect = options.nProtect ?? 1;
  const nFloorPerBlock = options.nFloorPerBlock ?? 2;
  const maxLowBitRun = options.maxLowBitRun ?? 3;
  const lowBits = options.lowBits ?? 4;
  const highBits = options.highBits ?? 8;

  if (sensitivityResults.length === 0) {
    return {
      configs: [], targetBpw, achievedBpw: 0, threshold: 0,
      nHighBits: 0, nLowBits: 0, totalParams: 0, estimatedSizeMb: 0,
    };
  }

  // Infer candidate bits from sensitivity data if not provided.
  let candidateBits = options.candidateBits;
  if (candidateBits === undefined) {
    const allBits = new Set<number>();
    for (const r of sensitivityResults) {
      for (const b of Object.keys(r.sensitivities)) allBits.add(Number(b));
    }
    candidateBits = [...allBits].sort((a, b) => a - b);
  }
  if (candidateBits.length === 0) candidateBits = [lowBits, highBits];

  candidateBits = [...candidateBits].sort((a, b) => a - b);
  const minBits = candidateBits[0]!;
  const maxBits = candidateBits[candidateBits.length - 1]!;

  const layerNames = sensitivityResults.map((r) => r.layerName);

  // Identify protected layers.
  const protectedLayers = new Set<string>();
  for (const n of identifyOutputLayers(layerNames)) protectedLayers.add(n);
  for (const n of identifyMoeProtectedLayers(layerNames)) protectedLayers.add(n);
  if (protectFirstLast) {
    for (const n of identifyBoundaryLayers(layerNames, nProtect)) protectedLayers.add(n);
  }

  let totalParams = 0;
  for (const r of sensitivityResults) totalParams += r.paramCount;

  // Initialize all layers at minimum bits.
  const allocation = new Map<string, number>();
  for (const r of sensitivityResults) allocation.set(r.layerName, minBits);

  // Block-aware floor.
  let floorUpgrades = 0;
  if (nFloorPerBlock > 0 && candidateBits.length >= 2) {
    const secondLowest = candidateBits[1]!;
    floorUpgrades = applyBlockAwareFloor(
      allocation, sensitivityResults, candidateBits[0]!, secondLowest, nFloorPerBlock,
    );
  }

  // NaN-sensitivity handling — treat as maximally sensitive.
  const nanLayers = new Set<string>();
  let cleanedResults: SensitivityResult[] = [];
  for (const r of sensitivityResults) {
    const hasNan = Object.values(r.sensitivities).some((v) => Number.isNaN(v));
    if (hasNan) {
      nanLayers.add(r.layerName);
      let maxFinite = Number.NEGATIVE_INFINITY;
      for (const v of Object.values(r.sensitivities)) {
        if (!Number.isNaN(v) && v > maxFinite) maxFinite = v;
      }
      if (maxFinite === Number.NEGATIVE_INFINITY) maxFinite = 1e6;
      const fixedSens: Record<number, number> = {};
      for (const [bStr, v] of Object.entries(r.sensitivities)) {
        const b = Number(bStr);
        fixedSens[b] = Number.isNaN(v)
          ? maxFinite * 10 * (maxBits / Math.max(b, 1))
          : v;
      }
      cleanedResults.push({
        layerName: r.layerName, sensitivities: fixedSens, paramCount: r.paramCount,
      });
    } else {
      cleanedResults.push(r);
    }
  }
  if (nanLayers.size > 0) {
    sensitivityResults = cleanedResults;
  }

  // Effective results — protected layers get a ×100 KL bonus so they upgrade first.
  const effectiveResults = new Map<string, SensitivityResult>();
  for (const r of sensitivityResults) {
    if (protectedLayers.has(r.layerName)) {
      const boosted: Record<number, number> = {};
      for (const [bStr, v] of Object.entries(r.sensitivities)) {
        boosted[Number(bStr)] = v * 100.0;
      }
      effectiveResults.set(r.layerName, {
        layerName: r.layerName, sensitivities: boosted, paramCount: r.paramCount,
      });
    } else {
      effectiveResults.set(r.layerName, r);
    }
  }

  // Build upgrade candidates.
  const upgradeHeap = new UpgradeHeap();
  for (const r of sensitivityResults) {
    const current = allocation.get(r.layerName)!;
    pushNextUpgrade(upgradeHeap, effectiveResults.get(r.layerName)!, current, candidateBits);
  }

  // Greedy: target_bpw is a FLOOR — keep upgrading until BPW ≥ target.
  while (
    upgradeHeap.length > 0 &&
    computeAllocationBpw(allocation, sensitivityResults) < targetBpw
  ) {
    const entry = upgradeHeap.pop()!;
    const [, layerName, oldBits, newBits] = entry;

    if (allocation.get(layerName) !== oldBits) continue; // stale

    allocation.set(layerName, newBits);
    pushNextUpgrade(upgradeHeap, effectiveResults.get(layerName)!, newBits, candidateBits);
  }

  // Post-greedy block-run guard.
  let runfixUpgrades = 0;
  if (maxLowBitRun > 0 && candidateBits.length >= 2) {
    runfixUpgrades = enforceBlockRunLimit(
      allocation, sensitivityResults, candidateBits[0]!, candidateBits[1]!, maxLowBitRun,
    );
  }
  void floorUpgrades;
  void runfixUpgrades;

  // Build configs (in sensitivityResults order, matching Python).
  const configs: LayerQuantConfig[] = sensitivityResults.map((r) => ({
    layerName: r.layerName,
    bits: allocation.get(r.layerName)!,
    groupSize,
    paramCount: r.paramCount,
  }));

  const achievedBpw = computeBpw(configs);
  let nMax = 0;
  let nMin = 0;
  let estBits = 0;
  for (const c of configs) {
    if (c.bits === maxBits) nMax++;
    if (c.bits === minBits) nMin++;
    estBits += c.bits * c.paramCount;
  }
  const estSizeMb = estBits / 8 / (1024 * 1024);

  return {
    configs,
    targetBpw,
    achievedBpw,
    threshold: 0,
    nHighBits: nMax,
    nLowBits: nMin,
    totalParams,
    estimatedSizeMb: estSizeMb,
  };
}
