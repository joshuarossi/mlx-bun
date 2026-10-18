import host.ts.RenameShapes
namespace Host.Mlx.Ffi
open Host.Ts

private theorem bif_renamed {R : Ren} {α β : Type} {P : α → β → Prop}
    (c : Bool) {t f : M α} {t' f' : M β} (ht : ComputationR R P t t') (hf : ComputationR R P f f') :
    ComputationR R P (bif c then t else f) (bif c then t' else f') := by
  cases c
  · exact hf
  · exact ht

private def sliceEnd (str ed st : Dim) : M (Option Dim) :=
  match str with
  | .lit 1 => .bind (dSub ed st) fun r => .pure (some r)
  | .lit k => bif decide (0 < k) then match ed, st with
      | .lit a, .lit b => .pure (some (.lit ((a - b + k - 1) / k)))
      | _, _ => .pure none
    else .pure none
  | .sym _ => .pure none

private theorem sliceEnd_renamed (R : Ren) (str ed st : Dim) :
    ComputationR R (fun x y => y = x.map R.dim) (sliceEnd str ed st)
      (sliceEnd (R.dim str) (R.dim ed) (R.dim st)) := by
  cases str with
  | sym _ => exact ComputationR.pure rfl
  | lit k =>
    by_cases hk : k = 1
    · subst k
      apply ComputationR.bind (dSub_renamed R ed st)
      intro a b hab
      subst b
      exact ComputationR.pure rfl
    · simp only [sliceEnd, Ren.dim]
      cases hb : decide (0 < k)
      · exact ComputationR.pure rfl
      · cases ed <;> cases st <;> exact ComputationR.pure rfl

theorem sliceAxis_renamed (R : Ren) (n s e str : Dim) :
    ComputationR R (fun x y => y = x.map R.dim) (sliceAxis n s e str)
      (sliceAxis (R.dim n) (R.dim s) (R.dim e) (R.dim str)) := by
  apply ComputationR.bind (dLt_renamed R s (.lit 0))
  intro sn sn' hsn
  subst sn'
  apply ComputationR.bind (bif_renamed sn (dAdd_renamed R s n) (ComputationR.pure rfl))
  intro s1 s1' hs1
  subst s1'
  apply ComputationR.bind (dLt_renamed R e (.lit 0))
  intro en en' hen
  subst en'
  apply ComputationR.bind (bif_renamed en (dAdd_renamed R e n) (ComputationR.pure rfl))
  intro e1 e1' he1
  subst e1'
  apply ComputationR.bind (dMin_renamed R s1 n)
  intro st st' hst
  subst st'
  apply ComputationR.bind (dMax_renamed R (.lit 0) st)
  intro st st' hst
  subst st'
  apply ComputationR.bind (dMin_renamed R e1 n)
  intro ed ed' hed
  subst ed'
  apply ComputationR.bind (dMax_renamed R (.lit 0) ed)
  intro ed ed' hed
  subst ed'
  apply ComputationR.bind (dLt_renamed R ed st)
  intro lt lt' hlt
  subst lt'
  cases lt
  · exact sliceEnd_renamed R str ed st
  · exact sliceEnd_renamed R str st st

theorem sliceShape_renamed (R : Ren) : ∀ (ns ss es ks : List Dim),
    ComputationR R (fun x y => y = x.map (List.map R.dim)) (sliceShape ns ss es ks)
      (sliceShape (ns.map R.dim) (ss.map R.dim) (es.map R.dim) (ks.map R.dim)) := by
  intro ns
  induction ns with
  | nil =>
    intro ss es ks
    cases ss <;> cases es <;> cases ks <;> exact ComputationR.pure rfl
  | cons n ns ih =>
    intro ss es ks
    cases ss with
    | nil => cases es <;> cases ks <;> exact ComputationR.pure rfl
    | cons s ss =>
      cases es with
      | nil => cases ks <;> exact ComputationR.pure rfl
      | cons e es =>
        cases ks with
        | nil => exact ComputationR.pure rfl
        | cons k ks =>
          apply ComputationR.bind (sliceAxis_renamed R n s e k)
          intro x y hxy
          subst y
          cases x with
          | none => exact ComputationR.pure rfl
          | some d =>
            apply ComputationR.bind (ih ss es ks)
            intro x y hxy
            subst y
            cases x <;> exact ComputationR.pure rfl

theorem infer_slice_renamed (R : Ren) (h : Function.Injective R.n) (st sp sr sh : List Dim) (dt : Nat) :
    ComputationR R (fun x y => y = x.map (out R))
      (infer (.slice st sp sr) [(sh, dt)])
      (infer (R.prim (.slice st sp sr)) ([(sh, dt)].map (shapeDt R))) := by
  simp only [infer, Ren.prim, List.map_cons, List.map_nil, shapeDt, len_map]
  cases hb : Nat.beq (len st) (len sh)
  · exact ComputationR.pure rfl
  · apply ComputationR.bind (sliceShape_renamed R sh st sp sr)
    intro x y hxy
    subst y
    cases x with
    | none => exact ComputationR.pure rfl
    | some r =>
      apply ComputationR.bind (allEq_renamed R h r sh)
      intro x y hxy
      subst y
      cases x <;> exact ComputationR.pure rfl

end Host.Mlx.Ffi
