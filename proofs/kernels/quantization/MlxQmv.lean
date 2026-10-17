import kernels.quantization.AffineRow

namespace Inference.Kernels.Quantization.MlxQmv
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- MLX v0.32.2 quantized.h qmv_fast_impl: 2 SIMD groups, 4 output rows
-- each, 16 values per lane at bits=3/4. Arithmetic per output row is the
-- same as affine-row.ts, except its masked fields use integer conversion.
-- No assertion about a compiler or a GPU is part of the equality below.
def integer (q : Nat) : Float32 := Float32.ofInt q

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem integer_fields_checked : ∀ field : Fin 16, ∀ shift : Fin 13,
    integer (field.val * 2^shift.val) = AffineLift.value (field.val * 2^shift.val) := by decide +kernel

theorem integer_mask (n width shift : Nat) (hw : width ≤ 4) (hs : shift < 13) :
    integer (n &&& ((2^width-1)*2^shift)) = AffineLift.value (n &&& ((2^width-1)*2^shift)) := by
  rw [AffinePacking.shifted_mask]
  have hf : n / 2^shift % 2^width < 16 := (Nat.mod_lt _ (by positivity)).trans_le (Nat.pow_le_pow_right (by decide) hw)
  exact integer_fields_checked ⟨n / 2^shift % 2^width, hf⟩ ⟨shift, hs⟩

theorem integer_mask3 (w : Fin 3 → BitVec 8) (i : Fin 10) : integer (AffineDot.mask3 w i) = AffineLift.value (AffineDot.mask3 w i) := by
  have hm : (2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i) < 256 := by fin_cases i <;> decide
  have hw : AffineDot.width3 i ≤ 4 := by fin_cases i <;> decide
  have hs : AffineDot.shift3 i < 13 := by fin_cases i <;> decide
  simpa only [AffineDot.mask3, AffinePacking.mask8, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm] using
    integer_mask (w (AffineDot.byte3 i)).toNat (AffineDot.width3 i) (AffineDot.shift3 i) hw hs

theorem integer_mask4 (w : BitVec 16) (i : Fin 4) : integer (AffineDot.mask4 w i) = AffineLift.value (AffineDot.mask4 w i) := by
  have hm : 15 * 2^(4*i.val) < 65536 := by fin_cases i <;> decide
  have hs : 4*i.val < 13 := by have := i.isLt; omega
  simpa only [AffineDot.mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm,
    show 2^4-1 = 15 from rfl] using integer_mask w.toNat 4 (4*i.val) (by decide) hs

def source3 (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) : Float32 :=
  (List.finRange 10).foldl (fun acc i => maddFloat contracted (integer (AffineDot.mask3 w i))
    (if AffineDot.crossed3 i then FlushToZero.mul (scaled (AffineDot.coordinate3 i)) 256 else scaled (AffineDot.coordinate3 i)) acc) acc
def source4 (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) : Float32 :=
  FlushToZero.add acc (maddFloat contracted (scaled 3) (integer (AffineDot.mask4 w 3))
    (maddFloat contracted (scaled 2) (integer (AffineDot.mask4 w 2))
      (maddFloat contracted (scaled 1) (integer (AffineDot.mask4 w 1)) (FlushToZero.mul (scaled 0) (integer (AffineDot.mask4 w 0))))))

theorem source3_eq (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) :
    source3 contracted w scaled acc = AffineDot.source3 contracted w scaled acc := by simp only [source3, integer_mask3, AffineDot.source3]
theorem source4_eq (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) :
    source4 contracted w scaled acc = AffineDot.source4 contracted w scaled acc := by simp only [source4, integer_mask4, AffineDot.source4]

def dot3 (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) : Float32 :=
  (List.finRange 2).foldl (fun acc chunk => source3 p.contracted (w chunk) (AffineTile.prepared3 p x chunk) acc) 0
def dot4 (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) : Float32 :=
  (List.finRange 4).foldl (fun acc chunk => source4 p.contracted (w chunk) (AffineTile.prepared4 p x chunk) acc) 0

theorem dot3_eq (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) : dot3 p x w = AffineTile.dot3 p x w := by
  simp only [dot3, source3_eq, AffineTile.dot3, AffineTile.step3]
theorem dot4_eq (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) : dot4 p x w = AffineTile.dot4 p x w := by
  simp only [dot4, source4_eq, AffineTile.dot4, AffineTile.step4]

def value3 (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) : Float32 :=
  AffineTile.combine p.tailContracted scale (dot3 p x w) (AffineInput.summed x AffineInput.groups3) bias
def value4 (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF) : Float32 :=
  AffineTile.combine p.tailContracted scale (dot4 p x w) (AffineInput.summed x AffineInput.groups4) bias

theorem value3_eq (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF) :
    value3 p x w scale bias = AffineTile.value3 p x w scale bias := by rw [value3, dot3_eq]; rfl
theorem value4_eq (p : AffineTile.Platform) (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF) :
    value4 p x w scale bias = AffineTile.value4 p x w scale bias := by rw [value4, dot4_eq]; rfl

def tiles3 (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights3 steps) (step : Fin steps) (lane : Fin 32) : Float32 :=
  value3 p.tile (AffineRow.slice x step lane) (w.bytes step lane) (w.scale (AffineRow.groupIndex step lane)) (w.bias (AffineRow.groupIndex step lane))
def tiles4 (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights4 steps) (step : Fin steps) (lane : Fin 32) : Float32 :=
  value4 p.tile (AffineRow.slice x step lane) (w.words step lane) (w.scale (AffineRow.groupIndex step lane)) (w.bias (AffineRow.groupIndex step lane))

theorem tiles3_eq (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights3 steps) : tiles3 p x w = AffineRow.tiles3 p x w := by
  funext step lane
  exact value3_eq _ _ _ _ _
theorem tiles4_eq (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights4 steps) : tiles4 p x w = AffineRow.tiles4 p x w := by
  funext step lane
  exact value4_eq _ _ _ _ _

theorem row3_error (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights3 steps) (target error : Fin (steps * 512) → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i)
    (ht : ∀ step lane, AffineTile.Finite3 p.tile (AffineRow.slice x step lane) (w.bytes step lane)
      (w.scale (AffineRow.groupIndex step lane)) (w.bias (AffineRow.groupIndex step lane)))
    (hf : Arithmetic.Finite (AffineRow.bind (AffineRow.tiles3 p x w)) (AffineRow.expression steps p.reduction.tree))
    (hb : Model.isFinite (AffineRow.output p (tiles3 p x w)) = true) :
    |Model.toReal (AffineRow.output p (tiles3 p x w)) - ∑ i, target i * AffineRow.weight3 w i| ≤
      AffineRow.budget p (AffineRow.tiles3 p x w) (AffineRow.targets3 target w) (AffineRow.tileBudgets3 p x w target error) := by
  rw [tiles3_eq] at hb ⊢
  exact AffineRow.row3_error p x w target error hi ht hf hb
theorem row4_error (p : AffineRow.Platform) (x : Fin (steps * 512) → BF) (w : AffineRow.Weights4 steps) (target error : Fin (steps * 512) → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i)
    (ht : ∀ step lane, AffineTile.Finite4 p.tile (AffineRow.slice x step lane) (w.words step lane)
      (w.scale (AffineRow.groupIndex step lane)) (w.bias (AffineRow.groupIndex step lane)))
    (hf : Arithmetic.Finite (AffineRow.bind (AffineRow.tiles4 p x w)) (AffineRow.expression steps p.reduction.tree))
    (hb : Model.isFinite (AffineRow.output p (tiles4 p x w)) = true) :
    |Model.toReal (AffineRow.output p (tiles4 p x w)) - ∑ i, target i * AffineRow.weight4 w i| ≤
      AffineRow.budget p (AffineRow.tiles4 p x w) (AffineRow.targets4 target w) (AffineRow.tileBudgets4 p x w target error) := by
  rw [tiles4_eq] at hb ⊢
  exact AffineRow.row4_error p x w target error hi ht hf hb

-- Specialize the reviewed host dispatch to one row, affine 3/4-bit, no
-- global scale, K >= 512. The architecture's qmv batch limit is at least 6.
def selectedFast (inputWidth outputWidth vectorLimit : Nat) : Bool :=
  1 < vectorLimit && inputWidth != 64 && inputWidth != 128 && outputWidth % 8 == 0 && inputWidth % 512 == 0

theorem selected (steps rows vectorLimit : Nat) (hl : 1 < vectorLimit) :
    selectedFast (steps * 512) (rows * 8) vectorLimit = true := by
  simp only [selectedFast, decide_eq_true_eq, Bool.and_eq_true, bne_iff_ne, beq_iff_eq]
  omega

def outputIndex (block : Fin blocks) (simd : Fin 2) (row : Fin 4) : Fin (blocks * 8) :=
  ⟨block.val * 8 + simd.val * 4 + row.val, by have := block.isLt; have := simd.isLt; have := row.isLt; omega⟩

theorem output_owner (i : Fin (blocks * 8)) : ∃ block : Fin blocks, ∃ simd : Fin 2, ∃ row : Fin 4, outputIndex block simd row = i := by
  refine ⟨⟨i.val / 8, by have := i.isLt; omega⟩, ⟨i.val / 4 % 2, by omega⟩, ⟨i.val % 4, by omega⟩, ?_⟩
  apply Fin.ext
  dsimp [outputIndex]
  omega

end Inference.Kernels.Quantization.MlxQmv
