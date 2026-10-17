import state.TokenStorage
import kernels.sampling.GreedyDevice
import contracts.mlx.ArrayRelocation

namespace Inference.State.SampledToken
open Contracts.Mlx Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

variable {p : LogSumExpRanges.Platform} {logits : Fin 248320 → ArrayStorage.BF}

def selected (execution : GreedyDevice.Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) : Fin 248320 :=
  ⟨execution.token, execution.token_bound primitive bound⟩

-- Only the destination address changes. The actual sampler store schedule,
-- its selected raw uint32 word, and the output bounds are retained.
def stores (execution : GreedyDevice.Execution p logits) (memory : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :=
  ArrayRelocation.words execution.selection.output memory base aligned bounded

theorem readback (execution : GreedyDevice.Execution p logits) (memory : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :
    (ByteMemory.load32 (stores execution memory base aligned bounded).memory base).toNat=execution.token := by
  have raw := ArrayRelocation.words_read execution.selection.output memory base aligned bounded (0 : Fin 1)
  have number := congrArg BitVec.toNat raw
  simpa only [stores, Fin.val_zero, Nat.mul_zero, Nat.add_zero] using number.trans execution.token_read.symm

def buffer (execution : GreedyDevice.Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :
    TokenStorage.Buffer (selected execution primitive bound) :=
  TokenStorage.Buffer.fromRead _ (stores execution memory base aligned bounded).memory base aligned bounded
    (readback execution memory base aligned bounded)

theorem buffer_bytes (execution : GreedyDevice.Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :
    (buffer execution primitive bound memory base aligned bounded).bytes=(stores execution memory base aligned bounded).memory := rfl

theorem buffer_read (execution : GreedyDevice.Execution p logits) (primitive : LogSumExpRanges.Primitives p)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (memory : ByteMemory.Bytes) (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :
    (buffer execution primitive bound memory base aligned bounded).read=GreedySampling.sample p logits := by
  rw [TokenStorage.Buffer.read_correct]
  exact execution.token_eq primitive bound

theorem stores_inside (execution : GreedyDevice.Execution p logits) (memory : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4 ≤ 2^64) :
    MemoryRegions.Inside32 base 4 (stores execution memory base aligned bounded).schedule :=
  ArrayFrame.word_stores_inside _

end Inference.State.SampledToken
