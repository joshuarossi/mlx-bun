import kernels.StableSigmoid
import kernels.delta.SiluRmsHeads

namespace Inference.Kernels.GatedRmsNorm
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Trellis
abbrev BF := BFloat16Arithmetic.Value

-- The selected recurrent value head is 128-wide and launches one SIMD group.
-- Its RMS stage rounds to bf16; its gate then uses binary32 sigmoid/products
-- with just one final bf16 conversion, matching gated-rms-norm.ts.
structure Platform where
  reduce : (Fin 32 → Float32) → Float32
  reduction : FlushedReduction.SimdContract reduce
  contracted : Bool
  divide : Float32 → Float32 → Float32
  divError : Float32 → Float32 → ℝ
  division : Division.Contract divide divError
  rsqrt : Float32 → Float32
  rsqrtError : Float32 → ℝ
  rootAccuracy : Normalization.RsqrtContract rsqrt rsqrtError
  expAbs : Float32 → Float32
  expAbsError : Float32 → ℝ
  exponential : StableSigmoid.ExpContract expAbs expAbsError

def input (x : Fin 128 → BF) : Fin 128 → Float32 := fun i => BFloat16.widen (x i)
def expression (p : Platform) : SquaredSum.Expr 128 := Delta.SiluRmsHeads.expression p.contracted p.reduction.tree
def normalized (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) : BF :=
  BFloat16Arithmetic.mul (weight i) (BFloat16.narrow
    (NormalizationExecution.normalized p.divide (input x) (expression p) width eps p.rsqrt i))

def sourceNormalized (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) : BF :=
  let sum := Delta.SiluRmsHeads.sourceSum p.reduce p.contracted (input x)
  let inverse := p.rsqrt (FlushToZero.add (p.divide sum width) eps)
  BFloat16Arithmetic.mul (weight i) (BFloat16.narrow (FlushToZero.mul (input x i) inverse))

theorem normalized_execution (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) :
    sourceNormalized p x weight width eps i = normalized p x weight width eps i := by
  unfold sourceNormalized
  rw [Delta.SiluRmsHeads.sum_execution p.reduce p.reduction]
  rfl

def silu (p : Platform) (gate : Float32) : Float32 := FlushToZero.mul gate (StableSigmoid.value p.expAbs gate)
def product (p : Platform) (gate up : Float32) : Float32 := FlushToZero.mul (silu p gate) up
def tail (p : Platform) (gate up : Float32) : BF := BFloat16.narrow (product p gate up)
def value (p : Platform) (x gate weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) : BF :=
  tail p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight width eps i))

structure TailFinite (p : Platform) (gate up : Float32) : Prop where
  gateFinite : gate.isFinite = true
  sigmoid : StableSigmoid.Valid p.expAbs gate
  activation : (FlushToZero.flush gate * FlushToZero.flush (StableSigmoid.value p.expAbs gate)).isFinite = true
  product : (FlushToZero.flush (silu p gate) * FlushToZero.flush up).isFinite = true
  cast : Model.isFinite (tail p gate up) = true

noncomputable def tailBudget (p : Platform) (gate up : Float32) : ℝ :=
  BFloat16.epsilon (real (product p gate up)) + FlushToZero.mulBudget (silu p gate) up +
    (FlushToZero.mulBudget gate (StableSigmoid.value p.expAbs gate) +
      |real gate| * StableSigmoid.budget p.expAbs p.expAbsError gate) * |real up|

theorem tail_error (p : Platform) (gate up : Float32) (hf : TailFinite p gate up) :
    |Model.toReal (tail p gate up) - GateUpTail.swiglu (real gate) (real up)| ≤ tailBudget p gate up := by
  have hs := StableSigmoid.accuracy p.expAbs p.expAbsError p.exponential gate hf.gateFinite hf.sigmoid
  have ha := FlushToZero.mul_error gate (StableSigmoid.value p.expAbs gate) hf.activation
  have hm := FlushToZero.mul_error (silu p gate) up hf.product
  have ht := SwiGLUStability.arithmetic_composition (real gate) (real (StableSigmoid.value p.expAbs gate))
    (real (silu p gate)) (real up) (real (product p gate up)) _ _ _ hs ha hm
  have hc := BFloat16.narrow_error (product p gate up) (FlushToZero.mul_finite _ _ hf.product) hf.cast
  unfold tailBudget FlushToZero.mulBudget
  calc
    _ = |(Model.toReal (tail p gate up) - real (product p gate up)) +
      (real (product p gate up) - GateUpTail.swiglu (real gate) (real up))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hc ht)
      simpa only [tail, add_assoc] using h

def NormFinite (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32) : Prop :=
  NormalizationExecution.Finite p.divide (input x) weight (expression p) width eps p.rsqrt

noncomputable def normBudget (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (i : Fin 128) : ℝ :=
  NormalizationExecution.outputBudget p.divide p.divError (input x) weight (expression p)
    width eps idealEps epsError p.rsqrt p.rsqrtError i

theorem normalized_finite (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32)
    (hf : NormFinite p x weight width eps) (i : Fin 128) : Model.isFinite (normalized p x weight width eps i) = true :=
  BFloat16Arithmetic.finite_flushExact _ _ (hf.hOutput i)

theorem normalized_error (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormFinite p x weight width eps) (i : Fin 128) :
    |Model.toReal (normalized p x weight width eps i) -
      Normalization.rmsNorm (fun j => real (input x j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      normBudget p x weight width eps idealEps epsError i := by
  have h := NormalizationExecution.accuracy p.divide p.divError p.division (input x) weight
    (expression p) (Delta.SiluRmsHeads.expression_coverage p.contracted p.reduction.tree p.reduction.coverage)
    width eps idealEps epsError hp he p.rsqrt p.rsqrtError p.rootAccuracy hf i
  change |real (BFloat16.widen (normalized p x weight width eps i)) - _| ≤ _ at h
  rwa [BFloat16.widen_real _ (normalized_finite p x weight width eps hf i)] at h

noncomputable def propagatedNormBudget (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (target error : Fin 128 → ℝ) (i : Fin 128) : ℝ :=
  normBudget p x weight width eps idealEps epsError i + |Model.toReal (weight i)| *
    Normalization.inputBudget (fun j => real (input x j)) target error idealEps i

theorem normalized_input_error (p : Platform) (x weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormFinite p x weight width eps) (hx : ∀ j, Model.isFinite (x j) = true)
    (target error : Fin 128 → ℝ) (hi : ∀ j, |Model.toReal (x j) - target j| ≤ error j) (i : Fin 128) :
    |Model.toReal (normalized p x weight width eps i) -
      Normalization.rmsNorm target (fun j => Model.toReal (weight j)) idealEps i| ≤
      propagatedNormBudget p x weight width eps idealEps epsError target error i := by
  have hl := normalized_error p x weight width eps idealEps epsError hp he hf i
  have hs : ∀ j, |real (input x j) - target j| ≤ error j := by
    intro j
    rw [input, BFloat16.widen_real _ (hx j)]
    exact hi j
  have ht := Normalization.input_perturbation (fun j => real (input x j)) target error (fun j => Model.toReal (weight j)) idealEps hp hs i
  calc
    _ = |(Model.toReal (normalized p x weight width eps i) -
      Normalization.rmsNorm (fun j => real (input x j)) (fun j => Model.toReal (weight j)) idealEps i) +
      (Normalization.rmsNorm (fun j => real (input x j)) (fun j => Model.toReal (weight j)) idealEps i -
      Normalization.rmsNorm target (fun j => Model.toReal (weight j)) idealEps i)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl ht)

-- Both incoming errors matter: recurrence error reaches the RMS denominator
-- and the gate projection error perturbs the SiLU factor.
theorem value_error (p : Platform) (x gate weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormFinite p x weight width eps) (hx : ∀ j, Model.isFinite (x j) = true)
    (target error targetGate gateError : Fin 128 → ℝ)
    (hi : ∀ j, |Model.toReal (x j) - target j| ≤ error j)
    (hg : ∀ j, Model.isFinite (gate j) = true)
    (hge : ∀ j, |Model.toReal (gate j) - targetGate j| ≤ gateError j)
    (i : Fin 128) (ht : TailFinite p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight width eps i))) :
    |Model.toReal (value p x gate weight width eps i) -
      GateUpTail.swiglu (targetGate i) (Normalization.rmsNorm target (fun j => Model.toReal (weight j)) idealEps i)| ≤
      tailBudget p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight width eps i)) +
      gateError i * (1 + |targetGate i| / 4) * |Model.toReal (normalized p x weight width eps i)| +
      |targetGate i| * propagatedNormBudget p x weight width eps idealEps epsError target error i := by
  have hn := normalized_input_error p x weight width eps idealEps epsError hp he hf hx target error hi i
  have hl := tail_error p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight width eps i)) ht
  rw [BFloat16.widen_real _ (hg i), BFloat16.widen_real _ (normalized_finite p x weight width eps hf i)] at hl
  exact SwiGLUStability.compose _ _ _ _ _ _ _ _ hl (hge i) hn

end Inference.Kernels.GatedRmsNorm
