import host.mlx.NativeRoles

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned

variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

theorem handle_ne_zero (h : Live NR R NodeRel ObjRel H N tail s s')
    {a : Nat} (ha : H a) (hne : a ≠ 0) : R.handle a ≠ 0 := by
  intro he
  have hab := h.liveHandleBound a ha
  have hz : 0 < s.next := by omega
  have heq : R.handle a = R.handle 0 := he.trans h.handleZero.symm
  exact hne (h.handleMap.injective a 0 hab hz heq)

/-- Reassigning a live non-null output slot preserves all other native
resources. The new producer must already be in the selected live graph. -/
theorem setArr_nonzero (h : Live NR R NodeRel ObjRel H N tail s s')
    (a i : Nat) (ha : H a) (hi : N i) (hne : a ≠ 0)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    Live NR R NodeRel ObjRel H N tail
      (s.setArr a i).2 (s'.setArr (R.handle a) (R.node i)).2 := by
  have hne' := h.handle_ne_zero ha hne
  have hb : Nat.beq a 0 = false := by
    cases he : Nat.beq a 0
    · rfl
    · exact False.elim (hne (Nat.eq_of_beq_eq_true he))
  have hb' : Nat.beq (R.handle a) 0 = false := by
    cases he : Nat.beq (R.handle a) 0
    · rfl
    · exact False.elim (hne' (Nat.eq_of_beq_eq_true he))
  simp only [St.setArr, hb, hb']
  refine { h with arrs := ?_, arrLive := ?_, sourceArrsBound := ?_, targetArrsBound := ?_ }
  · intro b hbl
    change (s'.arrs.set (R.handle a) (R.node i)).get (R.handle b) =
      ((s.arrs.set a i).get b).map R.node
    rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
    have he : R.handle b = R.handle a ↔ b = a :=
      ⟨h.handleMap.injective b a (h.liveHandleBound b hbl) (h.liveHandleBound a ha), congrArg R.handle⟩
    by_cases hba : b = a
    · simp only [hba, ite_true, Option.map_some]
    · rw [ite_eq_right hba, ite_eq_right (mt he.mp hba)]
      exact h.arrs b hbl
  · intro b j hbl hj
    change (s.arrs.set a i).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bs] at hj
    by_cases hba : b = a
    · rw [ite_eq_left hba] at hj
      exact Option.some.inj hj ▸ hi
    · rw [ite_eq_right hba] at hj
      exact h.arrLive b j hbl hj
  · intro b j hj
    change (s.arrs.set a i).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bs] at hj
    by_cases hba : b = a
    · subst b; exact h.liveHandleBound a ha
    · rw [ite_eq_right hba] at hj
      exact h.sourceArrsBound b j hj
  · intro b j hj
    change (s'.arrs.set (R.handle a) (R.node i)).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bt] at hj
    by_cases hba : b = R.handle a
    · subst b; exact h.handleMap.bound a (h.liveHandleBound a ha)
    · rw [ite_eq_right hba] at hj
      exact h.targetArrsBound b j hj

/-- Updating an existing live vector, closure, or kernel configuration keeps
the selected object relation and frames every other live resource. -/
theorem setObj (h : Live NR R NodeRel ObjRel H N tail s s')
    (a : Nat) (ha : H a) (o o' : Obj) (ho : ObjRel a o o')
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    Live NR R NodeRel ObjRel H N tail
      (s.setObj a o) (s'.setObj (R.handle a) o') := by
  refine { h with objs := ?_, sourceObjsBound := ?_, targetObjsBound := ?_ }
  · intro b hbl
    change OptionR (ObjRel b) ((s.objs.set a o).get b)
      ((s'.objs.set (R.handle a) o').get (R.handle b))
    rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
    have he : R.handle b = R.handle a ↔ b = a :=
      ⟨h.handleMap.injective b a (h.liveHandleBound b hbl) (h.liveHandleBound a ha), congrArg R.handle⟩
    by_cases hba : b = a
    · subst b; simp only [ite_true]; exact .some ho
    · rw [ite_eq_right hba, ite_eq_right (mt he.mp hba)]
      exact h.objs b hbl
  · intro b obj hb
    change (s.objs.set a o).get b = some obj at hb
    rw [PTrie.get_set_u64 _ _ _ bs] at hb
    by_cases hba : b = a
    · subst b; exact h.liveHandleBound a ha
    · rw [ite_eq_right hba] at hb
      exact h.sourceObjsBound b obj hb
  · intro b obj hb
    change (s'.objs.set (R.handle a) o').get b = some obj at hb
    rw [PTrie.get_set_u64 _ _ _ bt] at hb
    by_cases hba : b = R.handle a
    · subst b; exact h.handleMap.bound a (h.liveHandleBound a ha)
    · rw [ite_eq_right hba] at hb
      exact h.targetObjsBound b obj hb

/-- A released handle is removed from live support. Its old graph remains
available through other handles and native vectors. -/
theorem freeArr_nonzero (h : Live NR R NodeRel ObjRel H N tail s s')
    (a : Nat) (ha : H a) (hne : a ≠ 0)
    (bs : a < 2^64) (bt : R.handle a < 2^64) :
    Live NR R NodeRel ObjRel (fun b => H b ∧ b ≠ a) N tail
      (s.freeArr a) (s'.freeArr (R.handle a)) := by
  have hne' := h.handle_ne_zero ha hne
  have hb : Nat.beq a 0 = false := by
    cases he : Nat.beq a 0
    · rfl
    · exact False.elim (hne (Nat.eq_of_beq_eq_true he))
  have hb' : Nat.beq (R.handle a) 0 = false := by
    cases he : Nat.beq (R.handle a) 0
    · rfl
    · exact False.elim (hne' (Nat.eq_of_beq_eq_true he))
  simp only [St.freeArr, hb, hb']
  refine { h with arrs := ?_, objs := ?_, arrLive := ?_, liveHandleBound := ?_, sourceArrsBound := ?_, targetArrsBound := ?_ }
  · intro b hbl
    change (s'.arrs.set (R.handle a) 0).get (R.handle b) =
      ((s.arrs.set a 0).get b).map R.node
    have hne : R.handle b ≠ R.handle a := by
      intro he
      exact hbl.2 (h.handleMap.injective b a (h.liveHandleBound b hbl.1)
        (h.liveHandleBound a ha) he)
    rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt,
      ite_eq_right hbl.2, ite_eq_right hne]
    exact h.arrs b hbl.1
  · intro b hbl; exact h.objs b hbl.1
  · intro b j hbl hj
    change (s.arrs.set a 0).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bs, ite_eq_right hbl.2] at hj
    exact h.arrLive b j hbl.1 hj
  · intro b hbl; exact h.liveHandleBound b hbl.1
  · intro b j hj
    change (s.arrs.set a 0).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bs] at hj
    by_cases hba : b = a
    · subst b; exact h.liveHandleBound a ha
    · rw [ite_eq_right hba] at hj
      exact h.sourceArrsBound b j hj
  · intro b j hj
    change (s'.arrs.set (R.handle a) 0).get b = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bt] at hj
    by_cases hba : b = R.handle a
    · subst b; exact h.handleMap.bound a (h.liveHandleBound a ha)
    · rw [ite_eq_right hba] at hj
      exact h.targetArrsBound b j hj

/-- Recording a first read consumes exactly the related queue head. The
target's arbitrary future suffix is retained without numeric injectivity. -/
theorem recordRead (h : Live NR R NodeRel ObjRel H N tail s s')
    (i : Nat) (hi : N i) (t : NumV) (ts : List NumV) (ht : s.tokens = t :: ts)
    (bs : i < 2^64) (bt : R.node i < 2^64) :
    ∃ t' known, NR t t' ∧ ListR NR ts known ∧ s'.tokens = t' :: (known ++ tail) ∧
      Live NR R NodeRel ObjRel H N tail
        { s with tokens := ts, items := s.items.set i t }
        { s' with tokens := known ++ tail, items := s'.items.set (R.node i) t' } := by
  obtain ⟨t', known, hn, hk, he⟩ := h.tokens_cons ht
  refine ⟨t', known, hn, hk, he, { h with items := ?_, tokens := ?_, sourceItemsBound := ?_, targetItemsBound := ?_ }⟩
  · intro j hj
    change OptionR NR ((s.items.set i t).get j)
      ((s'.items.set (R.node i) t').get (R.node j))
    rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
    have heq : R.node j = R.node i ↔ j = i :=
      ⟨h.nodeMap.injective j i (h.liveNodeBound j hj) (h.liveNodeBound i hi), congrArg R.node⟩
    by_cases hji : j = i
    · simp only [hji, ite_true]; exact .some hn
    · rw [ite_eq_right hji, ite_eq_right (mt heq.mp hji)]
      exact h.items j hj
  · exact ⟨known, hk, rfl⟩
  · intro j v hv
    change (s.items.set i t).get j = some v at hv
    rw [PTrie.get_set_u64 _ _ _ bs] at hv
    by_cases hji : j = i
    · subst j; exact h.liveNodeBound i hi
    · rw [ite_eq_right hji] at hv
      exact h.sourceItemsBound j v hv
  · intro j v hv
    change (s'.items.set (R.node i) t').get j = some v at hv
    rw [PTrie.get_set_u64 _ _ _ bt] at hv
    by_cases hji : j = R.node i
    · subst j; exact h.nodeMap.bound i (h.liveNodeBound i hi)
    · rw [ite_eq_right hji] at hv
      exact h.targetItemsBound j v hv

end Host.Mlx.Ffi.NativeRoles.Live
