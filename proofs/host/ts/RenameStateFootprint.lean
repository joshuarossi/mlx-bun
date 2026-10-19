import host.ts.RenameParametricState

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Source-only closure of one selected heap slot. Framed arrays retain the
suffix owned by this execution; the caller's prefix is still abstract. -/
inductive SlotSupport (live framed : Nat → Prop) (before : List Val) (a : Nat) : Option HObj → Prop where
  | absent : ¬ framed a → SlotSupport live framed before a none
  | regular {object : HObj} : ¬ framed a → treeSupport live (Encode.hobj object) →
      SlotSupport live framed before a (some object)
  | framed {object : Obj} {values : List Val} : framed a → object.kind = .array (before ++ values) →
      listSupport (valueSupport live) values → treeSupport live (Encode.header object) →
      SlotSupport live framed before a (some (.obj object))

/-- Restrict the footprint without changing a heap, value interpretation,
resource map, or the caller's framed prefix. -/
theorem SlotR.restrict_live {NR : NumV → NumV → Prop} {R : Ren}
    {live small framed : Nat → Prop} {before after : List Val} {a : Nat} {source target : Option HObj}
    (related : SlotR NR R live framed before after a source target)
    (closed : SlotSupport small framed before a source) :
    SlotR NR R small framed before after a source target := by
  cases related with
  | absent notFramed => exact .absent notFramed
  | regular notFramed relation _ =>
    cases closed with
    | regular _ supported => exact .regular notFramed relation supported
    | framed isFramed _ _ _ => exact False.elim (notFramed isFramed)
  | @framed object other values otherValues isFramed kind otherKind relation header _ _ =>
    cases closed with
    | regular notFramed _ => exact False.elim (notFramed isFramed)
    | @framed _ newValues _ newKind supported headerSupported =>
      have same : values = newValues := List.append_cancel_left (Kind.array.inj (kind.symm.trans newKind))
      exact .framed isFramed kind otherKind relation header (same.symm ▸ supported) headerSupported

theorem HeapR.restrict_live {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live small framed : Nat → Prop} {before after : List Val} {source target : St S}
    (heap : HeapR NR R live framed before after source target)
    (subset : ∀ a, small a → live a)
    (closed : ∀ a, small a → SlotSupport small framed before a (source.heap.get a))
    (framedLive : ∀ a, framed a → small a) :
    HeapR NR R small framed before after source target :=
  ⟨fun a alive => (heap.lookup a (subset a alive)).restrict_live (closed a alive),
    fun a alive => heap.sourceBound a (subset a alive),
    fun a alive => heap.targetBound a (subset a alive),framedLive,
    fun a b alive other => heap.inj a b (subset a alive) (subset b other),heap.fresh⟩

/-- A checked source footprint may discard unreachable old allocations while
retaining the complete control, stack, jobs, stores, native and trace relation.
This restricts an existing relation; it does not assert a loop restart. -/
theorem StateR.restrict_live {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live small framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St S}
    (state : StateR NR FR R live framed before after old old' source target)
    (subset : ∀ a, small a → live a)
    (closed : ∀ a, small a → SlotSupport small framed before a (source.heap.get a))
    (framedLive : ∀ a, framed a → small a)
    (control : treeSupport small (Encode.ctl source.ctl))
    (stack : listSupport (fun f => treeSupport small (Encode.frame f)) source.stack)
    (jobs : listSupport (fun j => treeSupport small (Encode.job j)) source.jobs)
    (stores : treeSupport small (Encode.stores source.stores)) :
    StateR NR FR R small framed before after old old' source target :=
  ⟨state.heap.restrict_live subset closed framedLive,state.control,control,state.stack,stack,
    state.jobs,jobs,state.stores,stores,state.native,state.trace⟩

end Host.Ts.Owned.Parametric
