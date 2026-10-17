import kernels.trellis.DownFlushToZero

namespace Inference.Layers.TrellisCodebookDown
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

-- The base single-row projection, before any optional delta adapter. Shape
-- reshaping, native ownership, and adapter execution are not asserted here.
noncomputable def weight (words : DownExecution.PackedMatrix) (k : Nat)
    (scale : Nat → Float32) (row col : Nat) : ℝ :=
  DownAccuracy.idealCoefficient words k row col * real (scale row)

noncomputable def target (words : DownExecution.PackedMatrix) (k : Nat)
    (scale : Nat → Float32) (input : Nat → ℝ) (col : Nat) : ℝ :=
  ∑ row : Fin 17408, weight words k scale row.val col * input row.val

noncomputable def propagatedBudget (words : DownExecution.PackedMatrix) (k : Nat)
    (scale : Nat → Float32) (inputError : Nat → ℝ) (col : Nat) : ℝ :=
  ∑ row : Fin 17408, |weight words k scale row.val col| * inputError row.val

theorem target_error (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input ideal inputError : Nat → ℝ) (col : Nat)
    (h : ∀ row : Fin 17408, |input row.val - ideal row.val| ≤ inputError row.val) :
    |target words k scale input col - target words k scale ideal col| ≤ propagatedBudget words k scale inputError col := by
  unfold target propagatedBudget
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ row : Fin 17408, |weight words k scale row.val col * input row.val - weight words k scale row.val col * ideal row.val| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ _ := by
      apply Finset.sum_le_sum
      intro row _
      rw [← mul_sub, abs_mul]
      exact mul_le_mul_of_nonneg_left (h row) (abs_nonneg _)

theorem input_error (words : DownExecution.PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (ideal inputError : Nat → ℝ) (col : Nat)
    (h : ∀ row : Fin 17408, |real (input row.val)-ideal row.val| ≤ inputError row.val) :
    |DownReduction.dotProduct words k scale input col-target words k scale ideal col| ≤
      propagatedBudget words k scale inputError col := by
  have he : DownReduction.dotProduct words k scale input col-target words k scale ideal col =
      ∑ row : Fin 17408, weight words k scale row.val col * (real (input row.val)-ideal row.val) := by
    unfold DownReduction.dotProduct target weight
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro row _
    ring
  rw [he]
  calc
    _ ≤ ∑ row : Fin 17408, |weight words k scale row.val col * (real (input row.val)-ideal row.val)| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ propagatedBudget words k scale inputError col := by
      apply Finset.sum_le_sum
      intro row _
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_left (h row) (abs_nonneg _)

theorem output_error (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (before : Nat → M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ideal inputError : Nat → ℝ) (col : Nat) (hc : col<5120)
    (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (convert : Float32 → Float32) (conversion : BFloat16.RneContract convert)
    (hf : DownFlushToZero.Finite words k scale input col hardware.tree)
    (hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite
      (BFloat16.narrow (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val col)))=true)
    (hi : ∀ row : Fin 17408, |real (input row.val)-ideal row.val| ≤ inputError row.val) :
    |real (DownFlushToZero.output load before base words k scale input reduce convert col)-
      target words k scale ideal col| ≤
      DownFlushToZero.budget words k scale input col hardware.tree +
        BFloat16.epsilon (real (reduce (fun y => DownFlushToZero.partialSum words k scale input y.val col))) +
        propagatedBudget words k scale inputError col := by
  have localError := DownFlushToZero.output_bfloat_error load loads before base ha hn words k hk scale input
    col hc reduce hardware convert conversion hf hb
  have upstreamError := input_error words k scale input ideal inputError col hi
  calc
    _ = |(real (DownFlushToZero.output load before base words k scale input reduce convert col)-
          DownReduction.dotProduct words k scale input col) +
        (DownReduction.dotProduct words k scale input col-target words k scale ideal col)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add localError upstreamError)

structure Platform where
  load : M1Max.ThreadgroupLoad
  loads : M1Max.LoadContract load
  before : Nat → M1Max.WordMemory
  base : Nat
  aligned : base % 4 = 0
  bounded : base + 16384 ≤ 2^64
  reduce : DownExecution.SimdReduction
  reduction : GateUpFlushToZero.SimdContract reduce

structure Projection where
  words : DownExecution.PackedMatrix
  width : Nat
  validWidth : width = 2 ∨ width = 3 ∨ width = 4
  scale : Nat → Float32

def raw (platform : Platform) (w : Projection) (input : Nat → Float32) (col : Fin 5120) : Float32 :=
  platform.reduce (fun y => DownFlushToZero.partialSum w.words w.width w.scale input y.val col.val)

def value (platform : Platform) (w : Projection) (input : Nat → Float32) (col : Fin 5120) : Model FloatFormat.bfloat16 :=
  BFloat16.narrow (raw platform w input col)

def forward (platform : Platform) (w : Projection) (input : Nat → Float32) (col : Fin 5120) : Float32 :=
  DownFlushToZero.output platform.load platform.before platform.base w.words w.width w.scale input platform.reduce BFloat16.cast col.val

theorem forward_eq_widen (platform : Platform) (w : Projection) (input : Nat → Float32) (col : Fin 5120) :
    forward platform w input col = BFloat16.widen (value platform w input col) :=
  DownFlushToZero.output_correct platform.load platform.loads platform.before platform.base platform.aligned platform.bounded
    w.words w.width w.validWidth w.scale input platform.reduce BFloat16.cast col.val col.isLt

structure Finite (platform : Platform) (w : Projection) (input : Nat → Float32) : Prop where
  reduction : ∀ col : Fin 5120, DownFlushToZero.Finite w.words w.width w.scale input col.val platform.reduction.tree
  narrowing : ∀ col : Fin 5120, Model.isFinite (value platform w input col) = true

noncomputable def errorBudget (platform : Platform) (w : Projection) (input : Nat → Float32)
    (inputError : Nat → ℝ) (col : Fin 5120) : ℝ :=
  DownFlushToZero.budget w.words w.width w.scale input col.val platform.reduction.tree +
    BFloat16.epsilon (real (raw platform w input col)) + propagatedBudget w.words w.width w.scale inputError col.val

theorem value_error (platform : Platform) (w : Projection) (input : Nat → Float32) (hf : Finite platform w input)
    (ideal inputError : Nat → ℝ) (hi : ∀ row : Fin 17408, |real (input row.val) - ideal row.val| ≤ inputError row.val)
    (col : Fin 5120) :
    |Model.toReal (value platform w input col) - target w.words w.width w.scale ideal col.val| ≤
      errorBudget platform w input inputError col := by
  have he := output_error platform.load platform.loads platform.before platform.base platform.aligned platform.bounded
    w.words w.width w.validWidth w.scale input ideal inputError col.val col.isLt platform.reduce platform.reduction
    BFloat16.cast BFloat16.modelContract (hf.reduction col) (hf.narrowing col) hi
  change |real (forward platform w input col) - _| ≤ _ at he
  rw [forward_eq_widen, BFloat16.widen_real _ (hf.narrowing col)] at he
  exact he

end Inference.Layers.TrellisCodebookDown
