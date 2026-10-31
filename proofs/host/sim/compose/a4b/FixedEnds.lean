import host.sim.compose.a4b.FixedCells
import host.sim.compose.ChainFill
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template

/-- The two terminal driver cells, in addition to the original fixed-address set. -/
def terminalFixP : List Nat := [2586, 2589] ++ Template.fixP

theorem terminal_fix_append (σ : Map) (h : ∀ a ∈ Template.fixP, σ.a a = a)
    (hc : σ.a 2586 = 2586) (hg : σ.a 2589 = 2589) : ∀ a ∈ terminalFixP, σ.a a = a := by
  intro a ha
  change a ∈ [2586, 2589] ++ Template.fixP at ha
  rcases List.mem_append.mp ha with ha | ha
  · simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact hc
    · exact hg
  · exact h a ha

private noncomputable def terminalEnd {Wd : World} {A : Addr} {P : Wd.Par}
    {s0 : St Wd.F.S} {tab0 : List SymE} (e : IterEndW Wd A P s0 tab0 Template.fixP)
    (hc : e.σ.a 2586 = 2586) (hg : e.σ.a 2589 = 2589) : IterEndW Wd A P s0 tab0 terminalFixP where
  s1 := e.s1
  S1 := e.S1
  σ := e.σ
  θ := e.θ
  grow := e.grow
  xs := e.xs
  eR := e.eR
  tlen := e.tlen
  noVarTab := e.noVarTab
  noVarOr := e.noVarOr
  nshift := e.nshift
  num := e.num
  hE := e.hE
  theta := e.theta
  fwd := e.fwd
  emit := e.emit
  fix := terminal_fix_append e.σ e.fix hc hg

/-- The existing ord restart, with the two checked terminal cell identities. -/
noncomputable def DEC_ord.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_ord.iterEnd NB).toFb b0)
    DEC.FixedCells.ord_restart_2586 DEC.FixedCells.ord_restart_2589

/-- The existing clear restart, with the two checked terminal cell identities. -/
noncomputable def DEC_clear.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_clear.iterEnd NB).toFb b0)
    DEC.FixedCells.clear_restart_2586 DEC.FixedCells.clear_restart_2589

/-- The existing grow restart, with the two checked terminal cell identities. -/
noncomputable def DEC_grow.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_grow.iterEnd NB).toFb b0)
    DEC.FixedCells.grow_restart_2586 DEC.FixedCells.grow_restart_2589

/-- The existing fill restart, with the two checked terminal cell identities. -/
noncomputable def DEC_fill.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_fill.iterEnd NB).toFb b0)
    DEC.FixedCells.fill_restart_2586 DEC.FixedCells.fill_restart_2589

/-- The existing clearFill restart, with the two checked terminal cell identities. -/
noncomputable def DEC_clearFill.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_clearFill.iterEnd NB).toFb b0)
    DEC.FixedCells.clearFill_restart_2586 DEC.FixedCells.clearFill_restart_2589

/-- The existing clearGrow restart, with the two checked terminal cell identities. -/
noncomputable def DEC_clearGrow.endFixed (b0 : BSt) (NB : Nat) :=
  terminalEnd ((Host.Load.Run.Tpl.DEC_clearGrow.iterEnd NB).toFb b0)
    DEC.FixedCells.clearGrow_restart_2586 DEC.FixedCells.clearGrow_restart_2589

end Host.Ts.Sim.Compose
