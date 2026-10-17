import contracts.mlx.Numerics
import kernels.trellis.DownExecution
import kernels.trellis.CodebookAccuracy

namespace Inference.Kernels.Trellis.DownAccuracy
open Contracts.Mlx.Numerics DownCodebook

/- Forward error for the actual sequential multiplication/FMA accumulator.
   Budgets are evaluated at the executed prefix states, so they include
   cancellation and gradual underflow instead of assuming every sum is normal.
   Finiteness of the inputs, scaled weights, and prefix states is an explicit
   obligation for the caller; this theorem does not discharge model bounds. -/

theorem scalarRows_succ {α : Type} (step : Nat → α → α) (start count : Nat) (acc : α) :
    scalarRows step start (count+1) acc = step (start+count) (scalarRows step start count acc) := by
  induction count generalizing start acc with
  | zero => rfl
  | succ count ih =>
    change scalarRows step (start+1) (count+1) (step start acc) =
      step (start+(count+1)) (scalarRows step (start+1) count (step start acc))
    rw [ih]
    congr 1
    omega

def accumulated (code scale input : Nat → Float32) (start count : Nat) : Float32 :=
  scalarRows (accumulate code scale input) start count 0

theorem accumulated_succ (code scale input : Nat → Float32) (start count : Nat) :
    accumulated code scale input start (count+1) =
      Float32.fma (code (start+count)*scale (start+count)) (input (start+count))
        (accumulated code scale input start count) := by
  exact scalarRows_succ (accumulate code scale input) start count 0

noncomputable def exactSum (code scale input : Nat → Float32) (start : Nat) : Nat → ℝ
  | 0 => 0
  | count+1 => real (code (start+count))*real (scale (start+count))*real (input (start+count)) +
      exactSum code scale input start count

noncomputable def localBudget (code scale input : Nat → Float32) (start count : Nat) : ℝ :=
  epsilon (real (code (start+count))*real (scale (start+count))) * |real (input (start+count))| +
    epsilon (real (code (start+count)*scale (start+count))*real (input (start+count)) +
      real (accumulated code scale input start count))

noncomputable def errorBudget (code scale input : Nat → Float32) (start : Nat) : Nat → ℝ
  | 0 => 0
  | count+1 => localBudget code scale input start count + errorBudget code scale input start count

theorem real_zero : real (0 : Float32) = 0 := by
  rw [real_unpack]
  exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive

theorem accumulated_error (code scale input : Nat → Float32) (start count : Nat) :
    (∀ i, i<count → (code (start+i)*scale (start+i)).isFinite=true) →
    (∀ i, i<count → (input (start+i)).isFinite=true) →
    (∀ i, i≤count → (accumulated code scale input start i).isFinite=true) →
    |real (accumulated code scale input start count) - exactSum code scale input start count| ≤
      errorBudget code scale input start count := by
  induction count with
  | zero =>
    intro _ _ _
    simp only [accumulated, scalarRows, exactSum, errorBudget, real_zero, sub_self, abs_zero, le_refl]
  | succ count ih =>
    intro hw hx ha
    have prev := ih (fun i hi => hw i (by omega)) (fun i hi => hx i (by omega))
      (fun i hi => ha i (by omega))
    have hout := ha (count+1) (by omega)
    rw [accumulated_succ] at hout
    have step := scaled_fma_error (code (start+count)) (scale (start+count)) (input (start+count))
      (accumulated code scale input start count) (hw count (by omega)) (hx count (by omega))
      (ha count (by omega)) hout
    rw [accumulated_succ, exactSum, errorBudget]
    calc
      _ = |(real (Float32.fma (code (start+count)*scale (start+count)) (input (start+count))
          (accumulated code scale input start count)) -
          (real (code (start+count))*real (scale (start+count))*real (input (start+count)) +
            real (accumulated code scale input start count))) +
          (real (accumulated code scale input start count) - exactSum code scale input start count)| := by
        congr 1
        ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add step prev)

noncomputable def idealCoefficient (words : DownExecution.PackedMatrix) (k row col : Nat) : ℝ :=
  CodebookAccuracy.ideal (Codebook.PackedState.read (words row (col/256)) k (col%256))

noncomputable def idealSum (words : DownExecution.PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (start col : Nat) : Nat → ℝ
  | 0 => 0
  | count+1 => idealCoefficient words k (start+count) col * real (scale (start+count)) *
      real (input (start+count)) + idealSum words k scale input start col count

noncomputable def decoderBudget (words : DownExecution.PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (start col : Nat) : Nat → ℝ
  | 0 => 0
  | count+1 => |idealCoefficient words k (start+count) col| / 2^23 *
      |real (scale (start+count))| * |real (input (start+count))| +
      decoderBudget words k scale input start col count

theorem decoded_sum_error (words : DownExecution.PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (start col count : Nat) :
    |exactSum (fun row => DownExecution.coefficient words k row col) scale input start count -
      idealSum words k scale input start col count| ≤ decoderBudget words k scale input start col count := by
  induction count with
  | zero => simp [exactSum, idealSum, decoderBudget]
  | succ count ih =>
    have hc := CodebookAccuracy.relative_error
      (Codebook.PackedState.read (words (start+count) (col/256)) k (col%256))
    change |real (DownExecution.coefficient words k (start+count) col) -
      idealCoefficient words k (start+count) col| ≤ |idealCoefficient words k (start+count) col| / 2^23 at hc
    have hp := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_right hc (abs_nonneg (real (scale (start+count)))))
      (abs_nonneg (real (input (start+count))))
    rw [exactSum, idealSum, decoderBudget]
    calc
      _ = |(real (DownExecution.coefficient words k (start+count) col) - idealCoefficient words k (start+count) col) *
          real (scale (start+count)) * real (input (start+count)) +
          (exactSum (fun row => DownExecution.coefficient words k row col) scale input start count -
            idealSum words k scale input start col count)| := by congr 1; ring
      _ ≤ _ := (abs_add_le _ _).trans (add_le_add (by simpa only [abs_mul] using hp) ih)

theorem matrix_split_error (words : DownExecution.PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (split col : Nat)
    (hw : ∀ i, i<136 → (DownExecution.coefficient words k (split*136+i) col * scale (split*136+i)).isFinite=true)
    (hx : ∀ i, i<136 → (input (split*136+i)).isFinite=true)
    (ha : ∀ n, n≤136 →
      (accumulated (fun row => DownExecution.coefficient words k row col) scale input (split*136) n).isFinite=true) :
    |real (DownExecution.splitSum words k scale input split col) - idealSum words k scale input (split*136) col 136| ≤
      errorBudget (fun row => DownExecution.coefficient words k row col) scale input (split*136) 136 +
      decoderBudget words k scale input (split*136) col 136 := by
  have ha' := accumulated_error (fun row => DownExecution.coefficient words k row col) scale input (split*136) 136 hw hx ha
  have hd := decoded_sum_error words k scale input (split*136) col 136
  exact (abs_sub_le _ (exactSum (fun row => DownExecution.coefficient words k row col) scale input (split*136) 136) _).trans
    (add_le_add ha' hd)

-- A source lane's two-row unrolling inherits the same real error bound;
-- correctness is composed from the existing load and row-order theorems.
theorem lane_error (load : Contracts.Mlx.M1Max.ThreadgroupLoad)
    (hardware : Contracts.Mlx.M1Max.LoadContract load)
    (memory : Contracts.Mlx.M1Max.WordMemory) (base : Nat) (halign : base%4=0) (haddress : base+16384≤2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty sg lane i : Nat) (hl : lane<32) (hi : i<16)
    (hw : ∀ r, r<136 →
      (DownExecution.coefficient words k ((ty%32+32*(sg%4))*136+r) (DownExecution.laneColumn ty sg lane i) *
        scale ((ty%32+32*(sg%4))*136+r)).isFinite=true)
    (hx : ∀ r, r<136 → (input ((ty%32+32*(sg%4))*136+r)).isFinite=true)
    (ha : ∀ n, n≤136 →
      (accumulated (fun row => DownExecution.coefficient words k row (DownExecution.laneColumn ty sg lane i))
        scale input ((ty%32+32*(sg%4))*136) n).isFinite=true) :
    let code := fun row => DownExecution.coefficient words k row (DownExecution.laneColumn ty sg lane i)
    let start := (ty%32+32*(sg%4))*136
    |real (DownExecution.laneSum load memory base words k scale input ty sg lane i) -
      exactSum code scale input start 136| ≤ errorBudget code scale input start 136 := by
  dsimp only
  rw [DownExecution.laneSum_correct load hardware memory base halign haddress initialized words k hk
    scale input ty sg lane i hl hi]
  exact accumulated_error _ scale input _ 136 hw hx ha

end Inference.Kernels.Trellis.DownAccuracy
