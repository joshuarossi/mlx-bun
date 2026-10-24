import host.sim.stage.Under
import host.ts.tests.layers.Common
import host.mlx.FfiExpr
import host.ts.ast.inference.runtime.Resources
import host.ts.ast.inference.state.Leases
import host.ts.ast.inference.generation.Prefill
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Ssm
open Host.Ts Host.Ts.Sim.Stage

/-! # The SSM cache stage's templates: `SSMCache.recurDecode` and `evalCacheState`

Over the MLX FFI model (native state concrete), the drivers build an `SSMCache` (state/ssm.ts:96-205)
and the recurrence parameters a gated-DeltaNet block lends it (`GatedDeltaNet.recurrence`,
models/qwen/blocks.ts:162-165) at the route's linear-attention geometry (key heads 16, value heads 48,
head widths 128, convolution width 10240, kernel 4; weights `zeros` of the checkpoint's shapes and
dtypes): `heads` is `QwenFusedHeadsDeltaNet.heads` (blocks.ts:428-433), the shared
`CompiledSiluRMSHeads(16, 48, 128)` over folded Q/K scales (layers/delta-heads.ts). Each call is
`recurDecode` (ssm.ts:149-151 → `#recur` :167-205: convolution over the stored state, the heads, the
`gated_delta_step` kernel over the stored recurrent state, both states replaced, `advance(1)`), then
`evalCacheState` (generation/prefill.ts:12-14). Classes: `SsmF.first` (null states: the only row of a
one-token prompt; fresh module memos, both compiled closures traced), `Ssm.cold` (states present, fresh
memos: the closures traced at one row), `Ssm.warm` (the steady decode call: memos filled, the closures
replayed), and `evalCacheState` after the first and the warm call. The symbolic input is the driver's
offset `o` (`var 0`). Each stage is checked with the caller frames free (`tplN`, `stage_rfl`, 100-step
chunks: longer chunks through a closure trace exceed the kernel's recursion depth); `*.drive` composes
each driver's run from its stages and the driver's own steps. -/

namespace DFirst
def source : String := "import { SSMCache } from \"./state/ssm\";
import { CompiledSiluRMSHeads } from \"./layers/delta-heads\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { o } from \"sym\";
const headOperation = new CompiledSiluRMSHeads(16, 48, 128);
const qkScale = { q: ops.filledBf16(1 / 128, 128), k: ops.filledBf16(Math.pow(128, -0.5), 128) };
const layer = Object.freeze({ convWeight: ops.zeros([10240, 4, 1], 12), aLog: ops.zeros([48], 12), dtBias: ops.zeros([48], 12),
  heads: (convolved) => { const [q, k, v] = headOperation.forward(convolved, qkScale.q, qkScale.k); return { q, k, v }; } });
const cache = new SSMCache();
const y = cache.recurDecode(ops.zeros([1, 1, 10240], 12), ops.zeros([1, 1, 48], 12), ops.zeros([1, 1, 48], 12), layer);
evalCacheState([cache]);
y.dispose();
export const out = [cache.offset];"
source_parse source
source_ast
end DFirst

namespace DDec
def source : String := "import { SSMCache } from \"./state/ssm\";
import { CompiledSiluRMSHeads } from \"./layers/delta-heads\";
import { evalCacheState } from \"./generation/prefill\";
import * as ops from \"@mlx-bun/mlx/ops\";
import { o } from \"sym\";
const headOperation = new CompiledSiluRMSHeads(16, 48, 128);
const qkScale = { q: ops.filledBf16(1 / 128, 128), k: ops.filledBf16(Math.pow(128, -0.5), 128) };
const layer = Object.freeze({ convWeight: ops.zeros([10240, 4, 1], 12), aLog: ops.zeros([48], 12), dtBias: ops.zeros([48], 12),
  heads: (convolved) => { const [q, k, v] = headOperation.forward(convolved, qkScale.q, qkScale.k); return { q, k, v }; } });
const cache = new SSMCache();
cache.conv = ops.zeros([1, 3, 10240], 12);
cache.recurrent = ops.zeros([1, 48, 128, 128], 10);
cache.offset = o;
const y1 = cache.recurDecode(ops.zeros([1, 1, 10240], 12), ops.zeros([1, 1, 48], 12), ops.zeros([1, 1, 48], 12), layer);
y1.dispose();
const y2 = cache.recurDecode(ops.zeros([1, 1, 10240], 12), ops.zeros([1, 1, 48], 12), ops.zeros([1, 1, 48], 12), layer);
evalCacheState([cache]);
y2.dispose();
export const out = [cache.offset];"
source_parse source
source_ast
end DDec

def symMod {S : Type} : HMod S := ⟨chars!"sym", pure [(chars!"o", .num (.ref 0))]⟩

def modsOf (d : Module) : List UMod :=
  [⟨chars!"packages/mlx/src/ffi.ts", Sources.Mlx.Ffi.ast⟩,
   ⟨chars!"packages/mlx/src/array.ts", Sources.Mlx.Array.ast⟩,
   ⟨chars!"packages/mlx/src/ops.ts", Sources.Mlx.Ops.ast⟩,
   ⟨chars!"packages/mlx/src/native.ts", Tests.Layers.StandMlxNative.ast⟩,
   ⟨chars!"packages/mlx/src/command-buffers.ts", Tests.Layers.StandMlxCommandBuffers.ast⟩,
   ⟨chars!"packages/mlx/src/host-buffer.ts", Tests.Layers.StandMlxHostBuffer.ast⟩,
   ⟨chars!"packages/mlx/src/materialize.ts", Sources.Mlx.Materialize.ast⟩,
   ⟨chars!"packages/mlx/src/compile.ts", Sources.Mlx.Compile.ast⟩,
   ⟨chars!"packages/mlx/src/metal-kernel.ts", Sources.Mlx.MetalKernel.ast⟩,
   ⟨chars!"packages/mlx/src/autograd.ts", Tests.Layers.StandMlxAutograd.ast⟩,
   ⟨chars!"packages/mlx/src/custom-vjp.ts", Tests.Layers.StandMlxCustomVjp.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/gated.ts", Sources.Inference.Kernels.Delta.Gated.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/state.ts", Tests.Layers.StandInferenceKernelsDeltaState.ast⟩,
   ⟨chars!"packages/inference/src/kernels/delta/silu-rms-heads.ts", Sources.Inference.Kernels.Delta.SiluRmsHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/delta-heads.ts", Sources.Inference.Layers.DeltaHeads.ast⟩,
   ⟨chars!"packages/inference/src/layers/helpers.ts", Sources.Inference.Layers.Helpers.ast⟩,
   ⟨chars!"packages/inference/src/state/ssm.ts", Sources.Inference.State.Ssm.ast⟩,
   ⟨chars!"packages/inference/src/runtime/resources.ts", Sources.Inference.Runtime.Resources.ast⟩,
   ⟨chars!"packages/inference/src/state/leases.ts", Sources.Inference.State.Leases.ast⟩,
   ⟨chars!"packages/inference/src/generation/prefill.ts", Sources.Inference.Generation.Prefill.ast⟩,
   ⟨chars!"packages/inference/src/__ssm.ts", d⟩]

def bootOf (d : Module) : Option (St Host.Mlx.Ffi.ffi.S) :=
  boot (Host.Mlx.Ffi.init [] [] chars!"applegpu_g13s" []) (modsOf d) [bunFfi, symMod] chars!"packages/inference/src/__ssm.ts"

/-- The discovery valuation: offset `o`. -/
def ρ1 (o : Nat) : Nat → F64 := fun _ => F64.ofNat o

set_option maxHeartbeats 0 in
host_chain_sym SsmF : Host.Mlx.Ffi.ffi, bootOf DFirst.ast, [.var 0], ρ1 1000, 60000, [4000, 4000, 4000, 184, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 37, 1, 12, 991, 1, 59]

kernel_rfl SsmF.firstD : SsmF.s172.stack.length = 4
stage_rfl SsmF.firstB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s4 0 r) SsmF.S4 = some (tplN SsmF.s5 (SsmF.s5.stack.length - 3) r, SsmF.S5)
stage_rfl SsmF.firstB1 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s5 (SsmF.s5.stack.length - 3) r) SsmF.S5 = some (tplN SsmF.s6 (SsmF.s6.stack.length - 3) r, SsmF.S6)
stage_rfl SsmF.firstB2 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s6 (SsmF.s6.stack.length - 3) r) SsmF.S6 = some (tplN SsmF.s7 (SsmF.s7.stack.length - 3) r, SsmF.S7)
stage_rfl SsmF.firstB3 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s7 (SsmF.s7.stack.length - 3) r) SsmF.S7 = some (tplN SsmF.s8 (SsmF.s8.stack.length - 3) r, SsmF.S8)
stage_rfl SsmF.firstB4 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s8 (SsmF.s8.stack.length - 3) r) SsmF.S8 = some (tplN SsmF.s9 (SsmF.s9.stack.length - 3) r, SsmF.S9)
stage_rfl SsmF.firstB5 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s9 (SsmF.s9.stack.length - 3) r) SsmF.S9 = some (tplN SsmF.s10 (SsmF.s10.stack.length - 3) r, SsmF.S10)
stage_rfl SsmF.firstB6 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s10 (SsmF.s10.stack.length - 3) r) SsmF.S10 = some (tplN SsmF.s11 (SsmF.s11.stack.length - 3) r, SsmF.S11)
stage_rfl SsmF.firstB7 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s11 (SsmF.s11.stack.length - 3) r) SsmF.S11 = some (tplN SsmF.s12 (SsmF.s12.stack.length - 3) r, SsmF.S12)
stage_rfl SsmF.firstB8 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s12 (SsmF.s12.stack.length - 3) r) SsmF.S12 = some (tplN SsmF.s13 (SsmF.s13.stack.length - 3) r, SsmF.S13)
stage_rfl SsmF.firstB9 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s13 (SsmF.s13.stack.length - 3) r) SsmF.S13 = some (tplN SsmF.s14 (SsmF.s14.stack.length - 3) r, SsmF.S14)
stage_rfl SsmF.firstB10 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s14 (SsmF.s14.stack.length - 3) r) SsmF.S14 = some (tplN SsmF.s15 (SsmF.s15.stack.length - 3) r, SsmF.S15)
stage_rfl SsmF.firstB11 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s15 (SsmF.s15.stack.length - 3) r) SsmF.S15 = some (tplN SsmF.s16 (SsmF.s16.stack.length - 3) r, SsmF.S16)
stage_rfl SsmF.firstB12 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s16 (SsmF.s16.stack.length - 3) r) SsmF.S16 = some (tplN SsmF.s17 (SsmF.s17.stack.length - 3) r, SsmF.S17)
stage_rfl SsmF.firstB13 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s17 (SsmF.s17.stack.length - 3) r) SsmF.S17 = some (tplN SsmF.s18 (SsmF.s18.stack.length - 3) r, SsmF.S18)
stage_rfl SsmF.firstB14 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s18 (SsmF.s18.stack.length - 3) r) SsmF.S18 = some (tplN SsmF.s19 (SsmF.s19.stack.length - 3) r, SsmF.S19)
stage_rfl SsmF.firstB15 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s19 (SsmF.s19.stack.length - 3) r) SsmF.S19 = some (tplN SsmF.s20 (SsmF.s20.stack.length - 3) r, SsmF.S20)
stage_rfl SsmF.firstB16 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s20 (SsmF.s20.stack.length - 3) r) SsmF.S20 = some (tplN SsmF.s21 (SsmF.s21.stack.length - 3) r, SsmF.S21)
stage_rfl SsmF.firstB17 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s21 (SsmF.s21.stack.length - 3) r) SsmF.S21 = some (tplN SsmF.s22 (SsmF.s22.stack.length - 3) r, SsmF.S22)
stage_rfl SsmF.firstB18 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s22 (SsmF.s22.stack.length - 3) r) SsmF.S22 = some (tplN SsmF.s23 (SsmF.s23.stack.length - 3) r, SsmF.S23)
stage_rfl SsmF.firstB19 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s23 (SsmF.s23.stack.length - 3) r) SsmF.S23 = some (tplN SsmF.s24 (SsmF.s24.stack.length - 3) r, SsmF.S24)
stage_rfl SsmF.firstB20 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s24 (SsmF.s24.stack.length - 3) r) SsmF.S24 = some (tplN SsmF.s25 (SsmF.s25.stack.length - 3) r, SsmF.S25)
stage_rfl SsmF.firstB21 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s25 (SsmF.s25.stack.length - 3) r) SsmF.S25 = some (tplN SsmF.s26 (SsmF.s26.stack.length - 3) r, SsmF.S26)
stage_rfl SsmF.firstB22 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s26 (SsmF.s26.stack.length - 3) r) SsmF.S26 = some (tplN SsmF.s27 (SsmF.s27.stack.length - 3) r, SsmF.S27)
stage_rfl SsmF.firstB23 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s27 (SsmF.s27.stack.length - 3) r) SsmF.S27 = some (tplN SsmF.s28 (SsmF.s28.stack.length - 3) r, SsmF.S28)
stage_rfl SsmF.firstB24 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s28 (SsmF.s28.stack.length - 3) r) SsmF.S28 = some (tplN SsmF.s29 (SsmF.s29.stack.length - 3) r, SsmF.S29)
stage_rfl SsmF.firstB25 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s29 (SsmF.s29.stack.length - 3) r) SsmF.S29 = some (tplN SsmF.s30 (SsmF.s30.stack.length - 3) r, SsmF.S30)
stage_rfl SsmF.firstB26 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s30 (SsmF.s30.stack.length - 3) r) SsmF.S30 = some (tplN SsmF.s31 (SsmF.s31.stack.length - 3) r, SsmF.S31)
stage_rfl SsmF.firstB27 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s31 (SsmF.s31.stack.length - 3) r) SsmF.S31 = some (tplN SsmF.s32 (SsmF.s32.stack.length - 3) r, SsmF.S32)
stage_rfl SsmF.firstB28 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s32 (SsmF.s32.stack.length - 3) r) SsmF.S32 = some (tplN SsmF.s33 (SsmF.s33.stack.length - 3) r, SsmF.S33)
stage_rfl SsmF.firstB29 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s33 (SsmF.s33.stack.length - 3) r) SsmF.S33 = some (tplN SsmF.s34 (SsmF.s34.stack.length - 3) r, SsmF.S34)
stage_rfl SsmF.firstB30 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s34 (SsmF.s34.stack.length - 3) r) SsmF.S34 = some (tplN SsmF.s35 (SsmF.s35.stack.length - 3) r, SsmF.S35)
stage_rfl SsmF.firstB31 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s35 (SsmF.s35.stack.length - 3) r) SsmF.S35 = some (tplN SsmF.s36 (SsmF.s36.stack.length - 3) r, SsmF.S36)
stage_rfl SsmF.firstB32 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s36 (SsmF.s36.stack.length - 3) r) SsmF.S36 = some (tplN SsmF.s37 (SsmF.s37.stack.length - 3) r, SsmF.S37)
stage_rfl SsmF.firstB33 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s37 (SsmF.s37.stack.length - 3) r) SsmF.S37 = some (tplN SsmF.s38 (SsmF.s38.stack.length - 3) r, SsmF.S38)
stage_rfl SsmF.firstB34 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s38 (SsmF.s38.stack.length - 3) r) SsmF.S38 = some (tplN SsmF.s39 (SsmF.s39.stack.length - 3) r, SsmF.S39)
stage_rfl SsmF.firstB35 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s39 (SsmF.s39.stack.length - 3) r) SsmF.S39 = some (tplN SsmF.s40 (SsmF.s40.stack.length - 3) r, SsmF.S40)
stage_rfl SsmF.firstB36 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s40 (SsmF.s40.stack.length - 3) r) SsmF.S40 = some (tplN SsmF.s41 (SsmF.s41.stack.length - 3) r, SsmF.S41)
stage_rfl SsmF.firstB37 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s41 (SsmF.s41.stack.length - 3) r) SsmF.S41 = some (tplN SsmF.s42 (SsmF.s42.stack.length - 3) r, SsmF.S42)
stage_rfl SsmF.firstB38 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s42 (SsmF.s42.stack.length - 3) r) SsmF.S42 = some (tplN SsmF.s43 (SsmF.s43.stack.length - 3) r, SsmF.S43)
stage_rfl SsmF.firstB39 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s43 (SsmF.s43.stack.length - 3) r) SsmF.S43 = some (tplN SsmF.s44 (SsmF.s44.stack.length - 3) r, SsmF.S44)
stage_rfl SsmF.firstB40 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s44 (SsmF.s44.stack.length - 3) r) SsmF.S44 = some (tplN SsmF.s45 (SsmF.s45.stack.length - 3) r, SsmF.S45)
stage_rfl SsmF.firstB41 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s45 (SsmF.s45.stack.length - 3) r) SsmF.S45 = some (tplN SsmF.s46 (SsmF.s46.stack.length - 3) r, SsmF.S46)
stage_rfl SsmF.firstB42 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s46 (SsmF.s46.stack.length - 3) r) SsmF.S46 = some (tplN SsmF.s47 (SsmF.s47.stack.length - 3) r, SsmF.S47)
stage_rfl SsmF.firstB43 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s47 (SsmF.s47.stack.length - 3) r) SsmF.S47 = some (tplN SsmF.s48 (SsmF.s48.stack.length - 3) r, SsmF.S48)
stage_rfl SsmF.firstB44 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s48 (SsmF.s48.stack.length - 3) r) SsmF.S48 = some (tplN SsmF.s49 (SsmF.s49.stack.length - 3) r, SsmF.S49)
stage_rfl SsmF.firstB45 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s49 (SsmF.s49.stack.length - 3) r) SsmF.S49 = some (tplN SsmF.s50 (SsmF.s50.stack.length - 3) r, SsmF.S50)
stage_rfl SsmF.firstB46 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s50 (SsmF.s50.stack.length - 3) r) SsmF.S50 = some (tplN SsmF.s51 (SsmF.s51.stack.length - 3) r, SsmF.S51)
stage_rfl SsmF.firstB47 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s51 (SsmF.s51.stack.length - 3) r) SsmF.S51 = some (tplN SsmF.s52 (SsmF.s52.stack.length - 3) r, SsmF.S52)
stage_rfl SsmF.firstB48 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s52 (SsmF.s52.stack.length - 3) r) SsmF.S52 = some (tplN SsmF.s53 (SsmF.s53.stack.length - 3) r, SsmF.S53)
stage_rfl SsmF.firstB49 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s53 (SsmF.s53.stack.length - 3) r) SsmF.S53 = some (tplN SsmF.s54 (SsmF.s54.stack.length - 3) r, SsmF.S54)
stage_rfl SsmF.firstB50 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s54 (SsmF.s54.stack.length - 3) r) SsmF.S54 = some (tplN SsmF.s55 (SsmF.s55.stack.length - 3) r, SsmF.S55)
stage_rfl SsmF.firstB51 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s55 (SsmF.s55.stack.length - 3) r) SsmF.S55 = some (tplN SsmF.s56 (SsmF.s56.stack.length - 3) r, SsmF.S56)
stage_rfl SsmF.firstB52 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s56 (SsmF.s56.stack.length - 3) r) SsmF.S56 = some (tplN SsmF.s57 (SsmF.s57.stack.length - 3) r, SsmF.S57)
stage_rfl SsmF.firstB53 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s57 (SsmF.s57.stack.length - 3) r) SsmF.S57 = some (tplN SsmF.s58 (SsmF.s58.stack.length - 3) r, SsmF.S58)
stage_rfl SsmF.firstB54 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s58 (SsmF.s58.stack.length - 3) r) SsmF.S58 = some (tplN SsmF.s59 (SsmF.s59.stack.length - 3) r, SsmF.S59)
stage_rfl SsmF.firstB55 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s59 (SsmF.s59.stack.length - 3) r) SsmF.S59 = some (tplN SsmF.s60 (SsmF.s60.stack.length - 3) r, SsmF.S60)
stage_rfl SsmF.firstB56 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s60 (SsmF.s60.stack.length - 3) r) SsmF.S60 = some (tplN SsmF.s61 (SsmF.s61.stack.length - 3) r, SsmF.S61)
stage_rfl SsmF.firstB57 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s61 (SsmF.s61.stack.length - 3) r) SsmF.S61 = some (tplN SsmF.s62 (SsmF.s62.stack.length - 3) r, SsmF.S62)
stage_rfl SsmF.firstB58 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s62 (SsmF.s62.stack.length - 3) r) SsmF.S62 = some (tplN SsmF.s63 (SsmF.s63.stack.length - 3) r, SsmF.S63)
stage_rfl SsmF.firstB59 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s63 (SsmF.s63.stack.length - 3) r) SsmF.S63 = some (tplN SsmF.s64 (SsmF.s64.stack.length - 3) r, SsmF.S64)
stage_rfl SsmF.firstB60 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s64 (SsmF.s64.stack.length - 3) r) SsmF.S64 = some (tplN SsmF.s65 (SsmF.s65.stack.length - 3) r, SsmF.S65)
stage_rfl SsmF.firstB61 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s65 (SsmF.s65.stack.length - 3) r) SsmF.S65 = some (tplN SsmF.s66 (SsmF.s66.stack.length - 3) r, SsmF.S66)
stage_rfl SsmF.firstB62 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s66 (SsmF.s66.stack.length - 3) r) SsmF.S66 = some (tplN SsmF.s67 (SsmF.s67.stack.length - 3) r, SsmF.S67)
stage_rfl SsmF.firstB63 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s67 (SsmF.s67.stack.length - 3) r) SsmF.S67 = some (tplN SsmF.s68 (SsmF.s68.stack.length - 3) r, SsmF.S68)
stage_rfl SsmF.firstB64 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s68 (SsmF.s68.stack.length - 3) r) SsmF.S68 = some (tplN SsmF.s69 (SsmF.s69.stack.length - 3) r, SsmF.S69)
stage_rfl SsmF.firstB65 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s69 (SsmF.s69.stack.length - 3) r) SsmF.S69 = some (tplN SsmF.s70 (SsmF.s70.stack.length - 3) r, SsmF.S70)
stage_rfl SsmF.firstB66 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s70 (SsmF.s70.stack.length - 3) r) SsmF.S70 = some (tplN SsmF.s71 (SsmF.s71.stack.length - 3) r, SsmF.S71)
stage_rfl SsmF.firstB67 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s71 (SsmF.s71.stack.length - 3) r) SsmF.S71 = some (tplN SsmF.s72 (SsmF.s72.stack.length - 3) r, SsmF.S72)
stage_rfl SsmF.firstB68 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s72 (SsmF.s72.stack.length - 3) r) SsmF.S72 = some (tplN SsmF.s73 (SsmF.s73.stack.length - 3) r, SsmF.S73)
stage_rfl SsmF.firstB69 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s73 (SsmF.s73.stack.length - 3) r) SsmF.S73 = some (tplN SsmF.s74 (SsmF.s74.stack.length - 3) r, SsmF.S74)
stage_rfl SsmF.firstB70 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s74 (SsmF.s74.stack.length - 3) r) SsmF.S74 = some (tplN SsmF.s75 (SsmF.s75.stack.length - 3) r, SsmF.S75)
stage_rfl SsmF.firstB71 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s75 (SsmF.s75.stack.length - 3) r) SsmF.S75 = some (tplN SsmF.s76 (SsmF.s76.stack.length - 3) r, SsmF.S76)
stage_rfl SsmF.firstB72 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s76 (SsmF.s76.stack.length - 3) r) SsmF.S76 = some (tplN SsmF.s77 (SsmF.s77.stack.length - 3) r, SsmF.S77)
stage_rfl SsmF.firstB73 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s77 (SsmF.s77.stack.length - 3) r) SsmF.S77 = some (tplN SsmF.s78 (SsmF.s78.stack.length - 3) r, SsmF.S78)
stage_rfl SsmF.firstB74 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s78 (SsmF.s78.stack.length - 3) r) SsmF.S78 = some (tplN SsmF.s79 (SsmF.s79.stack.length - 3) r, SsmF.S79)
stage_rfl SsmF.firstB75 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s79 (SsmF.s79.stack.length - 3) r) SsmF.S79 = some (tplN SsmF.s80 (SsmF.s80.stack.length - 3) r, SsmF.S80)
stage_rfl SsmF.firstB76 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s80 (SsmF.s80.stack.length - 3) r) SsmF.S80 = some (tplN SsmF.s81 (SsmF.s81.stack.length - 3) r, SsmF.S81)
stage_rfl SsmF.firstB77 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s81 (SsmF.s81.stack.length - 3) r) SsmF.S81 = some (tplN SsmF.s82 (SsmF.s82.stack.length - 3) r, SsmF.S82)
stage_rfl SsmF.firstB78 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s82 (SsmF.s82.stack.length - 3) r) SsmF.S82 = some (tplN SsmF.s83 (SsmF.s83.stack.length - 3) r, SsmF.S83)
stage_rfl SsmF.firstB79 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s83 (SsmF.s83.stack.length - 3) r) SsmF.S83 = some (tplN SsmF.s84 (SsmF.s84.stack.length - 3) r, SsmF.S84)
stage_rfl SsmF.firstB80 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s84 (SsmF.s84.stack.length - 3) r) SsmF.S84 = some (tplN SsmF.s85 (SsmF.s85.stack.length - 3) r, SsmF.S85)
stage_rfl SsmF.firstB81 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s85 (SsmF.s85.stack.length - 3) r) SsmF.S85 = some (tplN SsmF.s86 (SsmF.s86.stack.length - 3) r, SsmF.S86)
stage_rfl SsmF.firstB82 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s86 (SsmF.s86.stack.length - 3) r) SsmF.S86 = some (tplN SsmF.s87 (SsmF.s87.stack.length - 3) r, SsmF.S87)
stage_rfl SsmF.firstB83 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s87 (SsmF.s87.stack.length - 3) r) SsmF.S87 = some (tplN SsmF.s88 (SsmF.s88.stack.length - 3) r, SsmF.S88)
stage_rfl SsmF.firstB84 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s88 (SsmF.s88.stack.length - 3) r) SsmF.S88 = some (tplN SsmF.s89 (SsmF.s89.stack.length - 3) r, SsmF.S89)
stage_rfl SsmF.firstB85 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s89 (SsmF.s89.stack.length - 3) r) SsmF.S89 = some (tplN SsmF.s90 (SsmF.s90.stack.length - 3) r, SsmF.S90)
stage_rfl SsmF.firstB86 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s90 (SsmF.s90.stack.length - 3) r) SsmF.S90 = some (tplN SsmF.s91 (SsmF.s91.stack.length - 3) r, SsmF.S91)
stage_rfl SsmF.firstB87 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s91 (SsmF.s91.stack.length - 3) r) SsmF.S91 = some (tplN SsmF.s92 (SsmF.s92.stack.length - 3) r, SsmF.S92)
stage_rfl SsmF.firstB88 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s92 (SsmF.s92.stack.length - 3) r) SsmF.S92 = some (tplN SsmF.s93 (SsmF.s93.stack.length - 3) r, SsmF.S93)
stage_rfl SsmF.firstB89 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s93 (SsmF.s93.stack.length - 3) r) SsmF.S93 = some (tplN SsmF.s94 (SsmF.s94.stack.length - 3) r, SsmF.S94)
stage_rfl SsmF.firstB90 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s94 (SsmF.s94.stack.length - 3) r) SsmF.S94 = some (tplN SsmF.s95 (SsmF.s95.stack.length - 3) r, SsmF.S95)
stage_rfl SsmF.firstB91 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s95 (SsmF.s95.stack.length - 3) r) SsmF.S95 = some (tplN SsmF.s96 (SsmF.s96.stack.length - 3) r, SsmF.S96)
stage_rfl SsmF.firstB92 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s96 (SsmF.s96.stack.length - 3) r) SsmF.S96 = some (tplN SsmF.s97 (SsmF.s97.stack.length - 3) r, SsmF.S97)
stage_rfl SsmF.firstB93 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s97 (SsmF.s97.stack.length - 3) r) SsmF.S97 = some (tplN SsmF.s98 (SsmF.s98.stack.length - 3) r, SsmF.S98)
stage_rfl SsmF.firstB94 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s98 (SsmF.s98.stack.length - 3) r) SsmF.S98 = some (tplN SsmF.s99 (SsmF.s99.stack.length - 3) r, SsmF.S99)
stage_rfl SsmF.firstB95 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s99 (SsmF.s99.stack.length - 3) r) SsmF.S99 = some (tplN SsmF.s100 (SsmF.s100.stack.length - 3) r, SsmF.S100)
stage_rfl SsmF.firstB96 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s100 (SsmF.s100.stack.length - 3) r) SsmF.S100 = some (tplN SsmF.s101 (SsmF.s101.stack.length - 3) r, SsmF.S101)
stage_rfl SsmF.firstB97 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s101 (SsmF.s101.stack.length - 3) r) SsmF.S101 = some (tplN SsmF.s102 (SsmF.s102.stack.length - 3) r, SsmF.S102)
stage_rfl SsmF.firstB98 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s102 (SsmF.s102.stack.length - 3) r) SsmF.S102 = some (tplN SsmF.s103 (SsmF.s103.stack.length - 3) r, SsmF.S103)
stage_rfl SsmF.firstB99 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s103 (SsmF.s103.stack.length - 3) r) SsmF.S103 = some (tplN SsmF.s104 (SsmF.s104.stack.length - 3) r, SsmF.S104)
stage_rfl SsmF.firstB100 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s104 (SsmF.s104.stack.length - 3) r) SsmF.S104 = some (tplN SsmF.s105 (SsmF.s105.stack.length - 3) r, SsmF.S105)
stage_rfl SsmF.firstB101 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s105 (SsmF.s105.stack.length - 3) r) SsmF.S105 = some (tplN SsmF.s106 (SsmF.s106.stack.length - 3) r, SsmF.S106)
stage_rfl SsmF.firstB102 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s106 (SsmF.s106.stack.length - 3) r) SsmF.S106 = some (tplN SsmF.s107 (SsmF.s107.stack.length - 3) r, SsmF.S107)
stage_rfl SsmF.firstB103 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s107 (SsmF.s107.stack.length - 3) r) SsmF.S107 = some (tplN SsmF.s108 (SsmF.s108.stack.length - 3) r, SsmF.S108)
stage_rfl SsmF.firstB104 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s108 (SsmF.s108.stack.length - 3) r) SsmF.S108 = some (tplN SsmF.s109 (SsmF.s109.stack.length - 3) r, SsmF.S109)
stage_rfl SsmF.firstB105 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s109 (SsmF.s109.stack.length - 3) r) SsmF.S109 = some (tplN SsmF.s110 (SsmF.s110.stack.length - 3) r, SsmF.S110)
stage_rfl SsmF.firstB106 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s110 (SsmF.s110.stack.length - 3) r) SsmF.S110 = some (tplN SsmF.s111 (SsmF.s111.stack.length - 3) r, SsmF.S111)
stage_rfl SsmF.firstB107 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s111 (SsmF.s111.stack.length - 3) r) SsmF.S111 = some (tplN SsmF.s112 (SsmF.s112.stack.length - 3) r, SsmF.S112)
stage_rfl SsmF.firstB108 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s112 (SsmF.s112.stack.length - 3) r) SsmF.S112 = some (tplN SsmF.s113 (SsmF.s113.stack.length - 3) r, SsmF.S113)
stage_rfl SsmF.firstB109 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s113 (SsmF.s113.stack.length - 3) r) SsmF.S113 = some (tplN SsmF.s114 (SsmF.s114.stack.length - 3) r, SsmF.S114)
stage_rfl SsmF.firstB110 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s114 (SsmF.s114.stack.length - 3) r) SsmF.S114 = some (tplN SsmF.s115 (SsmF.s115.stack.length - 3) r, SsmF.S115)
stage_rfl SsmF.firstB111 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s115 (SsmF.s115.stack.length - 3) r) SsmF.S115 = some (tplN SsmF.s116 (SsmF.s116.stack.length - 3) r, SsmF.S116)
stage_rfl SsmF.firstB112 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s116 (SsmF.s116.stack.length - 3) r) SsmF.S116 = some (tplN SsmF.s117 (SsmF.s117.stack.length - 3) r, SsmF.S117)
stage_rfl SsmF.firstB113 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s117 (SsmF.s117.stack.length - 3) r) SsmF.S117 = some (tplN SsmF.s118 (SsmF.s118.stack.length - 3) r, SsmF.S118)
stage_rfl SsmF.firstB114 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s118 (SsmF.s118.stack.length - 3) r) SsmF.S118 = some (tplN SsmF.s119 (SsmF.s119.stack.length - 3) r, SsmF.S119)
stage_rfl SsmF.firstB115 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s119 (SsmF.s119.stack.length - 3) r) SsmF.S119 = some (tplN SsmF.s120 (SsmF.s120.stack.length - 3) r, SsmF.S120)
stage_rfl SsmF.firstB116 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s120 (SsmF.s120.stack.length - 3) r) SsmF.S120 = some (tplN SsmF.s121 (SsmF.s121.stack.length - 3) r, SsmF.S121)
stage_rfl SsmF.firstB117 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s121 (SsmF.s121.stack.length - 3) r) SsmF.S121 = some (tplN SsmF.s122 (SsmF.s122.stack.length - 3) r, SsmF.S122)
stage_rfl SsmF.firstB118 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s122 (SsmF.s122.stack.length - 3) r) SsmF.S122 = some (tplN SsmF.s123 (SsmF.s123.stack.length - 3) r, SsmF.S123)
stage_rfl SsmF.firstB119 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s123 (SsmF.s123.stack.length - 3) r) SsmF.S123 = some (tplN SsmF.s124 (SsmF.s124.stack.length - 3) r, SsmF.S124)
stage_rfl SsmF.firstB120 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s124 (SsmF.s124.stack.length - 3) r) SsmF.S124 = some (tplN SsmF.s125 (SsmF.s125.stack.length - 3) r, SsmF.S125)
stage_rfl SsmF.firstB121 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s125 (SsmF.s125.stack.length - 3) r) SsmF.S125 = some (tplN SsmF.s126 (SsmF.s126.stack.length - 3) r, SsmF.S126)
stage_rfl SsmF.firstB122 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s126 (SsmF.s126.stack.length - 3) r) SsmF.S126 = some (tplN SsmF.s127 (SsmF.s127.stack.length - 3) r, SsmF.S127)
stage_rfl SsmF.firstB123 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s127 (SsmF.s127.stack.length - 3) r) SsmF.S127 = some (tplN SsmF.s128 (SsmF.s128.stack.length - 3) r, SsmF.S128)
stage_rfl SsmF.firstB124 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s128 (SsmF.s128.stack.length - 3) r) SsmF.S128 = some (tplN SsmF.s129 (SsmF.s129.stack.length - 3) r, SsmF.S129)
stage_rfl SsmF.firstB125 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s129 (SsmF.s129.stack.length - 3) r) SsmF.S129 = some (tplN SsmF.s130 (SsmF.s130.stack.length - 3) r, SsmF.S130)
stage_rfl SsmF.firstB126 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s130 (SsmF.s130.stack.length - 3) r) SsmF.S130 = some (tplN SsmF.s131 (SsmF.s131.stack.length - 3) r, SsmF.S131)
stage_rfl SsmF.firstB127 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s131 (SsmF.s131.stack.length - 3) r) SsmF.S131 = some (tplN SsmF.s132 (SsmF.s132.stack.length - 3) r, SsmF.S132)
stage_rfl SsmF.firstB128 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s132 (SsmF.s132.stack.length - 3) r) SsmF.S132 = some (tplN SsmF.s133 (SsmF.s133.stack.length - 3) r, SsmF.S133)
stage_rfl SsmF.firstB129 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s133 (SsmF.s133.stack.length - 3) r) SsmF.S133 = some (tplN SsmF.s134 (SsmF.s134.stack.length - 3) r, SsmF.S134)
stage_rfl SsmF.firstB130 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s134 (SsmF.s134.stack.length - 3) r) SsmF.S134 = some (tplN SsmF.s135 (SsmF.s135.stack.length - 3) r, SsmF.S135)
stage_rfl SsmF.firstB131 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s135 (SsmF.s135.stack.length - 3) r) SsmF.S135 = some (tplN SsmF.s136 (SsmF.s136.stack.length - 3) r, SsmF.S136)
stage_rfl SsmF.firstB132 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s136 (SsmF.s136.stack.length - 3) r) SsmF.S136 = some (tplN SsmF.s137 (SsmF.s137.stack.length - 3) r, SsmF.S137)
stage_rfl SsmF.firstB133 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s137 (SsmF.s137.stack.length - 3) r) SsmF.S137 = some (tplN SsmF.s138 (SsmF.s138.stack.length - 3) r, SsmF.S138)
stage_rfl SsmF.firstB134 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s138 (SsmF.s138.stack.length - 3) r) SsmF.S138 = some (tplN SsmF.s139 (SsmF.s139.stack.length - 3) r, SsmF.S139)
stage_rfl SsmF.firstB135 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s139 (SsmF.s139.stack.length - 3) r) SsmF.S139 = some (tplN SsmF.s140 (SsmF.s140.stack.length - 3) r, SsmF.S140)
stage_rfl SsmF.firstB136 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s140 (SsmF.s140.stack.length - 3) r) SsmF.S140 = some (tplN SsmF.s141 (SsmF.s141.stack.length - 3) r, SsmF.S141)
stage_rfl SsmF.firstB137 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s141 (SsmF.s141.stack.length - 3) r) SsmF.S141 = some (tplN SsmF.s142 (SsmF.s142.stack.length - 3) r, SsmF.S142)
stage_rfl SsmF.firstB138 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s142 (SsmF.s142.stack.length - 3) r) SsmF.S142 = some (tplN SsmF.s143 (SsmF.s143.stack.length - 3) r, SsmF.S143)
stage_rfl SsmF.firstB139 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s143 (SsmF.s143.stack.length - 3) r) SsmF.S143 = some (tplN SsmF.s144 (SsmF.s144.stack.length - 3) r, SsmF.S144)
stage_rfl SsmF.firstB140 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s144 (SsmF.s144.stack.length - 3) r) SsmF.S144 = some (tplN SsmF.s145 (SsmF.s145.stack.length - 3) r, SsmF.S145)
stage_rfl SsmF.firstB141 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s145 (SsmF.s145.stack.length - 3) r) SsmF.S145 = some (tplN SsmF.s146 (SsmF.s146.stack.length - 3) r, SsmF.S146)
stage_rfl SsmF.firstB142 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s146 (SsmF.s146.stack.length - 3) r) SsmF.S146 = some (tplN SsmF.s147 (SsmF.s147.stack.length - 3) r, SsmF.S147)
stage_rfl SsmF.firstB143 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s147 (SsmF.s147.stack.length - 3) r) SsmF.S147 = some (tplN SsmF.s148 (SsmF.s148.stack.length - 3) r, SsmF.S148)
stage_rfl SsmF.firstB144 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s148 (SsmF.s148.stack.length - 3) r) SsmF.S148 = some (tplN SsmF.s149 (SsmF.s149.stack.length - 3) r, SsmF.S149)
stage_rfl SsmF.firstB145 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s149 (SsmF.s149.stack.length - 3) r) SsmF.S149 = some (tplN SsmF.s150 (SsmF.s150.stack.length - 3) r, SsmF.S150)
stage_rfl SsmF.firstB146 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s150 (SsmF.s150.stack.length - 3) r) SsmF.S150 = some (tplN SsmF.s151 (SsmF.s151.stack.length - 3) r, SsmF.S151)
stage_rfl SsmF.firstB147 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s151 (SsmF.s151.stack.length - 3) r) SsmF.S151 = some (tplN SsmF.s152 (SsmF.s152.stack.length - 3) r, SsmF.S152)
stage_rfl SsmF.firstB148 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s152 (SsmF.s152.stack.length - 3) r) SsmF.S152 = some (tplN SsmF.s153 (SsmF.s153.stack.length - 3) r, SsmF.S153)
stage_rfl SsmF.firstB149 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s153 (SsmF.s153.stack.length - 3) r) SsmF.S153 = some (tplN SsmF.s154 (SsmF.s154.stack.length - 3) r, SsmF.S154)
stage_rfl SsmF.firstB150 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s154 (SsmF.s154.stack.length - 3) r) SsmF.S154 = some (tplN SsmF.s155 (SsmF.s155.stack.length - 3) r, SsmF.S155)
stage_rfl SsmF.firstB151 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s155 (SsmF.s155.stack.length - 3) r) SsmF.S155 = some (tplN SsmF.s156 (SsmF.s156.stack.length - 3) r, SsmF.S156)
stage_rfl SsmF.firstB152 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s156 (SsmF.s156.stack.length - 3) r) SsmF.S156 = some (tplN SsmF.s157 (SsmF.s157.stack.length - 3) r, SsmF.S157)
stage_rfl SsmF.firstB153 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s157 (SsmF.s157.stack.length - 3) r) SsmF.S157 = some (tplN SsmF.s158 (SsmF.s158.stack.length - 3) r, SsmF.S158)
stage_rfl SsmF.firstB154 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s158 (SsmF.s158.stack.length - 3) r) SsmF.S158 = some (tplN SsmF.s159 (SsmF.s159.stack.length - 3) r, SsmF.S159)
stage_rfl SsmF.firstB155 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s159 (SsmF.s159.stack.length - 3) r) SsmF.S159 = some (tplN SsmF.s160 (SsmF.s160.stack.length - 3) r, SsmF.S160)
stage_rfl SsmF.firstB156 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s160 (SsmF.s160.stack.length - 3) r) SsmF.S160 = some (tplN SsmF.s161 (SsmF.s161.stack.length - 3) r, SsmF.S161)
stage_rfl SsmF.firstB157 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s161 (SsmF.s161.stack.length - 3) r) SsmF.S161 = some (tplN SsmF.s162 (SsmF.s162.stack.length - 3) r, SsmF.S162)
stage_rfl SsmF.firstB158 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s162 (SsmF.s162.stack.length - 3) r) SsmF.S162 = some (tplN SsmF.s163 (SsmF.s163.stack.length - 3) r, SsmF.S163)
stage_rfl SsmF.firstB159 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s163 (SsmF.s163.stack.length - 3) r) SsmF.S163 = some (tplN SsmF.s164 (SsmF.s164.stack.length - 3) r, SsmF.S164)
stage_rfl SsmF.firstB160 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s164 (SsmF.s164.stack.length - 3) r) SsmF.S164 = some (tplN SsmF.s165 (SsmF.s165.stack.length - 3) r, SsmF.S165)
stage_rfl SsmF.firstB161 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s165 (SsmF.s165.stack.length - 3) r) SsmF.S165 = some (tplN SsmF.s166 (SsmF.s166.stack.length - 3) r, SsmF.S166)
stage_rfl SsmF.firstB162 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s166 (SsmF.s166.stack.length - 3) r) SsmF.S166 = some (tplN SsmF.s167 (SsmF.s167.stack.length - 3) r, SsmF.S167)
stage_rfl SsmF.firstB163 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s167 (SsmF.s167.stack.length - 3) r) SsmF.S167 = some (tplN SsmF.s168 (SsmF.s168.stack.length - 3) r, SsmF.S168)
stage_rfl SsmF.firstB164 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s168 (SsmF.s168.stack.length - 3) r) SsmF.S168 = some (tplN SsmF.s169 (SsmF.s169.stack.length - 3) r, SsmF.S169)
stage_rfl SsmF.firstB165 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s169 (SsmF.s169.stack.length - 3) r) SsmF.S169 = some (tplN SsmF.s170 (SsmF.s170.stack.length - 3) r, SsmF.S170)
stage_rfl SsmF.firstB166 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN SsmF.s170 (SsmF.s170.stack.length - 3) r) SsmF.S170 = some (tplN SsmF.s171 (SsmF.s171.stack.length - 3) r, SsmF.S171)
stage_rfl SsmF.firstB167 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 37 (tplN SsmF.s171 (SsmF.s171.stack.length - 3) r) SsmF.S171 = some (tplN SsmF.s172 1 r, SsmF.S172)
stage_rfl SsmF.firstLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN SsmF.s172 1 r)).run SsmF.S172 = some (tplN SsmF.s173 0 r, SsmF.S173)
kernel_rfl SsmF.firstLive : isHalt SsmF.s172.ctl = false
kernel_rfl SsmF.firstFrames : SsmF.s173.stack = SsmF.s4.stack

/-- Stage `SsmF.first` under every caller stack. -/
theorem SsmF.first (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 16738 (tplN SsmF.s4 0 r) SsmF.S4 = some (tplN SsmF.s173 0 r, SsmF.S173) :=
  runS_snoc _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (SsmF.firstB0 r) (SsmF.firstB1 r)) (SsmF.firstB2 r)) (SsmF.firstB3 r)) (SsmF.firstB4 r)) (SsmF.firstB5 r)) (SsmF.firstB6 r)) (SsmF.firstB7 r)) (SsmF.firstB8 r)) (SsmF.firstB9 r)) (SsmF.firstB10 r)) (SsmF.firstB11 r)) (SsmF.firstB12 r)) (SsmF.firstB13 r)) (SsmF.firstB14 r)) (SsmF.firstB15 r)) (SsmF.firstB16 r)) (SsmF.firstB17 r)) (SsmF.firstB18 r)) (SsmF.firstB19 r)) (SsmF.firstB20 r)) (SsmF.firstB21 r)) (SsmF.firstB22 r)) (SsmF.firstB23 r)) (SsmF.firstB24 r)) (SsmF.firstB25 r)) (SsmF.firstB26 r)) (SsmF.firstB27 r)) (SsmF.firstB28 r)) (SsmF.firstB29 r)) (SsmF.firstB30 r)) (SsmF.firstB31 r)) (SsmF.firstB32 r)) (SsmF.firstB33 r)) (SsmF.firstB34 r)) (SsmF.firstB35 r)) (SsmF.firstB36 r)) (SsmF.firstB37 r)) (SsmF.firstB38 r)) (SsmF.firstB39 r)) (SsmF.firstB40 r)) (SsmF.firstB41 r)) (SsmF.firstB42 r)) (SsmF.firstB43 r)) (SsmF.firstB44 r)) (SsmF.firstB45 r)) (SsmF.firstB46 r)) (SsmF.firstB47 r)) (SsmF.firstB48 r)) (SsmF.firstB49 r)) (SsmF.firstB50 r)) (SsmF.firstB51 r)) (SsmF.firstB52 r)) (SsmF.firstB53 r)) (SsmF.firstB54 r)) (SsmF.firstB55 r)) (SsmF.firstB56 r)) (SsmF.firstB57 r)) (SsmF.firstB58 r)) (SsmF.firstB59 r)) (SsmF.firstB60 r)) (SsmF.firstB61 r)) (SsmF.firstB62 r)) (SsmF.firstB63 r)) (SsmF.firstB64 r)) (SsmF.firstB65 r)) (SsmF.firstB66 r)) (SsmF.firstB67 r)) (SsmF.firstB68 r)) (SsmF.firstB69 r)) (SsmF.firstB70 r)) (SsmF.firstB71 r)) (SsmF.firstB72 r)) (SsmF.firstB73 r)) (SsmF.firstB74 r)) (SsmF.firstB75 r)) (SsmF.firstB76 r)) (SsmF.firstB77 r)) (SsmF.firstB78 r)) (SsmF.firstB79 r)) (SsmF.firstB80 r)) (SsmF.firstB81 r)) (SsmF.firstB82 r)) (SsmF.firstB83 r)) (SsmF.firstB84 r)) (SsmF.firstB85 r)) (SsmF.firstB86 r)) (SsmF.firstB87 r)) (SsmF.firstB88 r)) (SsmF.firstB89 r)) (SsmF.firstB90 r)) (SsmF.firstB91 r)) (SsmF.firstB92 r)) (SsmF.firstB93 r)) (SsmF.firstB94 r)) (SsmF.firstB95 r)) (SsmF.firstB96 r)) (SsmF.firstB97 r)) (SsmF.firstB98 r)) (SsmF.firstB99 r)) (SsmF.firstB100 r)) (SsmF.firstB101 r)) (SsmF.firstB102 r)) (SsmF.firstB103 r)) (SsmF.firstB104 r)) (SsmF.firstB105 r)) (SsmF.firstB106 r)) (SsmF.firstB107 r)) (SsmF.firstB108 r)) (SsmF.firstB109 r)) (SsmF.firstB110 r)) (SsmF.firstB111 r)) (SsmF.firstB112 r)) (SsmF.firstB113 r)) (SsmF.firstB114 r)) (SsmF.firstB115 r)) (SsmF.firstB116 r)) (SsmF.firstB117 r)) (SsmF.firstB118 r)) (SsmF.firstB119 r)) (SsmF.firstB120 r)) (SsmF.firstB121 r)) (SsmF.firstB122 r)) (SsmF.firstB123 r)) (SsmF.firstB124 r)) (SsmF.firstB125 r)) (SsmF.firstB126 r)) (SsmF.firstB127 r)) (SsmF.firstB128 r)) (SsmF.firstB129 r)) (SsmF.firstB130 r)) (SsmF.firstB131 r)) (SsmF.firstB132 r)) (SsmF.firstB133 r)) (SsmF.firstB134 r)) (SsmF.firstB135 r)) (SsmF.firstB136 r)) (SsmF.firstB137 r)) (SsmF.firstB138 r)) (SsmF.firstB139 r)) (SsmF.firstB140 r)) (SsmF.firstB141 r)) (SsmF.firstB142 r)) (SsmF.firstB143 r)) (SsmF.firstB144 r)) (SsmF.firstB145 r)) (SsmF.firstB146 r)) (SsmF.firstB147 r)) (SsmF.firstB148 r)) (SsmF.firstB149 r)) (SsmF.firstB150 r)) (SsmF.firstB151 r)) (SsmF.firstB152 r)) (SsmF.firstB153 r)) (SsmF.firstB154 r)) (SsmF.firstB155 r)) (SsmF.firstB156 r)) (SsmF.firstB157 r)) (SsmF.firstB158 r)) (SsmF.firstB159 r)) (SsmF.firstB160 r)) (SsmF.firstB161 r)) (SsmF.firstB162 r)) (SsmF.firstB163 r)) (SsmF.firstB164 r)) (SsmF.firstB165 r)) (SsmF.firstB166 r)) (SsmF.firstB167 r)) SsmF.firstLive (SsmF.firstLast r)

/-- Stage `SsmF.first` at the driver's own frames. -/
theorem SsmF.firstAt : runS Host.Mlx.Ffi.ffi 16738 SsmF.s4 SsmF.S4 = some (SsmF.s173, SsmF.S173) := by
  have h := SsmF.first SsmF.s4.stack
  rwa [show tplN SsmF.s4 0 SsmF.s4.stack = SsmF.s4 from tplN_self SsmF.s4 0,
    show tplN SsmF.s173 0 SsmF.s4.stack = SsmF.s173 by rw [← SsmF.firstFrames]; exact tplN_self SsmF.s173 0] at h

kernel_rfl SsmF.evalD : SsmF.s175.stack.length = 3
stage_rfl SsmF.evalB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 991 (tplN SsmF.s174 0 r) SsmF.S174 = some (tplN SsmF.s175 1 r, SsmF.S175)
stage_rfl SsmF.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN SsmF.s175 1 r)).run SsmF.S175 = some (tplN SsmF.s176 0 r, SsmF.S176)
kernel_rfl SsmF.evalLive : isHalt SsmF.s175.ctl = false
kernel_rfl SsmF.evalFrames : SsmF.s176.stack = SsmF.s174.stack

/-- Stage `SsmF.eval` under every caller stack. -/
theorem SsmF.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 992 (tplN SsmF.s174 0 r) SsmF.S174 = some (tplN SsmF.s176 0 r, SsmF.S176) :=
  runS_snoc _ (SsmF.evalB0 r) SsmF.evalLive (SsmF.evalLast r)

/-- Stage `SsmF.eval` at the driver's own frames. -/
theorem SsmF.evalAt : runS Host.Mlx.Ffi.ffi 992 SsmF.s174 SsmF.S174 = some (SsmF.s176, SsmF.S176) := by
  have h := SsmF.eval SsmF.s174.stack
  rwa [show tplN SsmF.s174 0 SsmF.s174.stack = SsmF.s174 from tplN_self SsmF.s174 0,
    show tplN SsmF.s176 0 SsmF.s174.stack = SsmF.s176 by rw [← SsmF.evalFrames]; exact tplN_self SsmF.s176 0] at h

host_chunk SsmF 0
host_chunk SsmF 1
host_chunk SsmF 2
host_chunk SsmF 3
host_chunk SsmF 173
host_chunk SsmF 176

/-- **The driver's run** from its stages and its own steps. -/
theorem SsmF.drive : runS Host.Mlx.Ffi.ffi 29985 SsmF.s0 SsmF.S0 = some (SsmF.s177, SsmF.S177) := by
  have h := (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ SsmF.c0 SsmF.c1) SsmF.c2) SsmF.c3) SsmF.firstAt) SsmF.c173) SsmF.evalAt) SsmF.c176)
  exact h

set_option maxHeartbeats 0 in
host_chain_sym Ssm : Host.Mlx.Ffi.ffi, bootOf DDec.ast, [.var 0], ρ1 1000, 60000, [4000, 4000, 4000, 701, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 63, 1, 681, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 80, 1, 12, 991, 1, 59]

kernel_rfl Ssm.coldD : Ssm.s167.stack.length = 4
stage_rfl Ssm.coldB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s4 0 r) Ssm.S4 = some (tplN Ssm.s5 (Ssm.s5.stack.length - 3) r, Ssm.S5)
stage_rfl Ssm.coldB1 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s5 (Ssm.s5.stack.length - 3) r) Ssm.S5 = some (tplN Ssm.s6 (Ssm.s6.stack.length - 3) r, Ssm.S6)
stage_rfl Ssm.coldB2 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s6 (Ssm.s6.stack.length - 3) r) Ssm.S6 = some (tplN Ssm.s7 (Ssm.s7.stack.length - 3) r, Ssm.S7)
stage_rfl Ssm.coldB3 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s7 (Ssm.s7.stack.length - 3) r) Ssm.S7 = some (tplN Ssm.s8 (Ssm.s8.stack.length - 3) r, Ssm.S8)
stage_rfl Ssm.coldB4 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s8 (Ssm.s8.stack.length - 3) r) Ssm.S8 = some (tplN Ssm.s9 (Ssm.s9.stack.length - 3) r, Ssm.S9)
stage_rfl Ssm.coldB5 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s9 (Ssm.s9.stack.length - 3) r) Ssm.S9 = some (tplN Ssm.s10 (Ssm.s10.stack.length - 3) r, Ssm.S10)
stage_rfl Ssm.coldB6 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s10 (Ssm.s10.stack.length - 3) r) Ssm.S10 = some (tplN Ssm.s11 (Ssm.s11.stack.length - 3) r, Ssm.S11)
stage_rfl Ssm.coldB7 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s11 (Ssm.s11.stack.length - 3) r) Ssm.S11 = some (tplN Ssm.s12 (Ssm.s12.stack.length - 3) r, Ssm.S12)
stage_rfl Ssm.coldB8 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s12 (Ssm.s12.stack.length - 3) r) Ssm.S12 = some (tplN Ssm.s13 (Ssm.s13.stack.length - 3) r, Ssm.S13)
stage_rfl Ssm.coldB9 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s13 (Ssm.s13.stack.length - 3) r) Ssm.S13 = some (tplN Ssm.s14 (Ssm.s14.stack.length - 3) r, Ssm.S14)
stage_rfl Ssm.coldB10 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s14 (Ssm.s14.stack.length - 3) r) Ssm.S14 = some (tplN Ssm.s15 (Ssm.s15.stack.length - 3) r, Ssm.S15)
stage_rfl Ssm.coldB11 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s15 (Ssm.s15.stack.length - 3) r) Ssm.S15 = some (tplN Ssm.s16 (Ssm.s16.stack.length - 3) r, Ssm.S16)
stage_rfl Ssm.coldB12 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s16 (Ssm.s16.stack.length - 3) r) Ssm.S16 = some (tplN Ssm.s17 (Ssm.s17.stack.length - 3) r, Ssm.S17)
stage_rfl Ssm.coldB13 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s17 (Ssm.s17.stack.length - 3) r) Ssm.S17 = some (tplN Ssm.s18 (Ssm.s18.stack.length - 3) r, Ssm.S18)
stage_rfl Ssm.coldB14 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s18 (Ssm.s18.stack.length - 3) r) Ssm.S18 = some (tplN Ssm.s19 (Ssm.s19.stack.length - 3) r, Ssm.S19)
stage_rfl Ssm.coldB15 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s19 (Ssm.s19.stack.length - 3) r) Ssm.S19 = some (tplN Ssm.s20 (Ssm.s20.stack.length - 3) r, Ssm.S20)
stage_rfl Ssm.coldB16 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s20 (Ssm.s20.stack.length - 3) r) Ssm.S20 = some (tplN Ssm.s21 (Ssm.s21.stack.length - 3) r, Ssm.S21)
stage_rfl Ssm.coldB17 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s21 (Ssm.s21.stack.length - 3) r) Ssm.S21 = some (tplN Ssm.s22 (Ssm.s22.stack.length - 3) r, Ssm.S22)
stage_rfl Ssm.coldB18 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s22 (Ssm.s22.stack.length - 3) r) Ssm.S22 = some (tplN Ssm.s23 (Ssm.s23.stack.length - 3) r, Ssm.S23)
stage_rfl Ssm.coldB19 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s23 (Ssm.s23.stack.length - 3) r) Ssm.S23 = some (tplN Ssm.s24 (Ssm.s24.stack.length - 3) r, Ssm.S24)
stage_rfl Ssm.coldB20 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s24 (Ssm.s24.stack.length - 3) r) Ssm.S24 = some (tplN Ssm.s25 (Ssm.s25.stack.length - 3) r, Ssm.S25)
stage_rfl Ssm.coldB21 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s25 (Ssm.s25.stack.length - 3) r) Ssm.S25 = some (tplN Ssm.s26 (Ssm.s26.stack.length - 3) r, Ssm.S26)
stage_rfl Ssm.coldB22 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s26 (Ssm.s26.stack.length - 3) r) Ssm.S26 = some (tplN Ssm.s27 (Ssm.s27.stack.length - 3) r, Ssm.S27)
stage_rfl Ssm.coldB23 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s27 (Ssm.s27.stack.length - 3) r) Ssm.S27 = some (tplN Ssm.s28 (Ssm.s28.stack.length - 3) r, Ssm.S28)
stage_rfl Ssm.coldB24 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s28 (Ssm.s28.stack.length - 3) r) Ssm.S28 = some (tplN Ssm.s29 (Ssm.s29.stack.length - 3) r, Ssm.S29)
stage_rfl Ssm.coldB25 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s29 (Ssm.s29.stack.length - 3) r) Ssm.S29 = some (tplN Ssm.s30 (Ssm.s30.stack.length - 3) r, Ssm.S30)
stage_rfl Ssm.coldB26 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s30 (Ssm.s30.stack.length - 3) r) Ssm.S30 = some (tplN Ssm.s31 (Ssm.s31.stack.length - 3) r, Ssm.S31)
stage_rfl Ssm.coldB27 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s31 (Ssm.s31.stack.length - 3) r) Ssm.S31 = some (tplN Ssm.s32 (Ssm.s32.stack.length - 3) r, Ssm.S32)
stage_rfl Ssm.coldB28 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s32 (Ssm.s32.stack.length - 3) r) Ssm.S32 = some (tplN Ssm.s33 (Ssm.s33.stack.length - 3) r, Ssm.S33)
stage_rfl Ssm.coldB29 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s33 (Ssm.s33.stack.length - 3) r) Ssm.S33 = some (tplN Ssm.s34 (Ssm.s34.stack.length - 3) r, Ssm.S34)
stage_rfl Ssm.coldB30 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s34 (Ssm.s34.stack.length - 3) r) Ssm.S34 = some (tplN Ssm.s35 (Ssm.s35.stack.length - 3) r, Ssm.S35)
stage_rfl Ssm.coldB31 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s35 (Ssm.s35.stack.length - 3) r) Ssm.S35 = some (tplN Ssm.s36 (Ssm.s36.stack.length - 3) r, Ssm.S36)
stage_rfl Ssm.coldB32 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s36 (Ssm.s36.stack.length - 3) r) Ssm.S36 = some (tplN Ssm.s37 (Ssm.s37.stack.length - 3) r, Ssm.S37)
stage_rfl Ssm.coldB33 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s37 (Ssm.s37.stack.length - 3) r) Ssm.S37 = some (tplN Ssm.s38 (Ssm.s38.stack.length - 3) r, Ssm.S38)
stage_rfl Ssm.coldB34 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s38 (Ssm.s38.stack.length - 3) r) Ssm.S38 = some (tplN Ssm.s39 (Ssm.s39.stack.length - 3) r, Ssm.S39)
stage_rfl Ssm.coldB35 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s39 (Ssm.s39.stack.length - 3) r) Ssm.S39 = some (tplN Ssm.s40 (Ssm.s40.stack.length - 3) r, Ssm.S40)
stage_rfl Ssm.coldB36 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s40 (Ssm.s40.stack.length - 3) r) Ssm.S40 = some (tplN Ssm.s41 (Ssm.s41.stack.length - 3) r, Ssm.S41)
stage_rfl Ssm.coldB37 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s41 (Ssm.s41.stack.length - 3) r) Ssm.S41 = some (tplN Ssm.s42 (Ssm.s42.stack.length - 3) r, Ssm.S42)
stage_rfl Ssm.coldB38 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s42 (Ssm.s42.stack.length - 3) r) Ssm.S42 = some (tplN Ssm.s43 (Ssm.s43.stack.length - 3) r, Ssm.S43)
stage_rfl Ssm.coldB39 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s43 (Ssm.s43.stack.length - 3) r) Ssm.S43 = some (tplN Ssm.s44 (Ssm.s44.stack.length - 3) r, Ssm.S44)
stage_rfl Ssm.coldB40 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s44 (Ssm.s44.stack.length - 3) r) Ssm.S44 = some (tplN Ssm.s45 (Ssm.s45.stack.length - 3) r, Ssm.S45)
stage_rfl Ssm.coldB41 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s45 (Ssm.s45.stack.length - 3) r) Ssm.S45 = some (tplN Ssm.s46 (Ssm.s46.stack.length - 3) r, Ssm.S46)
stage_rfl Ssm.coldB42 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s46 (Ssm.s46.stack.length - 3) r) Ssm.S46 = some (tplN Ssm.s47 (Ssm.s47.stack.length - 3) r, Ssm.S47)
stage_rfl Ssm.coldB43 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s47 (Ssm.s47.stack.length - 3) r) Ssm.S47 = some (tplN Ssm.s48 (Ssm.s48.stack.length - 3) r, Ssm.S48)
stage_rfl Ssm.coldB44 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s48 (Ssm.s48.stack.length - 3) r) Ssm.S48 = some (tplN Ssm.s49 (Ssm.s49.stack.length - 3) r, Ssm.S49)
stage_rfl Ssm.coldB45 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s49 (Ssm.s49.stack.length - 3) r) Ssm.S49 = some (tplN Ssm.s50 (Ssm.s50.stack.length - 3) r, Ssm.S50)
stage_rfl Ssm.coldB46 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s50 (Ssm.s50.stack.length - 3) r) Ssm.S50 = some (tplN Ssm.s51 (Ssm.s51.stack.length - 3) r, Ssm.S51)
stage_rfl Ssm.coldB47 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s51 (Ssm.s51.stack.length - 3) r) Ssm.S51 = some (tplN Ssm.s52 (Ssm.s52.stack.length - 3) r, Ssm.S52)
stage_rfl Ssm.coldB48 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s52 (Ssm.s52.stack.length - 3) r) Ssm.S52 = some (tplN Ssm.s53 (Ssm.s53.stack.length - 3) r, Ssm.S53)
stage_rfl Ssm.coldB49 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s53 (Ssm.s53.stack.length - 3) r) Ssm.S53 = some (tplN Ssm.s54 (Ssm.s54.stack.length - 3) r, Ssm.S54)
stage_rfl Ssm.coldB50 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s54 (Ssm.s54.stack.length - 3) r) Ssm.S54 = some (tplN Ssm.s55 (Ssm.s55.stack.length - 3) r, Ssm.S55)
stage_rfl Ssm.coldB51 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s55 (Ssm.s55.stack.length - 3) r) Ssm.S55 = some (tplN Ssm.s56 (Ssm.s56.stack.length - 3) r, Ssm.S56)
stage_rfl Ssm.coldB52 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s56 (Ssm.s56.stack.length - 3) r) Ssm.S56 = some (tplN Ssm.s57 (Ssm.s57.stack.length - 3) r, Ssm.S57)
stage_rfl Ssm.coldB53 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s57 (Ssm.s57.stack.length - 3) r) Ssm.S57 = some (tplN Ssm.s58 (Ssm.s58.stack.length - 3) r, Ssm.S58)
stage_rfl Ssm.coldB54 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s58 (Ssm.s58.stack.length - 3) r) Ssm.S58 = some (tplN Ssm.s59 (Ssm.s59.stack.length - 3) r, Ssm.S59)
stage_rfl Ssm.coldB55 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s59 (Ssm.s59.stack.length - 3) r) Ssm.S59 = some (tplN Ssm.s60 (Ssm.s60.stack.length - 3) r, Ssm.S60)
stage_rfl Ssm.coldB56 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s60 (Ssm.s60.stack.length - 3) r) Ssm.S60 = some (tplN Ssm.s61 (Ssm.s61.stack.length - 3) r, Ssm.S61)
stage_rfl Ssm.coldB57 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s61 (Ssm.s61.stack.length - 3) r) Ssm.S61 = some (tplN Ssm.s62 (Ssm.s62.stack.length - 3) r, Ssm.S62)
stage_rfl Ssm.coldB58 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s62 (Ssm.s62.stack.length - 3) r) Ssm.S62 = some (tplN Ssm.s63 (Ssm.s63.stack.length - 3) r, Ssm.S63)
stage_rfl Ssm.coldB59 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s63 (Ssm.s63.stack.length - 3) r) Ssm.S63 = some (tplN Ssm.s64 (Ssm.s64.stack.length - 3) r, Ssm.S64)
stage_rfl Ssm.coldB60 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s64 (Ssm.s64.stack.length - 3) r) Ssm.S64 = some (tplN Ssm.s65 (Ssm.s65.stack.length - 3) r, Ssm.S65)
stage_rfl Ssm.coldB61 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s65 (Ssm.s65.stack.length - 3) r) Ssm.S65 = some (tplN Ssm.s66 (Ssm.s66.stack.length - 3) r, Ssm.S66)
stage_rfl Ssm.coldB62 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s66 (Ssm.s66.stack.length - 3) r) Ssm.S66 = some (tplN Ssm.s67 (Ssm.s67.stack.length - 3) r, Ssm.S67)
stage_rfl Ssm.coldB63 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s67 (Ssm.s67.stack.length - 3) r) Ssm.S67 = some (tplN Ssm.s68 (Ssm.s68.stack.length - 3) r, Ssm.S68)
stage_rfl Ssm.coldB64 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s68 (Ssm.s68.stack.length - 3) r) Ssm.S68 = some (tplN Ssm.s69 (Ssm.s69.stack.length - 3) r, Ssm.S69)
stage_rfl Ssm.coldB65 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s69 (Ssm.s69.stack.length - 3) r) Ssm.S69 = some (tplN Ssm.s70 (Ssm.s70.stack.length - 3) r, Ssm.S70)
stage_rfl Ssm.coldB66 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s70 (Ssm.s70.stack.length - 3) r) Ssm.S70 = some (tplN Ssm.s71 (Ssm.s71.stack.length - 3) r, Ssm.S71)
stage_rfl Ssm.coldB67 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s71 (Ssm.s71.stack.length - 3) r) Ssm.S71 = some (tplN Ssm.s72 (Ssm.s72.stack.length - 3) r, Ssm.S72)
stage_rfl Ssm.coldB68 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s72 (Ssm.s72.stack.length - 3) r) Ssm.S72 = some (tplN Ssm.s73 (Ssm.s73.stack.length - 3) r, Ssm.S73)
stage_rfl Ssm.coldB69 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s73 (Ssm.s73.stack.length - 3) r) Ssm.S73 = some (tplN Ssm.s74 (Ssm.s74.stack.length - 3) r, Ssm.S74)
stage_rfl Ssm.coldB70 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s74 (Ssm.s74.stack.length - 3) r) Ssm.S74 = some (tplN Ssm.s75 (Ssm.s75.stack.length - 3) r, Ssm.S75)
stage_rfl Ssm.coldB71 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s75 (Ssm.s75.stack.length - 3) r) Ssm.S75 = some (tplN Ssm.s76 (Ssm.s76.stack.length - 3) r, Ssm.S76)
stage_rfl Ssm.coldB72 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s76 (Ssm.s76.stack.length - 3) r) Ssm.S76 = some (tplN Ssm.s77 (Ssm.s77.stack.length - 3) r, Ssm.S77)
stage_rfl Ssm.coldB73 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s77 (Ssm.s77.stack.length - 3) r) Ssm.S77 = some (tplN Ssm.s78 (Ssm.s78.stack.length - 3) r, Ssm.S78)
stage_rfl Ssm.coldB74 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s78 (Ssm.s78.stack.length - 3) r) Ssm.S78 = some (tplN Ssm.s79 (Ssm.s79.stack.length - 3) r, Ssm.S79)
stage_rfl Ssm.coldB75 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s79 (Ssm.s79.stack.length - 3) r) Ssm.S79 = some (tplN Ssm.s80 (Ssm.s80.stack.length - 3) r, Ssm.S80)
stage_rfl Ssm.coldB76 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s80 (Ssm.s80.stack.length - 3) r) Ssm.S80 = some (tplN Ssm.s81 (Ssm.s81.stack.length - 3) r, Ssm.S81)
stage_rfl Ssm.coldB77 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s81 (Ssm.s81.stack.length - 3) r) Ssm.S81 = some (tplN Ssm.s82 (Ssm.s82.stack.length - 3) r, Ssm.S82)
stage_rfl Ssm.coldB78 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s82 (Ssm.s82.stack.length - 3) r) Ssm.S82 = some (tplN Ssm.s83 (Ssm.s83.stack.length - 3) r, Ssm.S83)
stage_rfl Ssm.coldB79 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s83 (Ssm.s83.stack.length - 3) r) Ssm.S83 = some (tplN Ssm.s84 (Ssm.s84.stack.length - 3) r, Ssm.S84)
stage_rfl Ssm.coldB80 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s84 (Ssm.s84.stack.length - 3) r) Ssm.S84 = some (tplN Ssm.s85 (Ssm.s85.stack.length - 3) r, Ssm.S85)
stage_rfl Ssm.coldB81 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s85 (Ssm.s85.stack.length - 3) r) Ssm.S85 = some (tplN Ssm.s86 (Ssm.s86.stack.length - 3) r, Ssm.S86)
stage_rfl Ssm.coldB82 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s86 (Ssm.s86.stack.length - 3) r) Ssm.S86 = some (tplN Ssm.s87 (Ssm.s87.stack.length - 3) r, Ssm.S87)
stage_rfl Ssm.coldB83 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s87 (Ssm.s87.stack.length - 3) r) Ssm.S87 = some (tplN Ssm.s88 (Ssm.s88.stack.length - 3) r, Ssm.S88)
stage_rfl Ssm.coldB84 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s88 (Ssm.s88.stack.length - 3) r) Ssm.S88 = some (tplN Ssm.s89 (Ssm.s89.stack.length - 3) r, Ssm.S89)
stage_rfl Ssm.coldB85 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s89 (Ssm.s89.stack.length - 3) r) Ssm.S89 = some (tplN Ssm.s90 (Ssm.s90.stack.length - 3) r, Ssm.S90)
stage_rfl Ssm.coldB86 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s90 (Ssm.s90.stack.length - 3) r) Ssm.S90 = some (tplN Ssm.s91 (Ssm.s91.stack.length - 3) r, Ssm.S91)
stage_rfl Ssm.coldB87 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s91 (Ssm.s91.stack.length - 3) r) Ssm.S91 = some (tplN Ssm.s92 (Ssm.s92.stack.length - 3) r, Ssm.S92)
stage_rfl Ssm.coldB88 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s92 (Ssm.s92.stack.length - 3) r) Ssm.S92 = some (tplN Ssm.s93 (Ssm.s93.stack.length - 3) r, Ssm.S93)
stage_rfl Ssm.coldB89 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s93 (Ssm.s93.stack.length - 3) r) Ssm.S93 = some (tplN Ssm.s94 (Ssm.s94.stack.length - 3) r, Ssm.S94)
stage_rfl Ssm.coldB90 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s94 (Ssm.s94.stack.length - 3) r) Ssm.S94 = some (tplN Ssm.s95 (Ssm.s95.stack.length - 3) r, Ssm.S95)
stage_rfl Ssm.coldB91 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s95 (Ssm.s95.stack.length - 3) r) Ssm.S95 = some (tplN Ssm.s96 (Ssm.s96.stack.length - 3) r, Ssm.S96)
stage_rfl Ssm.coldB92 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s96 (Ssm.s96.stack.length - 3) r) Ssm.S96 = some (tplN Ssm.s97 (Ssm.s97.stack.length - 3) r, Ssm.S97)
stage_rfl Ssm.coldB93 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s97 (Ssm.s97.stack.length - 3) r) Ssm.S97 = some (tplN Ssm.s98 (Ssm.s98.stack.length - 3) r, Ssm.S98)
stage_rfl Ssm.coldB94 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s98 (Ssm.s98.stack.length - 3) r) Ssm.S98 = some (tplN Ssm.s99 (Ssm.s99.stack.length - 3) r, Ssm.S99)
stage_rfl Ssm.coldB95 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s99 (Ssm.s99.stack.length - 3) r) Ssm.S99 = some (tplN Ssm.s100 (Ssm.s100.stack.length - 3) r, Ssm.S100)
stage_rfl Ssm.coldB96 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s100 (Ssm.s100.stack.length - 3) r) Ssm.S100 = some (tplN Ssm.s101 (Ssm.s101.stack.length - 3) r, Ssm.S101)
stage_rfl Ssm.coldB97 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s101 (Ssm.s101.stack.length - 3) r) Ssm.S101 = some (tplN Ssm.s102 (Ssm.s102.stack.length - 3) r, Ssm.S102)
stage_rfl Ssm.coldB98 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s102 (Ssm.s102.stack.length - 3) r) Ssm.S102 = some (tplN Ssm.s103 (Ssm.s103.stack.length - 3) r, Ssm.S103)
stage_rfl Ssm.coldB99 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s103 (Ssm.s103.stack.length - 3) r) Ssm.S103 = some (tplN Ssm.s104 (Ssm.s104.stack.length - 3) r, Ssm.S104)
stage_rfl Ssm.coldB100 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s104 (Ssm.s104.stack.length - 3) r) Ssm.S104 = some (tplN Ssm.s105 (Ssm.s105.stack.length - 3) r, Ssm.S105)
stage_rfl Ssm.coldB101 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s105 (Ssm.s105.stack.length - 3) r) Ssm.S105 = some (tplN Ssm.s106 (Ssm.s106.stack.length - 3) r, Ssm.S106)
stage_rfl Ssm.coldB102 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s106 (Ssm.s106.stack.length - 3) r) Ssm.S106 = some (tplN Ssm.s107 (Ssm.s107.stack.length - 3) r, Ssm.S107)
stage_rfl Ssm.coldB103 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s107 (Ssm.s107.stack.length - 3) r) Ssm.S107 = some (tplN Ssm.s108 (Ssm.s108.stack.length - 3) r, Ssm.S108)
stage_rfl Ssm.coldB104 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s108 (Ssm.s108.stack.length - 3) r) Ssm.S108 = some (tplN Ssm.s109 (Ssm.s109.stack.length - 3) r, Ssm.S109)
stage_rfl Ssm.coldB105 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s109 (Ssm.s109.stack.length - 3) r) Ssm.S109 = some (tplN Ssm.s110 (Ssm.s110.stack.length - 3) r, Ssm.S110)
stage_rfl Ssm.coldB106 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s110 (Ssm.s110.stack.length - 3) r) Ssm.S110 = some (tplN Ssm.s111 (Ssm.s111.stack.length - 3) r, Ssm.S111)
stage_rfl Ssm.coldB107 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s111 (Ssm.s111.stack.length - 3) r) Ssm.S111 = some (tplN Ssm.s112 (Ssm.s112.stack.length - 3) r, Ssm.S112)
stage_rfl Ssm.coldB108 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s112 (Ssm.s112.stack.length - 3) r) Ssm.S112 = some (tplN Ssm.s113 (Ssm.s113.stack.length - 3) r, Ssm.S113)
stage_rfl Ssm.coldB109 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s113 (Ssm.s113.stack.length - 3) r) Ssm.S113 = some (tplN Ssm.s114 (Ssm.s114.stack.length - 3) r, Ssm.S114)
stage_rfl Ssm.coldB110 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s114 (Ssm.s114.stack.length - 3) r) Ssm.S114 = some (tplN Ssm.s115 (Ssm.s115.stack.length - 3) r, Ssm.S115)
stage_rfl Ssm.coldB111 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s115 (Ssm.s115.stack.length - 3) r) Ssm.S115 = some (tplN Ssm.s116 (Ssm.s116.stack.length - 3) r, Ssm.S116)
stage_rfl Ssm.coldB112 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s116 (Ssm.s116.stack.length - 3) r) Ssm.S116 = some (tplN Ssm.s117 (Ssm.s117.stack.length - 3) r, Ssm.S117)
stage_rfl Ssm.coldB113 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s117 (Ssm.s117.stack.length - 3) r) Ssm.S117 = some (tplN Ssm.s118 (Ssm.s118.stack.length - 3) r, Ssm.S118)
stage_rfl Ssm.coldB114 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s118 (Ssm.s118.stack.length - 3) r) Ssm.S118 = some (tplN Ssm.s119 (Ssm.s119.stack.length - 3) r, Ssm.S119)
stage_rfl Ssm.coldB115 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s119 (Ssm.s119.stack.length - 3) r) Ssm.S119 = some (tplN Ssm.s120 (Ssm.s120.stack.length - 3) r, Ssm.S120)
stage_rfl Ssm.coldB116 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s120 (Ssm.s120.stack.length - 3) r) Ssm.S120 = some (tplN Ssm.s121 (Ssm.s121.stack.length - 3) r, Ssm.S121)
stage_rfl Ssm.coldB117 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s121 (Ssm.s121.stack.length - 3) r) Ssm.S121 = some (tplN Ssm.s122 (Ssm.s122.stack.length - 3) r, Ssm.S122)
stage_rfl Ssm.coldB118 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s122 (Ssm.s122.stack.length - 3) r) Ssm.S122 = some (tplN Ssm.s123 (Ssm.s123.stack.length - 3) r, Ssm.S123)
stage_rfl Ssm.coldB119 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s123 (Ssm.s123.stack.length - 3) r) Ssm.S123 = some (tplN Ssm.s124 (Ssm.s124.stack.length - 3) r, Ssm.S124)
stage_rfl Ssm.coldB120 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s124 (Ssm.s124.stack.length - 3) r) Ssm.S124 = some (tplN Ssm.s125 (Ssm.s125.stack.length - 3) r, Ssm.S125)
stage_rfl Ssm.coldB121 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s125 (Ssm.s125.stack.length - 3) r) Ssm.S125 = some (tplN Ssm.s126 (Ssm.s126.stack.length - 3) r, Ssm.S126)
stage_rfl Ssm.coldB122 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s126 (Ssm.s126.stack.length - 3) r) Ssm.S126 = some (tplN Ssm.s127 (Ssm.s127.stack.length - 3) r, Ssm.S127)
stage_rfl Ssm.coldB123 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s127 (Ssm.s127.stack.length - 3) r) Ssm.S127 = some (tplN Ssm.s128 (Ssm.s128.stack.length - 3) r, Ssm.S128)
stage_rfl Ssm.coldB124 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s128 (Ssm.s128.stack.length - 3) r) Ssm.S128 = some (tplN Ssm.s129 (Ssm.s129.stack.length - 3) r, Ssm.S129)
stage_rfl Ssm.coldB125 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s129 (Ssm.s129.stack.length - 3) r) Ssm.S129 = some (tplN Ssm.s130 (Ssm.s130.stack.length - 3) r, Ssm.S130)
stage_rfl Ssm.coldB126 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s130 (Ssm.s130.stack.length - 3) r) Ssm.S130 = some (tplN Ssm.s131 (Ssm.s131.stack.length - 3) r, Ssm.S131)
stage_rfl Ssm.coldB127 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s131 (Ssm.s131.stack.length - 3) r) Ssm.S131 = some (tplN Ssm.s132 (Ssm.s132.stack.length - 3) r, Ssm.S132)
stage_rfl Ssm.coldB128 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s132 (Ssm.s132.stack.length - 3) r) Ssm.S132 = some (tplN Ssm.s133 (Ssm.s133.stack.length - 3) r, Ssm.S133)
stage_rfl Ssm.coldB129 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s133 (Ssm.s133.stack.length - 3) r) Ssm.S133 = some (tplN Ssm.s134 (Ssm.s134.stack.length - 3) r, Ssm.S134)
stage_rfl Ssm.coldB130 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s134 (Ssm.s134.stack.length - 3) r) Ssm.S134 = some (tplN Ssm.s135 (Ssm.s135.stack.length - 3) r, Ssm.S135)
stage_rfl Ssm.coldB131 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s135 (Ssm.s135.stack.length - 3) r) Ssm.S135 = some (tplN Ssm.s136 (Ssm.s136.stack.length - 3) r, Ssm.S136)
stage_rfl Ssm.coldB132 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s136 (Ssm.s136.stack.length - 3) r) Ssm.S136 = some (tplN Ssm.s137 (Ssm.s137.stack.length - 3) r, Ssm.S137)
stage_rfl Ssm.coldB133 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s137 (Ssm.s137.stack.length - 3) r) Ssm.S137 = some (tplN Ssm.s138 (Ssm.s138.stack.length - 3) r, Ssm.S138)
stage_rfl Ssm.coldB134 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s138 (Ssm.s138.stack.length - 3) r) Ssm.S138 = some (tplN Ssm.s139 (Ssm.s139.stack.length - 3) r, Ssm.S139)
stage_rfl Ssm.coldB135 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s139 (Ssm.s139.stack.length - 3) r) Ssm.S139 = some (tplN Ssm.s140 (Ssm.s140.stack.length - 3) r, Ssm.S140)
stage_rfl Ssm.coldB136 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s140 (Ssm.s140.stack.length - 3) r) Ssm.S140 = some (tplN Ssm.s141 (Ssm.s141.stack.length - 3) r, Ssm.S141)
stage_rfl Ssm.coldB137 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s141 (Ssm.s141.stack.length - 3) r) Ssm.S141 = some (tplN Ssm.s142 (Ssm.s142.stack.length - 3) r, Ssm.S142)
stage_rfl Ssm.coldB138 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s142 (Ssm.s142.stack.length - 3) r) Ssm.S142 = some (tplN Ssm.s143 (Ssm.s143.stack.length - 3) r, Ssm.S143)
stage_rfl Ssm.coldB139 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s143 (Ssm.s143.stack.length - 3) r) Ssm.S143 = some (tplN Ssm.s144 (Ssm.s144.stack.length - 3) r, Ssm.S144)
stage_rfl Ssm.coldB140 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s144 (Ssm.s144.stack.length - 3) r) Ssm.S144 = some (tplN Ssm.s145 (Ssm.s145.stack.length - 3) r, Ssm.S145)
stage_rfl Ssm.coldB141 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s145 (Ssm.s145.stack.length - 3) r) Ssm.S145 = some (tplN Ssm.s146 (Ssm.s146.stack.length - 3) r, Ssm.S146)
stage_rfl Ssm.coldB142 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s146 (Ssm.s146.stack.length - 3) r) Ssm.S146 = some (tplN Ssm.s147 (Ssm.s147.stack.length - 3) r, Ssm.S147)
stage_rfl Ssm.coldB143 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s147 (Ssm.s147.stack.length - 3) r) Ssm.S147 = some (tplN Ssm.s148 (Ssm.s148.stack.length - 3) r, Ssm.S148)
stage_rfl Ssm.coldB144 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s148 (Ssm.s148.stack.length - 3) r) Ssm.S148 = some (tplN Ssm.s149 (Ssm.s149.stack.length - 3) r, Ssm.S149)
stage_rfl Ssm.coldB145 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s149 (Ssm.s149.stack.length - 3) r) Ssm.S149 = some (tplN Ssm.s150 (Ssm.s150.stack.length - 3) r, Ssm.S150)
stage_rfl Ssm.coldB146 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s150 (Ssm.s150.stack.length - 3) r) Ssm.S150 = some (tplN Ssm.s151 (Ssm.s151.stack.length - 3) r, Ssm.S151)
stage_rfl Ssm.coldB147 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s151 (Ssm.s151.stack.length - 3) r) Ssm.S151 = some (tplN Ssm.s152 (Ssm.s152.stack.length - 3) r, Ssm.S152)
stage_rfl Ssm.coldB148 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s152 (Ssm.s152.stack.length - 3) r) Ssm.S152 = some (tplN Ssm.s153 (Ssm.s153.stack.length - 3) r, Ssm.S153)
stage_rfl Ssm.coldB149 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s153 (Ssm.s153.stack.length - 3) r) Ssm.S153 = some (tplN Ssm.s154 (Ssm.s154.stack.length - 3) r, Ssm.S154)
stage_rfl Ssm.coldB150 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s154 (Ssm.s154.stack.length - 3) r) Ssm.S154 = some (tplN Ssm.s155 (Ssm.s155.stack.length - 3) r, Ssm.S155)
stage_rfl Ssm.coldB151 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s155 (Ssm.s155.stack.length - 3) r) Ssm.S155 = some (tplN Ssm.s156 (Ssm.s156.stack.length - 3) r, Ssm.S156)
stage_rfl Ssm.coldB152 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s156 (Ssm.s156.stack.length - 3) r) Ssm.S156 = some (tplN Ssm.s157 (Ssm.s157.stack.length - 3) r, Ssm.S157)
stage_rfl Ssm.coldB153 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s157 (Ssm.s157.stack.length - 3) r) Ssm.S157 = some (tplN Ssm.s158 (Ssm.s158.stack.length - 3) r, Ssm.S158)
stage_rfl Ssm.coldB154 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s158 (Ssm.s158.stack.length - 3) r) Ssm.S158 = some (tplN Ssm.s159 (Ssm.s159.stack.length - 3) r, Ssm.S159)
stage_rfl Ssm.coldB155 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s159 (Ssm.s159.stack.length - 3) r) Ssm.S159 = some (tplN Ssm.s160 (Ssm.s160.stack.length - 3) r, Ssm.S160)
stage_rfl Ssm.coldB156 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s160 (Ssm.s160.stack.length - 3) r) Ssm.S160 = some (tplN Ssm.s161 (Ssm.s161.stack.length - 3) r, Ssm.S161)
stage_rfl Ssm.coldB157 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s161 (Ssm.s161.stack.length - 3) r) Ssm.S161 = some (tplN Ssm.s162 (Ssm.s162.stack.length - 3) r, Ssm.S162)
stage_rfl Ssm.coldB158 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s162 (Ssm.s162.stack.length - 3) r) Ssm.S162 = some (tplN Ssm.s163 (Ssm.s163.stack.length - 3) r, Ssm.S163)
stage_rfl Ssm.coldB159 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s163 (Ssm.s163.stack.length - 3) r) Ssm.S163 = some (tplN Ssm.s164 (Ssm.s164.stack.length - 3) r, Ssm.S164)
stage_rfl Ssm.coldB160 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s164 (Ssm.s164.stack.length - 3) r) Ssm.S164 = some (tplN Ssm.s165 (Ssm.s165.stack.length - 3) r, Ssm.S165)
stage_rfl Ssm.coldB161 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s165 (Ssm.s165.stack.length - 3) r) Ssm.S165 = some (tplN Ssm.s166 (Ssm.s166.stack.length - 3) r, Ssm.S166)
stage_rfl Ssm.coldB162 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 63 (tplN Ssm.s166 (Ssm.s166.stack.length - 3) r) Ssm.S166 = some (tplN Ssm.s167 1 r, Ssm.S167)
stage_rfl Ssm.coldLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Ssm.s167 1 r)).run Ssm.S167 = some (tplN Ssm.s168 0 r, Ssm.S168)
kernel_rfl Ssm.coldLive : isHalt Ssm.s167.ctl = false
kernel_rfl Ssm.coldFrames : Ssm.s168.stack = Ssm.s4.stack

/-- Stage `Ssm.cold` under every caller stack. -/
theorem Ssm.cold (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 16264 (tplN Ssm.s4 0 r) Ssm.S4 = some (tplN Ssm.s168 0 r, Ssm.S168) :=
  runS_snoc _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (Ssm.coldB0 r) (Ssm.coldB1 r)) (Ssm.coldB2 r)) (Ssm.coldB3 r)) (Ssm.coldB4 r)) (Ssm.coldB5 r)) (Ssm.coldB6 r)) (Ssm.coldB7 r)) (Ssm.coldB8 r)) (Ssm.coldB9 r)) (Ssm.coldB10 r)) (Ssm.coldB11 r)) (Ssm.coldB12 r)) (Ssm.coldB13 r)) (Ssm.coldB14 r)) (Ssm.coldB15 r)) (Ssm.coldB16 r)) (Ssm.coldB17 r)) (Ssm.coldB18 r)) (Ssm.coldB19 r)) (Ssm.coldB20 r)) (Ssm.coldB21 r)) (Ssm.coldB22 r)) (Ssm.coldB23 r)) (Ssm.coldB24 r)) (Ssm.coldB25 r)) (Ssm.coldB26 r)) (Ssm.coldB27 r)) (Ssm.coldB28 r)) (Ssm.coldB29 r)) (Ssm.coldB30 r)) (Ssm.coldB31 r)) (Ssm.coldB32 r)) (Ssm.coldB33 r)) (Ssm.coldB34 r)) (Ssm.coldB35 r)) (Ssm.coldB36 r)) (Ssm.coldB37 r)) (Ssm.coldB38 r)) (Ssm.coldB39 r)) (Ssm.coldB40 r)) (Ssm.coldB41 r)) (Ssm.coldB42 r)) (Ssm.coldB43 r)) (Ssm.coldB44 r)) (Ssm.coldB45 r)) (Ssm.coldB46 r)) (Ssm.coldB47 r)) (Ssm.coldB48 r)) (Ssm.coldB49 r)) (Ssm.coldB50 r)) (Ssm.coldB51 r)) (Ssm.coldB52 r)) (Ssm.coldB53 r)) (Ssm.coldB54 r)) (Ssm.coldB55 r)) (Ssm.coldB56 r)) (Ssm.coldB57 r)) (Ssm.coldB58 r)) (Ssm.coldB59 r)) (Ssm.coldB60 r)) (Ssm.coldB61 r)) (Ssm.coldB62 r)) (Ssm.coldB63 r)) (Ssm.coldB64 r)) (Ssm.coldB65 r)) (Ssm.coldB66 r)) (Ssm.coldB67 r)) (Ssm.coldB68 r)) (Ssm.coldB69 r)) (Ssm.coldB70 r)) (Ssm.coldB71 r)) (Ssm.coldB72 r)) (Ssm.coldB73 r)) (Ssm.coldB74 r)) (Ssm.coldB75 r)) (Ssm.coldB76 r)) (Ssm.coldB77 r)) (Ssm.coldB78 r)) (Ssm.coldB79 r)) (Ssm.coldB80 r)) (Ssm.coldB81 r)) (Ssm.coldB82 r)) (Ssm.coldB83 r)) (Ssm.coldB84 r)) (Ssm.coldB85 r)) (Ssm.coldB86 r)) (Ssm.coldB87 r)) (Ssm.coldB88 r)) (Ssm.coldB89 r)) (Ssm.coldB90 r)) (Ssm.coldB91 r)) (Ssm.coldB92 r)) (Ssm.coldB93 r)) (Ssm.coldB94 r)) (Ssm.coldB95 r)) (Ssm.coldB96 r)) (Ssm.coldB97 r)) (Ssm.coldB98 r)) (Ssm.coldB99 r)) (Ssm.coldB100 r)) (Ssm.coldB101 r)) (Ssm.coldB102 r)) (Ssm.coldB103 r)) (Ssm.coldB104 r)) (Ssm.coldB105 r)) (Ssm.coldB106 r)) (Ssm.coldB107 r)) (Ssm.coldB108 r)) (Ssm.coldB109 r)) (Ssm.coldB110 r)) (Ssm.coldB111 r)) (Ssm.coldB112 r)) (Ssm.coldB113 r)) (Ssm.coldB114 r)) (Ssm.coldB115 r)) (Ssm.coldB116 r)) (Ssm.coldB117 r)) (Ssm.coldB118 r)) (Ssm.coldB119 r)) (Ssm.coldB120 r)) (Ssm.coldB121 r)) (Ssm.coldB122 r)) (Ssm.coldB123 r)) (Ssm.coldB124 r)) (Ssm.coldB125 r)) (Ssm.coldB126 r)) (Ssm.coldB127 r)) (Ssm.coldB128 r)) (Ssm.coldB129 r)) (Ssm.coldB130 r)) (Ssm.coldB131 r)) (Ssm.coldB132 r)) (Ssm.coldB133 r)) (Ssm.coldB134 r)) (Ssm.coldB135 r)) (Ssm.coldB136 r)) (Ssm.coldB137 r)) (Ssm.coldB138 r)) (Ssm.coldB139 r)) (Ssm.coldB140 r)) (Ssm.coldB141 r)) (Ssm.coldB142 r)) (Ssm.coldB143 r)) (Ssm.coldB144 r)) (Ssm.coldB145 r)) (Ssm.coldB146 r)) (Ssm.coldB147 r)) (Ssm.coldB148 r)) (Ssm.coldB149 r)) (Ssm.coldB150 r)) (Ssm.coldB151 r)) (Ssm.coldB152 r)) (Ssm.coldB153 r)) (Ssm.coldB154 r)) (Ssm.coldB155 r)) (Ssm.coldB156 r)) (Ssm.coldB157 r)) (Ssm.coldB158 r)) (Ssm.coldB159 r)) (Ssm.coldB160 r)) (Ssm.coldB161 r)) (Ssm.coldB162 r)) Ssm.coldLive (Ssm.coldLast r)

/-- Stage `Ssm.cold` at the driver's own frames. -/
theorem Ssm.coldAt : runS Host.Mlx.Ffi.ffi 16264 Ssm.s4 Ssm.S4 = some (Ssm.s168, Ssm.S168) := by
  have h := Ssm.cold Ssm.s4.stack
  rwa [show tplN Ssm.s4 0 Ssm.s4.stack = Ssm.s4 from tplN_self Ssm.s4 0,
    show tplN Ssm.s168 0 Ssm.s4.stack = Ssm.s168 by rw [← Ssm.coldFrames]; exact tplN_self Ssm.s168 0] at h

kernel_rfl Ssm.warmD : Ssm.s241.stack.length = 4
stage_rfl Ssm.warmB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s169 0 r) Ssm.S169 = some (tplN Ssm.s170 (Ssm.s170.stack.length - 3) r, Ssm.S170)
stage_rfl Ssm.warmB1 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s170 (Ssm.s170.stack.length - 3) r) Ssm.S170 = some (tplN Ssm.s171 (Ssm.s171.stack.length - 3) r, Ssm.S171)
stage_rfl Ssm.warmB2 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s171 (Ssm.s171.stack.length - 3) r) Ssm.S171 = some (tplN Ssm.s172 (Ssm.s172.stack.length - 3) r, Ssm.S172)
stage_rfl Ssm.warmB3 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s172 (Ssm.s172.stack.length - 3) r) Ssm.S172 = some (tplN Ssm.s173 (Ssm.s173.stack.length - 3) r, Ssm.S173)
stage_rfl Ssm.warmB4 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s173 (Ssm.s173.stack.length - 3) r) Ssm.S173 = some (tplN Ssm.s174 (Ssm.s174.stack.length - 3) r, Ssm.S174)
stage_rfl Ssm.warmB5 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s174 (Ssm.s174.stack.length - 3) r) Ssm.S174 = some (tplN Ssm.s175 (Ssm.s175.stack.length - 3) r, Ssm.S175)
stage_rfl Ssm.warmB6 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s175 (Ssm.s175.stack.length - 3) r) Ssm.S175 = some (tplN Ssm.s176 (Ssm.s176.stack.length - 3) r, Ssm.S176)
stage_rfl Ssm.warmB7 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s176 (Ssm.s176.stack.length - 3) r) Ssm.S176 = some (tplN Ssm.s177 (Ssm.s177.stack.length - 3) r, Ssm.S177)
stage_rfl Ssm.warmB8 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s177 (Ssm.s177.stack.length - 3) r) Ssm.S177 = some (tplN Ssm.s178 (Ssm.s178.stack.length - 3) r, Ssm.S178)
stage_rfl Ssm.warmB9 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s178 (Ssm.s178.stack.length - 3) r) Ssm.S178 = some (tplN Ssm.s179 (Ssm.s179.stack.length - 3) r, Ssm.S179)
stage_rfl Ssm.warmB10 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s179 (Ssm.s179.stack.length - 3) r) Ssm.S179 = some (tplN Ssm.s180 (Ssm.s180.stack.length - 3) r, Ssm.S180)
stage_rfl Ssm.warmB11 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s180 (Ssm.s180.stack.length - 3) r) Ssm.S180 = some (tplN Ssm.s181 (Ssm.s181.stack.length - 3) r, Ssm.S181)
stage_rfl Ssm.warmB12 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s181 (Ssm.s181.stack.length - 3) r) Ssm.S181 = some (tplN Ssm.s182 (Ssm.s182.stack.length - 3) r, Ssm.S182)
stage_rfl Ssm.warmB13 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s182 (Ssm.s182.stack.length - 3) r) Ssm.S182 = some (tplN Ssm.s183 (Ssm.s183.stack.length - 3) r, Ssm.S183)
stage_rfl Ssm.warmB14 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s183 (Ssm.s183.stack.length - 3) r) Ssm.S183 = some (tplN Ssm.s184 (Ssm.s184.stack.length - 3) r, Ssm.S184)
stage_rfl Ssm.warmB15 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s184 (Ssm.s184.stack.length - 3) r) Ssm.S184 = some (tplN Ssm.s185 (Ssm.s185.stack.length - 3) r, Ssm.S185)
stage_rfl Ssm.warmB16 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s185 (Ssm.s185.stack.length - 3) r) Ssm.S185 = some (tplN Ssm.s186 (Ssm.s186.stack.length - 3) r, Ssm.S186)
stage_rfl Ssm.warmB17 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s186 (Ssm.s186.stack.length - 3) r) Ssm.S186 = some (tplN Ssm.s187 (Ssm.s187.stack.length - 3) r, Ssm.S187)
stage_rfl Ssm.warmB18 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s187 (Ssm.s187.stack.length - 3) r) Ssm.S187 = some (tplN Ssm.s188 (Ssm.s188.stack.length - 3) r, Ssm.S188)
stage_rfl Ssm.warmB19 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s188 (Ssm.s188.stack.length - 3) r) Ssm.S188 = some (tplN Ssm.s189 (Ssm.s189.stack.length - 3) r, Ssm.S189)
stage_rfl Ssm.warmB20 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s189 (Ssm.s189.stack.length - 3) r) Ssm.S189 = some (tplN Ssm.s190 (Ssm.s190.stack.length - 3) r, Ssm.S190)
stage_rfl Ssm.warmB21 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s190 (Ssm.s190.stack.length - 3) r) Ssm.S190 = some (tplN Ssm.s191 (Ssm.s191.stack.length - 3) r, Ssm.S191)
stage_rfl Ssm.warmB22 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s191 (Ssm.s191.stack.length - 3) r) Ssm.S191 = some (tplN Ssm.s192 (Ssm.s192.stack.length - 3) r, Ssm.S192)
stage_rfl Ssm.warmB23 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s192 (Ssm.s192.stack.length - 3) r) Ssm.S192 = some (tplN Ssm.s193 (Ssm.s193.stack.length - 3) r, Ssm.S193)
stage_rfl Ssm.warmB24 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s193 (Ssm.s193.stack.length - 3) r) Ssm.S193 = some (tplN Ssm.s194 (Ssm.s194.stack.length - 3) r, Ssm.S194)
stage_rfl Ssm.warmB25 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s194 (Ssm.s194.stack.length - 3) r) Ssm.S194 = some (tplN Ssm.s195 (Ssm.s195.stack.length - 3) r, Ssm.S195)
stage_rfl Ssm.warmB26 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s195 (Ssm.s195.stack.length - 3) r) Ssm.S195 = some (tplN Ssm.s196 (Ssm.s196.stack.length - 3) r, Ssm.S196)
stage_rfl Ssm.warmB27 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s196 (Ssm.s196.stack.length - 3) r) Ssm.S196 = some (tplN Ssm.s197 (Ssm.s197.stack.length - 3) r, Ssm.S197)
stage_rfl Ssm.warmB28 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s197 (Ssm.s197.stack.length - 3) r) Ssm.S197 = some (tplN Ssm.s198 (Ssm.s198.stack.length - 3) r, Ssm.S198)
stage_rfl Ssm.warmB29 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s198 (Ssm.s198.stack.length - 3) r) Ssm.S198 = some (tplN Ssm.s199 (Ssm.s199.stack.length - 3) r, Ssm.S199)
stage_rfl Ssm.warmB30 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s199 (Ssm.s199.stack.length - 3) r) Ssm.S199 = some (tplN Ssm.s200 (Ssm.s200.stack.length - 3) r, Ssm.S200)
stage_rfl Ssm.warmB31 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s200 (Ssm.s200.stack.length - 3) r) Ssm.S200 = some (tplN Ssm.s201 (Ssm.s201.stack.length - 3) r, Ssm.S201)
stage_rfl Ssm.warmB32 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s201 (Ssm.s201.stack.length - 3) r) Ssm.S201 = some (tplN Ssm.s202 (Ssm.s202.stack.length - 3) r, Ssm.S202)
stage_rfl Ssm.warmB33 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s202 (Ssm.s202.stack.length - 3) r) Ssm.S202 = some (tplN Ssm.s203 (Ssm.s203.stack.length - 3) r, Ssm.S203)
stage_rfl Ssm.warmB34 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s203 (Ssm.s203.stack.length - 3) r) Ssm.S203 = some (tplN Ssm.s204 (Ssm.s204.stack.length - 3) r, Ssm.S204)
stage_rfl Ssm.warmB35 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s204 (Ssm.s204.stack.length - 3) r) Ssm.S204 = some (tplN Ssm.s205 (Ssm.s205.stack.length - 3) r, Ssm.S205)
stage_rfl Ssm.warmB36 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s205 (Ssm.s205.stack.length - 3) r) Ssm.S205 = some (tplN Ssm.s206 (Ssm.s206.stack.length - 3) r, Ssm.S206)
stage_rfl Ssm.warmB37 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s206 (Ssm.s206.stack.length - 3) r) Ssm.S206 = some (tplN Ssm.s207 (Ssm.s207.stack.length - 3) r, Ssm.S207)
stage_rfl Ssm.warmB38 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s207 (Ssm.s207.stack.length - 3) r) Ssm.S207 = some (tplN Ssm.s208 (Ssm.s208.stack.length - 3) r, Ssm.S208)
stage_rfl Ssm.warmB39 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s208 (Ssm.s208.stack.length - 3) r) Ssm.S208 = some (tplN Ssm.s209 (Ssm.s209.stack.length - 3) r, Ssm.S209)
stage_rfl Ssm.warmB40 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s209 (Ssm.s209.stack.length - 3) r) Ssm.S209 = some (tplN Ssm.s210 (Ssm.s210.stack.length - 3) r, Ssm.S210)
stage_rfl Ssm.warmB41 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s210 (Ssm.s210.stack.length - 3) r) Ssm.S210 = some (tplN Ssm.s211 (Ssm.s211.stack.length - 3) r, Ssm.S211)
stage_rfl Ssm.warmB42 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s211 (Ssm.s211.stack.length - 3) r) Ssm.S211 = some (tplN Ssm.s212 (Ssm.s212.stack.length - 3) r, Ssm.S212)
stage_rfl Ssm.warmB43 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s212 (Ssm.s212.stack.length - 3) r) Ssm.S212 = some (tplN Ssm.s213 (Ssm.s213.stack.length - 3) r, Ssm.S213)
stage_rfl Ssm.warmB44 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s213 (Ssm.s213.stack.length - 3) r) Ssm.S213 = some (tplN Ssm.s214 (Ssm.s214.stack.length - 3) r, Ssm.S214)
stage_rfl Ssm.warmB45 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s214 (Ssm.s214.stack.length - 3) r) Ssm.S214 = some (tplN Ssm.s215 (Ssm.s215.stack.length - 3) r, Ssm.S215)
stage_rfl Ssm.warmB46 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s215 (Ssm.s215.stack.length - 3) r) Ssm.S215 = some (tplN Ssm.s216 (Ssm.s216.stack.length - 3) r, Ssm.S216)
stage_rfl Ssm.warmB47 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s216 (Ssm.s216.stack.length - 3) r) Ssm.S216 = some (tplN Ssm.s217 (Ssm.s217.stack.length - 3) r, Ssm.S217)
stage_rfl Ssm.warmB48 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s217 (Ssm.s217.stack.length - 3) r) Ssm.S217 = some (tplN Ssm.s218 (Ssm.s218.stack.length - 3) r, Ssm.S218)
stage_rfl Ssm.warmB49 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s218 (Ssm.s218.stack.length - 3) r) Ssm.S218 = some (tplN Ssm.s219 (Ssm.s219.stack.length - 3) r, Ssm.S219)
stage_rfl Ssm.warmB50 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s219 (Ssm.s219.stack.length - 3) r) Ssm.S219 = some (tplN Ssm.s220 (Ssm.s220.stack.length - 3) r, Ssm.S220)
stage_rfl Ssm.warmB51 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s220 (Ssm.s220.stack.length - 3) r) Ssm.S220 = some (tplN Ssm.s221 (Ssm.s221.stack.length - 3) r, Ssm.S221)
stage_rfl Ssm.warmB52 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s221 (Ssm.s221.stack.length - 3) r) Ssm.S221 = some (tplN Ssm.s222 (Ssm.s222.stack.length - 3) r, Ssm.S222)
stage_rfl Ssm.warmB53 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s222 (Ssm.s222.stack.length - 3) r) Ssm.S222 = some (tplN Ssm.s223 (Ssm.s223.stack.length - 3) r, Ssm.S223)
stage_rfl Ssm.warmB54 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s223 (Ssm.s223.stack.length - 3) r) Ssm.S223 = some (tplN Ssm.s224 (Ssm.s224.stack.length - 3) r, Ssm.S224)
stage_rfl Ssm.warmB55 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s224 (Ssm.s224.stack.length - 3) r) Ssm.S224 = some (tplN Ssm.s225 (Ssm.s225.stack.length - 3) r, Ssm.S225)
stage_rfl Ssm.warmB56 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s225 (Ssm.s225.stack.length - 3) r) Ssm.S225 = some (tplN Ssm.s226 (Ssm.s226.stack.length - 3) r, Ssm.S226)
stage_rfl Ssm.warmB57 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s226 (Ssm.s226.stack.length - 3) r) Ssm.S226 = some (tplN Ssm.s227 (Ssm.s227.stack.length - 3) r, Ssm.S227)
stage_rfl Ssm.warmB58 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s227 (Ssm.s227.stack.length - 3) r) Ssm.S227 = some (tplN Ssm.s228 (Ssm.s228.stack.length - 3) r, Ssm.S228)
stage_rfl Ssm.warmB59 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s228 (Ssm.s228.stack.length - 3) r) Ssm.S228 = some (tplN Ssm.s229 (Ssm.s229.stack.length - 3) r, Ssm.S229)
stage_rfl Ssm.warmB60 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s229 (Ssm.s229.stack.length - 3) r) Ssm.S229 = some (tplN Ssm.s230 (Ssm.s230.stack.length - 3) r, Ssm.S230)
stage_rfl Ssm.warmB61 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s230 (Ssm.s230.stack.length - 3) r) Ssm.S230 = some (tplN Ssm.s231 (Ssm.s231.stack.length - 3) r, Ssm.S231)
stage_rfl Ssm.warmB62 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s231 (Ssm.s231.stack.length - 3) r) Ssm.S231 = some (tplN Ssm.s232 (Ssm.s232.stack.length - 3) r, Ssm.S232)
stage_rfl Ssm.warmB63 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s232 (Ssm.s232.stack.length - 3) r) Ssm.S232 = some (tplN Ssm.s233 (Ssm.s233.stack.length - 3) r, Ssm.S233)
stage_rfl Ssm.warmB64 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s233 (Ssm.s233.stack.length - 3) r) Ssm.S233 = some (tplN Ssm.s234 (Ssm.s234.stack.length - 3) r, Ssm.S234)
stage_rfl Ssm.warmB65 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s234 (Ssm.s234.stack.length - 3) r) Ssm.S234 = some (tplN Ssm.s235 (Ssm.s235.stack.length - 3) r, Ssm.S235)
stage_rfl Ssm.warmB66 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s235 (Ssm.s235.stack.length - 3) r) Ssm.S235 = some (tplN Ssm.s236 (Ssm.s236.stack.length - 3) r, Ssm.S236)
stage_rfl Ssm.warmB67 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s236 (Ssm.s236.stack.length - 3) r) Ssm.S236 = some (tplN Ssm.s237 (Ssm.s237.stack.length - 3) r, Ssm.S237)
stage_rfl Ssm.warmB68 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s237 (Ssm.s237.stack.length - 3) r) Ssm.S237 = some (tplN Ssm.s238 (Ssm.s238.stack.length - 3) r, Ssm.S238)
stage_rfl Ssm.warmB69 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s238 (Ssm.s238.stack.length - 3) r) Ssm.S238 = some (tplN Ssm.s239 (Ssm.s239.stack.length - 3) r, Ssm.S239)
stage_rfl Ssm.warmB70 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Ssm.s239 (Ssm.s239.stack.length - 3) r) Ssm.S239 = some (tplN Ssm.s240 (Ssm.s240.stack.length - 3) r, Ssm.S240)
stage_rfl Ssm.warmB71 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 80 (tplN Ssm.s240 (Ssm.s240.stack.length - 3) r) Ssm.S240 = some (tplN Ssm.s241 1 r, Ssm.S241)
stage_rfl Ssm.warmLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Ssm.s241 1 r)).run Ssm.S241 = some (tplN Ssm.s242 0 r, Ssm.S242)
kernel_rfl Ssm.warmLive : isHalt Ssm.s241.ctl = false
kernel_rfl Ssm.warmFrames : Ssm.s242.stack = Ssm.s169.stack

/-- Stage `Ssm.warm` under every caller stack. -/
theorem Ssm.warm (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 7181 (tplN Ssm.s169 0 r) Ssm.S169 = some (tplN Ssm.s242 0 r, Ssm.S242) :=
  runS_snoc _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (Ssm.warmB0 r) (Ssm.warmB1 r)) (Ssm.warmB2 r)) (Ssm.warmB3 r)) (Ssm.warmB4 r)) (Ssm.warmB5 r)) (Ssm.warmB6 r)) (Ssm.warmB7 r)) (Ssm.warmB8 r)) (Ssm.warmB9 r)) (Ssm.warmB10 r)) (Ssm.warmB11 r)) (Ssm.warmB12 r)) (Ssm.warmB13 r)) (Ssm.warmB14 r)) (Ssm.warmB15 r)) (Ssm.warmB16 r)) (Ssm.warmB17 r)) (Ssm.warmB18 r)) (Ssm.warmB19 r)) (Ssm.warmB20 r)) (Ssm.warmB21 r)) (Ssm.warmB22 r)) (Ssm.warmB23 r)) (Ssm.warmB24 r)) (Ssm.warmB25 r)) (Ssm.warmB26 r)) (Ssm.warmB27 r)) (Ssm.warmB28 r)) (Ssm.warmB29 r)) (Ssm.warmB30 r)) (Ssm.warmB31 r)) (Ssm.warmB32 r)) (Ssm.warmB33 r)) (Ssm.warmB34 r)) (Ssm.warmB35 r)) (Ssm.warmB36 r)) (Ssm.warmB37 r)) (Ssm.warmB38 r)) (Ssm.warmB39 r)) (Ssm.warmB40 r)) (Ssm.warmB41 r)) (Ssm.warmB42 r)) (Ssm.warmB43 r)) (Ssm.warmB44 r)) (Ssm.warmB45 r)) (Ssm.warmB46 r)) (Ssm.warmB47 r)) (Ssm.warmB48 r)) (Ssm.warmB49 r)) (Ssm.warmB50 r)) (Ssm.warmB51 r)) (Ssm.warmB52 r)) (Ssm.warmB53 r)) (Ssm.warmB54 r)) (Ssm.warmB55 r)) (Ssm.warmB56 r)) (Ssm.warmB57 r)) (Ssm.warmB58 r)) (Ssm.warmB59 r)) (Ssm.warmB60 r)) (Ssm.warmB61 r)) (Ssm.warmB62 r)) (Ssm.warmB63 r)) (Ssm.warmB64 r)) (Ssm.warmB65 r)) (Ssm.warmB66 r)) (Ssm.warmB67 r)) (Ssm.warmB68 r)) (Ssm.warmB69 r)) (Ssm.warmB70 r)) (Ssm.warmB71 r)) Ssm.warmLive (Ssm.warmLast r)

/-- Stage `Ssm.warm` at the driver's own frames. -/
theorem Ssm.warmAt : runS Host.Mlx.Ffi.ffi 7181 Ssm.s169 Ssm.S169 = some (Ssm.s242, Ssm.S242) := by
  have h := Ssm.warm Ssm.s169.stack
  rwa [show tplN Ssm.s169 0 Ssm.s169.stack = Ssm.s169 from tplN_self Ssm.s169 0,
    show tplN Ssm.s242 0 Ssm.s169.stack = Ssm.s242 by rw [← Ssm.warmFrames]; exact tplN_self Ssm.s242 0] at h

kernel_rfl Ssm.evalD : Ssm.s244.stack.length = 3
stage_rfl Ssm.evalB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 991 (tplN Ssm.s243 0 r) Ssm.S243 = some (tplN Ssm.s244 1 r, Ssm.S244)
stage_rfl Ssm.evalLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Ssm.s244 1 r)).run Ssm.S244 = some (tplN Ssm.s245 0 r, Ssm.S245)
kernel_rfl Ssm.evalLive : isHalt Ssm.s244.ctl = false
kernel_rfl Ssm.evalFrames : Ssm.s245.stack = Ssm.s243.stack

/-- Stage `Ssm.eval` under every caller stack. -/
theorem Ssm.eval (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 992 (tplN Ssm.s243 0 r) Ssm.S243 = some (tplN Ssm.s245 0 r, Ssm.S245) :=
  runS_snoc _ (Ssm.evalB0 r) Ssm.evalLive (Ssm.evalLast r)

/-- Stage `Ssm.eval` at the driver's own frames. -/
theorem Ssm.evalAt : runS Host.Mlx.Ffi.ffi 992 Ssm.s243 Ssm.S243 = some (Ssm.s245, Ssm.S245) := by
  have h := Ssm.eval Ssm.s243.stack
  rwa [show tplN Ssm.s243 0 Ssm.s243.stack = Ssm.s243 from tplN_self Ssm.s243 0,
    show tplN Ssm.s245 0 Ssm.s243.stack = Ssm.s245 by rw [← Ssm.evalFrames]; exact tplN_self Ssm.s245 0] at h

host_chunk Ssm 0
host_chunk Ssm 1
host_chunk Ssm 2
host_chunk Ssm 3
host_chunk Ssm 168
host_chunk Ssm 242
host_chunk Ssm 245

/-- **The driver's run** from its stages and its own steps. -/
theorem Ssm.drive : runS Host.Mlx.Ffi.ffi 37890 Ssm.s0 Ssm.S0 = some (Ssm.s246, Ssm.S246) := by
  have h := (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ Ssm.c0 Ssm.c1) Ssm.c2) Ssm.c3) Ssm.coldAt) Ssm.c168) Ssm.warmAt) Ssm.c242) Ssm.evalAt) Ssm.c245)
  exact h

end Host.Ts.Sim.Stage.Ssm
