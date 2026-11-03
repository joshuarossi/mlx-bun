import host.sim.compose.a4b.PLTEKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_pl_tail.n : Nat := 445
kernel_rfl PRE_pl_tail.tab_len : PRE_pl_tail.S0.tab.length = PRE_pl_tail.n
noncomputable def PRE_pl_tail.suppAt (a : Nat) : Bool :=
  match PRE_pl_tail.s0.heap.get a with
  | some h => bHobj (presentB PRE_pl_tail.s0) PRE_pl_tail.n h
  | none => true
noncomputable def PRE_pl_tail.boundAt (a : Nat) : Bool := Nat.blt a PRE_pl_tail.s0.next

tpl_all_blocks PRE_pl_tail.HS from PLTEV : PRE_pl_tail.suppAt
kernel_rfl PRE_pl_tail.suppFramed : PLTEV.frames.all PRE_pl_tail.suppAt = true
tpl_all_blocks PRE_pl_tail.BD from PLTEV : PRE_pl_tail.boundAt
kernel_rfl PRE_pl_tail.boundFramed : PLTEV.frames.all PRE_pl_tail.boundAt = true
kernel_rfl PRE_pl_tail.rootsSupp_check : checkRootsSupp PRE_pl_tail.s0 PRE_pl_tail.n = true

theorem PRE_pl_tail.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PLTEV.gks, ∀ a ∈ q.2, p a = true) (hf : PLTEV.frames.all p = true) :
    ∀ a, Present PRE_pl_tail.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PLTEV.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_pl_tail.cover a h hg hm
    exact hb q hq a haq

theorem PRE_pl_tail.heapSupp : ∀ a h, PRE_pl_tail.s0.heap.get a = some h → Supp.hobj (Present PRE_pl_tail.s0) PRE_pl_tail.n h := by
  intro a h ha
  have hp := PRE_pl_tail.allPresent PRE_pl_tail.HS.all PRE_pl_tail.suppFramed a (Present.of_get ha)
  unfold PRE_pl_tail.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_pl_tail.rootsSupp : Supp.ctl (Present PRE_pl_tail.s0) PRE_pl_tail.n PRE_pl_tail.s0.ctl ∧
    (∀ f ∈ PRE_pl_tail.s0.stack, Supp.frame (Present PRE_pl_tail.s0) PRE_pl_tail.n f) ∧
    (∀ j ∈ PRE_pl_tail.s0.jobs, Supp.job (Present PRE_pl_tail.s0) PRE_pl_tail.n j) ∧ Supp.stores (Present PRE_pl_tail.s0) PRE_pl_tail.n PRE_pl_tail.s0.stores :=
  checkRootsSupp_sound PRE_pl_tail.rootsSupp_check

theorem PRE_pl_tail.presentBound : ∀ a, Present PRE_pl_tail.s0 a → a < PRE_pl_tail.s0.next := by
  intro a ha
  have := PRE_pl_tail.allPresent PRE_pl_tail.BD.all PRE_pl_tail.boundFramed a ha
  unfold PRE_pl_tail.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
