import host.mlx.OpsPrefill

namespace Host.Route.Sat
open Inference Inference.Contracts.Mlx Inference.Kernels Host.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # A model of MLX's contract

`MlxPrefillContract C` has only one clause that constrains a value, `log2_route` (and `hiddenThreads_m1max` on the
limit); every other field names a choice or an operation, which the model takes constant. -/

/-- A BF16 value for the operations the contract only names. -/
def bfOne : BF := BFloat16Arithmetic.one

/-- **A model of MLX's contract**, over any machine. -/
def mlxModel (C : M1Max.Contract) : MlxPrefillContract C where
  hiddenThreads := ⟨1024, by decide, by decide, by decide⟩
  hiddenThreads_m1max := rfl
  rmsContracted := false
  ropeFirst := .separate
  ropeSecond := .separate
  sdpaSum := false
  sdpaNumerator := .separate
  sdpaScore := false
  sdpaMerge := false
  convContracted := false
  qmvContracted := false
  qmvTail := false
  dequantizeContracted := false
  log2 := fun _ => Float32.ofBits 0x41ba0729
  log2_route := rfl
  logAddExp := ⟨false, false⟩
  ropeRowsFirst := .separate
  ropeRowsSecond := .separate
  sdpaCausal := fun _ _ _ _ => bfOne
  matmul := fun _ _ _ => bfOne
  softmaxPrecise := fun _ _ => bfOne
  sumAxis := fun _ _ _ => 1
  qmmRows := fun _ _ _ _ _ => bfOne
  dequantize3 := fun _ _ _ _ => bfOne
  silu := fun _ => bfOne
  swiglu := fun _ _ => bfOne
  preciseSwiglu := fun _ _ => bfOne

end Host.Route.Sat
