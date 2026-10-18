import host.mlx.NativeSliceGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def convLength (length kernel : Int) (stride padding dilation : Nat) : Int :=
  (length + 2*padding - dilation*(kernel-1)-1)/stride+1

/-- Literal convolution metadata and the original integer channel/group
guard. Exact output meanings follow the model's stride/padding formula. -/
def ConvGeometry (ν : Nat → F64) (input weight output : Shape) (stride padding dilation groups : Nat) : Prop :=
  ∃ batch length channels outChannels kernel inChannels : Int,
    input.literalValues ν = some [batch,length,channels] ∧ weight.literalValues ν = some [outChannels,kernel,inChannels] ∧
    0 < stride ∧ 0 < groups ∧ channels = inChannels*groups ∧
    LiteralDimensions ν output [batch,convLength length kernel stride padding dilation,outChannels]

theorem ConvGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (input weight output : Shape)
    (stride padding dilation groups : Nat) :
    ConvGeometry ν (Shape.subst θ input) (Shape.subst θ weight) (Shape.subst θ output) stride padding dilation groups ↔
    ConvGeometry (Owned.Annotated.nextValuation θ ν) input weight output stride padding dilation groups := by
  simp only [ConvGeometry,Shape.literalValues_subst]
  constructor
  · rintro ⟨n,l,c,o,k,ci,hx,hw,hs,hg,hc,ho⟩
    exact ⟨n,l,c,o,k,ci,hx,hw,hs,hg,hc,ho.of_subst θ⟩
  · rintro ⟨n,l,c,o,k,ci,hx,hw,hs,hg,hc,ho⟩
    exact ⟨n,l,c,o,k,ci,hx,hw,hs,hg,hc,ho.subst θ⟩

theorem ConvGeometry.infer {ν : Nat → F64} {C : CSrv} {input weight output : Shape}
    {stride padding dilation groups : Nat}
    (geometry : ConvGeometry ν input weight output stride padding dilation groups) (dx dw : Nat) {x w : List Dim}
    (hx : Shape.Holds ν C input x) (hw : Shape.Holds ν C weight w) :
    ∃ shape, Shape.Holds ν C output shape ∧
      infer (.conv1d stride padding dilation groups) [(x,dx),(w,dw)] = M.pure (some (.node shape (promote dx dw))) := by
  obtain ⟨n,l,c,o,k,ci,hxv,hwv,hs,hg,hc,ho⟩ := geometry
  refine ⟨_,ho.holds C,?_⟩
  rw [hx.literalValues hxv,hw.literalValues hwv]
  have guard : decide (0 < stride ∧ 0 < groups ∧ c = ci*groups) = true := decide_eq_true ⟨hs,hg,hc⟩
  simp only [List.map_cons,List.map_nil,Host.Mlx.Ffi.infer,guard,Bool.cond_true,convLength]

end Host.Mlx.Ffi.Annotated
