import kernels.delta.Gated

namespace Inference.Kernels.Delta.Convolution
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := Model FloatFormat.bfloat16

-- MLX v0.32.2 conv.cpp selects depthwise_conv_1d for this fixed descriptor:
-- groups = input channels = output channels = 10240; stride/dilations = 1,
-- padding = 0, no flip. conv.metal accumulates four widened products in float
-- and performs one bf16 store. Compiler contraction remains explicit.
def depthwiseSelected (inputChannels outputChannels groups stride kernelDilation inputDilation padding : Nat) (flip : Bool) : Bool :=
  inputDilation == 1 && groups == inputChannels && groups == outputChannels &&
    stride == 1 && kernelDilation == 1 && padding == 0 && !flip

theorem selected : depthwiseSelected 10240 10240 10240 1 1 1 0 false = true := by decide +kernel

def bind (input weight : Fin 4 → Float32) (i : Nat) : Float32 :=
  if h : i < 4 then input ⟨i, h⟩ else if h : i < 8 then weight ⟨i - 4, by omega⟩ else 0
noncomputable def bindReal (input weight : Fin 4 → ℝ) (i : Nat) : ℝ :=
  if h : i < 4 then input ⟨i, h⟩ else if h : i < 8 then weight ⟨i - 4, by omega⟩ else 0

theorem bind_input (input weight : Fin 4 → Float32) (i : Fin 4) : bind input weight i.val = input i := by simp [bind, i.isLt]
theorem bind_weight (input weight : Fin 4 → Float32) (i : Fin 4) : bind input weight (4 + i.val) = weight i := by
  have := i.isLt
  simp [bind, show ¬4 + i.val < 4 by omega, show 4 + i.val < 8 by omega]
theorem bindReal_input (input weight : Fin 4 → ℝ) (i : Fin 4) : bindReal input weight i.val = input i := by simp [bindReal, i.isLt]
theorem bindReal_weight (input weight : Fin 4 → ℝ) (i : Fin 4) : bindReal input weight (4 + i.val) = weight i := by
  have := i.isLt
  simp [bindReal, show ¬4 + i.val < 4 by omega, show 4 + i.val < 8 by omega]

def expression (contracted : Bool) : Arithmetic.Expr :=
  (List.finRange 4).foldl (fun acc tap => Gated.madd contracted (.input tap.val) (.input (4 + tap.val)) acc) .zero

def accumulate (contracted : Bool) (input weight : Fin 4 → Float32) : Float32 :=
  (List.finRange 4).foldl (fun acc tap => Gated.maddFloat contracted (input tap) (weight tap) acc) 0

def value (contracted : Bool) (input weight : Fin 4 → BF) : BF :=
  BFloat16.narrow (accumulate contracted (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i)))

theorem execution (contracted : Bool) (input weight : Fin 4 → Float32) :
    Arithmetic.evaluate (bind input weight) (expression contracted) = accumulate contracted input weight := by
  unfold expression accumulate
  rw [Gated.evaluate_fold]
  simp only [Arithmetic.evaluate, bind_input, bind_weight]

theorem ideal (contracted : Bool) (input weight : Fin 4 → ℝ) :
    Arithmetic.ideal (bindReal input weight) (expression contracted) = ∑ i, input i * weight i := by
  unfold expression
  rw [Gated.ideal_fold]
  simp only [Arithmetic.ideal, bindReal_input, bindReal_weight, zero_add, ← Fin.sum_univ_def]

theorem bind_error (input weight : Fin 4 → Float32) (targetInput targetWeight inputError weightError : Fin 4 → ℝ)
    (hi : ∀ i, |real (input i) - targetInput i| ≤ inputError i)
    (hw : ∀ i, |real (weight i) - targetWeight i| ≤ weightError i) (i : Nat) :
    |real (bind input weight i) - bindReal targetInput targetWeight i| ≤ bindReal inputError weightError i := by
  unfold bind bindReal
  split
  · exact hi _
  · split
    · exact hw _
    · have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
      simp only [hz, sub_zero, abs_zero, le_refl]

noncomputable def budget (contracted : Bool) (input weight : Fin 4 → BF)
    (targetInput targetWeight inputError weightError : Fin 4 → ℝ) : ℝ :=
  Arithmetic.budget (bind (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i)))
    (bindReal targetInput targetWeight) (bindReal inputError weightError) (expression contracted) +
    BFloat16.epsilon (real (accumulate contracted (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i))))

theorem value_error (contracted : Bool) (input weight : Fin 4 → BF)
    (targetInput targetWeight inputError weightError : Fin 4 → ℝ)
    (hif : ∀ i, Model.isFinite (input i) = true) (hwf : ∀ i, Model.isFinite (weight i) = true)
    (hi : ∀ i, |Model.toReal (input i) - targetInput i| ≤ inputError i)
    (hw : ∀ i, |Model.toReal (weight i) - targetWeight i| ≤ weightError i)
    (hf : Arithmetic.Finite (bind (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i))) (expression contracted))
    (hb : Model.isFinite (value contracted input weight) = true) :
    |Model.toReal (value contracted input weight) - ∑ i, targetInput i * targetWeight i| ≤
      budget contracted input weight targetInput targetWeight inputError weightError := by
  have he := bind_error (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i))
    targetInput targetWeight inputError weightError
    (fun i => by rw [BFloat16.widen_real _ (hif i)]; exact hi i)
    (fun i => by rw [BFloat16.widen_real _ (hwf i)]; exact hw i)
  have ha := Arithmetic.error _ _ _ he (expression contracted) hf
  rw [execution, ideal] at ha
  have hfa := Arithmetic.finite_evaluate _ (expression contracted) hf
  rw [execution] at hfa
  have hc := BFloat16.narrow_error _ hfa hb
  unfold budget
  calc
    _ = |(Model.toReal (value contracted input weight) - real (accumulate contracted (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i)))) +
      (real (accumulate contracted (fun i => BFloat16.widen (input i)) (fun i => BFloat16.widen (weight i))) - ∑ i, targetInput i * targetWeight i)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hc ha)
      simpa only [value, add_comm] using h

-- The first three rows are retained history; all subsequent rows are this
-- call's projected input. No boundary padding contributes a phantom tap.
def joined (history : Fin 3 → α) (input : Nat → α) (time : Nat) : α :=
  if h : time < 3 then history ⟨time, h⟩ else input (time - 3)

def window (history : Fin 3 → α) (input : Nat → α) (time : Nat) (tap : Fin 4) : α := joined history input (time + tap.val)
def tail (history : Fin 3 → α) (input : Nat → α) (steps : Nat) (i : Fin 3) : α := joined history input (steps + i.val)

theorem initial_history (history : Fin 3 → α) (input : Nat → α) (i : Fin 3) : tail history input 0 i = history i := by
  simp [tail, joined, i.isLt]

theorem newest (history : Fin 3 → α) (input : Nat → α) (time : Nat) : joined history input (time + 3) = input time := by
  simp [joined, show ¬time + 3 < 3 by omega]

def push (history : Fin 3 → α) (next : α) (i : Fin 3) : α :=
  if h : i.val < 2 then history ⟨i.val + 1, by omega⟩ else next

theorem tail_step (history : Fin 3 → α) (input : Nat → α) (time : Nat) :
    tail history input (time + 1) = push (tail history input time) (input time) := by
  funext i
  unfold push
  split
  · simp only [tail]
    congr 1
    omega
  · have hi : i.val = 2 := by have := i.isLt; omega
    simp only [tail, hi, show time + 1 + 2 = time + 3 by omega, newest]

def runHistory (history : Fin 3 → α) (input : Nat → α) : Nat → Fin 3 → α
  | 0 => history
  | t + 1 => push (runHistory history input t) (input t)

theorem history_correct (history : Fin 3 → α) (input : Nat → α) (time : Nat) :
    runHistory history input time = tail history input time := by
  induction time with
  | zero => funext i; exact (initial_history history input i).symm
  | succ t ih => rw [runHistory, ih, tail_step]

def streamWindow (history : Fin 3 → α) (next : α) (tap : Fin 4) : α :=
  if h : tap.val < 3 then history ⟨tap.val, h⟩ else next

theorem window_correct (history : Fin 3 → α) (input : Nat → α) (time : Nat) :
    streamWindow (runHistory history input time) (input time) = window history input time := by
  rw [history_correct]
  funext tap
  unfold streamWindow
  split
  · rfl
  · have ht : tap.val = 3 := by have := tap.isLt; omega
    simp only [window, ht, newest]

theorem streaming_value (contracted : Bool) (history : Fin 3 → BF) (input : Nat → BF) (weight : Fin 4 → BF) (time : Nat) :
    value contracted (streamWindow (runHistory history input time) (input time)) weight =
      value contracted (window history input time) weight := by rw [window_correct]

theorem window_error (history : Fin 3 → BF) (input : Nat → BF)
    (targetHistory historyError : Fin 3 → ℝ) (targetInput inputError : Nat → ℝ)
    (hh : ∀ i, |Model.toReal (history i) - targetHistory i| ≤ historyError i)
    (hi : ∀ t, |Model.toReal (input t) - targetInput t| ≤ inputError t) (time : Nat) (tap : Fin 4) :
    |Model.toReal (window history input time tap) - window targetHistory targetInput time tap| ≤
      window historyError inputError time tap := by
  unfold window joined
  split
  · exact hh _
  · exact hi _

theorem window_finite (history : Fin 3 → BF) (input : Nat → BF)
    (hh : ∀ i, Model.isFinite (history i) = true) (hi : ∀ t, Model.isFinite (input t) = true)
    (time : Nat) (tap : Fin 4) : Model.isFinite (window history input time tap) = true := by
  unfold window joined
  split
  · exact hh _
  · exact hi _

-- A padded batch row retains only its real-token prefix, including an empty
-- prefix. This is the takeAlongAxis index length + position in convTail.
theorem padded_tail (history : Fin 3 → α) (input : Nat → α) (length : Nat) (i : Fin 3) :
    joined history input (length + i.val) = runHistory history input length i := by
  rw [history_correct]
  rfl

theorem input_time_bound (time : Fin steps) (tap : Fin 4) : time.val + tap.val < steps + 3 := by
  have := time.isLt
  have := tap.isLt
  omega

theorem input_offset (batch time channel tap steps : Nat) :
    batch * ((steps + 3) * 10240) + time * 10240 + channel + tap * 10240 =
      (batch * (steps + 3) + time + tap) * 10240 + channel := by ring

theorem output_offset (batch time channel steps : Nat) :
    (batch * steps + time) * 10240 + channel = batch * (steps * 10240) + time * 10240 + channel := by ring

theorem weight_offset (channel : Fin 10240) (tap : Fin 4) : channel.val * 4 + tap.val < 40960 := by
  have := channel.isLt
  have := tap.isLt
  omega

end Inference.Kernels.Delta.Convolution
