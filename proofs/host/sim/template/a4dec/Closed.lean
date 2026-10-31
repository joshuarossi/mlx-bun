import host.sim.template.a4dec.Keys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Closedness of the template `DT.s0` (as `base/Closed`, its frames `DT.frames`): every heap entry and the roots mention
only present addresses and the first `DT.n` number references; present addresses lie below the counter. -/

abbrev DT.n : Nat := 123
kernel_rfl DT.tab_len : DT.S0.tab.length = DT.n
kernel_rfl DT.frames_eq : DT.frames = [2673448, 12504, 2665]
noncomputable def DT.suppAt (a : Nat) : Bool :=
  match DT.s0.heap.get a with
  | some h => bHobj (presentB DT.s0) DT.n h
  | none => true
noncomputable def DT.boundAt (a : Nat) : Bool := Nat.blt a DT.s0.next

tpl_all_blocks DT.HS from DT : DT.suppAt
kernel_rfl DT.suppFramed : DT.frames.all DT.suppAt = true
tpl_all_blocks DT.BD from DT : DT.boundAt
kernel_rfl DT.boundFramed : DT.frames.all DT.boundAt = true
kernel_rfl DT.rootsSupp_check : checkRootsSupp DT.s0 DT.n = true

theorem DT.allPresent {p : Nat → Bool} (hb : ∀ q ∈ DT.gks, ∀ a ∈ q.2, p a = true) (hf : DT.frames.all p = true) :
    ∀ a, Present DT.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ DT.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := DT.cover a h hg hm
    exact hb q hq a haq

theorem DT.heapSupp : ∀ a h, DT.s0.heap.get a = some h → Supp.hobj (Present DT.s0) DT.n h := by
  intro a h ha
  have hp := DT.allPresent DT.HS.all DT.suppFramed a (Present.of_get ha)
  unfold DT.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem DT.rootsSupp : Supp.ctl (Present DT.s0) DT.n DT.s0.ctl ∧
    (∀ f ∈ DT.s0.stack, Supp.frame (Present DT.s0) DT.n f) ∧
    (∀ j ∈ DT.s0.jobs, Supp.job (Present DT.s0) DT.n j) ∧ Supp.stores (Present DT.s0) DT.n DT.s0.stores :=
  checkRootsSupp_sound DT.rootsSupp_check

theorem DT.presentBound : ∀ a, Present DT.s0 a → a < DT.s0.next := by
  intro a ha
  have := DT.allPresent DT.BD.all DT.boundFramed a ha
  unfold DT.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
