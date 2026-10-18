import host.ts.RenameProtocol
namespace Host.Ts

/-! The specialization bridge for the actual numeric primitives: a referenced input
and its inline concrete value execute the same binary64 operation. This includes the
different request paths (reference allocation versus an inline result). -/

def TableExtends (C C' : CSrv) : Prop :=
  ∀ i x, nth? C.tab i = some x → nth? C'.tab i = some x

theorem TableExtends.refl (C : CSrv) : TableExtends C C := fun _ _ h => h

theorem TableExtends.append (C : CSrv) (xs : List F64) : TableExtends C ⟨C.tab ++ xs⟩ :=
  fun i x h => nth?_append_keep xs C.tab i x h

theorem TableExtends.trans {A B C : CSrv} (hab : TableExtends A B) (hbc : TableExtends B C) :
    TableExtends A C := fun i x h => hbc i x (hab i x h)

theorem TableExtends.val {C D : CSrv} (h : TableExtends C D) {a : NumV} {x : F64}
    (ha : C.val a = some x) : D.val a = some x := by
  cases a with
  | lit y => exact ha
  | ref i => exact h i x ha

theorem requestC_bin (C : CSrv) (op : NBin) (a b : NumV) (x y : F64)
    (ha : C.val a = some x) (hb : C.val b = some y) :
    interpC (.bin op a b (fun i => .pure (NumV.ref i))) C =
      some (NumV.ref C.tab.length, ⟨C.tab ++ [F64.bin op x y]⟩) := by
  rw [interpC_bin, ha, hb]
  rfl

theorem numBin_specialize (C : CSrv) (op : NBin) (a b : NumV) (x y : F64)
    (ha : C.val a = some x) (hb : C.val b = some y) :
    ∃ v C', interpC (numBin op a b).run C = some (v, C') ∧
      C'.val v = some (F64.bin op x y) ∧ TableExtends C C' ∧
      interpC (numBin op (.lit x) (.lit y)).run C = some (.lit (F64.bin op x y), C) := by
  cases a with
  | lit u =>
    cases b with
    | lit v =>
      have hx : u = x := Option.some.inj ha
      have hy : v = y := Option.some.inj hb
      subst x y
      exact ⟨.lit (F64.bin op u v), C, rfl, rfl, .refl C, rfl⟩
    | ref j =>
      exact ⟨.ref C.tab.length, ⟨C.tab ++ [F64.bin op x y]⟩,
        requestC_bin C op (.lit u) (.ref j) x y ha hb,
        nth?_append_length C.tab _, .append C _, rfl⟩
  | ref i =>
    cases b with
    | lit v =>
      exact ⟨.ref C.tab.length, ⟨C.tab ++ [F64.bin op x y]⟩,
        requestC_bin C op (.ref i) (.lit v) x y ha hb,
        nth?_append_length C.tab _, .append C _, rfl⟩
    | ref j =>
      exact ⟨.ref C.tab.length, ⟨C.tab ++ [F64.bin op x y]⟩,
        requestC_bin C op (.ref i) (.ref j) x y ha hb,
        nth?_append_length C.tab _, .append C _, rfl⟩

theorem numUn_specialize (C : CSrv) (op : NUn) (a : NumV) (x : F64)
    (ha : C.val a = some x) :
    ∃ v C', interpC (numUn op a).run C = some (v, C') ∧
      C'.val v = some (F64.un op x) ∧ TableExtends C C' ∧
      interpC (numUn op (.lit x)).run C = some (.lit (F64.un op x), C) := by
  cases a with
  | lit u =>
    have hx : u = x := Option.some.inj ha
    subst x
    exact ⟨.lit (F64.un op u), C, rfl, rfl, .refl C, rfl⟩
  | ref i =>
    refine ⟨.ref C.tab.length, ⟨C.tab ++ [F64.un op x]⟩, ?_,
      nth?_append_length C.tab _, .append C _, rfl⟩
    change interpC (.un op (.ref i) (fun j => .pure (NumV.ref j))) C = _
    rw [interpC_un, ha]
    rfl

theorem numTest_specialize (C : CSrv) (op : NTest) (a b : NumV) (x y : F64)
    (ha : C.val a = some x) (hb : C.val b = some y) :
    interpC (numTest op a b).run C = some (F64.test op x y, C) ∧
      interpC (numTest op (.lit x) (.lit y)).run C = some (F64.test op x y, C) := by
  refine ⟨?_, rfl⟩
  cases a with
  | lit u =>
    cases b with
    | lit v =>
      have hx : u = x := Option.some.inj ha
      have hy : v = y := Option.some.inj hb
      subst x y
      rfl
    | ref j =>
      change interpC (.test op (.lit u) (.ref j) .pure) C = _
      rw [interpC_test, ha, hb]
      rfl
  | ref i =>
    cases b <;>
      change interpC (.test op (.ref i) _ .pure) C = _ <;>
      rw [interpC_test, ha, hb] <;> rfl

theorem numConc_specialize (C : CSrv) (a : NumV) (x : F64) (ha : C.val a = some x) :
    interpC (numConc a).run C = some (x, C) ∧
      interpC (numConc (.lit x)).run C = some (x, C) := by
  refine ⟨?_, rfl⟩
  cases a with
  | lit u =>
    have hx : u = x := Option.some.inj ha
    subst x
    rfl
  | ref i =>
    change interpC (.conc (.ref i) .pure) C = _
    rw [interpC_conc, ha]
    rfl

end Host.Ts
