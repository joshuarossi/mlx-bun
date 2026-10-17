import contracts.mlx.ArithmeticFold
import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16
import Mathlib.Algebra.BigOperators.Fin

namespace Inference.Kernels.Attention.SdpaScore
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- sdpa_vector.h at D=256: each lane first scales eight query values,
-- accumulates eight products, then participates in the SIMD sum.
def scale : Float32 := Float32.ofBits 0x3d800000

theorem scale_value : real scale = (1 : ℝ)/16 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-27) (by decide)) = _
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8388608 * ((2 : ℝ)^27)⁻¹ = 1/16
  norm_num

theorem scale_finite : scale.isFinite = true := by decide +kernel

def index (lane : Fin 32) (offset : Fin 8) : Fin 256 :=
  ⟨lane.val*8+offset.val, by have := lane.isLt; have := offset.isLt; omega⟩
def indexEquiv : (Fin 32 × Fin 8) ≃ Fin 256 where
  toFun p := index p.1 p.2
  invFun i := (⟨i.val/8, by have := i.isLt; omega⟩, ⟨i.val%8, by omega⟩)
  left_inv p := by
    rcases p with ⟨lane, offset⟩
    apply Prod.ext <;> apply Fin.ext <;> dsimp [index] <;> have := offset.isLt <;> omega
  right_inv i := by apply Fin.ext; dsimp [index]; omega

theorem coverage (f : Fin 256 → ℝ) : (∑ lane : Fin 32, ∑ offset : Fin 8, f (index lane offset)) = ∑ i, f i := by
  simpa only [Fintype.sum_prod_type, indexEquiv, Equiv.coe_fn_mk] using Equiv.sum_comp indexEquiv f

def bind (q k : Fin 256 → BF) (i : Nat) : Float32 :=
  if hq : i < 256 then BFloat16.widen (q ⟨i, hq⟩)
  else if hk : i < 512 then BFloat16.widen (k ⟨i-256, by omega⟩) else scale
noncomputable def targetBind (q k : Fin 256 → ℝ) (i : Nat) : ℝ :=
  if hq : i < 256 then q ⟨i, hq⟩ else if hk : i < 512 then k ⟨i-256, by omega⟩ else 1/16
noncomputable def inputBudget (eq ek : Fin 256 → ℝ) (i : Nat) : ℝ :=
  if hq : i < 256 then eq ⟨i, hq⟩ else if hk : i < 512 then ek ⟨i-256, by omega⟩ else 0

def qExpr (i : Fin 256) : Arithmetic.Expr := .mul (.input 512) (.input i.val)
def kExpr (i : Fin 256) : Arithmetic.Expr := .input (256+i.val)
def laneExpr (contracted : Bool) (lane : Fin 32) : Arithmetic.Expr :=
  (List.finRange 8).foldl (fun acc offset => madd contracted (qExpr (index lane offset)) (kExpr (index lane offset)) acc) .zero

def expression (contracted : Bool) (tree : Reduction.Tree 32) : Arithmetic.Expr := reduceExpr (laneExpr contracted) tree

def source (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32) (q k : Fin 256 → BF) : Float32 :=
  reduce (fun lane => (List.finRange 8).foldl (fun acc offset =>
    maddFloat contracted (FlushToZero.mul scale (BFloat16.widen (q (index lane offset))))
      (BFloat16.widen (k (index lane offset))) acc) 0)

noncomputable def target (q k : Fin 256 → ℝ) : ℝ := (1/16) * ∑ i, q i * k i

noncomputable def budget (contracted : Bool) (tree : Reduction.Tree 32) (q k : Fin 256 → BF)
    (targetQ targetK errorQ errorK : Fin 256 → ℝ) : ℝ :=
  Arithmetic.budget (bind q k) (targetBind targetQ targetK) (inputBudget errorQ errorK) (expression contracted tree)

theorem bind_q (q k : Fin 256 → BF) (i : Fin 256) : bind q k i.val = BFloat16.widen (q i) := by simp [bind, i.isLt]
theorem bind_k (q k : Fin 256 → BF) (i : Fin 256) : bind q k (256+i.val) = BFloat16.widen (k i) := by
  have := i.isLt
  simp [bind, show ¬256+i.val < 256 by omega, show 256+i.val < 512 by omega]
theorem target_q (q k : Fin 256 → ℝ) (i : Fin 256) : targetBind q k i.val = q i := by simp [targetBind, i.isLt]
theorem target_k (q k : Fin 256 → ℝ) (i : Fin 256) : targetBind q k (256+i.val) = k i := by
  have := i.isLt
  simp [targetBind, show ¬256+i.val < 256 by omega, show 256+i.val < 512 by omega]

theorem bind_error (q k : Fin 256 → BF) (targetQ targetK errorQ errorK : Fin 256 → ℝ)
    (hq : ∀ i, |Model.toReal (q i) - targetQ i| ≤ errorQ i) (hk : ∀ i, |Model.toReal (k i) - targetK i| ≤ errorK i)
    (hqf : ∀ i, Model.isFinite (q i) = true) (hkf : ∀ i, Model.isFinite (k i) = true) (i : Nat) :
    |real (bind q k i) - targetBind targetQ targetK i| ≤ inputBudget errorQ errorK i := by
  unfold bind targetBind inputBudget
  split
  · rw [BFloat16.widen_real _ (hqf _)]; exact hq _
  · split
    · rw [BFloat16.widen_real _ (hkf _)]; exact hk _
    · rw [scale_value]; simp

theorem execution (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (q k : Fin 256 → BF) : Arithmetic.evaluate (bind q k) (expression contracted platform.tree) = source contracted reduce q k := by
  unfold expression source
  rw [evaluate_reduce, platform.execution]
  apply congrArg (fun f => FlushedReduction.evaluate f platform.tree)
  funext lane
  unfold laneExpr
  rw [evaluate_fold]
  simp only [qExpr, kExpr, Arithmetic.evaluate, bind_q, bind_k]
  rfl

theorem ideal (contracted : Bool) (tree : Reduction.Tree 32) (hc : (Reduction.leaves tree).Perm (List.finRange 32))
    (q k : Fin 256 → ℝ) : Arithmetic.ideal (targetBind q k) (expression contracted tree) = target q k := by
  unfold expression
  rw [ideal_reduce, Reduction.ideal_complete _ tree hc, ← Fin.sum_univ_def]
  have hl : ∀ lane, Arithmetic.ideal (targetBind q k) (laneExpr contracted lane) =
      ∑ offset : Fin 8, ((1:ℝ)/16) * q (index lane offset) * k (index lane offset) := by
    intro lane
    unfold laneExpr
    rw [ideal_fold, Arithmetic.ideal, zero_add, ← Fin.sum_univ_def]
    apply Finset.sum_congr rfl
    intro offset _
    simp only [qExpr, kExpr, Arithmetic.ideal, target_q, target_k]
    rfl
  simp_rw [hl]
  rw [coverage (fun i => ((1 : ℝ)/16) * q i * k i)]
  unfold target
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem source_error (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (q k : Fin 256 → BF) (targetQ targetK errorQ errorK : Fin 256 → ℝ)
    (hq : ∀ i, |Model.toReal (q i) - targetQ i| ≤ errorQ i) (hk : ∀ i, |Model.toReal (k i) - targetK i| ≤ errorK i)
    (hqf : ∀ i, Model.isFinite (q i) = true) (hkf : ∀ i, Model.isFinite (k i) = true)
    (hf : Arithmetic.Finite (bind q k) (expression contracted platform.tree)) :
    |real (source contracted reduce q k) - target targetQ targetK| ≤ budget contracted platform.tree q k targetQ targetK errorQ errorK := by
  have h := Arithmetic.error (bind q k) (targetBind targetQ targetK) (inputBudget errorQ errorK)
    (bind_error q k targetQ targetK errorQ errorK hq hk hqf hkf) (expression contracted platform.tree) hf
  rwa [execution contracted reduce platform, ideal contracted platform.tree platform.coverage] at h

theorem source_finite (contracted : Bool) (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (q k : Fin 256 → BF) (hf : Arithmetic.Finite (bind q k) (expression contracted platform.tree)) :
    (source contracted reduce q k).isFinite = true := by
  have h := Arithmetic.finite_evaluate (bind q k) (expression contracted platform.tree) hf
  rwa [execution contracted reduce platform] at h

-- One batch row, 24 query heads and 4 KV heads: six adjacent query heads
-- consume the same K/V head. The source's tid.x / gqa_factor is in bounds.
def kvHead (head : Fin 24) : Fin 4 := ⟨head.val/6, by have := head.isLt; omega⟩
theorem kv_head_bound (head : Fin 24) : head.val/6 < 4 := (kvHead head).isLt

def keyIndex (head : Fin 4) (time : Fin steps) (coordinate : Fin 256) : Nat :=
  head.val * steps * 256 + time.val * 256 + coordinate.val

theorem key_index_bound (head : Fin 4) (time : Fin steps) (coordinate : Fin 256) : keyIndex head time coordinate < 4*steps*256 := by
  have hhead := head.isLt
  have htime := time.isLt
  have hcoordinate := coordinate.isLt
  unfold keyIndex
  nlinarith

end Inference.Kernels.Attention.SdpaScore
