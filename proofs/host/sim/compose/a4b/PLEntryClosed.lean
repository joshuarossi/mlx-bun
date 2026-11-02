import host.sim.compose.a4b.PLEntryKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_pl_entry.n : Nat := 121
kernel_rfl PRE_pl_entry.tab_len : PRE_pl_entry.S0.tab.length = PRE_pl_entry.n
noncomputable def PRE_pl_entry.suppAt (a : Nat) : Bool :=
  match PRE_pl_entry.s0.heap.get a with
  | some h => bHobj (presentB PRE_pl_entry.s0) PRE_pl_entry.n h
  | none => true
noncomputable def PRE_pl_entry.boundAt (a : Nat) : Bool := Nat.blt a PRE_pl_entry.s0.next

tpl_all_blocks PRE_pl_entry.HS from PLEntryV : PRE_pl_entry.suppAt
kernel_rfl PRE_pl_entry.suppFramed : PLEntryV.frames.all PRE_pl_entry.suppAt = true
tpl_all_blocks PRE_pl_entry.BD from PLEntryV : PRE_pl_entry.boundAt
kernel_rfl PRE_pl_entry.boundFramed : PLEntryV.frames.all PRE_pl_entry.boundAt = true
kernel_rfl PRE_pl_entry.rootsSupp_check : checkRootsSupp PRE_pl_entry.s0 PRE_pl_entry.n = true

theorem PRE_pl_entry.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PLEntryV.gks, ∀ a ∈ q.2, p a = true) (hf : PLEntryV.frames.all p = true) :
    ∀ a, Present PRE_pl_entry.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PLEntryV.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_pl_entry.cover a h hg hm
    exact hb q hq a haq

theorem PRE_pl_entry.heapSupp : ∀ a h, PRE_pl_entry.s0.heap.get a = some h → Supp.hobj (Present PRE_pl_entry.s0) PRE_pl_entry.n h := by
  intro a h ha
  have hp := PRE_pl_entry.allPresent PRE_pl_entry.HS.all PRE_pl_entry.suppFramed a (Present.of_get ha)
  unfold PRE_pl_entry.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_pl_entry.rootsSupp : Supp.ctl (Present PRE_pl_entry.s0) PRE_pl_entry.n PRE_pl_entry.s0.ctl ∧
    (∀ f ∈ PRE_pl_entry.s0.stack, Supp.frame (Present PRE_pl_entry.s0) PRE_pl_entry.n f) ∧
    (∀ j ∈ PRE_pl_entry.s0.jobs, Supp.job (Present PRE_pl_entry.s0) PRE_pl_entry.n j) ∧ Supp.stores (Present PRE_pl_entry.s0) PRE_pl_entry.n PRE_pl_entry.s0.stores :=
  checkRootsSupp_sound PRE_pl_entry.rootsSupp_check

theorem PRE_pl_entry.presentBound : ∀ a, Present PRE_pl_entry.s0 a → a < PRE_pl_entry.s0.next := by
  intro a ha
  have := PRE_pl_entry.allPresent PRE_pl_entry.BD.all PRE_pl_entry.boundFramed a ha
  unfold PRE_pl_entry.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
