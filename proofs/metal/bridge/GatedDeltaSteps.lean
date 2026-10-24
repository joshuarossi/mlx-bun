import metal.kernels.GatedDeltaSteps
import metal.bridge.GatedDeltaStep

namespace Metal.Bridge.GatedDeltaSteps
open Metal Metal.Core Metal.Kernels.GatedDeltaStep Metal.Kernels.GatedDeltaSteps
open Inference.Contracts.Mlx Inference.Kernels.Delta
open Metal.Bridge.GatedDeltaStep (Fuses Decodes row tree)

/-! # gated_delta_step over `T` time steps: the machine spec is the model

`Metal.Kernels.GatedDeltaSteps.gpu_output_steps` states the launch's outputs as the one-step machine spec
iterated (`stepAt`); the T-step device model is `Delta.Recurrence.run` / `Recurrence.outputAt` on each row,
which iterate the one-step model `Recurrence.step` / `Gated.value` that `Delta.GatedDevice.producedState` /
`producedOutput` are (`stateRun_succ`, `outputAt_eq`). Step `τ`'s model inputs are `values τ`, decoded from the
`τ`-th slices of the buffers (`DecodesSteps`), the state from `state_in` and then the previous step's model
state. The contraction sites and operations correspond as for one step (`GatedDeltaStep.Fuses`,
`yOut_eq`, `stateOut_eq`); the finiteness hypothesis is the one-step bridge's at every step, on the model's
state after `τ` steps (from a zero state, supported input ranges and at most 262143 steps it follows from
`RecurrenceReadoutRanges.value` on `RecurrenceSupportedRanges.run_uniform`'s bounds, as in `run_output`). -/

variable (C : M1Max.Contract)

/-- Row `(h, r)`'s model inputs at each time step. -/
def rowInputs (values : Nat → GatedInputs.Values) (h : Fin 48) (r : Fin 128) (τ : Nat) : Recurrence.Inputs Float32 :=
  (values τ).inputs h r

/-- The model state after `τ` time steps: `Recurrence.run` on every row. -/
def stateRun (flags : Gated.Contraction) (initial : GatedDevice.State) (values : Nat → GatedInputs.Values) (τ : Nat) :
    GatedDevice.State :=
  fun h r => Recurrence.run C.simdSum flags (rowInputs values h r) (initial h r) τ

/-- Each step is the one-step device model's state. -/
theorem stateRun_succ (flags : Gated.Contraction) (initial : GatedDevice.State) (values : Nat → GatedInputs.Values)
    (τ : Nat) : stateRun C flags initial values (τ + 1) =
      GatedDevice.producedState C.simdSum flags (stateRun C flags initial values τ) (values τ).inputs := by
  funext h r; rw [GatedDevice.producedState]; rfl

/-- Each step's output is the one-step device model's output on the state after the previous steps. -/
theorem outputAt_eq (flags : Gated.Contraction) (initial : GatedDevice.State) (values : Nat → GatedInputs.Values)
    (h : Fin 48) (r : Fin 128) (τ : Nat) :
    Recurrence.outputAt C.simdSum flags (rowInputs values h r) (initial h r) τ =
      GatedDevice.producedOutput C.simdSum flags (stateRun C flags initial values τ) (values τ).inputs h r := by
  rw [GatedDevice.producedOutput]; rfl

/-- The model's `y` as a function of the flat index of [T, 48, 128]: step `e / 6144`'s output of row
`e % 128` of head `e % 6144 / 128`. -/
def yModelSteps (flags : Gated.Contraction) (initial : GatedDevice.State) (values : Nat → GatedInputs.Values)
    (e : Nat) : BF :=
  Recurrence.outputAt C.simdSum flags (rowInputs values ⟨e % 6144 / 128, by omega⟩ ⟨e % 128, by omega⟩)
    (initial ⟨e % 6144 / 128, by omega⟩ ⟨e % 128, by omega⟩) (e / 6144)

/-- The model's `state_out` as a function of the flat index of [48, 128, 128]: the state after `T` steps. -/
def stateModelSteps (T : Nat) (flags : Gated.Contraction) (initial : GatedDevice.State)
    (values : Nat → GatedInputs.Values) (e : Nat) : Float32 :=
  if h : e < 786432 then
    stateRun C flags initial values T ⟨e / 128 / 128, by omega⟩ ⟨e / 128 % 128, by omega⟩ ⟨e % 128, by omega⟩
  else Val.ofF32Bits 0

/-- The input buffers' elements are the model's inputs: `state_in`'s the initial state, and the `τ`-th slices
of `q`, `k` ([T, 16, 128]), `v` ([T, 48, 128]), `g`, `beta` ([T, 48]) step `τ`'s `values τ`. -/
structure DecodesSteps (T : Nat) (I : Ins) (initial : GatedDevice.State) (values : Nat → GatedInputs.Values) : Prop where
  state : ∀ (h : Fin 48) (r c : Fin 128), stateIn I h.val r.val c.val = initial h r c
  key : ∀ τ < T, ∀ (h : Fin 16) (c : Fin 128), bfAt I.k (2048 * τ + (h.val * 128 + c.val)) = (values τ).key h c
  query : ∀ τ < T, ∀ (h : Fin 16) (c : Fin 128), bfAt I.q (2048 * τ + (h.val * 128 + c.val)) = (values τ).query h c
  value : ∀ τ < T, ∀ (h : Fin 48) (c : Fin 128), bfAt I.v (6144 * τ + (h.val * 128 + c.val)) = (values τ).value h c
  decay : ∀ τ < T, ∀ h : Fin 48, f32At I.g (48 * τ + h.val) = (values τ).decay h
  beta : ∀ τ < T, ∀ h : Fin 48, bfAt I.beta (48 * τ + h.val) = (values τ).beta h

section Steps
variable {C} {fuse : Nat → Bool} {flags : Gated.Contraction} {T : Nat} {I : Ins} {initial : GatedDevice.State}
  {values : Nat → GatedInputs.Values}

/-- Step `τ`'s slices decode to `values τ`. -/
theorem slices (hd : DecodesSteps T I initial values) {τ : Nat} (hτ : τ < T) {S : GatedDevice.State}
    {B : ByteMemory.Bytes} (hS : ∀ (h : Fin 48) (r c : Fin 128), stateIn (stepIns I B τ) h.val r.val c.val = S h r c) :
    Decodes (stepIns I B τ) S (values τ) where
  state := hS
  key h c := by
    show bfAt (fun b => I.k (4096 * τ + b)) _ = _
    rw [bfAt_shift _ _ (show 4096 * τ = 2 * (2048 * τ) by ring)]; exact hd.key τ hτ h c
  query h c := by
    show bfAt (fun b => I.q (4096 * τ + b)) _ = _
    rw [bfAt_shift _ _ (show 4096 * τ = 2 * (2048 * τ) by ring)]; exact hd.query τ hτ h c
  value h c := by
    show bfAt (fun b => I.v (12288 * τ + b)) _ = _
    rw [bfAt_shift _ _ (show 12288 * τ = 2 * (6144 * τ) by ring)]; exact hd.value τ hτ h c
  decay h := by
    show f32At (fun b => I.g (192 * τ + b)) _ = _
    rw [f32At_shift _ _ (show 192 * τ = 4 * (48 * τ) by ring)]; exact hd.decay τ hτ h
  beta h := by
    show bfAt (fun b => I.beta (96 * τ + b)) _ = _
    rw [bfAt_shift _ _ (show 96 * τ = 2 * (48 * τ) by ring)]; exact hd.beta τ hτ h

/-- **Every step's machine inputs decode to the model's**: the machine state before step `τ` is the model's
state after `τ` steps, given finiteness at the earlier steps. -/
theorem decodes_at (hd : DecodesSteps T I initial values) (hs : Fuses fuse flags)
    (hf : ∀ τ < T, ∀ h r, Arithmetic.Finite (row (stateRun C flags initial values τ) (values τ) h r)
      (Gated.outputExpr flags (tree C))) :
    ∀ τ < T, Decodes (stepAt C fuse I τ) (stateRun C flags initial values τ) (values τ)
  | 0, hτ => slices hd hτ fun h r c => (stateIn_zero C fuse I _ _ _).trans (hd.state h r c)
  | τ + 1, hτ => slices hd hτ fun h r c => by
    have hprev := decodes_at hd hs hf τ (by omega)
    show f32At (bytes4 3145728 (stateOut C fuse (stepAt C fuse I τ))) ((h.val * 128 + r.val) * 128 + c.val) = _
    rw [f32At_bytes4 _ (by omega), Metal.Bridge.GatedDeltaStep.stateOut_eq hprev hs.prediction hs.update h r c
      (Metal.Bridge.GatedDeltaStep.state_finite (hf τ (by omega) h r) c), stateRun_succ]

/-- **The output bytes are the model's encodings**, under `DecodesSteps`, `Fuses` and finiteness at every
step. -/
theorem outputs_eq_steps (hT1 : 1 ≤ T) (hd : DecodesSteps T I initial values) (hs : Fuses fuse flags)
    (hf : ∀ τ < T, ∀ h r, Arithmetic.Finite (row (stateRun C flags initial values τ) (values τ) h r)
      (Gated.outputExpr flags (tree C))) :
    bytes2 (12288 * T) (ySteps C fuse I) = bytes2 (12288 * T) (yModelSteps C flags initial values) ∧
      bytes4 3145728 (stateOut C fuse (stepAt C fuse I (T - 1))) =
        bytes4 3145728 (stateModelSteps C T flags initial values) := by
  constructor
  · funext b
    unfold bytes2
    split
    · rename_i hb
      have hτ : b / 2 / 6144 < T := by omega
      have hy := Metal.Bridge.GatedDeltaStep.yOut_eq (decodes_at hd hs hf _ hτ) hs
        ⟨b / 2 % 6144 / 128, by omega⟩ ⟨b / 2 % 128, by omega⟩ (hf _ hτ _ _)
      rw [show b / 2 % 6144 / 128 * 128 + b / 2 % 128 = b / 2 % 6144 by omega] at hy
      unfold ySteps yModelSteps
      rw [hy, outputAt_eq]
    · rfl
  · funext b
    unfold bytes4
    split
    · rename_i hb
      have hτ : T - 1 < T := by omega
      have hy := Metal.Bridge.GatedDeltaStep.stateOut_eq (decodes_at hd hs hf _ hτ) hs.prediction hs.update
        ⟨b / 4 / 128 / 128, by omega⟩ ⟨b / 4 / 128 % 128, by omega⟩ ⟨b / 4 % 128, by omega⟩
        (Metal.Bridge.GatedDeltaStep.state_finite (hf _ hτ _ _) _)
      rw [show (b / 4 / 128 / 128 * 128 + b / 4 / 128 % 128) * 128 + b / 4 % 128 = b / 4 by omega] at hy
      rw [hy, stateModelSteps, dite_eq_left (by omega), show T = T - 1 + 1 by omega, stateRun_succ,
        Nat.add_sub_cancel]
    · rfl

end Steps

/-! ## The GPU runs the model -/

/-- **Under the GPU assumption the launch over `T` time steps produces the T-step model's encodings**
(`Delta.Recurrence.outputAt` at every step, `Recurrence.run` after `T` steps, on every row), when the buffers'
slices decode to the model's per-step inputs, the compiler's choices at sites 1, 3, 4 are the model's flags, and
every row's output expression is finite at every step. -/
theorem gpu_model_steps (G : Gpu C) (hmax : 128 ≤ G.maxThreads Metal.Elab.Tests.gatedDeltaStepText)
    (T : Nat) (hT1 : 1 ≤ T) (hT2 : T < 2 ^ 31)
    (q k v g beta s t : ByteMemory.Bytes) (aq ak av ag ab as aT : Nat)
    (hq : 2 ∣ aq) (hk : 2 ∣ ak) (hv : 2 ∣ av) (hg : 4 ∣ ag) (hb : 2 ∣ ab) (hs : 4 ∣ as) (ht : 4 ∣ aT)
    (hT : t 0 = BitVec.ofNat 8 T ∧ t 1 = BitVec.ofNat 8 (T / 2 ^ 8) ∧ t 2 = BitVec.ofNat 8 (T / 2 ^ 16) ∧
      t 3 = BitVec.ofNat 8 (T / 2 ^ 24))
    {flags : Gated.Contraction} {initial : GatedDevice.State} {values : Nat → GatedInputs.Values}
    (hd : DecodesSteps T ⟨q, k, v, g, beta, s, t⟩ initial values)
    (hfuse : Fuses (G.fusion Metal.Elab.Tests.gatedDeltaStepText) flags)
    (hf : ∀ τ < T, ∀ h r, Arithmetic.Finite (row (stateRun C flags initial values τ) (values τ) h r)
      (Gated.outputExpr flags (tree C))) :
    G.execute Metal.Elab.Tests.gatedDeltaStepText (32, 128, 48) (32, 4, 1)
      [⟨.device, 4096 * T, aq, q⟩, ⟨.device, 4096 * T, ak, k⟩, ⟨.device, 12288 * T, av, v⟩, ⟨.device, 192 * T, ag, g⟩,
        ⟨.device, 96 * T, ab, beta⟩, ⟨.device, 3145728, as, s⟩, ⟨.constant, 4, aT, t⟩] [12288 * T, 3145728] =
      some [bytes2 (12288 * T) (yModelSteps C flags initial values),
        bytes4 3145728 (stateModelSteps C T flags initial values)] := by
  obtain ⟨h1, h2⟩ := outputs_eq_steps hT1 hd hfuse hf
  rw [gpu_output_steps C G hmax T hT1 hT2 q k v g beta s t aq ak av ag ab as aT hq hk hv hg hb hs ht hT, h1, h2]

end Metal.Bridge.GatedDeltaSteps
