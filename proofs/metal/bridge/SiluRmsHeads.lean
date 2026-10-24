import metal.bridge.GatedRmsNorm
import metal.kernels.SiluRmsHeads
import host.mlx.GlueKernels

namespace Metal.Bridge.SiluRmsHeads
open Metal Metal.Core Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Inference.Kernels.Delta.SiluRmsHeads (ActivationFinite NormFinite)
open Inference.Kernels.Trellis
open Metal.Bridge.GatedRmsNorm (eps pre laneExpr_pre)

/-! # silu-rms-heads: the machine spec is the model's value

`Metal.Kernels.SiluRmsHeads.qOut`/`kOut`/`vOut` (the bytes `gpu_output` proves) against
`Inference.Layers.DeltaHeads.forward (C.headsPlatform contracted)` (the value `GlueKernels.silu_rms_heads`
consumes), element by element:

* inputs: channel `128 h + c` of `x` is the bf16 word at bytes `2 (128 h + c)`, `+1`, i.e. `values ⟨128 h + c⟩`
  of the `Row` value (`channel = 128 h` for every head, `row = 0`); `qscale[c]`/`kscale[c]` likewise;
* contraction: site 1 (`sum += activated * activated`) is the model's `contracted`, the only fusable site;
* the activation is all bf16 as in the model: `exp(abs(value))` is `C.narrow ∘ C.fastExp ∘ C.widen ∘ C.narrow ∘
  C.fastFabs ∘ C.widen` = `C.fastExpAbs` (`narrow_posInf` when `fast_exp` overflows), then `C.bfadd`, `C.bfdiv`
  (`bfadd_posInf`, `bfdiv_posInf` when the bf16 exponential is `+inf`), `C.bfsub`, `C.bfmul` = the
  `BFloat16Arithmetic` operations of `GateUpSplitTail.sigmoidValue` and `activate`; `value < T(0)` compares the
  widened words (flushed binary32) where the model compares the flushed bf16 words: the same sign test;
* the squared sum, the simd_sum and `sum / float(DK)` (as `sum * 2^-7`) are as in the gated RMS norm;
* `T(float(values[i]) * inv)` and `qscale[c] * normalized` are `C.narrow`/`C.bfmul` of the model. -/

variable (C : M1Max.Contract)

theorem eps_eq : eps = Inference.Kernels.Delta.SiluHeads128Output.epsilon := by decide

theorem bfAt_eq (B : ByteMemory.Bytes) (e : Nat) : bfAt B e = bfAt B e := rfl

theorem bfOne_eq : Kernels.SiluRmsHeads.bfOne = BFloat16Arithmetic.one := by decide
theorem widen_bfZero : BFloat16.widen Kernels.SiluRmsHeads.bfZero = (0 : Float32) := by decide
theorem flush_zero : FlushToZero.flush (0 : Float32) = 0 := by decide

/-- The flushed bf16 value of a finite word and the flushed binary32 value of its widening agree. -/
theorem flush_widen_real (v : BF) (hv : Model.isFinite v = true) :
    real (FlushToZero.flush (BFloat16.widen v)) = Model.toReal (BFloat16Arithmetic.flush v) := by
  have hw := BFloat16.widen_real v hv
  by_cases hs : |Model.toReal v| < FlushToZero.threshold
  · rw [FlushOrder.small_flush _ (BFloat16.widen_finite v hv) (by rw [hw]; exact hs)]
    rcases BFloat16Arithmetic.flush_normal v with h | h
    · rw [h]
    · exact absurd (h.trans (BFloat16Arithmetic.flush_abs_le v)) (not_le.mpr hs)
  · have hn := le_of_not_gt hs
    rw [FlushToZero.flush_eq_of_threshold_le _ (by rw [hw]; exact hn), hw,
      BFloat16Arithmetic.flush_eq_of_normal v (Or.inr hn)]

/-- `value < T(0)`, compared through widening, is the model's flushed bf16 sign test. -/
theorem isNeg_eq (v : BF) (hv : Model.isFinite v = true) :
    (Kernels.SiluRmsHeads.isNeg C v = true) ↔ GateUpSplitTail.negative v := by
  have hz : Model.isFinite Kernels.SiluRmsHeads.bfZero = true := by decide
  unfold Kernels.SiluRmsHeads.isNeg
  rw [C.widen_model _ hv, C.widen_model _ hz, widen_bfZero, decide_eq_true_iff]
  change Model.compare (model (FlushToZero.flush (BFloat16.widen v))) (model (FlushToZero.flush 0)) = some .lt ↔ _
  rw [flush_zero]
  change Inference.Kernels.StableSigmoid.negative (BFloat16.widen v) ↔ _
  rw [Inference.Kernels.StableSigmoid.negative_iff _ (BFloat16.widen_finite v hv), flush_widen_real v hv,
    GateUpSplitTail.negative_iff v hv]

theorem add_one_posInf :
    BFloat16Arithmetic.add BFloat16Arithmetic.one (Model.posInf FloatFormat.bfloat16) = Model.posInf FloatFormat.bfloat16 := by
  decide

/-- The core's `exp` stage, `T(fast_exp(float(·)))`, is the model's narrowing: a finite binary32 exponential by
`narrow_model`, an overflowed one by `narrow_posInf`. -/
theorem narrow_exp (y : Float32) (hy : y.isFinite = true) : C.narrow (C.fastExp y) = BFloat16.narrow (C.fastExp y) := by
  rcases C.fastExp_overflow y hy with he | he
  · exact C.narrow_model _ he
  · rw [he]; exact C.narrow_posInf

/-- `y = 1 / (1 + exp(abs(value)))` is the model's `sigY` (finite) on every finite `value`: a finite bf16
exponential by `bfadd_model`/`bfdiv_model`, `+inf` by `bfadd_posInf`/`bfdiv_posInf`. -/
theorem expTerm_eq (c : Bool) (v : BF) (hv : Model.isFinite v = true) :
    Kernels.SiluRmsHeads.expTerm C v = GateUpSplitTail.sigY (C.headsPlatform c).expAbs v ∧
      Model.isFinite (GateUpSplitTail.sigY (C.headsPlatform c).expAbs v) = true := by
  have hw := BFloat16.widen_finite v hv
  obtain ⟨haf, har⟩ := C.fastFabs_value _ hw
  have hn : Model.isFinite (BFloat16.narrow (C.fastFabs (BFloat16.widen v))) = true := by
    apply BFloat16ConversionBounds.narrow_finite _ haf
    rw [har, abs_abs, BFloat16.widen_real v hv]
    exact Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite v (by decide) hv
  unfold Kernels.SiluRmsHeads.expTerm
  rw [C.widen_model _ hv, C.narrow_model _ haf, C.widen_model _ hn, narrow_exp C _ (BFloat16.widen_finite _ hn), bfOne_eq]
  change C.bfdiv _ (C.bfadd _ ((C.headsPlatform c).expAbs v)) = _ ∧ _
  rcases C.fastExpAbs_exponential.result v hv with hE | hE
  · have hE : Model.isFinite ((C.headsPlatform c).expAbs v) = true := hE
    have hs := (Inference.Kernels.Trellis.SigmoidRanges.finite_branch _ _ (C.headsPlatform c).exponential v hv hE).1
    have hd := GateUpSplitTail.denominator_finite _ v hs
    have hge := GateUpSplitTail.denominator_ge_one _ _ (C.headsPlatform c).exponential v hs
    rw [C.bfadd_model _ _ BFloat16Arithmetic.finite_one hE]
    change C.bfdiv _ (GateUpSplitTail.denominator (C.headsPlatform c).expAbs v) = _ ∧ _
    rw [C.bfdiv_model _ _ BFloat16Arithmetic.finite_one hd (by
      rw [BFloat16Arithmetic.flush_eq_of_one_le _ hge]; linarith)]
    exact ⟨rfl, GateUpSplitTail.sigY_finite _ _ (C.headsPlatform c).exponential v hs⟩
  · have hinf : (C.headsPlatform c).expAbs v = Model.posInf FloatFormat.bfloat16 := hE
    rw [hinf, C.bfadd_posInf _ BFloat16Arithmetic.finite_one, add_one_posInf,
      C.bfdiv_posInf _ BFloat16Arithmetic.finite_one, GateUpSplitTail.sigY_of_exp_inf _ _ hinf]
    refine ⟨?_, by decide⟩
    rw [← GateUpSplitTail.sigY_of_exp_inf _ _ hinf]
    unfold GateUpSplitTail.sigY GateUpSplitTail.denominator
    rw [hinf, add_one_posInf]

/-- The core's `sigmoid` is the model's `sigmoidValue` on every finite `value`. -/
theorem sigmoid_eq (c : Bool) (v : BF) (hv : Model.isFinite v = true) :
    Kernels.SiluRmsHeads.sigmoid C v = GateUpSplitTail.sigmoidValue (C.headsPlatform c).expAbs v := by
  obtain ⟨hy, hyf⟩ := expTerm_eq C c v hv
  unfold Kernels.SiluRmsHeads.sigmoid GateUpSplitTail.sigmoidValue
  rw [hy]
  by_cases hn : GateUpSplitTail.negative v
  · rw [ite_eq_left ((isNeg_eq C v hv).mpr hn), ite_eq_left hn]
  · rw [ite_eq_right (fun h => hn ((isNeg_eq C v hv).mp h)), ite_eq_right hn, bfOne_eq,
      C.bfsub_model _ _ BFloat16Arithmetic.finite_one hyf]

/-- The head's input row of the model. -/
abbrev inp (values : Fin 10240 → BF) (head : Fin 80) : Fin 128 → BF :=
  Inference.Layers.DeltaHeads.slice (fun _ : Fin 1 => values) 0 head

/-- `values[i] = T(value * sigmoid)` at column `i` of head `head` is the model's activation. -/
theorem act_eq (c : Bool) (X : ByteMemory.Bytes) (values : Fin 10240 → BF)
    (hX : ∀ j : Fin 10240, bfAt X j.val = values j) (head : Fin 80) (i : Fin 128)
    (hv : Model.isFinite (inp values head i) = true) :
    Kernels.SiluRmsHeads.act C X head.val i.val =
      Inference.Kernels.Delta.SiluRmsHeads.activate (C.headsPlatform c) (inp values head i) := by
  have hb : bfAt X (128 * head.val + i.val) = inp values head i := by
    show _ = values (Inference.Layers.DeltaHeads.channel head i)
    rw [bfAt_eq, ← hX]
    congr 1
    simp only [Inference.Layers.DeltaHeads.channel]
    ring
  unfold Kernels.SiluRmsHeads.act
  rw [hb, sigmoid_eq C c _ hv, C.bfmul_model _ _ hv (Inference.Kernels.Trellis.SigmoidRanges.ranges _ _
    (C.headsPlatform c).exponential C.fastExpAbs_exponential _ hv).2.1]
  rfl

section Head
variable (fuse : Nat → Bool) (c : Bool) (X : ByteMemory.Bytes) (values : Fin 10240 → BF) (head : Fin 80)

/-- A lane's `sum` after `k ≤ 4` steps is its model expression's value on the activated row. -/
theorem laneSum_pre (hc : fuse 1 = c) (hX : ∀ j : Fin 10240, bfAt X j.val = values j)
    (hA : ∀ i, ActivationFinite (C.headsPlatform c) (inp values head i)) (lane : Fin 32) :
    ∀ k, k ≤ 4 → SquaredSum.Finite (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
        (pre c lane k) →
      Kernels.SiluRmsHeads.laneSum C fuse X head.val lane.val k =
        SquaredSum.evaluate (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
          (pre c lane k)
  | 0, _, _ => Metal.Bridge.GatedRmsNorm.zero_eq
  | k + 1, hk, hf => by
    have ih := laneSum_pre hc hX hA lane k (by omega) (finite_of_step hf)
    have hkk : k % 4 = k := Nat.mod_eq_of_lt (by omega)
    show (if fuse 1 then C.fma _ _ _ else C.fadd _ (C.fmul _ _)) = _
    rw [hc]
    apply step_eq C c _ _ _ _ _ _ ih hf
    have hi : (4 * lane.val + k) = (⟨lane.val * 4 + k % 4, by have := lane.isLt; omega⟩ : Fin 128).val := by
      simp only [hkk]; ring
    rw [hi, act_eq C c X values hX head _ (hA _).input,
      C.widen_model _ (Inference.Kernels.Delta.SiluRmsHeads.activate_finite _ _ (hA _))]
    rfl

/-- The head's `simd_sum` is the model's squared sum. -/
theorem headSum_eq (hc : fuse 1 = c) (hX : ∀ j : Fin 10240, bfAt X j.val = values j)
    (hA : ∀ i, ActivationFinite (C.headsPlatform c) (inp values head i))
    (hf : SquaredSum.Finite (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
      (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree)) :
    Kernels.SiluRmsHeads.headSum C fuse X head.val =
      SquaredSum.evaluate (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
        (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree) := by
  unfold Kernels.SiluRmsHeads.headSum
  rw [C.simdSum_tree.execution]
  change _ = SquaredSum.evaluate _ (SquaredSum.reduceTree (Inference.Kernels.Delta.SiluRmsHeads.laneExpr c) C.simdSum_tree.tree)
  rw [NormalizationReduction.evaluate_reduceTree]
  congr 1
  funext lane
  rw [laneExpr_pre]
  apply laneSum_pre C fuse c X values head hc hX hA lane 4 le_rfl
  rw [← laneExpr_pre]
  exact finite_of_leaf _ _ _ hf lane (C.simdSum_tree.coverage.mem_iff.mpr (List.mem_finRange lane))

/-- `T(float(values[i]) * inv)` and `scale[i] * normalized`: the model's normalized coordinate. -/
theorem scaled_eq (hc : fuse 1 = c) (hX : ∀ j : Fin 10240, bfAt X j.val = values j)
    (hA : ∀ i, ActivationFinite (C.headsPlatform c) (inp values head i)) (S : ByteMemory.Bytes) (scale : Fin 128 → BF)
    (hS : ∀ i : Fin 128, bfAt S i.val = scale i) (width : Float32)
    (hn : NormFinite (C.headsPlatform c) (inp values head) scale width eps) (i : Fin 128) :
    C.bfmul (bfAt S i.val) (Kernels.SiluRmsHeads.normalized C fuse X head.val i.val) =
      Inference.Kernels.Delta.SiluRmsHeads.normalized (C.headsPlatform c) (inp values head) scale width eps i := by
  have hf : NormalizationExecution.Finite C.fdiv (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
      scale (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree) width eps C.rsqrt := hn
  have hinv : Kernels.SiluRmsHeads.invRms C fuse X head.val = NormalizationExecution.normalizer C.fdiv
      (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
      (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree) width eps C.rsqrt := by
    unfold Kernels.SiluRmsHeads.invRms
    rw [headSum_eq C fuse c X values head hc hX hA hf.hSum]
    unfold NormalizationExecution.normalizer NormalizationExecution.denominator NormalizationExecution.mean
      NormalizationExecution.sum
    congr 1
    exact mean_eps C _ width eps (SquaredSum.finite_evaluate _ _ hf.hSum) hf.hWidth (by rw [hf.hWidthValue]; norm_num)
      hf.hEps (le_of_lt (lt_trans FlushToZero.threshold_pos hf.hNormalEps)) hf.hMean
      (NormalizationExecution.denominator_positive C.fdiv FlushToZero.divBudget C.division _ _ _ _ hf.toReductionFinite)
  have ha := Inference.Kernels.Delta.SiluRmsHeads.activate_finite _ _ (hA i)
  unfold Kernels.SiluRmsHeads.normalized
  rw [act_eq C c X values hX head i (hA i).input, hinv, C.widen_model _ ha,
    C.fmul_model _ _ (BFloat16.widen_finite _ ha) hf.hNormalizer]
  have hm : (FlushToZero.mul (BFloat16.widen (Inference.Kernels.Delta.SiluRmsHeads.activate (C.headsPlatform c)
      (inp values head i))) (NormalizationExecution.normalizer C.fdiv
        (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
        (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree) width eps C.rsqrt)).isFinite = true :=
    FlushToZero.mul_finite _ _ (hf.hNormalized i)
  rw [C.narrow_model _ hm, bfAt_eq, hS i]
  have hb : Model.isFinite (BFloat16.narrow (FlushToZero.mul (BFloat16.widen (Inference.Kernels.Delta.SiluRmsHeads.activate
      (C.headsPlatform c) (inp values head i))) (NormalizationExecution.normalizer C.fdiv
        (Inference.Kernels.Delta.SiluRmsHeads.activated (C.headsPlatform c) (inp values head))
        (Inference.Kernels.Delta.SiluRmsHeads.expression c C.simdSum_tree.tree) width eps C.rsqrt))) = true := hf.hNarrow i
  rw [C.bfmul_model _ _ (hf.hWeight i) hb]
  rfl

end Head

/-- The model's output of the launch (`GlueKernels.silu_rms_heads`' `out`, at width `width` and ε). -/
noncomputable abbrev out (c : Bool) (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) (width : Float32) :=
  Inference.Layers.DeltaHeads.forward (C.headsPlatform c) (fun _ : Fin 1 => values) qScale kScale width eps

/-- The hypotheses of the element bridges: inputs decoded from the bytes, the compiler's site-1 choice the
model's flag, and the model's `DeltaHeads.Finite`. -/
structure Hyp (fuse : Nat → Bool) (c : Bool) (X QS KS : ByteMemory.Bytes) (values : Fin 10240 → BF)
    (qScale kScale : Fin 128 → BF) (width : Float32) : Prop where
  site : fuse 1 = c
  x : ∀ j : Fin 10240, bfAt X j.val = values j
  q : ∀ i : Fin 128, bfAt QS i.val = qScale i
  k : ∀ i : Fin 128, bfAt KS i.val = kScale i
  finite : Inference.Layers.DeltaHeads.Finite (C.headsPlatform c) (fun _ : Fin 1 => values) qScale kScale width eps

section Elements
variable {C} {fuse : Nat → Bool} {c : Bool} {X QS KS : ByteMemory.Bytes} {values : Fin 10240 → BF}
  {qScale kScale : Fin 128 → BF} {width : Float32}

/-- **Element bridges.** Each element of `q`, `k` and `v` of the machine spec is the model's. -/
theorem qOut_eq (H : Hyp C fuse c X QS KS values qScale kScale width) (h : Fin 16) (i : Fin 128) :
    Kernels.SiluRmsHeads.qOut C fuse X QS (h.val * 128 + i.val) = (out C c values qScale kScale width).q 0 h i := by
  unfold Kernels.SiluRmsHeads.qOut
  rw [show (h.val * 128 + i.val) % 128 = i.val by omega, show (h.val * 128 + i.val) / 128 = h.val by omega]
  exact scaled_eq C fuse c X values (Inference.Layers.DeltaHeads.qHead h) H.site H.x (H.finite.activation 0 _) QS qScale H.q width (H.finite.qNorm 0 h) i

theorem kOut_eq (H : Hyp C fuse c X QS KS values qScale kScale width) (h : Fin 16) (i : Fin 128) :
    Kernels.SiluRmsHeads.kOut C fuse X KS (h.val * 128 + i.val) = (out C c values qScale kScale width).k 0 h i := by
  unfold Kernels.SiluRmsHeads.kOut
  rw [show (h.val * 128 + i.val) % 128 = i.val by omega, show (h.val * 128 + i.val) / 128 = h.val by omega]
  exact scaled_eq C fuse c X values (Inference.Layers.DeltaHeads.kHead h) H.site H.x (H.finite.activation 0 _) KS kScale H.k width (H.finite.kNorm 0 h) i

theorem vOut_eq (H : Hyp C fuse c X QS KS values qScale kScale width) (h : Fin 48) (i : Fin 128) :
    Kernels.SiluRmsHeads.vOut C X (h.val * 128 + i.val) = (out C c values qScale kScale width).v 0 h i := by
  unfold Kernels.SiluRmsHeads.vOut
  rw [show (h.val * 128 + i.val) % 128 = i.val by omega, show (h.val * 128 + i.val) / 128 = h.val by omega]
  exact act_eq C c X values H.x (Inference.Layers.DeltaHeads.vHead h) i (H.finite.activation 0 _ i).input

end Elements

/-- A bf16 [1, 1, heads, 128] output whose element `128 h + i` is `f h i`, read as the host's array. -/
theorem bytes_tensor (n heads : Nat) (hn : n = 2 * (heads * 128)) (g : Nat → BF) (f : Fin heads → Fin 128 → BF)
    (hg : ∀ h i, g (h.val * 128 + i.val) = f h i) :
    Host.Mlx.Tensor4 (Host.Mlx.halfArray (Kernels.SiluRmsHeads.bytesOf n g) 0 [1,1,heads,128]) 1 heads 128 (fun _ => f) := by
  apply Host.Mlx.GlueKernels.heads_tensor
  intro h i
  have hh := h.isLt
  have hi := i.isLt
  have e := (bfAt_eq_load (Kernels.SiluRmsHeads.bytesOf n g) (h.val * 128 + i.val)).symm
  have hb : bfAt (Kernels.SiluRmsHeads.bytesOf n g) (h.val * 128 + i.val) = f h i := by
    apply bfAt_of
    intro k hk
    have hlt : h.val * 128 + i.val < heads * 128 := by omega
    unfold Kernels.SiluRmsHeads.bytesOf
    rw [ite_eq_left (by omega), show (2 * (h.val * 128 + i.val) + k) / 2 = h.val * 128 + i.val by omega,
      show (2 * (h.val * 128 + i.val) + k) % 2 = k by omega, hg]
  simp only [Nat.zero_add]
  exact e.trans hb

/-- **Byte bridges.** The three output buffers of the machine spec, read as the host's bf16 arrays, are the
model's `q`, `k`, `v` in the `Tensor4` form `GlueKernels.silu_rms_heads` concludes. -/
theorem expected_tensors {fuse : Nat → Bool} {c : Bool} {X QS KS : ByteMemory.Bytes} {values : Fin 10240 → BF}
    {qScale kScale : Fin 128 → BF} {width : Float32} (H : Hyp C fuse c X QS KS values qScale kScale width) :
    Host.Mlx.Tensor4 (Host.Mlx.halfArray (Kernels.SiluRmsHeads.bytesOf 4096 (Kernels.SiluRmsHeads.qOut C fuse X QS)) 0
        [1,1,16,128]) 1 16 128 (fun _ => (out C c values qScale kScale width).q 0) ∧
      Host.Mlx.Tensor4 (Host.Mlx.halfArray (Kernels.SiluRmsHeads.bytesOf 4096 (Kernels.SiluRmsHeads.kOut C fuse X KS)) 0
        [1,1,16,128]) 1 16 128 (fun _ => (out C c values qScale kScale width).k 0) ∧
      Host.Mlx.Tensor4 (Host.Mlx.halfArray (Kernels.SiluRmsHeads.bytesOf 12288 (Kernels.SiluRmsHeads.vOut C X)) 0
        [1,1,48,128]) 1 48 128 (fun _ => (out C c values qScale kScale width).v 0) :=
  ⟨bytes_tensor 4096 16 rfl _ _ (qOut_eq H), bytes_tensor 4096 16 rfl _ _ (kOut_eq H),
    bytes_tensor 12288 48 rfl _ _ (vOut_eq H)⟩

/-- **End to end.** MLX's launch on the row-major storage of the `Row`/`Vector` inputs of
`GlueKernels.silu_rms_heads` returns buffers that, as the host's bf16 arrays, are the model's
`DeltaHeads.forward (C.headsPlatform contracted)`, when the compiler's site-1 choice is the model's flag. -/
theorem gpu_value (G : Gpu C) (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.siluRmsHeadsText)
    (xv qs ks : Host.Mlx.Value) (values : Fin 10240 → BF) (qScale kScale : Fin 128 → BF)
    (hxv : Host.Mlx.Row xv 10240 values) (hqs : Host.Mlx.GlueAttention.Vector qs 128 qScale)
    (hks : Host.Mlx.GlueAttention.Vector ks 128 kScale) (ax aq ak : Nat) (hax : 2 ∣ ax) (haq : 2 ∣ aq) (hak : 2 ∣ ak)
    (contracted : Bool) (hc : G.fusion Metal.Elab.Tests.siluRmsHeadsText 1 = contracted) (width : Float32)
    (hf : Inference.Layers.DeltaHeads.Finite (C.headsPlatform contracted) (fun _ : Fin 1 => values) qScale kScale width eps) :
    ∃ q k v, G.execute Metal.Elab.Tests.siluRmsHeadsText (2560, 1, 1) (32, 1, 1)
        [⟨.device, 20480, ax, xv.storageByte⟩, ⟨.device, 256, aq, qs.storageByte⟩, ⟨.device, 256, ak, ks.storageByte⟩]
        [4096, 4096, 12288] = some [q, k, v] ∧
      Host.Mlx.Tensor4 (Host.Mlx.halfArray q 0 [1,1,16,128]) 1 16 128 (fun _ => (out C contracted values qScale kScale width).q 0) ∧
      Host.Mlx.Tensor4 (Host.Mlx.halfArray k 0 [1,1,16,128]) 1 16 128 (fun _ => (out C contracted values qScale kScale width).k 0) ∧
      Host.Mlx.Tensor4 (Host.Mlx.halfArray v 0 [1,1,48,128]) 1 48 128 (fun _ => (out C contracted values qScale kScale width).v 0) := by
  have H : Hyp C (G.fusion Metal.Elab.Tests.siluRmsHeadsText) contracted xv.storageByte qs.storageByte ks.storageByte
      values qScale kScale width :=
    ⟨hc, fun j => by rw [bfAt_storage _ hxv.1]; exact Host.Mlx.Row.elems hxv j,
      fun i => by rw [bfAt_storage _ hqs.1]; exact hqs.2.2 i, fun i => by rw [bfAt_storage _ hks.1]; exact hks.2.2 i,
      hf⟩
  exact ⟨_, _, _, Kernels.SiluRmsHeads.gpu_output C G hmax _ _ _ ax aq ak hax haq hak, expected_tensors C H⟩

end Metal.Bridge.SiluRmsHeads
