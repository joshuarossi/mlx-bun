import host.sim.compose.a4b.PF4L8EKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_pf_x4_L8.n : Nat := 112
kernel_rfl PRE_pf_x4_L8.tab_len : PRE_pf_x4_L8.S0.tab.length = PRE_pf_x4_L8.n
noncomputable def PRE_pf_x4_L8.suppAt (a : Nat) : Bool :=
  match PRE_pf_x4_L8.s0.heap.get a with
  | some h => bHobj (presentB PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n h
  | none => true
noncomputable def PRE_pf_x4_L8.boundAt (a : Nat) : Bool := Nat.blt a PRE_pf_x4_L8.s0.next

tpl_all_blocks PRE_pf_x4_L8.HS from PF4L8EV : PRE_pf_x4_L8.suppAt
kernel_rfl PRE_pf_x4_L8.suppFramed : PF4L8EV.frames.all PRE_pf_x4_L8.suppAt = true
tpl_all_blocks PRE_pf_x4_L8.BD from PF4L8EV : PRE_pf_x4_L8.boundAt
kernel_rfl PRE_pf_x4_L8.boundFramed : PF4L8EV.frames.all PRE_pf_x4_L8.boundAt = true
kernel_rfl PRE_pf_x4_L8.rootsSupp_check : checkRootsSupp PRE_pf_x4_L8.s0 PRE_pf_x4_L8.n = true

theorem PRE_pf_x4_L8.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PF4L8EV.gks, ∀ a ∈ q.2, p a = true) (hf : PF4L8EV.frames.all p = true) :
    ∀ a, Present PRE_pf_x4_L8.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PF4L8EV.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_pf_x4_L8.cover a h hg hm
    exact hb q hq a haq

theorem PRE_pf_x4_L8.heapSupp : ∀ a h, PRE_pf_x4_L8.s0.heap.get a = some h → Supp.hobj (Present PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n h := by
  intro a h ha
  have hp := PRE_pf_x4_L8.allPresent PRE_pf_x4_L8.HS.all PRE_pf_x4_L8.suppFramed a (Present.of_get ha)
  unfold PRE_pf_x4_L8.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_pf_x4_L8.rootsSupp : Supp.ctl (Present PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n PRE_pf_x4_L8.s0.ctl ∧
    (∀ f ∈ PRE_pf_x4_L8.s0.stack, Supp.frame (Present PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n f) ∧
    (∀ j ∈ PRE_pf_x4_L8.s0.jobs, Supp.job (Present PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n j) ∧ Supp.stores (Present PRE_pf_x4_L8.s0) PRE_pf_x4_L8.n PRE_pf_x4_L8.s0.stores :=
  checkRootsSupp_sound PRE_pf_x4_L8.rootsSupp_check

theorem PRE_pf_x4_L8.presentBound : ∀ a, Present PRE_pf_x4_L8.s0 a → a < PRE_pf_x4_L8.s0.next := by
  intro a ha
  have := PRE_pf_x4_L8.allPresent PRE_pf_x4_L8.BD.all PRE_pf_x4_L8.boundFramed a ha
  unfold PRE_pf_x4_L8.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
