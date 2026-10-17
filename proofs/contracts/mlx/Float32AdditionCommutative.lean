import contracts.mlx.FlushToZero

namespace Inference.Contracts.Mlx.Float32AdditionCommutative
open Float.Model.UnpackedFloat

-- Equality of logical binary32 values, including the sign of zero. NaNs are
-- excluded because payload selection can depend on the order of operands.
theorem unpacked (format : Float.Model.Format) (x y : Float.Model.UnpackedFloat)
    (hx : x.isFinite = true) (hy : y.isFinite = true) :
    add format x y = add format y x := by
  cases x <;> cases y <;>
    simp only [Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx hy
  case zero.zero sx sy => cases sx <;> cases sy <;> rfl
  case zero.finite => rfl
  case finite.zero => rfl
  case finite.finite => simp only [add, min_comm, Int.add_comm]

theorem finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    x + y = y + x := by
  change Float32.ofModel (Float32.Model.pack
      (add Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) =
    Float32.ofModel (Float32.Model.pack
      (add Float.Model.Format.binary32 y.toModel.unpack x.toModel.unpack))
  rw [unpacked _ _ _ hx hy]

theorem flushed (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    FlushToZero.add x y = FlushToZero.add y x := by
  unfold FlushToZero.add
  rw [finite _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy)]

end Inference.Contracts.Mlx.Float32AdditionCommutative
