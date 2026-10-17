import kernels.sampling.LogSumExpExponentRanges
import kernels.sampling.LogSumExpAccumulator
import contracts.mlx.Maximum

namespace Inference.Kernels.Sampling.LogSumExpBlockRanges
open Contracts.Mlx Contracts.Mlx.Numerics Attention.SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure State where
  maximum : Float32
  normalizer : Float32

def initial : State := ⟨Attention.SdpaVector.initialShift, 0⟩
def nextMaximum (s : State) (values : Fin 4 → Float32) : Float32 :=
  Maximum.fold (List.ofFn values) s.maximum
def terms (p : Platform) (values : Fin 4 → Float32) (maximum : Float32) : Fin 4 → Float32 :=
  fun i => exponential p (values i) maximum
def update (p : Platform) (s : State) (maximum : Float32) (values : Fin 4 → Float32) : State :=
  ⟨maximum, LogSumExpAccumulator.update p.sumContracted s.normalizer
    (exponential p s.maximum maximum) (terms p values maximum)⟩
def validStep (p : Platform) (s : State) (values : Fin 4 → Float32) : State :=
  update p s (nextMaximum s values) values
-- In the all-padding block, each comparison with -infinity leaves the
-- finite maximum unchanged. The four exponential operations remain present.
def paddingStep (p : Platform) (s : State) : State :=
  update p s s.maximum (fun _ => LogSumExpExponentRanges.negativeInfinity)

theorem maximum_padding (x : Float32) (hx : x.isFinite = true) :
    Maximum.value x LogSumExpExponentRanges.negativeInfinity = x := by
  have hf : Model.isFinite (model (FlushToZero.flush x)) = true := by
    rw [finite_model]; exact FlushToZero.finite_flush x hx
  have hn := Model.isNaN_eq_false_of_isFinite_eq_true (model (FlushToZero.flush x)) hf
  have hi := Model.isInf_eq_false_of_isFinite_eq_true (model (FlushToZero.flush x)) hf
  have pn : Model.isNaN (model LogSumExpExponentRanges.negativeInfinity) = false := by decide +kernel
  have pi : Model.isInf (model LogSumExpExponentRanges.negativeInfinity) = true := by decide +kernel
  have ps : Model.signBit (model LogSumExpExponentRanges.negativeInfinity) = true := by decide +kernel
  simp only [Maximum.value, Maximum.less, LogSumExpExponentRanges.negative_infinity_flush, Model.compare, hn, pn,
    Bool.or_self, Bool.false_eq_true, dite_false, Model.compareNonNaN, hi, pi, ps, dite_true, ite_true,
    Option.some.injEq, reduceCtorEq, ite_false, beq_iff_eq]

theorem fold_padding (x : Float32) (hx : x.isFinite = true) (count : Nat) :
    Maximum.fold (List.replicate count LogSumExpExponentRanges.negativeInfinity) x = x := by
  induction count with
  | zero => rfl
  | succ count ih => simpa only [Maximum.fold, List.replicate_succ, List.foldl_cons, maximum_padding x hx] using ih

theorem padding_execution (p : Platform) (s : State) (hs : s.maximum.isFinite = true) :
    validStep p s (fun _ => LogSumExpExponentRanges.negativeInfinity) = paddingStep p s := by
  unfold validStep nextMaximum paddingStep
  rw [List.ofFn_const, fold_padding s.maximum hs]

structure Bounds (s : State) (count : Nat) : Prop where
  maximumFinite : s.maximum.isFinite = true
  maximumBound : |real s.maximum| ≤ (2 : ℝ)^(23 : Nat)
  normalizerFinite : s.normalizer.isFinite = true
  lower : 1 ≤ real s.normalizer
  upper : real s.normalizer ≤ count

structure Finite (p : Platform) (s : State) (maximum : Float32) (values : Fin 4 → Float32) : Prop where
  factor : ExponentFinite p s.maximum maximum
  termsFinite : ∀ i, (terms p values maximum i).isFinite = true
  arithmetic : Arithmetic.Finite
    (LogSumExpAccumulator.bind s.normalizer (exponential p s.maximum maximum) (terms p values maximum))
    (LogSumExpAccumulator.expression p.sumContracted)

private theorem sentinel_lt (x : Float32) (bound : |real x| ≤ (2 : ℝ)^(23 : Nat)) :
    real (FlushToZero.flush Attention.SdpaVector.initialShift) < real (FlushToZero.flush x) := by
  rw [Attention.SdpaExponentRanges.initial_flush, Attention.SdpaExponentRanges.initial_real,
    Float32OverflowMargin.maximum_value]
  have h := (abs_le.mp ((FlushToZero.flush_abs_le x).trans bound)).1
  norm_num at h ⊢
  linarith

theorem valid (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (s : State) (values : Fin 4 → Float32) (count : Nat) (size : count+4 < 16777216)
    (sf : s.maximum.isFinite = true)
    (sn : s.normalizer.isFinite = true ∧ 0 ≤ real s.normalizer ∧ real s.normalizer ≤ count)
    (state : (s.maximum = Attention.SdpaVector.initialShift ∧ real s.normalizer = 0) ∨
      (|real s.maximum| ≤ (2 : ℝ)^(23 : Nat) ∧ 1 ≤ real s.normalizer))
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Finite p s (nextMaximum s values) values ∧ Bounds (validStep p s values) (count+4) := by
  let maximum := nextMaximum s values
  have valueMem (i : Fin 4) : values i ∈ List.ofFn values := List.mem_ofFn.mpr ⟨i, rfl⟩
  have vf : ∀ x ∈ List.ofFn values, x.isFinite = true ∧ |real x| ≤ (2 : ℝ)^(23 : Nat) := by
    intro x hx
    obtain ⟨i, rfl⟩ := List.mem_ofFn.mp hx
    exact hv i
  have mf : maximum.isFinite = true := Maximum.fold_finite _ _ sf (fun x hx => (vf x hx).1)
  have order := Maximum.fold_dominates (List.ofFn values) s.maximum sf (fun x hx => (vf x hx).1)
  have mb : |real maximum| ≤ (2 : ℝ)^(23 : Nat) := by
    rcases state with hs | hs
    · apply Maximum.fold_bound_after_value _ _ _ sf vf
      exact ⟨values 0, valueMem 0, by rw [hs.1]; exact sentinel_lt _ (hv 0).2⟩
    · rcases Maximum.fold_selected (List.ofFn values) s.maximum with old | fresh
      · change |real (Maximum.fold (List.ofFn values) s.maximum)| ≤ _
        rw [old]
        exact hs.1
      · exact (vf _ fresh).2
  have mb24 : |real maximum| ≤ (2 : ℝ)^(24 : Nat) := mb.trans (by norm_num)
  have factor : ExponentFinite p s.maximum maximum ∧
      0 ≤ real (exponential p s.maximum maximum) ∧ real (exponential p s.maximum maximum) ≤ 1 := by
    rcases state with hs | hs
    · rw [hs.1]
      exact Attention.SdpaExponentRanges.initial p primitive maximum mf mb24
    · exact LogSumExpExponentRanges.ordered_flushed p primitive _ _ sf mf
        (hs.1.trans (by norm_num)) mb24 order.1
  have exps (i : Fin 4) := LogSumExpExponentRanges.ordered_flushed p primitive (values i) maximum (hv i).1 mf
    ((hv i).2.trans (by norm_num)) mb24 (order.2 (values i) (valueMem i))
  have witness : (1 ≤ real s.normalizer ∧ real (exponential p s.maximum maximum) = 1) ∨
      ∃ i, 1 ≤ real (terms p values maximum i) := by
    rcases Maximum.fold_selected (List.ofFn values) s.maximum with old | fresh
    · have eq : maximum = s.maximum := old
      rcases state with hs | hs
      · have h := order.2 (values 0) (valueMem 0)
        change real (FlushToZero.flush (values 0)) ≤ real (FlushToZero.flush maximum) at h

        rw [eq, hs.1] at h
        exact False.elim (not_le_of_gt (sentinel_lt _ (hv 0).2) h)
      · exact Or.inl ⟨hs.2, by rw [eq]; exact (Attention.SdpaExponentRanges.diagonal p primitive _ sf).2⟩
    · obtain ⟨i, hi⟩ := List.mem_ofFn.mp fresh
      have eq : values i = maximum := hi
      refine Or.inr ⟨i, ?_⟩
      change 1 ≤ real (exponential p (values i) maximum)
      rw [eq, (Attention.SdpaExponentRanges.diagonal p primitive _ mf).2]
  have hr := LogSumExpAccumulator.ranges count size p.sumContracted s.normalizer
    (exponential p s.maximum maximum) (terms p values maximum) sn
    ⟨factor.1.exponential, factor.2⟩ (fun i => ⟨(exps i).1.exponential, (exps i).2⟩)
  exact ⟨⟨factor.1, fun i => (exps i).1.exponential, hr.1⟩,
    ⟨mf, mb, hr.2.1, hr.2.2.2.2 witness, by
      simpa only [Nat.cast_add, Nat.cast_ofNat, validStep, update, maximum] using hr.2.2.2.1⟩⟩

theorem first (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (values : Fin 4 → Float32)
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Finite p initial (nextMaximum initial values) values ∧ Bounds (validStep p initial values) 4 := by
  exact valid p primitive initial values 0 (by decide) Attention.SdpaVector.initial_finite
    ⟨by decide, by rw [initial, FlushedIdentities.zero_real]; norm_num⟩
    (Or.inl ⟨rfl, FlushedIdentities.zero_real⟩) hv

theorem next (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (s : State) (count : Nat) (size : count+4 < 16777216) (hs : Bounds s count)
    (values : Fin 4 → Float32)
    (hv : ∀ i, (values i).isFinite = true ∧ |real (values i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Finite p s (nextMaximum s values) values ∧ Bounds (validStep p s values) (count+4) :=
  valid p primitive s values count size hs.maximumFinite
    ⟨hs.normalizerFinite, by linarith [hs.lower], hs.upper⟩ (Or.inr ⟨hs.maximumBound, hs.lower⟩) hv

theorem padding (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (paddingPrimitive : LogSumExpExponentRanges.PaddingPrimitive p)
    (s : State) (count : Nat) (size : count+4 < 16777216) (hs : Bounds s count) :
    Finite p s s.maximum (fun _ => LogSumExpExponentRanges.negativeInfinity) ∧
      Bounds (paddingStep p s) (count+4) := by
  have factor := Attention.SdpaExponentRanges.diagonal p primitive s.maximum hs.maximumFinite
  have term := LogSumExpExponentRanges.padding p paddingPrimitive s.maximum hs.maximumFinite
  have hr := LogSumExpAccumulator.ranges count size p.sumContracted s.normalizer
    (exponential p s.maximum s.maximum) (terms p (fun _ => LogSumExpExponentRanges.negativeInfinity) s.maximum)
    ⟨hs.normalizerFinite, by linarith [hs.lower], hs.upper⟩
    ⟨factor.1.exponential, by rw [factor.2]; norm_num⟩
    (fun _ => ⟨term.1, by
      change 0 ≤ real (exponential p LogSumExpExponentRanges.negativeInfinity s.maximum) ∧
        real (exponential p LogSumExpExponentRanges.negativeInfinity s.maximum) ≤ 1
      rw [term.2]
      norm_num⟩)
  exact ⟨⟨factor.1, fun _ => term.1, hr.1⟩,
    ⟨hs.maximumFinite, hs.maximumBound, hr.2.1, hr.2.2.2.2 (Or.inl ⟨hs.lower, factor.2⟩),
      by simpa only [Nat.cast_add, Nat.cast_ofNat, paddingStep, update] using hr.2.2.2.1⟩⟩

end Inference.Kernels.Sampling.LogSumExpBlockRanges
