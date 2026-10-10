// E4 bit-identity gate: the DFlash 2 drafter loaded in its trained basis and
// given the target's basis when a draft group binds proposes exactly what the
// pre-change drafter (basis at load, per-call row switch; dflash2-frozen.ts)
// proposes, on small synthetic weights whose 4-bit projections fit the
// simdgroup matrix unit (and, at these widths, round differently from MLX's
// quantized matmul, so a kernel change shows in the logits). Context chunks are
// 12 and 2×12 rows, plus a commit of 4 or 2×5 rows: outside 5..8 rows, the one
// range where context projection changed kernel (the last test pins that).
import { afterAll, beforeAll, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { writeShardedSafetensors, type NamedTensor } from "../../src/artifacts/safetensors-writer";
import { Affine4MmaLinear } from "../../src/layers/affine-verify-linear";
import type { DraftProjection } from "../../src/contracts/mlx/draft-projection";
import type { ResidualBasis, TargetView } from "../../src/contracts/mlx/draft-target";
import { projectedDraftGroups } from "../../src/generation/speculative/bindings/projected-draft-rows";
import type { DraftPrefillGroup, GroupedDraftProvider } from "../../src/generation/speculative/source";
import { Dflash2Provider } from "../../src/generation/speculative/sources/dflash2-source";
import { Dflash2Drafter } from "../../src/models/speculative/dflash2";
import { FrozenDflash2Drafter, r1Signs, type Dflash2TargetBasis } from "./dflash2-frozen";

// Every 4-bit projection fits the matrix unit: K a multiple of 256, N of 8.
const H = 1024, HEADS = 8, KV_HEADS = 2, HEAD_DIM = 128, INTER = 2048, LAYERS = 2, BLOCK = 8;
const TAPS = [1, 3], TARGET_LAYERS = 4, V = 64, RANK = 16, GROUP = 16, TOP_K = 4, MASK = 63;
const CONTEXT = 12, SEED = 7;

let dir: string;
const resident: MlxArray[] = [];
let projection: DraftProjection;
/** Pre-selection logits of each draft, read back as the head returns them. */
let captured: Float32Array[] = [];
let basis: ResidualBasis;

function normal(seed: number): () => number {
  let state = seed >>> 0;
  const uniform = () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return (((t ^ (t >>> 14)) >>> 0) + 0.5) / 4294967296;
  };
  return () => Math.sqrt(-2 * Math.log(uniform())) * Math.cos(2 * Math.PI * uniform());
}

const draw = normal(20261010);
function bf16(shape: number[], scale: number, offset = 0): MlxArray {
  const data = new Float32Array(shape.reduce((a, b) => a * b, 1));
  for (let i = 0; i < data.length; i++) data[i] = offset + scale * draw();
  using f = MlxArray.fromFloat32(data, shape);
  return f.astype(Dtype.bfloat16);
}

beforeAll(() => {
  dir = mkdtempSync(join(tmpdir(), "mlx-bun-dflash2-gate-"));
  writeFileSync(join(dir, "config.json"), JSON.stringify({
    architectures: ["DFlash2DraftModel"], hidden_size: H, num_hidden_layers: LAYERS,
    num_attention_heads: HEADS, num_key_value_heads: KV_HEADS, head_dim: HEAD_DIM, rms_norm_eps: 1e-6,
    rope_parameters: { rope_type: "default", rope_theta: 1_000_000 }, num_target_layers: TARGET_LAYERS,
    dflash_config: { block_size: BLOCK, mask_token_id: MASK, conv_group_size: GROUP, conv_kernel_size: 2,
      selector_top_k: TOP_K, target_layer_ids: TAPS },
  }));
  const tensors: NamedTensor[] = [];
  const add = (name: string, array: MlxArray) => tensors.push({ name, array });
  add("fc.weight", bf16([H, TAPS.length * H], 1 / Math.sqrt(TAPS.length * H)));
  add("hidden_norm.weight", bf16([H], 0.1, 1));
  add("norm.weight", bf16([H], 0.1, 1));
  add("candidate_selector.hidden_projection.weight", bf16([RANK, H], 1 / Math.sqrt(H)));
  add("candidate_selector.predecessor_codebook", bf16([V, RANK], 0.3));
  add("candidate_selector.successor_codebook", bf16([V, RANK], 0.3));
  for (let i = 0; i < LAYERS; i++) {
    const p = `layers.${i}`;
    add(`${p}.input_layernorm.weight`, bf16([H], 0.1, 1));
    add(`${p}.post_attention_layernorm.weight`, bf16([H], 0.1, 1));
    add(`${p}.self_attn.q_proj.weight`, bf16([HEADS * HEAD_DIM, H], 1 / Math.sqrt(H)));
    add(`${p}.self_attn.k_proj.weight`, bf16([KV_HEADS * HEAD_DIM, H], 1 / Math.sqrt(H)));
    add(`${p}.self_attn.v_proj.weight`, bf16([KV_HEADS * HEAD_DIM, H], 1 / Math.sqrt(H)));
    add(`${p}.self_attn.o_proj.weight`, bf16([H, HEADS * HEAD_DIM], 1 / Math.sqrt(HEADS * HEAD_DIM)));
    add(`${p}.self_attn.q_norm.weight`, bf16([HEAD_DIM], 0.1, 1));
    add(`${p}.self_attn.k_norm.weight`, bf16([HEAD_DIM], 0.1, 1));
    add(`${p}.mlp.gate_proj.weight`, bf16([INTER, H], 1 / Math.sqrt(H)));
    add(`${p}.mlp.up_proj.weight`, bf16([INTER, H], 1 / Math.sqrt(H)));
    add(`${p}.mlp.down_proj.weight`, bf16([H, INTER], 1 / Math.sqrt(INTER)));
    for (const site of ["attention_conv", "mlp_conv"]) {
      add(`${p}.${site}.base_kernel`, bf16([2, 2, H], 0.5));
      add(`${p}.${site}.kernel_projection.weight`, bf16([4 * (H / GROUP), H], 0.1 / Math.sqrt(H)));
    }
  }
  writeShardedSafetensors(dir, tensors);
  for (const { array } of tensors) array.dispose();

  // The target: an embedding and a head over the residual basis it declares.
  const table = bf16([V, H], 1), head = bf16([V, H], 1 / Math.sqrt(H));
  const headT = ops.transposeAxes(head, [1, 0]);
  resident.push(table, head, headT);
  projection = {
    embed: { encode: ids => ops.takeAxis(table, ids, 0), scales: { dtype: Dtype.bfloat16 } },
    logitsFromHidden(hidden) {
      const logits = ops.matmul(hidden, headT);
      captured.push(logits.toFloat32());
      return logits;
    },
  };
  const gain = new Float32Array(H);
  for (let i = 0; i < H; i++) gain[i] = 0.5 + Math.abs(draw());
  basis = Object.freeze({ r1Seed: SEED, finalGain: gain });
});

afterAll(() => {
  for (const array of resident) array.dispose();
  rmSync(dir, { recursive: true, force: true });
});

const targetOf = (residualBasis: ResidualBasis | undefined): TargetView => Object.freeze({
  identity: {}, hiddenLayerTaps: { layerCount: TARGET_LAYERS, projection }, ...(residualBasis ? { residualBasis } : {}),
});

/** The pre-change provider's grouped binding around the frozen drafter. */
function frozenGroups(drafter: FrozenDflash2Drafter): GroupedDraftProvider {
  return projectedDraftGroups("frozen", drafter.tapLayers, target => ({
    namespace: "frozen", schema: "dflash2-context-v1", layers: drafter.cfg.layers,
    project(hidden, positions) {
      using context = drafter.projectContext(hidden);
      return drafter.projectContextKVRows(context, positions);
    },
    draft: (context, pending, positions, depth) =>
      drafter.draftRows(context, target.hiddenLayerTaps!.projection, pending, positions, depth),
  }));
}

interface Run { tokens: number[][]; logits: Float32Array }

/** Prefill `anchors.length` rows with the same taps, commit `accepted`, then draft each depth. */
function drafts(groups: GroupedDraftProvider, target: TargetView, taps: MlxArray, commit: MlxArray,
  anchors: readonly number[], accepted: readonly number[], depths: readonly number[]): Run[] {
  const B = anchors.length;
  // Projected rows serve prefill, commit and draft from one group.
  const rows = groups.openPrefill({ target, checkpoints: Array(B).fill(null) }) as DraftPrefillGroup & {
    commit(accepted: readonly number[], hidden: MlxArray): void; draft(pending: readonly number[], depth: number): number[][];
  };
  try {
    using tokens = ops.zeros([B, CONTEXT], Dtype.int32);
    rows.prefill(tokens, taps);
    rows.commit(accepted, commit);
    rows.materialize();
    return depths.map(depth => {
      captured = [];
      const proposed = rows.draft(anchors, depth);
      expect(captured.length).toBe(1);
      return { tokens: proposed, logits: captured[0]! };
    });
  } finally { rows.dispose(); }
}

function maxDiff(a: Float32Array, b: Float32Array): number {
  expect(a.length).toBe(b.length);
  let worst = 0;
  for (let i = 0; i < a.length; i++) {
    expect(Number.isFinite(a[i]!) && Number.isFinite(b[i]!)).toBe(true);
    worst = Math.max(worst, Math.abs(a[i]! - b[i]!));
  }
  return worst;
}

const DEPTHS = [1, 3, 7];
const CASES = [
  { anchors: [5], accepted: [3] }, // blocks of 2, 4, 8 rows; commit of 4
  { anchors: [5, 11], accepted: [4, 1] }, // blocks of 4, 8, 16 rows; commit of 2×5, rows end apart
];

for (const [bits, folded] of [[4, true], [4, false], [0, true], [0, false]] as const) {
  test(`basis at bind proposes exactly what basis at load proposed (${bits ? "4-bit" : "BF16"}, ${folded ? "R1 fold" : "trained basis"}), depths 1, 3, 7`, async () => {
    const frozenBasis: Dflash2TargetBasis | null = folded
      ? { seed: SEED, signs: r1Signs(SEED, H), finalGain: basis.finalGain } : null;
    const frozen = await FrozenDflash2Drafter.load(dir, { bits, basis: frozenBasis });
    const provider = await Dflash2Provider.load(dir, { bits });
    const mma = spyOn(Affine4MmaLinear.prototype, "forward");
    try {
      const target = targetOf(folded ? basis : undefined);
      for (const { anchors, accepted } of CASES) {
        const B = anchors.length, width = Math.max(...accepted) + 1;
        using taps = bf16([B, CONTEXT, TAPS.length * H], 1);
        using commit = bf16([B, width, TAPS.length * H], 1);
        const before = drafts(frozenGroups(frozen), target, taps, commit, anchors, accepted, DEPTHS);
        const calls = mma.mock.calls.length;
        const after = drafts(provider.grouped, target, taps, commit, anchors, accepted, DEPTHS);
        for (const [i, depth] of DEPTHS.entries()) {
          expect(maxDiff(after[i]!.logits, before[i]!.logits)).toBe(0);
          expect(after[i]!.tokens).toEqual(before[i]!.tokens);
          expect(after[i]!.tokens.every(row => row.length === depth)).toBe(true);
          expect(after[i]!.logits.length).toBe(B * depth * V);
        }
        // The new 4-bit drafter ran the matrix unit for exactly one block width: B·G = 8 rows.
        expect(mma.mock.calls.length - calls).toBe(bits ? LAYERS * 7 : 0);
      }
    } finally {
      mma.mockRestore();
      frozen.dispose();
      provider.dispose();
    }
  });
}

test("a drafter keeps the basis it was first bound to and refuses another", async () => {
  const drafter = await Dflash2Drafter.load(dir, { bits: 4 });
  try {
    drafter.bindResidualBasis(basis);
    drafter.bindResidualBasis(basis);
    expect(() => drafter.bindResidualBasis(null))
      .toThrow("this DFlash 2 drafter is bound to a target with a different residual basis");
    expect(() => drafter.bindResidualBasis({ r1Seed: SEED, finalGain: basis.finalGain }))
      .toThrow("this DFlash 2 drafter is bound to a target with a different residual basis");
  } finally { drafter.dispose(); }
});

test("context projection runs MLX's quantized matmul at every row count (the matrix unit only drafts)", async () => {
  const frozen = await FrozenDflash2Drafter.load(dir, { bits: 4, basis: null });
  const drafter = await Dflash2Drafter.load(dir, { bits: 4 });
  drafter.bindResidualBasis(null);
  const mma = spyOn(Affine4MmaLinear.prototype, "forward");
  try {
    using taps = bf16([1, 6, TAPS.length * H], 1);
    using frozenContext = frozen.projectContext(taps);
    for (const pair of frozen.projectContextKVRows(frozenContext, 0)) { pair.k.dispose(); pair.v.dispose(); }
    // Before E4 a 6-row chunk took the matrix unit: fc, then k and v per layer.
    expect(mma.mock.calls.length).toBe(1 + 2 * LAYERS);
    using context = drafter.projectContext(taps);
    const kv = drafter.projectContextKVRows(context, 0);
    ops.evalAll(kv.flatMap(pair => [pair.k, pair.v]));
    for (const pair of kv) { pair.k.dispose(); pair.v.dispose(); }
    expect(mma.mock.calls.length).toBe(1 + 2 * LAYERS);
  } finally {
    mma.mockRestore();
    frozen.dispose();
    drafter.dispose();
  }
});
