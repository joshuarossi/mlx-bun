import host.sim.compose.a4b.GraphColdOneCaches
import host.sim.compose.a4b.GraphColdOneMachineValues
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneMachineCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

noncomputable def Goal {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
    (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey) (input : Fin 248320)
    (x : SegInst FF) (je : Host.Ts.Env) : Prop :=
  ∃ cs out, ExtractSim.cachesT (x.t.reFfi (_root_.Host.Load.Layers.toLoad x.t.ffi)) je = some cs ∧
    ForwardAtM P.toMlxContract KR.toKernelContract env
      (refPrompt P KR NE KR.inPlace net env [input.val]) x.C.tab 1 cs out
      (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi))

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey) (input : Fin 248320)

/-- The actual extracted cache list holds the exact reference's handles. -/
theorem of_extracted {x : SegInst FF} {je : Host.Ts.Env}
    (he : OneCache.Extracted x je)
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C) :
    Goal P KR NE net env input x je := by
  obtain ⟨cs, hc, _, _, hn⟩ := OneCache.extracted_carriers he
  exact ⟨cs, x.M.node 17776, hc, OneMachine.forward_at P KR NE net env input x.M x.t x.C hv cs hn⟩

theorem one {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Ffi.St}
    {x : SegInst FF} {je : Host.Ts.Env}
    (hr : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).R
      x D1PostOne.s10 ⟨D1PostOne.S10.tab, []⟩)
    (hb : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).B x)
    (hl : lookupEnv chars!"cache" je = some 2586)
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C) :
    Goal P KR NE net env input x je :=
  of_extracted P KR NE net env input (OneCache.one_extract hr hb hl) hv

theorem eos {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Ffi.St}
    {x : SegInst FF} {je : Host.Ts.Env}
    (hr : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).R
      x D1PostOneEos.s10 ⟨D1PostOneEos.S10.tab, []⟩)
    (hb : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).B x)
    (hl : lookupEnv chars!"cache" je = some 2586)
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C) :
    Goal P KR NE net env input x je :=
  of_extracted P KR NE net env input (OneCache.eos_extract hr hb hl) hv

end Host.Ts.Sim.Compose.ColdGraph.OneMachineCache
