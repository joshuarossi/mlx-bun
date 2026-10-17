import host.ts.tests.KvSrc
import host.ts.ast.mlx.Compile
import host.ts.ast.inference.models.qwen.Blocks
import host.ts.ast.inference.layers.Helpers
import host.ts.ast.inference.layers.QuantizedLinear
import host.ts.ast.inference.layers.Lora
import host.ts.ast.inference.layers.Normalization
import host.ts.ast.inference.layers.CompiledNormalization
import host.ts.ast.inference.layers.DeltaHeads

/-! The Qwen 3.5 full-attention block `Qwen3TextAttention.forward`
(`models/qwen/blocks.ts`): real block, norms, RoPE, KV cache append and
SDPA read; the four projections are reshaping stand-ins (`lin`), and the
modules on the import closure that the decode attention does not execute
are throwing stand-ins. -/

namespace Host.Ts.Tests.AttnTrellis
def source : String := "export class TrellisLinear { constructor() { throw new Error(\"stand-in\"); } }\nexport function fusedGateUpEligible() { throw new Error(\"stand-in\"); }\nexport function fusedGateUpSwiglu() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnTrellis

namespace Host.Ts.Tests.AttnSwiglu
def source : String := "export function compiledSwiglu() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnSwiglu

namespace Host.Ts.Tests.AttnMrope
def source : String := "export function applyInterleavedRope() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnMrope

namespace Host.Ts.Tests.AttnConfig
def source : String := "export function quantFor() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnConfig

namespace Host.Ts.Tests.AttnAffineRows
def source : String := "export function quantizedMatmulRows() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnAffineRows

namespace Host.Ts.Tests.AttnResidualRms
def source : String := "export function residualRmsNorm() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnResidualRms

namespace Host.Ts.Tests.AttnGatedRms
def source : String := "export function gatedRmsNorm() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnGatedRms

namespace Host.Ts.Tests.AttnSiluHeads
def source : String := "export function siluRmsHeads() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.AttnSiluHeads

namespace Host.Ts.Tests.AttnDrive
def source : String := "import { Qwen3TextAttention } from \"./models/qwen/blocks\";\nimport { KVCache } from \"./state/kv\";\nimport * as ops from \"@mlx-bun/mlx/ops\";\nimport { n } from \"sym\";\nconst H = 4, KV = 2, D = 16, hidden = 64;\nconst lin = (out) => ({ forward: (x) => ops.reshape(x, [1, 1, out]) });\nconst weights = { tensor: () => ops.zeros([D], 10) };\nconst config = { text: { numAttentionHeads: H, numKeyValueHeads: KV, headDim: D, partialRotaryFactor: 0.25, ropeParameters: {}, rmsNormEps: 0.000001 } };\nconst attn = new Qwen3TextAttention(weights, config, \"p\", { qProj: lin(2 * H * D), kProj: lin(KV * D), vProj: lin(KV * D), oProj: lin(hidden) });\nconst cache = new KVCache();\ncache.keys = ops.zeros([1, KV, 256, D], 10);\ncache.values = ops.zeros([1, KV, 256, D], 10);\ncache.offset = n;\nconst x = ops.zeros([1, 1, hidden], 10);\nconst y = attn.forward(x, cache, \"decode\");\nexport const out = [y.shape, cache.offset];"
source_parse source
source_ast
end Host.Ts.Tests.AttnDrive

namespace Host.Ts.Tests
open Host.Ts

def attnMods : List UMod :=
  kvMods.dropLast ++
  [⟨chars!"packages/mlx/src/compile.ts", Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/inference/src/models/qwen/blocks.ts", Sources.Inference.Models.Qwen.Blocks.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/layers/quantized-linear.ts", Sources.Inference.Layers.QuantizedLinear.ast⟩,
   ⟨chars!"packages/inference/src/layers/lora.ts", Sources.Inference.Layers.Lora.ast⟩,
   ⟨chars!"packages/inference/src/layers/normalization.ts", Sources.Inference.Layers.Normalization.ast⟩,
   ⟨chars!"packages/inference/src/layers/compiled-normalization.ts", Sources.Inference.Layers.CompiledNormalization.ast⟩,
   ⟨chars!"packages/inference/src/layers/delta-heads.ts", Sources.Inference.Layers.DeltaHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/trellis-linear.ts", AttnTrellis.ast⟩,
   ⟨chars!"packages/inference/src/layers/swiglu.ts", AttnSwiglu.ast⟩,
   ⟨chars!"packages/inference/src/layers/qwen-mrope.ts", AttnMrope.ast⟩,
   ⟨chars!"packages/inference/src/artifacts/config.ts", AttnConfig.ast⟩,
   ⟨chars!"packages/inference/src/kernels/quantization/affine-rows.ts", AttnAffineRows.ast⟩,
   ⟨chars!"packages/inference/src/kernels/residual-rms-norm.ts", AttnResidualRms.ast⟩,
   ⟨chars!"packages/inference/src/kernels/gated-rms-norm.ts", AttnGatedRms.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/silu-rms-heads.ts", AttnSiluHeads.ast⟩,
   ⟨chars!"packages/inference/src/__attn.ts", AttnDrive.ast⟩]

def attnBoot : Option (St Mock.St) :=
  boot Mock.init attnMods [bunFfi, symMod] chars!"packages/inference/src/__attn.ts"

end Host.Ts.Tests
