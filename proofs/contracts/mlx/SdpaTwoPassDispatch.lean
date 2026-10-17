import contracts.mlx.SdpaDispatch

namespace Inference.Contracts.Mlx.SdpaTwoPassDispatch
open SdpaDispatch

-- Pinned MLX sdpa_vector_2pass host specialization. The positive environment
-- override is modeled separately; the selected default configuration has 0.
-- Native int conversions and environment parsing are not assumed total.
def gqaVariant (x : Inputs) (sinks : Bool) : Bool :=
  !x.arrayMask && !sinks && decide (x.queryLength = 1) && decide (x.queryHeads = 8*x.keyHeads) &&
    decide (x.queryWidth = x.valueWidth) && decide (x.queryWidth = 64 ∨ x.queryWidth = 128) &&
    decide (8192 ≤ x.keyLength)

def defaultBlocks (arch : Char) (keys simds : Nat) : Nat :=
  if arch = 's' then
    if keys > 1024 ∧ simds > 4 then
      if keys ≤ 8192 then 128 else if keys ≤ 32768 then 256 else if keys ≤ 65536 then 512 else 1024
    else 64
  else if arch = 'd' then
    if simds ≤ 2 ∧ keys > 8192 then 256
    else if simds ≥ 6 then
      if keys ≥ 16384 ∧ keys < 65536 then 512 else if keys ≥ 65536 then 1024 else 128
    else 128
  else if simds ≥ 4 then 64 else 32

def blocks (arch : Char) (x : Inputs) (override : Nat) : Nat :=
  if override > 0 then ((override+31)/32)*32
  else defaultBlocks arch x.keyLength ((x.queryHeads/x.keyHeads)*x.queryLength)

theorem qwen_no_gqa_variant (keys : Nat) (sinks : Bool) : gqaVariant (qwen keys) sinks = false := by
  simp [gqaVariant, qwen]

theorem default_values (arch : Char) (keys simds : Nat) :
    defaultBlocks arch keys simds ∈ [32, 64, 128, 256, 512, 1024] := by
  unfold defaultBlocks
  repeat' first | split | decide

theorem qwen_values (arch : Char) (keys : Nat) :
    blocks arch (qwen keys) 0 ∈ [64, 128, 256, 512, 1024] := by
  simp only [blocks, qwen, Nat.lt_irrefl, ↓reduceIte]
  change defaultBlocks arch keys 6 ∈ _
  unfold defaultBlocks
  repeat' first | split | decide | omega

theorem qwen_bounds (arch : Char) (keys : Nat) :
    64 ≤ blocks arch (qwen keys) 0 ∧ blocks arch (qwen keys) 0 ≤ 1024 ∧
      blocks arch (qwen keys) 0 % 32 = 0 := by
  have h := qwen_values arch keys
  simp only [List.mem_cons, List.not_mem_nil, or_false] at h
  rcases h with h | h | h | h | h <;> rw [h] <;> decide

theorem override_coverage (arch : Char) (x : Inputs) (override : Nat) (positive : 0 < override) :
    override ≤ blocks arch x override ∧ blocks arch x override < override+32 ∧
      blocks arch x override % 32 = 0 := by
  simp only [blocks, positive, ↓reduceIte]
  omega

theorem override_no_overflow (override : Nat) (bound : override ≤ 2147483616) :
    override+31 < 2^31 ∧ ((override+31)/32)*32 < 2^31 := by omega

def firstGrid (blockCount : Nat) : Nat × Nat × Nat := (4, 1, blockCount)
def firstThreads : Nat × Nat × Nat := (32, 6, 1)
def secondGrid : Nat × Nat × Nat := (24, 1, 1)
def secondThreads : Nat × Nat × Nat := (1024, 1, 1)

theorem geometry (blockCount : Nat) :
    firstGrid blockCount = (4, 1, blockCount) ∧ firstThreads = (32, 6, 1) ∧
      secondGrid = (24, 1, 1) ∧ secondThreads = (32*32, 1, 1) := ⟨rfl, rfl, rfl, rfl⟩

end Inference.Contracts.Mlx.SdpaTwoPassDispatch
