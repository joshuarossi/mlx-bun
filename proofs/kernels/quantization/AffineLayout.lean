import contracts.mlx.ArithmeticFold
import contracts.mlx.Memory
import Mathlib.Algebra.BigOperators.Fin

namespace Inference.Kernels.Quantization.AffineLayout
open Contracts.Mlx
open scoped BigOperators

-- affineRowEligible fixes K to a multiple of 512, K <= 7680, N to a
-- multiple of 64, group size 64, and one input row. The launch has 16 SIMD
-- groups, each of 32 lanes, with four output rows per SIMD group.
def inputIndex (step : Fin steps) (lane : Fin 32) (column : Fin 16) : Fin (steps * 512) :=
  ⟨step.val * 512 + lane.val * 16 + column.val, by have := step.isLt; have := lane.isLt; have := column.isLt; omega⟩

def inputEquiv (steps : Nat) : (Fin steps × Fin 32 × Fin 16) ≃ Fin (steps * 512) where
  toFun p := inputIndex p.1 p.2.1 p.2.2
  invFun i := (⟨i.val / 512, by have := i.isLt; omega⟩,
    ⟨i.val / 16 % 32, by omega⟩, ⟨i.val % 16, by omega⟩)
  left_inv p := by
    rcases p with ⟨step, lane, column⟩
    have := lane.isLt
    have := column.isLt
    apply Prod.ext
    · apply Fin.ext; dsimp [inputIndex]; omega
    · apply Prod.ext <;> apply Fin.ext <;> dsimp [inputIndex] <;> omega
  right_inv i := by apply Fin.ext; dsimp [inputIndex]; omega

theorem input_coverage (f : Fin (steps * 512) → ℝ) :
    (∑ step : Fin steps, ∑ lane : Fin 32, ∑ column : Fin 16, f (inputIndex step lane column)) = ∑ i, f i := by
  simpa only [Fintype.sum_prod_type, inputEquiv, Equiv.coe_fn_mk] using Equiv.sum_comp (inputEquiv steps) f

theorem lane_coverage (f : Fin (steps * 512) → ℝ) :
    (∑ lane : Fin 32, ∑ step : Fin steps, ∑ column : Fin 16, f (inputIndex step lane column)) = ∑ i, f i := by
  rw [Finset.sum_comm]
  exact input_coverage f

def chunkIndex (step : Fin steps) (lane : Fin 32) : Fin (steps * 32) :=
  ⟨step.val * 32 + lane.val, by have := step.isLt; have := lane.isLt; omega⟩

theorem input_chunk (step : Fin steps) (lane : Fin 32) (column : Fin 16) :
    (chunkIndex step lane).val * 16 + column.val = (inputIndex step lane column).val := by
  dsimp [chunkIndex, inputIndex]
  omega

theorem sum_pointer (step : Fin steps) (lane : Fin 32) :
    (step.val * 512 + lane.val * 16) / 16 = (chunkIndex step lane).val := by
  dsimp [chunkIndex]
  omega

theorem group_pointer (step : Fin steps) (lane : Fin 32) (column : Fin 16) :
    (inputIndex step lane column).val / 64 = step.val * 8 + lane.val / 4 := by
  dsimp [inputIndex]
  have := lane.isLt
  have := column.isLt
  omega

theorem group_bound (step : Fin steps) (lane : Fin 32) : step.val * 8 + lane.val / 4 < steps * 8 := by
  have := step.isLt
  have := lane.isLt
  omega

theorem scale_offset (row0 r : Nat) (step : Fin steps) (lane : Fin 32) (column : Fin 16) :
    row0 * (steps * 8) + lane.val / 4 + r * (steps * 8) + step.val * 8 =
      (row0 + r) * (steps * 8) + (inputIndex step lane column).val / 64 := by
  rw [group_pointer]
  ring

def outputIndex (block : Fin blocks) (simd : Fin 16) (row : Fin 4) : Fin (blocks * 64) :=
  ⟨(block.val * 16 + simd.val) * 4 + row.val, by have := block.isLt; have := simd.isLt; have := row.isLt; omega⟩

theorem output_injective (a b : Fin blocks) (s t : Fin 16) (i j : Fin 4)
    (he : outputIndex a s i = outputIndex b t j) : a = b ∧ s = t ∧ i = j := by
  have h := congrArg Fin.val he
  have := s.isLt
  have := t.isLt
  have := i.isLt
  have := j.isLt
  dsimp [outputIndex] at h
  constructor
  · apply Fin.ext; omega
  · constructor <;> apply Fin.ext <;> omega

theorem output_owner (i : Fin (blocks * 64)) :
    ∃ block : Fin blocks, ∃ simd : Fin 16, ∃ row : Fin 4, outputIndex block simd row = i := by
  refine ⟨⟨i.val / 64, by have := i.isLt; omega⟩, ⟨i.val / 4 % 16, by omega⟩, ⟨i.val % 4, by omega⟩, ?_⟩
  apply Fin.ext
  dsimp [outputIndex]
  omega

-- Since K/16 <= 480 and the group has 512 threads, the preload loop runs
-- at most once per thread. Every live chunk has exactly one owner.
def preloadOwner (hsteps : steps ≤ 15) (chunk : Fin (steps * 32)) : Fin 16 × Fin 32 :=
  (⟨chunk.val / 32, by have := chunk.isLt; omega⟩, ⟨chunk.val % 32, by omega⟩)

theorem preload_owner (hsteps : steps ≤ 15) (chunk : Fin (steps * 32)) :
    (preloadOwner hsteps chunk).1.val * 32 + (preloadOwner hsteps chunk).2.val = chunk.val := by
  dsimp [preloadOwner]
  omega

theorem preload_unique (s t : Fin 16) (i j : Fin 32) (he : s.val * 32 + i.val = t.val * 32 + j.val) : s = t ∧ i = j := by
  have := i.isLt
  have := j.isLt
  constructor <;> apply Fin.ext <;> omega

theorem preload_no_second (hsteps : steps ≤ 15) (thread : Fin 512) : ¬thread.val + 512 < steps * 32 := by omega

theorem scratch_injective (a b : Fin (steps * 32)) (i j : Fin 16) (he : a.val * 16 + i.val = b.val * 16 + j.val) : a = b ∧ i = j := by
  have := i.isLt
  have := j.isLt
  constructor <;> apply Fin.ext <;> omega

def weightOffset (bits row steps step lane byte : Nat) : Nat :=
  row * (steps * 64 * bits) + (step * 32 + lane) * (2 * bits) + byte

theorem weight_pointer (bits row0 r steps step lane byte : Nat) :
    row0 * (steps * 64 * bits) + lane * (2 * bits) + r * (steps * 64 * bits) + step * (32 * (2 * bits)) + byte =
      weightOffset bits (row0+r) steps step lane byte := by
  unfold weightOffset
  ring

theorem weight_bound (bits : Nat) (hb : bits = 3 ∨ bits = 4) (row : Fin rows) (step : Fin steps) (lane : Fin 32)
    (byte : Nat) (hbyte : byte < 2*bits) :
    weightOffset bits row.val steps step.val lane.val byte < rows * (steps * 64 * bits) := by
  have ht : (step.val * 32 + lane.val) * (2*bits) + byte < steps * 64 * bits := by
    have := step.isLt
    have := lane.isLt
    rcases hb with rfl | rfl <;> omega
  unfold weightOffset
  calc
    _ = row.val * (steps * 64 * bits) + ((step.val * 32 + lane.val) * (2*bits) + byte) := by omega
    _ < row.val * (steps * 64 * bits) + steps * 64 * bits := Nat.add_lt_add_left ht _
    _ = (row.val + 1) * (steps * 64 * bits) := by ring
    _ ≤ _ := Nat.mul_le_mul_right _ row.isLt

theorem four_bit_word_aligned (row steps step lane : Nat) : weightOffset 4 row steps step lane 0 % 2 = 0 := by
  simp [weightOffset, Nat.add_mod, Nat.mul_mod]

theorem three_bit_byte (chunk : Fin 2) (byte : Fin 3) : chunk.val * 3 + byte.val < 6 := by
  have := chunk.isLt
  have := byte.isLt
  omega
theorem four_bit_byte (chunk : Fin 4) (byte : Fin 2) : chunk.val * 2 + byte.val < 8 := by
  have := chunk.isLt
  have := byte.isLt
  omega

theorem little_endian_word (lo hi : BitVec 8) : (hi ++ lo).toNat = lo.toNat + 256 * hi.toNat := by
  rw [BitVec.toNat_append, ← Nat.shiftLeft_add_eq_or_of_lt lo.isLt]
  simp only [Nat.shiftLeft_eq, show 2^8 = 256 from rfl]
  ring

end Inference.Kernels.Quantization.AffineLayout
