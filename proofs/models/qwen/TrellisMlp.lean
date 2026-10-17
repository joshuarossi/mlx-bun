import models.qwen.WrittenLayers

namespace Inference.Models.Qwen.TrellisMlp
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Layers WrittenLayers

-- Discharge the intermediate numerical contract from primitive exponential
-- semantics and software ranges. No whole-kernel accuracy is a premise here.
structure FloatFinite (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) (expNeg : Float32 → Float32) where
  expError : Float32 → ℝ
  exponential : GateUpTail.ExpNegContract expNeg expError
  gateFinite : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p gate input row.val
  upFinite : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p up input row.val
  gateCast : ∀ row : Fin 17408, Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)) = true
  upCast : ∀ row : Fin 17408, Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row.val)) = true
  tail : ∀ row : Fin 17408, GateUpTailFlushToZero.Valid expNeg
    (BFloat16.cast (TrellisCodebookGateUp.raw p gate input row.val)) (BFloat16.cast (TrellisCodebookGateUp.raw p up input row.val))

structure SplitFinite (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) where
  expError : BFloat16Arithmetic.Value → ℝ
  exponential : GateUpSplitTail.ExpAbsContract expAbs expError
  gateFinite : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p gate input row.val
  upFinite : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p up input row.val
  sigmoid : ∀ row : Fin 17408, Kernels.Delta.Gates.BetaValid expAbs (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val))
  products : ∀ row : Fin 17408, GateUpSplitTail.ProductsFinite expAbs
    (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)) (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row.val))

def TailFinite (activation : Activation) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) : Type :=
  match activation with
  | .float expNeg => FloatFinite p gate up input expNeg
  | .split expAbs => SplitFinite p gate up input expAbs

noncomputable def tailContract (activation : Activation) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) :
    TailFinite activation p gate up input → HiddenContract activation p gate up input :=
  match activation with
  | .float expNeg => fun h => floatValidContract p gate up input expNeg h.expError h.exponential h.gateFinite h.upFinite h.gateCast h.upCast h.tail
  | .split expAbs => fun h => splitValidContract p gate up input expAbs h.expError h.exponential h.gateFinite h.upFinite h.sigmoid h.products

structure Finite (mlp : GateDown) (input : Nat → BitVec 16) where
  tail : TailFinite mlp.activation mlp.gatePlatform mlp.gate mlp.up input
  down : TrellisCodebookDown.Finite mlp.downPlatform mlp.down (mlp.intermediate input)

noncomputable def budget (mlp : GateDown) (input : Nat → BitVec 16) (target error : Fin 5120 → ℝ)
    (hf : Finite mlp input) : Fin 5120 → ℝ :=
  mlp.errorBudget input target error (tailContract mlp.activation mlp.gatePlatform mlp.gate mlp.up input hf.tail)

theorem forward_error (mlp : GateDown) (input : Nat → BitVec 16) (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |real (GateUpExecution.widen (input i.val)) - target i| ≤ error i) (hf : Finite mlp input) (i : Fin 5120) :
    |Model.toReal (mlp.forward input i) - mlp.target target i| ≤ budget mlp input target error hf i :=
  mlp.forward_error input target error hi (tailContract mlp.activation mlp.gatePlatform mlp.gate mlp.up input hf.tail) hf.down i

theorem forward_finite (mlp : GateDown) (input : Nat → BitVec 16) (hf : Finite mlp input) (i : Fin 5120) :
    Model.isFinite (mlp.forward input i) = true := mlp.forward_finite input hf.down i

end Inference.Models.Qwen.TrellisMlp
