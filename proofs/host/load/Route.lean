import host.ts.ast.inference.Index
import host.ts.ast.inference.generation.bindings.AutoregressiveWhole
import host.ts.ast.inference.state.RequestPolicyWhole
import host.ts.ast.inference.contracts.portable.Composition
import host.ts.ast.inference.state.Ssm
import host.ts.ast.inference.state.Kv
import host.ts.ast.inference.artifacts.ConfigWhole
import host.ts.ast.inference.artifacts.Weights
import host.ts.ast.inference.models.Factory
import host.ts.ast.inference.models.Composition
import host.ts.ast.inference.models.Implementation
import host.ts.ast.inference.input.Tokenizer
import host.ts.ast.inference.input.ChatTemplate
import host.ts.ast.inference.generation.Generate
import host.ts.ast.inference.generation.Autoregressive
import host.ts.ast.inference.generation.Denoising
import host.ts.ast.inference.generation.Result
import host.ts.ast.inference.embeddings.Text
import host.ts.ast.inference.adapters.Manager
import host.ts.ast.inference.state.paged.Cache
import host.ts.ast.inference.models.Capabilities
import host.ts.ast.inference.runtime.Config
import host.ts.ast.inference.generation.bindings.PrefillPolicy
import host.ts.ast.inference.generation.PhaseDispatch
import host.ts.ast.inference.state.TurboquantCodec
import host.ts.ast.inference.state.Capabilities
import host.ts.ast.mlx.Array
import host.ts.ast.mlx.Ffi
import host.ts.ast.mlx.Materialize
import host.ts.ast.mlx.Ops
import host.ts.ast.inference.kernels.delta.Gated
import host.ts.ast.inference.kernels.delta.State
import host.ts.ast.inference.layers.Helpers
import host.ts.ast.inference.kernels.attention.Masks
import host.ts.ast.inference.state.QuantizedKv
import host.ts.ast.inference.state.AttentionRead
import host.ts.ast.inference.state.TurboquantAttention
import host.ts.ast.inference.artifacts.ConfigDialects
import host.ts.ast.inference.artifacts.Glm52Config
import host.ts.ast.inference.artifacts.Safetensors
import host.ts.ast.inference.models.gemma4.Model
import host.ts.ast.inference.artifacts.Fingerprint
import host.ts.ast.inference.models.qwen.Checkpoint
import host.ts.ast.inference.models.qwen.Qwen3827bTrellisM4pro
import host.ts.ast.inference.models.qwen.Qwen3827bTrellisM1max
import host.ts.ast.inference.models.gemma4.Graphs
import host.ts.ast.inference.models.minicpm5.Model
import host.ts.ast.inference.models.qwen.Qwen35
import host.ts.ast.inference.models.qwen.Qwen3
import host.ts.ast.inference.models.qwen.Qwen3Moe
import host.ts.ast.inference.models.diffusion_gemma.Model
import host.ts.ast.inference.models.glm52.Model
import host.ts.ast.inference.artifacts.glm52.Memory
import host.ts.ast.inference.models.universal.Dense
import host.ts.ast.inference.models.whisper.Model
import host.ts.ast.inference.models.universal.Archs
import host.ts.ast.inference.models.Families
import host.ts.ast.inference.models.CacheComposition
import host.ts.ast.inference.models.Graph
import host.ts.ast.inference.models.Profile
import host.ts.ast.inference.state.KvScheme
import host.ts.ast.inference.generation.bindings.Denoising
import host.ts.ast.inference.contracts.portable.Prefill
import host.ts.ast.inference.generation.FillAppend
import host.ts.ast.inference.generation.GrammarStep
import host.ts.ast.inference.generation.Scopes
import host.ts.ast.inference.generation.Prefill
import host.ts.ast.inference.sampling.Index
import host.ts.ast.inference.state.Rollback
import host.ts.ast.inference.generation.fill.Session
import host.ts.ast.inference.generation.Diffusion
import host.ts.ast.inference.adapters.Available
import host.ts.ast.inference.runtime.Resources
import host.ts.ast.inference.kernels.attention.Paged
import host.ts.ast.inference.kernels.turboquant.Ops
import host.ts.ast.inference.state.TurboquantKv
import host.ts.ast.inference.runtime.RowOperations
import host.ts.ast.mlx.HostBuffer
import host.ts.ast.mlx.CommandBuffers
import host.ts.ast.mlx.Native
import host.ts.ast.mlx.Autograd
import host.ts.ast.mlx.Compile
import host.ts.ast.mlx.CustomVjp
import host.ts.ast.mlx.MetalKernel
import host.ts.ast.inference.state.QuantizedTensor
import host.ts.ast.inference.state.AffineAttention
import host.ts.ast.inference.layers.FoldedAttention
import host.ts.ast.inference.artifacts.Mmap
import host.ts.ast.mlx.Checkpoint
import host.ts.ast.inference.layers.Lora
import host.ts.ast.inference.models.gemma4.CompiledDecode
import host.ts.ast.inference.models.gemma4.Trainable
import host.ts.ast.inference.models.gemma4.Media
import host.ts.ast.inference.layers.Geglu
import host.ts.ast.inference.models.gemma4.ServingBlocks
import host.ts.ast.inference.models.gemma4.Blocks
import host.ts.ast.inference.input.TokenGroups
import host.ts.ast.inference.layers.Normalization
import host.ts.ast.inference.layers.QuantizedEmbedding
import host.ts.ast.inference.kernels.Logits
import host.ts.ast.inference.kernels.Softcap
import host.ts.ast.inference.layers.AffineVerifyLinear
import host.ts.ast.inference.layers.AnePrefillSplit
import host.ts.ast.inference.layers.QuantizedLinear
import host.ts.ast.inference.layers.QwenAppend
import host.ts.ast.inference.layers.QwenMrope
import host.ts.ast.inference.layers.TrellisDown
import host.ts.ast.inference.layers.TrellisGateUp
import host.ts.ast.inference.layers.TrellisPrompt
import host.ts.ast.inference.runtime.GraphForward
import host.ts.ast.inference.models.qwen.Blocks
import host.ts.ast.inference.models.qwen.MediaInput
import host.ts.ast.inference.models.qwen.WrittenLayers
import host.ts.ast.inference.layers.TrellisReduceGateUp
import host.ts.ast.inference.layers.TrellisCodebookGateUp
import host.ts.ast.inference.layers.TrellisCodebookDown
import host.ts.ast.inference.layers.DequantizedLinear
import host.ts.ast.inference.input.PackedMixed
import host.ts.ast.inference.models.gemma4.Gemma4E4b
import host.ts.ast.inference.models.gemma4.Gemma412b
import host.ts.ast.inference.models.gemma4.Gemma426b
import host.ts.ast.inference.models.gemma4.WrittenBlocks
import host.ts.ast.inference.models.minicpm5.Trainable
import host.ts.ast.inference.layers.Swiglu
import host.ts.ast.inference.layers.TrellisLinear
import host.ts.ast.inference.kernels.trellis.Index
import host.ts.ast.inference.layers.QuantizedSwitchLinear
import host.ts.ast.inference.models.diffusion_gemma.Experts
import host.ts.ast.inference.models.diffusion_gemma.Vision
import host.ts.ast.inference.artifacts.glm52.Layout
import host.ts.ast.inference.artifacts.glm52.ResidentWeights
import host.ts.ast.inference.artifacts.glm52.Weights
import host.ts.ast.inference.models.glm52.Dsa
import host.ts.ast.inference.models.glm52.Mtp
import host.ts.ast.inference.models.glm52.Mla
import host.ts.ast.inference.models.glm52.Moe
import host.ts.ast.inference.models.glm52.Pilot
import host.ts.ast.inference.models.glm52.Residency
import host.ts.ast.inference.models.Drafters
import host.ts.ast.inference.artifacts.glm52.ExpertLayout
import host.ts.ast.inference.runtime.Integers
import host.ts.ast.inference.artifacts.glm52.Container
import host.ts.ast.inference.artifacts.WeightAudit
import host.ts.ast.inference.layers.Rope
import host.ts.ast.inference.layers.Loading
import host.ts.ast.inference.models.universal.Blocks
import host.ts.ast.inference.models.whisper.Fast
import host.ts.ast.inference.models.diffusion_gemma.Family
import host.ts.ast.inference.models.gemma4.Family
import host.ts.ast.inference.models.glm52.Family
import host.ts.ast.inference.models.minicpm5.Family
import host.ts.ast.inference.models.qwen.Families
import host.ts.ast.inference.models.universal.Family
import host.ts.ast.inference.models.whisper.Family
import host.ts.ast.inference.state.Bf16FirstKv
import host.ts.ast.inference.state.LatentLegos
import host.ts.ast.inference.models.RowTable
import host.ts.ast.inference.models.Family
import host.ts.ast.inference.state.Leases
import host.ts.ast.inference.sampling.Types
import host.ts.ast.inference.sampling.Filters
import host.ts.ast.inference.sampling.Hlg
import host.ts.ast.inference.sampling.Processors
import host.ts.ast.inference.sampling.Step
import host.ts.ast.inference.sampling.Extras
import host.ts.ast.inference.sampling.Sampler
import host.ts.ast.inference.sampling.Grammar
import host.ts.ast.inference.sampling.Curve
import host.ts.ast.inference.generation.fill.EchoIndex
import host.ts.ast.inference.kernels.turboquant.Tables
import host.ts.ast.inference.kernels.turboquant.Signs
import host.ts.ast.inference.kernels.turboquant.Decode
import host.ts.ast.inference.kernels.turboquant.Inverse
import host.ts.ast.inference.state.DecodedKvDonor
import host.ts.ast.inference.layers.QuantizedAppendAttention
import host.ts.ast.inference.layers.QuantizedAttention
import host.ts.ast.inference.state.DecodeStepInputs
import host.ts.ast.inference.runtime.CompiledTrace
import host.ts.ast.inference.state.TrainingCache
import host.ts.ast.inference.models.MediaInput
import host.ts.ast.inference.models.gemma4.AssistantTarget
import host.ts.ast.inference.runtime.ExpertTrace
import host.ts.ast.inference.kernels.quantization.AffineRow
import host.ts.ast.inference.kernels.quantization.AffineSplitMma
import host.ts.ast.inference.kernels.quantization.Affine3Rows
import host.ts.ast.inference.kernels.quantization.Affine3Mma
import host.ts.ast.inference.kernels.quantization.Affine4Rows
import host.ts.ast.inference.kernels.quantization.Affine4Mma
import host.ts.ast.inference.kernels.ane.Linear
import host.ts.ast.inference.kernels.ane.Fill
import host.ts.ast.inference.kernels.quantization.AffineRows
import host.ts.ast.inference.kernels.trellis.DownFactored
import host.ts.ast.inference.kernels.trellis.DownK3InterleavedFactored
import host.ts.ast.inference.kernels.trellis.DownMma
import host.ts.ast.inference.kernels.trellis.DownMmaWide
import host.ts.ast.inference.kernels.trellis.GateUpFactored
import host.ts.ast.inference.kernels.trellis.MixedGateUpFactored
import host.ts.ast.inference.kernels.trellis.GateUpMma
import host.ts.ast.inference.kernels.trellis.GateUpMmaWide
import host.ts.ast.inference.kernels.trellis.GateUpCodebookMma
import host.ts.ast.inference.layers.CompiledNormalization
import host.ts.ast.inference.layers.DeltaHeads
import host.ts.ast.inference.artifacts.TurboquantFold
import host.ts.ast.inference.artifacts.DraftVocabulary
import host.ts.ast.inference.kernels.trellis.GateUp
import host.ts.ast.inference.kernels.trellis.MixedGateUp
import host.ts.ast.inference.kernels.trellis.GateUpCodebook
import host.ts.ast.inference.kernels.trellis.DownCodebook
import host.ts.ast.inference.models.gemma4.WrittenForward
import host.ts.ast.inference.models.gemma4.WrittenInput
import host.ts.ast.inference.kernels.trellis.Codebook
import host.ts.ast.inference.kernels.trellis.VectorExpand
import host.ts.ast.inference.kernels.trellis.Expand
import host.ts.ast.inference.kernels.trellis.Reduce
import host.ts.ast.inference.kernels.trellis.Scatter
import host.ts.ast.inference.kernels.trellis.Qualified
import host.ts.ast.inference.kernels.trellis.TiledPrefill
import host.ts.ast.inference.kernels.trellis.SplitkPrefill
import host.ts.ast.inference.kernels.trellis.WidePrefill
import host.ts.ast.inference.artifacts.ExpertOffload
import host.ts.ast.inference.layers.Rope2d
import host.ts.ast.inference.models.vision.Siglip
import host.ts.ast.inference.input.vision.Preprocess
import host.ts.ast.inference.models.glm52.Reference
import host.ts.ast.inference.artifacts.experts.Residency
import host.ts.ast.inference.artifacts.experts.Io
import host.ts.ast.inference.artifacts.experts.Usage
import host.ts.ast.inference.models.glm52.StreamedExperts
import host.ts.ast.inference.models.speculative.DeepspecArtifact
import host.ts.ast.inference.models.speculative.Dflash2Artifact
import host.ts.ast.inference.kernels.glm52.Layout
import host.ts.ast.inference.layers.DenseEmbedding
import host.ts.ast.inference.layers.DenseLinear
import host.ts.ast.inference.layers.LayerNorm
import host.ts.ast.inference.state.SoftcapAttention
import host.ts.ast.inference.kernels.attention.Kvq4Decode
import host.ts.ast.inference.state.Kv4Head256Cache
import host.ts.ast.inference.state.RotatingKv
import host.ts.ast.inference.state.RotatingQuantizedKv
import host.ts.ast.inference.state.BatchedRowStorage
import host.ts.ast.inference.state.Glm52Cache
import host.ts.ast.inference.state.Persistence
import host.ts.ast.inference.kernels.sampling.NormalizedArgmax
import host.ts.ast.inference.sampling.WindowFilters
import host.ts.ast.inference.kernels.sampling.TokenBitmask
import host.ts.ast.inference.kernels.attention.Flash
import host.ts.ast.inference.layers.PrefixLayout
import host.ts.ast.inference.state.KvAttentionView
import host.ts.ast.inference.runtime.Native
import host.ts.ast.inference.kernels.trellis.Launch
import host.ts.ast.inference.kernels.ResidualRmsNorm
import host.ts.ast.inference.kernels.GatedRmsNorm
import host.ts.ast.inference.kernels.delta.SiluRmsHeads
import host.ts.ast.inference.kernels.glm52.StreamedExperts
import host.ts.ast.inference.artifacts.glm52.KernelLayout
import host.ts.ast.inference.state.KvStorage
import host.ts.ast.inference.layers.Kv4DecodeAttention
import host.ts.ast.inference.state.FullPrefillPadding
import host.ts.ast.inference.state.Checkpoint
import host.ts.ast.inference.state.paged.Codec
import host.ts.ast.inference.state.PersistenceWorker
import host.ts.HostLib
import host.load.World
import host.load.Data
namespace Host.Load.Route
open Host.Ts Host.Load
set_option maxRecDepth 100000

/-! # The load route

The process the real harness runs (`/tmp/tscov/run.ts`, `/tmp/kerneltrace/trace-generate.ts`):
import the library entry `packages/inference/src/index.ts`, `openModel` the
Qwen3.8 27B Trellis 3.2bpw artifact, and create the caches of one request as
`generate()` does (`bindMlxAutoregressiveGraph(model).makeCache()`, then
`maybePageKv` for a one-token prompt and 300 new tokens). The driver below is
that harness's code; every other module is the repository source
(`host/ts/SourceBinding.ts` pins), the JavaScript host library (`HostLib`) or a
host module. The world (`Host.Load.LSt`): the environment of the real run, the
model directory (`Data`, bound to the files), the native libraries' paths, and
the platform facts listed in `world`. -/

namespace Driver
/-- The harness: load phase of `run.ts` (not repository code). -/
def source : String := r#"import "%host/globals";
import { openModel } from "./index";
import { bindMlxAutoregressiveGraph } from "./generation/bindings/autoregressive";
import { maybePageKv } from "./state/request-policy";
import { BF16_KV } from "./contracts/portable/composition";
import { SSMCache } from "./state/ssm";
import { KVCache } from "./state/kv";
const DIR = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-bun--Qwen3.8-27B-Trellis-3.2bpw/snapshots/cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d";
export let model = null;
export let binding = null;
export let cache = null;
export let out = null;
async function main() {
  model = await openModel(DIR);
  binding = bindMlxAutoregressiveGraph(model);
  cache = binding.makeCache();
  maybePageKv(cache, binding.kv ?? BF16_KV, binding.pagedKv ?? null, 1 + 300);
  out = [cache.length, cache.filter(c => c instanceof SSMCache).length, cache.filter(c => c instanceof KVCache).length];
}
main().catch(e => { out = ["error", String(e && e.message)]; });
"#
source_parse source
source_ast
end Driver

def entry : List Char := chars!"packages/inference/src/__load.ts"

/-- The modules, in the order the import graph reaches them from the driver. -/
def mods : List UMod :=
  [⟨chars!"packages/inference/src/index.ts", Host.Ts.Sources.Inference.Index.ast⟩,
   ⟨chars!"packages/inference/src/generation/bindings/autoregressive.ts", Host.Ts.Sources.Inference.Generation.Bindings.AutoregressiveWhole.ast⟩,
   ⟨chars!"packages/inference/src/state/request-policy.ts", Host.Ts.Sources.Inference.State.RequestPolicyWhole.ast⟩,
   ⟨chars!"packages/inference/src/contracts/portable/composition.ts", Host.Ts.Sources.Inference.Contracts.Portable.Composition.ast⟩,
   ⟨chars!"packages/inference/src/state/ssm.ts", Host.Ts.Sources.Inference.State.Ssm.ast⟩,
   ⟨chars!"packages/inference/src/state/kv.ts", Host.Ts.Sources.Inference.State.Kv.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Host.Ts.Sources.Inference.Artifacts.ConfigWhole.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/weights.ts", Host.Ts.Sources.Inference.Artifacts.Weights.ast⟩,
   ⟨chars!"packages/inference/src/models/factory.ts", Host.Ts.Sources.Inference.Models.Factory.ast⟩,
   ⟨chars!"packages/inference/src/models/composition.ts", Host.Ts.Sources.Inference.Models.Composition.ast⟩,
   ⟨chars!"packages/inference/src/models/implementation.ts", Host.Ts.Sources.Inference.Models.Implementation.ast⟩,
   ⟨chars!"packages/inference/src/input/tokenizer.ts", Host.Ts.Sources.Inference.Input.Tokenizer.ast⟩,
   ⟨chars!"packages/inference/src/input/chat-template.ts", Host.Ts.Sources.Inference.Input.ChatTemplate.ast⟩,
   ⟨chars!"packages/inference/src/generation/generate.ts", Host.Ts.Sources.Inference.Generation.Generate.ast⟩,
   ⟨chars!"packages/inference/src/generation/autoregressive.ts", Host.Ts.Sources.Inference.Generation.Autoregressive.ast⟩,
   ⟨chars!"packages/inference/src/generation/denoising.ts", Host.Ts.Sources.Inference.Generation.Denoising.ast⟩,
   ⟨chars!"packages/inference/src/generation/result.ts", Host.Ts.Sources.Inference.Generation.Result.ast⟩,
   ⟨chars!"packages/inference/src/embeddings/text.ts", Host.Ts.Sources.Inference.Embeddings.Text.ast⟩,
   ⟨chars!"packages/inference/src/adapters/manager.ts", Host.Ts.Sources.Inference.Adapters.Manager.ast⟩,
   ⟨chars!"packages/inference/src/state/paged/cache.ts", Host.Ts.Sources.Inference.State.Paged.Cache.ast⟩,
   ⟨chars!"packages/inference/src/models/capabilities.ts", Host.Ts.Sources.Inference.Models.Capabilities.ast⟩,
   ⟨chars!"packages/inference/src/runtime/config.ts", Host.Ts.Sources.Inference.Runtime.Config.ast⟩,
   ⟨chars!"packages/inference/src/generation/bindings/prefill-policy.ts", Host.Ts.Sources.Inference.Generation.Bindings.PrefillPolicy.ast⟩,
   ⟨chars!"packages/inference/src/generation/phase-dispatch.ts", Host.Ts.Sources.Inference.Generation.PhaseDispatch.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-codec.ts", Host.Ts.Sources.Inference.State.TurboquantCodec.ast⟩,
   ⟨chars!"packages/inference/src/state/capabilities.ts", Host.Ts.Sources.Inference.State.Capabilities.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/materialize.ts", Host.Ts.Sources.Mlx.Materialize.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/gated.ts", Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/state.ts", Host.Ts.Sources.Inference.Kernels.Delta.State.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Host.Ts.Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/masks.ts", Host.Ts.Sources.Inference.Kernels.Attention.Masks.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-kv.ts", Host.Ts.Sources.Inference.State.QuantizedKv.ast⟩,
   ⟨chars!"packages/inference/src/state/attention-read.ts", Host.Ts.Sources.Inference.State.AttentionRead.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-attention.ts", Host.Ts.Sources.Inference.State.TurboquantAttention.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config-dialects.ts", Host.Ts.Sources.Inference.Artifacts.ConfigDialects.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52-config.ts", Host.Ts.Sources.Inference.Artifacts.Glm52Config.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/safetensors.ts", Host.Ts.Sources.Inference.Artifacts.Safetensors.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/model.ts", Host.Ts.Sources.Inference.Models.Gemma4.Model.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/fingerprint.ts", Host.Ts.Sources.Inference.Artifacts.Fingerprint.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/checkpoint.ts", Host.Ts.Sources.Inference.Models.Qwen.Checkpoint.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/qwen38-27b-trellis-m4pro.ts", Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM4pro.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/qwen38-27b-trellis-m1max.ts", Host.Ts.Sources.Inference.Models.Qwen.Qwen3827bTrellisM1max.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/graphs.ts", Host.Ts.Sources.Inference.Models.Gemma4.Graphs.ast⟩,
   ⟨chars!"packages/inference/src/models/minicpm5/model.ts", Host.Ts.Sources.Inference.Models.Minicpm5.Model.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/qwen3_5.ts", Host.Ts.Sources.Inference.Models.Qwen.Qwen35.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/qwen3.ts", Host.Ts.Sources.Inference.Models.Qwen.Qwen3.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/qwen3-moe.ts", Host.Ts.Sources.Inference.Models.Qwen.Qwen3Moe.ast⟩,
   ⟨chars!"packages/inference/src/models/diffusion-gemma/model.ts", Host.Ts.Sources.Inference.Models.DiffusionGemma.Model.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/model.ts", Host.Ts.Sources.Inference.Models.Glm52.Model.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/memory.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.Memory.ast⟩,
   ⟨chars!"packages/inference/src/models/universal/dense.ts", Host.Ts.Sources.Inference.Models.Universal.Dense.ast⟩,
   ⟨chars!"packages/inference/src/models/whisper/model.ts", Host.Ts.Sources.Inference.Models.Whisper.Model.ast⟩,
   ⟨chars!"packages/inference/src/models/universal/archs.ts", Host.Ts.Sources.Inference.Models.Universal.Archs.ast⟩,
   ⟨chars!"packages/inference/src/models/families.ts", Host.Ts.Sources.Inference.Models.Families.ast⟩,
   ⟨chars!"packages/inference/src/models/cache-composition.ts", Host.Ts.Sources.Inference.Models.CacheComposition.ast⟩,
   ⟨chars!"packages/inference/src/models/graph.ts", Host.Ts.Sources.Inference.Models.Graph.ast⟩,
   ⟨chars!"packages/inference/src/models/profile.ts", Host.Ts.Sources.Inference.Models.Profile.ast⟩,
   ⟨chars!"packages/inference/src/state/kv-scheme.ts", Host.Ts.Sources.Inference.State.KvScheme.ast⟩,
   ⟨chars!"packages/inference/src/generation/bindings/denoising.ts", Host.Ts.Sources.Inference.Generation.Bindings.Denoising.ast⟩,
   ⟨chars!"packages/inference/src/contracts/portable/prefill.ts", Host.Ts.Sources.Inference.Contracts.Portable.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/generation/fill-append.ts", Host.Ts.Sources.Inference.Generation.FillAppend.ast⟩,
   ⟨chars!"packages/inference/src/generation/grammar-step.ts", Host.Ts.Sources.Inference.Generation.GrammarStep.ast⟩,
   ⟨chars!"packages/inference/src/generation/scopes.ts", Host.Ts.Sources.Inference.Generation.Scopes.ast⟩,
   ⟨chars!"packages/inference/src/generation/prefill.ts", Host.Ts.Sources.Inference.Generation.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/sampling/index.ts", Host.Ts.Sources.Inference.Sampling.Index.ast⟩,
   ⟨chars!"packages/inference/src/state/rollback.ts", Host.Ts.Sources.Inference.State.Rollback.ast⟩,
   ⟨chars!"packages/inference/src/generation/fill/session.ts", Host.Ts.Sources.Inference.Generation.Fill.Session.ast⟩,
   ⟨chars!"packages/inference/src/generation/diffusion.ts", Host.Ts.Sources.Inference.Generation.Diffusion.ast⟩,
   ⟨chars!"packages/inference/src/adapters/available.ts", Host.Ts.Sources.Inference.Adapters.Available.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", Host.Ts.Sources.Inference.Runtime.Resources.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/paged.ts", Host.Ts.Sources.Inference.Kernels.Attention.Paged.ast⟩,
   ⟨chars!"packages/inference/src/kernels/turboquant/ops.ts", Host.Ts.Sources.Inference.Kernels.Turboquant.Ops.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-kv.ts", Host.Ts.Sources.Inference.State.TurboquantKv.ast⟩,
   ⟨chars!"packages/inference/src/runtime/row-operations.ts", Host.Ts.Sources.Inference.Runtime.RowOperations.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", Host.Ts.Sources.Mlx.HostBuffer.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", Host.Ts.Sources.Mlx.CommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", Host.Ts.Sources.Mlx.Native.ast⟩,
   ⟨chars!"packages/mlx/src/autograd.ts", Host.Ts.Sources.Mlx.Autograd.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/custom-vjp.ts", Host.Ts.Sources.Mlx.CustomVjp.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-tensor.ts", Host.Ts.Sources.Inference.State.QuantizedTensor.ast⟩,
   ⟨chars!"packages/inference/src/state/affine-attention.ts", Host.Ts.Sources.Inference.State.AffineAttention.ast⟩,
   ⟨chars!"packages/inference/src/layers/folded-attention.ts", Host.Ts.Sources.Inference.Layers.FoldedAttention.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/mmap.ts", Host.Ts.Sources.Inference.Artifacts.Mmap.ast⟩,
   ⟨chars!"packages/mlx/src/checkpoint.ts", Host.Ts.Sources.Mlx.Checkpoint.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/compiled-decode.ts", Host.Ts.Sources.Inference.Models.Gemma4.CompiledDecode.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/trainable.ts", Host.Ts.Sources.Inference.Models.Gemma4.Trainable.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/media.ts", Host.Ts.Sources.Inference.Models.Gemma4.Media.ast⟩,
   ⟨chars!"packages/inference/src/layers/geglu.ts", Host.Ts.Sources.Inference.Layers.Geglu.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/serving-blocks.ts", Host.Ts.Sources.Inference.Models.Gemma4.ServingBlocks.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/blocks.ts", Host.Ts.Sources.Inference.Models.Gemma4.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/input/token-groups.ts", Host.Ts.Sources.Inference.Input.TokenGroups.ast⟩,
   ⟨chars!"packages/inference/src/layers/normalization.ts", Host.Ts.Sources.Inference.Layers.Normalization.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-embedding.ts", Host.Ts.Sources.Inference.Layers.QuantizedEmbedding.ast⟩,
   ⟨chars!"packages/inference/src/kernels/logits.ts", Host.Ts.Sources.Inference.Kernels.Logits.ast⟩,
   ⟨chars!"packages/inference/src/kernels/softcap.ts", Host.Ts.Sources.Inference.Kernels.Softcap.ast⟩,
   ⟨chars!"packages/inference/src/layers/affine-verify-linear.ts", Host.Ts.Sources.Inference.Layers.AffineVerifyLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/ane-prefill-split.ts", Host.Ts.Sources.Inference.Layers.AnePrefillSplit.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/qwen-append.ts", Host.Ts.Sources.Inference.Layers.QwenAppend.ast⟩,
   ⟨chars!"packages/inference/src/layers/qwen-mrope.ts", Host.Ts.Sources.Inference.Layers.QwenMrope.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-down.ts", Host.Ts.Sources.Inference.Layers.TrellisDown.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-gate-up.ts", Host.Ts.Sources.Inference.Layers.TrellisGateUp.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-prompt.ts", Host.Ts.Sources.Inference.Layers.TrellisPrompt.ast⟩,
   ⟨chars!"packages/inference/src/runtime/graph-forward.ts", Host.Ts.Sources.Inference.Runtime.GraphForward.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/blocks.ts", Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/media-input.ts", Host.Ts.Sources.Inference.Models.Qwen.MediaInput.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/written-layers.ts", Host.Ts.Sources.Inference.Models.Qwen.WrittenLayers.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-reduce-gate-up.ts", Host.Ts.Sources.Inference.Layers.TrellisReduceGateUp.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-gate-up.ts", Host.Ts.Sources.Inference.Layers.TrellisCodebookGateUp.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-down.ts", Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast⟩,
   ⟨chars!"packages/inference/src/layers/dequantized-linear.ts", Host.Ts.Sources.Inference.Layers.DequantizedLinear.ast⟩,
   ⟨chars!"packages/inference/src/input/packed-mixed.ts", Host.Ts.Sources.Inference.Input.PackedMixed.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/gemma4-e4b.ts", Host.Ts.Sources.Inference.Models.Gemma4.Gemma4E4b.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/gemma4-12b.ts", Host.Ts.Sources.Inference.Models.Gemma4.Gemma412b.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/gemma4-26b.ts", Host.Ts.Sources.Inference.Models.Gemma4.Gemma426b.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/written-blocks.ts", Host.Ts.Sources.Inference.Models.Gemma4.WrittenBlocks.ast⟩,
   ⟨chars!"packages/inference/src/models/minicpm5/trainable.ts", Host.Ts.Sources.Inference.Models.Minicpm5.Trainable.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", Host.Ts.Sources.Inference.Layers.Swiglu.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", Host.Ts.Sources.Inference.Layers.TrellisLinear.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/index.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Index.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-switch-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedSwitchLinear.ast⟩,
   ⟨chars!"packages/inference/src/models/diffusion-gemma/experts.ts", Host.Ts.Sources.Inference.Models.DiffusionGemma.Experts.ast⟩,
   ⟨chars!"packages/inference/src/models/diffusion-gemma/vision.ts", Host.Ts.Sources.Inference.Models.DiffusionGemma.Vision.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/layout.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.Layout.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/resident-weights.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.ResidentWeights.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/weights.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.Weights.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/dsa.ts", Host.Ts.Sources.Inference.Models.Glm52.Dsa.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/mtp.ts", Host.Ts.Sources.Inference.Models.Glm52.Mtp.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/mla.ts", Host.Ts.Sources.Inference.Models.Glm52.Mla.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/moe.ts", Host.Ts.Sources.Inference.Models.Glm52.Moe.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/pilot.ts", Host.Ts.Sources.Inference.Models.Glm52.Pilot.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/residency.ts", Host.Ts.Sources.Inference.Models.Glm52.Residency.ast⟩,
   ⟨chars!"packages/inference/src/models/drafters.ts", Host.Ts.Sources.Inference.Models.Drafters.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/expert-layout.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.ExpertLayout.ast⟩,
   ⟨chars!"packages/inference/src/runtime/integers.ts", Host.Ts.Sources.Inference.Runtime.Integers.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/container.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.Container.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/weight-audit.ts", Host.Ts.Sources.Inference.Artifacts.WeightAudit.ast⟩,
   ⟨chars!"packages/inference/src/layers/rope.ts", Host.Ts.Sources.Inference.Layers.Rope.ast⟩,
   ⟨chars!"packages/inference/src/layers/loading.ts", Host.Ts.Sources.Inference.Layers.Loading.ast⟩,
   ⟨chars!"packages/inference/src/models/universal/blocks.ts", Host.Ts.Sources.Inference.Models.Universal.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/models/whisper/fast.ts", Host.Ts.Sources.Inference.Models.Whisper.Fast.ast⟩,
   ⟨chars!"packages/inference/src/models/diffusion-gemma/family.ts", Host.Ts.Sources.Inference.Models.DiffusionGemma.Family.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/family.ts", Host.Ts.Sources.Inference.Models.Gemma4.Family.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/family.ts", Host.Ts.Sources.Inference.Models.Glm52.Family.ast⟩,
   ⟨chars!"packages/inference/src/models/minicpm5/family.ts", Host.Ts.Sources.Inference.Models.Minicpm5.Family.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/families.ts", Host.Ts.Sources.Inference.Models.Qwen.Families.ast⟩,
   ⟨chars!"packages/inference/src/models/universal/family.ts", Host.Ts.Sources.Inference.Models.Universal.Family.ast⟩,
   ⟨chars!"packages/inference/src/models/whisper/family.ts", Host.Ts.Sources.Inference.Models.Whisper.Family.ast⟩,
   ⟨chars!"packages/inference/src/state/bf16-first-kv.ts", Host.Ts.Sources.Inference.State.Bf16FirstKv.ast⟩,
   ⟨chars!"packages/inference/src/state/latent-legos.ts", Host.Ts.Sources.Inference.State.LatentLegos.ast⟩,
   ⟨chars!"packages/inference/src/models/row-table.ts", Host.Ts.Sources.Inference.Models.RowTable.ast⟩,
   ⟨chars!"packages/inference/src/models/family.ts", Host.Ts.Sources.Inference.Models.Family.ast⟩,
   ⟨chars!"packages/inference/src/state/leases.ts", Host.Ts.Sources.Inference.State.Leases.ast⟩,
   ⟨chars!"packages/inference/src/sampling/types.ts", Host.Ts.Sources.Inference.Sampling.Types.ast⟩,
   ⟨chars!"packages/inference/src/sampling/filters.ts", Host.Ts.Sources.Inference.Sampling.Filters.ast⟩,
   ⟨chars!"packages/inference/src/sampling/hlg.ts", Host.Ts.Sources.Inference.Sampling.Hlg.ast⟩,
   ⟨chars!"packages/inference/src/sampling/processors.ts", Host.Ts.Sources.Inference.Sampling.Processors.ast⟩,
   ⟨chars!"packages/inference/src/sampling/step.ts", Host.Ts.Sources.Inference.Sampling.Step.ast⟩,
   ⟨chars!"packages/inference/src/sampling/extras.ts", Host.Ts.Sources.Inference.Sampling.Extras.ast⟩,
   ⟨chars!"packages/inference/src/sampling/sampler.ts", Host.Ts.Sources.Inference.Sampling.Sampler.ast⟩,
   ⟨chars!"packages/inference/src/sampling/grammar.ts", Host.Ts.Sources.Inference.Sampling.Grammar.ast⟩,
   ⟨chars!"packages/inference/src/sampling/curve.ts", Host.Ts.Sources.Inference.Sampling.Curve.ast⟩,
   ⟨chars!"packages/inference/src/generation/fill/echo-index.ts", Host.Ts.Sources.Inference.Generation.Fill.EchoIndex.ast⟩,
   ⟨chars!"packages/inference/src/kernels/turboquant/tables.ts", Host.Ts.Sources.Inference.Kernels.Turboquant.Tables.ast⟩,
   ⟨chars!"packages/inference/src/kernels/turboquant/signs.ts", Host.Ts.Sources.Inference.Kernels.Turboquant.Signs.ast⟩,
   ⟨chars!"packages/inference/src/kernels/turboquant/decode.ts", Host.Ts.Sources.Inference.Kernels.Turboquant.Decode.ast⟩,
   ⟨chars!"packages/inference/src/kernels/turboquant/inverse.ts", Host.Ts.Sources.Inference.Kernels.Turboquant.Inverse.ast⟩,
   ⟨chars!"packages/inference/src/state/decoded-kv-donor.ts", Host.Ts.Sources.Inference.State.DecodedKvDonor.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-append-attention.ts", Host.Ts.Sources.Inference.Layers.QuantizedAppendAttention.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-attention.ts", Host.Ts.Sources.Inference.Layers.QuantizedAttention.ast⟩,
   ⟨chars!"packages/inference/src/state/decode-step-inputs.ts", Host.Ts.Sources.Inference.State.DecodeStepInputs.ast⟩,
   ⟨chars!"packages/inference/src/runtime/compiled-trace.ts", Host.Ts.Sources.Inference.Runtime.CompiledTrace.ast⟩,
   ⟨chars!"packages/inference/src/state/training-cache.ts", Host.Ts.Sources.Inference.State.TrainingCache.ast⟩,
   ⟨chars!"packages/inference/src/models/media-input.ts", Host.Ts.Sources.Inference.Models.MediaInput.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/assistant-target.ts", Host.Ts.Sources.Inference.Models.Gemma4.AssistantTarget.ast⟩,
   ⟨chars!"packages/inference/src/runtime/expert-trace.ts", Host.Ts.Sources.Inference.Runtime.ExpertTrace.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-row.ts", Host.Ts.Sources.Inference.Kernels.Quantization.AffineRow.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-split-mma.ts", Host.Ts.Sources.Inference.Kernels.Quantization.AffineSplitMma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-rows.ts", Host.Ts.Sources.Inference.Kernels.Quantization.Affine3Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-mma.ts", Host.Ts.Sources.Inference.Kernels.Quantization.Affine3Mma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-rows.ts", Host.Ts.Sources.Inference.Kernels.Quantization.Affine4Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-mma.ts", Host.Ts.Sources.Inference.Kernels.Quantization.Affine4Mma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/ane/linear.ts", Host.Ts.Sources.Inference.Kernels.Ane.Linear.ast⟩,
   ⟨chars!"packages/inference/src/kernels/ane/fill.ts", Host.Ts.Sources.Inference.Kernels.Ane.Fill.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-rows.ts", Host.Ts.Sources.Inference.Kernels.Quantization.AffineRows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-factored.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownFactored.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-k3-interleaved-factored.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownK3InterleavedFactored.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-mma.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownMma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-mma-wide.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownMmaWide.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-factored.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpFactored.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/mixed-gate-up-factored.ts", Host.Ts.Sources.Inference.Kernels.Trellis.MixedGateUpFactored.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-mma.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpMma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-mma-wide.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpMmaWide.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-codebook-mma.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebookMma.ast⟩,
   ⟨chars!"packages/inference/src/layers/compiled-normalization.ts", Host.Ts.Sources.Inference.Layers.CompiledNormalization.ast⟩,
   ⟨chars!"packages/inference/src/layers/delta-heads.ts", Host.Ts.Sources.Inference.Layers.DeltaHeads.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/turboquant-fold.ts", Host.Ts.Sources.Inference.Artifacts.TurboquantFold.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/draft-vocabulary.ts", Host.Ts.Sources.Inference.Artifacts.DraftVocabulary.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUp.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/mixed-gate-up.ts", Host.Ts.Sources.Inference.Kernels.Trellis.MixedGateUp.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownCodebook.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/written-forward.ts", Host.Ts.Sources.Inference.Models.Gemma4.WrittenForward.ast⟩,
   ⟨chars!"packages/inference/src/models/gemma4/written-input.ts", Host.Ts.Sources.Inference.Models.Gemma4.WrittenInput.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Codebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/vector-expand.ts", Host.Ts.Sources.Inference.Kernels.Trellis.VectorExpand.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/expand.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Expand.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/reduce.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Reduce.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/scatter.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Scatter.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/qualified.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Qualified.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/tiled-prefill.ts", Host.Ts.Sources.Inference.Kernels.Trellis.TiledPrefill.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/splitk-prefill.ts", Host.Ts.Sources.Inference.Kernels.Trellis.SplitkPrefill.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/wide-prefill.ts", Host.Ts.Sources.Inference.Kernels.Trellis.WidePrefill.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/expert-offload.ts", Host.Ts.Sources.Inference.Artifacts.ExpertOffload.ast⟩,
   ⟨chars!"packages/inference/src/layers/rope-2d.ts", Host.Ts.Sources.Inference.Layers.Rope2d.ast⟩,
   ⟨chars!"packages/inference/src/models/vision/siglip.ts", Host.Ts.Sources.Inference.Models.Vision.Siglip.ast⟩,
   ⟨chars!"packages/inference/src/input/vision/preprocess.ts", Host.Ts.Sources.Inference.Input.Vision.Preprocess.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/reference.ts", Host.Ts.Sources.Inference.Models.Glm52.Reference.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/experts/residency.ts", Host.Ts.Sources.Inference.Artifacts.Experts.Residency.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/experts/io.ts", Host.Ts.Sources.Inference.Artifacts.Experts.Io.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/experts/usage.ts", Host.Ts.Sources.Inference.Artifacts.Experts.Usage.ast⟩,
   ⟨chars!"packages/inference/src/models/glm52/streamed-experts.ts", Host.Ts.Sources.Inference.Models.Glm52.StreamedExperts.ast⟩,
   ⟨chars!"packages/inference/src/models/speculative/deepspec-artifact.ts", Host.Ts.Sources.Inference.Models.Speculative.DeepspecArtifact.ast⟩,
   ⟨chars!"packages/inference/src/models/speculative/dflash2-artifact.ts", Host.Ts.Sources.Inference.Models.Speculative.Dflash2Artifact.ast⟩,
   ⟨chars!"packages/inference/src/kernels/glm52/layout.ts", Host.Ts.Sources.Inference.Kernels.Glm52.Layout.ast⟩,
   ⟨chars!"packages/inference/src/layers/dense-embedding.ts", Host.Ts.Sources.Inference.Layers.DenseEmbedding.ast⟩,
   ⟨chars!"packages/inference/src/layers/dense-linear.ts", Host.Ts.Sources.Inference.Layers.DenseLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/layer-norm.ts", Host.Ts.Sources.Inference.Layers.LayerNorm.ast⟩,
   ⟨chars!"packages/inference/src/state/softcap-attention.ts", Host.Ts.Sources.Inference.State.SoftcapAttention.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/kvq4-decode.ts", Host.Ts.Sources.Inference.Kernels.Attention.Kvq4Decode.ast⟩,
   ⟨chars!"packages/inference/src/state/kv4-head256-cache.ts", Host.Ts.Sources.Inference.State.Kv4Head256Cache.ast⟩,
   ⟨chars!"packages/inference/src/state/rotating-kv.ts", Host.Ts.Sources.Inference.State.RotatingKv.ast⟩,
   ⟨chars!"packages/inference/src/state/rotating-quantized-kv.ts", Host.Ts.Sources.Inference.State.RotatingQuantizedKv.ast⟩,
   ⟨chars!"packages/inference/src/state/batched-row-storage.ts", Host.Ts.Sources.Inference.State.BatchedRowStorage.ast⟩,
   ⟨chars!"packages/inference/src/state/glm52-cache.ts", Host.Ts.Sources.Inference.State.Glm52Cache.ast⟩,
   ⟨chars!"packages/inference/src/state/persistence.ts", Host.Ts.Sources.Inference.State.Persistence.ast⟩,
   ⟨chars!"packages/inference/src/kernels/sampling/normalized-argmax.ts", Host.Ts.Sources.Inference.Kernels.Sampling.NormalizedArgmax.ast⟩,
   ⟨chars!"packages/inference/src/sampling/window-filters.ts", Host.Ts.Sources.Inference.Sampling.WindowFilters.ast⟩,
   ⟨chars!"packages/inference/src/kernels/sampling/token-bitmask.ts", Host.Ts.Sources.Inference.Kernels.Sampling.TokenBitmask.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/flash.ts", Host.Ts.Sources.Inference.Kernels.Attention.Flash.ast⟩,
   ⟨chars!"packages/inference/src/layers/prefix-layout.ts", Host.Ts.Sources.Inference.Layers.PrefixLayout.ast⟩,
   ⟨chars!"packages/inference/src/state/kv-attention-view.ts", Host.Ts.Sources.Inference.State.KvAttentionView.ast⟩,
   ⟨chars!"packages/inference/src/runtime/native.ts", Host.Ts.Sources.Inference.Runtime.Native.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/launch.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Launch.ast⟩,
   ⟨chars!"packages/inference/src/kernels/residual-rms-norm.ts", Host.Ts.Sources.Inference.Kernels.ResidualRmsNorm.ast⟩,
   ⟨chars!"packages/inference/src/kernels/gated-rms-norm.ts", Host.Ts.Sources.Inference.Kernels.GatedRmsNorm.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/silu-rms-heads.ts", Host.Ts.Sources.Inference.Kernels.Delta.SiluRmsHeads.ast⟩,
   ⟨chars!"packages/inference/src/kernels/glm52/streamed-experts.ts", Host.Ts.Sources.Inference.Kernels.Glm52.StreamedExperts.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/glm52/kernel-layout.ts", Host.Ts.Sources.Inference.Artifacts.Glm52.KernelLayout.ast⟩,
   ⟨chars!"packages/inference/src/state/kv-storage.ts", Host.Ts.Sources.Inference.State.KvStorage.ast⟩,
   ⟨chars!"packages/inference/src/layers/kv4-decode-attention.ts", Host.Ts.Sources.Inference.Layers.Kv4DecodeAttention.ast⟩,
   ⟨chars!"packages/inference/src/state/full-prefill-padding.ts", Host.Ts.Sources.Inference.State.FullPrefillPadding.ast⟩,
   ⟨chars!"packages/inference/src/state/checkpoint.ts", Host.Ts.Sources.Inference.State.Checkpoint.ast⟩,
   ⟨chars!"packages/inference/src/state/paged/codec.ts", Host.Ts.Sources.Inference.State.Paged.Codec.ast⟩,
   ⟨chars!"packages/inference/src/state/persistence-worker.ts", Host.Ts.Sources.Inference.State.PersistenceWorker.ast⟩] ++
  HostLib.mods ++ [⟨entry, Driver.ast⟩]

def hosts : List (HMod LSt) :=
  HostLib.hosts ++ [HostLib.textMod chars!"packages/inference/src/state/persistence.worker.js" Data.workerChars]

/-- Module paths are relative to the real run's overlay root (`import.meta`). -/
def cx : LinkCx LSt := ⟨mods, hosts, entry, chars!"/tmp/tscov/inst"⟩

def modelDirC : List Char := strOf Data.modelDir

/-- The model directory as the file system: texts the route reads, shard
headers (length prefix and JSON) of the safetensors files, sizes of the rest. -/
def modelFiles : List (List Char × FileC) :=
  Data.listing.map fun (rel, size) =>
    let path := modelDirC ++ '/' :: rel
    bif nameEq rel chars!"config.json" then (path, .text Data.configChars)
    else bif nameEq rel chars!"model.safetensors.index.json" then (path, .text Data.indexChars)
    else bif nameEq rel chars!"turboquant_fold.json" then (path, .text Data.foldChars)
    else match Data.shards.find? fun (f, _, _, _) => nameEq f rel with
      | some (_, _, hlen, hdr) => (path, .blob size (leBytes 8 hlen ++ hdr.map Char.toNat))
      | none => (path, .blob size [])

/-- The native libraries the environment names (paths and sizes; only existence is read). -/
def libFiles : List (List Char × FileC) :=
  [(chars!"/Users/joshrossi/Code/mlx-bun/packages/mlx/dist/native/libmlxc.dylib", .blob 872352 []),
   (chars!"/Users/joshrossi/Code/mlx-bun/packages/inference/dist/native/libmlx_bun_ane.dylib", .blob 55320 []),
   (chars!"/Users/joshrossi/Code/mlx-bun/packages/inference/dist/native/libmlx_bun_expert_io.dylib", .blob 36136 [])]

/-- The real run's environment (`/tmp/tscov/env.sh` and `HOME`); no other
`MLX_BUN_*`, `MLX_METAL_GPU_ARCH` or `MLX_MAX_*_PER_BUFFER` variable is set. -/
def env : List (List Char × List Char) :=
  [(chars!"HOME", chars!"/Users/joshrossi"),
   (chars!"MLX_BUN_LIBMLXC", chars!"/Users/joshrossi/Code/mlx-bun/packages/mlx/dist/native/libmlxc.dylib"),
   (chars!"MLX_BUN_ANE_DYLIB", chars!"/Users/joshrossi/Code/mlx-bun/packages/inference/dist/native/libmlx_bun_ane.dylib"),
   (chars!"MLX_BUN_EXPERT_IO_DYLIB", chars!"/Users/joshrossi/Code/mlx-bun/packages/inference/dist/native/libmlx_bun_expert_io.dylib")]

/-- Platform facts of the M1 Max the real run used: Metal's architecture name
for the system device (`MTLDevice.architecture.name`, also MLX's
`mlx_device_info` "architecture"), the physical memory (`sysctl hw.memsize`),
and the runtime's `Math.log(1e-6)` (JavaScriptCore on macOS libm). -/
def arch : List Char := chars!"applegpu_g13s"
def memsize : Nat := 34359738368
def math : List (List Char × F64 × F64) :=
  [(chars!"log", F64.ofString chars!"1e-6", F64.ofString chars!"-13.815510557964274")]

def world : Host.Load.LSt :=
  Host.Load.LSt.mk (Host.Mlx.Ffi.init [] (Data.tables.map fun (f, t) => (modelDirC ++ '/' :: f, t)) arch [])
    (HostSt.init env (modelFiles ++ libFiles) arch memsize chars!"/tmp/tscov" math)

end Host.Load.Route
