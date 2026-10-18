import host.ts.RenameNumbers
namespace Host.Ts

/-! A structural relation on numeric request trees. Its constructors expose every
request, so proving it for a machine primitive requires checking that primitive's code.
The interpreter theorem below proves the relation sound rather than assuming StepSim. -/

inductive RequestR (R : Ren) {α β : Type} (P : α → β → Prop) : Free α → Free β → Prop
  | pure {a b} : P a b → RequestR R P (.pure a) (.pure b)
  | fail (m m') : RequestR R P (.fail m) (.fail m')
  | bin {op a b k k'} : (∀ i, RequestR R P (k i) (k' (R.n i))) →
      RequestR R P (.bin op a b k) (.bin op (R.num a) (R.num b) k')
  | un {op a k k'} : (∀ i, RequestR R P (k i) (k' (R.n i))) →
      RequestR R P (.un op a k) (.un op (R.num a) k')
  | test {op a b k k'} : (∀ v, RequestR R P (k v) (k' v)) →
      RequestR R P (.test op a b k) (.test op (R.num a) (R.num b) k')
  | conc {a k k'} : (∀ v, RequestR R P (k v) (k' v)) →
      RequestR R P (.conc a k) (.conc (R.num a) k')

theorem RequestR.interp {R : Ren} {α β : Type} {P : α → β → Prop} {u : Free α} {v : Free β}
    (h : RequestR R P u v) (θ : Nat → SymE) :
    ∀ (S S' : SSrv) (a : α) (T : SSrv), SrvR R θ S S' → interpS u S = some (a, T) →
      ∃ b T', interpS v S' = some (b, T') ∧ P a b ∧ SrvR R θ T T' := by
  induction h with
  | pure hp =>
    intro S S' a T hs hr
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at hr
    obtain ⟨rfl, rfl⟩ := hr
    exact ⟨_, S', rfl, hp, hs⟩
  | fail _ _ => intro S S' a T hs hr; simp [interpS_fail] at hr
  | @bin op x y k k' hk ih =>
    intro S S' a T hs hr
    cases hx : S.val x with
    | none => simp [interpS_bin, hx] at hr
    | some ex =>
      cases hy : S.val y with
      | none => simp [interpS_bin, hx, hy] at hr
      | some ey =>
        simp only [interpS_bin, hx, hy] at hr
        obtain ⟨b, T', ht, hp, hs'⟩ := ih S.tab.length _ _ a T (hs.push (.bin op ex ey)) hr
        refine ⟨b, T', ?_, hp, hs'⟩
        have hn : R.n S.tab.length = S'.tab.length := by simpa using hs.fresh 0
        rw [interpS_bin, hs.val hx, hs.val hy, ← hn]
        exact ht
  | @un op x k k' hk ih =>
    intro S S' a T hs hr
    cases hx : S.val x with
    | none => simp [interpS_un, hx] at hr
    | some ex =>
      simp only [interpS_un, hx] at hr
      obtain ⟨b, T', ht, hp, hs'⟩ := ih S.tab.length _ _ a T (hs.push (.un op ex)) hr
      refine ⟨b, T', ?_, hp, hs'⟩
      have hn : R.n S.tab.length = S'.tab.length := by simpa using hs.fresh 0
      rw [interpS_un, hs.val hx, ← hn]
      exact ht
  | @test op x y k k' hk ih =>
    intro S S' a T hs hr
    cases hx : S.val x with
    | none => simp [interpS_test, hx] at hr
    | some ex =>
      cases hy : S.val y with
      | none => simp [interpS_test, hx, hy] at hr
      | some ey =>
        simp only [interpS_test, hx, hy] at hr
        cases ha : S.answer op ex ey with
        | none => simp [ha] at hr
        | some p =>
          obtain ⟨q, U⟩ := p
          simp only [ha] at hr
          obtain ⟨U', hu, hsU⟩ := hs.answer ha
          obtain ⟨b, T', ht, hp, hs'⟩ := ih q U U' a T hsU hr
          exact ⟨b, T', by
            rw [interpS_test, hs.val hx, hs.val hy]
            simp only [hu]
            exact ht, hp, hs'⟩
  | @conc x k k' hk ih =>
    intro S S' a T hs hr
    cases hx : S.val x with
    | none => simp [interpS_conc, hx] at hr
    | some e =>
      cases e with
      | lit f =>
        simp only [interpS_conc, hx] at hr
        obtain ⟨b, T', ht, hp, hs'⟩ := ih f S S' a T hs hr
        exact ⟨b, T', by rw [interpS_conc, hs.val hx]; exact ht, hp, hs'⟩
      | _ => simp [interpS_conc, hx] at hr

/-- Relational parametricity for the interpreter's continuation-passing primitives. -/
def ComputationR (R : Ren) {α β : Type} (P : α → β → Prop) (m : M α) (m' : M β) : Prop :=
  ∀ (γ δ : Type) (Q : γ → δ → Prop) (k : α → Free γ) (k' : β → Free δ),
    (∀ a b, P a b → RequestR R Q (k a) (k' b)) → RequestR R Q (m γ k) (m' δ k')

namespace ComputationR

theorem pure {R : Ren} {α β : Type} {P : α → β → Prop} {a : α} {b : β} (h : P a b) :
    ComputationR R P (M.pure a) (M.pure b) := by
  intro γ δ Q k k' hk
  exact hk a b h

theorem bind {R : Ren} {α β γ δ : Type} {P : α → β → Prop} {Q : γ → δ → Prop}
    {m : M α} {m' : M β} {f : α → M γ} {f' : β → M δ}
    (hm : ComputationR R P m m') (hf : ∀ a b, P a b → ComputationR R Q (f a) (f' b)) :
    ComputationR R Q (M.bind m f) (M.bind m' f') := by
  intro ε ζ A k k' hk
  exact hm ε ζ A _ _ (fun a b hab => hf a b hab ε ζ A k k' hk)

theorem run {R : Ren} {α β : Type} {P : α → β → Prop} {m : M α} {m' : M β}
    (h : ComputationR R P m m') : RequestR R P m.run m'.run :=
  h α β P .pure .pure (fun _ _ hp => .pure hp)

theorem numBin (R : Ren) (op : NBin) (a b : NumV) :
    ComputationR R (fun x y => y = R.num x) (Host.Ts.numBin op a b)
      (Host.Ts.numBin op (R.num a) (R.num b)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk _ _ rfl
    | ref i => exact .bin (fun j => hk _ _ rfl)
  | ref i => cases b <;> exact .bin (fun j => hk _ _ rfl)

theorem numUn (R : Ren) (op : NUn) (a : NumV) :
    ComputationR R (fun x y => y = R.num x) (Host.Ts.numUn op a)
      (Host.Ts.numUn op (R.num a)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x => exact hk _ _ rfl
  | ref i => exact .un (fun j => hk _ _ rfl)

theorem numTest (R : Ren) (op : NTest) (a b : NumV) :
    ComputationR R Eq (Host.Ts.numTest op a b) (Host.Ts.numTest op (R.num a) (R.num b)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk _ _ rfl
    | ref i => exact .test (fun v => hk _ _ rfl)
  | ref i => cases b <;> exact .test (fun v => hk _ _ rfl)

theorem numConc (R : Ren) (a : NumV) :
    ComputationR R Eq (Host.Ts.numConc a) (Host.Ts.numConc (R.num a)) := by
  intro γ δ Q k k' hk
  cases a with
  | lit x => exact hk _ _ rfl
  | ref i => exact .conc (fun v => hk _ _ rfl)

end ComputationR
end Host.Ts
