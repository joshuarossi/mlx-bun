import host.ts.tests.MlxSrc
import host.ts.ast.inference.state.Kv
import host.ts.ast.inference.state.AttentionRead

/-! Stand-ins for the five modules `state/kv.ts` imports that the decode
path does not execute (every stand-in function throws, so a run that
reached one would fail), and the `updateAndFetch` driver. The host module
`sym` exports the symbolic cache offset `n` (number-table entry 0). -/

namespace Host.Ts.Tests.KvMasks
def source : String := "export function bidirMask() { throw new Error(\"stand-in\"); }
export function createCausalMask() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.KvMasks

namespace Host.Ts.Tests.KvQuantized
def source : String := "export class QuantizedKVCache { constructor() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.KvQuantized

namespace Host.Ts.Tests.KvTurbo
def source : String := "export const uncomposedTurboQuantKernels = Object.freeze({});"
source_parse source
source_ast
end Host.Ts.Tests.KvTurbo

namespace Host.Ts.Tests.KvFolded
def source : String := "export function foldedSdpa() { throw new Error(\"stand-in\"); }
export function foldedSdpaEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.KvFolded

namespace Host.Ts.Tests.KvResources
def source : String := "export function disposeResources() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.KvResources

namespace Host.Ts.Tests.KvDrive
/-- A cache with 512 preallocated positions at symbolic offset `n`, one
appended token (`L = 1`). -/
def source : String := "import { KVCache } from \"./kv\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { n } from \"sym\";
const cache = new KVCache();
cache.keys = ops.zeros([1, 2, 512, 4], 10);
cache.values = ops.zeros([1, 2, 512, 4], 10);
cache.offset = n;
const k = ops.zeros([1, 2, 1, 4], 10);
const v = ops.zeros([1, 2, 1, 4], 10);
const [K, V] = cache.updateAndFetch(k, v);
export const out = [K.shape, V.shape, cache.offset];"
source_parse source
source_ast
end Host.Ts.Tests.KvDrive

namespace Host.Ts.Tests
open Host.Ts

def kvMods : List UMod :=
  (mlxMods []).dropLast ++
  [⟨chars!"packages/inference/src/state/kv.ts", Sources.Inference.State.Kv.ast⟩,
   ⟨chars!"packages/inference/src/state/attention-read.ts", Sources.Inference.State.AttentionRead.ast⟩,
   ⟨chars!"packages/inference/src/kernels/attention/masks.ts", KvMasks.ast⟩,
   ⟨chars!"packages/inference/src/state/quantized-kv.ts", KvQuantized.ast⟩,
   ⟨chars!"packages/inference/src/state/turboquant-attention.ts", KvTurbo.ast⟩,
   ⟨chars!"packages/inference/src/layers/folded-attention.ts", KvFolded.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", KvResources.ast⟩,
   ⟨chars!"packages/inference/src/state/__drive.ts", KvDrive.ast⟩]

def symMod {S : Type} : HMod S := ⟨chars!"sym", pure [(chars!"n", .num (.ref 0))]⟩

def kvBoot : Option (St Mock.St) :=
  boot Mock.init kvMods [bunFfi, symMod] chars!"packages/inference/src/state/__drive.ts"

end Host.Ts.Tests
