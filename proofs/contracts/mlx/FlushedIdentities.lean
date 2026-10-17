import contracts.mlx.FlushToZero

namespace Inference.Contracts.Mlx.FlushedIdentities
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem zero_real : real (0 : Float32) = 0 := by
  rw [real_unpack]
  exact Model.unpackedToReal_zero .positive

theorem flush_zero (x : Float32) (hx : real x = 0) : real (FlushToZero.flush x) = 0 := by
  have h := FlushToZero.flush_abs_le x
  rw [hx, abs_zero] at h
  exact abs_nonpos_iff.mp h

theorem flush_one (x : Float32) (hx : real x = 1) : real (FlushToZero.flush x) = 1 := by
  rw [FlushToZero.flush_eq_of_one_le x hx.ge, hx]

theorem round_one : Model.roundAt FloatFormat.binary32 (1 : ℝ) = 1 := by
  have h := Model.roundAt_toReal_eq (model (1 : Float32)) (by rw [finite_model]; decide)
  simpa only [show Model.toReal (model (1 : Float32)) = 1 from real_one] using h

theorem mul_zero_left (x y : Float32) (hx : real x = 0)
    (hf : (FlushToZero.flush x * FlushToZero.flush y).isFinite = true) :
    real (FlushToZero.mul x y) = 0 := by
  apply flush_zero
  rw [mul_real _ _ hf, flush_zero x hx, zero_mul, Model.roundAt_zero]

theorem mul_one_one (x y : Float32) (hx : real x = 1) (hy : real y = 1)
    (hf : (FlushToZero.flush x * FlushToZero.flush y).isFinite = true) :
    real (FlushToZero.mul x y) = 1 := by
  apply flush_one
  rw [mul_real _ _ hf, flush_one x hx, flush_one y hy, one_mul, round_one]

theorem add_zero_one (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (xz : real x = 0) (yo : real y = 1)
    (hf : (FlushToZero.flush x + FlushToZero.flush y).isFinite = true) :
    real (FlushToZero.add x y) = 1 := by
  apply flush_one
  rw [add_real _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy) hf,
    flush_zero x xz, flush_one y yo, zero_add, round_one]

theorem fma_zero_one (x y z : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hz : z.isFinite = true)
    (xz : real x = 0) (zo : real z = 1)
    (hf : (Float32.fma (FlushToZero.flush x) (FlushToZero.flush y) (FlushToZero.flush z)).isFinite = true) :
    real (FlushToZero.fma x y z) = 1 := by
  apply flush_one
  rw [fma_real _ _ _ (FlushToZero.finite_flush x hx) (FlushToZero.finite_flush y hy)
    (FlushToZero.finite_flush z hz) hf, flush_zero x xz, flush_one z zo, zero_mul, zero_add, round_one]

end Inference.Contracts.Mlx.FlushedIdentities
