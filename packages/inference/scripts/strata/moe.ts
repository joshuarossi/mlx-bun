import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";
import { strataSource, body } from "./source";

const ROUTE = String.raw`
  const int row = threadgroup_position_in_grid.x, lane = thread_index_in_simdgroup;
  float v[16];
  float mx = -INFINITY;
  for (int i = 0; i < 16; ++i) { v[i] = logits[row * 512 + lane + 32 * i]; mx = max(mx, v[i]); }
  mx = simd_max(mx);
  float sum = 0.0f;
  for (int i = 0; i < 16; ++i) { v[i] = exp(v[i] - mx); sum += v[i]; }
  sum = simd_sum(sum);
  for (int i = 0; i < 16; ++i) v[i] /= sum;
  float selected = 0.0f;
  for (int rank = 0; rank < TOP; ++rank) {
    float best = -INFINITY;
    int ex = 2147483647;
    for (int i = 0; i < 16; ++i) if (v[i] > best) { best = v[i]; ex = lane + 32 * i; }
    const float top = simd_max(best);
    ex = simd_min(best == top ? ex : 2147483647);
    if ((ex & 31) == lane) v[ex / 32] = -INFINITY;
    if (lane == rank) { selected = top; ids[row * TOP + rank] = ex; }
  }
  const float norm = simd_sum(selected);
  if (lane < TOP) weights[row * TOP + lane] = selected / norm;
`;
let router: MetalKernel | undefined;
export function route(logits: MlxArray, top: number): MlxArray[] {
  router ??= new MetalKernel({ name: "strata_screen_route", inputNames: ["logits"], outputNames: ["ids", "weights"], source: ROUTE });
  return router.apply([logits], { outputs: [{ shape: [logits.shape[0]!, top], dtype: Dtype.int32 }, { shape: [logits.shape[0]!, top], dtype: Dtype.float32 }],
    grid: [logits.shape[0]! * 32, 1, 1], threadGroup: [32, 1, 1], templateInts: { TOP: top } });
}
export function referenceRoute(logits: MlxArray, top: number): MlxArray[] {
  using gates = ops.softmaxAxis(logits, -1, true);
  using partition = ops.argpartitionAxis(gates, 512 - top, -1);
  const indices = partition.slice([0, 512 - top], [logits.shape[0]!, 512]);
  using selected = ops.takeAlongAxis(gates, indices, -1);
  using denominator = ops.sumAxis(selected, -1, true);
  return [indices, ops.div(selected, denominator)];
}

export class ExpertPlan {
  readonly sha256: string;
  readonly hist: MetalKernel; readonly scan: MetalKernel; readonly place: MetalKernel;
  constructor(root: string) {
    const { source, sha256 } = strataSource(root, "moe_mm.metal");
    this.sha256 = sha256;
    const header = "struct MmPlanArgs { uint n_ent, topk, n_expert, tm, n_blocks; };";
    const pre = `const uint3 tg = threadgroup_position_in_grid;
      const ushort tid = thread_index_in_threadgroup, sg = simdgroup_index_in_threadgroup, lane = thread_index_in_simdgroup;
      const MmPlanArgs a{ENT, TOP, EXPERTS, TILE, BLOCKS};\n`;
    this.hist = new MetalKernel({ name: "strata_screen_hist", inputNames: ["ids"], outputNames: ["bcnt"], header, source: pre + body(source, "mm_hist") });
    this.scan = new MetalKernel({ name: "strata_screen_scan", inputNames: ["bcnt"], outputNames: ["boff", "eoff", "tiles", "meta"], header,
      source: pre + "device int2* tiles2 = (device int2*)tiles;\n" + body(source, "mm_scan").replaceAll("tiles[", "tiles2[") + "\nif (tid == 0) { meta[2] = 1; meta[5] = 1; }" });
    this.place = new MetalKernel({ name: "strata_screen_place", inputNames: ["ids", "w", "boff", "eoff"], outputNames: ["srt_tok", "srt_w", "pos"], header, source: pre + body(source, "mm_place") });
  }
  apply(ids: MlxArray, weights: MlxArray, experts: number, top: number): MlxArray[] {
    const ENT = ids.size, TILE = 16, BLOCKS = Math.ceil(ENT / 1024), max = ENT + experts * TILE;
    const templateInts = { ENT, TOP: top, EXPERTS: experts, TILE, BLOCKS };
    const u = (shape: number[]) => ({ shape, dtype: Dtype.uint32 });
    const [counts] = this.hist.apply([ids], { outputs: [u([BLOCKS, experts])], grid: [BLOCKS * 1024, 1, 1], threadGroup: [1024, 1, 1], templateInts });
    try {
      const [offsets, starts, tiles, meta] = this.scan.apply([counts!], { outputs: [u([BLOCKS, experts]), u([experts]), { shape: [Math.ceil(max / TILE), 2], dtype: Dtype.int32 }, u([11])],
        grid: [experts, 1, 1], threadGroup: [experts, 1, 1], templateInts });
      try {
        const [tokens, sortedWeights, positions] = this.place.apply([ids, weights, offsets!, starts!], {
          outputs: [{ shape: [max], dtype: Dtype.int32 }, { shape: [max], dtype: Dtype.float32 }, { shape: ids.shape, dtype: Dtype.int32 }],
          grid: [BLOCKS * 1024, 1, 1], threadGroup: [1024, 1, 1], templateInts, initValue: -1 });
        return [positions!, tokens!, sortedWeights!, starts!, meta!, tiles!];
      } catch (error) { starts?.dispose(); meta?.dispose(); tiles?.dispose(); throw error; }
      finally { offsets?.dispose(); }
    } finally { counts?.dispose(); }
  }
  dispose() { this.hist.dispose(); this.scan.dispose(); this.place.dispose(); }
  [Symbol.dispose]() { this.dispose(); }
}

export function sortedPlan(ids: MlxArray, weights: MlxArray, top: number): MlxArray[] {
  using flat = ops.reshape(ids, [ids.size]);
  const order = ops.argsortAxis(flat, 0), inverse = ops.argsortAxis(order, 0);
  using n = ops.scalarLike(top, order);
  using flatWeights = ops.reshape(weights, [weights.size]);
  return [order, inverse, ops.floorDivide(order, n), ops.takeAxis(flatWeights, order, 0)];
}
