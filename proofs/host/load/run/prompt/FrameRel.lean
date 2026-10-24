import host.sim.State
import host.sim.Support
import host.ts.StoreLaws
namespace Host.Load.Run.Prompt.FrameRel
open Host.Ts Host.Ts.Sim

/-! # One framed array between two otherwise equal states

A state `s` and the same state with the array at `a` holding other elements are related
by `Rel` (`RelF` without further frames) under the identity map, with the array framed:
template prefix `[]`, target prefix `fw` (`relF_frame`). What the relation needs of `s` beyond
that (its server, its native relation to itself, its closedness) is `Hyps`. -/

/-- The context framing the array at `a`: prefixes `[]` (template) and `fw` (target), the
source's trace as both bases, no counter offset, the handle band `[lo, hi)`. -/
def ctx {S : Type} (s : St S) (a : Nat) (fw : List Val) (lo hi : Nat) : Ctx :=
  ⟨fun b => bif Nat.beq b a then some ([], fw) else none, s.trace, s.trace, 0, lo, hi⟩

/-- What `Rel` needs of the source beyond the frame. -/
structure Hyps (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ν : Nat → F64) (S : SSrv) (C : CSrv)
    (lo hi : Nat) (s : St F.S) : Prop where
  srv : Srv Map.id ν S C
  ffi : FR Map.id S.tab.length s.ffi s.ffi
  band : hi ≤ 2 ^ 56
  presentBound : ∀ a, Present s a → a < s.next
  heapSupp : ∀ a h, s.heap.get a = some h → Supp.hobj (Present s) S.tab.length h
  ctlSupp : Supp.ctl (Present s) S.tab.length s.ctl
  stackSupp : ∀ f ∈ s.stack, Supp.frame (Present s) S.tab.length f
  jobsSupp : ∀ j ∈ s.jobs, Supp.job (Present s) S.tab.length j
  storesSupp : Supp.stores (Present s) S.tab.length s.stores

theorem ctx_fr {S : Type} (s : St S) (a b : Nat) (fw : List Val) (lo hi : Nat) :
    (ctx s a fw lo hi).fr b = if b = a then some ([], fw) else none := by
  simp only [ctx]
  by_cases h : b = a
  · subst h; simp
  · have : Nat.beq b a = false := by
      cases hq : Nat.beq b a
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true hq) h
    simp [h, this]

/-- **The frame**: `s` with the empty array at `a` is related to `s` with `fw` there. -/
theorem relF_frame {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    {lo hi : Nat} {s : St F.S} {a : Nat} {o : Obj} {fw : List Val}
    (h : Hyps F FR ν S C lo hi s) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array [])
    (ha : a / 4096 < 4 ^ 31) :
    Rel F FR Map.id ν (ctx s a fw lo hi) s S (s.setObj a { o with kind := .array fw }) C where
  srv := h.srv
  heap := by
    intro b hb hg
    show SlotOK Map.id (ctx s a fw lo hi).fr b hb ((s.heap.set a (.obj { o with kind := .array fw })).get b)
    by_cases hba : b = a
    · subst hba
      rw [SlotOK.some_iff (pre := []) (pre' := fw) (by rw [ctx_fr]; simp)]
      rw [ho] at hg
      refine ⟨o, { o with kind := .array fw }, (Option.some.inj hg).symm, PTrie.get_set_self _ _ _ ha, [], ?_, ?_⟩
      · rw [hk]; rfl
      · rw [Map.obj_id]; simp [Map.vals]
    · rw [SlotOK.none_iff (by rw [ctx_fr]; simp [hba]), PTrie.get_set_ne _ _ _ ha _ hba, hg, Map.hobj_id]
  next := fun _ => rfl
  offset := rfl
  room := by show 0 < bound; decide
  bigFixed := fun _ _ => rfl
  bigExt := fun _ _ _ => rfl
  band := h.band
  intr := fun _ _ => rfl
  bound := fun b hb => h.presentBound b hb
  inj := fun _ _ _ _ he => he
  presentBound := h.presentBound
  framedPresent := by
    intro b p hp
    rw [ctx_fr] at hp
    by_cases hba : b = a
    · subst hba; exact Present.of_get ho
    · simp [hba] at hp
  ctl := (Map.ctl_id _).symm
  stack := (List.map_id'' Map.frame_id _).symm
  jobs := (List.map_id'' Map.job_id _).symm
  stores := (Map.stores_id _).symm
  ffi := h.ffi
  trace := ⟨[], rfl, rfl⟩
  heapSupp := h.heapSupp
  ctlSupp := h.ctlSupp
  stackSupp := h.stackSupp
  jobsSupp := h.jobsSupp
  storesSupp := h.storesSupp
  traceSupp := ⟨[], rfl, by simp⟩

end Host.Load.Run.Prompt.FrameRel
