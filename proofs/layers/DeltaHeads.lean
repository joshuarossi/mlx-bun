import kernels.delta.SiluRmsHeads

namespace Inference.Layers.DeltaHeads
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Delta
abbrev BF := BFloat16Arithmetic.Value

-- Fixed Qwen head geometry: 16 Q, 16 K, and 48 V heads, each 128 wide.
-- The tensor's row dimension combines batch and sequence exactly as the launch.
def channel (head : Fin 80) (column : Fin 128) : Fin 10240 :=
  ⟨head.val * 128 + column.val, by have := head.isLt; have := column.isLt; omega⟩
def qHead (head : Fin 16) : Fin 80 := ⟨head.val, by have := head.isLt; omega⟩
def kHead (head : Fin 16) : Fin 80 := ⟨16 + head.val, by have := head.isLt; omega⟩
def vHead (head : Fin 48) : Fin 80 := ⟨32 + head.val, by have := head.isLt; omega⟩

def sourceChannel (head : Fin 80) : Nat :=
  if head.val < 32 then head.val * 128 else 4096 + (head.val - 32) * 128

theorem source_channel (head : Fin 80) : sourceChannel head = head.val * 128 := by
  unfold sourceChannel
  split <;> omega

theorem input_offset (row : Nat) (head : Fin 80) (column : Fin 128) :
    row * 10240 + sourceChannel head + column.val = row * 10240 + (channel head column).val := by
  rw [source_channel]
  simp only [channel]
  omega

theorem input_bound (row : Fin rows) (head : Fin 80) (column : Fin 128) :
    row.val * 10240 + (channel head column).val < rows * 10240 := by
  have := row.isLt
  have := (channel head column).isLt
  omega

theorem channel_injective (a b : Fin 80) (i j : Fin 128) (h : channel a i = channel b j) : a = b ∧ i = j := by
  have he := congrArg Fin.val h
  have := i.isLt
  have := j.isLt
  constructor <;> apply Fin.ext <;> dsimp [channel] at he <;> omega

theorem q_offset (row : Nat) (head : Fin 16) (column : Fin 128) :
    (row * 16 + (qHead head).val % 16) * 128 + column.val = (row * 16 + head.val) * 128 + column.val := by
  simp only [qHead, Nat.mod_eq_of_lt head.isLt]

theorem k_offset (row : Nat) (head : Fin 16) (column : Fin 128) :
    (row * 16 + (kHead head).val % 16) * 128 + column.val = (row * 16 + head.val) * 128 + column.val := by
  have := head.isLt
  simp only [kHead]
  omega

theorem v_offset (row : Nat) (head : Fin 48) (column : Fin 128) :
    (row * 48 + (vHead head).val - 32) * 128 + column.val = (row * 48 + head.val) * 128 + column.val := by
  simp only [vHead]
  omega

theorem output_bound (row : Fin rows) (head : Fin heads) (column : Fin 128) :
    (row.val * heads + head.val) * 128 + column.val < rows * heads * 128 := by
  have h : row.val * heads + head.val < rows * heads := by
    calc
      _ < row.val * heads + heads := Nat.add_lt_add_left head.isLt _
      _ = (row.val + 1) * heads := by ring
      _ ≤ rows * heads := Nat.mul_le_mul_right heads row.isLt
  have := column.isLt
  omega

def slice (input : Fin rows → Fin 10240 → α) (row : Fin rows) (head : Fin 80) : Fin 128 → α :=
  fun i => input row (channel head i)

structure Output (rows : Nat) (α : Type) where
  q : Fin rows → Fin 16 → Fin 128 → α
  k : Fin rows → Fin 16 → Fin 128 → α
  v : Fin rows → Fin 48 → Fin 128 → α

def forward (p : SiluRmsHeads.Platform) (input : Fin rows → Fin 10240 → BF)
    (qScale kScale : Fin 128 → BF) (width eps : Float32) : Output rows BF where
  q row head := SiluRmsHeads.normalized p (slice input row (qHead head)) qScale width eps
  k row head := SiluRmsHeads.normalized p (slice input row (kHead head)) kScale width eps
  v row head i := SiluRmsHeads.activate p (slice input row (vHead head) i)

noncomputable def target (input : Fin rows → Fin 10240 → ℝ) (qScale kScale : Fin 128 → BF) (eps : ℝ) : Output rows ℝ where
  q row head := Normalization.rmsNorm (fun i => SiluRmsHeads.silu (slice input row (qHead head) i)) (fun i => Model.toReal (qScale i)) eps
  k row head := Normalization.rmsNorm (fun i => SiluRmsHeads.silu (slice input row (kHead head) i)) (fun i => Model.toReal (kScale i)) eps
  v row head i := SiluRmsHeads.silu (slice input row (vHead head) i)

structure Finite (p : SiluRmsHeads.Platform) (input : Fin rows → Fin 10240 → BF)
    (qScale kScale : Fin 128 → BF) (width eps : Float32) : Prop where
  activation : ∀ row head i, SiluRmsHeads.ActivationFinite p (slice input row head i)
  qNorm : ∀ row head, SiluRmsHeads.NormFinite p (slice input row (qHead head)) qScale width eps
  kNorm : ∀ row head, SiluRmsHeads.NormFinite p (slice input row (kHead head)) kScale width eps

noncomputable def bounds (p : SiluRmsHeads.Platform) (input : Fin rows → Fin 10240 → BF)
    (qScale kScale : Fin 128 → BF) (width eps : Float32) (idealEps epsError : ℝ)
    (ideal error : Fin rows → Fin 10240 → ℝ) : Output rows ℝ where
  q row head := SiluRmsHeads.inputBudget p (slice input row (qHead head)) qScale width eps idealEps epsError
    (slice ideal row (qHead head)) (slice error row (qHead head))
  k row head := SiluRmsHeads.inputBudget p (slice input row (kHead head)) kScale width eps idealEps epsError
    (slice ideal row (kHead head)) (slice error row (kHead head))
  v row head i := SiluRmsHeads.activationInputBudget p (slice input row (vHead head) i)
    (slice ideal row (vHead head) i) (slice error row (vHead head) i)

structure Error (actual : Output rows BF) (ideal bound : Output rows ℝ) : Prop where
  q : ∀ row head i, |Model.toReal (actual.q row head i) - ideal.q row head i| ≤ bound.q row head i
  k : ∀ row head i, |Model.toReal (actual.k row head i) - ideal.k row head i| ≤ bound.k row head i
  v : ∀ row head i, |Model.toReal (actual.v row head i) - ideal.v row head i| ≤ bound.v row head i

theorem forward_error (p : SiluRmsHeads.Platform) (input : Fin rows → Fin 10240 → BF)
    (qScale kScale : Fin 128 → BF) (width eps : Float32) (idealEps epsError : ℝ)
    (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : Finite p input qScale kScale width eps) (ideal error : Fin rows → Fin 10240 → ℝ)
    (hi : ∀ row i, |Model.toReal (input row i) - ideal row i| ≤ error row i) :
    Error (forward p input qScale kScale width eps) (target ideal qScale kScale idealEps)
      (bounds p input qScale kScale width eps idealEps epsError ideal error) := by
  constructor
  · intro row head i
    exact SiluRmsHeads.normalized_input_error p _ qScale width eps idealEps epsError hp he
      (hf.qNorm row head) (hf.activation row (qHead head)) _ _ (fun j => hi row (channel (qHead head) j)) i
  · intro row head i
    exact SiluRmsHeads.normalized_input_error p _ kScale width eps idealEps epsError hp he
      (hf.kNorm row head) (hf.activation row (kHead head)) _ _ (fun j => hi row (channel (kHead head) j)) i
  · intro row head i
    exact SiluRmsHeads.activate_input_error p _ (hf.activation row (vHead head) i) _ _ (hi row (channel (vHead head) i))

end Inference.Layers.DeltaHeads
