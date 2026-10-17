import host.ts.tests.layers.Common
namespace Host.Ts.Tests.Layers.DeltaLayer
open Host.Ts

/-- The driver: real classes over the MLX FFI model (see `Common`). -/
def source : String := r#"import { Weights } from "./artifacts/weights";
import { SafetensorsFile, ShardedSafetensors } from "./artifacts/safetensors";
import { parseQuantization } from "./artifacts/config";
import { DeltaWeights, GateDownMLP, canonicalQwenWeights } from "./models/qwen/written-layers";
import { QwenResidualDeltaLayer, QwenFusedHeadsDeltaNet } from "./models/qwen/blocks";
import { CodebookSplitGateUpRow } from "./layers/trellis-codebook-gate-up";
import { CodebookDownK3iRow } from "./layers/trellis-codebook-down";
import { TrellisReducePrompt } from "./layers/trellis-prompt";
import { QuantizedLinearPlain } from "./layers/quantized-linear";
import { AffineRowLinear } from "./layers/affine-verify-linear";
import { LoraState } from "./layers/lora";
import { SSMCache } from "./state/ssm";
import * as ops from "@mlx-bun/mlx/ops";
const DIR = "/models/qwen3.8";
const SHARDS = [["model-00001-of-00007.safetensors",[["model.language_model.layers.1.input_layernorm.weight","BF16",[5120],978120224,978130464],["model.language_model.layers.1.linear_attn.A_log","BF16",[48],1324765920,1324766016],["model.language_model.layers.1.linear_attn.conv1d.weight","BF16",[10240,1,4],978038304,978120224],["model.language_model.layers.1.linear_attn.dt_bias","BF16",[48],977948512,977948608],["model.language_model.layers.1.linear_attn.in_proj_a.biases","BF16",[48,80],966144352,966152032],["model.language_model.layers.1.linear_attn.in_proj_a.scales","BF16",[48,80],978030528,978038208],["model.language_model.layers.1.linear_attn.in_proj_a.weight","U32",[48,640],1000457760,1000580640],["model.language_model.layers.1.linear_attn.in_proj_b.biases","BF16",[48,80],966013696,966021376],["model.language_model.layers.1.linear_attn.in_proj_b.scales","BF16",[48,80],2036300608,2036308288],["model.language_model.layers.1.linear_attn.in_proj_b.weight","U32",[48,640],966021472,966144352],["model.language_model.layers.1.linear_attn.in_proj_qkv.biases","BF16",[10240,80],924644096,926282496],["model.language_model.layers.1.linear_attn.in_proj_qkv.scales","BF16",[10240,80],180107008,181745408],["model.language_model.layers.1.linear_attn.in_proj_qkv.weight","U32",[10240,640],2096079168,2122293568],["model.language_model.layers.1.linear_attn.in_proj_z.biases","BF16",[6144,80],1137856384,1138839424],["model.language_model.layers.1.linear_attn.in_proj_z.scales","BF16",[6144,80],922667776,923650816],["model.language_model.layers.1.linear_attn.in_proj_z.weight","U32",[6144,640],1122117504,1137846144],["model.language_model.layers.1.linear_attn.norm.weight","BF16",[128],1036667936,1036668192],["model.language_model.layers.1.linear_attn.out_proj.biases","BF16",[5120,96],920701696,921684736],["model.language_model.layers.1.linear_attn.out_proj.scales","BF16",[5120,96],923650816,924633856],["model.language_model.layers.1.linear_attn.out_proj.weight","U32",[5120,768],2018800448,2034529088],["model.language_model.layers.1.mlp.down_proj.scales","F16",[17408],887126784,887161600],["model.language_model.layers.1.mlp.down_proj.weight","U32",[10,17408,48],1961448768,1994872128],["model.language_model.layers.1.mlp.gate_proj.scales","F16",[17408],852514048,852548864],["model.language_model.layers.1.mlp.gate_proj.weight","U32",[17408,480],852712704,886136064],["model.language_model.layers.1.mlp.up_proj.scales","F16",[17408],1199464672,1199499488],["model.language_model.layers.1.mlp.up_proj.weight","U32",[17408,480],181753088,215176448],["model.language_model.layers.1.post_attention_layernorm.weight","BF16",[5120],2069731648,2069741888],["mtp.fc.weight","U32",[5120,960],1202285280,1221946080]]]];
const QUANTIZATION = {"group_size":64,"bits":3,"mode":"affine","model.language_model.layers.1.linear_attn.in_proj_a":{"bits":4,"group_size":64},"language_model.model.layers.1.linear_attn.in_proj_a":{"bits":4,"group_size":64},"model.language_model.layers.1.linear_attn.in_proj_b":{"bits":4,"group_size":64},"language_model.model.layers.1.linear_attn.in_proj_b":{"bits":4,"group_size":64},"model.language_model.layers.1.linear_attn.in_proj_qkv":{"bits":4,"group_size":64},"language_model.model.layers.1.linear_attn.in_proj_qkv":{"bits":4,"group_size":64},"model.language_model.layers.1.linear_attn.in_proj_z":{"bits":4,"group_size":64},"language_model.model.layers.1.linear_attn.in_proj_z":{"bits":4,"group_size":64},"model.language_model.layers.1.linear_attn.out_proj":{"bits":4,"group_size":64},"language_model.model.layers.1.linear_attn.out_proj":{"bits":4,"group_size":64},"model.language_model.layers.1.mlp.down_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":0}},"language_model.model.layers.1.mlp.down_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":0}},"model.language_model.layers.1.mlp.gate_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"language_model.model.layers.1.mlp.gate_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"model.language_model.layers.1.mlp.up_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}},"language_model.model.layers.1.mlp.up_proj":{"bits":3,"group_size":256,"mode":"trellis","trellis":{"L":12,"code":"1mad","axis":1}}};
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
  const invScale = Math.pow(text.linearKeyHeadDim, -0.5);
  const qk = { q: ops.filledBf16(invScale * invScale, text.linearKeyHeadDim), k: ops.filledBf16(invScale, text.linearKeyHeadDim) };
  const d1 = new DeltaWeights(w, config, "language_model.model.layers.1", REPRESENTATIONS, new LoraState());
  const layer = d1.stage(w, config, QwenResidualDeltaLayer, GateDownMLP, CodebookSplitGateUpRow, TrellisReducePrompt,
    CodebookDownK3iRow, AffineRowLinear, AffineRowLinear, QuantizedLinearPlain, QuantizedLinearPlain, QuantizedLinearPlain, qk,
    QwenFusedHeadsDeltaNet);
  const cache = new SSMCache();
  const x = ops.zeros([1, 1, 5120], 12);
  const y = layer.forward(x, cache, "decode");
  const first = [y.shape, y.dtype];
  y.dispose();
  const y2 = layer.forward(x, cache, "decode");
  out = [first, y2.shape, y2.dtype, cache.offset, cache.conv.shape, cache.recurrent.shape, cache.recurrent.dtype];
}
main().catch(e => { out = ["error", String(e && e.message)]; });
"#
source_parse source
source_ast

def files : List (List Char × Host.Mlx.Ffi.Header) :=
[(chars!"/models/qwen3.8/model-00001-of-00007.safetensors",
  [(chars!"model.language_model.layers.1.input_layernorm.weight", [5120], 12),
   (chars!"model.language_model.layers.1.linear_attn.A_log", [48], 12),
   (chars!"model.language_model.layers.1.linear_attn.conv1d.weight", [10240, 1, 4], 12),
   (chars!"model.language_model.layers.1.linear_attn.dt_bias", [48], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.biases", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.scales", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_a.weight", [48, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.biases", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.scales", [48, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_b.weight", [48, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.biases", [10240, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.scales", [10240, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_qkv.weight", [10240, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.biases", [6144, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.scales", [6144, 80], 12),
   (chars!"model.language_model.layers.1.linear_attn.in_proj_z.weight", [6144, 640], 3),
   (chars!"model.language_model.layers.1.linear_attn.norm.weight", [128], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.biases", [5120, 96], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.scales", [5120, 96], 12),
   (chars!"model.language_model.layers.1.linear_attn.out_proj.weight", [5120, 768], 3),
   (chars!"model.language_model.layers.1.mlp.down_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.down_proj.weight", [10, 17408, 48], 3),
   (chars!"model.language_model.layers.1.mlp.gate_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.gate_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.1.mlp.up_proj.scales", [17408], 9),
   (chars!"model.language_model.layers.1.mlp.up_proj.weight", [17408, 480], 3),
   (chars!"model.language_model.layers.1.post_attention_layernorm.weight", [5120], 12),
   (chars!"mtp.fc.weight", [5120, 960], 3)])]

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
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-row.ts", Host.Ts.Sources.Inference.Kernels.Quantization.AffineRow.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-split-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffineSplitMma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine3Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine3-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine3Mma.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-rows.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine4Rows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine4-mma.ts", Tests.Layers.StandInferenceKernelsQuantizationAffine4Mma.ast⟩,
   ⟨chars!"packages/inference/src/layers/affine-verify-linear.ts", Host.Ts.Sources.Inference.Layers.AffineVerifyLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Host.Ts.Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/materialize.ts", Host.Ts.Sources.Mlx.Materialize.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Host.Ts.Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/autograd.ts", Tests.Layers.StandMlxAutograd.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Host.Ts.Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/custom-vjp.ts", Tests.Layers.StandMlxCustomVjp.ast⟩,
   ⟨chars!"packages/mlx/src/ffi.ts", Host.Ts.Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Host.Ts.Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/gated.ts", Host.Ts.Sources.Inference.Kernels.Delta.Gated.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/state.ts", Tests.Layers.StandInferenceKernelsDeltaState.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Host.Ts.Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/state/ssm.ts", Host.Ts.Sources.Inference.State.Ssm.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Host.Ts.Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/inference/src/__deltalayer.ts", ast⟩]

def boot0 : Option (St Host.Mlx.Ffi.St) :=
  boot (Host.Mlx.Ffi.init [] files chars!"applegpu_g13s" []) mods [bunFfi, symMod] chars!"packages/inference/src/__deltalayer.ts"

end Host.Ts.Tests.Layers.DeltaLayer
