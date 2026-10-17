import contracts.mlx.Reduction
import contracts.mlx.BFloat16
import kernels.trellis.DownAccuracy
import kernels.trellis.DownMemory
import Mathlib.Algebra.BigOperators.Fin

set_option maxRecDepth 10000

namespace Inference.Kernels.Trellis.DownReduction
open Contracts.Mlx.Numerics Contracts.Mlx.Reduction DownExecution DownAccuracy
open scoped BigOperators

def firstTree : Tree 5 := .add (.leaf 4) (.add (.leaf 3) (.add (.leaf 2) (.add (.leaf 1) (.leaf 0))))

def firstInputs (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) (i : Fin 5) : Float32 :=
  if i.val=0 then 0 else splitSum words k scale input (y+32*(i.val-1)) col

noncomputable def firstTargets (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) (i : Fin 5) : ℝ :=
  if i.val=0 then 0 else idealSum words k scale input ((y+32*(i.val-1))*136) col 136

noncomputable def firstErrors (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) (i : Fin 5) : ℝ :=
  if i.val=0 then 0 else
    errorBudget (fun row => coefficient words k row col) scale input ((y+32*(i.val-1))*136) 136 +
      decoderBudget words k scale input ((y+32*(i.val-1))*136) col 136

def SplitFinite (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (split col : Nat) : Prop :=
  (∀ r, r<136 → (coefficient words k (split*136+r) col * scale (split*136+r)).isFinite=true) ∧
  (∀ r, r<136 → (input (split*136+r)).isFinite=true) ∧
  (∀ n, n≤136 → (accumulated (fun row => coefficient words k row col) scale input (split*136) n).isFinite=true)

theorem first_input_error (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) (h : ∀ s, s<4 → SplitFinite words k scale input (y+32*s) col) (i : Fin 5) :
    |real (firstInputs words k scale input y col i) - firstTargets words k scale input y col i| ≤
      firstErrors words k scale input y col i := by
  by_cases hi : i.val=0
  · simp [firstInputs, firstTargets, firstErrors, hi, real_zero]
  · obtain ⟨hw, hx, ha⟩ := h (i.val-1) (by have := i.isLt; omega)
    simpa only [firstInputs, firstTargets, firstErrors, hi, ite_false] using
      matrix_split_error words k scale input (y+32*(i.val-1)) col hw hx ha

theorem first_evaluate (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat) :
    evaluate (firstInputs words k scale input y col) firstTree = partialSum words k scale input y col := by
  rfl

noncomputable def idealFirst (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat) : ℝ :=
  ∑ s : Fin 4, idealSum words k scale input ((y+32*s.val)*136) col 136

theorem first_ideal (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat) :
    ideal (firstTargets words k scale input y col) firstTree = idealFirst words k scale input y col := by
  simp [firstTree, ideal, firstTargets, idealFirst, Fin.sum_univ_succ]
  ring

noncomputable def firstBudget (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat) : ℝ :=
  budget (firstInputs words k scale input y col) (firstErrors words k scale input y col) firstTree

theorem first_error (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (y col : Nat)
    (hs : ∀ s, s<4 → SplitFinite words k scale input (y+32*s) col)
    (hf : Finite (firstInputs words k scale input y col) firstTree) :
    |real (partialSum words k scale input y col) - idealFirst words k scale input y col| ≤
      firstBudget words k scale input y col := by
  have h := error (firstInputs words k scale input y col) (firstTargets words k scale input y col)
    (firstErrors words k scale input y col) (first_input_error words k scale input y col hs) firstTree hf
  rw [first_evaluate, first_ideal] at h
  exact h

abbrev RowIndex := Fin 32 × Fin 4 × Fin 136

def rowEquiv : RowIndex ≃ Fin 17408 where
  toFun p := ⟨(p.1.val+32*p.2.1.val)*136+p.2.2.val, by
    have := p.1.isLt; have := p.2.1.isLt; have := p.2.2.isLt; omega⟩
  invFun r := (⟨r.val/136%32, by omega⟩, ⟨r.val/136/32, by have := r.isLt; omega⟩,
    ⟨r.val%136, by omega⟩)
  left_inv p := by
    rcases p with ⟨⟨y, hy⟩, ⟨s, hs⟩, ⟨r, hr⟩⟩
    apply Prod.ext
    · apply Fin.ext; dsimp only; omega
    · apply Prod.ext <;> apply Fin.ext <;> dsimp only <;> omega
  right_inv r := by
    apply Fin.ext
    dsimp only
    have := r.isLt
    omega

theorem rows_once (term : Fin 17408 → ℝ) :
    (∑ p : RowIndex, term (rowEquiv p)) = ∑ r : Fin 17408, term r := by
  exact Equiv.sum_comp rowEquiv term

theorem idealSum_eq_sum (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (start col count : Nat) :
    idealSum words k scale input start col count =
      ∑ i : Fin count, idealCoefficient words k (start+i.val) col * real (scale (start+i.val)) * real (input (start+i.val)) := by
  induction count with
  | zero => simp [idealSum]
  | succ count ih =>
    rw [idealSum, Fin.sum_univ_castSucc, ih]
    simp only [Fin.val_castSucc, Fin.val_last]
    ring

theorem simd_error_bound (reduce : SimdReduction) (hardware : SimdContract reduce)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (col : Nat)
    (hs : ∀ y : Fin 32, ∀ s, s<4 → SplitFinite words k scale input (y.val+32*s) col)
    (hf : ∀ y : Fin 32, Finite (firstInputs words k scale input y.val col) firstTree)
    (ht : Finite (fun y : Fin 32 => partialSum words k scale input y.val col) hardware.tree) :
    |real (reduce (fun y => partialSum words k scale input y.val col)) -
      ((List.finRange 32).map (fun y => idealFirst words k scale input y.val col)).sum| ≤
      budget (fun y => partialSum words k scale input y.val col)
        (fun y => firstBudget words k scale input y.val col) hardware.tree := by
  apply simd_error reduce hardware
  · intro y
    exact first_error words k scale input y.val col (hs y) (hf y)
  · exact ht

noncomputable def dotProduct (words : PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (col : Nat) : ℝ :=
  ∑ r : Fin 17408, idealCoefficient words k r.val col * real (scale r.val) * real (input r.val)

-- The split schedule is a bijection onto the input rows. Associativity here
-- applies only to the exact real target; the rounded execution keeps its tree.
theorem target_is_dotProduct (words : PackedMatrix) (k : Nat)
    (scale input : Nat → Float32) (col : Nat) :
    ((List.finRange 32).map (fun y => idealFirst words k scale input y.val col)).sum =
      dotProduct words k scale input col := by
  rw [← Fin.sum_univ_def]
  unfold idealFirst
  simp only [idealSum_eq_sum]
  have h := rows_once (fun r => idealCoefficient words k r.val col * real (scale r.val) * real (input r.val))
  simp only [RowIndex, Fintype.sum_prod_type, rowEquiv, Equiv.coe_fn_mk] at h
  exact h

noncomputable def projectionBudget (reduce : SimdReduction) (hardware : SimdContract reduce)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (col : Nat) : ℝ :=
  budget (fun y => partialSum words k scale input y.val col)
    (fun y => firstBudget words k scale input y.val col) hardware.tree

-- Includes packed decoding, codebook initialization, scratch writes, both
-- reduction stages, and their numerical errors. The final bf16 cast is separate.
theorem output_error (load : Contracts.Mlx.M1Max.ThreadgroupLoad)
    (loads : Contracts.Mlx.M1Max.LoadContract load)
    (before : Nat → Contracts.Mlx.M1Max.WordMemory) (base : Nat)
    (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (reduce : SimdReduction) (hardware : SimdContract reduce)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (col : Nat) (hc : col<5120)
    (hs : ∀ y : Fin 32, ∀ s, s<4 → SplitFinite words k scale input (y.val+32*s) col)
    (hf : ∀ y : Fin 32, Finite (firstInputs words k scale input y.val col) firstTree)
    (ht : Finite (fun y : Fin 32 => partialSum words k scale input y.val col) hardware.tree) :
    |real (DownMemory.output load before base words k scale input reduce id col) -
      dotProduct words k scale input col| ≤ projectionBudget reduce hardware words k scale input col := by
  rw [DownMemory.output_correct load loads before base ha hn words k hk scale input reduce id col hc]
  have h := simd_error_bound reduce hardware words k scale input col hs hf ht
  rw [target_is_dotProduct] at h
  exact h

theorem output_bfloat_error (load : Contracts.Mlx.M1Max.ThreadgroupLoad)
    (loads : Contracts.Mlx.M1Max.LoadContract load)
    (before : Nat → Contracts.Mlx.M1Max.WordMemory) (base : Nat)
    (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (reduce : SimdReduction) (hardware : SimdContract reduce)
    (convert : Float32 → Float32) (conversion : Contracts.Mlx.BFloat16.RneContract convert)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (col : Nat) (hc : col<5120)
    (hs : ∀ y : Fin 32, ∀ s, s<4 → SplitFinite words k scale input (y.val+32*s) col)
    (hf : ∀ y : Fin 32, Finite (firstInputs words k scale input y.val col) firstTree)
    (ht : Finite (fun y : Fin 32 => partialSum words k scale input y.val col) hardware.tree)
    (hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite
      (Contracts.Mlx.BFloat16.narrow (reduce (fun y => partialSum words k scale input y.val col)))=true) :
    |real (DownMemory.output load before base words k scale input reduce convert col) -
      dotProduct words k scale input col| ≤ projectionBudget reduce hardware words k scale input col +
        Contracts.Mlx.BFloat16.epsilon (real (reduce (fun y => partialSum words k scale input y.val col))) := by
  have hp := simd_error_bound reduce hardware words k scale input col hs hf ht
  rw [target_is_dotProduct] at hp
  have hfinite : (reduce (fun y => partialSum words k scale input y.val col)).isFinite=true := by
    rw [hardware.execution]
    exact finite_evaluate _ _ ht
  have hcvt := Contracts.Mlx.BFloat16.rne_error convert conversion _ hfinite hb
  rw [DownMemory.output_correct load loads before base ha hn words k hk scale input reduce convert col hc]
  change |real (convert (reduce (fun y => partialSum words k scale input y.val col))) - _| ≤ _
  calc
    _ = |(real (convert (reduce (fun y => partialSum words k scale input y.val col))) -
          real (reduce (fun y => partialSum words k scale input y.val col))) +
        (real (reduce (fun y => partialSum words k scale input y.val col)) - dotProduct words k scale input col)| := by
      congr 1
      ring
    _ ≤ _ := (abs_add_le _ _).trans ((add_le_add hcvt hp).trans (by unfold projectionBudget; ring_nf; rfl))

end Inference.Kernels.Trellis.DownReduction
