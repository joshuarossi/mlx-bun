import host.mlx.NativeSizeValues
set_option Elab.async false
namespace Host.Mlx.Ffi.Annotated.Tests.SizeValues
open Host.Ts Host.Ts.Owned

def varied : Shape := [.literal (.var 0)]
def valuation (n : Nat) : Nat → F64 := fun _ => F64.ofNat n

theorem varied_size (n : Nat) (bound : n < 2^53) : NaturalSize (valuation n) varied [n] := by
  exact .cons (.var 0) n rfl bound (by simpa only [List.foldr_cons,List.foldr_nil,Nat.mul_one] using bound) .nil
example : closedLiteralShape varied = false := by decide +kernel
example : NaturalSizeBounds [1,4,256,256] := by decide +kernel
example : NaturalSizeBounds [0,2^53] → False := by
  intro h
  have impossible := h.2.2.1
  omega
example : NaturalSizeBounds [2^53] → False := by
  intro h
  have impossible := h.1
  omega
end Host.Mlx.Ffi.Annotated.Tests.SizeValues
