import host.ts.RenameIntegerPacking
namespace Host.Ts.Owned.Parametric

theorem valueSupport_mono {p q : Nat → Prop} (h : ∀ a, p a → q a) :
    ∀ v, valueSupport p v → valueSupport q v := by
  intro v hv
  cases v with
  | obj a => exact h a hv
  | sym a => exact hv.elim Or.inl (fun hp => Or.inr (h _ hp))
  | ptr m off => cases m with
    | js a => exact h a hv
    | ext a => exact True.intro
  | _ => exact True.intro

mutual
  theorem treeSupport_mono {p q : Nat → Prop} (h : ∀ a, p a → q a)
      (t : Tree) : treeSupport p t → treeSupport q t :=
    match t with
    | .atom _ _ => id
    | .value v => valueSupport_mono h v
    | .cell _ => id
    | .byte _ => id
    | .address a => h a
    | .symbol _ => fun hp => hp.elim Or.inl (fun hp => Or.inr (h _ hp))
    | .region _ => id
    | .number _ => id
    | .node _ xs => forestSupport_mono h xs
  theorem forestSupport_mono {p q : Nat → Prop} (h : ∀ a, p a → q a)
      (xs : List Tree) : forestSupport p xs → forestSupport q xs :=
    match xs with
    | [] => id
    | x :: xs => fun hp => ⟨treeSupport_mono h x hp.1,forestSupport_mono h xs hp.2⟩
end

theorem listSupport_mono {α : Type} {p q : α → Prop} (h : ∀ a, p a → q a) :
    ∀ xs, listSupport p xs → listSupport q xs
  | [], hp => hp
  | x :: xs, hp => ⟨h x hp.1,listSupport_mono h xs hp.2⟩

theorem SlotR.grow {NR : NumV → NumV → Prop} {R : Ren} {live live' framed : Nat → Prop}
    {before after : List Val} {a : Nat} {o o' : Option HObj}
    (h : SlotR NR R live framed before after a o o') (hg : ∀ a, live a → live' a) :
    SlotR NR R live' framed before after a o o' := by
  cases h with
  | absent hf => exact .absent hf
  | regular hf hr hl => exact .regular hf hr (treeSupport_mono hg _ hl)
  | framed hf hk hk' hv hh hl hhLive =>
    exact .framed hf hk hk' hv hh (listSupport_mono (valueSupport_mono hg) _ hl)
      (treeSupport_mono hg _ hhLive)

def LiveAfter (live : Nat → Prop) (fresh : Nat) : Nat → Prop := fun a => live a ∨ a = fresh

/-- Allocating actual paired heap objects extends live support by exactly the
fresh cell. Old unreachable graph/heap slots need not be related. -/
theorem HeapR.alloc {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (o o' : HObj)
    (hr : HeapObjectR NR R o o')
    (hl : treeSupport (LiveAfter live s.next) (Encode.hobj o))
    (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    HeapR NR R (LiveAfter live s.next) framed before after (s.alloc o).2 (s'.alloc o').2 := by
  have hn : R.a s.next = s'.next := by simpa only [Nat.add_zero] using h.fresh 0
  have hg : ∀ a, live a → LiveAfter live s.next a := fun _ ha => Or.inl ha
  have hnf : ¬ framed s.next := fun hf => (Nat.lt_irrefl s.next) (h.sourceBound _ (h.prefixLive _ hf))
  constructor
  · intro a ha
    by_cases he : a = s.next
    · subst a
      simp only [St.alloc,hn,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht,ite_true]
      exact .regular hnf hr hl
    · have ha : live a := ha.elim id (fun heq => False.elim (he heq))
      have hne : R.a a ≠ s'.next := Nat.ne_of_lt (h.targetBound _ ha)
      simpa only [St.alloc,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht,
        ite_eq_right he,ite_eq_right hne] using (h.lookup a ha).grow hg
  · intro a ha
    change a < s.next + 1
    exact ha.elim (fun ha => Nat.lt_trans (h.sourceBound _ ha) (Nat.lt_succ_self _))
      (fun he => he ▸ Nat.lt_succ_self _)
  · intro a ha
    change R.a a < s'.next + 1
    exact ha.elim (fun ha => Nat.lt_trans (h.targetBound _ ha) (Nat.lt_succ_self _))
      (fun he => by rw [he,hn]; exact Nat.lt_succ_self _)
  · intro a ha
    exact Or.inl (h.prefixLive a ha)
  · intro a b ha hb he
    rcases ha with ha | rfl <;> rcases hb with hb | rfl
    · exact h.inj a b ha hb he
    · have ht' := h.targetBound a ha
      rw [hn] at he
      omega
    · have ht' := h.targetBound b hb
      rw [hn] at he
      omega
    · rfl
  · intro k
    change R.a (s.next + 1 + k) = s'.next + 1 + k
    simpa only [Nat.add_assoc] using h.fresh (1+k)

/-- Whole-state heap allocation: every runtime support predicate is extended,
while control, pending jobs, stores, trace frame and native resources are retained. -/
theorem StateR.alloc {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s') (o o' : HObj)
    (hr : HeapObjectR NR R o o')
    (hl : treeSupport (LiveAfter live s.next) (Encode.hobj o))
    (hs : s.next < 2 ^ 64) (ht : s'.next < 2 ^ 64) :
    StateR NR FR R (LiveAfter live s.next) framed before after old old' (s.alloc o).2 (s'.alloc o').2 := by
  have hg : ∀ a, live a → LiveAfter live s.next a := fun _ ha => Or.inl ha
  exact ⟨h.heap.alloc o o' hr hl hs ht,h.control,treeSupport_mono hg _ h.controlLive,h.stack,
    listSupport_mono (fun _ => treeSupport_mono hg _) _ h.stackLive,h.jobs,
    listSupport_mono (fun _ => treeSupport_mono hg _) _ h.jobsLive,h.stores,
    treeSupport_mono hg _ h.storesLive,h.native,h.trace⟩


/-- Actual empty-array source evaluation, including its fresh heap allocation. -/
theorem step_empty_array_eq (F : Ffi) (s : St F.S) (env : Env)
    (hc : s.ctl = .ev (.array []) env) :
    step F s = M.pure ((s.alloc (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩)).2.ret (.obj s.next)) := by
  simp only [step,hc,evStep,arrayNext,newArray,St.allocObj,retS]
  rfl

/-- The true source array constructor preserves full runtime roles and extends
fresh-address support. Its prototype is one of the fixed live intrinsics. -/
theorem step_empty_array_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (env₀ env : Env)
    (hc₀ : s₀.ctl = .ev (.array []) env₀) (hc : s.ctl = .ev (.array []) env)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2 ^ 64) (ht : s.next < 2 ^ 64) :
    let o : HObj := .obj ⟨.array [],.obj aArrayProto,[],[],true⟩
    interpC (step F s₀).run C₀ = some ((s₀.alloc o).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C = some ((s.alloc o).2.ret (.obj s.next),C) ∧
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc o).2.ret (.obj s₀.next)) ((s.alloc o).2.ret (.obj s.next)) := by
  dsimp only
  have hproto : ValueR NR R (.obj aArrayProto) (.obj aArrayProto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) aArrayProto)
  have ho : HeapObjectR NR R (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩)
      (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩) :=
    .obj (.node _ (.cons (.node _ (.cons (.node _ .nil) .nil))
      (.cons (.value hproto) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have hol : treeSupport (LiveAfter live s₀.next)
      (Encode.hobj (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩)) :=
    ⟨⟨⟨True.intro,True.intro⟩,Or.inl hp,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have hh := h.alloc _ _ ho hol hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have hv : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [hn] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  refine ⟨?_,?_,hh.go (.node _ (.cons (.value hv) .nil)) ⟨Or.inr rfl,True.intro⟩⟩
  · rw [step_empty_array_eq F s₀ env₀ hc₀]; rfl
  · rw [step_empty_array_eq F s env hc]; rfl

end Host.Ts.Owned.Parametric
