import host.ts.RenameParametricPropWrites
import host.ts.RenameParametricNativeCall
import host.ts.RenameWrites

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem StateR.setFfi {S : Type} {NR : NumV → NumV → Prop}
    {FR FR' : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (n n' : S) (hn : FR' R n n') :
    StateR NR FR' R live framed before after old old' (s.setFfi n) (s'.setFfi n') :=
  ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,hn,h.trace⟩

theorem StateR.traceCons {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (e e' : Event) (he : TreeR NR R (event e) (event e')) :
    StateR NR FR R live framed before after old old'
      (s.setTrace (e::s.trace)) (s'.setTrace (e'::s'.trace)) := by
  refine ⟨⟨h.heap.lookup,h.heap.sourceBound,h.heap.targetBound,h.heap.prefixLive,h.heap.inj,h.heap.fresh⟩,
    h.control,h.controlLive,h.stack,h.stackLive,h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,?_⟩
  obtain ⟨xs,ys,hx,hy,hr⟩ := h.trace
  exact ⟨e::xs,e'::ys,congrArg (e::·) hx,congrArg (e'::·) hy,.cons he hr⟩

theorem ObjectR.with_kind {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (k k' : Kind)
    (hk : TreeR NR R (Encode.kind k) (Encode.kind k')) :
    ObjectR NR R {o with kind := k} {o' with kind := k'} := by
  cases h with | node tag hs =>
    cases hs with | cons _ hs => exact .node _ (.cons hk hs)

theorem bytes_roles {NR : NumV → NumV → Prop} {R : Ren} {xs ys : List Byte}
    (h : ListR (ByteR NR R) xs ys) :
    TreeR NR R (Encode.seq (xs.map Encode.byte)) (Encode.seq (ys.map Encode.byte)) := by
  refine .node _ ?_
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (.byte h) ih

theorem kind_buffer {NR : NumV → NumV → Prop} {R : Ren} {xs : List Byte} {k : Kind}
    (h : TreeR NR R (Encode.kind (.buf xs)) (Encode.kind k)) :
    ∃ ys, k = .buf ys ∧ ListR (ByteR NR R) xs ys := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case buf ys =>
    refine ⟨ys,rfl,?_⟩
    cases h with | node tag hs =>
      cases hs with | cons hb hs =>
        cases hb with | node tag hs =>
          induction xs generalizing ys with
          | nil => cases ys <;> cases hs; exact .nil
          | cons x xs ih =>
            cases ys with
            | nil => cases hs
            | cons y ys =>
              cases hs with | cons h hs =>
                cases h with | byte h => exact .cons h (ih ys hs)

theorem HeapR.buffer_notFramed {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (o : Obj) (bs : List Byte)
    (ha : live a) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .buf bs) : ¬ framed a := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s'.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf => exact hf
  | framed hf hk₀ => rw [hk] at hk₀; cases hk₀

/-- The actual buffer patch preserves occurrence roles and the full live heap
frame, including objects not touched by the native write. -/
theorem StateR.write_buffer {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s')
    (a off : Nat) (o o' : Obj) (bs bs' ws ws' : List Byte)
    (ha : live a) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .buf bs)
    (hr : ObjectR NR R o o') (hol : treeSupport live (Encode.obj o))
    (hb : ListR (ByteR NR R) bs bs') (hw : ListR (ByteR NR R) ws ws')
    (hs : a < 2^64) (ht : R.a a < 2^64) :
    StateR NR FR R live framed before after old old'
      (s.setObj a {o with kind := .buf (bs.take off ++ ws ++ bs.drop (off + len ws))})
      (s'.setObj (R.a a) {o' with kind := .buf (bs'.take off ++ ws' ++ bs'.drop (off + len ws'))}) := by
  have hp : ListR (ByteR NR R)
      (bs.take off ++ ws ++ bs.drop (off + len ws))
      (bs'.take off ++ ws' ++ bs'.drop (off + len ws')) := by
    rw [← hw.len_eq]
    exact ((hb.take off).append hw).append (hb.drop (off + len ws))
  have support : ∀ bytes : List Byte, treeSupport live (Encode.kind (.buf bytes)) := by
    intro bytes
    refine ⟨?_,True.intro⟩
    induction bytes with
    | nil => exact True.intro
    | cons b bs ih => exact ⟨True.intro,ih⟩
  exact h.setObject a _ _ ha (h.heap.buffer_notFramed a o bs ha ho hk)
    (hr.with_kind _ _ (.node _ (.cons (bytes_roles hp) .nil)))
    ⟨support _,hol.2⟩ hs ht

end Host.Ts.Owned.Parametric
