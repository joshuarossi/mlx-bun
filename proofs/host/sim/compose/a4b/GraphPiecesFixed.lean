import host.sim.compose.a4b.DecodePiecesFixed
import host.sim.compose.MainFramed
import host.sim.compose.a4b.GraphFixedEnds
import host.sim.compose.a4b.FinalCaches1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill _root_.Host.Ts.Sim.Full
open _root_.Host.Ts.Sim.Template _root_.Host.Load.Layers _root_.Host.Load.Run.Prompt
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph _root_.Host.Mlx.FfiEval
open _root_.Host.Load.Program
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open _root_.Host.Route (machVal machReads)

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (env : FfiEval.Env InKey) (π : List Nat)
  {b0 : BSt} {NB T : Nat} {tk : Nat → Nat} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The actual six decode graphs and all terminal graph/cache facts, at the saved source environment. -/
noncomputable def DEC.graphPiecesFramedFixed (q : List Val) (hql : q.length = π.length)
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T tk j = F64.ofNat n)
    (h1 : 1 ≤ π.length) (hT : 3 ≤ T) (hctx : π.length + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) (hNB : 15235 ≤ NB)
    (hJ : DEC.ΔJ ≤ ΔJ) (hH : DEC.ΔH ≤ ΔH) (hN : DEC.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    DecodeGraphMFramedAt P KR env π b0
      (entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))) DEC.inputs
      (DEC.piecesFramedFixed (b0 := b0) (NB := NB) (ρ := machVal T tk)
        (toks := .ref 2 :: machReads T tk) q hql hρ h1 hT hctx htv hJ hH hN hJb hHb hNb) where
  st := DEC.startGM b0 NB
  en
    | .ord => DECGraph.fixedEndGM.Ord b0 NB
    | .clear => DECGraph.fixedEndGM.Clear b0 NB
    | .grow => DECGraph.fixedEndGM.Grow b0 NB
    | .fill => DECGraph.fixedEndGM.Fill b0 NB
    | .clearFill => DECGraph.fixedEndGM.ClearFill b0 NB
    | .clearGrow => DECGraph.fixedEndGM.ClearGrow b0 NB
  tpl k i hs := by
    cases k
    · exact DECGraph.fixedCaseTpl.Ord P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.fixedCaseTpl.Clear P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.fixedCaseTpl.Grow P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.fixedCaseTpl.Fill P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.fixedCaseTpl.ClearFill P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.fixedCaseTpl.ClearGrow P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
  f0 := DEC.finalPlain_graph b0 NB q _
  f1 := DEC.finalClear0_graph b0 NB q _
  f2 := DEC.finalClear1_graph b0 NB q _
  c0 := DEC.finalPlain_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  c1 := DEC.finalClear0_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  c2 := DEC.finalClear1_savedCacheTpl b0 NB q _ (π.map natV) (machReads T tk)
  e0 := DEC.finalEos0_graph b0 NB q _
  e1 := DEC.finalEos1_graph b0 NB q _
  x k := DEC.eosCutFramed_graph b0 NB _

end
end Host.Ts.Sim.Compose
