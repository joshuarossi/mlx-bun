import Std

namespace Inference.Contracts.Mlx.SdpaDispatch

-- Manual translation of the pinned MLX has_fused_kernel, use_fallback,
-- and eval_gpu branch predicates. Error-message strings are omitted.
-- Shapes are nonnegative and must be bound to actual array metadata;
-- this does not certify execution of the compiled C++ dispatcher.
structure Inputs where
  gpu : Bool
  outputLogsumexp : Bool
  training : Bool
  forceFused : Bool
  nax : Bool
  tf32 : Bool
  float32 : Bool
  hasMask : Bool
  arrayMask : Bool
  causal : Bool
  queryLength : Nat
  keyLength : Nat
  queryHeads : Nat
  keyHeads : Nat
  queryWidth : Nat
  valueWidth : Nat

def hasFused (x : Inputs) : Bool :=
  if !x.gpu || x.outputLogsumexp then false
  else if x.queryLength > 8 then
    decide (x.queryWidth = x.valueWidth ∧ x.queryWidth ∈ [64, 72, 80, 96, 128, 192, 256]) &&
      !(x.hasMask && !x.arrayMask && !(decide (x.queryLength ≤ x.keyLength) && x.causal))
  else
    decide ((x.queryWidth = x.valueWidth ∧ x.queryWidth ∈ [64, 96, 128, 192, 256]) ∨
      (x.queryWidth = 192 ∧ x.valueWidth = 128)) &&
      decide (x.queryLength ≤ x.keyLength) && decide (x.queryLength * (x.queryHeads / x.keyHeads) ≤ 32)

-- none corresponds to the explicit invalid_argument when forced fusion
-- is unavailable. The NAX branch is retained even though decode excludes it.
def useFallback (x : Inputs) : Option Bool :=
  if x.forceFused then if hasFused x then some false else none
  else if x.training || !hasFused x then some true
  else if x.nax && (x.tf32 || !x.float32) && decide (x.queryLength ≥ 1024) &&
      decide (x.queryWidth = 256) && x.causal && !x.arrayMask then some false
  else if x.queryLength > 8 then some (decide (x.queryWidth = 192 ∨ x.queryWidth = 256))
  else some (decide (x.queryWidth = x.valueWidth ∧ x.queryWidth = 192))

inductive Route where
  | rejected | fallback | full | onePass | twoPass
  deriving DecidableEq

def route (x : Inputs) (architectureSuffix : Char) : Route :=
  match useFallback x with
  | none => .rejected
  | some true => .fallback
  | some false =>
    if x.queryLength > 8 then .full
    else if ((architectureSuffix = 'd' ∨ architectureSuffix = 's') ∧ x.keyLength ≥ 1024) ∨
        (x.keyHeads < x.queryHeads ∧ x.keyLength ≥ 4096) then .twoPass
    else .onePass

def qwen (keys : Nat) : Inputs where
  gpu := true
  outputLogsumexp := false
  training := false
  forceFused := false
  nax := false
  tf32 := false
  float32 := false
  hasMask := false
  arrayMask := false
  causal := false
  queryLength := 1
  keyLength := keys
  queryHeads := 24
  keyHeads := 4
  queryWidth := 256
  valueWidth := 256

theorem qwen_available (keys : Nat) (positive : 0 < keys) : hasFused (qwen keys) = true := by
  simp [hasFused, qwen, show 1 ≤ keys from positive]

theorem qwen_fused (keys : Nat) (positive : 0 < keys) : useFallback (qwen keys) = some false := by
  unfold useFallback
  rw [qwen_available keys positive]
  simp [qwen]

theorem qwen_short (keys : Nat) (positive : 0 < keys) (short : keys < 1024) (arch : Char) :
    route (qwen keys) arch = .onePass := by
  have longer : ¬keys ≥ 4096 := by omega
  unfold route
  rw [qwen_fused keys positive]
  simp [qwen, show ¬keys ≥ 1024 from by omega, longer]

theorem qwen_large_device (keys : Nat) (long : 1024 ≤ keys) (arch : Char)
    (large : arch = 'd' ∨ arch = 's') : route (qwen keys) arch = .twoPass := by
  unfold route
  rw [qwen_fused keys (by omega)]
  simp [qwen, large, long]

theorem qwen_long (keys : Nat) (long : 4096 ≤ keys) (arch : Char) :
    route (qwen keys) arch = .twoPass := by
  unfold route
  rw [qwen_fused keys (by omega)]
  simp [qwen, long]

theorem qwen_small_device (keys : Nat) (positive : 0 < keys) (short : keys < 4096)
    (arch : Char) (small : arch ≠ 'd' ∧ arch ≠ 's') : route (qwen keys) arch = .onePass := by
  unfold route
  rw [qwen_fused keys positive]
  simp [qwen, small.1, small.2, show ¬keys ≥ 4096 from by omega]

-- sdpa_vector supplies 24 head groups, one query, and 1024 threads.
-- The head quotient routes each six-query-head group to one KV head.
def grid : Nat × Nat × Nat := (1*24, 1, 1)
def threads : Nat × Nat × Nat := (1024, 1, 1)
def kvHead (head : Fin 24) : Fin 4 := ⟨head.val / (24/4), by have := head.isLt; omega⟩

theorem geometry : grid = (24, 1, 1) ∧ threads = (32*32, 1, 1) := ⟨rfl, rfl⟩
theorem kv_head (head : Fin 24) : (kvHead head).val = head.val/6 := rfl
theorem kv_head_group (head : Fin 24) :
    (kvHead head).val*6 ≤ head.val ∧ head.val < ((kvHead head).val+1)*6 := by
  simp only [kv_head]
  omega

end Inference.Contracts.Mlx.SdpaDispatch
