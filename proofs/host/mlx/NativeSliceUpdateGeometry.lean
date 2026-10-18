import host.mlx.NativeLiteralGeometry
import host.mlx.QuantizedInference

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem dLt_literal_false (a b : Int) (h : b ≤ a) : dLt (.lit a) (.lit b) = M.pure false := by
  simp only [dLt,show decide (a < b) = false from decide_eq_false (by omega)]

theorem dMin_literal_le (a b : Int) (h : a ≤ b) : dMin (.lit a) (.lit b) = M.pure (.lit a) := by
  change M.pure (bif decide (a < b) then Dim.lit a else Dim.lit b) = _
  by_cases lt : a < b
  · rw [show decide (a < b) = true from decide_eq_true lt]; rfl
  · have eq : a = b := by omega
    rw [eq,show decide (b < b) = false from decide_eq_false (by omega)]
    rfl

theorem dMax_literal_le (a b : Int) (h : a ≤ b) : dMax (.lit a) (.lit b) = M.pure (.lit b) := by
  change M.pure (bif decide (a < b) then Dim.lit b else Dim.lit a) = _
  by_cases lt : a < b
  · rw [show decide (a < b) = true from decide_eq_true lt]; rfl
  · have eq : a = b := by omega
    rw [eq,show decide (b < b) = false from decide_eq_false (by omega)]
    rfl

/-- The existing normalizer preserves a nonnegative in-bounds unit-stride
interval exactly, so its output extent is the integer stop-start. -/
theorem sliceAxis_unit_bounds (n start stop : Int) (nonnegative : 0 ≤ start)
    (ordered : start ≤ stop) (bound : stop ≤ n) :
    sliceAxis (.lit n) (.lit start) (.lit stop) (.lit 1) = M.pure (some (.lit (stop-start))) := by
  have startBound : start ≤ n := by omega
  have stopNonnegative : 0 ≤ stop := by omega
  funext β k
  simp only [sliceAxis,dLt_literal_false start 0 nonnegative,dLt_literal_false stop 0 stopNonnegative,
    dMin_literal_le start n startBound,dMax_literal_le 0 start nonnegative,dMin_literal_le stop n bound,
    dMax_literal_le 0 stop stopNonnegative,dLt_literal_false stop start ordered,M.bind,M.pure,Bool.cond_false,dSub]

def SliceRanges : List Int → List Int → List Int → Prop
  | [],[],[] => True
  | n::ns,start::ss,stop::es => 0 ≤ start ∧ start ≤ stop ∧ stop ≤ n ∧ SliceRanges ns ss es
  | _,_,_ => False

def sliceExtents (starts stops : List Int) : List Int := List.zipWith (fun start stop => stop-start) starts stops

theorem sliceShape_unit_bounds (sizes starts stops : List Int) (bounds : SliceRanges sizes starts stops) :
    sliceShape (sizes.map Dim.lit) (starts.map Dim.lit) (stops.map Dim.lit)
      ((List.replicate sizes.length 1).map Dim.lit) = M.pure (some ((sliceExtents starts stops).map Dim.lit)) := by
  induction sizes generalizing starts stops with
  | nil =>
    cases starts <;> cases stops
    · rfl
    all_goals cases bounds
  | cons n ns ih =>
    cases starts with
    | nil => cases bounds
    | cons start ss =>
      cases stops with
      | nil => cases bounds
      | cons stop es =>
        have h := sliceAxis_unit_bounds n start stop bounds.1 bounds.2.1 bounds.2.2.1
        funext β k
        simp only [List.map_cons,List.length_cons,List.replicate_succ,sliceShape,h,ih ss es bounds.2.2.2,
          sliceExtents,List.zipWith_cons_cons,M.bind,M.pure,Option.map_some]

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Pure integer cache-write guards. Literal dimension meanings may vary
with the loop counter and capacity; the source program's strides stay one. -/
def SliceUpdateGeometry (ν : Nat → F64) (input update starts stops strides : Shape) : Prop :=
  ∃ ns ss es : List Int, input.literalValues ν = some ns ∧ starts.literalValues ν = some ss ∧
    stops.literalValues ν = some es ∧ update.literalValues ν = some (NativeRoles.sliceExtents ss es) ∧
    strides.literalValues ν = some (List.replicate ns.length 1) ∧ NativeRoles.SliceRanges ns ss es

theorem SliceUpdateGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (input update starts stops strides : Shape) :
    SliceUpdateGeometry ν (Shape.subst θ input) (Shape.subst θ update) (Shape.subst θ starts) (Shape.subst θ stops) (Shape.subst θ strides) ↔
      SliceUpdateGeometry (Owned.Annotated.nextValuation θ ν) input update starts stops strides := by
  simp only [SliceUpdateGeometry,Shape.literalValues_subst]

theorem SliceUpdateGeometry.infer {ν : Nat → F64} {C : CSrv} {input update starts stops strides : Shape}
    (geometry : SliceUpdateGeometry ν input update starts stops strides) (dtype updateDtype : Nat)
    {x u st sp sr : List Dim} (hx : Shape.Holds ν C input x) (hu : Shape.Holds ν C update u)
    (hst : Shape.Holds ν C starts st) (hsp : Shape.Holds ν C stops sp) (hsr : Shape.Holds ν C strides sr) :
    infer (.sliceUpdate st sp sr) [(x,dtype),(u,updateDtype)] = M.pure (some (.node x dtype)) := by
  obtain ⟨ns,ss,es,hn,hs,he,huv,hr,bounds⟩ := geometry
  rw [hx.literalValues hn,hu.literalValues huv,hst.literalValues hs,hsp.literalValues he,hsr.literalValues hr]
  funext β k
  simp only [Host.Mlx.Ffi.infer,NativeRoles.sliceShape_unit_bounds ns ss es bounds,
    InferenceRoles.broadcast_same,InferenceRoles.allEq_self,M.bind,M.pure,Bool.cond_true]

end Host.Mlx.Ffi.Annotated
