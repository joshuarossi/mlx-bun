import host.sim.template.a4dec_fill.EShift
import host.sim.template.a4dec_fill.EFull
import host.sim.template.a4dec_fill.EFacts
import host.sim.full.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Chain `DEC_fill`'s end as a decode iteration's end (`Prefill.IterEndW` at `addrPrompt`, `DEC_fill.PE`, `fixP`), its shift under the
prompt route's frames (`framesP`, `wideP`), the frames' arrays kept, and the hypothesis form `DEC_fill.endB`. -/

noncomputable def DEC_fill.iterEnd (NB : Nat) :
    Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) Host.Load.Run.Prompt.addrPrompt DEC_fill.PE DEC_fill.s0 DEC_fill.S0.tab fixP where
  s1 := DEC_fill.s11
  S1 := DEC_fill.S1D
  σ := DEC_fill.σ
  θ := DEC_fill.θ
  grow := false
  xs := DEC_fill.xs
  eR := DEC_fill.eR
  tlen := Nat.le_of_ble_eq_true DEC_fill.tlen_check
  noVarTab := DEC_fill.noVarTab
  noVarOr := DEC_fill.noVarOr
  nshift := DEC_fill.fullShift
  num := DEC_fill.num79
  hE := DEC_fill.hE
  theta := DEC_fill.theta
  fwd := DEC_fill.fwd
  emit := DEC_fill.emit
  fix := DEC_fill.fix

theorem DEC_fill.shiftFW (NB : Nat) (q : List Val) : (DEC_fill.iterEnd NB).ShiftFW (framesP DEC_fill.s0 q) wideP := by
  refine ⟨fun p1 p2 K hfr hlo hhi => DEC_fill.shiftJS q p1 p2 K hfr hlo hhi, fun a w hw => ?_⟩
  have ha : a = 4910 := by
    unfold wideP at hw
    cases h : Nat.beq a 4910
    · rw [h] at hw; cases hw
    · exact Nat.eq_of_beq_eq_true h
  subst ha
  have hw' : w = .memo [] := by simp [wideP] at hw; exact hw.symm
  subst hw'
  exact ⟨by show 4910 ∈ [2665, 4910]; decide, DEC_fill.w4910a, DEC_fill.w4910p, wfix_of DEC_fill.w4910f⟩

theorem DEC_fill.keep (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_fill.s0 q) DEC_fill.s11 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_fill.w4910k ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_fill.prompt
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp

/-- **The end in the hypothesis form** (`A`, the further frames, the wide frames, the fixed addresses given). -/
theorem DEC_fill.endB {NB : Nat} {A : Addr} {Fr : LoopFramesA A} {W : Nat → Option WFrame} {fixA : List Nat} (q : List Val)
    (hA : A = Host.Load.Run.Prompt.addrPrompt) (hfr : HEq Fr (framesP DEC_fill.s0 q)) (hW : W = wideP) (hfix : fixA = fixP) :
    ∃ e : Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) A DEC_fill.PE DEC_fill.s0 DEC_fill.S0.tab fixA,
      e.s1 = DEC_fill.s11 ∧ e.S1 = DEC_fill.S1D ∧ e.eR = DEC_fill.eR ∧ e.ShiftFW Fr W ∧ Host.Ts.Sim.Prefill.KeepsAtW Fr e.s1 := by
  subst hA hW hfix
  cases hfr
  exact ⟨DEC_fill.iterEnd NB, rfl, rfl, rfl, DEC_fill.shiftFW NB q, DEC_fill.keep q⟩

end Host.Load.Run.Tpl
