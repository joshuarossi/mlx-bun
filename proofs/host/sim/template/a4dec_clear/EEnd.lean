import host.sim.template.a4dec_clear.EShift
import host.sim.template.a4dec_clear.EFull
import host.sim.template.a4dec_clear.EFacts
import host.sim.full.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Chain `DEC_clear`'s end as a decode iteration's end (`Prefill.IterEndW` at `addrPrompt`, `DEC_clear.PE`, `fixP`), its shift under the
prompt route's frames (`framesP`, `wideP`), the frames' arrays kept, and the hypothesis form `DEC_clear.endB`. -/

noncomputable def DEC_clear.iterEnd (NB : Nat) :
    Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) Host.Load.Run.Prompt.addrPrompt DEC_clear.PE DEC_clear.s0 DEC_clear.S0.tab fixP where
  s1 := DEC_clear.s11
  S1 := DEC_clear.S1D
  σ := DEC_clear.σ
  θ := DEC_clear.θ
  grow := false
  xs := DEC_clear.xs
  eR := DEC_clear.eR
  tlen := Nat.le_of_ble_eq_true DEC_clear.tlen_check
  noVarTab := DEC_clear.noVarTab
  noVarOr := DEC_clear.noVarOr
  nshift := DEC_clear.fullShift
  num := DEC_clear.num79
  hE := DEC_clear.hE
  theta := DEC_clear.theta
  fwd := DEC_clear.fwd
  emit := DEC_clear.emit
  fix := DEC_clear.fix

theorem DEC_clear.shiftFW (NB : Nat) (q : List Val) : (DEC_clear.iterEnd NB).ShiftFW (framesP DEC_clear.s0 q) wideP := by
  refine ⟨fun p1 p2 K hfr hlo hhi => DEC_clear.shiftJS q p1 p2 K hfr hlo hhi, fun a w hw => ?_⟩
  have ha : a = 4910 := by
    unfold wideP at hw
    cases h : Nat.beq a 4910
    · rw [h] at hw; cases hw
    · exact Nat.eq_of_beq_eq_true h
  subst ha
  have hw' : w = .memo [] := by simp [wideP] at hw; exact hw.symm
  subst hw'
  exact ⟨by show 4910 ∈ [2665, 4910]; decide, DEC_clear.w4910a, DEC_clear.w4910p, wfix_of DEC_clear.w4910f⟩

theorem DEC_clear.keep (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_clear.s0 q) DEC_clear.s11 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_clear.w4910k ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_clear.prompt
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp

/-- **The end in the hypothesis form** (`A`, the further frames, the wide frames, the fixed addresses given). -/
theorem DEC_clear.endB {NB : Nat} {A : Addr} {Fr : LoopFramesA A} {W : Nat → Option WFrame} {fixA : List Nat} (q : List Val)
    (hA : A = Host.Load.Run.Prompt.addrPrompt) (hfr : HEq Fr (framesP DEC_clear.s0 q)) (hW : W = wideP) (hfix : fixA = fixP) :
    ∃ e : Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) A DEC_clear.PE DEC_clear.s0 DEC_clear.S0.tab fixA,
      e.s1 = DEC_clear.s11 ∧ e.S1 = DEC_clear.S1D ∧ e.eR = DEC_clear.eR ∧ e.ShiftFW Fr W ∧ Host.Ts.Sim.Prefill.KeepsAtW Fr e.s1 := by
  subst hA hW hfix
  cases hfr
  exact ⟨DEC_clear.iterEnd NB, rfl, rfl, rfl, DEC_clear.shiftFW NB q, DEC_clear.keep q⟩

end Host.Load.Run.Tpl
