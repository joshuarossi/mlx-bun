import host.sim.compose.a4b.FixedEnds
import host.sim.compose.FixedGhost
import host.sim.compose.a4b.GraphOrdLoop
import host.sim.compose.a4b.GraphClearLoop
import host.sim.compose.a4b.GraphGrowLoop
import host.sim.compose.a4b.GraphFillLoop
import host.sim.compose.a4b.GraphClearFillLoop
import host.sim.compose.a4b.GraphClearGrowLoop
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

section Adapter
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA extra : List Nat} {I : TplInputs}
  {e : IterEndW Wd A P s0 tab0 fixA}

/-- Extend fixed-address bookkeeping with the same checked graph carriers and endpoint facts. -/
def EndGM.withFixed (en : EndGM I e) (hσ : ∀ a ∈ extra, e.σ.a a = a) :
    EndGM I (e.withFixed hσ) where
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

theorem EndGM.withFixed_outT (en : EndGM I e) (hσ : ∀ a ∈ extra, e.σ.a a = a) :
    (en.withFixed hσ).outT = en.outT := rfl

theorem EndGM.withFixed_outs (en : EndGM I e) (hσ : ∀ a ∈ extra, e.σ.a a = a) :
    (en.withFixed hσ).outs = en.outs := rfl
end Adapter

namespace DECGraph.fixedEndGM

/-- The actual checked ord graph end, at the terminal fixed-address set. -/
noncomputable def Ord (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_ord.endFixed b0 NB) :=
  (DECGraph.Ord.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.ord_restart_2586
    · exact DEC.FixedCells.ord_restart_2589)

/-- The actual checked clear graph end, at the terminal fixed-address set. -/
noncomputable def Clear (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_clear.endFixed b0 NB) :=
  (DECGraph.Clear.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.clear_restart_2586
    · exact DEC.FixedCells.clear_restart_2589)

/-- The actual checked grow graph end, at the terminal fixed-address set. -/
noncomputable def Grow (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_grow.endFixed b0 NB) :=
  (DECGraph.Grow.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.grow_restart_2586
    · exact DEC.FixedCells.grow_restart_2589)

/-- The actual checked fill graph end, at the terminal fixed-address set. -/
noncomputable def Fill (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_fill.endFixed b0 NB) :=
  (DECGraph.Fill.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.fill_restart_2586
    · exact DEC.FixedCells.fill_restart_2589)

/-- The actual checked clearFill graph end, at the terminal fixed-address set. -/
noncomputable def ClearFill (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_clearFill.endFixed b0 NB) :=
  (DECGraph.ClearFill.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.clearFill_restart_2586
    · exact DEC.FixedCells.clearFill_restart_2589)

/-- The actual checked clearGrow graph end, at the terminal fixed-address set. -/
noncomputable def ClearGrow (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM DEC.inputs (DEC_clearGrow.endFixed b0 NB) :=
  (DECGraph.ClearGrow.endGM b0 NB).withFixed (extra := [2586, 2589]) (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact DEC.FixedCells.clearGrow_restart_2586
    · exact DEC.FixedCells.clearGrow_restart_2589)

end DECGraph.fixedEndGM

namespace DECGraph.fixedCaseTpl
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)

/-- The selected ord graph template at the unchanged runtime endpoint and checked carriers. -/
theorem Ord (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .ord i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_ord.endFixed b0 NB).s1.ffi (DEC_ord.endFixed b0 NB).S1.tab
      (fixedEndGM.Ord b0 NB).outT (fixedEndGM.Ord b0 NB).outs i NB :=
  DECGraph.Ord.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

/-- The selected clear graph template at the unchanged runtime endpoint and checked carriers. -/
theorem Clear (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .clear i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_clear.endFixed b0 NB).s1.ffi (DEC_clear.endFixed b0 NB).S1.tab
      (fixedEndGM.Clear b0 NB).outT (fixedEndGM.Clear b0 NB).outs i NB :=
  DECGraph.Clear.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

/-- The selected grow graph template at the unchanged runtime endpoint and checked carriers. -/
theorem Grow (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .grow i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_grow.endFixed b0 NB).s1.ffi (DEC_grow.endFixed b0 NB).S1.tab
      (fixedEndGM.Grow b0 NB).outT (fixedEndGM.Grow b0 NB).outs i NB :=
  DECGraph.Grow.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

/-- The selected fill graph template at the unchanged runtime endpoint and checked carriers. -/
theorem Fill (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .fill i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_fill.endFixed b0 NB).s1.ffi (DEC_fill.endFixed b0 NB).S1.tab
      (fixedEndGM.Fill b0 NB).outT (fixedEndGM.Fill b0 NB).outs i NB :=
  DECGraph.Fill.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

/-- The selected clearFill graph template at the unchanged runtime endpoint and checked carriers. -/
theorem ClearFill (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .clearFill i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_clearFill.endFixed b0 NB).s1.ffi (DEC_clearFill.endFixed b0 NB).S1.tab
      (fixedEndGM.ClearFill b0 NB).outT (fixedEndGM.ClearFill b0 NB).outs i NB :=
  DECGraph.ClearFill.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

/-- The selected clearGrow graph template at the unchanged runtime endpoint and checked carriers. -/
theorem ClearGrow (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .clearGrow i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      (DEC_clearGrow.endFixed b0 NB).s1.ffi (DEC_clearGrow.endFixed b0 NB).S1.tab
      (fixedEndGM.ClearGrow b0 NB).outT (fixedEndGM.ClearGrow b0 NB).outs i NB :=
  DECGraph.ClearGrow.caseTpl_selected M K env b0 NB L T i tk hNB hctx hs

end DECGraph.fixedCaseTpl
end Host.Ts.Sim.Compose
