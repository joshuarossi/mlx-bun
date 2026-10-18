import host.mlx.NativeSliceUpdateGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem allEq_literals (xs ys : List Int) :
    allEq (xs.map Dim.lit) (ys.map Dim.lit) = M.pure (decide (xs = ys)) := by
  induction xs generalizing ys with
  | nil => cases ys <;> rfl
  | cons x xs ih =>
    cases ys with
    | nil => rfl
    | cons y ys =>
      by_cases he : x = y
      · subst y
        funext β k
        simp only [List.map_cons,allEq,dEq,decide_true,M.bind,M.pure,Bool.cond_true,ih]
        simp only [List.cons.injEq,true_and]
      · have hb : decide (x = y) = false := decide_eq_false he
        funext β k
        simp only [List.map_cons,allEq,dEq,hb,M.bind,M.pure,Bool.cond_false]
        simp only [List.cons.injEq,he,false_and,decide_false]

theorem SliceRanges.starts_length {sizes starts stops : List Int} (h : SliceRanges sizes starts stops) :
    starts.length = sizes.length := by
  induction sizes generalizing starts stops with
  | nil =>
    cases starts <;> cases stops
    · rfl
    all_goals cases h
  | cons n ns ih =>
    cases starts with
    | nil => cases h
    | cons start ss =>
      cases stops with
      | nil => cases h
      | cons stop es => exact congrArg Nat.succ (ih h.2.2.2)

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- A pure exact interpretation of literal dimensions, independent of numeric
reference allocation. In particular, truncating an arbitrary fractional F64
does not supply a dimension annotation. -/
inductive LiteralDimensions (ν : Nat → F64) : Shape → List Int → Prop where
  | nil : LiteralDimensions ν [] []
  | cons (e : SymE) (i : Int) {rs : Shape} {is : List Int}
      (value : e.eval ν = F64.ofInt i) (exactInteger : F64.toInt? (e.eval ν) = some i)
      (tail : LiteralDimensions ν rs is) : LiteralDimensions ν (.literal e::rs) (i::is)

theorem LiteralDimensions.holds {ν : Nat → F64} {roles : Shape} {ints : List Int}
    (h : LiteralDimensions ν roles ints) (C : CSrv) : Shape.Holds ν C roles (ints.map Dim.lit) := by
  induction h with
  | nil => exact .nil
  | cons e i value hi _ ih => exact .cons (.literal e i (by change some _ = some _; rw [value]) hi) ih

theorem LiteralDimensions.subst {ν : Nat → F64} {roles : Shape} {ints : List Int}
    (θ : Nat → SymE) (h : LiteralDimensions (Owned.Annotated.nextValuation θ ν) roles ints) :
    LiteralDimensions ν (Shape.subst θ roles) ints := by
  induction h with
  | nil => exact .nil
  | cons e i value hi _ ih =>
    exact .cons (e.subst θ) i (by rw [SymE.eval_subst]; exact value) (by rw [SymE.eval_subst]; exact hi) ih

theorem LiteralDimensions.of_subst {ν : Nat → F64} {roles : Shape} {ints : List Int}
    (θ : Nat → SymE) (h : LiteralDimensions ν (Shape.subst θ roles) ints) :
    LiteralDimensions (Owned.Annotated.nextValuation θ ν) roles ints := by
  induction roles generalizing ints with
  | nil => cases h; exact .nil
  | cons r rs ih =>
    cases r with
    | symbolic r => cases h
    | literal e =>
      cases h with
      | cons _ i value hi tail =>
        have value' : e.eval (Owned.Annotated.nextValuation θ ν) = F64.ofInt i := by
          change e.eval (fun j => (θ j).eval ν) = _
          rw [← SymE.eval_subst θ ν e]
          exact value
        have hi' : F64.toInt? (e.eval (Owned.Annotated.nextValuation θ ν)) = some i := by
          change F64.toInt? (e.eval (fun j => (θ j).eval ν)) = _
          rw [← SymE.eval_subst θ ν e]
          exact hi
        exact .cons e i value' hi' (ih tail)

/-- Both the strict subview and the full-capacity alias branch are properties
of the original integer slice geometry. Each paired execution must establish
the same branch explicitly. -/
def SliceGeometry (ν : Nat → F64) (input output starts stops strides : Shape) (same : Bool) : Prop :=
  ∃ ns ss es : List Int, input.literalValues ν = some ns ∧ starts.literalValues ν = some ss ∧
    stops.literalValues ν = some es ∧ LiteralDimensions ν output (NativeRoles.sliceExtents ss es) ∧
    strides.literalValues ν = some (List.replicate ns.length 1) ∧ NativeRoles.SliceRanges ns ss es ∧
    decide (NativeRoles.sliceExtents ss es = ns) = same

theorem SliceGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (input output starts stops strides : Shape) (same : Bool) :
    SliceGeometry ν (Shape.subst θ input) (Shape.subst θ output) (Shape.subst θ starts) (Shape.subst θ stops)
      (Shape.subst θ strides) same ↔
    SliceGeometry (Owned.Annotated.nextValuation θ ν) input output starts stops strides same := by
  simp only [SliceGeometry,Shape.literalValues_subst]
  constructor
  · rintro ⟨ns,ss,es,hn,hs,he,ho,hr,hb,branch⟩
    exact ⟨ns,ss,es,hn,hs,he,ho.of_subst θ,hr,hb,branch⟩
  · rintro ⟨ns,ss,es,hn,hs,he,ho,hr,hb,branch⟩
    exact ⟨ns,ss,es,hn,hs,he,ho.subst θ,hr,hb,branch⟩

theorem SliceGeometry.infer {ν : Nat → F64} {C : CSrv} {input output starts stops strides : Shape} {same : Bool}
    (geometry : SliceGeometry ν input output starts stops strides same) (dtype : Nat)
    {x st sp sr : List Dim} (hx : Shape.Holds ν C input x)
    (hst : Shape.Holds ν C starts st) (hsp : Shape.Holds ν C stops sp) (hsr : Shape.Holds ν C strides sr) :
    ∃ result, Shape.Holds ν C output result ∧
      infer (.slice st sp sr) [(x,dtype)] = M.pure (some (bif same then .same 0 else .node result dtype)) := by
  obtain ⟨ns,ss,es,hn,hs,he,ho',hr,bounds,branch⟩ := geometry
  refine ⟨_,ho'.holds C,?_⟩
  rw [hx.literalValues hn,hst.literalValues hs,hsp.literalValues he,hsr.literalValues hr]
  have rank : Nat.beq (len (ss.map Dim.lit)) (len (ns.map Dim.lit)) = true := by
    have lengthEq : ∀ {α : Type} (xs : List α) (n : Nat), lenL xs n = xs.length + n := by
      intro α xs
      induction xs with
      | nil => intro n; simp only [lenL,List.length_nil,Nat.zero_add]
      | cons x xs ih => intro n; simp only [lenL,List.length_cons,ih]; omega
    simp only [len,lengthEq,List.length_map,bounds.starts_length,Nat.beq_refl]
  funext β k
  simp only [Host.Mlx.Ffi.infer,rank,Bool.cond_true,NativeRoles.sliceShape_unit_bounds ns ss es bounds,
    NativeRoles.allEq_literals,branch,M.bind,M.pure]

/-- A KV view of the used prefix aliases the input exactly at capacity. This
guard remains explicit when the loop index and capacity vary independently. -/
theorem SliceGeometry.kv4 {ν : Nat → F64} {input output starts stops strides : Shape}
    (batch heads capacity used width : Int)
    (inputValues : input.literalValues ν = some [batch,heads,capacity,width])
    (startValues : starts.literalValues ν = some [0,0,0,0])
    (stopValues : stops.literalValues ν = some [batch,heads,used,width])
    (strideValues : strides.literalValues ν = some [1,1,1,1])
    (outputValues : LiteralDimensions ν output [batch,heads,used,width])
    (batchNonnegative : 0 ≤ batch) (headsNonnegative : 0 ≤ heads) (usedNonnegative : 0 ≤ used)
    (widthNonnegative : 0 ≤ width) (bound : used ≤ capacity) :
    SliceGeometry ν input output starts stops strides (decide (used = capacity)) := by
  have extents : NativeRoles.sliceExtents [0,0,0,0] [batch,heads,used,width] = [batch,heads,used,width] := by
    simp only [NativeRoles.sliceExtents,List.zipWith,Int.sub_zero]
  refine ⟨[batch,heads,capacity,width],[0,0,0,0],[batch,heads,used,width],inputValues,startValues,stopValues,
    by rw [extents]; exact outputValues,strideValues,?_,?_⟩
  · exact ⟨by omega,batchNonnegative,by omega,by omega,headsNonnegative,by omega,
      by omega,usedNonnegative,bound,by omega,widthNonnegative,by omega,True.intro⟩
  · rw [extents]
    simp only [List.cons.injEq,true_and,and_true]

end Host.Mlx.Ffi.Annotated
