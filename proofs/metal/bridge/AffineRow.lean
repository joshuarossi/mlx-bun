import metal.kernels.AffineRow
import metal.bridge.General

namespace Metal.Bridge.AffineRow
open Metal Metal.Core Metal.Kernels.AffineRow
open Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics Inference.Contracts.Mlx.ArithmeticFold
open Inference.Kernels Inference.Layers
open Inference.Kernels.Quantization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Arithmetic (evaluate finite_evaluate)
open Metal.Bridge.General

/-! # affine_row: the machine spec is the model

`Metal.Kernels.AffineRow.gpu_output3`/`gpu_output4` state the launch's outputs with the M1 Max operations and the
compiler's contraction choices `fuse`; `AffineVerifyLinear.Projection3/4.forward` (what
`GlueKernels.affine_row3/4` consume) state them with the flush-to-zero models on `C.rowPlatformAt contracted
tailContracted`, one choice per contraction site. The correspondence:

* inputs: `bfAt` of `x`, `scales`, `biases` and the bytes (BITS = 3) or halfwords (BITS = 4) of `w` at
  `AffineLayout.weightOffset` are the model's input and `Weights3/4` (`Decodes3/4`; from MLX's row-major storage
  of `GlueKernels`' `Row`/`Affine3`/`Affine4` values by `decodes3_of_values`/`decodes4_of_values`);
* lane `L`'s chunk at K step `t` is the model's tile `(t, L)`, its scale and bias the group `8t + L/4`;
* `MLXQ_F` (`deq`) is `AffineLift.value` on every masked field (`deq_checked`, by evaluation);
* the compiler folds `x / 2^s` to `x * 2^-s`; the model divides (`C.fdiv`); equal on finite `x` (`scale_eq`);
* `scale * accum + sum * bias` unfused is the model's `sum * bias + scale * accum` (commuted, `add_comm`);
* contraction sites: BITS = 3 has ten (2–11, one per `accum +=` line), the model's sites 0–9 (`sites3`);
  BITS = 4 has 12, 13, 14, the model's sites 0, 1, 2 (`sites4`); site 15 is `tailContracted`. Fused, site 12
  (`x₀ F₀ + x₁ F₁`) contracts the left product, as the model's `maddLeft` does. -/

variable (C : M1Max.Contract)

/-- The model's contraction choices (`AffineTile.Platform.contracted`) from the compiler's `fuse`: term `i` of
BITS = 3 is site `2 + i`, addition `i` of BITS = 4 is site `12 + i`. -/
def sites3 (fuse : Nat → Bool) (i : Nat) : Bool := fuse (2 + i)
def sites4 (fuse : Nat → Bool) (i : Nat) : Bool := fuse (12 + i)

/-! ## Dequantization: `MLXQ_F` is `AffineLift.value` on every masked field -/

set_option maxRecDepth 10000 in
set_option maxHeartbeats 0 in
theorem deq_checked : ∀ field : Fin 16, ∀ shift : Fin 13,
    (Val.ofF32Bits (field.val * 2 ^ shift.val ||| 0x4B000000)).isFinite = true ∧
    Arithmetic.sub (Val.ofF32Bits (field.val * 2 ^ shift.val ||| 0x4B000000)) (Val.ofF32Bits 0x4B000000) =
      AffineLift.value (field.val * 2 ^ shift.val) := by decide +kernel

theorem deq_mask (n width shift : Nat) (hw : width ≤ 4) (hs : shift < 13) :
    deq C (n &&& ((2 ^ width - 1) * 2 ^ shift)) = AffineLift.value (n &&& ((2 ^ width - 1) * 2 ^ shift)) := by
  rw [AffinePacking.shifted_mask]
  have hf : n / 2 ^ shift % 2 ^ width < 16 :=
    (Nat.mod_lt _ (by positivity)).trans_le (Nat.pow_le_pow_right (by decide) hw)
  obtain ⟨hA, hsub⟩ := deq_checked ⟨_, hf⟩ ⟨shift, hs⟩
  unfold deq
  rw [fadd_f32Neg C _ _ hA (by decide)]
  exact hsub

/-! ## `x / d` compiled as `x * (1/d)` is the model's division -/

theorem scale_eq (v : BF) (hv : Model.isFinite v = true) (bits : Nat) (s : Fin 13) (hs : 1 ≤ s.val)
    (hyf : (Val.ofF32Bits bits).isFinite = true) (hfy : FlushToZero.flush (Val.ofF32Bits bits) = Val.ofF32Bits bits)
    (hy : (Val.ofF32Bits bits).toModel.unpack = .finite .positive 8388608 (-(23 + s.val : Int)) (by decide)) :
    C.fmul (C.widen v) (Val.ofF32Bits bits) = C.fdiv (BFloat16.widen v) (AffineInput.divisor s) := by
  have hw := BFloat16.widen_finite v hv
  have hz := (AffineInput.divisors_checked s).2
  have hzr := AffineInput.divisor_value s
  have h2 : (2 : ℝ) ≤ 2 ^ s.val := by
    calc (2 : ℝ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ s.val := pow_le_pow_right₀ (by norm_num) hs
  rw [C.widen_model v hv, C.fmul_model _ _ hw hyf, C.fdiv_model _ _ hw hz (AffineInput.divisor_domain s)]
  exact mul_eq_div _ _ _ hw hyf hz hfy (FlushToZero.flush_eq_of_one_le _ (by rw [hzr]; linarith))
    (by rw [real_pow2 _ _ hy, hzr]) (by rw [hzr]; exact h2)

/-! ## BITS = 3: one lane's tile -/

section Tile3
variable {C}

/-- `x_thread[8 chunk + i]` of chunk `c` (BITS = 3) is the model's prepared input `prepared3`. -/
theorem xt3_eq (ctr : Nat → Bool) (tail : Bool) (X : ByteMemory.Bytes) (c : Nat) (xs : Fin 16 → BF)
    (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j) (hfin : ∀ j, Model.isFinite (xs j) = true)
    (chunk : Fin 2) (i : Fin 8) :
    xt3 C X c (8 * chunk.val + i.val) = AffineTile.prepared3 (C.tilePlatform ctr tail) xs chunk i := by
  have hj : (8 * chunk.val + i.val) % 8 = i.val := by omega
  have hidx : AffineInput.index8 chunk i = ⟨8 * chunk.val + i.val, by omega⟩ :=
    Fin.ext (by simp only [AffineInput.index8]; ring)
  have hx := hX ⟨8 * chunk.val + i.val, by omega⟩
  have hv := hfin ⟨8 * chunk.val + i.val, by omega⟩
  unfold xt3 AffineTile.prepared3 AffineInput.prepare
  rw [hj, hidx]
  simp only [xf, hx]
  fin_cases i
  · exact widen_eq C _ (BFloat16.widen_finite _ hv)
  · exact scale_eq C _ hv 0x3E000000 ⟨3, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3C800000 ⟨6, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3F000000 ⟨1, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3D800000 ⟨4, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3C000000 ⟨7, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3E800000 ⟨2, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3D000000 ⟨5, by decide⟩ (by decide) (by decide) (by decide) (by rfl)

theorem sfold_init {n : Nat} {xs : Fin n → BF} (g : Nat → Fin n) :
    ∀ (ks : List Nat) (e : AffineInput.SumExpr n),
      AffineInput.Finite xs (ks.foldl (fun s k => .add s (.input (g k))) e) → AffineInput.Finite xs e
  | [], _, h => h
  | k :: ks, e, h => (sfold_init g ks (.add e (.input (g k))) h).1

/-- A bfloat left sum of `bfAt X (e + k)` over `ks` is the model's `SumExpr` fold. -/
theorem sum_fold (X : ByteMemory.Bytes) {n : Nat} (xs : Fin n → BF) (e : Nat) (g : Nat → Fin n) (bound : Nat)
    (hX : ∀ k < bound, bfAt X (e + k) = xs (g k)) :
    ∀ (ks : List Nat) (acc : BF) (accE : AffineInput.SumExpr n), (∀ k ∈ ks, k < bound) →
      acc = AffineInput.evaluate xs accE → AffineInput.Finite xs (ks.foldl (fun s k => .add s (.input (g k))) accE) →
      ks.foldl (fun s k => C.bfadd s (bfAt X (e + k))) acc =
        AffineInput.evaluate xs (ks.foldl (fun s k => .add s (.input (g k))) accE)
  | [], _, _, _, h, _ => h
  | k :: ks, acc, accE, hks, h, hf => by
    simp only [List.foldl_cons] at hf ⊢
    have hinit := sfold_init g ks _ hf
    refine sum_fold X xs e g bound hX ks _ _ (fun j hj => hks j (List.mem_cons_of_mem _ hj)) ?_ hf
    rw [hX k (hks k (List.mem_cons_self ..)), h]
    exact C.bfadd_model _ _ (AffineInput.evaluate_finite _ _ hinit.1) hinit.2.1

/-- Group `grp` of BITS = 3 as a left fold. -/
def g3 (grp : Fin 2) (k : Nat) : Fin 16 := AffineInput.index8 grp ⟨k % 8, Nat.mod_lt _ (by decide)⟩

theorem groups3_fold (grp : Fin 2) :
    AffineInput.groups3 grp = [1, 2, 3, 4, 5, 6, 7].foldl (fun s k => .add s (.input (g3 grp k))) (.input (g3 grp 0)) :=
  rfl

/-- The chunk sum `load_vector` returns (BITS = 3) is the model's `summed`. -/
theorem cs3_eq (X : ByteMemory.Bytes) (c : Nat) (xs : Fin 16 → BF) (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j)
    (hg : ∀ i, AffineInput.Finite xs (AffineInput.groups3 i))
    (hsum : Arithmetic.Finite (AffineInput.bind (fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i))))
      (AffineInput.sumExpression 2)) :
    cs3 C X c = AffineInput.summed xs AffineInput.groups3 := by
  have hG : ∀ (grp : Fin 2) (e : Nat), e = 16 * c + 8 * grp.val →
      bsum C X e [1, 2, 3, 4, 5, 6, 7] = AffineInput.evaluate xs (AffineInput.groups3 grp) := by
    intro grp e he
    have hX' : ∀ k < 8, bfAt X (e + k) = xs (g3 grp k) := by
      intro k hk
      rw [show e + k = 16 * c + (g3 grp k).val by simp only [g3, AffineInput.index8]; omega]
      exact hX _
    rw [groups3_fold grp]
    unfold bsum
    exact sum_fold (C := C) X xs e (g3 grp) 8 hX' _ _ _ (by decide) (by have h0 := hX' 0 (by decide); rw [Nat.add_zero] at h0; exact h0)
      (by rw [← groups3_fold]; exact hg grp)
  have hse : AffineInput.sumExpression 2 = .add (.add .zero (.input 0)) (.input 1) := rfl
  rw [hse] at hsum
  unfold cs3 AffineInput.summed
  rw [← AffineInput.sum_execution, hse, hG 0 _ (by simp), hG 1 _ (by simp),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 0))),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 1)))]
  have h0 : zero = evaluate (AffineInput.bind fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i)))
      .zero := ofF32Bits_zero
  rw [h0]
  rw [show BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 0)) =
      evaluate (AffineInput.bind fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i))) (.input 0) from
      (AffineInput.bind_read (fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i))) 0).symm,
    show BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 1)) =
      evaluate (AffineInput.bind fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i))) (.input 1) from
      (AffineInput.bind_read (fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups3 i))) 1).symm,
    add_eq C hsum.1, add_eq C hsum]

/-- The machine's ten lines of `qdot` (BITS = 3) by line number: site `2 + i`, the model's byte, mask, coordinate
and crossing of term `i`. -/
def line3 (i : Fin 10) : Nat × Nat × Nat × Nat × Bool :=
  (2 + i.val, (AffineDot.byte3 i).val, (2 ^ AffineDot.width3 i - 1) * 2 ^ AffineDot.shift3 i, (AffineDot.coordinate3 i).val,
    AffineDot.crossed3 i)

theorem lines3_eq : lines3 = (List.finRange 10).map line3 := by decide

theorem c256_eq : c256 = (256 : Float32) := by decide

theorem bind3_low (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32) (k : Fin 8) :
    AffineDot.bind3 w scaled acc k.val = scaled k := by
  simp [AffineDot.bind3, k.isLt]

/-- One iteration of `qdot`'s bits-3 loop is the model's `AffineDot.source3` on the compiler's choices at its sites
when its expression is finite. -/
theorem half3_eq {fuse : Nat → Bool} (W : ByteMemory.Bytes)
    (o : Nat) (w : Fin 3 → BitVec 8) (hw : ∀ b : Fin 3, W (o + b.val) = w b) (x : Nat → Float32)
    (scaled : Fin 8 → Float32) (hx : ∀ k : Fin 8, x k.val = scaled k) (a acc : Float32) (ha : a = acc)
    (hf : Arithmetic.Finite (AffineDot.bind3 w scaled acc) (AffineDot.expression3 (sites3 fuse))) :
    half3 C fuse W o x a = AffineDot.source3 (sites3 fuse) w scaled acc := by
  rw [← AffineDot.execution3]
  unfold half3
  rw [lines3_eq, List.foldl_map]
  unfold AffineDot.expression3 at hf ⊢
  refine fold_eq _ (fun e i => madd (sites3 fuse i.val) (AffineDot.left3 i) (AffineDot.right3 i) e)
    (fun e i h => madd_acc_finite _ _ _ e h) _ a (.input 19) (by rw [ha]; rfl) ?_ hf
  intro i _ a' e' he' hfi
  obtain ⟨hl, hr, -⟩ := madd_finite hfi
  have hM : (2 ^ AffineDot.width3 i - 1) * 2 ^ AffineDot.shift3 i < 256 := by fin_cases i <;> decide
  have hW4 : AffineDot.width3 i ≤ 4 := by fin_cases i <;> decide
  have hS13 : AffineDot.shift3 i < 13 := by fin_cases i <;> decide
  have hdeq : deq C (byteAt W (o + (AffineDot.byte3 i).val) &&& ((2 ^ AffineDot.width3 i - 1) * 2 ^ AffineDot.shift3 i)) =
      evaluate (AffineDot.bind3 w scaled acc) (AffineDot.left3 i) := by
    have hl' : evaluate (AffineDot.bind3 w scaled acc) (AffineDot.left3 i) = AffineLift.value (AffineDot.mask3 w i) := by
      have := i.isLt
      simp [AffineDot.left3, Arithmetic.evaluate, AffineDot.bind3, show ¬8 + i.val < 8 by omega,
        show 8 + i.val < 18 by omega]
    rw [hl', byteAt, hw, deq_mask C _ _ _ hW4 hS13, AffineDot.mask3, AffinePacking.mask8, BitVec.toNat_and,
      BitVec.toNat_ofNat, Nat.mod_eq_of_lt hM]
  have hxo : xOperand C x (AffineDot.coordinate3 i).val (AffineDot.crossed3 i) =
      evaluate (AffineDot.bind3 w scaled acc) (AffineDot.right3 i) := by
    unfold AffineDot.right3 at hr ⊢
    unfold xOperand
    cases hc : AffineDot.crossed3 i
    · simp only [hc, Bool.false_eq_true, ite_false] at hr ⊢
      rw [hx]
      exact (bind3_low w scaled acc _).symm
    · simp only [hc, ite_true] at hr ⊢
      rw [hx, c256_eq, ← mul_eq C hr]
      rw [show evaluate (AffineDot.bind3 w scaled acc) (.input (AffineDot.coordinate3 i).val) = scaled (AffineDot.coordinate3 i)
        from bind3_low w scaled acc _]
      rfl
  show addTerm C fuse (2 + i.val) a' _ _ = _
  unfold addTerm
  rw [hdeq, hxo, he']
  exact madd_eq C rfl hfi

/-- `scale * accum + sum * bias` at contraction site 15 is the model's `combine`: the unfused sum's operands are
commuted (`sum * bias + scale * accum` in `tailExpr`), equal by commutativity of the flushed addition. -/
theorem tail_eq {fuse : Nat → Bool} {tail : Bool} (h15 : fuse 15 = tail) (sc bi : BF) (dot sum : Float32)
    (hf : Arithmetic.Finite (AffineTile.tailBind (BFloat16.widen sc) dot sum (BFloat16.widen bi)) (AffineTile.tailExpr tail)) :
    (if fuse 15 then C.fma (BFloat16.widen sc) dot (C.fmul sum (BFloat16.widen bi))
      else C.fadd (C.fmul (BFloat16.widen sc) dot) (C.fmul sum (BFloat16.widen bi))) =
      AffineTile.combine tail sc dot sum bi := by
  rw [← AffineTile.tail_execution, h15]
  unfold AffineTile.tailExpr at hf ⊢
  let T := AffineTile.tailBind (BFloat16.widen sc) dot sum (BFloat16.widen bi)
  cases tail
  · obtain ⟨hsb, hsd, -⟩ := hf
    simp only [Bool.false_eq_true, ite_false, madd]
    change C.fadd (C.fmul (evaluate T (.input 0)) (evaluate T (.input 1)))
      (C.fmul (evaluate T (.input 2)) (evaluate T (.input 3))) = _
    rw [mul_eq C hsd, mul_eq C hsb, C.fadd_model _ _ (finite_evaluate _ _ hsd) (finite_evaluate _ _ hsb), add_comm]
    rfl
  · obtain ⟨h0, h1, hsb, -⟩ := hf
    simp only [ite_true, madd]
    change C.fma (evaluate T (.input 0)) (evaluate T (.input 1)) (C.fmul (evaluate T (.input 2)) (evaluate T (.input 3))) = _
    rw [mul_eq C hsb, C.fma_model _ _ _ (finite_evaluate _ _ h0) (finite_evaluate _ _ h1) (finite_evaluate _ _ hsb)]
    rfl

theorem finRange2 : List.finRange 2 = [0, 1] := by decide

/-- **One lane's `qdot` (BITS = 3) is the model's tile value** `AffineTile.value3` on `C.tilePlatform` at the
compiler's choices (sites 2–11 as `sites3`, site 15 the tail), when the model's tile finiteness holds. -/
theorem tile3_eq {fuse : Nat → Bool} (X W : ByteMemory.Bytes) (c o : Nat) (xs : Fin 16 → BF)
    (ws : Fin 2 → Fin 3 → BitVec 8) (sc bi : BF) (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j)
    (hW : ∀ (chunk : Fin 2) (b : Fin 3), W (o + 3 * chunk.val + b.val) = ws chunk b)
    (hf : AffineTile.Finite3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws sc bi) :
    qdot3 C fuse W o (xt3 C X c) (C.widen sc) (C.widen bi) (cs3 C X c) =
      AffineTile.value3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws sc bi := by
  have hx0 : ∀ k : Fin 8, xt3 C X c k.val = AffineTile.prepared3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs 0 k := by
    intro k; have := xt3_eq (C := C) (sites3 fuse) (fuse 15) X c xs hX hf.dot.input 0 k; simpa using this
  have hx1 : ∀ k : Fin 8, (fun k => xt3 C X c (8 + k)) k.val =
      AffineTile.prepared3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs 1 k := by
    intro k; have := xt3_eq (C := C) (sites3 fuse) (fuse 15) X c xs hX hf.dot.input 1 k; simpa using this
  have harith := hf.dot.arithmetic
  rw [finRange2] at harith
  obtain ⟨v0, v1, -⟩ := harith
  have hd0 : half3 C fuse W o (xt3 C X c) zero =
      AffineTile.step3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws 0 0 :=
    half3_eq (C := C) W o (ws 0) (fun b => by simpa using hW 0 b) (xt3 C X c) _ hx0 zero 0 ofF32Bits_zero v0
  have hd1 : half3 C fuse W (o + 3) (fun k => xt3 C X c (8 + k)) (half3 C fuse W o (xt3 C X c) zero) =
      AffineTile.step3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws 1
        (AffineTile.step3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws 0 0) :=
    half3_eq (C := C) W (o + 3) (ws 1) (fun b => by simpa [Nat.add_assoc] using hW 1 b) (fun k => xt3 C X c (8 + k)) _
      hx1 _ _ hd0 v1
  have hdot : AffineTile.dot3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws =
      AffineTile.step3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws 1
        (AffineTile.step3 (C.tilePlatform (sites3 fuse) (fuse 15)) xs ws 0 0) := by
    unfold AffineTile.dot3; rw [finRange2, List.foldl_cons, List.foldl_cons, List.foldl_nil]
  unfold qdot3 AffineTile.value3
  rw [hdot, hd1, cs3_eq (C := C) X c xs hX hf.groups hf.sum, C.widen_model _ hf.scaleFinite, C.widen_model _ hf.biasFinite]
  have ht := hf.tail
  rw [hdot] at ht
  exact tail_eq (C := C) rfl sc bi _ _ ht

end Tile3

/-! ## A row: the K loop, the `simd_sum` and the cast -/

section Row
variable {C}

/-- Lane `L`'s `qdot` value at K step `t`. -/
def qOf (V : Variant) (fuse : Nat → Bool) (steps : Nat) (X W S B : ByteMemory.Bytes) (row L t : Nat) : Float32 :=
  V.qv fuse W (row * (64 * V.bits * steps) + 2 * V.bits * L + 64 * V.bits * t) (V.xt X (32 * t + L))
    (C.widen (bfAt S (row * (8 * steps) + 8 * t + L / 4))) (C.widen (bfAt B (row * (8 * steps) + 8 * t + L / 4)))
    (V.cs X (32 * t + L))

theorem acc_range (V : Variant) (fuse : Nat → Bool) (steps : Nat) (X W S B : ByteMemory.Bytes) (row L : Nat) :
    ∀ t, acc C V fuse steps X W S B row L t =
      (List.range t).foldl (fun a t => C.fadd a (qOf (C := C) V fuse steps X W S B row L t)) zero
  | 0 => rfl
  | t + 1 => by
    rw [List.range_succ, List.foldl_append, ← acc_range V fuse steps X W S B row L t]
    rfl

/-- **A row of the kernel is the model's row** (`AffineRow.source` cast to bf16) when every lane's `qdot` at every K
step is the model's tile and the model's reduction expression is finite. -/
theorem yOf_eq (V : Variant) {steps : Nat} (ctr : Nat → Bool) (tail : Bool) (tiles : Fin steps → Fin 32 → Float32)
    (fuse : Nat → Bool) (X W S B : ByteMemory.Bytes) (row : Nat)
    (htile : ∀ (t : Fin steps) (L : Fin 32), qOf (C := C) V fuse steps X W S B row L.val t.val = tiles t L)
    (hf : Arithmetic.Finite (Quantization.AffineRow.bind tiles) (Quantization.AffineRow.expression steps C.simdSum_tree.tree)) :
    yOf C V fuse steps X W S B row = BFloat16.narrow (Quantization.AffineRow.source (C.rowPlatformAt ctr tail) tiles) := by
  have hlane : ∀ L : Fin 32, acc C V fuse steps X W S B row L.val steps =
      evaluate (Quantization.AffineRow.bind tiles) (Quantization.AffineRow.laneExpr steps L) := by
    intro L
    have hl : Quantization.AffineRow.laneExpr steps L =
        (List.range steps).foldl (fun (e : Arithmetic.Expr) (t : Nat) => Arithmetic.Expr.add e (.input (t * 32 + L.val))) .zero := by
      unfold Quantization.AffineRow.laneExpr
      exact foldl_finRange steps (fun (e : Arithmetic.Expr) (t : Nat) => Arithmetic.Expr.add e (.input (t * 32 + L.val))) .zero
    have hfl := lanes_finite C.simdSum_tree.coverage hf L
    rw [hl] at hfl ⊢
    rw [acc_range]
    refine fold_eq _ (fun (e : Arithmetic.Expr) (t : Nat) => Arithmetic.Expr.add e (.input (t * 32 + L.val))) (fun e t h => h.1) _ zero .zero ofF32Bits_zero ?_ hfl
    intro t ht a' e' he' hfi
    have ht' : t < steps := List.mem_range.mp ht
    have hq : qOf (C := C) V fuse steps X W S B row L.val t =
        evaluate (Quantization.AffineRow.bind tiles) (.input (t * 32 + L.val)) := by
      rw [htile ⟨t, ht'⟩ L]
      exact (Quantization.AffineRow.bind_read tiles ⟨t, ht'⟩ L).symm
    show C.fadd a' _ = _
    rw [he', hq]
    exact add_eq C hfi
  unfold yOf
  rw [simdSum_eq C _ hlane]
  change C.narrow (evaluate (Quantization.AffineRow.bind tiles) (Quantization.AffineRow.expression steps C.simdSum_tree.tree)) = _
  rw [C.narrow_model _ (finite_evaluate _ _ hf), ← Quantization.AffineRow.execution]
  rfl

end Row

/-! ## BITS = 3: the projection -/

/-- The buffers' elements are the model's input and row weights, read as `Host.Mlx.weights3` reads them. -/
structure Decodes3 {steps rows : Nat} (p : AffineVerifyLinear.Projection3 steps rows) (input : Fin (steps * 512) → BF)
    (X W S B : ByteMemory.Bytes) : Prop where
  x : ∀ i : Fin (steps * 512), bfAt X i.val = input i
  w : ∀ (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 2) (b : Fin 3),
    W (AffineLayout.weightOffset 3 row.val steps step.val lane.val (chunk.val * 3 + b.val)) =
      (p.weights row).bytes step lane chunk b
  scale : ∀ (row : Fin rows) (g : Fin (steps * 8)), bfAt S (row.val * (steps * 8) + g.val) = (p.weights row).scale g
  bias : ∀ (row : Fin rows) (g : Fin (steps * 8)), bfAt B (row.val * (steps * 8) + g.val) = (p.weights row).bias g

section Projection3
variable {C}

theorem input_index {steps : Nat} (t : Fin steps) (L : Fin 32) (j : Fin 16) :
    16 * (32 * t.val + L.val) + j.val = (AffineLayout.inputIndex t L j).val := by
  simp only [AffineLayout.inputIndex]; ring

theorem group_index {steps : Nat} (row : Nat) (t : Fin steps) (L : Fin 32) :
    row * (8 * steps) + 8 * t.val + L.val / 4 = row * (steps * 8) + (Quantization.AffineRow.groupIndex t L).val := by
  simp only [Quantization.AffineRow.groupIndex]; ring

/-- **Row `row` of the 3-bit kernel is the model's `Projection3.forward`** on `C.rowPlatformAt (sites3 fuse)
(fuse 15)`, the compiler's choices at sites 2–11 and 15, when the buffers decode to the model's input and weights and
the model's finiteness predicate `Projection3.Finite` holds. -/
theorem yOf3_eq {steps rows : Nat} (p : AffineVerifyLinear.Projection3 steps rows) (input : Fin (steps * 512) → BF)
    {fuse : Nat → Bool} (hp : p.platform = C.rowPlatformAt (sites3 fuse) (fuse 15)) {X W S B : ByteMemory.Bytes}
    (hd : Decodes3 p input X W S B) (hf : p.Finite input) (row : Fin rows) :
    yOf C (v3 C) fuse steps X W S B row.val = p.forward input row := by
  obtain ⟨plat, weights⟩ := p
  change plat = _ at hp
  subst hp
  unfold AffineVerifyLinear.Projection3.forward Quantization.AffineRow.output
  apply yOf_eq (v3 C) (sites3 fuse) (fuse 15) _ fuse X W S B row.val _ (hf.reduction row)
  intro t L
  unfold qOf
  change qdot3 C fuse W (row.val * (64 * 3 * steps) + 2 * 3 * L.val + 64 * 3 * t.val) (xt3 C X (32 * t.val + L.val))
    (C.widen (bfAt S (row.val * (8 * steps) + 8 * t.val + L.val / 4)))
    (C.widen (bfAt B (row.val * (8 * steps) + 8 * t.val + L.val / 4))) (cs3 C X (32 * t.val + L.val)) = _
  rw [group_index, hd.scale, hd.bias]
  refine tile3_eq X W (32 * t.val + L.val) _ _ _ _ _ (fun j => ?_) (fun chunk b => ?_) (hf.tiles row t L)
  · rw [input_index]; exact hd.x _
  · rw [← hd.w row t L chunk b]
    congr 1
    unfold AffineLayout.weightOffset
    ring

end Projection3

/-! ## BITS = 4: one lane's tile

The model groups each halfword's four products as `((p₀ + p₁) + p₂) + p₃` with its sites 0, 1, 2 at the three
additions; the machine's sites are 12, 13, 14 (`sites4`). Fused, site 12 contracts `p₀ + p₁` (both products) into
`fma(x₀, F₀, x₁ * F₁)`, the model's `maddLeft`; sites 13, 14 contract into the running sum, the model's `madd`. -/

section Tile4
variable {C}

/-- `x * y + z` at contraction site `site` is the model's `maddLeft`. -/
theorem maddLeft_eq {fuse : Nat → Bool} {site : Nat} {c : Bool} (hs : fuse site = c)
    {input : Nat → Float32} {a b acc : Arithmetic.Expr} (hf : Arithmetic.Finite input (maddLeft c a b acc)) :
    (if fuse site then C.fma (evaluate input a) (evaluate input b) (evaluate input acc)
      else C.fadd (C.fmul (evaluate input a) (evaluate input b)) (evaluate input acc)) =
      evaluate input (maddLeft c a b acc) := by
  rw [hs]
  cases c
  · obtain ⟨⟨ha, hb, hm⟩, hacc, -⟩ := hf
    simp only [Bool.false_eq_true, ite_false, maddLeft, evaluate]
    rw [C.fmul_model _ _ (finite_evaluate _ _ ha) (finite_evaluate _ _ hb),
      C.fadd_model _ _ (FlushToZero.mul_finite _ _ hm) (finite_evaluate _ _ hacc)]
  · obtain ⟨ha, hb, hacc, -⟩ := hf
    simp only [ite_true, maddLeft, evaluate]
    rw [C.fma_model _ _ _ (finite_evaluate _ _ ha) (finite_evaluate _ _ hb) (finite_evaluate _ _ hacc)]

theorem maddLeft_acc_finite {input : Nat → Float32} {c : Bool} {a b acc : Arithmetic.Expr}
    (hf : Arithmetic.Finite input (maddLeft c a b acc)) : Arithmetic.Finite input acc := by
  cases c
  · exact hf.2.1
  · exact hf.2.2.1

/-- `x_thread[4 chunk + i]` of chunk `c` (BITS = 4) is the model's prepared input `prepared4`. -/
theorem xt4_eq (ctr : Nat → Bool) (tail : Bool) (X : ByteMemory.Bytes) (c : Nat) (xs : Fin 16 → BF)
    (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j) (hfin : ∀ j, Model.isFinite (xs j) = true)
    (chunk : Fin 4) (i : Fin 4) :
    xt4 C X c (4 * chunk.val + i.val) = AffineTile.prepared4 (C.tilePlatform ctr tail) xs chunk i := by
  have hj : (4 * chunk.val + i.val) % 4 = i.val := by omega
  have hidx : AffineInput.index4 chunk i = ⟨4 * chunk.val + i.val, by omega⟩ :=
    Fin.ext (by simp only [AffineInput.index4]; ring)
  have hx := hX ⟨4 * chunk.val + i.val, by omega⟩
  have hv := hfin ⟨4 * chunk.val + i.val, by omega⟩
  unfold xt4 AffineTile.prepared4 AffineInput.prepare
  rw [hj, hidx]
  simp only [xf, hx]
  fin_cases i
  · exact widen_eq C _ (BFloat16.widen_finite _ hv)
  · exact scale_eq C _ hv 0x3D800000 ⟨4, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x3B800000 ⟨8, by decide⟩ (by decide) (by decide) (by decide) (by rfl)
  · exact scale_eq C _ hv 0x39800000 ⟨12, by decide⟩ (by decide) (by decide) (by decide) (by rfl)

/-- Group `grp` of BITS = 4 as a left fold. -/
def g4 (grp : Fin 4) (k : Nat) : Fin 16 := AffineInput.index4 grp ⟨k % 4, Nat.mod_lt _ (by decide)⟩

theorem groups4_fold (grp : Fin 4) :
    AffineInput.groups4 grp = [1, 2, 3].foldl (fun s k => .add s (.input (g4 grp k))) (.input (g4 grp 0)) := rfl

/-- The chunk sum `load_vector` returns (BITS = 4) is the model's `summed`. -/
theorem cs4_eq (X : ByteMemory.Bytes) (c : Nat) (xs : Fin 16 → BF) (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j)
    (hg : ∀ i, AffineInput.Finite xs (AffineInput.groups4 i))
    (hsum : Arithmetic.Finite (AffineInput.bind (fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups4 i))))
      (AffineInput.sumExpression 4)) :
    cs4 C X c = AffineInput.summed xs AffineInput.groups4 := by
  have hG : ∀ (grp : Fin 4) (e : Nat), e = 16 * c + 4 * grp.val →
      bsum C X e [1, 2, 3] = AffineInput.evaluate xs (AffineInput.groups4 grp) := by
    intro grp e he
    have hX' : ∀ k < 4, bfAt X (e + k) = xs (g4 grp k) := by
      intro k hk
      rw [show e + k = 16 * c + (g4 grp k).val by simp only [g4, AffineInput.index4]; omega]
      exact hX _
    rw [groups4_fold grp]
    unfold bsum
    exact sum_fold (C := C) X xs e (g4 grp) 4 hX' _ _ _ (by decide)
      (by have h0 := hX' 0 (by decide); rw [Nat.add_zero] at h0; exact h0) (by rw [← groups4_fold]; exact hg grp)
  have hse : AffineInput.sumExpression 4 = .add (.add (.add (.add .zero (.input 0)) (.input 1)) (.input 2)) (.input 3) := rfl
  rw [hse] at hsum
  unfold cs4 AffineInput.summed
  rw [← AffineInput.sum_execution, hse, hG 0 _ (by simp), hG 1 _ (by simp), hG 2 _ (by simp), hG 3 _ (by simp),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 0))),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 1))),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 2))),
    widen_eq C _ (BFloat16.widen_finite _ (AffineInput.evaluate_finite _ _ (hg 3)))]
  have hb : ∀ i : Fin 4, BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups4 i)) =
      evaluate (AffineInput.bind fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups4 i))) (.input i.val) :=
    fun i => (AffineInput.bind_read (fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups4 i))) i).symm
  have h0 : zero = evaluate (AffineInput.bind fun i => BFloat16.widen (AffineInput.evaluate xs (AffineInput.groups4 i)))
      .zero := ofF32Bits_zero
  rw [h0, hb 0, hb 1, hb 2, hb 3]
  exact (congrArg₂ C.fadd (congrArg₂ C.fadd (congrArg₂ C.fadd (add_eq C hsum.1.1.1) rfl) rfl) rfl).trans
    ((congrArg₂ C.fadd (congrArg₂ C.fadd (add_eq C hsum.1.1) rfl) rfl).trans ((congrArg₂ C.fadd (add_eq C hsum.1) rfl).trans
      (add_eq C hsum)))

theorem bind4_low (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) (k : Fin 4) :
    AffineDot.bind4 w scaled acc k.val = scaled k := by
  simp [AffineDot.bind4, k.isLt]

theorem bind4_mask (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32) (k : Fin 4) :
    AffineDot.bind4 w scaled acc (4 + k.val) = AffineLift.value (w.toNat &&& (2 ^ 4 - 1) * 2 ^ (4 * k.val)) := by
  have hk := k.isLt
  have hM : 15 * 2 ^ (4 * k.val) < 65536 := by fin_cases k <;> decide
  simp only [AffineDot.bind4, show ¬4 + k.val < 4 by omega, show 4 + k.val < 8 by omega, dite_false, dite_true,
    AffineDot.mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hM,
    show 4 + k.val - 4 = k.val by omega]
  rfl

/-- One halfword of `qdot`'s bits-4 loop is the model's `AffineDot.source4` on the compiler's choices at sites 12,
13, 14 when its expression is finite. -/
theorem quad4_eq {fuse : Nat → Bool} (q : Nat) (w : BitVec 16) (hq : q = w.toNat) (x : Nat → Float32)
    (scaled : Fin 4 → Float32) (hx : ∀ k : Fin 4, x k.val = scaled k) (a acc : Float32) (ha : a = acc)
    (hf : Arithmetic.Finite (AffineDot.bind4 w scaled acc) (AffineDot.expression4 (sites4 fuse))) :
    quad4 C fuse q x a = AffineDot.source4 (sites4 fuse) w scaled acc := by
  rw [← AffineDot.execution4]
  unfold AffineDot.expression4 at hf ⊢
  have h13 := (madd_finite hf.2.1).2.2
  have h12 := (madd_finite h13).2.2
  unfold quad4 addMul mulAdd
  have hdk : ∀ k : Fin 4, deq C (q &&& (2 ^ 4 - 1) * 2 ^ (4 * k.val)) =
      evaluate (AffineDot.bind4 w scaled acc) (.input (4 + k.val)) := by
    intro k
    rw [hq, deq_mask C _ _ _ (le_refl _) (by have := k.isLt; omega)]
    exact (bind4_mask w scaled acc k).symm
  have e0 : x 0 = evaluate (AffineDot.bind4 w scaled acc) (.input 0) := (hx 0).trans (bind4_low w scaled acc 0).symm
  have e1 : x 1 = evaluate (AffineDot.bind4 w scaled acc) (.input 1) := (hx 1).trans (bind4_low w scaled acc 1).symm
  have e2 : x 2 = evaluate (AffineDot.bind4 w scaled acc) (.input 2) := (hx 2).trans (bind4_low w scaled acc 2).symm
  have e3 : x 3 = evaluate (AffineDot.bind4 w scaled acc) (.input 3) := (hx 3).trans (bind4_low w scaled acc 3).symm
  have d0 : deq C (q &&& 0x000f) = evaluate (AffineDot.bind4 w scaled acc) (.input 4) := hdk 0
  have d1 : deq C (q &&& 0x00f0) = evaluate (AffineDot.bind4 w scaled acc) (.input 5) := hdk 1
  have d2 : deq C (q &&& 0x0f00) = evaluate (AffineDot.bind4 w scaled acc) (.input 6) := hdk 2
  have d3 : deq C (q &&& 0xf000) = evaluate (AffineDot.bind4 w scaled acc) (.input 7) := hdk 3
  have ea : a = evaluate (AffineDot.bind4 w scaled acc) (.input 8) := by
    rw [ha]; show acc = AffineDot.bind4 w scaled acc 8; simp [AffineDot.bind4]
  rw [e0, e1, e2, e3, d0, d1, d2, d3, ea, mul_eq C (maddLeft_acc_finite h12),
    maddLeft_eq (C := C) (show fuse 12 = sites4 fuse 0 from rfl) h12, madd_eq C (show fuse 13 = sites4 fuse 1 from rfl) h13,
    madd_eq C (show fuse 14 = sites4 fuse 2 from rfl) hf.2.1]
  exact add_eq C hf

/-- **One lane's `qdot` (BITS = 4) is the model's tile value** `AffineTile.value4` on `C.tilePlatform` at the
compiler's choices (sites 12–14 as `sites4`, site 15 the tail), when the model's tile finiteness holds. -/
theorem tile4_eq {fuse : Nat → Bool} (X W : ByteMemory.Bytes) (c o : Nat) (xs : Fin 16 → BF)
    (ws : Fin 4 → BitVec 16) (sc bi : BF) (hX : ∀ j : Fin 16, bfAt X (16 * c + j.val) = xs j)
    (hW : ∀ chunk : Fin 4, word16 W (o + 2 * chunk.val) = (ws chunk).toNat)
    (hf : AffineTile.Finite4 (C.tilePlatform (sites4 fuse) (fuse 15)) xs ws sc bi) :
    qdot4 C fuse W o (xt4 C X c) (C.widen sc) (C.widen bi) (cs4 C X c) =
      AffineTile.value4 (C.tilePlatform (sites4 fuse) (fuse 15)) xs ws sc bi := by
  have hq : ∀ (chunk : Fin 4) (a acc : Float32), a = acc →
      AffineTile.valid4 (C.tilePlatform (sites4 fuse) (fuse 15)) xs ws chunk acc →
      quad4 C fuse (word16 W (o + 2 * chunk.val)) (fun k => xt4 C X c (4 * chunk.val + k)) a =
        AffineTile.step4 (C.tilePlatform (sites4 fuse) (fuse 15)) xs ws chunk acc :=
    fun chunk a acc ha hv => quad4_eq _ (ws chunk) (hW chunk) _ _
      (fun k => xt4_eq (C := C) (sites4 fuse) (fuse 15) X c xs hX hf.dot.input chunk k) a acc ha hv
  have harith := hf.dot.arithmetic
  rw [finRange4] at harith
  obtain ⟨v0, v1, v2, v3, -⟩ := harith
  have hacc : accum4 C fuse W o (xt4 C X c) 4 = AffineTile.dot4 (C.tilePlatform (sites4 fuse) (fuse 15)) xs ws := by
    show quad4 C fuse (word16 W (o + 2 * (3 : Fin 4).val)) (fun k => xt4 C X c (4 * (3 : Fin 4).val + k))
      (quad4 C fuse (word16 W (o + 2 * (2 : Fin 4).val)) (fun k => xt4 C X c (4 * (2 : Fin 4).val + k))
        (quad4 C fuse (word16 W (o + 2 * (1 : Fin 4).val)) (fun k => xt4 C X c (4 * (1 : Fin 4).val + k))
          (quad4 C fuse (word16 W (o + 2 * (0 : Fin 4).val)) (fun k => xt4 C X c (4 * (0 : Fin 4).val + k)) zero))) = _
    rw [hq 0 zero 0 ofF32Bits_zero v0, hq 1 _ _ rfl v1, hq 2 _ _ rfl v2, hq 3 _ _ rfl v3]
    unfold AffineTile.dot4
    rw [finRange4, List.foldl_cons, List.foldl_cons, List.foldl_cons, List.foldl_cons, List.foldl_nil]
  unfold qdot4 AffineTile.value4
  rw [hacc, cs4_eq (C := C) X c xs hX hf.groups hf.sum, C.widen_model _ hf.scaleFinite,
    C.widen_model _ hf.biasFinite]
  exact tail_eq (C := C) rfl sc bi _ _ hf.tail

end Tile4

/-! ## BITS = 4: the projection -/

/-- The buffers' elements are the model's input and row weights, read as `Host.Mlx.weights4` reads them. -/
structure Decodes4 {steps rows : Nat} (p : AffineVerifyLinear.Projection4 steps rows) (input : Fin (steps * 512) → BF)
    (X W S B : ByteMemory.Bytes) : Prop where
  x : ∀ i : Fin (steps * 512), bfAt X i.val = input i
  w : ∀ (row : Fin rows) (step : Fin steps) (lane : Fin 32) (chunk : Fin 4),
    word16 W (AffineLayout.weightOffset 4 row.val steps step.val lane.val (chunk.val * 2)) =
      ((p.weights row).words step lane chunk).toNat
  scale : ∀ (row : Fin rows) (g : Fin (steps * 8)), bfAt S (row.val * (steps * 8) + g.val) = (p.weights row).scale g
  bias : ∀ (row : Fin rows) (g : Fin (steps * 8)), bfAt B (row.val * (steps * 8) + g.val) = (p.weights row).bias g

section Projection4
variable {C}

/-- **Row `row` of the 4-bit kernel is the model's `Projection4.forward`** on `C.rowPlatformAt (sites4 fuse)
(fuse 15)`, the compiler's choices at sites 12–14 and 15, when the buffers decode to the model's input and weights and
`Projection4.Finite` holds. -/
theorem yOf4_eq {steps rows : Nat} (p : AffineVerifyLinear.Projection4 steps rows) (input : Fin (steps * 512) → BF)
    {fuse : Nat → Bool} (hp : p.platform = C.rowPlatformAt (sites4 fuse) (fuse 15)) {X W S B : ByteMemory.Bytes}
    (hd : Decodes4 p input X W S B) (hf : p.Finite input) (row : Fin rows) :
    yOf C (v4 C) fuse steps X W S B row.val = p.forward input row := by
  obtain ⟨plat, weights⟩ := p
  change plat = _ at hp
  subst hp
  unfold AffineVerifyLinear.Projection4.forward Quantization.AffineRow.output
  apply yOf_eq (v4 C) (sites4 fuse) (fuse 15) _ fuse X W S B row.val _ (hf.reduction row)
  intro t L
  unfold qOf
  change qdot4 C fuse W (row.val * (64 * 4 * steps) + 2 * 4 * L.val + 64 * 4 * t.val) (xt4 C X (32 * t.val + L.val))
    (C.widen (bfAt S (row.val * (8 * steps) + 8 * t.val + L.val / 4)))
    (C.widen (bfAt B (row.val * (8 * steps) + 8 * t.val + L.val / 4))) (cs4 C X (32 * t.val + L.val)) = _
  rw [group_index, hd.scale, hd.bias]
  refine tile4_eq X W (32 * t.val + L.val) _ _ _ _ _ (fun j => ?_) (fun chunk => ?_) (hf.tiles row t L)
  · rw [input_index]; exact hd.x _
  · rw [← hd.w row t L chunk]
    congr 1
    unfold AffineLayout.weightOffset
    ring

end Projection4

/-! ## The GPU runs the model -/

/-- The bytes of a bf16 vector of `rows` elements. -/
def rowBytes {rows : Nat} (f : Fin rows → BF) (b : Nat) : BitVec 8 :=
  if h : b < 2 * rows then (wordBytes 2 (Val.bf16Bits (f ⟨b / 2, by omega⟩))).getD (b % 2) 0 else 0

section Gpu
variable {C}

/-- **Under the GPU assumption, the 3-bit launch's output is the encoding of the model's `Projection3.forward`.** -/
theorem gpu_model3 (G : Gpu C) (text : List Char) (steps blocks : Nat)
    (hc : (frontend text).bind elaborate = some (core3 steps)) (hmax : 512 ≤ G.maxThreads text) (hst : 0 < steps)
    (hbk : 0 < blocks) (hW : 64 * blocks * (192 * steps) < 2 ^ 31) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (hax : 2 ∣ ax) (has : 2 ∣ as) (hab : 2 ∣ ab) (p : AffineVerifyLinear.Projection3 steps (4 * (blocks * 16)))
    (input : Fin (steps * 512) → BF) (hp : p.platform = C.rowPlatformAt (sites3 (G.fusion text)) (G.fusion text 15))
    (hd : Decodes3 p input X W S B) (hf : p.Finite input) :
    G.execute text (32, 16 * blocks, 1) (32, 16, 1)
        [⟨.device, 2 * (512 * steps), ax, X⟩, ⟨.device, 4 * (64 * blocks * (48 * steps)), aw, W⟩,
         ⟨.device, 2 * (64 * blocks * (8 * steps)), as, S⟩, ⟨.device, 2 * (64 * blocks * (8 * steps)), ab, B⟩]
        [2 * (64 * blocks)] = some [rowBytes (p.forward input)] := by
  rw [gpu_output3 C G text steps blocks hc hmax hst hbk hW X W S B ax aw as ab hax has hab]
  congr 2
  funext b
  unfold expected3 expectedOf rowBytes
  by_cases hb : b < 128 * blocks
  · rw [ite_eq_left hb, dite_eq_left (by omega)]
    rw [← yOf3_eq p input hp hd hf ⟨b / 2, by omega⟩]
  · rw [ite_eq_right hb, dite_eq_right (by omega)]

/-- **Under the GPU assumption, the 4-bit launch's output is the encoding of the model's `Projection4.forward`.** -/
theorem gpu_model4 (G : Gpu C) (text : List Char) (steps blocks : Nat)
    (hc : (frontend text).bind elaborate = some (core4 steps)) (hmax : 512 ≤ G.maxThreads text) (hst : 0 < steps)
    (hbk : 0 < blocks) (hW : 64 * blocks * (256 * steps) < 2 ^ 31) (X W S B : ByteMemory.Bytes) (ax aw as ab : Nat)
    (hax : 2 ∣ ax) (haw : 2 ∣ aw) (has : 2 ∣ as) (hab : 2 ∣ ab)
    (p : AffineVerifyLinear.Projection4 steps (4 * (blocks * 16))) (input : Fin (steps * 512) → BF)
    (hp : p.platform = C.rowPlatformAt (sites4 (G.fusion text)) (G.fusion text 15)) (hd : Decodes4 p input X W S B)
    (hf : p.Finite input) :
    G.execute text (32, 16 * blocks, 1) (32, 16, 1)
        [⟨.device, 2 * (512 * steps), ax, X⟩, ⟨.device, 4 * (64 * blocks * (64 * steps)), aw, W⟩,
         ⟨.device, 2 * (64 * blocks * (8 * steps)), as, S⟩, ⟨.device, 2 * (64 * blocks * (8 * steps)), ab, B⟩]
        [2 * (64 * blocks)] = some [rowBytes (p.forward input)] := by
  rw [gpu_output4 C G text steps blocks hc hmax hst hbk hW X W S B ax aw as ab hax haw has hab]
  congr 2
  funext b
  unfold expected4 expectedOf rowBytes
  by_cases hb : b < 128 * blocks
  · rw [ite_eq_left hb, dite_eq_left (by omega)]
    rw [← yOf4_eq p input hp hd hf ⟨b / 2, by omega⟩]
  · rw [ite_eq_right hb, dite_eq_right (by omega)]

end Gpu

/-! ## Values: the route's `Row`/`Affine3`/`Affine4` inputs -/

section Values
open Host.Mlx

theorem bfAt_storage (v : Value) (hv : v.dtype = .bfloat16) (i : Nat) : bfAt v.storageByte i = bf (v.elems i) := by
  unfold bfAt; rw [storage2 v hv, ofBf16Bits_mod]

theorem storage_byte (v : Value) (hv : v.dtype = .uint32) (b : Nat) : v.storageByte b = v.byte b := by
  unfold Value.storageByte Value.byte; rw [hv]; rfl

theorem storage_word16 (v : Value) (hv : v.dtype = .uint32) (b : Nat) (he : b % 2 = 0) :
    word16 v.storageByte b = (v.word16 b).toNat := by
  unfold word16 byteAt Value.word16
  rw [storage_byte v hv, storage_byte v hv]
  unfold Value.byte
  simp only [BitVec.toNat_ofNat]
  have h1 : (b + 1) / 4 = b / 4 := by omega
  rcases (by omega : b % 4 = 0 ∨ b % 4 = 2) with h | h
  · rw [h1, show (b + 1) % 4 = 1 by omega, h]; simp only [pow_zero, pow_one, Nat.div_one]; omega
  · rw [h1, show (b + 1) % 4 = 3 by omega, h]
    simp only [show (256 : Nat) ^ 2 = 65536 from rfl, show (256 : Nat) ^ 3 = 16777216 from rfl]
    omega

/-- Buffers holding the row-major bytes of values that `GlueKernels.affine_row3`'s hypotheses describe decode to the
model's input and weights. -/
theorem decodes3_of_values {steps rows : Nat} (p : AffineVerifyLinear.Projection3 steps rows) (input : Fin (steps * 512) → BF)
    (x w scales biases : Value) (hx : Row x (steps * 512) input) (hw : Affine3 p w scales biases) :
    Decodes3 p input x.storageByte w.storageByte scales.storageByte biases.storageByte where
  x i := by rw [bfAt_storage x hx.1]; exact hx.elems i
  w row step lane chunk b := by rw [storage_byte w hw.words.1, hw.weights row]; rfl
  scale row g := by rw [bfAt_storage scales hw.groups.1, hw.weights row]; rfl
  bias row g := by rw [bfAt_storage biases hw.groups.2.2.1, hw.weights row]; rfl

/-- The same for `GlueKernels.affine_row4`'s hypotheses. -/
theorem decodes4_of_values {steps rows : Nat} (p : AffineVerifyLinear.Projection4 steps rows) (input : Fin (steps * 512) → BF)
    (x w scales biases : Value) (hx : Row x (steps * 512) input) (hw : Affine4 p w scales biases) :
    Decodes4 p input x.storageByte w.storageByte scales.storageByte biases.storageByte where
  x i := by rw [bfAt_storage x hx.1]; exact hx.elems i
  w row step lane chunk := by
    rw [storage_word16 w hw.words.1 _ (by
      unfold AffineLayout.weightOffset
      have : row.val * (steps * 64 * 4) = 2 * (row.val * (steps * 128)) := by ring
      omega), hw.weights row]; rfl
  scale row g := by rw [bfAt_storage scales hw.groups.1, hw.weights row]; rfl
  bias row g := by rw [bfAt_storage biases hw.groups.2.2.1, hw.weights row]; rfl

end Values

end Metal.Bridge.AffineRow
