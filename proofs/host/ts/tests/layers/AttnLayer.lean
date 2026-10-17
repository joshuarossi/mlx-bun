import host.ts.tests.layers.Common
namespace Host.Ts.Tests.Layers.AttnLayer
open Host.Ts

/-- The driver: real classes over the MLX FFI model (see `Common`). -/
def source : String := r#"import { Weights } from "./artifacts/weights";
import { SafetensorsFile, ShardedSafetensors } from "./artifacts/safetensors";
import { parseQuantization } from "./artifacts/config";
import { AttentionWeights, GateDownMLP, canonicalQwenWeights } from "./models/qwen/written-layers";
import { QwenResidualAttentionLayer } from "./models/qwen/blocks";
import { CodebookSplitGateUpRow } from "./layers/trellis-codebook-gate-up";
import { CodebookDownK3iRow } from "./layers/trellis-codebook-down";
import { TrellisReducePrompt } from "./layers/trellis-prompt";
import { QuantizedLinearPlain } from "./layers/quantized-linear";
import { LoraState } from "./layers/lora";
import { KVCache } from "./state/kv";
import * as ops from "@mlx-bun/mlx/ops";
import { n } from "sym";
const DIR = "/models/qwen3.8";
const SHARDS = [["model-00001-of-00007.safetensors",[["model.language_model.layers.3.input_layernorm.weight","BF16",[5120],33423360,33433600],["model.language_model.layers.3.mlp.down_proj.scales","F16",[17408],1173911424,1173946240],["model.language_model.layers.3.mlp.down_proj.weight","U32",[10,17408,48],0,33423360],["mtp.fc.biases","BF16",[5120,160],2034529088,2036167488],["mtp.fc.scales","BF16",[5120,160],1994879808,1996518208],["mtp.fc.weight","U32",[5120,960],1202285280,1221946080]]],["model-00002-of-00007.safetensors",[["model.language_model.layers.3.mlp.gate_proj.scales","F16",[17408],1029698016,1029732832],["model.language_model.layers.3.mlp.gate_proj.weight","U32",[17408,480],2073452416,2106875776],["model.language_model.layers.3.mlp.up_proj.scales","F16",[17408],2112207648,2112242464],["model.language_model.layers.3.mlp.up_proj.weight","U32",[17408,480],1869905120,1903328480],["model.language_model.layers.3.post_attention_layernorm.weight","BF16",[5120],1064963776,1064974016],["model.language_model.layers.3.self_attn.k_norm.weight","BF16",[256],868722176,868722688],["model.language_model.layers.3.self_attn.k_proj.biases","BF16",[1024,80],2012138368,2012302208],["model.language_model.layers.3.self_attn.k_proj.scales","BF16",[1024,80],1538500000,1538663840],["model.language_model.layers.3.self_attn.k_proj.weight","U32",[1024,640],1375968800,1378590240],["model.language_model.layers.3.self_attn.o_proj.biases","BF16",[5120,96],932650400,933633440],["model.language_model.layers.3.self_attn.o_proj.scales","BF16",[5120,96],1847088608,1848071648],["model.language_model.layers.3.self_attn.o_proj.weight","U32",[5120,768],1956980608,1972709248],["model.language_model.layers.3.self_attn.q_norm.weight","BF16",[256],1913247200,1913247712],["model.language_model.layers.3.self_attn.q_proj.biases","BF16",[12288,80],1867925984,1869892064],["model.language_model.layers.3.self_attn.q_proj.scales","BF16",[12288,80],1913247712,1915213792],["model.language_model.layers.3.self_attn.q_proj.weight","U32",[12288,640],1972709248,2004166528],["model.language_model.layers.3.self_attn.v_proj.biases","BF16",[1024,80],2042772448,2042936288],["model.language_model.layers.3.self_attn.v_proj.scales","BF16",[1024,80],1281061856,1281225696],["model.language_model.layers.3.self_attn.v_proj.weight","U32",[1024,640],2132778016,2135399456]]]];
const QUANTIZATION = {"group_size":64,"bits":3,"mode":"affine","model.language_model.layers.3.mlp.down_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":0}},"language_model.model.layers.3.mlp.down_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":0}},"model.language_model.layers.3.mlp.gate_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"language_model.model.layers.3.mlp.gate_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"model.language_model.layers.3.mlp.up_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"language_model.model.layers.3.mlp.up_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"model.language_model.layers.3.self_attn.k_proj":{"bits":4,"group_size":64},"language_model.model.layers.3.self_attn.k_proj":{"bits":4,"group_size":64},"model.language_model.layers.3.self_attn.o_proj":{"bits":4,"group_size":64},"language_model.model.layers.3.self_attn.o_proj":{"bits":4,"group_size":64},"model.language_model.layers.3.self_attn.q_proj":{"bits":4,"group_size":64},"language_model.model.layers.3.self_attn.q_proj":{"bits":4,"group_size":64},"model.language_model.layers.3.self_attn.v_proj":{"bits":4,"group_size":64},"language_model.model.layers.3.self_attn.v_proj":{"bits":4,"group_size":64}};
const REPRESENTATIONS = {gateUpCodebook:true,mixedExactBits:true,scatter:{bits:true,genericBits:true,floatCodebook:true},widePrefill:false};
const text = { hiddenSize: 5120, numHiddenLayers: 64, numAttentionHeads: 24, numKeyValueHeads: 4, headDim: 256,
  intermediateSize: 17408, rmsNormEps: 0.000001, linearNumValueHeads: 48, linearNumKeyHeads: 16, linearKeyHeadDim: 128,
  linearValueHeadDim: 128, linearConvKernelDim: 4, fullAttentionInterval: 4, attnOutputGate: true, partialRotaryFactor: 0.25,
  ropeParameters: { full_attention: { ropeTheta: 10000000, ropeType: "default", partialRotaryFactor: 0.25, factor: 1 } } };
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
  const w = canonicalQwenWeights(weights);
  const config = { text, quantization: parseQuantization(QUANTIZATION) };
  const a3 = new AttentionWeights(w, config, "language_model.model.layers.3", REPRESENTATIONS, new LoraState());
  const layer = a3.stage(w, config, QwenResidualAttentionLayer, GateDownMLP, CodebookSplitGateUpRow, TrellisReducePrompt,
    CodebookDownK3iRow, QuantizedLinearPlain, QuantizedLinearPlain, QuantizedLinearPlain, QuantizedLinearPlain);
  const cache = new KVCache();
  cache.keys = ops.zeros([1, 4, 256, 256], 12);
  cache.values = ops.zeros([1, 4, 256, 256], 12);
  cache.offset = n;
  const x = ops.zeros([1, 1, 5120], 12);
  const y = layer.forward(x, cache, "decode");
  out = [y.shape, y.dtype, cache.offset];
}
main();
"#
source_parse source
source_ast

def files : List (List Char × Host.Mlx.Ffi.Header) :=
[(chars!"/models/qwen3.8/model-00001-of-00007.safetensors",
  [(chars!"model.language_model.layers.3.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.3.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"mtp.fc.biases", [5120, 160], 12),
   (chars!"mtp.fc.scales", [5120, 160], 12),
   (chars!"mtp.fc.weight", [5120, 960], 3)]),
 (chars!"/models/qwen3.8/model-00002-of-00007.safetensors",
  [(chars!"model.language_model.layers.3.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.3.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.3.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.3.post_attention_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.3.self_attn.k_norm.weight", [256], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.k_proj.weight", [1024, 640], 3),
   (chars!"model.language_model.layers.3.self_attn.o_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.3.self_attn.o_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.3.self_attn.o_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.3.self_attn.q_norm.weight", [256], 12),
   (chars!"model.language_model.layers.3.self_attn.q_proj.biases", [12288, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.q_proj.scales", [12288, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.q_proj.weight", [12288, 640], 3),
   (chars!"model.language_model.layers.3.self_attn.v_proj.biases", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.v_proj.scales", [1024, 80], 12),
   (chars!"model.language_model.layers.3.self_attn.v_proj.weight", [1024, 640], 3)])]

def mods : List UMod :=
  [⟨chars!"packages/inference/src/artifacts/mmap.ts", Tests.Layers.StandInferenceArtifactsMmap.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/safetensors.ts", Host.Ts.Sources.Inference.Artifacts.Safetensors.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", Tests.Layers.StandMlxHostBuffer.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", Tests.Layers.StandMlxCommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", Tests.Layers.StandMlxNative.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/weights.ts", Host.Ts.Sources.Inference.Artifacts.Weights.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/safetensors.ts", Host.Ts.Sources.Inference.Artifacts.Safetensors.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Host.Ts.Sources.Inference.Artifacts.Config.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Host.Ts.Sources.Inference.Artifacts.Config.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffineRows.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Host.Ts.Sources.Inference.Artifacts.Config.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Codebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/index.ts", Tests.Layers.StandInferenceKernelsTrellisIndex.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", Host.Ts.Sources.Inference.Layers.TrellisLinear.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", Host.Ts.Sources.Inference.Layers.Swiglu.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", Host.Ts.Sources.Inference.Layers.TrellisLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-prompt.ts", Host.Ts.Sources.Inference.Layers.TrellisPrompt.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", Host.Ts.Sources.Inference.Layers.TrellisLinear.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Host.Ts.Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", Host.Ts.Sources.Inference.Layers.Swiglu.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/normalization.ts", Host.Ts.Sources.Inference.Layers.Normalization.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/residual-rms-norm.ts", Host.Ts.Sources.Inference.Kernels.ResidualRmsNorm.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/gated-rms-norm.ts", Host.Ts.Sources.Inference.Kernels.GatedRmsNorm.ast⟩,
   ⟨chars!"packages/inference/src/layers/compiled-normalization.ts", Host.Ts.Sources.Inference.Layers.CompiledNormalization.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/silu-rms-heads.ts", Host.Ts.Sources.Inference.Kernels.Delta.SiluRmsHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/delta-heads.ts", Host.Ts.Sources.Inference.Layers.DeltaHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/qwen-mrope.ts", Tests.Layers.StandInferenceLayersQwenMrope.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/blocks.ts", Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/layers/ane-prefill-split.ts", Tests.Layers.StandInferenceLayersAnePrefillSplit.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", Host.Ts.Sources.Inference.Layers.Swiglu.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", Host.Ts.Sources.Inference.Artifacts.Config.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/checkpoint.ts", Host.Ts.Sources.Inference.Models.Qwen.Checkpoint.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/written-layers.ts", Host.Ts.Sources.Inference.Models.Qwen.WrittenLayers.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/blocks.ts", Host.Ts.Sources.Inference.Models.Qwen.Blocks.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Codebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/launch.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Launch.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/gate-up-codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.GateUpCodebook.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-gate-up.ts", Host.Ts.Sources.Inference.Layers.TrellisCodebookGateUp.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Codebook.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/launch.ts", Host.Ts.Sources.Inference.Kernels.Trellis.Launch.ast⟩,
   ⟨chars!"packages/inference/src/kernels/trellis/down-codebook.ts", Host.Ts.Sources.Inference.Kernels.Trellis.DownCodebook.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-codebook-down.ts", Host.Ts.Sources.Inference.Layers.TrellisCodebookDown.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-prompt.ts", Host.Ts.Sources.Inference.Layers.TrellisPrompt.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Host.Ts.Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/masks.ts", Tests.Layers.StandInferenceKernelsAttentionMasks.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-kv.ts", Tests.Layers.StandInferenceStateQuantizedKv.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/layers/folded-attention.ts", Tests.Layers.StandInferenceLayersFoldedAttention.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", Tests.Layers.StandInferenceRuntimeResources.ast⟩,
   ⟨chars!"packages/inference/src/state/attention-read.ts", Host.Ts.Sources.Inference.State.AttentionRead.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-attention.ts", Tests.Layers.StandInferenceStateTurboquantAttention.ast⟩,
   ⟨chars!"packages/inference/src/state/kv.ts", Host.Ts.Sources.Inference.State.Kv.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/__attnlayer.ts", ast⟩]

def boot0 : Option (St Host.Mlx.Ffi.St) :=
  boot (Host.Mlx.Ffi.init [] files chars!"applegpu_g13s" []) mods [bunFfi, symMod] chars!"packages/inference/src/__attnlayer.ts"

end Host.Ts.Tests.Layers.AttnLayer
