import host.load.boot.ld.HS
import host.load.boot.ld.BD
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Closedness of the `loadDone` state `Ld.s0` (as `Tpl.Base`'s): every heap entry, the control, the
stack, the jobs and the stores mention only present addresses and the first `Ld.n` number references,
and every present address is below the counter (kernel evaluation of the Boolean checks, block by
block over `Ld.gks` (`Ld.HS`, `Ld.BD`), and at the present ones of the template tooling's framed
addresses `framedList`). -/

kernel_rfl Ld.suppFramed : framedList.all (fun a => !presentB Ld.s0 a || Ld.suppAt a) = true
kernel_rfl Ld.boundFramed : framedList.all (fun a => !presentB Ld.s0 a || Ld.boundAt a) = true
kernel_rfl Ld.rootsSupp_check : checkRootsSupp Ld.s0 Ld.n = true

/-- A property checked over the blocks and the present framed addresses holds at every present address. -/
theorem Ld.allPresent {p : Nat → Bool} (hb : ∀ q ∈ Ld.gks, ∀ a ∈ q.2, p a = true)
    (hf : framedList.all (fun a => !presentB Ld.s0 a || p a) = true) :
    ∀ a, Present Ld.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ framedList
  · have := List.all_eq_true.mp hf a hm
    have hpr : presentB Ld.s0 a = true := by simp [presentB, hg]
    simpa [hpr] using this
  · obtain ⟨q, hq, haq⟩ := Ld.cover a h hg hm
    exact hb q hq a haq

theorem Ld.heapSupp : ∀ a h, Ld.s0.heap.get a = some h → Supp.hobj (Present Ld.s0) Ld.n h := by
  intro a h ha
  have hp := Ld.allPresent Ld.HS.all Ld.suppFramed a (Present.of_get ha)
  unfold Ld.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem Ld.rootsSupp : Supp.ctl (Present Ld.s0) Ld.n Ld.s0.ctl ∧
    (∀ f ∈ Ld.s0.stack, Supp.frame (Present Ld.s0) Ld.n f) ∧
    (∀ j ∈ Ld.s0.jobs, Supp.job (Present Ld.s0) Ld.n j) ∧ Supp.stores (Present Ld.s0) Ld.n Ld.s0.stores :=
  checkRootsSupp_sound Ld.rootsSupp_check

theorem Ld.presentBound : ∀ a, Present Ld.s0 a → a < Ld.s0.next := by
  intro a ha
  have := Ld.allPresent Ld.BD.all Ld.boundFramed a ha
  unfold Ld.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Prompt
