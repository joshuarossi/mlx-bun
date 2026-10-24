import metal.kernels.GatedDeltaStep
import metal.bridge.General
import kernels.delta.GatedDevice

namespace Metal.Bridge.GatedDeltaStep
open Metal Metal.Core Metal.Kernels.GatedDeltaStep
open Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics Inference.Contracts.Mlx.ArithmeticFold
open Inference.Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Arithmetic (evaluate finite_evaluate)
open Metal.Bridge.General

/-! # gated_delta_step: the machine spec is the model

`Metal.Kernels.GatedDeltaStep.gpu_output` states the launch's outputs with the M1 Max operations and the
compiler's contraction choice `fuse`; `Delta.GatedDevice.producedOutput`/`producedState` (the values
`Host.Mlx.GlueKernels.gated_delta_step` consumes) state them with the flush-to-zero models and the flags
`Delta.Gated.Contraction`. The correspondence:

* inputs: `bfAt`/`f32At` of the buffers at the row-major element indices are the model's `values` and
  `initial` (`Decodes`); key head `hk_idx = hv_idx / 3` is `Layout.keyHead`;
* contraction sites: 1 (`kv_mem += state[i] * k_[s_idx]`) is `flags.prediction`, 3
  (`state[i] + k_[s_idx] * delta`) is `flags.update`, 4 (`out += state[i] * q_[s_idx]`) is `flags.output`
  (`Fuses`); the model has one flag per site, so every choice is expressible;
* operations: the model's expressions `Gated.decayedExpr`, `predictionExpr`, `deltaExpr`, `stateExpr`,
  `outputExpr` are the source's operations in the same order, `v - kv_mem` being `Arithmetic.sub`
  (the machine's `C.fadd v (f32Neg kv_mem)`, `fadd_f32Neg`), the lanes' four-term folds and the
  `simd_sum` tree the same;
* finiteness: `Arithmetic.Finite` of `outputExpr` on the row's operands, exactly what
  `GatedRanges.initial_ranges` and `GatedRecurrentRanges.ranges` prove (their `.2.1`), covers every
  operation of both outputs; for `state_out` alone `stateExpr` (their `.1`) suffices. -/

variable (C : M1Max.Contract)

/-- The compiler's choices at the three contraction sites are the model's flags. -/
structure Fuses (fuse : Nat → Bool) (flags : Gated.Contraction) : Prop where
  prediction : fuse 1 = flags.prediction
  update : fuse 3 = flags.update
  output : fuse 4 = flags.output

/-- The input buffers' elements are the model's inputs. -/
structure Decodes (I : Ins) (initial : GatedDevice.State) (values : GatedInputs.Values) : Prop where
  state : ∀ (h : Fin 48) (r c : Fin 128), stateIn I h.val r.val c.val = initial h r c
  key : ∀ (h : Fin 16) (c : Fin 128), bfAt I.k (h.val * 128 + c.val) = values.key h c
  query : ∀ (h : Fin 16) (c : Fin 128), bfAt I.q (h.val * 128 + c.val) = values.query h c
  value : ∀ (h : Fin 48) (c : Fin 128), bfAt I.v (h.val * 128 + c.val) = values.value h c
  decay : ∀ h : Fin 48, f32At I.g h.val = values.decay h
  beta : ∀ h : Fin 48, bfAt I.beta h.val = values.beta h

/-- Row `r` of head `h`: the model's operands (`Recurrence.bind`). -/
def row (initial : GatedDevice.State) (values : GatedInputs.Values) (h : Fin 48) (r : Fin 128) : Nat → Float32 :=
  Recurrence.bind (initial h r) (values.inputs h r)

/-- The `simd_sum` tree of the contract. -/
abbrev tree : Reduction.Tree 32 := C.simdSum_tree.tree

/-! ## A lane's four-term fold -/

section Lane
variable {C}

/-- A machine lane fold `part (j + 1) = part j + A j * B j` at a site whose choice is `c` is the model's
`Gated.laneExpr c a b d` when the latter is finite. -/
theorem lane_eq {fuse : Nat → Bool} {site : Nat} {c : Bool} (hs : fuse site = c) {input : Nat → Float32}
    {a b : Fin 128 → Arithmetic.Expr} (d : Fin 32) (A B part : Nat → Float32) (h0 : part 0 = Val.ofF32Bits 0)
    (hstep : ∀ j, part (j + 1) =
      if fuse site then C.fma (A j) (B j) (part j) else C.fadd (part j) (C.fmul (A j) (B j)))
    (hA : ∀ j (hj : j < 4), Arithmetic.Finite input (a (Gated.laneIndex d ⟨j, hj⟩)) →
      A j = evaluate input (a (Gated.laneIndex d ⟨j, hj⟩)))
    (hB : ∀ j (hj : j < 4), Arithmetic.Finite input (b (Gated.laneIndex d ⟨j, hj⟩)) →
      B j = evaluate input (b (Gated.laneIndex d ⟨j, hj⟩)))
    (hf : Arithmetic.Finite input (Gated.laneExpr c a b d)) :
    part 4 = evaluate input (Gated.laneExpr c a b d) := by
  unfold Gated.laneExpr at hf ⊢
  rw [finRange4] at hf ⊢
  simp only [List.foldl] at hf ⊢
  have step : ∀ (j : Nat) (hj : j < 4) (acc : Arithmetic.Expr), part j = evaluate input acc →
      Arithmetic.Finite input (madd c (a (Gated.laneIndex d ⟨j, hj⟩)) (b (Gated.laneIndex d ⟨j, hj⟩)) acc) →
      part (j + 1) = evaluate input (madd c (a (Gated.laneIndex d ⟨j, hj⟩)) (b (Gated.laneIndex d ⟨j, hj⟩)) acc) := by
    intro j hj acc hp hm
    obtain ⟨ha, hb, -⟩ := madd_finite hm
    rw [hstep j, hA j hj ha, hB j hj hb, hp]
    exact madd_eq C hs hm
  obtain ⟨-, -, f2⟩ := madd_finite hf
  obtain ⟨-, -, f1⟩ := madd_finite f2
  obtain ⟨-, -, f0⟩ := madd_finite f1
  exact step 3 (by decide) _ (step 2 (by decide) _ (step 1 (by decide) _
    (step 0 (by decide) _ (h0.trans ofF32Bits_zero) f0) f1) f2) hf

theorem laneIndex_val (d : Fin 32) (j : Nat) (hj : j < 4) : (Gated.laneIndex d ⟨j, hj⟩).val = 4 * d.val + j := by
  simp only [Gated.laneIndex]; omega

end Lane

/-! ## The operands -/

section Operands
variable {C} {I : Ins} {initial : GatedDevice.State} {values : GatedInputs.Values}

theorem state_eq (hd : Decodes I initial values) (h : Fin 48) (r c : Fin 128) :
    stateIn I h.val r.val c.val = evaluate (row initial values h r) (.input c.val) := by
  rw [hd.state]; exact (Recurrence.bind_state (initial h r) (values.inputs h r) c).symm

theorem decay_eq (hd : Decodes I initial values) (h : Fin 48) (r : Fin 128) :
    f32At I.g h.val = evaluate (row initial values h r) (.input 385) := by
  rw [hd.decay]; exact (Recurrence.bind_decay (initial h r) (values.inputs h r)).symm

theorem keyHead_index (h : Fin 48) (c : Fin 128) : h.val / 3 * 128 + c.val = (Layout.keyHead h).val * 128 + c.val := rfl

theorem keyAt_eq (hd : Decodes I initial values) (h : Fin 48) (r c : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (.input (128 + c.val))) :
    keyAt C I h.val c.val = evaluate (row initial values h r) (.input (128 + c.val)) := by
  have hv : row initial values h r (128 + c.val) = BFloat16.widen (values.key (Layout.keyHead h) c) :=
    Recurrence.bind_key (initial h r) (values.inputs h r) c
  change (row initial values h r (128 + c.val)).isFinite = true at hf
  change _ = row initial values h r (128 + c.val)
  rw [hv] at hf ⊢
  rw [keyAt, keyHead_index, hd.key]
  exact widen_eq C _ hf

theorem queryAt_eq (hd : Decodes I initial values) (h : Fin 48) (r c : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (.input (256 + c.val))) :
    queryAt C I h.val c.val = evaluate (row initial values h r) (.input (256 + c.val)) := by
  have hv : row initial values h r (256 + c.val) = BFloat16.widen (values.query (Layout.keyHead h) c) :=
    Recurrence.bind_query (initial h r) (values.inputs h r) c
  change (row initial values h r (256 + c.val)).isFinite = true at hf
  change _ = row initial values h r (256 + c.val)
  rw [hv] at hf ⊢
  rw [queryAt, keyHead_index, hd.query]
  exact widen_eq C _ hf

theorem value_eq (hd : Decodes I initial values) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (.input 384)) :
    C.widen (bfAt I.v (h.val * 128 + r.val)) = evaluate (row initial values h r) (.input 384) := by
  have hv : row initial values h r 384 = BFloat16.widen (values.value h r) :=
    Recurrence.bind_value (initial h r) (values.inputs h r)
  change (row initial values h r 384).isFinite = true at hf
  change _ = row initial values h r 384
  rw [hv] at hf ⊢
  rw [hd.value]
  exact widen_eq C _ hf

theorem beta_eq (hd : Decodes I initial values) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (.input 386)) :
    C.widen (bfAt I.beta h.val) = evaluate (row initial values h r) (.input 386) := by
  have hv : row initial values h r 386 = BFloat16.widen (values.beta h) :=
    Recurrence.bind_beta (initial h r) (values.inputs h r)
  change (row initial values h r 386).isFinite = true at hf
  change _ = row initial values h r 386
  rw [hv] at hf ⊢
  rw [hd.beta]
  exact widen_eq C _ hf

end Operands

/-! ## The source's quantities -/

section Values
variable {C} {fuse : Nat → Bool} {flags : Gated.Contraction} {I : Ins} {initial : GatedDevice.State}
  {values : GatedInputs.Values}

theorem decayed_eq (hd : Decodes I initial values) (h : Fin 48) (r c : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.decayedExpr c)) :
    decayed C I h.val r.val c.val = evaluate (row initial values h r) (Gated.decayedExpr c) := by
  rw [decayed, state_eq hd, decay_eq hd h r]
  exact mul_eq C hf

/-! The `simd_sum` quantities, along the tree of any reduction contract `R` of `C.simdSum` (the model's
recurrence platform certifies its own contract), then along the contract's own (`C.simdSum_tree`). -/

section Tree
variable (R : FlushedReduction.SimdContract C.simdSum)

theorem kvMem_tree (hd : Decodes I initial values) (hs : fuse 1 = flags.prediction) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.predictionExpr flags R.tree)) :
    kvMem C fuse I h.val r.val = evaluate (row initial values h r) (Gated.predictionExpr flags R.tree) := by
  apply simdSum_tree R
  intro d
  refine lane_eq hs d (fun j => decayed C I h.val r.val (4 * d.val + j)) (fun j => keyAt C I h.val (4 * d.val + j))
    (kvPart C fuse I h.val r.val d.val) rfl (fun j => rfl) (fun j hj ha => ?_) (fun j hj hb => ?_)
    (lanes_finite R.coverage hf d)
  · have := decayed_eq (C := C) hd h r _ ha
    rwa [laneIndex_val] at this
  · have := keyAt_eq (C := C) hd h r _ hb
    rw [laneIndex_val] at this ⊢; exact this

theorem delta_tree (hd : Decodes I initial values) (hs : fuse 1 = flags.prediction) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.deltaExpr flags R.tree)) :
    delta C fuse I h.val r.val = evaluate (row initial values h r) (Gated.deltaExpr flags R.tree) := by
  have hsub := hf.1
  rw [delta, value_eq hd h r hsub.1, kvMem_tree R hd hs h r hsub.2.1, beta_eq hd h r hf.2.1, sub_eq C hsub]
  exact mul_eq C hf

theorem updated_tree (hd : Decodes I initial values) (hs1 : fuse 1 = flags.prediction) (hs3 : fuse 3 = flags.update)
    (h : Fin 48) (r c : Fin 128) (hf : Arithmetic.Finite (row initial values h r) (Gated.stateExpr flags R.tree c)) :
    updated C fuse I h.val r.val c.val = evaluate (row initial values h r) (Gated.stateExpr flags R.tree c) := by
  obtain ⟨hk, hδ, hdec⟩ := madd_finite hf
  rw [updated, keyAt_eq hd h r c hk, delta_tree R hd hs1 h r hδ, decayed_eq hd h r c hdec]
  exact madd_eq C hs3 hf

theorem outSum_tree (hd : Decodes I initial values) (hs : Fuses fuse flags) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags R.tree)) :
    outSum C fuse I h.val r.val = evaluate (row initial values h r) (Gated.outputExpr flags R.tree) := by
  apply simdSum_tree R
  intro d
  refine lane_eq hs.output d (fun j => updated C fuse I h.val r.val (4 * d.val + j))
    (fun j => queryAt C I h.val (4 * d.val + j)) (outPart C fuse I h.val r.val d.val) rfl (fun j => rfl)
    (fun j hj ha => ?_) (fun j hj hb => ?_) (lanes_finite R.coverage hf d)
  · have := updated_tree R hd hs.prediction hs.update h r _ ha
    rwa [laneIndex_val] at this
  · have := queryAt_eq (C := C) hd h r _ hb
    rw [laneIndex_val] at this ⊢; exact this

/-- Every state expression of a row is finite when its output expression is. -/
theorem state_finite_tree {input : Nat → Float32} (hf : Arithmetic.Finite input (Gated.outputExpr flags R.tree))
    (c : Fin 128) : Arithmetic.Finite input (Gated.stateExpr flags R.tree c) := by
  have hl := lanes_finite R.coverage hf ⟨c.val / 4, by omega⟩
  unfold Gated.laneExpr at hl
  rw [finRange4] at hl
  simp only [List.foldl] at hl
  obtain ⟨a3, -, f2⟩ := madd_finite hl
  obtain ⟨a2, -, f1⟩ := madd_finite f2
  obtain ⟨a1, -, f0⟩ := madd_finite f1
  obtain ⟨a0, -, -⟩ := madd_finite f0
  have hc : c = Gated.laneIndex ⟨c.val / 4, by omega⟩ ⟨c.val % 4, by omega⟩ := Fin.ext (by simp [Gated.laneIndex]; omega)
  have : c.val % 4 = 0 ∨ c.val % 4 = 1 ∨ c.val % 4 = 2 ∨ c.val % 4 = 3 := by omega
  rw [hc]
  rcases this with e | e | e | e <;> simp only [e] <;> assumption

end Tree

theorem kvMem_eq (hd : Decodes I initial values) (hs : fuse 1 = flags.prediction) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.predictionExpr flags (tree C))) :
    kvMem C fuse I h.val r.val = evaluate (row initial values h r) (Gated.predictionExpr flags (tree C)) :=
  kvMem_tree C.simdSum_tree hd hs h r hf

theorem delta_eq (hd : Decodes I initial values) (hs : fuse 1 = flags.prediction) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.deltaExpr flags (tree C))) :
    delta C fuse I h.val r.val = evaluate (row initial values h r) (Gated.deltaExpr flags (tree C)) :=
  delta_tree C.simdSum_tree hd hs h r hf

theorem updated_eq (hd : Decodes I initial values) (hs1 : fuse 1 = flags.prediction) (hs3 : fuse 3 = flags.update)
    (h : Fin 48) (r c : Fin 128) (hf : Arithmetic.Finite (row initial values h r) (Gated.stateExpr flags (tree C) c)) :
    updated C fuse I h.val r.val c.val = evaluate (row initial values h r) (Gated.stateExpr flags (tree C) c) :=
  updated_tree C.simdSum_tree hd hs1 hs3 h r c hf

theorem outSum_eq (hd : Decodes I initial values) (hs : Fuses fuse flags) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags (tree C))) :
    outSum C fuse I h.val r.val = evaluate (row initial values h r) (Gated.outputExpr flags (tree C)) :=
  outSum_tree C.simdSum_tree hd hs h r hf

/-- Every state expression of a row is finite when its output expression is. -/
theorem state_finite {flags : Gated.Contraction} {input : Nat → Float32}
    (hf : Arithmetic.Finite input (Gated.outputExpr flags (tree C))) (c : Fin 128) :
    Arithmetic.Finite input (Gated.stateExpr flags (tree C) c) :=
  state_finite_tree C.simdSum_tree hf c

end Values

/-! ## The outputs -/

/-- The model's outputs as element functions of the flat output index. -/
def yModel (flags : Gated.Contraction) (initial : GatedDevice.State) (values : GatedInputs.Values) (e : Nat) : BF :=
  if h : e < 6144 then
    GatedDevice.producedOutput C.simdSum flags initial values.inputs ⟨e / 128, by omega⟩ ⟨e % 128, by omega⟩
  else Val.ofBf16Bits 0
def stateModel (flags : Gated.Contraction) (initial : GatedDevice.State) (values : GatedInputs.Values) (e : Nat) :
    Float32 :=
  if h : e < 786432 then
    GatedDevice.producedState C.simdSum flags initial values.inputs ⟨e / 128 / 128, by omega⟩ ⟨e / 128 % 128, by omega⟩
      ⟨e % 128, by omega⟩
  else Val.ofF32Bits 0


section Outputs
variable {C} {fuse : Nat → Bool} {flags : Gated.Contraction} {I : Ins} {initial : GatedDevice.State}
  {values : GatedInputs.Values}

section Tree
variable (R : FlushedReduction.SimdContract C.simdSum)

/-- **`y` element `128 h + r` is the model's output** of row `r` of head `h`, the finiteness along the tree of any
reduction contract `R` of `C.simdSum`. -/
theorem yOut_tree (hd : Decodes I initial values) (hs : Fuses fuse flags) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags R.tree)) :
    yOut C fuse I (h.val * 128 + r.val) = GatedDevice.producedOutput C.simdSum flags initial values.inputs h r := by
  have e1 : (h.val * 128 + r.val) / 128 = h.val := by omega
  have e2 : (h.val * 128 + r.val) % 128 = r.val := by omega
  rw [yOut, e1, e2, outSum_tree R hd hs h r hf, C.narrow_model _ (finite_evaluate _ _ hf), GatedDevice.producedOutput,
    Gated.value, ← Gated.output_execution _ _ R]
  rfl

/-- **`state_out` element `(128 h + r) 128 + c` is the model's state** at column `c` of row `r` of head `h`. -/
theorem stateOut_tree (hd : Decodes I initial values) (hs1 : fuse 1 = flags.prediction) (hs3 : fuse 3 = flags.update)
    (h : Fin 48) (r c : Fin 128) (hf : Arithmetic.Finite (row initial values h r) (Gated.stateExpr flags R.tree c)) :
    stateOut C fuse I ((h.val * 128 + r.val) * 128 + c.val) =
      GatedDevice.producedState C.simdSum flags initial values.inputs h r c := by
  have e1 : ((h.val * 128 + r.val) * 128 + c.val) / 128 / 128 = h.val := by omega
  have e2 : ((h.val * 128 + r.val) * 128 + c.val) / 128 % 128 = r.val := by omega
  have e3 : ((h.val * 128 + r.val) * 128 + c.val) % 128 = c.val := by omega
  rw [stateOut, e1, e2, e3, updated_tree R hd hs1 hs3 h r c hf, GatedDevice.producedState, Recurrence.step,
    ← Gated.state_execution _ _ R]
  rfl

/-- **The output bytes are the model's encodings**: under `Fuses` and the finiteness the existing range theorems
prove for every row. -/
theorem outputs_tree (hd : Decodes I initial values) (hs : Fuses fuse flags)
    (hf : ∀ h r, Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags R.tree)) :
    bytes2 12288 (yOut C fuse I) = bytes2 12288 (yModel C flags initial values) ∧
      bytes4 3145728 (stateOut C fuse I) = bytes4 3145728 (stateModel C flags initial values) := by
  constructor
  · funext b
    unfold bytes2
    split
    · rename_i hb
      have hy := yOut_tree R hd hs ⟨b / 2 / 128, by omega⟩ ⟨b / 2 % 128, by omega⟩ (hf _ _)
      rw [show (b / 2 / 128) * 128 + b / 2 % 128 = b / 2 by omega] at hy
      rw [hy, yModel, dite_eq_left (by omega)]
    · rfl
  · funext b
    unfold bytes4
    split
    · rename_i hb
      have hy := stateOut_tree R hd hs.prediction hs.update ⟨b / 4 / 128 / 128, by omega⟩ ⟨b / 4 / 128 % 128, by omega⟩
        ⟨b / 4 % 128, by omega⟩ (state_finite_tree R (hf _ _) _)
      rw [show (b / 4 / 128 / 128 * 128 + b / 4 / 128 % 128) * 128 + b / 4 % 128 = b / 4 by omega] at hy
      rw [hy, stateModel, dite_eq_left (by omega)]
    · rfl

end Tree

/-- **`y` element `128 h + r` is the model's output** of row `r` of head `h`. -/
theorem yOut_eq (hd : Decodes I initial values) (hs : Fuses fuse flags) (h : Fin 48) (r : Fin 128)
    (hf : Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags (tree C))) :
    yOut C fuse I (h.val * 128 + r.val) = GatedDevice.producedOutput C.simdSum flags initial values.inputs h r :=
  yOut_tree C.simdSum_tree hd hs h r hf

/-- **`state_out` element `(128 h + r) 128 + c` is the model's state** at column `c` of row `r` of head `h`. -/
theorem stateOut_eq (hd : Decodes I initial values) (hs1 : fuse 1 = flags.prediction) (hs3 : fuse 3 = flags.update)
    (h : Fin 48) (r c : Fin 128) (hf : Arithmetic.Finite (row initial values h r) (Gated.stateExpr flags (tree C) c)) :
    stateOut C fuse I ((h.val * 128 + r.val) * 128 + c.val) =
      GatedDevice.producedState C.simdSum flags initial values.inputs h r c :=
  stateOut_tree C.simdSum_tree hd hs1 hs3 h r c hf

/-- **The output bytes are the model's encodings**: under `Fuses` and the finiteness the existing range theorems
prove for every row. -/
theorem outputs_eq (hd : Decodes I initial values) (hs : Fuses fuse flags)
    (hf : ∀ h r, Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags (tree C))) :
    bytes2 12288 (yOut C fuse I) = bytes2 12288 (yModel C flags initial values) ∧
      bytes4 3145728 (stateOut C fuse I) = bytes4 3145728 (stateModel C flags initial values) :=
  outputs_tree C.simdSum_tree hd hs hf

end Outputs

/-! ## The GPU runs the model -/

/-- **Under the GPU assumption the launch's outputs are the model's encodings** (`Delta.GatedDevice.producedOutput`
and `producedState`, the values `GlueKernels.gated_delta_step` consumes), when the buffers decode to the model's
inputs, the compiler's choices at sites 1, 3, 4 are the model's flags, and every row's output expression is finite. -/
theorem gpu_model (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (q k v g beta s t : ByteMemory.Bytes) (aq ak av ag ab as aT : Nat)
    (hq : 2 ∣ aq) (hk : 2 ∣ ak) (hv : 2 ∣ av) (hg : 4 ∣ ag) (hb : 2 ∣ ab) (hs : 4 ∣ as) (ht : 4 ∣ aT)
    (hT : t 0 = 1 ∧ t 1 = 0 ∧ t 2 = 0 ∧ t 3 = 0) {flags : Gated.Contraction} {initial : GatedDevice.State}
    {values : GatedInputs.Values} (hd : Decodes ⟨q, k, v, g, beta, s, t⟩ initial values)
    (hfuse : Fuses (G.fusion Metal.Elab.Tests.gatedDeltaStepText) flags)
    (hf : ∀ h r, Arithmetic.Finite (row initial values h r) (Gated.outputExpr flags (tree C))) :
    G.execute Metal.Elab.Tests.gatedDeltaStepText (32, 128, 48) (32, 4, 1)
      [⟨.device, 4096, aq, q⟩, ⟨.device, 4096, ak, k⟩, ⟨.device, 12288, av, v⟩, ⟨.device, 192, ag, g⟩,
        ⟨.device, 96, ab, beta⟩, ⟨.device, 3145728, as, s⟩, ⟨.constant, 4, aT, t⟩] [12288, 3145728] =
      some [bytes2 12288 (yModel C flags initial values), bytes4 3145728 (stateModel C flags initial values)] := by
  obtain ⟨h1, h2⟩ := outputs_eq hd hfuse hf
  rw [gpu_output C G hmax q k v g beta s t aq ak av ag ab as aT hq hk hv hg hb hs ht hT, h1, h2]

/-! ## Values: the route's `Flat` inputs and readback -/

section Values
open Host.Mlx

/-- Buffers holding the row-major bytes of values that `GlueKernels.gated_delta_step`'s hypotheses describe decode
to the model's inputs. -/
theorem decodes_of_values {initial : GatedDevice.State} {values : GatedInputs.Values} {qv kv vv gv bv sv : Value}
    (t : ByteMemory.Bytes)
    (hq : Flat qv [1,1,16,128] (GatedInputs.flatten values.query))
    (hk : Flat kv [1,1,16,128] (GatedInputs.flatten values.key))
    (hv : Flat vv [1,1,48,128] (GatedInputs.flatten values.value)) (hg : FlatF32 gv [1,1,48] values.decay)
    (hb : Flat bv [1,1,48] values.beta)
    (hs : sv.dtype = .float32 ∧ sv.shape = [1,48,128,128] ∧
      ∀ h r c, f32 (sv.elems (GatedStores.stateIndex h r c)) = initial h r c) :
    Decodes ⟨qv.storageByte, kv.storageByte, vv.storageByte, gv.storageByte, bv.storageByte, sv.storageByte, t⟩
      initial values where
  state h r c := by
    change Val.ofF32Bits (bytesWord ((List.range 4).map fun i => sv.storageByte (4 * GatedStores.stateIndex h r c + i))) = _
    rw [storage4 sv (by rw [hs.1]; rfl), ofF32Bits_mod, hs.2.2]
  key h c := by
    unfold bfAt
    rw [storage2 kv hk.1, ofBf16Bits_mod, show h.val * 128 + c.val = (GatedInputs.index h c).val from rfl, hk.2.2,
      GatedInputs.flatten_index]
  query h c := by
    unfold bfAt
    rw [storage2 qv hq.1, ofBf16Bits_mod, show h.val * 128 + c.val = (GatedInputs.index h c).val from rfl, hq.2.2,
      GatedInputs.flatten_index]
  value h c := by
    unfold bfAt
    rw [storage2 vv hv.1, ofBf16Bits_mod, show h.val * 128 + c.val = (GatedInputs.index h c).val from rfl, hv.2.2,
      GatedInputs.flatten_index]
  decay h := by
    unfold f32At
    rw [storage4 gv (by rw [hg.1]; rfl), ofF32Bits_mod]
    exact hg.2.2 h
  beta h := by
    unfold bfAt
    rw [storage2 bv hb.1, ofBf16Bits_mod]
    exact hb.2.2 h

/-- The output bytes read back as the route reads them are `GlueKernels.gated_delta_step`'s conclusions. -/
theorem readback (flags : Gated.Contraction) (initial : GatedDevice.State) (values : GatedInputs.Values) :
    Tensor4 (halfArray (bytes2 12288 (yModel C flags initial values)) 0 [1,1,48,128]) 1 48 128
        (fun _ => GatedDevice.producedOutput C.simdSum flags initial values.inputs) ∧
      ∀ h r c, f32 ((wordArray .float32 (bytes4 3145728 (stateModel C flags initial values)) 0 [1,48,128,128]).elems
        (GatedStores.stateIndex h r c)) = GatedDevice.producedState C.simdSum flags initial values.inputs h r c := by
  constructor
  · refine GlueKernels.heads_tensor _ 0 48 _ fun h i => ?_
    rw [Nat.zero_add]
    refine half_readback _ _ _ fun k hk => ?_
    have he : h.val * 128 + i.val < 6144 := by omega
    unfold bytes2
    rw [ite_eq_left (by omega), show (2 * (h.val * 128 + i.val) + k) / 2 = h.val * 128 + i.val by omega,
      show (2 * (h.val * 128 + i.val) + k) % 2 = k by omega, yModel, dite_eq_left he]
    congr 4 <;> apply Fin.ext <;> simp only <;> omega
  · intro h r c
    rw [GlueKernels.word_read, Nat.zero_add]
    refine word_readback _ _ _ fun k hk => ?_
    have he : GatedStores.stateIndex h r c < 786432 := by unfold GatedStores.stateIndex; omega
    unfold bytes4
    rw [ite_eq_left (by omega), show (4 * GatedStores.stateIndex h r c + k) / 4 = GatedStores.stateIndex h r c by omega,
      show (4 * GatedStores.stateIndex h r c + k) % 4 = k by omega, stateModel, dite_eq_left he]
    congr 4 <;> apply Fin.ext <;> simp only [GatedStores.stateIndex] <;> omega

end Values

end Metal.Bridge.GatedDeltaStep
