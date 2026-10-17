import kernels.sampling.LogSumExpSourceArithmetic
import kernels.sampling.LogSumExpSourceGeometry
namespace Inference.Kernels.Sampling.LogSumExpSourceLoop
open Contracts.Mlx
set_option maxRecDepth 10000

-- The selected one-row pointer update has gid=0. Setup creates the finite
-- minimum float sentinel and positive-zero normalizer before any input load.
def initial : LogSumExpBlockRanges.State := ⟨Float32.ofBits 0xff7fffff,0⟩

def loop (p : Attention.SdpaUpdate.Platform) (memory : ByteMemory.Bytes) (base : Nat) (thread : Fin 1024) :
    (count : Nat)→count≤61→LogSumExpBlockRanges.State
  | 0,_ => initial
  | count+1,bound => LogSumExpSourceArithmetic.block p (loop p memory base thread count (by omega))
      (LogSumExpSourceGeometry.load memory base ⟨count,by omega⟩ thread)

def checkedPrefix {α : Type} (result : Option α) : Option α := do
  let code ←LogSumExpSourceSyntax.parse LogSumExpSourceSyntax.bodyTokens
  match code with
  | .pointer::.setup::.loop::_ => result
  | _ => none

theorem prefix_eq {α : Type} (result : Option α) : checkedPrefix result=result := by
  rw [checkedPrefix,LogSumExpSourceSyntax.parsed]
  rfl

def executeThread (p : Attention.SdpaUpdate.Platform) (memory : ByteMemory.Bytes) (base : Nat) (thread : Fin 1024) :
    Option LogSumExpBlockRanges.State := checkedPrefix (some (loop p memory base thread 61 (by decide)))

theorem loop_model {logits : Fin 248320→ArrayStorage.BF} (source : ArrayStorage.BFBuffer logits)
    (p : Attention.SdpaUpdate.Platform) (thread : Fin 1024) (count : Nat) (bound : count≤61) :
    loop p source.bytes source.base thread count bound=
      LogSumExpLoopRanges.loop p (fun i=>BFloat16.widen (logits i)) thread count bound := by
  induction count with
  | zero => rfl
  | succ count ih =>
    rw [loop,LogSumExpLoopRanges.loop,ih,LogSumExpSourceArithmetic.block_model]
    congr 1
    funext read
    exact LogSumExpSourceGeometry.load_source source _ thread read

theorem thread_execution {logits : Fin 248320→ArrayStorage.BF} (source : ArrayStorage.BFBuffer logits)
    (p : Attention.SdpaUpdate.Platform) (thread : Fin 1024) :
    executeThread p source.bytes source.base thread=
      some (LogSumExpLoopRanges.localState p (fun i=>BFloat16.widen (logits i)) thread) := by
  rw [executeThread,prefix_eq,loop_model source]
  rfl

-- This quantifies over the same protected current global heap used by the
-- original sampler memory execution, including later output-store prefixes.
theorem current_thread {logits : Fin 248320→ArrayStorage.BF} {source : ArrayStorage.BFBuffer logits}
    {p : LogSumExpRanges.Platform} (execution : LogSumExpMemory.Execution p source)
    (stores : List HalfMemory.Store) (subset : ∀ store∈stores,store∈execution.output.schedule) (thread : Fin 1024) :
    executeThread p.scalar (HalfMemory.execute stores source.bytes) source.base thread=
      some (LogSumExpLoopRanges.localState p.scalar (fun i=>BFloat16.widen (logits i)) thread) :=
  thread_execution (execution.sourceDuring stores subset) p.scalar thread
end Inference.Kernels.Sampling.LogSumExpSourceLoop
