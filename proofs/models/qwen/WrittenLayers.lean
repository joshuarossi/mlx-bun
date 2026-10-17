import layers.TrellisCodebookGateUp
import layers.TrellisCodebookDown
import kernels.delta.Gates

namespace Inference.Models.Qwen.WrittenLayers
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open Layers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- A static activation choice, corresponding to the kernel specialization.
-- The match below models specialization; it adds no runtime validation.
inductive Activation where
  | float (expNeg : Float32 → Float32)
  | split (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value)

def hidden (activation : Activation) (platform : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) (row : Nat) : Float32 :=
  match activation with
  | .float expNeg => TrellisCodebookGateUp.floatOutput platform gate up input row expNeg
  | .split expAbs => TrellisCodebookGateUp.splitOutput platform gate up input row expAbs

-- This contract is a theorem about the mathematical function and numerical
-- error, not just shape compatibility. Constructors below discharge it from
-- kernel proofs. It can also be assembled row by row using the overflow
-- theorems, without changing the executed activation.
structure HiddenContract (activation : Activation) (platform : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) where
  error : Nat → ℝ
  accuracy : ∀ row : Fin 17408,
    |real (hidden activation platform gate up input row.val)-TrellisCodebookGateUp.layerTarget gate up input row.val| ≤ error row.val

-- Lift a checked kernel contract to an independently specified input. This
-- is needed when normalization has already introduced numerical error.
theorem hidden_input_error (activation : Activation) (platform : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (localProof : HiddenContract activation platform gate up input) (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c) (row : Fin 17408) :
    |real (hidden activation platform gate up input row.val) - TrellisCodebookGateUp.idealLayerTarget gate up ideal row.val| ≤
      localProof.error row.val + TrellisCodebookGateUp.layerInputBudget gate up input ideal inputError row.val := by
  calc
    _ = |(real (hidden activation platform gate up input row.val) - TrellisCodebookGateUp.layerTarget gate up input row.val) +
      (TrellisCodebookGateUp.layerTarget gate up input row.val - TrellisCodebookGateUp.idealLayerTarget gate up ideal row.val)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add (localProof.accuracy row)
      (TrellisCodebookGateUp.layer_input_error gate up input ideal inputError hi row.val))

-- The down projection propagates that upstream error through the actual
-- decoded weights. No claim of input equality is used at this boundary.
theorem gateDown_target_error (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32) (col : Nat) :
    |TrellisCodebookDown.target words k scale (TrellisCodebookGateUp.layerTarget gate up input) col -
      TrellisCodebookDown.target words k scale (TrellisCodebookGateUp.idealLayerTarget gate up ideal) col| ≤
      TrellisCodebookDown.propagatedBudget words k scale
        (TrellisCodebookGateUp.layerInputBudget gate up input ideal inputError) col :=
  TrellisCodebookDown.target_error words k scale _ _ _ col
    (fun row => TrellisCodebookGateUp.layer_input_error gate up input ideal inputError hi row.val)

noncomputable def floatFiniteContract (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (expNeg : Float32 → Float32) (expError : Float32 → ℝ) (exponential : GateUpTail.ExpNegContract expNeg expError)
    (hg : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p gate input row.val)
    (hu : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p up input row.val)
    (hgb : ∀ row : Fin 17408, Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val))=true)
    (hub : ∀ row : Fin 17408, Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row.val))=true)
    (hf : ∀ row : Fin 17408, GateUpTailFlushToZero.Finite expNeg
      (BFloat16.cast (TrellisCodebookGateUp.raw p gate input row.val)) (BFloat16.cast (TrellisCodebookGateUp.raw p up input row.val))) :
    HiddenContract (.float expNeg) p gate up input where
  error row := TrellisCodebookGateUp.layerBudget p gate up input row
    (real (BFloat16.cast (TrellisCodebookGateUp.raw p up input row)))
    (GateUpTailFlushToZero.tailBudget expNeg expError (BFloat16.cast (TrellisCodebookGateUp.raw p gate input row))
      (BFloat16.cast (TrellisCodebookGateUp.raw p up input row)))
  accuracy row := TrellisCodebookGateUp.float_finite_error p gate up input row.val expNeg expError exponential
    (hg row) (hu row) (hgb row) (hub row) (hf row)

noncomputable def splitFiniteContract (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) (expError : BFloat16Arithmetic.Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs expError)
    (hg : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p gate input row.val)
    (hu : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p up input row.val)
    (hs : ∀ row : Fin 17408, GateUpSplitTail.SigmoidFinite expAbs (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)))
    (hp : ∀ row : Fin 17408, GateUpSplitTail.ProductsFinite expAbs
      (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)) (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row.val))) :
    HiddenContract (.split expAbs) p gate up input where
  error row := TrellisCodebookGateUp.layerBudget p gate up input row
    (Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row)))
    (GateUpSplitTail.tailBudget expAbs (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))
      (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row))
      (GateUpSplitTail.sigmoidBudget expAbs expError (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))))
  accuracy row := TrellisCodebookGateUp.split_finite_error p gate up input row.val expAbs expError exponential
    (hg row) (hu row) (hs row) (hp row)

-- Compose either the finite exponential proof or its explicit overflow case.
noncomputable def splitValidContract (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) (expError : BFloat16Arithmetic.Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs expError)
    (hg : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p gate input row.val)
    (hu : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p up input row.val)
    (hs : ∀ row : Fin 17408, Kernels.Delta.Gates.BetaValid expAbs (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)))
    (hp : ∀ row : Fin 17408, GateUpSplitTail.ProductsFinite expAbs
      (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val)) (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row.val))) :
    HiddenContract (.split expAbs) p gate up input where
  error row := TrellisCodebookGateUp.layerBudget p gate up input row
    (Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row)))
    (GateUpSplitTail.tailBudget expAbs (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))
      (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row))
      (Kernels.Delta.Gates.betaBudget expAbs expError (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))))
  accuracy row := by
    have he := Kernels.Delta.Gates.beta_total_error expAbs expError exponential _ (hp row).hGate (hs row)
      (Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row.val))) 0 (by simp)
    simp only [zero_div, add_zero] at he
    have ht := GateUpSplitTail.tail_error_of_sigmoid_error expAbs _ _ _ (hp row).hGate (hp row).hUp
      (Kernels.Delta.Gates.beta_finite expAbs expError exponential _ (hs row)) (hp row).hSilu (hp row).hOutput he
    exact TrellisCodebookGateUp.split_compose p gate up input row.val expAbs _ (hg row) (hu row)
      (hp row).hGate (hp row).hUp (GateUpSplitTail.output_finite expAbs _ _ (hp row)) ht

-- GateDownMLP.forward is gateUp.forward followed by down.forward. This theorem
-- composes their numerical contracts for the base single-row Trellis path.
-- Optional delta adapters and other dispatch paths are separate proof targets.
theorem gateDown_error (activation : Activation) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (hmid : HiddenContract activation p gate up input)
    (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (before : Nat → M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (col : Nat) (hc : col<5120)
    (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (convert : Float32 → Float32) (conversion : BFloat16.RneContract convert)
    (hf : DownFlushToZero.Finite words k scale (hidden activation p gate up input) col hardware.tree)
    (hb : Model.isFinite (BFloat16.narrow (reduce (fun y =>
      DownFlushToZero.partialSum words k scale (hidden activation p gate up input) y.val col)))=true) :
    |real (DownFlushToZero.output load before base words k scale (hidden activation p gate up input) reduce convert col)-
      TrellisCodebookDown.target words k scale (TrellisCodebookGateUp.layerTarget gate up input) col| ≤
      DownFlushToZero.budget words k scale (hidden activation p gate up input) col hardware.tree +
        BFloat16.epsilon (real (reduce (fun y =>
          DownFlushToZero.partialSum words k scale (hidden activation p gate up input) y.val col))) +
        TrellisCodebookDown.propagatedBudget words k scale hmid.error col := by
  exact TrellisCodebookDown.output_error load loads before base ha hn words k hk scale
    (hidden activation p gate up input) (TrellisCodebookGateUp.layerTarget gate up input) hmid.error col hc
    reduce hardware convert conversion hf hb hmid.accuracy

-- The specialized graph fixes these choices once. This record describes the
-- base single-row GateDownMLP execution and its statically selected tail.
structure GateDown where
  activation : Activation
  gatePlatform : TrellisCodebookGateUp.Platform
  gate : TrellisCodebookGateUp.Projection
  up : TrellisCodebookGateUp.Projection
  downPlatform : TrellisCodebookDown.Platform
  down : TrellisCodebookDown.Projection

def GateDown.intermediate (mlp : GateDown) (input : Nat → BitVec 16) : Nat → Float32 :=
  hidden mlp.activation mlp.gatePlatform mlp.gate mlp.up input

def GateDown.forward (mlp : GateDown) (input : Nat → BitVec 16) : Fin 5120 → BFloat16Arithmetic.Value :=
  TrellisCodebookDown.value mlp.downPlatform mlp.down (mlp.intermediate input)

noncomputable def GateDown.target (mlp : GateDown) (input : Fin 5120 → ℝ) (col : Fin 5120) : ℝ :=
  TrellisCodebookDown.target mlp.down.words mlp.down.width mlp.down.scale
    (TrellisCodebookGateUp.idealLayerTarget mlp.gate mlp.up input) col.val

noncomputable def GateDown.errorBudget (mlp : GateDown) (input : Nat → BitVec 16) (ideal inputError : Fin 5120 → ℝ)
    (localProof : HiddenContract mlp.activation mlp.gatePlatform mlp.gate mlp.up input) (col : Fin 5120) : ℝ :=
  TrellisCodebookDown.errorBudget mlp.downPlatform mlp.down (mlp.intermediate input)
    (fun row => localProof.error row + TrellisCodebookGateUp.layerInputBudget mlp.gate mlp.up input ideal inputError row) col

theorem GateDown.forward_finite (mlp : GateDown) (input : Nat → BitVec 16)
    (hf : TrellisCodebookDown.Finite mlp.downPlatform mlp.down (mlp.intermediate input)) (col : Fin 5120) :
    Model.isFinite (mlp.forward input col) = true := hf.narrowing col

theorem GateDown.forward_error (mlp : GateDown) (input : Nat → BitVec 16) (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c)
    (localProof : HiddenContract mlp.activation mlp.gatePlatform mlp.gate mlp.up input)
    (hf : TrellisCodebookDown.Finite mlp.downPlatform mlp.down (mlp.intermediate input)) (col : Fin 5120) :
    |Model.toReal (mlp.forward input col) - mlp.target ideal col| ≤ mlp.errorBudget input ideal inputError localProof col :=
  TrellisCodebookDown.value_error mlp.downPlatform mlp.down (mlp.intermediate input) hf _ _
    (hidden_input_error mlp.activation mlp.gatePlatform mlp.gate mlp.up input localProof ideal inputError hi) col

end Inference.Models.Qwen.WrittenLayers
