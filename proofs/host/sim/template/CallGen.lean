import host.sim.conv.Merge
import host.sim.world.IterCut
import host.sim.template.ShiftJS
import host.sim.stage.Mlx
import host.sim.conv.CompactShift
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim
open Host.Ts.Sim.Prefill (NumRefs)

/-! # A chain's call links and end as the chain generator states them

`genChain.ts` states a stage instance's footprint as its Foot module's heap equality (`Stage.setAll` of
the written and fresh entries) and the merged and end states' framed arrays as their elements past the
template start's (`arrOf`); here they become `Conv.StageFoot` (`stageFoot_of`), the arrays' shapes
(`arrExt_of`) and `NumRefs` (`numRefs_of`), which `Compose.cut_compactQ` and `IterEndW` take. -/

/-- **A stage template's footprint** from its heap equality: the written and fresh entries, distinct and
in range, those below the start's counter present at the start. -/
theorem stageFoot_of {S : Type} {s0 s2 : St S} {wrE : List (Nat × HObj)}
    (hh : s2.heap = Stage.setAll s0.heap wrE) (hnd : (wrE.map (·.1)).Nodup)
    (hbd : ∀ b ∈ wrE.map (·.1), b / 4096 < 4 ^ 31)
    (h0 : (wrE.map (·.1)).all (fun b => !Nat.blt b s0.next || (s0.heap.get b).isSome) = true)
    (hg : s0.next ≤ s2.next) : Conv.StageFoot (wrE.map (·.1)) s0 s2 where
  wrP b hb := by
    obtain ⟨⟨b', v⟩, hm, rfl⟩ := List.mem_map.1 hb
    show (s2.heap.get b').isSome = true
    rw [hh, Stage.setAll_get_mem _ _ _ _ hnd hm (fun e he => hbd _ (List.mem_map_of_mem he))]
    rfl
  wr0 b hb hlt := by
    have := List.all_eq_true.mp h0 b hb
    rw [Nat.blt_eq.mpr hlt] at this
    show (s0.heap.get b).isSome = true
    simpa using this
  same b hb := by
    rw [hh]
    exact Stage.setAll_get _ _ _ fun e he =>
      ⟨fun h => hb (h ▸ List.mem_map_of_mem (f := (·.1)) he), hbd _ (List.mem_map_of_mem he)⟩
  grows := hg

/-- The heap entry at `a` is an array object. -/
def isArrB {S : Type} (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some (.obj o) => match o.kind with
    | .array _ => true
    | _ => false
  | _ => false

/-- **An array extended past a start's** (`Compose.cut_compactQ`'s `hfwd`, `hemit`; `IterEndW.fwd`, `emit`). -/
theorem arrExt_of {S S' : Type} {s : St S} {s0 : St S'} {a : Nat} {els : List Val}
    (h1 : arrOf s a = arrOf s0 a ++ els) (h2 : isArrB s a = true) :
    ∃ o, s.heap.get a = some (.obj o) ∧ o.kind = .array (arrOf s0 a ++ els) := by
  unfold isArrB at h2
  cases hg : s.heap.get a with
  | none => rw [hg] at h2; simp at h2
  | some v =>
    rw [hg] at h2
    cases v with
    | obj o =>
      cases hk : o.kind with
      | array es =>
        refine ⟨o, rfl, ?_⟩
        have he : arrOf s a = es := by unfold arrOf; rw [hg]; simp only [hk]
        rw [hk, ← h1, he]
      | _ => simp [hk] at h2
    | _ => simp at h2

/-- An address holding no array (a wide frame's map). -/
theorem notArr_of {S : Type} {s : St S} {a : Nat} (h : isArrB s a = false) {o : Obj} {es : List Val}
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array es) : False := by
  unfold isArrB at h
  rw [ho] at h
  simp only [hk] at h
  cases h

/-- The values are references below `n`. -/
def numRefsB (n : Nat) (vs : List Val) : Bool :=
  vs.all fun v => match v with
    | .num (.ref j) => Nat.blt j n
    | _ => false

theorem numRefs_of {n : Nat} {vs : List Val} (h : numRefsB n vs = true) : NumRefs n vs := by
  intro v hv
  have := List.all_eq_true.mp h v hv
  match v, this with
  | .num (.ref j), hj => exact ⟨j, Nat.blt_eq.mp hj, rfl⟩

/-- **The JS bookkeeping of a state whose present addresses are all checked** (a template's blocks and frames,
`tpl_all_blocks` over `Conv.jcleanAtB`). -/
theorem jclean_of_present {S : Type} {c : Conv.Cnt} {s : St S} (h : ∀ a, Present s a → Conv.jcleanAtB c s a = true) :
    Conv.JClean c s := fun a o ho =>
  Conv.jcleanListB_sound (l := [a])
    (by simp only [Conv.jcleanListB, List.all_cons, List.all_nil, Bool.and_true]; exact h a (Present.of_get ho))
    a (List.mem_singleton_self a) o ho

end Host.Ts.Sim.Template
