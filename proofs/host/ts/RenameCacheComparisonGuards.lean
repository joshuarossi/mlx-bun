import host.ts.RenameLoopVariableNamespace
import host.ts.RenameBounded

set_option Elab.async false
namespace Host.Ts.F64

theorem test_eq_ofNat32 (m n : Nat) (hm : m < 2^31) (hn : n < 2^31) :
    test .eq (ofNat m) (ofNat n) = decide (m = n) := by
  change eq (ofNat m) (ofNat n) = _
  rw [ofNat_exact32 m hm,ofNat_exact32 n hn]
  cases m with
  | zero => cases n <;> simp [natExact,eq]
  | succ m =>
    cases n with
    | zero => simp [natExact,eq]
    | succ n =>
      simp [natExact,eq]
      apply Bool.eq_iff_iff.mpr
      simp only [Nat.beq_eq,decide_eq_true_eq]
      omega

theorem test_le_ofNat32 (m n : Nat) (hm : m < 2^31) (hn : n < 2^31) :
    test .le (ofNat m) (ofNat n) = decide (m ≤ n) := by
  change (lt (ofNat m) (ofNat n) || eq (ofNat m) (ofNat n)) = _
  have left := test_lt_ofNat32 m n hm hn
  have right := test_eq_ofNat32 m n hm hn
  change lt (ofNat m) (ofNat n) = _ at left
  change eq (ofNat m) (ofNat n) = _ at right
  rw [left,right]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.or_eq_true,decide_eq_true_eq]
  omega

end Host.Ts.F64

namespace Host.Ts.Owned.Annotated.CacheGuards

theorem less_than (ν : Nat → F64) (left right : SymE) (m n : Nat)
    (leftValue : left.eval ν = F64.ofNat m) (rightValue : right.eval ν = F64.ofNat n)
    (leftBound : m < 2^31) (rightBound : n < 2^31) :
    F64.test .lt (left.eval ν) (right.eval ν) = decide (m < n) := by
  rw [leftValue,rightValue,F64.test_lt_ofNat32 m n leftBound rightBound]

theorem less_equal (ν : Nat → F64) (left right : SymE) (m n : Nat)
    (leftValue : left.eval ν = F64.ofNat m) (rightValue : right.eval ν = F64.ofNat n)
    (leftBound : m < 2^31) (rightBound : n < 2^31) :
    F64.test .le (left.eval ν) (right.eval ν) = decide (m ≤ n) := by
  rw [leftValue,rightValue,F64.test_le_ofNat32 m n leftBound rightBound]

theorem equal (ν : Nat → F64) (left right : SymE) (m n : Nat)
    (leftValue : left.eval ν = F64.ofNat m) (rightValue : right.eval ν = F64.ofNat n)
    (leftBound : m < 2^31) (rightBound : n < 2^31) :
    F64.test .eq (left.eval ν) (right.eval ν) = decide (m = n) := by
  rw [leftValue,rightValue,F64.test_eq_ofNat32 m n leftBound rightBound]

/-- The original binary64 capacity test has exactly the natural full-cache
classification, including the positive-capacity growth boundary. -/
theorem growth (ν : Nat → F64) (index capacity : SymE) (i c : Nat)
    (indexValue : index.eval ν = F64.ofNat i) (capacityValue : capacity.eval ν = F64.ofNat c)
    (capacityBound : c < 2^31) (nextBound : i+1 < 2^31) (fits : i ≤ c) :
    F64.test .lt (capacity.eval ν) ((SymE.bin .add index (.lit (F64.ofNat 1))).eval ν) = decide (i = c) := by
  change F64.test .lt (capacity.eval ν) (F64.add (index.eval ν) (F64.ofNat 1)) = _
  rw [capacityValue,indexValue]
  exact F64.kv_growth_test i c capacityBound nextBound fits

theorem no_growth (ν : Nat → F64) (index capacity : SymE) (i c : Nat)
    (indexValue : index.eval ν = F64.ofNat i) (capacityValue : capacity.eval ν = F64.ofNat c)
    (capacityBound : c < 2^31) (fits : i+1 ≤ c) :
    F64.test .lt (capacity.eval ν) ((SymE.bin .add index (.lit (F64.ofNat 1))).eval ν) = false := by
  rw [growth ν index capacity i c indexValue capacityValue capacityBound (by omega) (by omega)]
  exact decide_eq_false (by omega)

theorem full_growth (ν : Nat → F64) (index capacity : SymE) (c : Nat)
    (indexValue : index.eval ν = F64.ofNat c) (capacityValue : capacity.eval ν = F64.ofNat c)
    (nextBound : c+1 < 2^31) :
    F64.test .lt (capacity.eval ν) ((SymE.bin .add index (.lit (F64.ofNat 1))).eval ν) = true := by
  rw [growth ν index capacity c c indexValue capacityValue (by omega) nextBound (Nat.le_refl _)]
  simp

theorem view_alias (ν : Nat → F64) (index capacity : SymE) (i c : Nat)
    (indexValue : index.eval ν = F64.ofNat i) (capacityValue : capacity.eval ν = F64.ofNat c)
    (capacityBound : c < 2^31) (fits : i+1 ≤ c) :
    F64.test .eq ((SymE.bin .add index (.lit (F64.ofNat 1))).eval ν) (capacity.eval ν) = decide (i+1 = c) := by
  change F64.test .eq (F64.add (index.eval ν) (F64.ofNat 1)) (capacity.eval ν) = _
  rw [indexValue,capacityValue,F64.add_ofNat32 i 1 (by omega)]
  exact F64.test_eq_ofNat32 (i+1) c (by omega) capacityBound

end Host.Ts.Owned.Annotated.CacheGuards
