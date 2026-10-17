import contracts.mlx.M1Max
import kernels.trellis.Codebook

namespace Inference.Kernels.Trellis.CodebookLoad
open Contracts.Mlx.M1Max

def codeValue (s : BitVec 32) : Float32 :=
  Codebook.FloatingPoint.lifted (Codebook.implementation s) * Codebook.FloatingPoint.reciprocal

def mathematicalCode (s : BitVec 32) : Float32 :=
  Codebook.FloatingPoint.unrefined (Codebook.specification s)

theorem codeValue_correct (s : BitVec 32) : codeValue s = mathematicalCode s := by
  apply float_eq_of_bits_eq
  exact Codebook.FloatingPoint.unrefined_bits_state_correct s

theorem mathematicalCode_accuracy (s : BitVec 32) :
    Codebook.FloatingPoint.representable (mathematicalCode s) = true ∧
    Codebook.FloatingPoint.errorNumerator (mathematicalCode s) (Codebook.specification s) * 2^23 ≤
      (Codebook.specification s * 4096 * 2^32).natAbs := by
  simpa only [mathematicalCode, Codebook.correct] using Codebook.FloatingPoint.unrefined_state_accuracy s

def Initialized (memory : WordMemory) (base : Nat) : Prop :=
  ∀ i, i < 4096 → memory (base / 4 + i) = codeValue (BitVec.ofNat 32 i)

theorem initialization_owners (i threads : Nat) (hi : i < 4096)
    (ht : threads = 256 ∨ threads = 1024) :
    i % threads < threads ∧ i / threads < 4096 / threads ∧
    i % threads + threads * (i / threads) = i := by
  rcases ht with rfl | rfl <;> omega

theorem packedState_bound (w : Nat → BitVec 32) (k t : Nat) :
    (Codebook.PackedState.read w k t).toNat < 4096 := by
  have bound (x : BitVec 32) : (x &&& 4095#32).toNat ≤ 4095 := by
    simpa using (Nat.and_le_right (n := x.toNat) (m := 4095))
  unfold Codebook.PackedState.read Codebook.PackedState.implementation
  exact Nat.lt_of_le_of_lt (bound _) (by decide)

theorem eq_of_low_bits (x y : BitVec 32) (hx : x.toNat < 4096) (hy : y.toNat < 4096)
    (h : ∀ j, j < 12 → x.getLsbD j = y.getLsbD j) : x = y := by
  apply BitVec.eq_of_getLsbD_eq
  intro j _hj
  by_cases hj : j < 12
  · exact h j hj
  · have hxb := (BitVec.toNat_lt_iff_getLsbD_eq_false 12 (by decide)).mp hx (j-12)
    have hyb := (BitVec.toNat_lt_iff_getLsbD_eq_false 12 (by decide)).mp hy (j-12)
    have he : 12+(j-12)=j := by omega
    rw [he] at hxb hyb
    exact hxb.trans hyb.symm

def read (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat)
    (w : Nat → BitVec 32) (off : Nat) : Float32 :=
  load memory (base + (Codebook.CodebookWindow.byteOffset w off).toNat)

-- The table bounds and index are proved here. Only the instruction's handling
-- of low address bits is assumed; the desired numerical answer is not assumed.
theorem read_correct (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base % 4 = 0) (hn : base + 16384 ≤ 2^64)
    (initialized : Initialized memory base) (w : Nat → BitVec 32) (off : Nat) :
    read load memory base w off =
      mathematicalCode (Codebook.CodebookWindow.byteOffset w off >>> 2) := by
  unfold read
  rw [hardware.ignoresLowAddressBits memory base 4096 _ ha hn
    (Codebook.CodebookWindow.byteOffset_bound w off)]
  have hindex : (Codebook.CodebookWindow.byteOffset w off).toNat / 4 =
      (Codebook.CodebookWindow.byteOffset w off >>> 2).toNat := by
    simp [BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow]
  rw [hindex, initialized _ (Codebook.CodebookWindow.index_bound w off)]
  rw [BitVec.ofNat_toNat]
  exact codeValue_correct _

theorem read_accuracy (load : ThreadgroupLoad) (hardware : LoadContract load)
    (memory : WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : Initialized memory base) (w : Nat → BitVec 32) (off : Nat) :
    let s := Codebook.CodebookWindow.byteOffset w off >>> 2
    Codebook.FloatingPoint.representable (read load memory base w off) = true ∧
    Codebook.FloatingPoint.errorNumerator (read load memory base w off) (Codebook.specification s) * 2^23 ≤
      (Codebook.specification s * 4096 * 2^32).natAbs := by
  dsimp only
  rw [read_correct load hardware memory base ha hn initialized]
  exact mathematicalCode_accuracy _

end Inference.Kernels.Trellis.CodebookLoad
