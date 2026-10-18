import host.mlx.OwnedMetadata

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Resource maps are injective below the allocation counters and pair all
future allocations by offset. Numeric meanings have no injectivity requirement. -/
structure CounterR (f : Nat → Nat) (source target : Nat) : Prop where
  bound : ∀ i, i < source → f i < target
  injective : ∀ i j, i < source → j < source → f i = f j → i = j
  fresh : ∀ k, f (source+k) = target+k

namespace CounterR
theorem head {f : Nat → Nat} {a b : Nat} (h : CounterR f a b) : f a = b := by
  simpa using h.fresh 0

theorem advance {f : Nat → Nat} {a b : Nat} (h : CounterR f a b) : CounterR f (a+1) (b+1) := by
  constructor
  · intro i hi
    by_cases he : i = a
    · subst i; rw [h.head]; omega
    · have hi' : i < a := by omega
      have := h.bound i hi'
      omega
  · intro i j hi hj he
    by_cases hi' : i = a <;> by_cases hj' : j = a
    · omega
    · subst i
      have hb := h.bound j (by omega)
      rw [h.head] at he
      omega
    · subst j
      have hb := h.bound i (by omega)
      rw [h.head] at he
      omega
    · exact h.injective i j (by omega) (by omega) he
  · intro k
    simpa only [Nat.add_assoc] using h.fresh (1+k)
end CounterR

inductive OptionR (rel : α → β → Prop) : Option α → Option β → Prop where
  | none : OptionR rel none none
  | some {a : α} {b : β} : rel a b → OptionR rel (some a) (some b)

theorem OptionR.mono {rel rel' : α → β → Prop} {x : Option α} {y : Option β}
    (h : OptionR rel x y) (m : ∀ a b, rel a b → rel' a b) : OptionR rel' x y := by
  cases h with
  | none => exact .none
  | some h => exact .some (m _ _ h)

private theorem list_mono {rel rel' : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR rel xs ys) (m : ∀ a b, rel a b → rel' a b) : ListR rel' xs ys := by
  induction h with
  | nil => exact .nil
  | cons h _ ih => exact .cons (m _ _ h) ih

structure NodeR (NR : NumV → NumV → Prop) (R : Ren) (PrimRel : Prim → Prim → Prop)
    (boundary : Nat → Prop) (i : Nat) (n n' : Node) : Prop where
  shape : Parametric.ShapeR NR n.shape n'.shape
  dtype : n'.dtype = n.dtype
  graph : boundary i ∨ (PrimRel n.prim n'.prim ∧ n'.ins = n.ins.map R.node)

/-- Only selected live resources are compared. Node and object relations are
explicit parameters: each primitive must prove the relation for the value it
creates. Earlier cache roots may use a shape-only relation, while new nodes
retain their full graph relation. Numeric values use the independent `NR`. -/
structure Live (NR : NumV → NumV → Prop) (R : Ren)
    (NodeRel : Nat → Node → Node → Prop) (ObjRel : Nat → Obj → Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV) (s s' : St) : Prop where
  arrs : ∀ h, H h → s'.arrs.get (R.handle h) = (s.arrs.get h).map R.node
  objs : ∀ h, H h → OptionR (ObjRel h) (s.objs.get h) (s'.objs.get (R.handle h))
  nodes : ∀ i, N i → OptionR (NodeRel i) (s.nodes.get i) (s'.nodes.get (R.node i))
  arrLive : ∀ h i, H h → s.arrs.get h = some i → N i
  items : ∀ i, N i → OptionR NR (s.items.get i) (s'.items.get (R.node i))
  tokens : ∃ known, ListR NR s.tokens known ∧ s'.tokens = known ++ tail
  pending : s'.pending = s.pending.map R.nativePending
  errh : OptionR (fun a b => Host.Ts.Owned.Parametric.TreeR NR R
    (Host.Ts.Owned.Parametric.arg a) (Host.Ts.Owned.Parametric.arg b)) s.errh s'.errh
  files : s'.files = s.files
  arch : s'.arch = s.arch
  deviceSizes : s'.deviceSizes = s.deviceSizes
  wired : s'.wired = s.wired
  liveHandleBound : ∀ h, H h → h < s.next
  liveNodeBound : ∀ i, N i → i < s.nnext
  handleMap : CounterR R.handle s.next s'.next
  nodeMap : CounterR R.node s.nnext s'.nnext
  sourceItemsBound : ∀ i t, s.items.get i = some t → i < s.nnext
  targetItemsBound : ∀ i t, s'.items.get i = some t → i < s'.nnext
  sourceObjsBound : ∀ h o, s.objs.get h = some o → h < s.next
  targetObjsBound : ∀ h o, s'.objs.get h = some o → h < s'.next
  sourceArrsBound : ∀ h i, s.arrs.get h = some i → h < s.next
  targetArrsBound : ∀ h i, s'.arrs.get h = some i → h < s'.next
  handleZero : R.handle 0 = 0

namespace Live
variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

/-- Extending numeric tables weakens their denotation relation. All live
numeric fields can be transported without changing resource maps or states. -/
theorem mono {NR' : NumV → NumV → Prop}
    {NodeRel' : Nat → Node → Node → Prop} {ObjRel' : Nat → Obj → Obj → Prop}
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (numbers : ∀ a b, NR a b → NR' a b)
    (nodes : ∀ i n n', NodeRel i n n' → NodeRel' i n n')
    (objects : ∀ i o o', ObjRel i o o' → ObjRel' i o o') :
    Live NR' R NodeRel' ObjRel' H N tail s s' := by
  refine {
    arrs := h.arrs, objs := ?_, nodes := ?_, arrLive := h.arrLive, items := ?_,
    tokens := ?_, pending := h.pending, errh := ?_, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    liveHandleBound := h.liveHandleBound, liveNodeBound := h.liveNodeBound,
    handleMap := h.handleMap, nodeMap := h.nodeMap,
    sourceItemsBound := h.sourceItemsBound, targetItemsBound := h.targetItemsBound,
    sourceObjsBound := h.sourceObjsBound, targetObjsBound := h.targetObjsBound,
    sourceArrsBound := h.sourceArrsBound, targetArrsBound := h.targetArrsBound,
    handleZero := h.handleZero }
  · intro i hi; exact (h.objs i hi).mono (objects i)
  · intro i hi; exact (h.nodes i hi).mono (nodes i)
  · intro i hi; exact (h.items i hi).mono numbers
  · obtain ⟨known, hk, he⟩ := h.tokens
    exact ⟨known, list_mono hk numbers, he⟩
  · exact h.errh.mono (fun _ _ he => he.mono numbers)

theorem node_view (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat} (hi : N i)
    {n : Node} (hn : s.nodes.get i = some n) :
    ∃ n', s'.nodes.get (R.node i) = some n' ∧ NodeRel i n n' := by
  have hv := h.nodes i hi
  rw [hn] at hv
  cases ht : s'.nodes.get (R.node i) with
  | none => rw [ht] at hv; cases hv
  | some n' =>
    rw [ht] at hv
    cases hv with
    | some hr => exact ⟨n', rfl, hr⟩

theorem node? (h : Live NR R NodeRel ObjRel H N tail s s') {a : Nat} (ha : H a)
    {n : Node} (hn : s.node? a = some n) :
    ∃ i n', s.arrs.get a = some i ∧ s'.node? (R.handle a) = some n' ∧ NodeRel i n n' := by
  unfold St.node? at hn ⊢
  rw [h.arrs a ha]
  cases hs : s.arrs.get a with
  | none => simp only [hs, Option.bind_none] at hn; cases hn
  | some i =>
    simp only [hs, Option.bind_some] at hn
    obtain ⟨n', ht, hr⟩ := h.node_view (h.arrLive a i ha hs) hn
    exact ⟨i, n', rfl, by simp only [Option.map_some, Option.bind_some, ht], hr⟩

theorem tokens_cons (h : Live NR R NodeRel ObjRel H N tail s s')
    {t : NumV} {ts : List NumV} (ht : s.tokens = t :: ts) :
    ∃ t' known, NR t t' ∧ ListR NR ts known ∧ s'.tokens = t' :: (known ++ tail) := by
  obtain ⟨known, hk, he⟩ := h.tokens
  rw [ht] at hk
  cases hk with
  | cons hhead hrest => exact ⟨_, _, hhead, hrest, he⟩

theorem source_fresh_item (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s.nnext ≤ i) : s.items.get i = none := by
  cases he : s.items.get i with
  | none => rfl
  | some t => have := h.sourceItemsBound i t he; omega

theorem target_fresh_item (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s'.nnext ≤ i) : s'.items.get i = none := by
  cases he : s'.items.get i with
  | none => rfl
  | some t => have := h.targetItemsBound i t he; omega

theorem source_fresh_arr (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s.next ≤ i) : s.arrs.get i = none := by
  cases he : s.arrs.get i with
  | none => rfl
  | some n => have := h.sourceArrsBound i n he; omega

theorem target_fresh_arr (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s'.next ≤ i) : s'.arrs.get i = none := by
  cases he : s'.arrs.get i with
  | none => rfl
  | some n => have := h.targetArrsBound i n he; omega

theorem source_fresh_obj (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s.next ≤ i) : s.objs.get i = none := by
  cases he : s.objs.get i with
  | none => rfl
  | some o => have := h.sourceObjsBound i o he; omega

theorem target_fresh_obj (h : Live NR R NodeRel ObjRel H N tail s s') {i : Nat}
    (hi : s'.next ≤ i) : s'.objs.get i = none := by
  cases he : s'.objs.get i with
  | none => rfl
  | some o => have := h.targetObjsBound i o he; omega

/-- Actual native graph allocation preserves the live relation. The caller
supplies the new node's primitive/shape proof; no machine-step law is assumed. -/
theorem addNode (h : Live NR R NodeRel ObjRel H N tail s s') (n n' : Node)
    (hn : NodeRel s.nnext n n') (bs : s.nnext < 2^64) (bt : s'.nnext < 2^64) :
    Live NR R NodeRel ObjRel H (fun i => i = s.nnext ∨ N i) tail
      (s.addNode n).2 (s'.addNode n').2 := by
  have hf := h.nodeMap.head
  refine {
    arrs := h.arrs, objs := h.objs, arrLive := ?_, nodes := ?_, items := ?_,
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    liveHandleBound := h.liveHandleBound, liveNodeBound := ?_,
    handleMap := h.handleMap, nodeMap := h.nodeMap.advance,
    sourceItemsBound := ?_, targetItemsBound := ?_,
    sourceObjsBound := h.sourceObjsBound, targetObjsBound := h.targetObjsBound,
    sourceArrsBound := h.sourceArrsBound, targetArrsBound := h.targetArrsBound,
    handleZero := h.handleZero }
  · intro i hi
    change OptionR (NodeRel i) ((s.nodes.set s.nnext n).get i)
      ((s'.nodes.set s'.nnext n').get (R.node i))
    rcases hi with rfl | hi
    · rw [hf, PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
      simp only [ite_true]
      exact .some hn
    · have hib := h.liveNodeBound i hi
      have hir := h.nodeMap.bound i hib
      have hin : i ≠ s.nnext := by omega
      have hin' : R.node i ≠ s'.nnext := by omega
      rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt,
        ite_eq_right hin, ite_eq_right hin']
      exact h.nodes i hi
  · intro a i ha hi
    exact .inr (h.arrLive a i ha hi)
  · intro i hi
    rcases hi with rfl | hi
    · change OptionR NR (s.items.get s.nnext) (s'.items.get (R.node s.nnext))
      rw [hf, h.source_fresh_item (Nat.le_refl _), h.target_fresh_item (Nat.le_refl _)]
      exact .none
    · exact h.items i hi
  · intro i hi
    change i < s.nnext+1
    rcases hi with rfl | hi
    · omega
    · have := h.liveNodeBound i hi; omega
  · intro i t hi
    have := h.sourceItemsBound i t hi
    change i < s.nnext+1
    omega
  · intro i t hi
    have := h.targetItemsBound i t hi
    change i < s'.nnext+1
    omega

/-- The actual runtime-object allocator preserves occurrence-specific object
roles. Array slots at the newly allocated handle remain absent in both states. -/
theorem newObj (h : Live NR R NodeRel ObjRel H N tail s s') (o o' : Obj)
    (ho : ObjRel s.next o o') (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a) N tail
      (s.newObj o).2 (s'.newObj o').2 := by
  have hf := h.handleMap.head
  refine {
    arrs := ?_, objs := ?_, nodes := h.nodes, arrLive := ?_, items := h.items,
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    liveHandleBound := ?_, liveNodeBound := h.liveNodeBound,
    handleMap := h.handleMap.advance, nodeMap := h.nodeMap,
    sourceItemsBound := h.sourceItemsBound, targetItemsBound := h.targetItemsBound,
    sourceObjsBound := ?_, targetObjsBound := ?_,
    sourceArrsBound := ?_, targetArrsBound := ?_, handleZero := h.handleZero }
  · intro a ha
    rcases ha with rfl | ha
    · change s'.arrs.get (R.handle s.next) = (s.arrs.get s.next).map R.node
      rw [hf, h.source_fresh_arr (Nat.le_refl _), h.target_fresh_arr (Nat.le_refl _)]
      rfl
    · exact h.arrs a ha
  · intro a ha
    change OptionR (ObjRel a) ((s.objs.set s.next o).get a)
      ((s'.objs.set s'.next o').get (R.handle a))
    rcases ha with rfl | ha
    · rw [hf, PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
      simp only [ite_true]
      exact .some ho
    · have hab := h.liveHandleBound a ha
      have har := h.handleMap.bound a hab
      have hne : a ≠ s.next := by omega
      have hne' : R.handle a ≠ s'.next := by omega
      rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt,
        ite_eq_right hne, ite_eq_right hne']
      exact h.objs a ha
  · intro a i ha hi
    rcases ha with rfl | ha
    · change s.arrs.get s.next = some i at hi
      rw [h.source_fresh_arr (Nat.le_refl _)] at hi
      cases hi
    · exact h.arrLive a i ha hi
  · intro a ha
    change a < s.next+1
    rcases ha with rfl | ha
    · omega
    · have := h.liveHandleBound a ha; omega
  · intro a obj ha
    change (s.objs.set s.next o).get a = some obj at ha
    rw [PTrie.get_set_u64 _ _ _ bs] at ha
    change a < s.next+1
    by_cases he : a = s.next
    · omega
    · rw [ite_eq_right he] at ha
      have := h.sourceObjsBound a obj ha
      omega
  · intro a obj ha
    change (s'.objs.set s'.next o').get a = some obj at ha
    rw [PTrie.get_set_u64 _ _ _ bt] at ha
    change a < s'.next+1
    by_cases he : a = s'.next
    · omega
    · rw [ite_eq_right he] at ha
      have := h.targetObjsBound a obj ha
      omega
  · intro a i ha
    have := h.sourceArrsBound a i ha
    change a < s.next+1
    omega
  · intro a i ha
    have := h.targetArrsBound a i ha
    change a < s'.next+1
    omega

/-- A null result slot receives a fresh array handle pointing at the related
node. Other native objects, graph nodes, numeric items, and future reads remain
framed by the same relations. -/
theorem setArr_zero (h : Live NR R NodeRel ObjRel H N tail s s') (i : Nat) (hi : N i)
    (bs : s.next < 2^64) (bt : s'.next < 2^64) :
    Live NR R NodeRel ObjRel (fun a => a = s.next ∨ H a) N tail
      (s.setArr 0 i).2 (s'.setArr 0 (R.node i)).2 := by
  have hf := h.handleMap.head
  refine {
    arrs := ?_, objs := ?_, nodes := h.nodes, arrLive := ?_, items := h.items,
    tokens := h.tokens, pending := h.pending, errh := h.errh, files := h.files,
    arch := h.arch, deviceSizes := h.deviceSizes, wired := h.wired,
    liveHandleBound := ?_, liveNodeBound := h.liveNodeBound,
    handleMap := h.handleMap.advance, nodeMap := h.nodeMap,
    sourceItemsBound := h.sourceItemsBound, targetItemsBound := h.targetItemsBound,
    sourceObjsBound := ?_, targetObjsBound := ?_,
    sourceArrsBound := ?_, targetArrsBound := ?_, handleZero := h.handleZero }
  · intro a ha
    change (s'.arrs.set s'.next (R.node i)).get (R.handle a) =
      ((s.arrs.set s.next i).get a).map R.node
    rcases ha with rfl | ha
    · rw [hf, PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt]
      simp only [ite_true, Option.map_some]
    · have hab := h.liveHandleBound a ha
      have har := h.handleMap.bound a hab
      have hne : a ≠ s.next := by omega
      have hne' : R.handle a ≠ s'.next := by omega
      rw [PTrie.get_set_u64 _ _ _ bs, PTrie.get_set_u64 _ _ _ bt,
        ite_eq_right hne, ite_eq_right hne']
      exact h.arrs a ha
  · intro a ha
    rcases ha with rfl | ha
    · change OptionR (ObjRel s.next) (s.objs.get s.next) (s'.objs.get (R.handle s.next))
      rw [hf, h.source_fresh_obj (Nat.le_refl _), h.target_fresh_obj (Nat.le_refl _)]
      exact .none
    · exact h.objs a ha
  · intro a j ha hj
    change (s.arrs.set s.next i).get a = some j at hj
    rw [PTrie.get_set_u64 _ _ _ bs] at hj
    rcases ha with rfl | ha
    · simp only [ite_true] at hj
      have he : i = j := Option.some.inj hj
      subst j
      exact hi
    · have hne : a ≠ s.next := by have := h.liveHandleBound a ha; omega
      rw [ite_eq_right hne] at hj
      exact h.arrLive a j ha hj
  · intro a ha
    change a < s.next+1
    rcases ha with rfl | ha
    · omega
    · have := h.liveHandleBound a ha; omega
  · intro a o ha
    have := h.sourceObjsBound a o ha
    change a < s.next+1
    omega
  · intro a o ha
    have := h.targetObjsBound a o ha
    change a < s'.next+1
    omega
  · intro a j ha
    change (s.arrs.set s.next i).get a = some j at ha
    rw [PTrie.get_set_u64 _ _ _ bs] at ha
    change a < s.next+1
    by_cases he : a = s.next
    · omega
    · rw [ite_eq_right he] at ha
      have := h.sourceArrsBound a j ha
      omega
  · intro a j ha
    change (s'.arrs.set s'.next (R.node i)).get a = some j at ha
    rw [PTrie.get_set_u64 _ _ _ bt] at ha
    change a < s'.next+1
    by_cases he : a = s'.next
    · omega
    · rw [ite_eq_right he] at ha
      have := h.targetArrsBound a j ha
      omega

end Live
end Host.Mlx.Ffi.NativeRoles
