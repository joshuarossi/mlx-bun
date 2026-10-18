import host.ts.RenameOwned
namespace Host.Ts.Owned

theorem ListR.len_eq {α β : Type} {rel : α → β → Prop} {as : List α} {bs : List β}
    (h : ListR rel as bs) : len as = len bs := by
  have hl : ∀ n, lenL as n = lenL bs n := by
    induction h with
    | nil => intro n; rfl
    | cons _ _ ih => intro n; exact ih (n + 1)
  exact hl 0

theorem ListR.append {α β : Type} {rel : α → β → Prop} {as cs : List α} {bs ds : List β}
    (h : ListR rel as bs) (g : ListR rel cs ds) : ListR rel (as ++ cs) (bs ++ ds) := by
  induction h with
  | nil => exact g
  | cons hab _ ih => exact .cons hab ih

theorem ListR.take {α β : Type} {rel : α → β → Prop} {as : List α} {bs : List β}
    (h : ListR rel as bs) (n : Nat) : ListR rel (as.take n) (bs.take n) := by
  induction n generalizing as bs with
  | zero => exact .nil
  | succ n ih => cases h with
    | nil => exact .nil
    | cons hab hrest => exact .cons hab (ih hrest)

theorem ListR.drop {α β : Type} {rel : α → β → Prop} {as : List α} {bs : List β}
    (h : ListR rel as bs) (n : Nat) : ListR rel (as.drop n) (bs.drop n) := by
  induction n generalizing as bs with
  | zero => exact h
  | succ n ih => cases h with
    | nil => exact .nil
    | cons _ hrest => exact ih hrest

theorem patch_related {R : Ren} {bs bs' bytes bytes' : List Byte}
    (hb : ListR (ByteR R) bs bs') (hw : ListR (ByteR R) bytes bytes') (off : Nat) :
    ListR (ByteR R) (bs.take off ++ bytes ++ bs.drop (off + len bytes))
      (bs'.take off ++ bytes' ++ bs'.drop (off + len bytes')) := by
  have hd : ListR (ByteR R) (bs.drop (off + len bytes)) (bs'.drop (off + len bytes')) := by
    rw [← hw.len_eq]
    exact hb.drop _
  exact ((hb.take off).append hw).append hd

/-- Actual buffer writes preserve cell roles and every other heap lookup. This
frames old garbage as well as live locations and does not rename ordinary bigint
cells merely because their values happen to equal native handles. -/
theorem applyWrites_buffer_roles (F : Ffi) (R : Ren) (s s' : St F.S) (b off : Nat)
    (o o' : Obj) (bs bs' bytes bytes' : List Byte)
    (ho : s.obj? b = some o) (hk : o.kind = .buf bs)
    (ho' : s'.obj? (R.a b) = some o') (hk' : o'.kind = .buf bs')
    (hb : ListR (ByteR R) bs bs') (hw : ListR (ByteR R) bytes bytes')
    (hbound : b < 2 ^ 64) (hbound' : R.a b < 2 ^ 64) :
    let data := bs.take off ++ bytes ++ bs.drop (off + len bytes)
    let data' := bs'.take off ++ bytes' ++ bs'.drop (off + len bytes')
    let u := s.setObj b { o with kind := .buf data }
    let u' := s'.setObj (R.a b) { o' with kind := .buf data' }
    applyWrites F s [(b, off, bytes)] = some u ∧
      applyWrites F s' [(R.a b, off, bytes')] = some u' ∧
      ListR (ByteR R) data data' ∧
      (∀ a, a ≠ b → u.heap.get a = s.heap.get a) ∧
      (∀ a, a ≠ R.a b → u'.heap.get a = s'.heap.get a) := by
  dsimp only
  refine ⟨applyWrites_one_buffer F s b off bytes bs o ho hk,
    applyWrites_one_buffer F s' (R.a b) off bytes' bs' o' ho' hk', patch_related hb hw off, ?_, ?_⟩
  · intro a ha
    simp only [St.setObj, PTrie.get_set_u64 _ _ _ hbound, ite_eq_right ha]
  · intro a ha
    simp only [St.setObj, PTrie.get_set_u64 _ _ _ hbound', ite_eq_right ha]

theorem readCell_parts (k : EltK) (c : Cell) : readCell k (cellParts k c k.size 0) = some c := by
  cases k <;> rfl

theorem cellVal_related {R : Ren} {c c' : Cell} (h : CellR R c c') : ValueR R (cellVal c) (cellVal c') := by
  cases h with
  | num n => exact .num n
  | ordinaryBig i => exact .ordinaryBig i
  | handle h => exact .handle h
  | pointerInteger m off => exact .pointerInteger m off

/-- A coherent native-written element is read without concretizing its bytes.
The read keeps the cell's number, ordinary bigint or owned-resource role. -/
theorem typedGet_roles (F : Ffi) (R : Ren) (s s' : St F.S) (k : EltK)
    (b off n i : Nat) (bs bs' : List Byte) (c c' : Cell) (hc : CellR R c c')
    (hi : Nat.blt i n = true)
    (hb : bufBytes F s b = some bs) (hb' : bufBytes F s' (R.a b) = some bs')
    (hw : bs.drop (off + i * k.size) = cellParts k c k.size 0)
    (hw' : bs'.drop (off + i * k.size) = cellParts k c' k.size 0) :
    typedGet F s k b off n i = M.pure (some (.data (cellVal c) true true)) ∧
      typedGet F s' k (R.a b) off n i = M.pure (some (.data (cellVal c') true true)) ∧
      ValueR R (cellVal c) (cellVal c') := by
  refine ⟨?_, ?_, cellVal_related hc⟩
  · simp only [typedGet, hi, Bool.cond_true, hb, hw, readCell_parts]
  · simp only [typedGet, hi, Bool.cond_true, hb', hw', readCell_parts]

private theorem isIndexable_typed (F : Ffi) (s : St F.S) (a : Nat) (o : Obj)
    (k : EltK) (b off n : Nat) (ho : s.obj? a = some o) (hk : o.kind = .typed k b off n) :
    isIndexable F s (.obj a) = true := by
  obtain ⟨kind, proto, props, priv, ext⟩ := o
  dsimp only at hk
  subst kind
  simp only [isIndexable, ho]

/-- The actual `view[0]` machine step reads a coherent one-element buffer and
retains its ghost role. This covers uint32 token reads and uint64 handle-slot
reads, including equal-valued ordinary integers and handles. -/
theorem step_indexTyped0_roles (F : Ffi) (R : Ren) (s s' : St F.S) (a b : Nat) (o o' : Obj)
    (k : EltK) (c c' : Cell) (fs fs' : List Frame) (hcells : CellR R c c')
    (hc : s.ctl = .ret (.num zeroN)) (hc' : s'.ctl = .ret (.num zeroN))
    (hf : s.stack = .e (.indexR (.obj a)) :: fs)
    (hf' : s'.stack = .e (.indexR (.obj (R.a a))) :: fs')
    (ho : s.obj? a = some o) (hk : o.kind = .typed k b 0 1)
    (ho' : s'.obj? (R.a a) = some o') (hk' : o'.kind = .typed k (R.a b) 0 1)
    (hb : bufBytes F s b = some (cellParts k c k.size 0))
    (hb' : bufBytes F s' (R.a b) = some (cellParts k c' k.size 0)) :
    step F s = M.pure ({ s with stack := fs }.ret (cellVal c)) ∧
      step F s' = M.pure ({ s' with stack := fs' }.ret (cellVal c')) ∧
      ValueR R (cellVal c) (cellVal c') := by
  have hzero : numIndex (.num zeroN) = some 0 := by decide +kernel
  have ht := typedGet_roles F R { s with stack := fs } { s' with stack := fs' } k b 0 1 0
    (cellParts k c k.size 0) (cellParts k c' k.size 0) c c' hcells (by decide +kernel) hb hb'
    (by simp only [Nat.zero_mul, Nat.zero_add, List.drop_zero])
    (by simp only [Nat.zero_mul, Nat.zero_add, List.drop_zero])
  have ho0 : ({ s with stack := fs }).obj? a = some o := ho
  have ho1 : ({ s' with stack := fs' }).obj? (R.a a) = some o' := ho'
  have hi0 := isIndexable_typed F { s with stack := fs } a o k b 0 1 ho0 hk
  have hi1 := isIndexable_typed F { s' with stack := fs' } (R.a a) o' k (R.a b) 0 1 ho1 hk'
  simp only [hc, hc'] at ht ho0 ho1 hi0 hi1
  refine ⟨?_, ?_, ht.2.2⟩
  · funext β cont
    simp only [step, hc, stepRet, hf, retStep, retE, getIndex, hzero, hi0, Bool.cond_true,
      elemAt, ho0, hk]
    rw [ht.1]
    rfl
  · funext β cont
    simp only [step, hc', stepRet, hf', retStep, retE, getIndex, hzero, hi1, Bool.cond_true,
      elemAt, ho1, hk']
    rw [ht.2.1]
    rfl

end Host.Ts.Owned
