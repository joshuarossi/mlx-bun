import host.mlx.NativeShapelessSignature

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated.ShapelessSignatureTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

private def valuation (i : Nat) : F64 := if i = 0 then F64.ofNat 256 else F64.ofNat 257
private def captured : Metadata := [([.literal (.var 0)],12)]
private def inputs : Metadata := [([.literal (.var 1)],12)]

private theorem captured_holds (C : CSrv) : Metadata.Holds valuation C captured [([.lit 256],12)] := by
  refine .cons ⟨.cons (.literal (.var 0) 256 ?_ ?_) .nil,rfl⟩ .nil
  · rfl
  · decide +kernel

private theorem inputs_holds (C : CSrv) : Metadata.Holds valuation C inputs [([.lit 257],12)] := by
  refine .cons ⟨.cons (.literal (.var 1) 257 ?_ ?_) .nil,rfl⟩ .nil
  · rfl
  · decide +kernel

/-- Distinct dimension expressions and source dimensions still select the
same shapeless rank/dtype signature. No dimension equality is introduced. -/
theorem varying_dimensions (C : CSrv) : TraceSignature true captured inputs :=
  TraceSignature.of_shapeless_source (captured_holds C) (inputs_holds C) rfl

/-- The derived signature remains valid after the loop valuation changes. -/
theorem varying_dimensions_subst (C : CSrv) (θ : Nat → SymE) :
    TraceSignature true (Metadata.subst θ captured) (Metadata.subst θ inputs) :=
  (varying_dimensions C).subst θ

theorem reject_rank : ¬ TraceSignature true captured [([],12)] := by
  intro signature
  cases signature with
  | rank _ _ _ sameRank => cases sameRank

theorem reject_dtype : ¬ TraceSignature true captured [([.literal (.var 1)],10)] := by
  intro signature
  cases signature

end Host.Mlx.Ffi.Annotated.ShapelessSignatureTest
