import metal.Elab
import metal.Frontend
import metal.Assemble
import host.mlx.PrefillKernelSources
import Lean
import metal.kernels.AneTrellisFill

namespace Metal.Kernels.AneWriteHalf
open Metal Metal.Core

/-! # ane/fill.ts: `mlx_bun_ane_write_half`

```
const uint i = thread_position_in_grid.x;
if (i < (uint)N) ((device half*)dst)[OFFSET + i] = half(float(src[i]));
if (i == 0u) done[0] = 1;
```
Launch (fill.ts:86-101): inputs `src` (its N elements, bfloat16) and `dst` (float16, a zero-copy wrap
of an ANE program's surface), output `done` int32 `[1]`; `T` = bfloat16, ints N = src's size and
OFFSET = 0; grid `[⌈N/256⌉·256, 1, 1]`, threadgroup `[256, 1, 1]`. The route calls it for the hidden
rows (ane-prefill-split.ts:117, N = 5120·r), the projection inputs (:260, 5120·r and 6144·r) and the
dequantized weight heads (:259) at every ANE prompt row count r ∈ 224 … 2048: one pipeline per N.

`compile_eq` proves the compile for every N from 8 below 2^31 at once, by lemmas about the frontend:
the lexer reads the decimal digits `D` of N inside the mangled kernel name (three identifiers and
MLX's `host_name` string, `lexName`, `lexHostName`) and as the instantiation's argument
(`lexDigits`), while every other segment of the text lexes to the same tokens for every N (`lexQ0` …
`lexQ6`); preprocessing passes the tokens through (`preprocess_plain`); parsing and elaboration carry
the name and N, deciding only on the name's fixed prefix, on its equality with itself
(`nameEq_self`, `same_self`) and on N < 2^31 (`intLiteral_N`). -/

open Lean Elab Command Meta in
/-- `kernel_rfl_all n : ∀ xs, a = b` proves `fun xs => Eq.refl a`, checked by the kernel alone (the
elaborator does not reduce `a`). -/
elab "kernel_rfl_all " n:ident " : " t:term : command => do
  let ns ← getCurrNamespace
  liftTermElabM do
    let ty ← Term.elabType t
    Term.synthesizeSyntheticMVarsNoPostponing
    let ty ← instantiateMVars ty
    let value ← forallTelescope ty fun xs body => do
      let some (α, a, _) := body.eq? | throwError "expected an equation under binders"
      let u ← getLevel α
      mkLambdaFVars xs (mkApp2 (mkConst ``Eq.refl [u]) α a)
    addDecl (.thmDecl { name := ns ++ n.getId, levelParams := [], type := ty, value })

def u32l (n : Nat) : CExpr := .lit (.int .u32 n)
def i32l (n : Nat) : CExpr := .lit (.int .i32 n)

/-- Slots: 0 src, 1 dst, 2 done, 3 i; `w` is `(uint)N`. -/
def body (w : Nat) : List CStmt :=
  [.set 0 (.lit (.ptr ⟨0, 0, .scalar .bf16⟩)),
   .set 1 (.lit (.ptr ⟨1, 0, .scalar .f16⟩)),
   .set 2 (.lit (.ptr ⟨2, 0, .scalar .i32⟩)),
   .set 3 (.component (.coord .threadPositionInGrid) (u32l 0)),
   .ite (.bin .lt .u32 0 (.local 3) (u32l w))
     [.store (.scalar .f16) (.offset (.local 1) (.bin .add .u32 0 (u32l 0) (.local 3)))
       (.conv .f16 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) (.local 3)))))]
     [],
   .ite (.bin .eq .u32 0 (.local 3) (u32l 0)) [.store (.scalar .i32) (.offset (.local 2) (i32l 0)) (i32l 1)] []]

def core (N : Nat) : Kernel := ⟨3, [], [], body N⟩

section Texts
open Host.Mlx
/-! ## The texts MLX compiles -/

def inputs (N : Nat) : List Assemble.Input := [⟨chars!"src", .bfloat16, [N]⟩, ⟨chars!"dst", .float16, [N]⟩]

def args (N : Nat) : List Assemble.TemplateArg :=
  [.dtype chars!"T" .bfloat16, .int chars!"N" N, .int chars!"OFFSET" 0]

def assembled (N : Nat) : Option (List Char) :=
  Assemble.assemble (PrefillSources.name .aneWriteHalf) (inputs N) [chars!"done"] [.int32]
    (PrefillSources.source .aneWriteHalf) (PrefillSources.header .aneWriteHalf) (args N) false

def text (N : Nat) : List Char := (assembled N).getD []

/-! ## Digit lists -/

def Digits (D : List Char) : Prop := ∀ c ∈ D, isDigit c.toNat = true

def digitsVal (D : List Char) : Nat := D.foldl (fun v c => v * 10 + (c.toNat - 48)) 0

theorem isDigit_iff (n : Nat) : isDigit n = true ↔ 48 ≤ n ∧ n ≤ 57 := by
  simp [isDigit, Nat.ble_eq]

/-- What the lexer's character classes say of a digit. -/
theorem digit_classes {n : Nat} (h : isDigit n = true) :
    isIdPart n = true ∧ isNumPart n = true ∧ isExpChar n = false ∧ isIdStart n = false ∧ isBlank n = false ∧
      Nat.beq n 10 = false ∧ Nat.beq n 35 = false ∧ Nat.beq n 47 = false ∧ Nat.beq n 34 = false ∧
      Nat.beq n 92 = false ∧ isU n = false ∧ isL n = false := by
  rw [isDigit_iff] at h
  have : ∀ m < 58, 48 ≤ m → (isIdPart m = true ∧ isNumPart m = true ∧ isExpChar m = false ∧ isIdStart m = false ∧
      isBlank m = false ∧ Nat.beq m 10 = false ∧ Nat.beq m 35 = false ∧ Nat.beq m 47 = false ∧
      Nat.beq m 34 = false ∧ Nat.beq m 92 = false ∧ isU m = false ∧ isL m = false) := by decide
  exact this n (by omega) h.1

theorem digit_ofNat (d : Nat) (h : d < 10) : (Char.ofNat (48 + d)).toNat = 48 + d := by
  revert d; decide

/-- `decimal n`'s digits: their value is `n`, the first is nonzero unless `n = 0`. -/
theorem decimalAux_spec : ∀ (fuel n : Nat) (acc : List Char), n < fuel →
    ∃ ds, Assemble.decimalAux fuel n acc = ds ++ acc ∧ Digits ds ∧ ds ≠ [] ∧ digitsVal ds = n ∧
      (0 < n → ∀ c, ds.head? = some c → c.toNat ≠ 48)
  | 0, _, _, h => absurd h (Nat.not_lt_zero _)
  | fuel + 1, n, acc, h => by
    by_cases hn : n < 10
    · refine ⟨[Char.ofNat (48 + n)], by simp [Assemble.decimalAux, hn], ?_, by simp, ?_, ?_⟩
      · intro c hc; simp at hc; subst hc; rw [digit_ofNat n hn, isDigit_iff]; omega
      · simp [digitsVal, digit_ofNat n hn]
      · intro hp c hc; simp at hc; subst hc; rw [digit_ofNat n hn]; omega
    · obtain ⟨ds, h1, h2, h3, h4, h5⟩ :=
        decimalAux_spec fuel (n / 10) (Char.ofNat (48 + n % 10) :: acc) (by omega)
      have hd := digit_ofNat (n % 10) (Nat.mod_lt _ (by omega))
      refine ⟨ds ++ [Char.ofNat (48 + n % 10)], ?_, ?_, by simp, ?_, ?_⟩
      · simp only [Assemble.decimalAux, hn, ite_false, h1]; simp
      · intro c hc; rcases List.mem_append.mp hc with hc | hc
        · exact h2 c hc
        · simp at hc; subst hc; rw [hd, isDigit_iff]; omega
      · simp only [digitsVal, List.foldl_append, List.foldl_cons, List.foldl_nil] at h4 ⊢
        rw [h4, hd]; omega
      · intro _ c hc
        cases ds with
        | nil => exact absurd rfl h3
        | cons d ds => simp at hc; subst hc; exact h5 (by omega) d rfl

theorem decimal_spec (n : Nat) :
    Digits (Assemble.decimal n) ∧ Assemble.decimal n ≠ [] ∧ digitsVal (Assemble.decimal n) = n ∧
      (0 < n → ∀ c, (Assemble.decimal n).head? = some c → c.toNat ≠ 48) := by
  obtain ⟨ds, h1, h2, h3, h4, h5⟩ := decimalAux_spec (n + 1) n [] (by omega)
  simp only [List.append_nil] at h1
  unfold Assemble.decimal; rw [h1]; exact ⟨h2, h3, h4, h5⟩

/-! ## Lexing a digit run

Inside an identifier (the mangled kernel name), inside a string literal (MLX's
`host_name`) and as a decimal literal (the instantiation's `N`). -/

theorem isIdStart_classes {n : Nat} (h : isIdStart n = true) :
    Nat.beq n 10 = false ∧ isBlank n = false ∧ Nat.beq n 35 = false ∧ isIdPart n = true := by
  have hn : n < 123 := by
    by_cases h97 : 97 ≤ n
    · have h1 : Nat.ble 97 n = true := Nat.ble_eq.mpr h97
      unfold isIdStart at h
      simp only [h1, Bool.cond_true, Nat.ble_eq] at h
      omega
    · omega
  have : ∀ m < 123, isIdStart m = true →
      (Nat.beq m 10 = false ∧ isBlank m = false ∧ Nat.beq m 35 = false ∧ isIdPart m = true) := by decide
  exact this n hn h

theorem wordTake_append (w r : List Char) (hw : ∀ c ∈ w, isIdPart c.toNat = true) :
    wordTake (w ++ r) = w ++ wordTake r := by
  induction w with
  | nil => rfl
  | cons c cs ih =>
    simp only [List.cons_append, wordTake, hw c (by simp), Bool.cond_true]
    rw [ih (fun x hx => hw x (by simp [hx]))]

theorem wordDrop_append (w r : List Char) (hw : ∀ c ∈ w, isIdPart c.toNat = true) :
    wordDrop (w ++ r) = wordDrop r := by
  induction w with
  | nil => rfl
  | cons c cs ih =>
    simp only [List.cons_append, wordDrop, hw c (by simp), Bool.cond_true]
    exact ih (fun x hx => hw x (by simp [hx]))

theorem wordTake_stop (c : Char) (r : List Char) (h : isIdPart c.toNat = false) : wordTake (c :: r) = [] := by
  simp [wordTake, h]

theorem wordDrop_stop (c : Char) (r : List Char) (h : isIdPart c.toNat = false) : wordDrop (c :: r) = c :: r := by
  simp [wordDrop, h]

/-- An identifier `w` followed by a character that ends it (and starts no string literal). -/
theorem mainAux_ident (f : Nat) (bol : Bool) (x : Char) (w r : List Char) (c : Char)
    (hx : isIdStart x.toNat = true) (hw : ∀ y ∈ w, isIdPart y.toNat = true)
    (hc : isIdPart c.toNat = false) (hq : Nat.beq c.toNat 34 = false) :
    mainAux (f + 1) bol (x :: w ++ c :: r) = .ident (x :: w) :: mainAux f false (c :: r) := by
  obtain ⟨h10, hb, h35, hp⟩ := isIdStart_classes hx
  have hxw : ∀ y ∈ x :: w, isIdPart y.toNat = true := by
    intro y hy; rcases List.mem_cons.mp hy with rfl | hy
    · exact hp
    · exact hw y hy
  have hd := wordDrop_append (x :: w) (c :: r) hxw
  have ht := wordTake_append (x :: w) (c :: r) hxw
  rw [wordDrop_stop c r hc] at hd
  rw [wordTake_stop c r hc, List.append_nil] at ht
  simp only [List.cons_append] at hd ht
  simp only [List.cons_append, mainAux, mainStep, h10, hb, h35, Bool.cond_false, lexCommon, hx, Bool.cond_true, lexWord, hd, hq, emit, ht]

theorem strBody_append (s r : List Char)
    (hs : ∀ y ∈ s, Nat.beq y.toNat 34 = false ∧ Nat.beq y.toNat 10 = false ∧ Nat.beq y.toNat 92 = false) :
    strBody (s ++ '"' :: r) = some (s, r) := by
  induction s with
  | nil => unfold strBody; rfl
  | cons y ys ih =>
    obtain ⟨h1, h2, h3⟩ := hs y (by simp)
    rw [List.cons_append]; unfold strBody
    simp only [h1, h2, h3, Bool.cond_false]
    rw [ih (fun z hz => hs z (by simp [hz]))]
    rfl

/-- A string literal `"s"` followed by a character that is no identifier start. -/
theorem mainAux_str (f : Nat) (bol : Bool) (s r : List Char) (c : Char)
    (hs : ∀ y ∈ s, Nat.beq y.toNat 34 = false ∧ Nat.beq y.toNat 10 = false ∧ Nat.beq y.toNat 92 = false)
    (hc : isIdStart c.toNat = false) :
    mainAux (f + 1) bol ('"' :: (s ++ '"' :: c :: r)) = .str s :: mainAux f false (c :: r) := by
  have hb := strBody_append s (c :: r) hs
  cases s with
  | nil => simp only [List.nil_append] at hb ⊢; simp [mainAux, mainStep, lexCommon, startsNumber, lexString, hb, hc, emit]; rfl
  | cons y ys => simp only [List.cons_append] at hb ⊢; simp [mainAux, mainStep, lexCommon, startsNumber, lexString, hb, hc, emit]; rfl

theorem numTake_append (D r : List Char) (c : Char) (hD : Digits D) (hc : isNumPart c.toNat = false) :
    numTake (D ++ c :: r) = D := by
  induction D with
  | nil =>
    cases r with
    | nil => simp [numTake, hc]
    | cons d r => simp [numTake, hc]
  | cons x xs ih =>
    obtain ⟨_, hn, he, _⟩ := digit_classes (hD x (by simp))
    have ih' := ih (fun y hy => hD y (by simp [hy]))
    cases xs with
    | nil => simp only [List.nil_append] at ih' ⊢; simp only [List.cons_append, List.nil_append, numTake, hn, he, Bool.false_and, Bool.cond_true, Bool.cond_false, ih']
    | cons y ys => simp only [List.cons_append] at ih' ⊢; simp only [numTake, hn, he, Bool.false_and, Bool.cond_true, Bool.cond_false, ih']

theorem numDrop_append (D r : List Char) (c : Char) (hD : Digits D) (hc : isNumPart c.toNat = false) :
    numDrop (D ++ c :: r) = c :: r := by
  induction D with
  | nil =>
    cases r with
    | nil => simp [numDrop, hc]
    | cons d r => simp [numDrop, hc]
  | cons x xs ih =>
    obtain ⟨_, hn, he, _⟩ := digit_classes (hD x (by simp))
    have ih' := ih (fun y hy => hD y (by simp [hy]))
    cases xs with
    | nil => simp only [List.nil_append] at ih' ⊢; simp only [List.cons_append, List.nil_append, numDrop, hn, he, Bool.false_and, Bool.cond_true, Bool.cond_false, ih']
    | cons y ys => simp only [List.cons_append] at ih' ⊢; simp only [numDrop, hn, he, Bool.false_and, Bool.cond_true, Bool.cond_false, ih']

theorem decNum_digits (D : List Char) (hD : Digits D) : ∀ v nd,
    decNum v nd false D = some (.int (D.foldl (fun v c => v * 10 + (c.toNat - 48)) v) false false false) := by
  induction D with
  | nil => intro v nd; simp [decNum]
  | cons x xs ih =>
    intro v nd
    have hx := hD x (by simp)
    simp only [decNum, hx, Bool.cond_true, List.foldl_cons]
    exact ih (fun y hy => hD y (by simp [hy])) _ _

theorem numTok_digits (D : List Char) (hD : Digits D) (x : Char) (hx : D.head? = some x) (h0 : x.toNat ≠ 48) :
    numTok D = some (.int (digitsVal D) false false false) := by
  have hb : Nat.beq x.toNat 48 = false := by
    cases h : Nat.beq x.toNat 48
    · rfl
    · exact absurd (Nat.eq_of_beq_eq_true h) h0
  cases D with
  | nil => cases hx
  | cons y ys =>
    simp at hx; subst hx
    cases ys with
    | nil => simp only [numTok, startsZero, hb, decNum_digits _ hD, digitsVal]
    | cons z zs => simp only [numTok, startsZero, hb, Bool.false_and, Bool.cond_false, decNum_digits _ hD, digitsVal]

/-- A decimal literal (no leading zero) followed by a character that ends it. -/
theorem mainAux_num (f : Nat) (bol : Bool) (D r : List Char) (c : Char) (hD : Digits D) (x : Char)
    (hx : D.head? = some x) (h0 : x.toNat ≠ 48) (hc : isNumPart c.toNat = false) :
    mainAux (f + 1) bol (D ++ c :: r) = .int (digitsVal D) false false false :: mainAux f false (c :: r) := by
  have ht := numTake_append D r c hD hc
  have hd := numDrop_append D r c hD hc
  have hk := numTok_digits D hD x hx h0
  cases D with
  | nil => cases hx
  | cons y ys =>
    simp at hx; subst hx
    obtain ⟨_, _, _, hs, hb, h10, h35, h47, _⟩ := digit_classes (hD y (by simp))
    have hy := hD y (by simp)
    simp only [List.cons_append] at ht hd ⊢
    cases hys : ys ++ c :: r with
    | nil => simp at hys
    | cons z zs =>
      rw [hys] at ht hd
      simp only [mainAux, mainStep, h10, hb, h35, Bool.cond_false, lexCommon, hs, startsNumber, hy, Bool.true_or,
        Bool.cond_true, lexNumber, ht, hk, emit, hd]

theorem mainAux_nil (f : Nat) (bol : Bool) : mainAux (f + 1) bol [] = [] := rfl

/-! ## The text

`text N` with `D = decimal N`: the mangled name `W0 ++ D ++ W1` three times and in MLX's `host_name`
string, `D` twice as the instantiation's argument, every other character fixed. -/

def W0 : List Char := chars!"custom_kernel_mlx_bun_ane_write_half__bfloat16_t_"
def W1 : List Char := chars!"_0_bfloat16_t_float16_t_int32_t"
def nameOf (D : List Char) : List Char := W0 ++ (D ++ W1)

def Q0 : List Char := chars!"template <typename T, int N, int OFFSET>\n[[kernel]] void "
def S1 : List Char :=
  chars!"(\n  const device bfloat16_t* src [[buffer(0)]],\n  const device float16_t* dst [[buffer(1)]],\n  device int32_t* done [[buffer(2)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]]) {\n"
def Q1 : List Char := S1 ++ (PrefillSources.source .aneWriteHalf ++ chars!"\n}\n\ntemplate [[host_name(")
def Q2 : List Char := chars!")]] [[kernel]] decltype("
def Q3 : List Char := chars!"<bfloat16_t, "
def Q4 : List Char := chars!", 0>) "
def Q6 : List Char := chars!", 0>;\n"

/-- The assembled text, `D` the decimal digits of `N`. -/
def textOf (D : List Char) : List Char :=
  Q0 ++ (nameOf D ++ (Q1 ++ ('"' :: (nameOf D ++ ('"' :: (Q2 ++ (nameOf D ++ (Q3 ++ (D ++ (Q4 ++
    (nameOf D ++ (Q3 ++ (D ++ Q6)))))))))))))

end Texts
/-! ## Lexing the text -/

theorem splice_id : ∀ cs : List Char, (∀ c ∈ cs, c.toNat ≠ 92) → splice cs = cs
  | [], _ => rfl
  | [_], _ => rfl
  | c :: d :: ds, h => by
    have hc : Nat.beq c.toNat 92 = false := by
      cases hb : Nat.beq c.toNat 92
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true hb) (h c (by simp))
    rw [splice, hc, Bool.false_and, Bool.cond_false, splice_id (d :: ds) (fun x hx => h x (by simp [hx]))]

kernel_rfl_all lexQ0 : ∀ (f : Nat) (rest : List Char),
  mainAux (f + 27) true (Q0 ++ rest) = mainAux 27 true Q0 ++ mainAux (f + 1) false rest
kernel_rfl_all lexQ1 : ∀ (f : Nat) (r : List Char),
  mainAux (f + 173) false (Q1 ++ '"' :: r) = mainAux 173 false Q1 ++ mainAux (f + 1) false ('"' :: r)
kernel_rfl_all lexQ2 : ∀ (f : Nat) (r : List Char),
  mainAux (f + 13) false (Q2 ++ 'c' :: r) = mainAux 13 false Q2 ++ mainAux (f + 1) false ('c' :: r)
kernel_rfl_all lexQ3 : ∀ (f : Nat) (rest : List Char),
  mainAux (f + 5) false (Q3 ++ rest) = mainAux 5 false Q3 ++ mainAux (f + 1) false rest
kernel_rfl_all lexQ4 : ∀ (f : Nat) (rest : List Char),
  mainAux (f + 7) false (Q4 ++ rest) = mainAux 7 false Q4 ++ mainAux (f + 1) false rest
kernel_rfl_all lexQ6 : ∀ (f : Nat) (rest : List Char),
  mainAux (f + 7) false (Q6 ++ rest) = mainAux 7 false Q6 ++ mainAux (f + 1) true rest

/-- A fixed segment lexed with any fuel above what it takes. -/
theorem seg {a : Nat} {b b' : Bool} {Q rest : List Char}
    (h : ∀ f, mainAux (f + a) b (Q ++ rest) = mainAux a b Q ++ mainAux (f + 1) b' rest)
    (g : Nat) (hg : a ≤ g) :
    mainAux g b (Q ++ rest) = mainAux a b Q ++ mainAux (g - a + 1) b' rest := by
  obtain ⟨f, rfl⟩ : ∃ f, g = f + a := ⟨g - a, by omega⟩
  rw [h, Nat.add_sub_cancel]

theorem name_idPart (D : List Char) (hD : Digits D) : ∀ y ∈ (nameOf D).tail, isIdPart y.toNat = true := by
  have h0 : ∀ y ∈ W0.tail, isIdPart y.toNat = true := by decide
  have h1 : ∀ y ∈ W1, isIdPart y.toNat = true := by decide
  intro y hy
  have e : (nameOf D).tail = W0.tail ++ (D ++ W1) := rfl
  rw [e] at hy
  rcases List.mem_append.mp hy with hy | hy
  · exact h0 y hy
  · rcases List.mem_append.mp hy with hy | hy
    · exact (digit_classes (hD y hy)).1
    · exact h1 y hy

/-- The mangled name, then a character that ends it. -/
theorem lexName (D : List Char) (hD : Digits D) (g : Nat) (bol : Bool) (c : Char) (r : List Char) (hg : 1 ≤ g)
    (hc : isIdPart c.toNat = false) (hq : Nat.beq c.toNat 34 = false) :
    mainAux g bol (nameOf D ++ c :: r) = .ident (nameOf D) :: mainAux (g - 1) false (c :: r) := by
  obtain ⟨f, rfl⟩ : ∃ f, g = f + 1 := ⟨g - 1, by omega⟩
  have hw := name_idPart D hD
  have e : nameOf D = 'c' :: (nameOf D).tail := rfl
  rw [e]
  rw [mainAux_ident f bol 'c' (nameOf D).tail r c (by decide) hw hc hq, Nat.add_sub_cancel]

theorem name_strPart (D : List Char) (hD : Digits D) :
    ∀ y ∈ nameOf D, Nat.beq y.toNat 34 = false ∧ Nat.beq y.toNat 10 = false ∧ Nat.beq y.toNat 92 = false := by
  have h0 : ∀ y ∈ W0, Nat.beq y.toNat 34 = false ∧ Nat.beq y.toNat 10 = false ∧ Nat.beq y.toNat 92 = false := by decide
  have h1 : ∀ y ∈ W1, Nat.beq y.toNat 34 = false ∧ Nat.beq y.toNat 10 = false ∧ Nat.beq y.toNat 92 = false := by decide
  intro y hy
  rcases List.mem_append.mp hy with hy | hy
  · exact h0 y hy
  · rcases List.mem_append.mp hy with hy | hy
    · obtain ⟨_, _, _, _, _, h10, _, _, h34, h92, _⟩ := digit_classes (hD y hy)
      exact ⟨h34, h10, h92⟩
    · exact h1 y hy

theorem lexHostName (D : List Char) (hD : Digits D) (g : Nat) (bol : Bool) (c : Char) (r : List Char) (hg : 1 ≤ g)
    (hc : isIdStart c.toNat = false) :
    mainAux g bol ('"' :: (nameOf D ++ '"' :: c :: r)) = .str (nameOf D) :: mainAux (g - 1) false (c :: r) := by
  obtain ⟨f, rfl⟩ : ∃ f, g = f + 1 := ⟨g - 1, by omega⟩
  rw [mainAux_str f bol _ r c (name_strPart D hD) hc, Nat.add_sub_cancel]

theorem lexDigits (D : List Char) (hD : Digits D) (x : Char) (hx : D.head? = some x) (h0 : x.toNat ≠ 48)
    (g : Nat) (bol : Bool) (c : Char) (r : List Char) (hg : 1 ≤ g) (hc : isNumPart c.toNat = false) :
    mainAux g bol (D ++ c :: r) = .int (digitsVal D) false false false :: mainAux (g - 1) false (c :: r) := by
  obtain ⟨f, rfl⟩ : ∃ f, g = f + 1 := ⟨g - 1, by omega⟩
  rw [mainAux_num f bol D r c hD x hx h0 hc, Nat.add_sub_cancel]

/-- The tokens after the `host_name` string. -/
def rest2 (D : List Char) : List Tok :=
  mainAux 13 false Q2 ++ (.ident (nameOf D) :: (mainAux 5 false Q3 ++ (.int (digitsVal D) false false false ::
    (mainAux 7 false Q4 ++ (.ident (nameOf D) :: (mainAux 5 false Q3 ++ (.int (digitsVal D) false false false ::
    mainAux 7 false Q6)))))))

/-- The tokens of `textOf D`. -/
def toks (D : List Char) : List Tok :=
  mainAux 27 true Q0 ++ (.ident (nameOf D) :: (mainAux 173 false Q1 ++ (.str (nameOf D) :: rest2 D)))

theorem name_cons (D rest : List Char) : nameOf D ++ rest = 'c' :: ((nameOf D).tail ++ rest) := rfl
theorem Q1_cons (rest : List Char) : Q1 ++ rest = '(' :: (Q1.tail ++ rest) := rfl
theorem Q2_cons (rest : List Char) : Q2 ++ rest = ')' :: (Q2.tail ++ rest) := rfl
theorem Q3_cons (rest : List Char) : Q3 ++ rest = '<' :: (Q3.tail ++ rest) := rfl
theorem Q4_cons (rest : List Char) : Q4 ++ rest = ',' :: (Q4.tail ++ rest) := rfl
theorem Q6_cons (rest : List Char) : Q6 ++ rest = ',' :: (Q6.tail ++ rest) := rfl

theorem textOf_length (D : List Char) : (textOf D).length = 6 * D.length + 807 := by
  have h0 : Q0.length = 57 := by decide +kernel
  have h1 : Q1.length = 366 := by decide +kernel
  have h2 : Q2.length = 24 := by decide +kernel
  have h3 : Q3.length = 13 := by decide +kernel
  have h4 : Q4.length = 6 := by decide +kernel
  have h6 : Q6.length = 6 := by decide +kernel
  have hw0 : W0.length = 49 := by decide +kernel
  have hw1 : W1.length = 31 := by decide +kernel
  simp only [textOf, nameOf, List.length_append, List.length_cons, h0, h1, h2, h3, h4, h6, hw0, hw1]
  omega

theorem lex_text (D : List Char) (hD : Digits D) (x : Char) (hx : D.head? = some x) (h0 : x.toNat ≠ 48) :
    lex (textOf D) = toks D := by
  have hs : ∀ c ∈ textOf D, c.toNat ≠ 92 := by
    have h : ∀ (L : List Char), (∀ c ∈ L, c.toNat ≠ 92) → ∀ c ∈ L, c.toNat ≠ 92 := fun _ h => h
    have hq0 : ∀ c ∈ Q0, c.toNat ≠ 92 := by decide +kernel
    have hq1 : ∀ c ∈ Q1, c.toNat ≠ 92 := by decide +kernel
    have hq2 : ∀ c ∈ Q2, c.toNat ≠ 92 := by decide +kernel
    have hq3 : ∀ c ∈ Q3, c.toNat ≠ 92 := by decide +kernel
    have hq4 : ∀ c ∈ Q4, c.toNat ≠ 92 := by decide +kernel
    have hq6 : ∀ c ∈ Q6, c.toNat ≠ 92 := by decide +kernel
    have hd : ∀ c ∈ D, c.toNat ≠ 92 := fun c hc => by have := (isDigit_iff _).mp (hD c hc); omega
    have hn : ∀ c ∈ nameOf D, c.toNat ≠ 92 := fun c hc => by
      have := (name_strPart D hD c hc).2.2; intro e; rw [e] at this; cases this
    intro c hc
    simp only [textOf, List.mem_append, List.mem_cons] at hc
    rcases hc with h | h | h | h | h | h | h | h | h | h | h | h | h | h | h
    · exact hq0 c h
    · exact hn c h
    · exact hq1 c h
    · subst h; decide
    · exact hn c h
    · subst h; decide
    · exact hq2 c h
    · exact hn c h
    · exact hq3 c h
    · exact hd c h
    · exact hq4 c h
    · exact hn c h
    · exact hq3 c h
    · exact hd c h
    · exact hq6 c h
  unfold lex
  rw [splice_id _ hs, textOf_length]
  generalize hF : 6 * D.length + 807 + 1 = F
  have hF' : 808 ≤ F := by omega
  unfold textOf
  have e6 : D ++ Q6 = D ++ (Q6 ++ []) := by rw [List.append_nil]
  rw [seg (lexQ0 · _) F (by omega), Q1_cons, lexName D hD _ false _ _ (by omega) (by decide) (by decide), ← Q1_cons,
    seg (lexQ1 · _) _ (by omega), Q2_cons, lexHostName D hD _ false _ _ (by omega) (by decide), ← Q2_cons, name_cons,
    seg (lexQ2 · _) _ (by omega), ← name_cons, Q3_cons, lexName D hD _ false _ _ (by omega) (by decide) (by decide), ← Q3_cons,
    seg (lexQ3 · _) _ (by omega), Q4_cons, lexDigits D hD x hx h0 _ false _ _ (by omega) (by decide), ← Q4_cons,
    seg (lexQ4 · _) _ (by omega), Q3_cons, lexName D hD _ false _ _ (by omega) (by decide) (by decide), ← Q3_cons,
    seg (lexQ3 · _) _ (by omega), e6, Q6_cons, lexDigits D hD x hx h0 _ false _ _ (by omega) (by decide), ← Q6_cons,
    seg (lexQ6 · _) _ (by omega)]
  rw [show F - 27 + 1 - 1 - 173 + 1 - 1 - 13 + 1 - 1 - 5 + 1 - 1 - 7 + 1 - 1 - 5 + 1 - 1 - 7 + 1 =
    (F - 27 + 1 - 1 - 173 + 1 - 1 - 13 + 1 - 1 - 5 + 1 - 1 - 7 + 1 - 1 - 5 + 1 - 1 - 7) + 1 by omega, mainAux_nil,
    List.append_nil]
  rfl

/-! ## Preprocessing: no directives, no macros -/

theorem expand_plain : ∀ (ts : List Tok) (fuel : Nat) (acc : List HTok), ts.length < fuel →
    (∀ t ∈ ts, isDirective t = false) →
    expand fuel [] (ts.map fun t => (t, [])) acc = some ((ts.map fun t => (t, [])).reverse ++ acc)
  | [], 0, _, hl, _ => absurd hl (Nat.not_lt_zero _)
  | [], _ + 1, _, _, _ => rfl
  | _ :: _, 0, _, hl, _ => absurd hl (Nat.not_lt_zero _)
  | t :: ts, fuel + 1, acc, hl, hd => by
    have ht := hd t (by simp)
    have ih := expand_plain ts fuel ((t, []) :: acc) (by simp at hl; omega) (fun x hx => hd x (by simp [hx]))
    rw [List.map_cons, show fuel + 1 = Nat.succ fuel from rfl, expand]
    cases t with
    | ident n => simp only [expandStep, expandIdent, mem, lookup, Bool.cond_false]; rw [ih]; simp
    | int _ _ _ _ => simp only [expandStep]; rw [ih]; simp
    | float _ _ _ => simp only [expandStep]; rw [ih]; simp
    | str _ => simp only [expandStep]; rw [ih]; simp
    | punct _ => simp only [expandStep]; rw [ih]; simp
    | pragma _ => simp [isDirective] at ht
    | defineObject _ _ => simp [isDirective] at ht
    | defineFunction _ _ _ => simp [isDirective] at ht
    | err _ => simp [isDirective] at ht

theorem unwind_eq : ∀ (acc : List HTok) (out : List Tok), unwind acc out = (acc.map Prod.fst).reverse ++ out
  | [], _ => rfl
  | (t, _) :: acc, out => by rw [unwind, unwind_eq acc]; simp

theorem preprocess_plain (ts : List Tok) (hl : ts.length < ppFuel) (hd : ∀ t ∈ ts, isDirective t = false) :
    preprocess ts = some ts := by
  unfold preprocess
  rw [expand_plain ts ppFuel [] hl hd]
  simp [unwind_eq, List.map_reverse, Function.comp_def]

kernel_rfl_all toks_length : ∀ D : List Char, (toks D).length = 159
kernel_rfl_all toks_plain : ∀ D : List Char, (toks D).all (fun t => !isDirective t) = true

/-! ## Parsing -/

def instTail : List Tok :=
  [.ident chars!"template", .punct ['['], .punct ['['], .ident chars!"host_name", .punct ['(']]

/-- The kernel function, its name `nm`: the parse of the reference text's (`D = 11`) with that name. -/
def F0 : Func :=
  match topP [] (toks ['1', '1']) with
  | some (.func f, _) => f
  | _ => default
def funcOf (nm : List Char) : Func := { F0 with name := nm }

kernel_rfl_all funcOf_tparams : ∀ nm : List Char,
  (funcOf nm).tparams = [.type chars!"T", .int chars!"N", .int chars!"OFFSET"]
theorem funcOf_name (nm : List Char) : (funcOf nm).name = nm := rfl

def targsOf (N : Nat) : List TArg :=
  [.type { name := chars!"bfloat16_t" }, .expr (.int N false false false), .expr (.int 0 false false false)]

kernel_rfl_all topP_toks : ∀ D : List Char,
  topP [] (toks D) = some (.func (funcOf (nameOf D)), instTail ++ (.str (nameOf D) :: rest2 D))

kernel_rfl_all targs_Q4 : ∀ (nm : List Char) (N : Nat) (rest : List Tok),
  targs { templates := [nm] } (ParseCtx.grammar { templates := [nm] })
    (mainAux 5 false Q3 ++ (.int N false false false :: (mainAux 7 false Q4 ++ rest))) =
    some (targsOf N, .punct [')'] :: rest)
kernel_rfl_all targs_Q6 : ∀ (nm : List Char) (N : Nat),
  targs { templates := [nm] } (ParseCtx.grammar { templates := [nm] })
    (mainAux 5 false Q3 ++ (.int N false false false :: mainAux 7 false Q6)) =
    some (targsOf N, [.punct [';']])

theorem nameEq_self : ∀ l : List Char, nameEq l l = true
  | [] => rfl
  | c :: cs => by simp [nameEq, nameEq_self cs]

theorem instName_nm (nm : List Char) (ts : Ts) :
    instName { templates := [nm] } (.ident nm :: ts) =
      bnd (targs { templates := [nm] } (ParseCtx.grammar { templates := [nm] }) ts) fun as ts => some ((nm, as), ts) := by
  simp only [instName, nameIn, nameEq_self, Bool.true_or, Bool.cond_true]

kernel_rfl_all Q2_toks : mainAux 13 false Q2 =
  [.punct [')'], .punct [']'], .punct [']'], .punct ['['], .punct ['['], .ident chars!"kernel", .punct [']'],
    .punct [']'], .ident chars!"decltype", .punct ['(']]

theorem targsOf_beqs (N : Nat) : TArg.beqs (targsOf N) (targsOf N) = true := by
  simp [targsOf, TArg.beqs, TArg.beq, Expr.beq]

theorem inst_step (D : List Char) :
    topP [nameOf D] (instTail ++ (.str (nameOf D) :: rest2 D)) =
      some (.instantiate (nameOf D) (nameOf D) (targsOf (digitsVal D)), []) := by
  show instantiateP [nameOf D] (instTail.tail ++ (.str (nameOf D) :: rest2 D)) = _
  simp only [rest2, Q2_toks, instTail, List.tail_cons, List.cons_append, List.nil_append, instantiateP]
  rw [instName_nm, targs_Q4]
  simp only [bnd]
  rw [instName_nm, targs_Q6]
  simp only [bnd, nameEq_self, targsOf_beqs, Bool.and_self, Bool.cond_true]

theorem parse_toks (D : List Char) :
    parseUnit (toks D) = some [.func (funcOf (nameOf D)), .instantiate (nameOf D) (nameOf D) (targsOf (digitsVal D))] := by
  show unitLoop (999999 + 1) [] [] (toks D) = _
  have e : toks D = .ident chars!"template" :: (toks D).tail := rfl
  rw [e, unitLoop, ← e, topP_toks]
  simp only [declares, funcOf_tparams, funcOf_name]
  have e2 : instTail ++ (.str (nameOf D) :: rest2 D) = .ident chars!"template" :: (instTail.tail ++ (.str (nameOf D) :: rest2 D)) := rfl
  rw [show (999999 : Nat) = 999998 + 1 from rfl, e2, unitLoop, ← e2, inst_step]
  rfl
  all_goals exact fun h => List.cons_ne_nil _ _ h

/-! ## Elaborating the unit -/

def envOf (N : Nat) : Elab.Env :=
  [(chars!"T", .type .bf16), (chars!"N", .const (.scalar .i32) ⟨.i32, N⟩),
    (chars!"OFFSET", .const (.scalar .i32) ⟨.i32, 0⟩)]

theorem intLiteral_N (N : Nat) (hN : N < 2 ^ 31) : intLiteral N false false false = some .i32 := by
  have h : (N < 2 ^ (if Scalar.i32.isSigned then Scalar.i32.width - 1 else Scalar.i32.width)) = True := by
    simp only [Scalar.isSigned, Scalar.width, Scalar.bytes, ite_true, eq_iff_iff, iff_true]; omega
  simp only [intLiteral, List.find?, h, decide_true]

theorem bindTemplate_N (N : Nat) (hN : N < 2 ^ 31) (ctx : Elab.Ctx) :
    (Elab.bindTemplate Elab.fuel ctx [] [.type chars!"T", .int chars!"N", .int chars!"OFFSET"] (targsOf N)).run {} =
      some (envOf N, {}) := by
  have h := intLiteral_N N hN
  simp only [Elab.fuel, targsOf, Elab.bindTemplate, Elab.expr, h]
  rfl

/-- The word of `(uint)N` as elaboration folds it. -/
def uword (N : Nat) : Nat := (Elab.K.int ⟨.i32, N⟩ % 2 ^ Scalar.width .u32).toNat % 2 ^ Scalar.width .u32

theorem uword_eq (N : Nat) (hN : N < 2 ^ 31) : uword N = N := by
  have h : Val.signed .i32 N = N := by
    simp only [Val.signed, Scalar.isSigned, Scalar.width, Scalar.bytes, true_and]
    rw [ite_eq_right (by omega)]
  simp only [uword, Elab.K.int, h, Scalar.width, Scalar.bytes]
  omega

kernel_rfl_all instanceOf_unit : ∀ (nm : List Char) (N : Nat),
  Elab.instanceOf [.func (funcOf nm), .instantiate nm nm (targsOf N)] = some (nm, targsOf N)
kernel_rfl_all funcOf_kernel : ∀ nm : List Char, (funcOf nm).kernel = true
kernel_rfl_all funcOf_void : ∀ nm : List Char,
  (!Builtins.same (funcOf nm).result.name chars!"void" || (funcOf nm).result.pointer) = false

theorem same_self : ∀ l : List Char, Builtins.same l l = true
  | [] => rfl
  | c :: cs => by simp [Builtins.same, same_self cs]

theorem split_unit (nm : List Char) (N : Nat) :
    Elab.split nm [.func (funcOf nm), .instantiate nm nm (targsOf N)] [] = some ([], funcOf nm) := by
  simp [Elab.split, funcOf_kernel, funcOf_name, same_self]

kernel_rfl_all body_N : ∀ (nm : List Char) (N : Nat),
  ((Elab.kernelBody true [] (funcOf nm) (envOf N)).run {}).bind
    (fun r => some ({ buffers := r.1.2, threadgroupArrays := r.2.group, threadArrays := r.2.thread, body := r.1.1 } : Kernel)) =
  some (core (uword N))

theorem run_bind_eq {α β : Type} (x : Elab.M α) (f : α → Elab.M β) (s s' : Elab.St) (a : α)
    (h : x.run s = some (a, s')) : (x >>= f).run s = (f a).run s' := by
  simp only [StateT.run_bind, h]; rfl

theorem elab_unit (nm : List Char) (N : Nat) (hN : N < 2 ^ 31) :
    elaborate [.func (funcOf nm), .instantiate nm nm (targsOf N)] = some (core N) := by
  unfold elaborate Elab.kernelOf
  simp only [instanceOf_unit, split_unit, funcOf_void, funcOf_tparams, Option.bind_eq_bind, Option.bind_some,
    Bool.false_eq_true, ite_false]
  rw [run_bind_eq _ _ _ _ _ (bindTemplate_N N hN _)]
  have h := body_N nm N
  rw [uword_eq N hN] at h
  exact h

section Assembled
open Host.Mlx
/-! ## The assembled text: `textOf` of `N`'s digits -/

theorem hashChars_cons (c : Char) (r : List Char) (hc : c ≠ ',') :
    Assemble.hashChars (c :: r) = (if c = '<' ∨ c = '>' then '_' else c) :: Assemble.hashChars r := by
  conv_lhs => unfold Assemble.hashChars
  split
  · rename_i heq; simp at heq
  · rename_i heq; simp at heq; exact absurd heq.1 hc
  · rename_i heq; simp at heq; obtain ⟨rfl, rfl⟩ := heq; rfl

theorem hashChars_digits (D r : List Char) (hD : Digits D) : Assemble.hashChars (D ++ r) = D ++ Assemble.hashChars r := by
  induction D with
  | nil => rfl
  | cons c cs ih =>
    have h := (isDigit_iff _).mp (hD c (by simp))
    have hc : c ≠ ',' := fun e => by subst e; simp at h
    have h1 : ¬ (c = '<' ∨ c = '>') := by
      rintro (e | e) <;> subst e <;> simp at h
    rw [List.cons_append, hashChars_cons c _ hc, ite_eq_right h1, ih (fun x hx => hD x (by simp [hx]))]
    rfl

kernel_rfl_all hashPre : ∀ X : List Char,
  Assemble.hashChars ('<' :: (chars!"bfloat16_t, " ++ X)) = '_' :: (chars!"bfloat16_t_" ++ Assemble.hashChars X)
kernel_rfl_all hashPost : Assemble.hashChars chars!", 0>" = chars!"_0_"

theorem templateDef_N (N : Nat) :
    Assemble.templateDef (args N) = some ('<' :: (chars!"bfloat16_t, " ++ (Assemble.decimal N ++ chars!", 0>"))) := by
  simp [Assemble.templateDef, args, Assemble.TemplateArg.text, Assemble.typeString, Assemble.intText,
    Assemble.joinWith, Assemble.decimal, Assemble.decimalAux]

theorem templateHash_N (D : List Char) (hD : Digits D) :
    Assemble.templateHash ('<' :: (chars!"bfloat16_t, " ++ (D ++ chars!", 0>"))) =
      '_' :: (chars!"bfloat16_t_" ++ (D ++ chars!"_0")) := by
  unfold Assemble.templateHash
  rw [hashPre, hashChars_digits D _ hD, hashPost]
  rw [List.dropLast_cons_of_ne_nil (by simp), List.dropLast_append_of_ne_nil (by simp),
    List.dropLast_append_of_ne_nil (by simp)]
  rfl

theorem inputSuffix_big (nm : List Char) (d : Dtype) (N : Nat) (h8 : 8 ≤ N) (t : List Char) (ht : Assemble.typeString d = some t) :
    Assemble.inputSuffix ⟨nm, d, [N]⟩ = some ('_' :: t) := by
  simp [Assemble.inputSuffix, ht, Assemble.Input.size, Assemble.maxConstantArraySize]; omega

theorem kernelName_N (N : Nat) (h8 : 8 ≤ N) :
    Assemble.kernelName (PrefillSources.name .aneWriteHalf) (inputs N) [.int32] (args N) =
      some (nameOf (Assemble.decimal N)) := by
  have hD := (decimal_spec N).1
  simp only [Assemble.kernelName, args, List.isEmpty_cons, Bool.false_eq_true, ite_false]
  rw [show [Assemble.TemplateArg.dtype chars!"T" .bfloat16, .int chars!"N" N, .int chars!"OFFSET" 0] = args N from rfl,
    templateDef_N]
  simp only [Option.bind_eq_bind, Option.bind_some, Option.pure_def, templateHash_N _ hD, inputs, List.mapM_cons,
    List.mapM_nil, inputSuffix_big chars!"src" .bfloat16 N h8 chars!"bfloat16_t" rfl,
    inputSuffix_big chars!"dst" .float16 N h8 chars!"float16_t" rfl, Assemble.typeString]
  simp [nameOf, W0, W1, PrefillSources.name]

def insT : List Char :=
  chars!"  const device bfloat16_t* src [[buffer(0)]],\n  const device float16_t* dst [[buffer(1)]],\n"
def outsT : List Char := chars!"  device int32_t* done [[buffer(2)]],\n"
def attrT : List Char := chars!"  uint3 thread_position_in_grid [[thread_position_in_grid]]) {\n"

kernel_rfl_all signature_m : ∀ (k : List Char) (m : Nat),
  Assemble.signature k (PrefillSources.source .aneWriteHalf) (inputs (m + 8)) [chars!"done"] [.int32] (args (m + 8))
    false = some (Q0 ++ k ++ chars!"(\n" ++ insT ++ outsT ++ attrT)
kernel_rfl_all S1_eq : S1 = chars!"(\n" ++ insT ++ outsT ++ attrT

theorem signature_N (k : List Char) (N : Nat) (h8 : 8 ≤ N) :
    Assemble.signature k (PrefillSources.source .aneWriteHalf) (inputs N) [chars!"done"] [.int32] (args N) false =
      some (Q0 ++ (k ++ S1)) := by
  obtain ⟨m, rfl⟩ : ∃ m, N = m + 8 := ⟨N - 8, by omega⟩
  rw [signature_m k m, S1_eq]
  simp only [List.append_assoc]

theorem instantiation_N (k : List Char) (N : Nat) :
    Assemble.instantiation k (args N) =
      some (chars!"\ntemplate [[host_name(\"" ++ k ++ chars!"\")]] [[kernel]] decltype(" ++
        (k ++ '<' :: (chars!"bfloat16_t, " ++ (Assemble.decimal N ++ chars!", 0>"))) ++ chars!") " ++
        (k ++ '<' :: (chars!"bfloat16_t, " ++ (Assemble.decimal N ++ chars!", 0>"))) ++ chars!";\n") := by
  simp only [Assemble.instantiation, args, List.isEmpty_cons, Bool.false_eq_true, ite_false]
  rw [show [Assemble.TemplateArg.dtype chars!"T" .bfloat16, .int chars!"N" N, .int chars!"OFFSET" 0] = args N from rfl,
    templateDef_N]
  rfl

set_option maxRecDepth 100000 in
theorem assembled_eq (N : Nat) (h8 : 8 ≤ N) (hN : N < 2 ^ 31) : assembled N = some (textOf (Assemble.decimal N)) := by
  have hrep : (args N).all Assemble.TemplateArg.representable = true := by
    simp [args, Assemble.TemplateArg.representable]; omega
  unfold assembled Assemble.assemble
  rw [hrep]
  simp only [List.isEmpty_cons, List.length_cons, List.length_nil, bne_self_eq_false, Bool.not_true, Bool.or_false,
    Bool.false_eq_true, ite_false, kernelName_N N h8, signature_N _ N h8, instantiation_N, Option.bind_eq_bind,
    Option.bind_some, Option.pure_def]
  simp only [textOf, nameOf, Q1, Q2, Q3, Q4, Q6, PrefillSources.header, List.append_assoc, List.cons_append,
    List.nil_append]

/-! ## The compile, for every element count -/

theorem toks_noDirective (D : List Char) : ∀ t ∈ toks D, isDirective t = false := by
  intro t ht
  have h := List.all_eq_true.mp (toks_plain D) t ht
  simpa using h

/-- Every `N` from 8 below 2^31 (MLX's `int` template argument): the text MLX assembles for `N`
elements elaborates to `core N`. The lexer reads `N`'s digits inside the mangled name (three
identifiers and the `host_name` string) and as the instantiation's argument; every other token is
the same for all `N` (`toks`); parsing and elaboration carry the name and `N` through. -/
theorem compile_eq (N : Nat) (h8 : 8 ≤ N) (hN : N < 2 ^ 31) :
    (frontend (text N)).bind elaborate = some (core N) := by
  obtain ⟨hD, hne, hval, hhead⟩ := decimal_spec N
  obtain ⟨x, hx⟩ : ∃ x, (Assemble.decimal N).head? = some x := by
    cases h : Assemble.decimal N with
    | nil => exact absurd h hne
    | cons y ys => exact ⟨y, rfl⟩
  have h0 := hhead (by omega) x hx
  have hl : (toks (Assemble.decimal N)).length < ppFuel := by rw [toks_length]; decide
  unfold text
  rw [assembled_eq N h8 hN, Option.getD_some]
  unfold frontend
  rw [lex_text _ hD x hx h0, preprocess_plain _ hl (toks_noDirective _), Option.bind_some, parse_toks, Option.bind_some,
    hval, elab_unit _ N hN]

/-- The route's element counts: the hidden rows `5120·r` (MLP and 5120-input projections) and `6144·r`
(6144-input projections) for every prompt row count `r` the ANE forwards take (224 … 2048), and the
weight heads (ane-prefill-split.ts `AneAffineSplit.forward`: n·K for qkv 3840·5120, z and out/o
2304·5120 = 1920·6144, q 4608·5120). -/
theorem compile_route (r : Nat) (hr : 224 ≤ r ∧ r ≤ 2048) :
    (frontend (text (5120 * r))).bind elaborate = some (core (5120 * r)) ∧
    (frontend (text (6144 * r))).bind elaborate = some (core (6144 * r)) ∧
    (frontend (text 19660800)).bind elaborate = some (core 19660800) ∧
    (frontend (text 11796480)).bind elaborate = some (core 11796480) ∧
    (frontend (text 23592960)).bind elaborate = some (core 23592960) :=
  ⟨compile_eq _ (by omega) (by omega), compile_eq _ (by omega) (by omega), compile_eq _ (by omega) (by omega),
    compile_eq _ (by omega) (by omega), compile_eq _ (by omega) (by omega)⟩

end Assembled
end Metal.Kernels.AneWriteHalf

set_option linter.constructorNameAsVariable false

/-! ## The proof -/

namespace Metal.Kernels.AneWrite
open Metal Metal.Core Inference.Contracts.Mlx Metal.Kernels.Trellis

/-! ### Expected outputs -/

section Spec
variable (C : M1Max.Contract)

/-- `half(float(src[i]))` of the bfloat16 `src`. -/
def halfOf (Src : ByteMemory.Bytes) (i : Nat) : Float16.Value := C.narrowHalf (C.widen (Val.ofBf16Bits (half Src i)))

/-- The writer's stores into `dst`: halves `OFFSET … OFFSET + N - 1` (`OFFSET = 0`), `half(float(src[i]))`
(`WritesThrough`'s `stored`). -/
def writeStored (N : Nat) (Src : ByteMemory.Bytes) (b : Nat) : Option (BitVec 8) :=
  if b < 2 * N then some (halfByte (halfOf C Src (b / 2)) (b % 2)) else none

end Spec

/-! ### The launch -/

/-- Threadgroups: `⌈N / 256⌉`. -/
def gx (N : Nat) : Nat := (N + 255) / 256

def bufs (N nd : Nat) (Src D : ByteMemory.Bytes) (as ad : Nat) : List Buffer :=
  [⟨.device, N * 2, as, Src⟩, ⟨.device, nd * 2, ad, D⟩]

/-- MLX's launch (fill.ts `writeHalf`): grid `[⌈N/256⌉·256, 1, 1]`, threadgroup `[256, 1, 1]`, `done` int32 [1]. -/
def launch (N nd : Nat) (Src D : ByteMemory.Bytes) (as ad : Nat) (initial : Nat → ByteMemory.Bytes) : Launch :=
  ⟨AneWriteHalf.core N, (gx N * 256, 1, 1), (256, 1, 1), buffers (bufs N nd Src D as ad) [4] 16 initial⟩

structure Shape (L : Launch) (N nd as ad : Nat) : Prop where
  r0 : L.regions 0 = some ⟨.device, N * 2, as⟩
  r1 : L.regions 1 = some ⟨.device, nd * 2, ad⟩
  r2 : L.regions 2 = some ⟨.device, 4, 16⟩
  as : as % 2 = 0
  ad : ad % 2 = 0

theorem launch_shape {N nd as ad : Nat} {Src D : ByteMemory.Bytes} {initial : Nat → ByteMemory.Bytes}
    (has : as % 2 = 0) (had : ad % 2 = 0) : Shape (launch N nd Src D as ad initial) N nd as ad := by
  have hb : (launch N nd Src D as ad initial).buffers = buffers (bufs N nd Src D as ad) [4] 16 initial := rfl
  exact ⟨regions_input hb 0 (by simp [bufs]), regions_input hb 1 (by simp [bufs]), regions_output hb 0 (by simp), has,
    had⟩

/-- The writer of each device byte: `dst`'s element `e` by thread `e` (threadgroup `e / 256`), `done` by thread 0. -/
def dev (region byte : Nat) : Option Writer :=
  if region = 1 then some ⟨byte / 2, byte / 2 / 256, 0⟩ else if region = 2 then some ⟨0, 0, 0⟩ else none

/-- Memory during the launch: `src` intact, `dst`'s first `E` halves `W`, `done` written once a thread has finished
(`0 < P`), every access so far keeping the ownership discipline. -/
structure Mem (L : Launch) (Src D : ByteMemory.Bytes) (W : Nat → Float16.Value) (E P : Nat) (sh : Shared) : Prop where
  regions : sh.regions = L.regions
  src : sh.bytes 0 = Src
  dst : sh.bytes 1 = halvesOver W D E
  done : 0 < P → cells (sh.bytes 2) 0 4 = wordBytes 4 1
  deve : sh.deviceEpoch = 0
  grpe : sh.groupEpoch = 0
  log : ∀ a ∈ sh.log, Owned L dev AneFill.tgo a

section Memory
variable {L : Launch} {N nd as ad : Nat} {Src D : ByteMemory.Bytes} {W : Nat → Float16.Value} {E P : Nat} {sh : Shared}

theorem Mem.cast (h : Mem L Src D W E P sh) {E' P' : Nat} (h1 : E = E') (h2 : P = P') : Mem L Src D W E' P' sh := by
  subst h1 h2; exact h

theorem Mem.rd (h : Mem L Src D W E P sh) (hS : Shape L N nd as ad) (ctx : Ctx) (o n : Nat) :
    Mem L Src D W E P (rdn ctx sh 0 o n) :=
  ⟨h.regions, h.src, h.dst, h.done, h.deve, h.grpe, forall_log _ n _ (fun j _ =>
    owned_device_read L dev AneFill.tgo ctx sh 0 (o + j) _ hS.r0 (by simp) (by simp [dev])) h.log⟩

/-- Thread `E`'s store of `dst`'s next half. -/
theorem Mem.w (h : Mem L Src D W E P sh) (hS : Shape L N nd as ad) (ctx : Ctx) (ht : ctx.thread = E)
    (hg : ctx.group = E / 256) :
    Mem L Src D W (E + 1) P (wrn ctx sh 1 (2 * E) 2 (wordBytes 2 (Val.f16Bits (W E)))) :=
  ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.src,
    by rw [wrn_same, h.dst]; exact halvesOver_store W D E 1 _ (wordBytes_length 2 _) (fun k hk => by
      rcases (show k = 0 ∨ k = 1 by omega) with rfl | rfl <;> rfl),
    fun hp => by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.done hp, h.deve, h.grpe,
    forall_log _ 2 _ (fun j hj => owned_device L dev AneFill.tgo ctx sh 1 (2 * E + j) _ hS.r1 true (by simp)
      ⟨(2 * E + j) / 2, (2 * E + j) / 2 / 256, 0⟩ (by simp [dev])
      (by rw [ht]; dsimp only; omega) (by rw [hg]; dsimp only; rw [show (2 * E + j) / 2 = E by omega])
      (by rw [h.deve])) h.log⟩

theorem Mem.wdone (h : Mem L Src D W E P sh) (hS : Shape L N nd as ad) (ctx : Ctx) (ht : ctx.thread = 0)
    (hg : ctx.group = 0) : Mem L Src D W E (P + 1) (wrn ctx sh 2 0 4 (wordBytes 4 1)) :=
  ⟨h.regions, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.src, by rw [wrn_other _ _ _ _ _ (by omega)]; exact h.dst,
    fun _ => by
      rw [wrn_same]
      have := cells_writeBytes_same (sh.bytes 2) 0 (wordBytes 4 1)
      rwa [wordBytes_length] at this,
    h.deve, h.grpe,
    forall_log _ 4 _ (fun j _ => owned_device L dev AneFill.tgo ctx sh 2 (0 + j) _ hS.r2 true (by simp)
      ⟨0, 0, 0⟩ (by simp [dev]) ht hg (by rw [h.deve])) h.log⟩

theorem Mem.bump (h : Mem L Src D W E P sh) (hp : 0 < P) : Mem L Src D W E (P + 1) sh :=
  ⟨h.regions, h.src, h.dst, fun _ => h.done hp, h.deve, h.grpe, h.log⟩

theorem Mem.reset (h : Mem L Src D W E P sh) (hg : L.groupArrays = 0) (garbage : Garbage) (g : Nat) :
    Mem L Src D W E P { sh with bytes := L.resetGroup garbage g sh.bytes } := by
  rw [Launch.resetGroup_none L garbage g sh.bytes hg]
  exact h

end Memory

/-! ### A thread -/

section Thread
variable (C : M1Max.Contract) {ctx : Ctx} {L : Launch} {N nd as ad : Nat} {Src D : ByteMemory.Bytes}

/-- **Thread `x`**: if `x < N`, `dst[x] = half(float(src[x]))`; thread 0 writes `done`. -/
theorem lane_run (hS : Shape L N nd as ad) (hN : N < 2 ^ 31) (hnd : N ≤ nd) {x : Nat} (hx : x < 2 ^ 32)
    (hpos : ctx.coord .threadPositionInGrid = u32x3 x 0 0) (ht : ctx.thread = x) (hg : ctx.group = x / 256)
    {sh : Shared} (hm : Mem L Src D (halfOf C Src) (min x N) x sh) :
    ∃ l' sh', Exec C ctx (AneWriteHalf.body N) (fun _ => none) sh .normal l' sh' ∧
      Mem L Src D (halfOf C Src) (min (x + 1) N) (x + 1) sh' := by
  generalize hl : setLocal (setLocal (setLocal (setLocal (fun _ => none) 0 (.ptr ⟨0, 0, .scalar .bf16⟩)) 1
    (.ptr ⟨1, 0, .scalar .f16⟩)) 2 (.ptr ⟨2, 0, .scalar .i32⟩)) 3 (u32 x) = l
  have h0 : l 0 = some (.ptr ⟨0, 0, .scalar .bf16⟩) := by rw [← hl]; rfl
  have h1 : l 1 = some (.ptr ⟨1, 0, .scalar .f16⟩) := by rw [← hl]; rfl
  have h2 : l 2 = some (.ptr ⟨2, 0, .scalar .i32⟩) := by rw [← hl]; rfl
  have h3 : l 3 = some (u32 x) := by rw [← hl]; rfl
  have hlt := eval_lt_u32 C (ctx := ctx) (sh := sh) (b := N) h3 hx (by omega)
  -- the half
  have hwr : ∃ sh₁, Exec C ctx (if decide (x < N) then [.store (.scalar .f16)
      (.offset (.local 1) (.bin .add .u32 0 (.lit (.int .u32 0)) (.local 3)))
      (.conv .f16 (.conv .f32 (.load (.scalar .bf16) (.offset (.local 0) (.local 3)))))] else []) l sh .normal l sh₁ ∧
      Mem L Src D (halfOf C Src) (min (x + 1) N) x sh₁ := by
    by_cases hxN : x < N
    · rw [decide_eq_true hxN]
      have hp : (eval C ctx l (.offset (.local 1) (.bin .add .u32 0 (.lit (.int .u32 0)) (.local 3)))).run sh =
          some (.ptr ⟨1, ((2 * x : Nat) : Int), .scalar .f16⟩, sh) := by
        have hidx : (eval C ctx l (.bin .add .u32 0 (.lit (.int .u32 0)) (.local 3))).run sh = some (u32 (0 + x), sh) :=
          eval_bin_u32 C (eval_u32lit C l sh 0 (by decide)) (eval_local' C h3 sh) (binary_add_u32 C 0 x)
        have := eval_offset_u32 C (o := 0) (eval_local' C h1 sh) hidx (show 0 + x < 2 ^ 32 by omega)
        rwa [show 0 + (0 + x) * (Ty.scalar .f16).bytes = 2 * x by show 0 + (0 + x) * 2 = _; omega] at this
      have hq : (eval C ctx l (.offset (.local 0) (.local 3))).run sh =
          some (.ptr ⟨0, ((2 * x : Nat) : Int), .scalar .bf16⟩, sh) := by
        have := eval_offset_u32 C (ctx := ctx) (o := 0) (eval_local' C h0 sh) (eval_local' C h3 sh) hx
        rwa [show 0 + x * (Ty.scalar .bf16).bytes = 2 * x by show 0 + x * 2 = _; omega] at this
      have hld : (eval C ctx l (.load (.scalar .bf16) (.offset (.local 0) (.local 3)))).run sh =
          some (.bf16 (Val.ofBf16Bits (half Src x)), rdn ctx sh 0 (2 * x) 2) := by
        rw [eval_load C _ _ _ _ _ _ _ hq, load_shared ctx .bf16 sh 0 (2 * x) ⟨.device, N * 2, as⟩
          (by rw [hm.regions]; exact hS.r0) (by simp) (by show as % 2 = 0; exact hS.as) (by show 2 * x % 2 = 0; omega)
          (by show 2 * x + 2 ≤ N * 2; omega) (by simp [loadOffset]), hm.src]
        rfl
      have hval := eval_conv C (t := .f16) (w := .f16 (halfOf C Src x)) (eval_conv C (t := .f32) hld rfl) rfl
      have hm₁ := hm.rd hS ctx (2 * x) 2
      generalize rdn ctx sh 0 (2 * x) 2 = sh₁ at hval hm₁
      have hs := store_shared ctx .f16 sh₁ 1 (2 * x) ⟨.device, nd * 2, ad⟩ (.f16 (halfOf C Src x))
        (wordBytes 2 (Val.f16Bits (halfOf C Src x))) (by rw [hm₁.regions]; exact hS.r1) (by simp) (by simp)
        (by show ad % 2 = 0; exact hS.ad) (by show 2 * x % 2 = 0; omega) (by show 2 * x + 2 ≤ nd * 2; omega) rfl
      have hm₂ := (hm₁.cast (E' := x) (by omega) rfl).w hS ctx ht hg
      exact ⟨_, .store hp hval hs (.nil _ _), hm₂.cast (by omega) rfl⟩
    · rw [decide_eq_false hxN]
      exact ⟨sh, .nil _ _, hm.cast (by omega) rfl⟩
  obtain ⟨sh₁, hex, hm₁⟩ := hwr
  -- `done`
  have heq := eval_eq_u32 C (ctx := ctx) (sh := sh₁) (b := 0) h3 hx (by decide)
  by_cases hx0 : x = 0
  · rw [decide_eq_true hx0] at heq
    have hp3 : (eval C ctx l (.offset (.local 2) (.lit (.int .i32 0)))).run sh₁ =
        some (.ptr ⟨2, ((0 : Nat) : Int), .scalar .i32⟩, sh₁) := by
      have := eval_offset_i32 C (o := 0) (n := 0) (eval_local' C h2 sh₁)
        (show (eval C ctx l (.lit (.int .i32 0))).run sh₁ = some (.int .i32 0, sh₁) from rfl) (by decide)
      rwa [show 0 + 0 * (Ty.scalar .i32).bytes = 0 from rfl] at this
    have hs3 := store_shared ctx .i32 sh₁ 2 0 ⟨.device, 4, 16⟩ (.int .i32 1) (wordBytes 4 1)
      (by rw [hm₁.regions]; exact hS.r2) (by simp) (by simp) (by decide) (by decide) (by decide) rfl
    refine ⟨l, _, ?_, hm₁.wdone hS ctx (by rw [ht, hx0]) (by rw [hg, hx0])⟩
    rw [← hl]
    exact .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_coord0 C hpos)
      (by rw [hl]; exact .ite hlt hex (.ite heq (.store hp3 (eval_lit C _ _ _ _) hs3 (.nil _ _)) (.nil _ _))))))
  · rw [decide_eq_false hx0] at heq
    refine ⟨l, sh₁, ?_, hm₁.bump (Nat.pos_of_ne_zero hx0)⟩
    rw [← hl]
    exact .set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_lit C _ _ _ _) (.set (eval_coord0 C hpos)
      (by rw [hl]; exact .ite hlt hex (.ite heq (.nil _ _) (.nil _ _))))))

end Thread

/-! ### Threadgroups and the launch -/

section Group
variable (C : M1Max.Contract) {N nd as ad : Nat} {Src D : ByteMemory.Bytes} {initial : Nat → ByteMemory.Bytes}

theorem launch_tiles (hN : 0 < N) : (launch N nd Src D as ad initial).Tiles 256 1 1 (gx N) 1 1 8 :=
  ⟨rfl, rfl, rfl, ⟨by decide, by unfold gx; omega, by decide, by decide⟩⟩

/-- Threadgroup `bx`: its 256 threads `256·bx + l`. -/
theorem group_run (hS : Shape (launch N nd Src D as ad initial) N nd as ad) (h8 : 8 ≤ N) (hN : N < 2 ^ 31)
    (hnd : N ≤ nd) (fuse : Nat → Bool) {bx : Nat} (hx : bx < gx N) {sh : Shared}
    (hm : Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx) N) (256 * bx) sh) :
    ∃ sh', (Ev fun m => (runGroup C m 1 1 (List.ofFn fun s : Fin 8 =>
        List.ofFn ((launch N nd Src D as ad initial).lanes fuse bx 0 0 s))).run sh = some ((), sh')) ∧
      Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx + 256) N) (256 * bx + 256) sh' := by
  have hT := launch_tiles (N := N) (nd := nd) (Src := Src) (D := D) (as := as) (ad := ad) (initial := initial)
    (by omega)
  have hlane : ∀ (s : Fin 8) (i : Fin 32) (sh : Shared),
      Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx + 32 * s + i) N)
        (256 * bx + 32 * s + i) sh →
      ∃ t sh', (Ev fun m => (runThread C m ((launch N nd Src D as ad initial).lanes fuse bx 0 0 s i)).run sh =
          some (t, sh')) ∧
        Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx + 32 * s + i + 1) N)
          (256 * bx + 32 * s + i + 1) sh' ∧ blocked t.status = true ∧ t.status = .done := by
    intro s i sh hi
    have hs := s.isLt
    have hi' := i.isLt
    have hgx : gx N * 256 < 2 ^ 32 := by unfold gx; omega
    have hpos : ((launch N nd Src D as ad initial).ctxAt fuse bx 0 0 (32 * s + i)).coord .threadPositionInGrid =
        u32x3 (256 * bx + 32 * s + i) 0 0 := by
      rw [hT.threadPositionInGrid]
      rw [show (32 * s.val + i.val) % 256 = 32 * s + i by omega, show (32 * s.val + i.val) / 256 % 1 = 0 by omega,
        show (32 * s.val + i.val) / (256 * 1) = 0 by omega]
      congr 1; omega
    obtain ⟨l', sh', hex, hm'⟩ := lane_run C (ctx := (launch N nd Src D as ad initial).ctxAt fuse bx 0 0 (32 * s + i))
      hS hN hnd (x := 256 * bx + 32 * s + i) (by omega) hpos (by rw [hT.thread]; omega)
      (by rw [hT.group_id]; omega) hi
    exact ⟨⟨_, l', [], .done⟩, sh', hex.reaches_done.ev_stop rfl, hm', rfl, rfl⟩
  refine runGroup_done_ev C 1 0 (fun (s : Fin 8) (i : Fin 32) => (launch N nd Src D as ad initial).lanes fuse bx 0 0 s i)
    (fun j sh => Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx + 32 * j) N)
      (256 * bx + 32 * j) sh) (fun j sh hj => ?_) sh (hm.cast (by omega) (by omega))
  obtain ⟨V, sh', hr, hI, hR⟩ := runSimd_blocked_ev C 0 _
    (fun i sh => Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * bx + 32 * j + i) N)
      (256 * bx + 32 * j + i) sh)
    (fun _ t => t.status = .done)
    (fun i sh hi => by
      obtain ⟨t, sh', ht, hm', hb, hd⟩ := hlane j i sh hi
      exact ⟨t, sh', ht, hm'.cast (by omega) (by omega), hb, hd⟩)
    sh (hj.cast (by omega) (by omega))
  exact ⟨V, sh', hr, hI.cast (by omega) (by omega), hR⟩

theorem launch_run (hS : Shape (launch N nd Src D as ad initial) N nd as ad) (h8 : 8 ≤ N) (hN : N < 2 ^ 31)
    (hnd : N ≤ nd) (fuse : Nat → Bool) (garbage : Garbage) :
    ∃ sh, Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) N (256 * gx N) sh ∧
      Ev fun m => runLaunch C fuse (launch N nd Src D as ad initial) garbage m 1 1 = some ⟨sh.bytes, sh.log⟩ := by
  have hT := launch_tiles (N := N) (nd := nd) (Src := Src) (D := D) (as := as) (ad := ad) (initial := initial)
    (by omega)
  have hb : (launch N nd Src D as ad initial).buffers = buffers (bufs N nd Src D as ad) [4] 16 initial := rfl
  have h0 : Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) 0 0
      ((launch N nd Src D as ad initial).initial garbage) :=
    ⟨rfl, initial_input hb garbage 0 (by simp [bufs]),
      by rw [initial_input hb garbage 1 (by simp [bufs])]; funext b; simp [halvesOver, bufs],
      fun h => absurd h (by omega), rfl, rfl, fun a ha => by simp [Launch.initial] at ha⟩
  obtain ⟨sh, hI, hr⟩ := hT.launch_run_ev C fuse garbage 1 1
    (fun g sh => Mem (launch N nd Src D as ad initial) Src D (halfOf C Src) (min (256 * g) N) (256 * g) sh)
    (h0.cast (by omega) (by omega))
    (fun bx byy bz hx hy hz sh hI => by
      obtain rfl : byy = 0 := by omega
      obtain rfl : bz = 0 := by omega
      have hm := (hI.reset rfl garbage (bx + 0 * gx N + 0 * gx N * 1)).cast (E' := min (256 * bx) N) (P' := 256 * bx)
        (by simp) (by simp)
      obtain ⟨sh', hr, hm'⟩ := group_run C hS h8 hN hnd fuse hx hm
      exact ⟨sh', hr, hm'.cast (by simp; omega) (by simp; omega)⟩)
  exact ⟨sh, hI.cast (by unfold gx; omega) (by simp), hr⟩

end Group

/-! ### The GPU -/

variable (C : M1Max.Contract)

/-- **The GPU runs `mlx_bun_ane_write_half` as its source says**, for every element count `N` from 8 below 2^31
(`OFFSET = 0`). MLX's launch on `src` (`N` bfloat16, 2-aligned) and `dst` (`nd ≥ N` halves, 2-aligned) completes,
`dst` holds `half(float(src[i]))` in its first `N` halves and its previous bytes elsewhere, and `done` is 1. -/
theorem gpu_output (N : Nat) (h8 : 8 ≤ N) (hN : N < 2 ^ 31) (G : Gpu C) (hmax : 256 ≤ G.maxThreads (AneWriteHalf.text N))
    (Src D : ByteMemory.Bytes) (as ad nd : Nat) (has : 2 ∣ as) (had : 2 ∣ ad) (hnd : N ≤ nd) :
    ∃ res B, G.executeAll (AneWriteHalf.text N) ((N + 255) / 256 * 256, 1, 1) (256, 1, 1)
        [⟨.device, N * 2, as, Src⟩, ⟨.device, nd * 2, ad, D⟩] [4] = some res ∧
      res.length = 3 ∧ res[1]? = some B ∧ (∀ b, b < nd * 2 → B b = (writeStored C N Src b).getD (D b)) ∧
      res[2]? = some AneFill.doneOut := by
  obtain ⟨res, hres, hlen, hall⟩ := gpu_owned_set C G (text := AneWriteHalf.text N) (kernel := AneWriteHalf.core N)
    (grid := (gx N * 256, 1, 1)) (tg := (256, 1, 1)) (inputs := bufs N nd Src D as ad) (sizes := [4])
    (fun i => i = 1 ∨ i = 2)
    (fun i => if i = 1 then halvesOver (halfOf C Src) D N else fun b => (wordBytes 4 1).getD b 0)
    (AneWriteHalf.compile_eq N h8 hN) (by simpa using hmax) (fun initial garbage => by
      have hS := launch_shape (N := N) (nd := nd) (Src := Src) (D := D) (initial := initial)
        (Nat.mod_eq_zero_of_dvd has) (Nat.mod_eq_zero_of_dvd had)
      obtain ⟨sh, hm, n, hn⟩ := launch_run C hS h8 hN hnd (G.fusion (AneWriteHalf.text N)) garbage
      refine ⟨n, 1, 1, sh, dev, AneFill.tgo, hn n le_rfl, hm.log, ?_⟩
      rintro i (rfl | rfl) b hb
      · rw [hm.dst, ite_eq_left rfl]
      · rw [ite_eq_right (show ¬ (2 : Nat) = 1 by decide)]
        have hb4 : b < 4 := hb
        have hd := hm.done (by unfold gx; omega)
        have e := cells_getD (sh.bytes 2) 0 4 b hb4
        rw [hd, Nat.zero_add] at e
        exact e.symm)
  have h1 : 1 < res.length := by rw [hlen]; simp [bufs]
  have h2 : 2 < res.length := by rw [hlen]; simp [bufs]
  refine ⟨res, res[1], hres, by rw [hlen]; simp [bufs], List.getElem?_eq_getElem h1, fun b hb => ?_, ?_⟩
  · rw [hall 1 h1 (.inl rfl)]
    show (if b < nd * 2 then (if (1 : Nat) = 1 then halvesOver (halfOf C Src) D N
      else fun b => (wordBytes 4 1).getD b 0) b else 0) = _
    rw [ite_eq_left hb, ite_eq_left rfl]
    unfold halvesOver writeStored
    by_cases h : b < 2 * N <;> simp [h]
  · rw [List.getElem?_eq_getElem h2, hall 2 h2 (.inr rfl)]
    congr 1
    funext b
    show (if b < 4 then (if (2 : Nat) = 1 then halvesOver (halfOf C Src) D N
      else fun b => (wordBytes 4 1).getD b 0) b else 0) = AneFill.doneOut b
    rw [ite_eq_right (show ¬ (2 : Nat) = 1 by decide)]
    unfold AneFill.doneOut
    by_cases hb : b < 4
    · rw [ite_eq_left hb]
    · rw [ite_eq_right hb, List.getD_eq_default _ _ (by rw [wordBytes_length]; omega)]

end Metal.Kernels.AneWrite
