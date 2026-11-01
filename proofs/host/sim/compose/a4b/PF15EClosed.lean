import host.sim.compose.a4b.PF15EKeys
import host.sim.template.Check
import host.sim.template.NShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

abbrev PRE_pf_vw.n : Nat := 8323
kernel_rfl PRE_pf_vw.tab_len : PRE_pf_vw.S0.tab.length = PRE_pf_vw.n
kernel_rfl PRE_pf_vw.frames_eq : PRE_pf_vw.frames = [2665]
noncomputable def PRE_pf_vw.suppAt (a : Nat) : Bool :=
  match PRE_pf_vw.s0.heap.get a with
  | some h => bHobj (presentB PRE_pf_vw.s0) PRE_pf_vw.n h
  | none => true
noncomputable def PRE_pf_vw.boundAt (a : Nat) : Bool := Nat.blt a PRE_pf_vw.s0.next

tpl_all_blocks PRE_pf_vw.HS from PF15EV : PRE_pf_vw.suppAt
kernel_rfl PRE_pf_vw.suppFramed : PRE_pf_vw.frames.all PRE_pf_vw.suppAt = true
tpl_all_blocks PRE_pf_vw.BD from PF15EV : PRE_pf_vw.boundAt
kernel_rfl PRE_pf_vw.boundFramed : PRE_pf_vw.frames.all PRE_pf_vw.boundAt = true
kernel_rfl PRE_pf_vw.rootsSupp_check : checkRootsSupp PRE_pf_vw.s0 PRE_pf_vw.n = true

theorem PRE_pf_vw.allPresent {p : Nat → Bool} (hb : ∀ q ∈ PF15EV.gks, ∀ a ∈ q.2, p a = true) (hf : PRE_pf_vw.frames.all p = true) :
    ∀ a, Present PRE_pf_vw.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ PRE_pf_vw.frames
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := PRE_pf_vw.cover a h hg hm
    exact hb q hq a haq

theorem PRE_pf_vw.heapSupp : ∀ a h, PRE_pf_vw.s0.heap.get a = some h → Supp.hobj (Present PRE_pf_vw.s0) PRE_pf_vw.n h := by
  intro a h ha
  have hp := PRE_pf_vw.allPresent PRE_pf_vw.HS.all PRE_pf_vw.suppFramed a (Present.of_get ha)
  unfold PRE_pf_vw.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem PRE_pf_vw.rootsSupp : Supp.ctl (Present PRE_pf_vw.s0) PRE_pf_vw.n PRE_pf_vw.s0.ctl ∧
    (∀ f ∈ PRE_pf_vw.s0.stack, Supp.frame (Present PRE_pf_vw.s0) PRE_pf_vw.n f) ∧
    (∀ j ∈ PRE_pf_vw.s0.jobs, Supp.job (Present PRE_pf_vw.s0) PRE_pf_vw.n j) ∧ Supp.stores (Present PRE_pf_vw.s0) PRE_pf_vw.n PRE_pf_vw.s0.stores :=
  checkRootsSupp_sound PRE_pf_vw.rootsSupp_check

theorem PRE_pf_vw.presentBound : ∀ a, Present PRE_pf_vw.s0 a → a < PRE_pf_vw.s0.next := by
  intro a ha
  have := PRE_pf_vw.allPresent PRE_pf_vw.BD.all PRE_pf_vw.boundFramed a ha
  unfold PRE_pf_vw.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
