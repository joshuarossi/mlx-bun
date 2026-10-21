import host.sim.template.base.Keys
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Closedness of the template `Base.s0`: every heap entry, the control, the
stack, the jobs and the stores mention only present addresses and the first
`Base.n` number references (kernel evaluation of the Boolean checks, block by
block over `Base.ukeys`, and the two framed arrays). -/

/-- The template's number references. -/
abbrev Base.n : Nat := 112

kernel_rfl Base.tab_len : Base.S0.tab.length = Base.n

/-- The support check of the entry at `a`. -/
noncomputable def Base.suppAt (a : Nat) : Bool :=
  match Base.s0.heap.get a with
  | some h => bHobj (presentB Base.s0) Base.n h
  | none => true

/-- Present addresses are below the counter. -/
noncomputable def Base.boundAt (a : Nat) : Bool := Nat.blt a Base.s0.next

tpl_all_blocks Base.HS from Base : Base.suppAt
kernel_rfl Base.suppFramed : framedList.all Base.suppAt = true
tpl_all_blocks Base.BD from Base : Base.boundAt
kernel_rfl Base.boundFramed : framedList.all Base.boundAt = true
kernel_rfl Base.rootsSupp_check : checkRootsSupp Base.s0 Base.n = true

-- The token read at the cut is the only template entry mentioning `var 14`.
kernel_rfl Base.token_ref : ((List.range Base.S0.tab.length).filter fun i => (nth? Base.S0.tab i).any (symOcc 14)) = [79]

/-- A property checked over the blocks and the framed arrays holds at every present address. -/
theorem Base.allPresent {p : Nat → Bool} (hb : ∀ q ∈ Base.gks, ∀ a ∈ q.2, p a = true) (hf : framedList.all p = true) :
    ∀ a, Present Base.s0 a → p a = true := by
  intro a ha
  obtain ⟨h, hg⟩ := Present.get ha
  by_cases hm : a ∈ framedList
  · exact List.all_eq_true.mp hf a hm
  · obtain ⟨q, hq, haq⟩ := Base.cover a h hg hm
    exact hb q hq a haq

theorem Base.heapSupp : ∀ a h, Base.s0.heap.get a = some h → Supp.hobj (Present Base.s0) Base.n h := by
  intro a h ha
  have hp := Base.allPresent Base.HS.all Base.suppFramed a (Present.of_get ha)
  unfold Base.suppAt at hp
  rw [ha] at hp
  exact bHobj_sound hp

theorem Base.rootsSupp : Supp.ctl (Present Base.s0) Base.n Base.s0.ctl ∧
    (∀ f ∈ Base.s0.stack, Supp.frame (Present Base.s0) Base.n f) ∧
    (∀ j ∈ Base.s0.jobs, Supp.job (Present Base.s0) Base.n j) ∧ Supp.stores (Present Base.s0) Base.n Base.s0.stores :=
  checkRootsSupp_sound Base.rootsSupp_check

theorem Base.presentBound : ∀ a, Present Base.s0 a → a < Base.s0.next := by
  intro a ha
  have := Base.allPresent Base.BD.all Base.boundFramed a ha
  unfold Base.boundAt at this
  simpa [Nat.blt_eq] using this

end Host.Load.Run.Tpl
