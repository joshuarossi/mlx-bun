import host.sim.compose.a4b.PLVEKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_plvw_entry.n : Nat := 9094
kernel_rfl PRE_plvw_entry.tab_len : PRE_plvw_entry.S0.tab.length = PRE_plvw_entry.n
noncomputable def PRE_plvw_entry.suppAt (a : Nat) : Bool :=
  match PRE_plvw_entry.s0.heap.get a with
  | some h => bHobj (presentB PRE_plvw_entry.s0) PRE_plvw_entry.n h
  | none => true
noncomputable def PRE_plvw_entry.boundAt (a : Nat) : Bool := Nat.blt a PRE_plvw_entry.s0.next

tpl_all_blocks PRE_plvw_entry.HS from PLVEV : PRE_plvw_entry.suppAt
kernel_rfl PRE_plvw_entry.suppFramed : PLVEV.frames.all PRE_plvw_entry.suppAt = true
tpl_all_blocks PRE_plvw_entry.BD from PLVEV : PRE_plvw_entry.boundAt
kernel_rfl PRE_plvw_entry.boundFramed : PLVEV.frames.all PRE_plvw_entry.boundAt = true
kernel_rfl PRE_plvw_entry.rootsSupp_check : checkRootsSupp PRE_plvw_entry.s0 PRE_plvw_entry.n = true

theorem PRE_plvw_entry.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PLVEV.gks, ∀ a ∈ q.2, p a = true) (hf : PLVEV.frames.all p = true) :
    ∀ a, Present PRE_plvw_entry.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PLVEV.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_plvw_entry.cover a h hg hm
    exact hb q hq a haq

theorem PRE_plvw_entry.heapSupp : ∀ a h, PRE_plvw_entry.s0.heap.get a = some h → Supp.hobj (Present PRE_plvw_entry.s0) PRE_plvw_entry.n h := by
  intro a h ha
  have hp := PRE_plvw_entry.allPresent PRE_plvw_entry.HS.all PRE_plvw_entry.suppFramed a (Present.of_get ha)
  unfold PRE_plvw_entry.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_plvw_entry.rootsSupp : Supp.ctl (Present PRE_plvw_entry.s0) PRE_plvw_entry.n PRE_plvw_entry.s0.ctl ∧
    (∀ f ∈ PRE_plvw_entry.s0.stack, Supp.frame (Present PRE_plvw_entry.s0) PRE_plvw_entry.n f) ∧
    (∀ j ∈ PRE_plvw_entry.s0.jobs, Supp.job (Present PRE_plvw_entry.s0) PRE_plvw_entry.n j) ∧ Supp.stores (Present PRE_plvw_entry.s0) PRE_plvw_entry.n PRE_plvw_entry.s0.stores :=
  checkRootsSupp_sound PRE_plvw_entry.rootsSupp_check

theorem PRE_plvw_entry.presentBound : ∀ a, Present PRE_plvw_entry.s0 a → a < PRE_plvw_entry.s0.next := by
  intro a ha
  have := PRE_plvw_entry.allPresent PRE_plvw_entry.BD.all PRE_plvw_entry.boundFramed a ha
  unfold PRE_plvw_entry.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
