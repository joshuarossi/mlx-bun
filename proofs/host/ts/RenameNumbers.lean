import host.ts.Rename
namespace Host.Ts

/-! Numeric operations commute with reference renaming and symbolic substitution.
These lemmas run the real number interpreter and machine arithmetic primitives. -/

theorem request_bin_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NBin) (a b : NumV) {v : NumV}
    (run : interpS (.bin op a b (fun i => .pure (.ref i))) S = some (v, T)) :
    ∃ T', interpS (.bin op (R.num a) (R.num b) (fun i => .pure (.ref i))) S' =
      some (R.num v, T') ∧ SrvR R θ T T' := by
  cases hx : S.val a with
  | none => simp [interpS_bin, hx] at run
  | some x =>
    cases hy : S.val b with
    | none => simp [interpS_bin, hx, hy] at run
    | some y =>
      simp only [interpS_bin, hx, hy, interpS_pure, Option.some.injEq, Prod.mk.injEq] at run
      obtain ⟨rfl, rfl⟩ := run
      refine ⟨{ S' with tab := S'.tab ++ [.bin op (x.subst θ) (y.subst θ)] }, ?_, h.push (.bin op x y)⟩
      have hn : R.n S.tab.length = S'.tab.length := by simpa using h.fresh 0
      rw [interpS_bin, h.val hx, h.val hy]
      simp only [interpS_pure, Ren.num, NameMap.num, hn]

theorem request_un_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NUn) (a : NumV) {v : NumV}
    (run : interpS (.un op a (fun i => .pure (.ref i))) S = some (v, T)) :
    ∃ T', interpS (.un op (R.num a) (fun i => .pure (.ref i))) S' =
      some (R.num v, T') ∧ SrvR R θ T T' := by
  cases hx : S.val a with
  | none => simp [interpS_un, hx] at run
  | some x =>
    simp only [interpS_un, hx, interpS_pure, Option.some.injEq, Prod.mk.injEq] at run
    obtain ⟨rfl, rfl⟩ := run
    refine ⟨{ S' with tab := S'.tab ++ [.un op (x.subst θ)] }, ?_, h.push (.un op x)⟩
    have hn : R.n S.tab.length = S'.tab.length := by simpa using h.fresh 0
    rw [interpS_un, h.val hx]
    simp only [interpS_pure, Ren.num, NameMap.num, hn]

theorem request_test_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NTest) (a b : NumV) {v : Bool}
    (run : interpS (.test op a b .pure) S = some (v, T)) :
    ∃ T', interpS (.test op (R.num a) (R.num b) .pure) S' =
      some (v, T') ∧ SrvR R θ T T' := by
  cases hx : S.val a with
  | none => simp [interpS_test, hx] at run
  | some x =>
    cases hy : S.val b with
    | none => simp [interpS_test, hx, hy] at run
    | some y =>
      simp only [interpS_test, hx, hy] at run
      cases ha : S.answer op x y with
      | none => simp [ha] at run
      | some p =>
        obtain ⟨r, U⟩ := p
        simp only [ha, interpS_pure, Option.some.injEq, Prod.mk.injEq] at run
        obtain ⟨rfl, rfl⟩ := run
        obtain ⟨T', ht, hr⟩ := h.answer ha
        exact ⟨T', by simp only [interpS_test, h.val hx, h.val hy, ht, interpS_pure], hr⟩

theorem request_conc_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (a : NumV) {v : F64}
    (run : interpS (.conc a .pure) S = some (v, T)) :
    ∃ T', interpS (.conc (R.num a) .pure) S' = some (v, T') ∧ SrvR R θ T T' := by
  cases hx : S.val a with
  | none => simp [interpS_conc, hx] at run
  | some x =>
    cases x with
    | lit f =>
      simp only [interpS_conc, hx, interpS_pure, Option.some.injEq, Prod.mk.injEq] at run
      obtain ⟨rfl, rfl⟩ := run
      exact ⟨S', by simp only [interpS_conc, h.val hx, SymE.subst, interpS_pure], h⟩
    | _ => simp [interpS_conc, hx] at run

theorem numBin_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NBin) (a b : NumV) {v : NumV}
    (run : interpS (numBin op a b).run S = some (v, T)) :
    ∃ T', interpS (numBin op (R.num a) (R.num b)).run S' =
      some (R.num v, T') ∧ SrvR R θ T T' := by
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      change some (.lit (F64.bin op x y), S) = some (v, T) at run
      obtain ⟨rfl, rfl⟩ := Option.some.inj run
      exact ⟨S', rfl, h⟩
    | ref i => exact request_bin_renamed h op (.lit x) (.ref i) run
  | ref i =>
    cases b <;> exact request_bin_renamed h op (.ref i) _ run

theorem numUn_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NUn) (a : NumV) {v : NumV}
    (run : interpS (numUn op a).run S = some (v, T)) :
    ∃ T', interpS (numUn op (R.num a)).run S' = some (R.num v, T') ∧ SrvR R θ T T' := by
  cases a with
  | lit x =>
    change some (.lit (F64.un op x), S) = some (v, T) at run
    obtain ⟨rfl, rfl⟩ := Option.some.inj run
    exact ⟨S', rfl, h⟩
  | ref i => exact request_un_renamed h op (.ref i) run

theorem numTest_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (op : NTest) (a b : NumV) {v : Bool}
    (run : interpS (numTest op a b).run S = some (v, T)) :
    ∃ T', interpS (numTest op (R.num a) (R.num b)).run S' =
      some (v, T') ∧ SrvR R θ T T' := by
  cases a with
  | lit x =>
    cases b with
    | lit y =>
      change some (F64.test op x y, S) = some (v, T) at run
      obtain ⟨rfl, rfl⟩ := Option.some.inj run
      exact ⟨S', rfl, h⟩
    | ref i => exact request_test_renamed h op (.lit x) (.ref i) run
  | ref i => cases b <;> exact request_test_renamed h op (.ref i) _ run

theorem numConc_renamed {R : Ren} {θ : Nat → SymE} {S S' T : SSrv}
    (h : SrvR R θ S S') (a : NumV) {v : F64}
    (run : interpS (numConc a).run S = some (v, T)) :
    ∃ T', interpS (numConc (R.num a)).run S' = some (v, T') ∧ SrvR R θ T T' := by
  cases a with
  | lit x =>
    change some (x, S) = some (v, T) at run
    obtain ⟨rfl, rfl⟩ := Option.some.inj run
    exact ⟨S', rfl, h⟩
  | ref i => exact request_conc_renamed h (.ref i) run

end Host.Ts
