import host.mlx.NativeInputs
import host.ts.RenameIntegerPacking

set_option Elab.async false

namespace Host.Ts.F64

theorem mul_natExact53 (m n : Nat) (h : m*n < 2^53) :
    mul (natExact m) (natExact n) = natExact (m*n) := by
  cases m with
  | zero => cases n <;> simp [natExact, mul]
  | succ m => cases n with
    | zero => simp [natExact, mul]
    | succ n =>
      have hs : Nat.blt ((m+1)*(n+1)) small = true := by rw [Nat.blt_eq]; exact h
      change (bif Nat.blt ((m+1)*(n+1)) small then fin false ((m+1)*(n+1)) 0
        else round b64 false ((m+1)*(n+1)) 1 0) = natExact ((m+1)*(n+1))
      rw [hs]
      simp only [natExact, Nat.mul_eq_zero, Nat.succ_ne_zero, or_self, ↓reduceIte]
      rfl

theorem mul_ofNat53 (m n : Nat) (hm : m < 2^53) (hn : n < 2^53) (hp : m*n < 2^53) :
    mul (ofNat m) (ofNat n) = ofNat (m*n) := by
  rw [ofNat_exact53 m hm, ofNat_exact53 n hn, ofNat_exact53 (m*n) hp]
  exact mul_natExact53 m n hp

theorem sub_natExact_nonnegative (m n : Nat) (h : n ≤ m) :
    sub (natExact m) (natExact n) = natExact (m-n) := by
  cases m with
  | zero => have hn : n = 0 := by omega
            subst n; rfl
  | succ m => cases n with
    | zero => simp [natExact, sub, neg, add]
    | succ n =>
      by_cases he : m = n
      · subst m
        change (bif Nat.blt (n+1) (n+1) then fin false ((n+1)-(n+1)) 0
          else bif Nat.blt (n+1) (n+1) then fin true ((n+1)-(n+1)) 0 else zero false) = natExact ((n+1)-(n+1))
        have hz : Nat.blt (n+1) (n+1) = false := by
          cases he : Nat.blt (n+1) (n+1)
          · rfl
          · have := Nat.blt_eq.mp he; omega
        rw [hz, Nat.sub_self]
        rfl
      · have hlt : Nat.blt (n+1) (m+1) = true := by rw [Nat.blt_eq]; omega
        have hz : m+1-(n+1) ≠ 0 := by omega
        change (bif Nat.blt (n+1) (m+1) then fin false ((m+1)-(n+1)) 0
          else bif Nat.blt (m+1) (n+1) then fin true ((n+1)-(m+1)) 0 else zero false) = natExact ((m+1)-(n+1))
        rw [hlt]
        exact (ite_eq_right hz).symm

theorem sub_ofNat53 (m n : Nat) (hm : m < 2^53) (hn : n ≤ m) :
    sub (ofNat m) (ofNat n) = ofNat (m-n) := by
  have hb : n < 2^53 := by omega
  have hd : m-n < 2^53 := by omega
  rw [ofNat_exact53 m hm, ofNat_exact53 n hb, ofNat_exact53 (m-n) hd]
  exact sub_natExact_nonnegative m n hn

theorem test_lt_ofNat53 (m n : Nat) (hm : m < 2^53) (hn : n < 2^53) :
    test .lt (ofNat m) (ofNat n) = decide (m < n) := by
  change lt (ofNat m) (ofNat n) = _
  rw [ofNat_exact53 m hm, ofNat_exact53 n hn, lt_natExact]

theorem eq_natExact (m n : Nat) : eq (natExact m) (natExact n) = decide (m = n) := by
  cases m with
  | zero => cases n <;> simp [natExact, eq]
  | succ m => cases n with
    | zero => simp [natExact, eq]
    | succ n =>
      simp only [natExact, Nat.succ_ne_zero, ↓reduceIte]
      change (true && Nat.beq (m+1) (n+1) && true) = decide (m+1 = n+1)
      simp only [Bool.and_true, Bool.true_and]
      apply Bool.eq_iff_iff.mpr
      simp only [Nat.beq_eq, decide_eq_true_eq]

theorem test_eq_ofNat53 (m n : Nat) (hm : m < 2^53) (hn : n < 2^53) :
    test .eq (ofNat m) (ofNat n) = decide (m = n) := by
  change eq (ofNat m) (ofNat n) = _
  rw [ofNat_exact53 m hm, ofNat_exact53 n hn, eq_natExact]

end Host.Ts.F64

namespace Host.Mlx.Ffi.DimRoles
open Host.Ts

/-- The three actual arithmetic primitives used by native shape inference. -/
inductive Arithmetic where
  | add | sub | mul

def Arithmetic.numOp : Arithmetic → NBin
  | .add => .add | .sub => .sub | .mul => .mul

def Arithmetic.integer : Arithmetic → Int → Int → Int
  | .add => (· + ·) | .sub => (· - ·) | .mul => (· * ·)

def Arithmetic.apply : Arithmetic → Dim → Dim → M Dim
  | .add => dAdd | .sub => dSub | .mul => dMul

theorem arithmetic_literal (op : Arithmetic) (a b : Int) :
    op.apply (.lit a) (.lit b) = M.pure (.lit (op.integer a b)) := by
  cases op <;> rfl

/-- Integer dimension arithmetic and binary64 arithmetic are distinguished.
The explicit exactness premises bridge them at the operand values in each
execution; numeric references and table lengths need not agree. -/
theorem arithmetic_literal_roles (op : Arithmetic)
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {ea eb : SymE} {a₀ a b₀ b : Int}
    (ha : NumRole ν₀ ν C₀ C ea (Dim.lit a₀).num (Dim.lit a).num)
    (hb : NumRole ν₀ ν C₀ C eb (Dim.lit b₀).num (Dim.lit b).num)
    (exact₀ : F64.bin op.numOp (F64.ofInt a₀) (F64.ofInt b₀) = F64.ofInt (op.integer a₀ b₀))
    (exact : F64.bin op.numOp (F64.ofInt a) (F64.ofInt b) = F64.ofInt (op.integer a b)) :
    interpC (op.apply (.lit a₀) (.lit b₀)).run C₀ = some (.lit (op.integer a₀ b₀), C₀) ∧
      interpC (op.apply (.lit a) (.lit b)).run C = some (.lit (op.integer a b), C) ∧
      NumRole ν₀ ν C₀ C (.bin op.numOp ea eb)
        (Dim.lit (op.integer a₀ b₀)).num (Dim.lit (op.integer a b)).num := by
  have ha₀ : ea.eval ν₀ = F64.ofInt a₀ := Option.some.inj ha.left.symm
  have ha' : ea.eval ν = F64.ofInt a := Option.some.inj ha.right.symm
  have hb₀ : eb.eval ν₀ = F64.ofInt b₀ := Option.some.inj hb.left.symm
  have hb' : eb.eval ν = F64.ofInt b := Option.some.inj hb.right.symm
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [arithmetic_literal]; rfl
  · rw [arithmetic_literal]; rfl
  · change some (F64.ofInt (op.integer a₀ b₀)) = some (F64.bin op.numOp (ea.eval ν₀) (eb.eval ν₀))
    rw [ha₀, hb₀, exact₀]
  · change some (F64.ofInt (op.integer a b)) = some (F64.bin op.numOp (ea.eval ν) (eb.eval ν))
    rw [ha', hb', exact]

/-- Nonnegative dimensions whose sum is below 2^53 require no separate
floating-point exactness assumption. Literal capacities may differ. -/
theorem add_natural_roles {ν₀ ν : Nat → F64} {C₀ C : CSrv} {ea eb : SymE}
    {a₀ a b₀ b : Nat}
    (ha : NumRole ν₀ ν C₀ C ea (.lit (F64.ofNat a₀)) (.lit (F64.ofNat a)))
    (hb : NumRole ν₀ ν C₀ C eb (.lit (F64.ofNat b₀)) (.lit (F64.ofNat b)))
    (bound₀ : a₀ + b₀ < 2^53) (bound : a + b < 2^53) :
    interpC (dAdd (.lit (Int.ofNat a₀)) (.lit (Int.ofNat b₀))).run C₀ =
        some (.lit (Int.ofNat (a₀+b₀)), C₀) ∧
      interpC (dAdd (.lit (Int.ofNat a)) (.lit (Int.ofNat b))).run C =
        some (.lit (Int.ofNat (a+b)), C) ∧
      NumRole ν₀ ν C₀ C (.bin .add ea eb)
        (.lit (F64.ofNat (a₀+b₀))) (.lit (F64.ofNat (a+b))) := by
  exact arithmetic_literal_roles .add ha hb
    (F64.add_ofNat53 a₀ b₀ bound₀) (F64.add_ofNat53 a b bound)

theorem mul_natural_roles {ν₀ ν : Nat → F64} {C₀ C : CSrv} {ea eb : SymE}
    {a₀ a b₀ b : Nat}
    (ha : NumRole ν₀ ν C₀ C ea (.lit (F64.ofNat a₀)) (.lit (F64.ofNat a)))
    (hb : NumRole ν₀ ν C₀ C eb (.lit (F64.ofNat b₀)) (.lit (F64.ofNat b)))
    (aBound₀ : a₀ < 2^53) (aBound : a < 2^53) (bBound₀ : b₀ < 2^53) (bBound : b < 2^53)
    (bound₀ : a₀*b₀ < 2^53) (bound : a*b < 2^53) :
    interpC (dMul (.lit (Int.ofNat a₀)) (.lit (Int.ofNat b₀))).run C₀ =
        some (.lit (Int.ofNat (a₀*b₀)), C₀) ∧
      interpC (dMul (.lit (Int.ofNat a)) (.lit (Int.ofNat b))).run C =
        some (.lit (Int.ofNat (a*b)), C) ∧
      NumRole ν₀ ν C₀ C (.bin .mul ea eb)
        (.lit (F64.ofNat (a₀*b₀))) (.lit (F64.ofNat (a*b))) := by
  exact arithmetic_literal_roles .mul ha hb
    (F64.mul_ofNat53 a₀ b₀ aBound₀ bBound₀ bound₀) (F64.mul_ofNat53 a b aBound bBound bound)

theorem sub_natural_roles {ν₀ ν : Nat → F64} {C₀ C : CSrv} {ea eb : SymE}
    {a₀ a b₀ b : Nat}
    (ha : NumRole ν₀ ν C₀ C ea (.lit (F64.ofNat a₀)) (.lit (F64.ofNat a)))
    (hb : NumRole ν₀ ν C₀ C eb (.lit (F64.ofNat b₀)) (.lit (F64.ofNat b)))
    (aBound₀ : a₀ < 2^53) (aBound : a < 2^53) (order₀ : b₀ ≤ a₀) (order : b ≤ a) :
    interpC (dSub (.lit (Int.ofNat a₀)) (.lit (Int.ofNat b₀))).run C₀ =
        some (.lit (Int.ofNat (a₀-b₀)), C₀) ∧
      interpC (dSub (.lit (Int.ofNat a)) (.lit (Int.ofNat b))).run C =
        some (.lit (Int.ofNat (a-b)), C) ∧
      NumRole ν₀ ν C₀ C (.bin .sub ea eb)
        (.lit (F64.ofNat (a₀-b₀))) (.lit (F64.ofNat (a-b))) := by
  have hs₀ : Int.ofNat a₀ - Int.ofNat b₀ = Int.ofNat (a₀-b₀) := (Int.ofNat_sub order₀).symm
  have hs : Int.ofNat a - Int.ofNat b = Int.ofNat (a-b) := (Int.ofNat_sub order).symm
  have exact₀ : F64.bin Arithmetic.sub.numOp (F64.ofInt (Int.ofNat a₀))
      (F64.ofInt (Int.ofNat b₀)) = F64.ofInt (Arithmetic.sub.integer (Int.ofNat a₀) (Int.ofNat b₀)) := by
    change F64.sub (F64.ofNat a₀) (F64.ofNat b₀) = F64.ofInt (Int.ofNat a₀ - Int.ofNat b₀)
    rw [hs₀]; exact F64.sub_ofNat53 a₀ b₀ aBound₀ order₀
  have exact : F64.bin Arithmetic.sub.numOp (F64.ofInt (Int.ofNat a))
      (F64.ofInt (Int.ofNat b)) = F64.ofInt (Arithmetic.sub.integer (Int.ofNat a) (Int.ofNat b)) := by
    change F64.sub (F64.ofNat a) (F64.ofNat b) = F64.ofInt (Int.ofNat a - Int.ofNat b)
    rw [hs]; exact F64.sub_ofNat53 a b aBound order
  simpa only [Arithmetic.apply, Arithmetic.integer, Arithmetic.numOp, hs₀, hs, Dim.num, F64.ofInt, F64.ofNat]
    using arithmetic_literal_roles .sub ha hb exact₀ exact

/-- A native literal comparison follows the same branch only after its two
integer guards have been established. Numeric-role agreement alone does not
identify branch answers across different valuations. -/
theorem lt_literal_same (C₀ C : CSrv) (a₀ a b₀ b : Int) (r : Bool)
    (guard₀ : decide (a₀ < b₀) = r) (guard : decide (a < b) = r) :
    interpC (dLt (.lit a₀) (.lit b₀)).run C₀ = some (r, C₀) ∧
      interpC (dLt (.lit a) (.lit b)).run C = some (r, C) := by
  change some (decide (a₀ < b₀), C₀) = some (r, C₀) ∧
    some (decide (a < b), C) = some (r, C)
  rw [guard₀, guard]
  exact ⟨rfl, rfl⟩

theorem eq_literal_same (C₀ C : CSrv) (a₀ a b₀ b : Int) (r : Bool)
    (guard₀ : decide (a₀ = b₀) = r) (guard : decide (a = b) = r) :
    interpC (dEq (.lit a₀) (.lit b₀)).run C₀ = some (r, C₀) ∧
      interpC (dEq (.lit a) (.lit b)).run C = some (r, C) := by
  change some (decide (a₀ = b₀), C₀) = some (r, C₀) ∧
    some (decide (a = b), C) = some (r, C)
  rw [guard₀, guard]
  exact ⟨rfl, rfl⟩

theorem dimOf_natural53 (n : Nat) (bound : n < 2^53) :
    dimOf (.lit (F64.ofNat n)) = .lit (Int.ofNat n) := by
  simp only [dimOf, F64.toInt_ofNat53 n bound]
  rfl

end Host.Mlx.Ffi.DimRoles
