import host.sim.compose.a4b.DecodeGpu
import host.sim.compose.MainFramed
import host.sim.compose.a4b.FixedEnds
import host.sim.compose.FixedGhost
import host.sim.compose.a4b.GraphOrdLoop
import host.sim.compose.a4b.GraphClearLoop
import host.sim.compose.a4b.GraphGrowLoop
import host.sim.compose.a4b.GraphFillLoop
import host.sim.compose.a4b.FinalCaches1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Prefill _root_.Host.Ts.Sim.Full
open _root_.Host.Ts.Sim.Template _root_.Host.Load.Layers _root_.Host.Load.Run.Prompt
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph _root_.Host.Mlx.FfiEval
open _root_.Host.Mlx.SimGraph.Iter
open _root_.Host.Load.Program
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open _root_.Host.Route (machVal machReads)
open _root_.Host.Ts.Sim.Lin.Cls

/-! # The decode graph facts at `L ≤ 224`

`DEC.graphPiecesFramedFixed` from the four chains those prompts run. The graph facts of `clearFill` and `clearGrow` are
the `clear` and `grow` ends' (`Gpu.casesOfFour` keeps those ends) and their selected templates are vacuous. The ends and
templates of `GraphFixedEnds` are restated here so its other two cases are not imported. -/

namespace DECGraphGpu

section
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA extra : List Nat} {I : TplInputs}
  {e : IterEndW Wd A P s0 tab0 fixA}

/-- Extend fixed-address bookkeeping with the same checked graph carriers and endpoint facts. -/
def withFixed (en : EndGM I e) (hσ : ∀ a ∈ extra, e.σ.a a = a) : EndGM I (e.withFixed hσ) where
  outT := en.outT
  outs := en.outs
  read := en.read
  fed := en.fed
  caches := en.caches
  h1read := en.h1read
  h1pread := en.h1pread
  s1tok := en.s1tok
  pout := en.pout
  pouts := en.pouts

end

noncomputable def Ord (b0 : Host.Mlx.FfiAne.St) (NB : Nat) : EndGM DEC.inputs (DEC_ord.endFixed b0 NB) :=
  withFixed (DECGraph.Ord.endGM b0 NB) (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.ord_restart_2586
    · exact DEC.FixedCells.ord_restart_2589)

noncomputable def Clear (b0 : Host.Mlx.FfiAne.St) (NB : Nat) : EndGM DEC.inputs (DEC_clear.endFixed b0 NB) :=
  withFixed (DECGraph.Clear.endGM b0 NB) (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.clear_restart_2586
    · exact DEC.FixedCells.clear_restart_2589)

noncomputable def Grow (b0 : Host.Mlx.FfiAne.St) (NB : Nat) : EndGM DEC.inputs (DEC_grow.endFixed b0 NB) :=
  withFixed (DECGraph.Grow.endGM b0 NB) (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.grow_restart_2586
    · exact DEC.FixedCells.grow_restart_2589)

noncomputable def Fill (b0 : Host.Mlx.FfiAne.St) (NB : Nat) : EndGM DEC.inputs (DEC_fill.endFixed b0 NB) :=
  withFixed (DECGraph.Fill.endGM b0 NB) (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.fill_restart_2586
    · exact DEC.FixedCells.fill_restart_2589)

end DECGraphGpu

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  (env : FfiEval.Env InKey) (π : List Nat)
  {b0 : BSt} {NB T : Nat} {tk : Nat → Nat} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The decode graph facts of a prompt of at most 224 tokens, at the saved source environment. -/
noncomputable def DEC.graphPiecesFramedGpu (q : List Val) (hql : q.length = π.length)
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T tk j = F64.ofNat n)
    (h1 : 1 ≤ π.length) (hL : π.length ≤ 224) (hT : 3 ≤ T) (hctx : π.length + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319) (hNB : 15235 ≤ NB)
    (hJ : DECG.ΔJ ≤ ΔJ) (hH : DECG.ΔH ≤ ΔH) (hN : DECG.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    DecodeGraphMFramedAt P KR env π b0
      (entryEnv (Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))) DEC.inputs
      (DEC.piecesFramedGpu (b0 := b0) (NB := NB) (ρ := machVal T tk)
        (toks := .ref 2 :: machReads T tk) q hql hρ h1 hL hT hctx htv hJ hH hN hJb hHb hNb) where
  st := DEC.startGM b0 NB
  en
    | .ord => DECGraphGpu.Ord b0 NB
    | .clear => DECGraphGpu.Clear b0 NB
    | .grow => DECGraphGpu.Grow b0 NB
    | .fill => DECGraphGpu.Fill b0 NB
    | .clearFill => DECGraphGpu.Clear b0 NB
    | .clearGrow => DECGraphGpu.Grow b0 NB
  tpl k i hs := by
    cases k
    · exact DECGraph.Ord.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.Clear.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.Grow.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact DECGraph.Fill.caseTpl_selected P.toMlxContract KR.toKernelContract env b0 NB π.length T i tk hNB hctx hs
    · exact (Gpu.clearFill_not hL hs.1.2.2).elim
    · exact (Gpu.clearGrow_not hL hs.1.2.2).elim
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
