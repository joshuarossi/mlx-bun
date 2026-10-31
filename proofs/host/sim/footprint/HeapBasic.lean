import host.sim.conv.HeapFoot
import host.sim.steps.CbRet
import host.sim.full.Keep

namespace Host.Ts.Sim
open BufSim

/-- Attach the actual source and target runs without changing a simulation's relation. -/
theorem MSim.withRuns {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop}
    {S : SSrv} {C : CSrv} {m : Host.Ts.M α} {m' : Host.Ts.M β}
    (h : MSim P S C m m') (hs : Lawful m) (ht : Lawful m') :
    MSim (fun M' S' C' a b => P M' S' C' a b ∧
      interpS m.run S = some (a, S') ∧ interpC m'.run C = some (b, C')) S C m m' := by
  intro γ δ Q k k' hk r S2 hu
  rw [hs.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b, C1, hc, hp⟩ := MSim.run h a S1 hrun
    obtain ⟨M2, r', C2, hc', hq⟩ := hk M1 S1 C1 a b ⟨hp, hrun, hc⟩ r S2 hu
    exact ⟨M2, r', C2, by rw [ht.2, hc]; exact hc', hq⟩

namespace HeapFoot
open Conv
open Host.Mlx.Ffi.FullKeep (AllX)

theorem allX_fail {α : Type} (Q : α → Prop) (msg : String) : AllX Q (Host.Ts.M.fail msg) := by
  constructor <;> intro _ _ _ h <;> cases h

/-- A result changes neither the heap nor its allocation counter. -/
def Same {S : Type} (s u : St S) : Prop := u.heap = s.heap ∧ u.next = s.next

theorem same_foot {S : Type} {M : Map} {s t u v : St S}
    (hs : Same s u) (ht : Same t v) : HeapStepFoot M s t u v :=
  HeapStepFoot.sameHeap hs.1 hs.2 ht.1

/-- Heap footprints are insensitive to control, stack, auxiliary and native-state wrappers. -/
theorem congr {S : Type} {M : Map} {s t u v s' t' u' v' : St S}
    (h : HeapStepFoot M s t u v)
    (hs : Same s s') (ht : Same t t') (hu : Same u u') (hv : Same v v') :
    HeapStepFoot M s' t' u' v' where
  grows := by rw [hs.2, hu.2]; exact h.grows
  old a ha := by
    have hp : Present u a := by unfold Present at ha ⊢; rw [hu.1] at ha; exact ha
    rcases h.old a hp with hp | hp
    · exact .inl (by unfold Present at hp ⊢; rw [hs.1]; exact hp)
    · exact .inr (by rw [hs.2]; exact hp)
  kept a ha hn := by
    rw [hv.1, ht.1]
    apply h.kept a (by rw [← ht.2]; exact ha)
    intro b hb
    exact hn b (by unfold Present at hb ⊢; rw [hs.1]; exact hb)

/-- The existing step postcondition, with its actual heap footprint. -/
def Post (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (stk : List Frame) (M : Map) (ν : Nat → F64) (K : Ctx) (S : SSrv) (C : CSrv)
    (s t : St F.S) : Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  fun M' S' C' u v => StepPostB F FR W stk M ν K S C M' S' C' u v ∧ HeapStepFoot M s t u v

/-- Number-server work may extend number images; heap address images stay fixed. -/
theorem Post.after {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {stk : List Frame} {M M' : Map} {ν : Nat → F64} {K : Ctx} {S S' : SSrv} {C C' : CSrv}
    {s t : St F.S} {m m' : Host.Ts.M (St F.S)} (g : Grow M ν S C M' S' C')
    (h : MSim (Post F FR W stk M' ν K S' C' s t) S' C' m m') :
    MSim (Post F FR W stk M ν K S C s t) S' C' m m' := by
  apply h.mono
  rintro M2 S2 C2 u v ⟨⟨g2, hr⟩, hf⟩
  refine ⟨⟨g.trans g2, hr⟩, ?_⟩
  exact ⟨hf.grows, hf.old, fun a ha hn => hf.kept a ha (by rw [g.ext.a]; exact hn)⟩

theorem Post.start {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {S : SSrv} {C : CSrv}
    {s t s0 t0 : St F.S} {m m' : Host.Ts.M (St F.S)}
    (h : MSim (Post F FR W stk M ν K S C s t) S C m m') (hs : Same s s0) (ht : Same t t0) :
    MSim (Post F FR W stk M ν K S C s0 t0) S C m m' :=
  h.mono fun _ _ _ _ _ hp => ⟨hp.1, congr hp.2 hs ht ⟨rfl, rfl⟩ ⟨rfl, rfl⟩⟩

/-- Extract the footprint for any supplied successful pair of runs by determinism. -/
theorem Post.foot {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {S S1 : SSrv} {C C1 : CSrv}
    {s t s1 t1 : St F.S} {m m' : Host.Ts.M (St F.S)}
    (h : MSim (Post F FR W stk M ν K S C s t) S C m m')
    (hs : interpS m.run S = some (s1, S1)) (ht : interpC m'.run C = some (t1, C1)) :
    HeapStepFoot M s t s1 t1 := by
  obtain ⟨M', v, C', hv, hp⟩ := MSim.run h s1 S1 hs
  have e : (v, C') = (t1, C1) := Option.some.inj (hv.symm.trans ht)
  cases e
  exact hp.2

theorem ffiCallback_lawful (F : Ffi) (s : St F.S) (name : Name) (r : Nat) (args : List Arg) :
    Lawful (ffiCallback F s name r args) := by
  unfold ffiCallback
  refine Lawful.cond _ (Lawful.fail _) ?_
  split
  · split
    · refine Lawful.bind (elemsOf_lawful _ _ _) ?_
      intro tys
      cases tys
      · exact Lawful.fail _
      · exact Lawful.pure _
    · exact Lawful.fail _
  · exact Lawful.fail _

/-- Invoking a native callback reads its signature and changes only control and stack. -/
theorem ffiCallback_same (F : Ffi) (s : St F.S) (name : Name) (r : Nat) (args : List Arg) :
    AllX (Same s) (ffiCallback F s name r args) := by
  unfold ffiCallback
  refine AllX.cond _ ?_ ?_
  · exact allX_fail _ _
  · split
    · split
      · refine AllX.bind' (elemsOf_lawful _ _ _) ?_
        intro tys
        cases tys
        · exact allX_fail _ _
        · exact AllX.pure ⟨rfl, rfl⟩
      · exact allX_fail _ _
    · exact allX_fail _ _

end HeapFoot
end Host.Ts.Sim
