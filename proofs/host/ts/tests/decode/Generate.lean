import host.ts.tests.decode.Stand
import host.ts.tests.decode.Checkpoint
import host.ts.ast.inference.artifacts.Config
import host.ts.ast.inference.artifacts.Safetensors
import host.ts.ast.inference.artifacts.Weights
import host.ts.ast.inference.contracts.portable.Composition
import host.ts.ast.inference.contracts.portable.Prefill
import host.ts.ast.inference.generation.Autoregressive
import host.ts.ast.inference.generation.bindings.Autoregressive
import host.ts.ast.inference.generation.PhaseDispatch
import host.ts.ast.inference.generation.Prefill
import host.ts.ast.inference.generation.Result
import host.ts.ast.inference.generation.Scopes
import host.ts.ast.inference.kernels.delta.Gated
import host.ts.ast.inference.kernels.delta.SiluRmsHeads
import host.ts.ast.inference.kernels.GatedRmsNorm
import host.ts.ast.inference.kernels.quantization.AffineRow
import host.ts.ast.inference.kernels.ResidualRmsNorm
import host.ts.ast.inference.kernels.sampling.NormalizedArgmax
import host.ts.ast.inference.kernels.trellis.Codebook
import host.ts.ast.inference.kernels.trellis.DownCodebook
import host.ts.ast.inference.kernels.trellis.GateUpCodebook
import host.ts.ast.inference.kernels.trellis.Launch
import host.ts.ast.inference.layers.AffineVerifyLinear
import host.ts.ast.inference.layers.CompiledNormalization
import host.ts.ast.inference.layers.DeltaHeads
import host.ts.ast.inference.layers.Helpers
import host.ts.ast.inference.layers.Lora
import host.ts.ast.inference.layers.Normalization
import host.ts.ast.inference.layers.QuantizedEmbedding
import host.ts.ast.inference.layers.QuantizedLinear
import host.ts.ast.inference.layers.Swiglu
import host.ts.ast.inference.layers.TrellisCodebookDown
import host.ts.ast.inference.layers.TrellisCodebookGateUp
import host.ts.ast.inference.layers.TrellisLinear
import host.ts.ast.inference.layers.TrellisPrompt
import host.ts.ast.inference.models.qwen.Blocks
import host.ts.ast.inference.models.qwen.Checkpoint
import host.ts.ast.inference.models.qwen.WrittenLayers
import host.ts.ast.inference.runtime.Config
import host.ts.ast.inference.runtime.GraphForward
import host.ts.ast.inference.runtime.RowOperations
import host.ts.ast.inference.sampling.Extras
import host.ts.ast.inference.sampling.Index
import host.ts.ast.inference.sampling.Processors
import host.ts.ast.inference.sampling.Step
import host.ts.ast.inference.sampling.WindowFilters
import host.ts.ast.inference.state.AttentionRead
import host.ts.ast.inference.state.Kv
import host.ts.ast.inference.state.RequestPolicy
import host.ts.ast.inference.state.Ssm
import host.ts.ast.mlx.Array
import host.ts.ast.mlx.Compile
import host.ts.ast.mlx.Ffi
import host.ts.ast.mlx.Materialize
import host.ts.ast.mlx.MetalKernel
import host.ts.ast.mlx.Ops
namespace Host.Ts.Tests.Decode.Generate
open Host.Ts

/-! The decode route's generation loop over the first block of `#one` (layers 0-3, stand-in
construction, `Stand`): the library's `generateAutoregressive` for a one-token prompt, consumed by
`for await`. The driver repositions the caller-owned caches between yields, so the iteration after
the yield of token 1 runs at symbolic cache offset `n` (capacity `c`) and the one after token 2 at
offset `c` = capacity (the growth step); `maxTokens` is the symbolic `M`, the read-back tokens are
symbolic (number-table entries 3 …). -/

/-- The driver: the repository's loader pieces and `generateAutoregressive`, over the stand-in
model and binding (see the source's comments). -/
def source : String := r#"
import { Weights } from "./artifacts/weights";
import { SafetensorsFile, ShardedSafetensors } from "./artifacts/safetensors";
import { parseQuantization } from "./artifacts/config";
import { Qwen38TrellisM1Max } from "./__qwen38one";
import { KVCache } from "./state/kv";
import { AttentionMasks } from "./state/attention-read";
import { SSMCache } from "./state/ssm";
import { MlxPhaseDispatch } from "./generation/phase-dispatch";
import { generateAutoregressive } from "./generation/autoregressive";
import * as ops from "@mlx-bun/mlx/ops";
import { SHARDS, QUANTIZATION } from "checkpoint";
import { n, c, M } from "sym";
const DIR = "/models/qwen3.8";
const PROMPT = 9707;
const text = { hiddenSize: 5120, numHiddenLayers: 64, numAttentionHeads: 24, numKeyValueHeads: 4, headDim: 256,
  intermediateSize: 17408, rmsNormEps: 0.000001, linearNumValueHeads: 48, linearNumKeyHeads: 16, linearKeyHeadDim: 128,
  linearValueHeadDim: 128, linearConvKernelDim: 4, fullAttentionInterval: 4, attnOutputGate: true, partialRotaryFactor: 0.25,
  vocabSize: 248320, ropeParameters: { full_attention: { ropeTheta: 10000000, ropeType: "default", partialRotaryFactor: 0.25, factor: 1 } } };
// STAND-IN for the loader's binding of this graph (its first block: the cache layers 0-3) (`bindMlxAutoregressiveGraph`, generation/bindings/autoregressive.ts,
// over `composeGraphCaches` of the graph's `cacheLayers` under the default bf16 KV composition, models/cache-composition.ts):
// the fields generateInner reads on this route. The graph declares no compiled decode step (no `createDecode`), and
// config.json's eos_token_id is 248044. The KV caches omit the dense TurboQuant kernels and the folded window read,
// which only TurboQuant conversion and window appends read.
function makeCache() {
  const masks = new AttentionMasks();
  const caches = [];
  for (let i = 0; i < 4; i++) caches.push(i % 4 === 3 ? new KVCache(masks) : new SSMCache());
  return caches;
}
function bind(model) {
  return {
    descriptor: Object.freeze({ id: "legacy:qwen3_5", artifact: "legacy-resident-model",
      stateAbi: "legacy-cache-array-v1", backend: "mlx", graphAbi: "mlx-hidden-bsh-v1" }),
    phases: new MlxPhaseDispatch(model),
    eosTokenIds: [248044],
    memory: model,
    adapters: model.loraState,
    pagedKv: null,
    makeCache,
  };
}
/** Reposition caller-owned caches between yields: every cache at offset `offset`, the
 * full-attention storage at capacity `capacity` (zeros: their contents are not read by shape). */
function reposition(caches, offset, capacity) {
  for (const cache of caches) {
    if (cache instanceof KVCache) {
      cache.keys.dispose();
      cache.values.dispose();
      cache.keys = ops.zeros([1, 4, capacity, 256], 12);
      cache.values = ops.zeros([1, 4, capacity, 256], 12);
    }
    cache.offset = offset;
  }
}
export let out = null;
async function main() {
  const shards = new ShardedSafetensors();
  for (const [file, entries] of SHARDS) {
    const tensors = new Map();
    for (const [name, dtype, shape, begin, end] of entries) tensors.set(name, { name, dtype, shape, begin, end });
    const sf = new SafetensorsFile(`${DIR}/${file}`, null, tensors, {}, 0);
    shards.files.set(file, sf);
    for (const name of tensors.keys()) shards.tensorToFile.set(name, sf);
  }
  const weights = await Weights.open(DIR, { openShards: async () => shards });
  const config = { text, quantization: parseQuantization(QUANTIZATION) };
  const model = new Qwen38TrellisM1Max(weights, config);
  const binding = bind(model);
  const cache = binding.makeCache();
  const generation = generateAutoregressive(binding, [PROMPT], { cache, maxTokens: M });
  const tokens = [];
  for await (const t of generation) {
    tokens.push(t.token);
    if (t.index === 1) reposition(cache, n, c);
    else if (t.index === 2) reposition(cache, c, c);
  }
  out = [tokens, generation.stats.generatedTokens, cache[3].offset, cache[3].keys.shape, cache[0].offset];
}
main().catch(e => { out = ["error", String(e && e.message)]; });
"#
source_parse source
source_ast

def mods : List UMod :=
  [⟨chars!"packages/inference/src/__decode.ts", ast⟩,
   ⟨chars!"packages/inference/src/artifacts/weights.ts", Sources.Inference.Artifacts.Weights.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/safetensors.ts", Sources.Inference.Artifacts.Safetensors.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/mmap.ts", Tests.Layers.StandInferenceArtifactsMmap.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", Tests.Layers.StandMlxHostBuffer.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", Tests.Layers.StandMlxCommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", Tests.Layers.StandMlxNative.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Sources.Inference.Artifacts.Config.ast⟩,
   ⟨chars!"packages/inference/src/__qwen38one.ts", Tests.Decode.StandInferenceQwen38one.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/inference/src/layers/normalization.ts", Sources.Inference.Layers.Normalization.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-embedding.ts", Sources.Inference.Layers.QuantizedEmbedding.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffineRows.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-gate-up.ts", Sources.Inference.Layers.TrellisCodebookGateUp.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-codebook.ts", Sources.Inference.Kernels.Trellis.GateUpCodebook.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/codebook.ts", Sources.Inference.Kernels.Trellis.Codebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/launch.ts", Sources.Inference.Kernels.Trellis.Launch.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-down.ts", Sources.Inference.Layers.TrellisCodebookDown.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-codebook.ts", Sources.Inference.Kernels.Trellis.DownCodebook.ast⟩,
   ⟨chars!"packages/inference/src/layers/affine-verify-linear.ts", Sources.Inference.Layers.AffineVerifyLinear.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-row.ts", Sources.Inference.Kernels.Quantization.AffineRow.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-split-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffineSplitMma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine3Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine3Mma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine4Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine4Mma.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-prompt.ts", Sources.Inference.Layers.TrellisPrompt.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/index.ts", Tests.Layers.StandInferenceKernelsTrellisIndex.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", Sources.Inference.Layers.Swiglu.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", Sources.Inference.Layers.TrellisLinear.ast⟩,
   ⟨chars!"packages/inference/src/runtime/graph-forward.ts", Sources.Inference.Runtime.GraphForward.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/blocks.ts", Sources.Inference.Models.Qwen.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/layers/compiled-normalization.ts", Sources.Inference.Layers.CompiledNormalization.ast⟩,
   ⟨chars!"packages/inference/src/kernels/residual-rms-norm.ts", Sources.Inference.Kernels.ResidualRmsNorm.ast⟩,
   ⟨chars!"packages/inference/src/kernels/gated-rms-norm.ts", Sources.Inference.Kernels.GatedRmsNorm.ast⟩,
   ⟨chars!"packages/inference/src/layers/delta-heads.ts", Sources.Inference.Layers.DeltaHeads.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/silu-rms-heads.ts", Sources.Inference.Kernels.Delta.SiluRmsHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/qwen-mrope.ts", Tests.Layers.StandInferenceLayersQwenMrope.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/written-layers.ts", Sources.Inference.Models.Qwen.WrittenLayers.ast⟩,
   ⟨chars!"packages/inference/src/layers/ane-prefill-split.ts", Tests.Layers.StandInferenceLayersAnePrefillSplit.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/checkpoint.ts", Sources.Inference.Models.Qwen.Checkpoint.ast⟩,
   ⟨chars!"packages/inference/src/state/kv.ts", Sources.Inference.State.Kv.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/masks.ts", Tests.Layers.StandInferenceKernelsAttentionMasks.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-kv.ts", Tests.Layers.StandInferenceStateQuantizedKv.ast⟩,
   ⟨chars!"packages/inference/src/state/attention-read.ts", Sources.Inference.State.AttentionRead.ast⟩,
   ⟨chars!"packages/inference/src/layers/folded-attention.ts", Tests.Layers.StandInferenceLayersFoldedAttention.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", Tests.Decode.StandInferenceRuntimeResources.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-attention.ts", Tests.Layers.StandInferenceStateTurboquantAttention.ast⟩,
   ⟨chars!"packages/inference/src/state/ssm.ts", Sources.Inference.State.Ssm.ast⟩,
   ⟨chars!"packages/mlx/src/materialize.ts", Sources.Mlx.Materialize.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/gated.ts", Sources.Inference.Kernels.Delta.Gated.ast⟩,
   ⟨chars!"packages/mlx/src/autograd.ts", Tests.Layers.StandMlxAutograd.ast⟩,
   ⟨chars!"packages/mlx/src/custom-vjp.ts", Tests.Layers.StandMlxCustomVjp.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/state.ts", Tests.Layers.StandInferenceKernelsDeltaState.ast⟩,
   ⟨chars!"packages/inference/src/generation/phase-dispatch.ts", Sources.Inference.Generation.PhaseDispatch.ast⟩,
   ⟨chars!"packages/inference/src/runtime/row-operations.ts", Sources.Inference.Runtime.RowOperations.ast⟩,
   ⟨chars!"packages/inference/src/generation/autoregressive.ts", Sources.Inference.Generation.Autoregressive.ast⟩,
   ⟨chars!"packages/inference/src/contracts/portable/prefill.ts", Sources.Inference.Contracts.Portable.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/generation/bindings/autoregressive.ts", Sources.Inference.Generation.Bindings.Autoregressive.ast⟩,
   ⟨chars!"packages/inference/src/runtime/config.ts", Sources.Inference.Runtime.Config.ast⟩,
   ⟨chars!"packages/inference/src/generation/fill-append.ts", Tests.Decode.StandInferenceGenerationFillAppend.ast⟩,
   ⟨chars!"packages/inference/src/generation/grammar-step.ts", Tests.Decode.StandInferenceGenerationGrammarStep.ast⟩,
   ⟨chars!"packages/inference/src/generation/scopes.ts", Sources.Inference.Generation.Scopes.ast⟩,
   ⟨chars!"packages/inference/src/generation/types.ts", Tests.Decode.StandInferenceGenerationTypes.ast⟩,
   ⟨chars!"packages/inference/src/generation/prefill.ts", Sources.Inference.Generation.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/state/leases.ts", Tests.Decode.StandInferenceStateLeases.ast⟩,
   ⟨chars!"packages/inference/src/sampling/index.ts", Sources.Inference.Sampling.Index.ast⟩,
   ⟨chars!"packages/inference/src/sampling/types.ts", Tests.Decode.StandInferenceSamplingTypes.ast⟩,
   ⟨chars!"packages/inference/src/sampling/processors.ts", Sources.Inference.Sampling.Processors.ast⟩,
   ⟨chars!"packages/inference/src/sampling/step.ts", Sources.Inference.Sampling.Step.ast⟩,
   ⟨chars!"packages/inference/src/kernels/sampling/normalized-argmax.ts", Sources.Inference.Kernels.Sampling.NormalizedArgmax.ast⟩,
   ⟨chars!"packages/inference/src/sampling/extras.ts", Sources.Inference.Sampling.Extras.ast⟩,
   ⟨chars!"packages/inference/src/sampling/window-filters.ts", Sources.Inference.Sampling.WindowFilters.ast⟩,
   ⟨chars!"packages/inference/src/sampling/sampler.ts", Tests.Decode.StandInferenceSamplingSampler.ast⟩,
   ⟨chars!"packages/inference/src/contracts/portable/composition.ts", Sources.Inference.Contracts.Portable.Composition.ast⟩,
   ⟨chars!"packages/inference/src/state/request-policy.ts", Sources.Inference.State.RequestPolicy.ast⟩,
   ⟨chars!"packages/inference/src/state/rollback.ts", Tests.Decode.StandInferenceStateRollback.ast⟩,
   ⟨chars!"packages/inference/src/generation/fill/session.ts", Tests.Decode.StandInferenceGenerationFillSession.ast⟩,
   ⟨chars!"packages/inference/src/generation/result.ts", Sources.Inference.Generation.Result.ast⟩]

/-- Read-back token values: number-table entries `3 …`. -/
def reads : List NumV := (List.range 8).map fun i => .ref (i + 3)

def boot0 : Option (St Host.Mlx.Ffi.St) :=
  boot (Host.Mlx.Ffi.init reads (headerOf Checkpoint.dir Checkpoint.shards) chars!"applegpu_g13s"
      [(chars!"max_recommended_working_set_size", 26800000000)])
    mods [bunFfi, asyncHooks, nodeFs, processMod, symMod, ckptMod Checkpoint.shards Checkpoint.quantization]
    chars!"packages/inference/src/__decode.ts"

/-- The number table: `n`, `c`, `M`, then the tokens. -/
def tab : List SymE := (List.range 11).map SymE.var

end Host.Ts.Tests.Decode.Generate
