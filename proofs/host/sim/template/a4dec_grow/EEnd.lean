import host.sim.template.a4dec_grow.EShift
import host.sim.template.a4dec_grow.EFull
import host.sim.template.a4dec_grow.EFacts
import host.sim.full.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Chain `DEC_grow`'s end as a decode iteration's end (`Prefill.IterEndW` at `addrPrompt`, `DEC_grow.PE`, `fixP`), its shift under the
prompt route's frames (`framesP`, `wideP`), the frames' arrays kept, and the hypothesis form `DEC_grow.endB`. -/

noncomputable def DEC_grow.iterEnd (NB : Nat) :
    Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) Host.Load.Run.Prompt.addrPrompt DEC_grow.PE DEC_grow.s0 DEC_grow.S0.tab fixP where
  s1 := DEC_grow.s11
  S1 := DEC_grow.S1D
  σ := DEC_grow.σ
  θ := DEC_grow.θ
  grow := true
  xs := DEC_grow.xs
  eR := DEC_grow.eR
  tlen := Nat.le_of_ble_eq_true DEC_grow.tlen_check
  noVarTab := DEC_grow.noVarTab
  noVarOr := DEC_grow.noVarOr
  nshift := DEC_grow.fullShift
  num := DEC_grow.num79
  hE := DEC_grow.hE
  theta := DEC_grow.theta
  fwd := DEC_grow.fwd
  emit := DEC_grow.emit
  fix := DEC_grow.fix

theorem DEC_grow.shiftFW (NB : Nat) (q : List Val) : (DEC_grow.iterEnd NB).ShiftFW (framesP DEC_grow.s0 q) wideP := by
  refine ⟨fun p1 p2 K hfr hlo hhi => DEC_grow.shiftJS q p1 p2 K hfr hlo hhi, fun a w hw => ?_⟩
  have ha : a = 4910 := by
    unfold wideP at hw
    cases h : Nat.beq a 4910
    · rw [h] at hw; cases hw
    · exact Nat.eq_of_beq_eq_true h
  subst ha
  have hw' : w = .memo [] := by simp [wideP] at hw; exact hw.symm
  subst hw'
  exact ⟨by show 4910 ∈ [2665, 4910]; decide, DEC_grow.w4910a, DEC_grow.w4910p, wfix_of DEC_grow.w4910f⟩

theorem DEC_grow.keep (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP DEC_grow.s0 q) DEC_grow.s11 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of DEC_grow.w4910k ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := DEC_grow.prompt
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp

/-- **The end in the hypothesis form** (`A`, the further frames, the wide frames, the fixed addresses given). -/
theorem DEC_grow.endB {NB : Nat} {A : Addr} {Fr : LoopFramesA A} {W : Nat → Option WFrame} {fixA : List Nat} (q : List Val)
    (hA : A = Host.Load.Run.Prompt.addrPrompt) (hfr : HEq Fr (framesP DEC_grow.s0 q)) (hW : W = wideP) (hfix : fixA = fixP) :
    ∃ e : Host.Ts.Sim.Prefill.IterEndW (Host.Ts.Sim.Full.fullWorld NB) A DEC_grow.PE DEC_grow.s0 DEC_grow.S0.tab fixA,
      e.s1 = DEC_grow.s11 ∧ e.S1 = DEC_grow.S1D ∧ e.eR = DEC_grow.eR ∧ e.ShiftFW Fr W ∧ Host.Ts.Sim.Prefill.KeepsAtW Fr e.s1 := by
  subst hA hW hfix
  cases hfr
  exact ⟨DEC_grow.iterEnd NB, rfl, rfl, rfl, DEC_grow.shiftFW NB q, DEC_grow.keep q⟩

end Host.Load.Run.Tpl
