import host.sim.compose.a4b.PL0EKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_plx0_entry.n : Nat := 483
kernel_rfl PRE_plx0_entry.tab_len : PRE_plx0_entry.S0.tab.length = PRE_plx0_entry.n
noncomputable def PRE_plx0_entry.suppAt (a : Nat) : Bool :=
  match PRE_plx0_entry.s0.heap.get a with
  | some h => bHobj (presentB PRE_plx0_entry.s0) PRE_plx0_entry.n h
  | none => true
noncomputable def PRE_plx0_entry.boundAt (a : Nat) : Bool := Nat.blt a PRE_plx0_entry.s0.next

tpl_all_blocks PRE_plx0_entry.HS from PL0EV : PRE_plx0_entry.suppAt
kernel_rfl PRE_plx0_entry.suppFramed : PL0EV.frames.all PRE_plx0_entry.suppAt = true
tpl_all_blocks PRE_plx0_entry.BD from PL0EV : PRE_plx0_entry.boundAt
kernel_rfl PRE_plx0_entry.boundFramed : PL0EV.frames.all PRE_plx0_entry.boundAt = true
kernel_rfl PRE_plx0_entry.rootsSupp_check : checkRootsSupp PRE_plx0_entry.s0 PRE_plx0_entry.n = true

theorem PRE_plx0_entry.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PL0EV.gks, ∀ a ∈ q.2, p a = true) (hf : PL0EV.frames.all p = true) :
    ∀ a, Present PRE_plx0_entry.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PL0EV.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_plx0_entry.cover a h hg hm
    exact hb q hq a haq

theorem PRE_plx0_entry.heapSupp : ∀ a h, PRE_plx0_entry.s0.heap.get a = some h → Supp.hobj (Present PRE_plx0_entry.s0) PRE_plx0_entry.n h := by
  intro a h ha
  have hp := PRE_plx0_entry.allPresent PRE_plx0_entry.HS.all PRE_plx0_entry.suppFramed a (Present.of_get ha)
  unfold PRE_plx0_entry.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_plx0_entry.rootsSupp : Supp.ctl (Present PRE_plx0_entry.s0) PRE_plx0_entry.n PRE_plx0_entry.s0.ctl ∧
    (∀ f ∈ PRE_plx0_entry.s0.stack, Supp.frame (Present PRE_plx0_entry.s0) PRE_plx0_entry.n f) ∧
    (∀ j ∈ PRE_plx0_entry.s0.jobs, Supp.job (Present PRE_plx0_entry.s0) PRE_plx0_entry.n j) ∧ Supp.stores (Present PRE_plx0_entry.s0) PRE_plx0_entry.n PRE_plx0_entry.s0.stores :=
  checkRootsSupp_sound PRE_plx0_entry.rootsSupp_check

theorem PRE_plx0_entry.presentBound : ∀ a, Present PRE_plx0_entry.s0 a → a < PRE_plx0_entry.s0.next := by
  intro a ha
  have := PRE_plx0_entry.allPresent PRE_plx0_entry.BD.all PRE_plx0_entry.boundFramed a ha
  unfold PRE_plx0_entry.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
