import host.mlx.NativeTransposeRetained

set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated.TransposeRetainedTest
open Host.Ts Host.Ts.Owned

theorem variable_geometry (i c : Nat) :
    transposeShape [.literal (.var i),.literal (.var c)] [1,0] =
      [.literal (.var c),.literal (.var i)] := rfl

theorem geometry_rebase (θ : Nat → SymE) (shape : Shape) (axes : List Nat) :
    Shape.subst θ (transposeShape shape axes) = transposeShape (Shape.subst θ shape) axes :=
  transposeShape_subst θ shape axes

theorem input_ancestry (roles : Nat → GraphNode) (input : Nat) (axes : List Nat) :
    (transposeRole roles input axes).graph = some (.transpose axes,[input]) := rfl

theorem rank_guard_rejects_duplicates :
    (Nat.beq (Host.Ts.len [0,0]) 2 &&
      (List.range 2).all (fun a => [0,0].any (Nat.beq a))) = false := rfl

theorem rank_guard_rejects_omission :
    (Nat.beq (Host.Ts.len [0]) 2 &&
      (List.range 2).all (fun a => [0].any (Nat.beq a))) = false := rfl
end Host.Mlx.Ffi.Annotated.TransposeRetainedTest
