import host.sim.stage.Under
import host.ts.tests.KvSrc
import host.ts.tests.decode.Stand
import host.mlx.FfiExpr
import host.ts.ast.inference.sampling.Step
import host.ts.ast.inference.sampling.Curve
import host.ts.ast.inference.sampling.Extras
import host.ts.ast.inference.sampling.Filters
import host.ts.ast.inference.sampling.Hlg
import host.ts.ast.inference.sampling.Processors
import host.ts.ast.inference.sampling.Sampler
import host.ts.ast.inference.sampling.Types
import host.ts.ast.inference.sampling.WindowFilters
import host.ts.ast.inference.kernels.sampling.NormalizedArgmax
import host.ts.ast.inference.runtime.Config
import host.ts.ast.mlx.Compile
import host.ts.ast.mlx.MetalKernel
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.Sample
open Host.Ts Host.Ts.Sim.Stage

/-! # The sample stage's templates: `sample`, `asyncEvalAll`, the readback

Over the MLX FFI model, the driver makes the route's step sampler (`makeStepSampler`,
sampling/step.ts:37-337, as generation/autoregressive.ts:158-164 makes it: greedy, device tokens, manual
history, no logprob capture) and runs the decode loop's sample, dispatch and readback twice on bf16
logits `[1, 1, 248320]`: `sampler.sample(logits, step)` (the `sampleStep` closure's call,
autoregressive.ts:225-231 → step.ts:305-309 → `sampleDevice` :114-183 → `normalizedArgmax`,
kernels/sampling/normalized-argmax.ts), `ops.asyncEvalAll([token])` (autoregressive.ts:543/667) and
`ops.itemUint32(token)` (autoregressive.ts:574/673, the readback). The readback values are the FFI
model's queued tokens, the table entries `var 0`, `var 1` (symbolic). `sampling/types.ts` and
`sampling/sampler.ts` are the route's stand-ins (`host.ts.tests.decode.Stand`: Bun-erased interfaces;
`makeSampler`'s greedy branch, which a greedy sampler without metadata never calls).

The first `sample` is cold: it fills the kernel and compiled-closure memos (normalized-argmax.ts
`partial`, `finish`, `compiled`) and traces the compiled closure (a `JSCallback`); the second is
warm: it replays the traced graph. They are two stage classes (`cold`, `warm`). The chain's states:
`s1`/`s69` cold call/return, `s70`/`s72` dispatch, `s73`/`s75` readback, `s76`/`s78` warm call/return,
`s79`/`s81` dispatch, `s82`/`s84` readback (the cold call in 100-step chunks). Each stage is checked with the caller frames free; `drive`
composes the driver's run from the six stages and the driver's own steps between them. -/

namespace Drive
def source : String := "import { makeStepSampler } from \"./sampling/step\";
import * as ops from \"@mlx-bun/mlx/ops\";
const sampler = makeStepSampler({}, { tokenRepresentation: \"device\", grammarWait: \"external\", historyUpdate: \"manual\", captureSelectedLogprob: false, captureTopLogprobs: 0 });
const logits0 = ops.zeros([1, 1, 248320], 12);
const s0 = sampler.sample(logits0, 0);
ops.asyncEvalAll([s0.token]);
const t0 = ops.itemUint32(s0.token);
const logits1 = ops.zeros([1, 1, 248320], 12);
const s1 = sampler.sample(logits1, 1);
ops.asyncEvalAll([s1.token]);
const t1 = ops.itemUint32(s1.token);
export const out = [t0, t1];"
source_parse source
source_ast
end Drive


def p (path : String) (m : Module) : UMod := ⟨path.toList, m⟩
def mods : List UMod :=
  [p "packages/mlx/src/ffi.ts" Sources.Mlx.Ffi.ast, p "packages/mlx/src/array.ts" Sources.Mlx.Array.ast,
   p "packages/mlx/src/ops.ts" Sources.Mlx.Ops.ast, p "packages/mlx/src/native.ts" Tests.MlxNative.ast,
   p "packages/mlx/src/command-buffers.ts" Tests.MlxCommandBuffers.ast, p "packages/mlx/src/host-buffer.ts" Tests.MlxHostBuffer.ast,
   p "packages/mlx/src/compile.ts" Sources.Mlx.Compile.ast, p "packages/mlx/src/metal-kernel.ts" Sources.Mlx.MetalKernel.ast,
   p "packages/inference/src/kernels/sampling/normalized-argmax.ts" Sources.Inference.Kernels.Sampling.NormalizedArgmax.ast,
   p "packages/inference/src/runtime/config.ts" Sources.Inference.Runtime.Config.ast,
   p "packages/inference/src/sampling/curve.ts" Sources.Inference.Sampling.Curve.ast,
   p "packages/inference/src/sampling/extras.ts" Sources.Inference.Sampling.Extras.ast,
   p "packages/inference/src/sampling/filters.ts" Sources.Inference.Sampling.Filters.ast,
   p "packages/inference/src/sampling/hlg.ts" Sources.Inference.Sampling.Hlg.ast,
   p "packages/inference/src/sampling/processors.ts" Sources.Inference.Sampling.Processors.ast,
   p "packages/inference/src/sampling/sampler.ts" Tests.Decode.StandInferenceSamplingSampler.ast,
   p "packages/inference/src/sampling/step.ts" Sources.Inference.Sampling.Step.ast,
   p "packages/inference/src/sampling/types.ts" Tests.Decode.StandInferenceSamplingTypes.ast,
   p "packages/inference/src/sampling/window-filters.ts" Sources.Inference.Sampling.WindowFilters.ast,
   p "packages/inference/src/__sample.ts" Drive.ast]


def bootS : Option (St Host.Mlx.Ffi.ffi.S) :=
  boot (Host.Mlx.Ffi.init [.ref 0, .ref 1] [] chars!"applegpu_g13s" []) mods [bunFfi, asyncHooks, Tests.Decode.processMod] chars!"packages/inference/src/__sample.ts"

/-- The readback values: tokens `t0`, `t1` (table entries `0`, `1`). -/
def ρtok (t0 t1 : Nat) : Nat → F64 := fun i => if i = 0 then F64.ofNat t0 else F64.ofNat t1

set_option maxHeartbeats 0 in
host_chain_sym Smp : Host.Mlx.Ffi.ffi, bootS, [.var 0, .var 1], ρtok 100 101, 20000, [4692, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 61, 1, 15, 184, 1, 10, 123, 1, 225, 1325, 1, 15, 184, 1, 10, 123, 1, 16]

kernel_rfl Smp.coldD : Smp.s68.stack.length = 4
stage_rfl Smp.coldB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s1 0 r) Smp.S1 = some (tplN Smp.s2 (Smp.s2.stack.length - 3) r, Smp.S2)
stage_rfl Smp.coldB1 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s2 (Smp.s2.stack.length - 3) r) Smp.S2 = some (tplN Smp.s3 (Smp.s3.stack.length - 3) r, Smp.S3)
stage_rfl Smp.coldB2 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s3 (Smp.s3.stack.length - 3) r) Smp.S3 = some (tplN Smp.s4 (Smp.s4.stack.length - 3) r, Smp.S4)
stage_rfl Smp.coldB3 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s4 (Smp.s4.stack.length - 3) r) Smp.S4 = some (tplN Smp.s5 (Smp.s5.stack.length - 3) r, Smp.S5)
stage_rfl Smp.coldB4 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s5 (Smp.s5.stack.length - 3) r) Smp.S5 = some (tplN Smp.s6 (Smp.s6.stack.length - 3) r, Smp.S6)
stage_rfl Smp.coldB5 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s6 (Smp.s6.stack.length - 3) r) Smp.S6 = some (tplN Smp.s7 (Smp.s7.stack.length - 3) r, Smp.S7)
stage_rfl Smp.coldB6 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s7 (Smp.s7.stack.length - 3) r) Smp.S7 = some (tplN Smp.s8 (Smp.s8.stack.length - 3) r, Smp.S8)
stage_rfl Smp.coldB7 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s8 (Smp.s8.stack.length - 3) r) Smp.S8 = some (tplN Smp.s9 (Smp.s9.stack.length - 3) r, Smp.S9)
stage_rfl Smp.coldB8 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s9 (Smp.s9.stack.length - 3) r) Smp.S9 = some (tplN Smp.s10 (Smp.s10.stack.length - 3) r, Smp.S10)
stage_rfl Smp.coldB9 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s10 (Smp.s10.stack.length - 3) r) Smp.S10 = some (tplN Smp.s11 (Smp.s11.stack.length - 3) r, Smp.S11)
stage_rfl Smp.coldB10 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s11 (Smp.s11.stack.length - 3) r) Smp.S11 = some (tplN Smp.s12 (Smp.s12.stack.length - 3) r, Smp.S12)
stage_rfl Smp.coldB11 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s12 (Smp.s12.stack.length - 3) r) Smp.S12 = some (tplN Smp.s13 (Smp.s13.stack.length - 3) r, Smp.S13)
stage_rfl Smp.coldB12 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s13 (Smp.s13.stack.length - 3) r) Smp.S13 = some (tplN Smp.s14 (Smp.s14.stack.length - 3) r, Smp.S14)
stage_rfl Smp.coldB13 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s14 (Smp.s14.stack.length - 3) r) Smp.S14 = some (tplN Smp.s15 (Smp.s15.stack.length - 3) r, Smp.S15)
stage_rfl Smp.coldB14 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s15 (Smp.s15.stack.length - 3) r) Smp.S15 = some (tplN Smp.s16 (Smp.s16.stack.length - 3) r, Smp.S16)
stage_rfl Smp.coldB15 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s16 (Smp.s16.stack.length - 3) r) Smp.S16 = some (tplN Smp.s17 (Smp.s17.stack.length - 3) r, Smp.S17)
stage_rfl Smp.coldB16 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s17 (Smp.s17.stack.length - 3) r) Smp.S17 = some (tplN Smp.s18 (Smp.s18.stack.length - 3) r, Smp.S18)
stage_rfl Smp.coldB17 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s18 (Smp.s18.stack.length - 3) r) Smp.S18 = some (tplN Smp.s19 (Smp.s19.stack.length - 3) r, Smp.S19)
stage_rfl Smp.coldB18 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s19 (Smp.s19.stack.length - 3) r) Smp.S19 = some (tplN Smp.s20 (Smp.s20.stack.length - 3) r, Smp.S20)
stage_rfl Smp.coldB19 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s20 (Smp.s20.stack.length - 3) r) Smp.S20 = some (tplN Smp.s21 (Smp.s21.stack.length - 3) r, Smp.S21)
stage_rfl Smp.coldB20 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s21 (Smp.s21.stack.length - 3) r) Smp.S21 = some (tplN Smp.s22 (Smp.s22.stack.length - 3) r, Smp.S22)
stage_rfl Smp.coldB21 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s22 (Smp.s22.stack.length - 3) r) Smp.S22 = some (tplN Smp.s23 (Smp.s23.stack.length - 3) r, Smp.S23)
stage_rfl Smp.coldB22 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s23 (Smp.s23.stack.length - 3) r) Smp.S23 = some (tplN Smp.s24 (Smp.s24.stack.length - 3) r, Smp.S24)
stage_rfl Smp.coldB23 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s24 (Smp.s24.stack.length - 3) r) Smp.S24 = some (tplN Smp.s25 (Smp.s25.stack.length - 3) r, Smp.S25)
stage_rfl Smp.coldB24 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s25 (Smp.s25.stack.length - 3) r) Smp.S25 = some (tplN Smp.s26 (Smp.s26.stack.length - 3) r, Smp.S26)
stage_rfl Smp.coldB25 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s26 (Smp.s26.stack.length - 3) r) Smp.S26 = some (tplN Smp.s27 (Smp.s27.stack.length - 3) r, Smp.S27)
stage_rfl Smp.coldB26 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s27 (Smp.s27.stack.length - 3) r) Smp.S27 = some (tplN Smp.s28 (Smp.s28.stack.length - 3) r, Smp.S28)
stage_rfl Smp.coldB27 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s28 (Smp.s28.stack.length - 3) r) Smp.S28 = some (tplN Smp.s29 (Smp.s29.stack.length - 3) r, Smp.S29)
stage_rfl Smp.coldB28 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s29 (Smp.s29.stack.length - 3) r) Smp.S29 = some (tplN Smp.s30 (Smp.s30.stack.length - 3) r, Smp.S30)
stage_rfl Smp.coldB29 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s30 (Smp.s30.stack.length - 3) r) Smp.S30 = some (tplN Smp.s31 (Smp.s31.stack.length - 3) r, Smp.S31)
stage_rfl Smp.coldB30 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s31 (Smp.s31.stack.length - 3) r) Smp.S31 = some (tplN Smp.s32 (Smp.s32.stack.length - 3) r, Smp.S32)
stage_rfl Smp.coldB31 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s32 (Smp.s32.stack.length - 3) r) Smp.S32 = some (tplN Smp.s33 (Smp.s33.stack.length - 3) r, Smp.S33)
stage_rfl Smp.coldB32 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s33 (Smp.s33.stack.length - 3) r) Smp.S33 = some (tplN Smp.s34 (Smp.s34.stack.length - 3) r, Smp.S34)
stage_rfl Smp.coldB33 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s34 (Smp.s34.stack.length - 3) r) Smp.S34 = some (tplN Smp.s35 (Smp.s35.stack.length - 3) r, Smp.S35)
stage_rfl Smp.coldB34 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s35 (Smp.s35.stack.length - 3) r) Smp.S35 = some (tplN Smp.s36 (Smp.s36.stack.length - 3) r, Smp.S36)
stage_rfl Smp.coldB35 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s36 (Smp.s36.stack.length - 3) r) Smp.S36 = some (tplN Smp.s37 (Smp.s37.stack.length - 3) r, Smp.S37)
stage_rfl Smp.coldB36 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s37 (Smp.s37.stack.length - 3) r) Smp.S37 = some (tplN Smp.s38 (Smp.s38.stack.length - 3) r, Smp.S38)
stage_rfl Smp.coldB37 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s38 (Smp.s38.stack.length - 3) r) Smp.S38 = some (tplN Smp.s39 (Smp.s39.stack.length - 3) r, Smp.S39)
stage_rfl Smp.coldB38 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s39 (Smp.s39.stack.length - 3) r) Smp.S39 = some (tplN Smp.s40 (Smp.s40.stack.length - 3) r, Smp.S40)
stage_rfl Smp.coldB39 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s40 (Smp.s40.stack.length - 3) r) Smp.S40 = some (tplN Smp.s41 (Smp.s41.stack.length - 3) r, Smp.S41)
stage_rfl Smp.coldB40 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s41 (Smp.s41.stack.length - 3) r) Smp.S41 = some (tplN Smp.s42 (Smp.s42.stack.length - 3) r, Smp.S42)
stage_rfl Smp.coldB41 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s42 (Smp.s42.stack.length - 3) r) Smp.S42 = some (tplN Smp.s43 (Smp.s43.stack.length - 3) r, Smp.S43)
stage_rfl Smp.coldB42 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s43 (Smp.s43.stack.length - 3) r) Smp.S43 = some (tplN Smp.s44 (Smp.s44.stack.length - 3) r, Smp.S44)
stage_rfl Smp.coldB43 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s44 (Smp.s44.stack.length - 3) r) Smp.S44 = some (tplN Smp.s45 (Smp.s45.stack.length - 3) r, Smp.S45)
stage_rfl Smp.coldB44 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s45 (Smp.s45.stack.length - 3) r) Smp.S45 = some (tplN Smp.s46 (Smp.s46.stack.length - 3) r, Smp.S46)
stage_rfl Smp.coldB45 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s46 (Smp.s46.stack.length - 3) r) Smp.S46 = some (tplN Smp.s47 (Smp.s47.stack.length - 3) r, Smp.S47)
stage_rfl Smp.coldB46 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s47 (Smp.s47.stack.length - 3) r) Smp.S47 = some (tplN Smp.s48 (Smp.s48.stack.length - 3) r, Smp.S48)
stage_rfl Smp.coldB47 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s48 (Smp.s48.stack.length - 3) r) Smp.S48 = some (tplN Smp.s49 (Smp.s49.stack.length - 3) r, Smp.S49)
stage_rfl Smp.coldB48 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s49 (Smp.s49.stack.length - 3) r) Smp.S49 = some (tplN Smp.s50 (Smp.s50.stack.length - 3) r, Smp.S50)
stage_rfl Smp.coldB49 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s50 (Smp.s50.stack.length - 3) r) Smp.S50 = some (tplN Smp.s51 (Smp.s51.stack.length - 3) r, Smp.S51)
stage_rfl Smp.coldB50 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s51 (Smp.s51.stack.length - 3) r) Smp.S51 = some (tplN Smp.s52 (Smp.s52.stack.length - 3) r, Smp.S52)
stage_rfl Smp.coldB51 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s52 (Smp.s52.stack.length - 3) r) Smp.S52 = some (tplN Smp.s53 (Smp.s53.stack.length - 3) r, Smp.S53)
stage_rfl Smp.coldB52 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s53 (Smp.s53.stack.length - 3) r) Smp.S53 = some (tplN Smp.s54 (Smp.s54.stack.length - 3) r, Smp.S54)
stage_rfl Smp.coldB53 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s54 (Smp.s54.stack.length - 3) r) Smp.S54 = some (tplN Smp.s55 (Smp.s55.stack.length - 3) r, Smp.S55)
stage_rfl Smp.coldB54 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s55 (Smp.s55.stack.length - 3) r) Smp.S55 = some (tplN Smp.s56 (Smp.s56.stack.length - 3) r, Smp.S56)
stage_rfl Smp.coldB55 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s56 (Smp.s56.stack.length - 3) r) Smp.S56 = some (tplN Smp.s57 (Smp.s57.stack.length - 3) r, Smp.S57)
stage_rfl Smp.coldB56 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s57 (Smp.s57.stack.length - 3) r) Smp.S57 = some (tplN Smp.s58 (Smp.s58.stack.length - 3) r, Smp.S58)
stage_rfl Smp.coldB57 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s58 (Smp.s58.stack.length - 3) r) Smp.S58 = some (tplN Smp.s59 (Smp.s59.stack.length - 3) r, Smp.S59)
stage_rfl Smp.coldB58 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s59 (Smp.s59.stack.length - 3) r) Smp.S59 = some (tplN Smp.s60 (Smp.s60.stack.length - 3) r, Smp.S60)
stage_rfl Smp.coldB59 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s60 (Smp.s60.stack.length - 3) r) Smp.S60 = some (tplN Smp.s61 (Smp.s61.stack.length - 3) r, Smp.S61)
stage_rfl Smp.coldB60 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s61 (Smp.s61.stack.length - 3) r) Smp.S61 = some (tplN Smp.s62 (Smp.s62.stack.length - 3) r, Smp.S62)
stage_rfl Smp.coldB61 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s62 (Smp.s62.stack.length - 3) r) Smp.S62 = some (tplN Smp.s63 (Smp.s63.stack.length - 3) r, Smp.S63)
stage_rfl Smp.coldB62 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s63 (Smp.s63.stack.length - 3) r) Smp.S63 = some (tplN Smp.s64 (Smp.s64.stack.length - 3) r, Smp.S64)
stage_rfl Smp.coldB63 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s64 (Smp.s64.stack.length - 3) r) Smp.S64 = some (tplN Smp.s65 (Smp.s65.stack.length - 3) r, Smp.S65)
stage_rfl Smp.coldB64 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s65 (Smp.s65.stack.length - 3) r) Smp.S65 = some (tplN Smp.s66 (Smp.s66.stack.length - 3) r, Smp.S66)
stage_rfl Smp.coldB65 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 100 (tplN Smp.s66 (Smp.s66.stack.length - 3) r) Smp.S66 = some (tplN Smp.s67 (Smp.s67.stack.length - 3) r, Smp.S67)
stage_rfl Smp.coldB66 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 61 (tplN Smp.s67 (Smp.s67.stack.length - 3) r) Smp.S67 = some (tplN Smp.s68 1 r, Smp.S68)
stage_rfl Smp.coldLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s68 1 r)).run Smp.S68 = some (tplN Smp.s69 0 r, Smp.S69)
kernel_rfl Smp.coldLive : isHalt Smp.s68.ctl = false
kernel_rfl Smp.coldFrames : Smp.s69.stack = Smp.s1.stack

/-- Stage `cold` under every caller stack. -/
theorem Smp.cold (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 6662 (tplN Smp.s1 0 r) Smp.S1 = some (tplN Smp.s69 0 r, Smp.S69) :=
  runS_snoc _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (Smp.coldB0 r) (Smp.coldB1 r)) (Smp.coldB2 r)) (Smp.coldB3 r)) (Smp.coldB4 r)) (Smp.coldB5 r)) (Smp.coldB6 r)) (Smp.coldB7 r)) (Smp.coldB8 r)) (Smp.coldB9 r)) (Smp.coldB10 r)) (Smp.coldB11 r)) (Smp.coldB12 r)) (Smp.coldB13 r)) (Smp.coldB14 r)) (Smp.coldB15 r)) (Smp.coldB16 r)) (Smp.coldB17 r)) (Smp.coldB18 r)) (Smp.coldB19 r)) (Smp.coldB20 r)) (Smp.coldB21 r)) (Smp.coldB22 r)) (Smp.coldB23 r)) (Smp.coldB24 r)) (Smp.coldB25 r)) (Smp.coldB26 r)) (Smp.coldB27 r)) (Smp.coldB28 r)) (Smp.coldB29 r)) (Smp.coldB30 r)) (Smp.coldB31 r)) (Smp.coldB32 r)) (Smp.coldB33 r)) (Smp.coldB34 r)) (Smp.coldB35 r)) (Smp.coldB36 r)) (Smp.coldB37 r)) (Smp.coldB38 r)) (Smp.coldB39 r)) (Smp.coldB40 r)) (Smp.coldB41 r)) (Smp.coldB42 r)) (Smp.coldB43 r)) (Smp.coldB44 r)) (Smp.coldB45 r)) (Smp.coldB46 r)) (Smp.coldB47 r)) (Smp.coldB48 r)) (Smp.coldB49 r)) (Smp.coldB50 r)) (Smp.coldB51 r)) (Smp.coldB52 r)) (Smp.coldB53 r)) (Smp.coldB54 r)) (Smp.coldB55 r)) (Smp.coldB56 r)) (Smp.coldB57 r)) (Smp.coldB58 r)) (Smp.coldB59 r)) (Smp.coldB60 r)) (Smp.coldB61 r)) (Smp.coldB62 r)) (Smp.coldB63 r)) (Smp.coldB64 r)) (Smp.coldB65 r)) (Smp.coldB66 r)) Smp.coldLive (Smp.coldLast r)

/-- Stage `cold` at the driver's own frames. -/
theorem Smp.coldAt : runS Host.Mlx.Ffi.ffi 6662 Smp.s1 Smp.S1 = some (Smp.s69, Smp.S69) := by
  have h := Smp.cold Smp.s1.stack
  rwa [show tplN Smp.s1 0 Smp.s1.stack = Smp.s1 from tplN_self Smp.s1 0,
    show tplN Smp.s69 0 Smp.s1.stack = Smp.s69 by rw [← Smp.coldFrames]; exact tplN_self Smp.s69 0] at h

kernel_rfl Smp.dispatch0D : Smp.s71.stack.length = 3
stage_rfl Smp.dispatch0B0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 184 (tplN Smp.s70 0 r) Smp.S70 = some (tplN Smp.s71 1 r, Smp.S71)
stage_rfl Smp.dispatch0Last : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s71 1 r)).run Smp.S71 = some (tplN Smp.s72 0 r, Smp.S72)
kernel_rfl Smp.dispatch0Live : isHalt Smp.s71.ctl = false
kernel_rfl Smp.dispatch0Frames : Smp.s72.stack = Smp.s70.stack

/-- Stage `dispatch0` under every caller stack. -/
theorem Smp.dispatch0 (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 185 (tplN Smp.s70 0 r) Smp.S70 = some (tplN Smp.s72 0 r, Smp.S72) :=
  runS_snoc _ (Smp.dispatch0B0 r) Smp.dispatch0Live (Smp.dispatch0Last r)

/-- Stage `dispatch0` at the driver's own frames. -/
theorem Smp.dispatch0At : runS Host.Mlx.Ffi.ffi 185 Smp.s70 Smp.S70 = some (Smp.s72, Smp.S72) := by
  have h := Smp.dispatch0 Smp.s70.stack
  rwa [show tplN Smp.s70 0 Smp.s70.stack = Smp.s70 from tplN_self Smp.s70 0,
    show tplN Smp.s72 0 Smp.s70.stack = Smp.s72 by rw [← Smp.dispatch0Frames]; exact tplN_self Smp.s72 0] at h

kernel_rfl Smp.readback0D : Smp.s74.stack.length = 4
stage_rfl Smp.readback0B0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 123 (tplN Smp.s73 0 r) Smp.S73 = some (tplN Smp.s74 1 r, Smp.S74)
stage_rfl Smp.readback0Last : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s74 1 r)).run Smp.S74 = some (tplN Smp.s75 0 r, Smp.S75)
kernel_rfl Smp.readback0Live : isHalt Smp.s74.ctl = false
kernel_rfl Smp.readback0Frames : Smp.s75.stack = Smp.s73.stack

/-- Stage `readback0` under every caller stack. -/
theorem Smp.readback0 (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 124 (tplN Smp.s73 0 r) Smp.S73 = some (tplN Smp.s75 0 r, Smp.S75) :=
  runS_snoc _ (Smp.readback0B0 r) Smp.readback0Live (Smp.readback0Last r)

/-- Stage `readback0` at the driver's own frames. -/
theorem Smp.readback0At : runS Host.Mlx.Ffi.ffi 124 Smp.s73 Smp.S73 = some (Smp.s75, Smp.S75) := by
  have h := Smp.readback0 Smp.s73.stack
  rwa [show tplN Smp.s73 0 Smp.s73.stack = Smp.s73 from tplN_self Smp.s73 0,
    show tplN Smp.s75 0 Smp.s73.stack = Smp.s75 by rw [← Smp.readback0Frames]; exact tplN_self Smp.s75 0] at h

kernel_rfl Smp.warmD : Smp.s77.stack.length = 4
stage_rfl Smp.warmB0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 1325 (tplN Smp.s76 0 r) Smp.S76 = some (tplN Smp.s77 1 r, Smp.S77)
stage_rfl Smp.warmLast : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s77 1 r)).run Smp.S77 = some (tplN Smp.s78 0 r, Smp.S78)
kernel_rfl Smp.warmLive : isHalt Smp.s77.ctl = false
kernel_rfl Smp.warmFrames : Smp.s78.stack = Smp.s76.stack

/-- Stage `warm` under every caller stack. -/
theorem Smp.warm (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 1326 (tplN Smp.s76 0 r) Smp.S76 = some (tplN Smp.s78 0 r, Smp.S78) :=
  runS_snoc _ (Smp.warmB0 r) Smp.warmLive (Smp.warmLast r)

/-- Stage `warm` at the driver's own frames. -/
theorem Smp.warmAt : runS Host.Mlx.Ffi.ffi 1326 Smp.s76 Smp.S76 = some (Smp.s78, Smp.S78) := by
  have h := Smp.warm Smp.s76.stack
  rwa [show tplN Smp.s76 0 Smp.s76.stack = Smp.s76 from tplN_self Smp.s76 0,
    show tplN Smp.s78 0 Smp.s76.stack = Smp.s78 by rw [← Smp.warmFrames]; exact tplN_self Smp.s78 0] at h

kernel_rfl Smp.dispatch1D : Smp.s80.stack.length = 3
stage_rfl Smp.dispatch1B0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 184 (tplN Smp.s79 0 r) Smp.S79 = some (tplN Smp.s80 1 r, Smp.S80)
stage_rfl Smp.dispatch1Last : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s80 1 r)).run Smp.S80 = some (tplN Smp.s81 0 r, Smp.S81)
kernel_rfl Smp.dispatch1Live : isHalt Smp.s80.ctl = false
kernel_rfl Smp.dispatch1Frames : Smp.s81.stack = Smp.s79.stack

/-- Stage `dispatch1` under every caller stack. -/
theorem Smp.dispatch1 (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 185 (tplN Smp.s79 0 r) Smp.S79 = some (tplN Smp.s81 0 r, Smp.S81) :=
  runS_snoc _ (Smp.dispatch1B0 r) Smp.dispatch1Live (Smp.dispatch1Last r)

/-- Stage `dispatch1` at the driver's own frames. -/
theorem Smp.dispatch1At : runS Host.Mlx.Ffi.ffi 185 Smp.s79 Smp.S79 = some (Smp.s81, Smp.S81) := by
  have h := Smp.dispatch1 Smp.s79.stack
  rwa [show tplN Smp.s79 0 Smp.s79.stack = Smp.s79 from tplN_self Smp.s79 0,
    show tplN Smp.s81 0 Smp.s79.stack = Smp.s81 by rw [← Smp.dispatch1Frames]; exact tplN_self Smp.s81 0] at h

kernel_rfl Smp.readback1D : Smp.s83.stack.length = 4
stage_rfl Smp.readback1B0 : ∀ r : List Frame,
  runS Host.Mlx.Ffi.ffi 123 (tplN Smp.s82 0 r) Smp.S82 = some (tplN Smp.s83 1 r, Smp.S83)
stage_rfl Smp.readback1Last : ∀ r : List Frame,
  interpS (step Host.Mlx.Ffi.ffi (tplN Smp.s83 1 r)).run Smp.S83 = some (tplN Smp.s84 0 r, Smp.S84)
kernel_rfl Smp.readback1Live : isHalt Smp.s83.ctl = false
kernel_rfl Smp.readback1Frames : Smp.s84.stack = Smp.s82.stack

/-- Stage `readback1` under every caller stack. -/
theorem Smp.readback1 (r : List Frame) :
    runS Host.Mlx.Ffi.ffi 124 (tplN Smp.s82 0 r) Smp.S82 = some (tplN Smp.s84 0 r, Smp.S84) :=
  runS_snoc _ (Smp.readback1B0 r) Smp.readback1Live (Smp.readback1Last r)

/-- Stage `readback1` at the driver's own frames. -/
theorem Smp.readback1At : runS Host.Mlx.Ffi.ffi 124 Smp.s82 Smp.S82 = some (Smp.s84, Smp.S84) := by
  have h := Smp.readback1 Smp.s82.stack
  rwa [show tplN Smp.s82 0 Smp.s82.stack = Smp.s82 from tplN_self Smp.s82 0,
    show tplN Smp.s84 0 Smp.s82.stack = Smp.s84 by rw [← Smp.readback1Frames]; exact tplN_self Smp.s84 0] at h

host_chunk Smp 0
host_chunk Smp 69
host_chunk Smp 72
host_chunk Smp 75
host_chunk Smp 78
host_chunk Smp 81
host_chunk Smp 84

/-- **The driver's run**: its prefix, the six stages under the driver's frames, the driver's steps between. -/
theorem Smp.drive : runS Host.Mlx.Ffi.ffi 13589 Smp.s0 Smp.S0 = some (Smp.s85, Smp.S85) := by
  have h := runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _
    (runS_trans _ (runS_trans _ (runS_trans _ (runS_trans _ Smp.c0 Smp.coldAt) Smp.c69) Smp.dispatch0At) Smp.c72)
    Smp.readback0At) Smp.c75) Smp.warmAt) Smp.c78) Smp.dispatch1At) Smp.c81) Smp.readback1At) Smp.c84
  exact h

end Host.Ts.Sim.Stage.Sample
