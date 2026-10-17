import models.qwen.InitialCopiedWorkspace
import models.qwen.CopiedAttentionPositiveReuseAllocation
import state.KvGrowthAllocation
namespace Inference.Models.Qwen.CapacityCopiedWorkspace
open Contracts.Mlx Layers DecodeStage Kernels.Attention
open ResidualDeltaHighWater (Frontier)
set_option maxRecDepth 10000

-- The cursor counts cumulative reservations, not peak physical residency.
def readBytes (n : Nat) : Nat :=
  if n+1≤State.KvAllocation.capacity n then 2*State.KvRegions.bytes (n+1)
  else State.KvGrowthAllocation.bytes n+2*State.KvRegions.bytes (n+1)

def stageBytes (n : Nat) : Stage → Nat
  | .delta _ => ResidualDeltaAllocation.bytes
  | .attention layer => CopiedAttentionEntryAllocation.bytes+readBytes n+
      CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix (n+1)+ResidualMlpAllocation.bytes

def bytes (n : Nat) : List Stage → Nat
  | [] => 0
  | stage::rest => stageBytes n stage+bytes n rest

theorem read_aligned (n : Nat) : readBytes n%16=0 := by
  unfold readBytes
  split <;> simp only [State.KvRegions.bytes,State.KvGrowthAllocation.bytes,State.KvGrowthAllocation.tensorBytes] <;> omega

theorem stage_aligned (n : Nat) (stage : Stage) : stageBytes n stage%16=0 := by
  cases stage with
  | delta => simp only [stageBytes,ResidualDeltaAllocation.bytes]
  | attention layer =>
    have read := read_aligned n
    simp only [stageBytes,CopiedAttentionEntryAllocation.bytes,CopiedAttentionTailArena.bytes,
      SdpaWorkspace.bytes,AttentionTailAllocation.bytes,ResidualMlpAllocation.bytes]
    omega

theorem bytes_aligned (n : Nat) (stages : List Stage) : bytes n stages%16=0 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => simp only [bytes,Nat.add_mod,stage_aligned,ih,Nat.zero_add,Nat.zero_mod]

def next (n : Nat) (frontier : Frontier) (stage : Stage) : Frontier where
  cursor := frontier.cursor+stageBytes n stage
  aligned := by rw [Nat.add_mod,frontier.aligned,stage_aligned]

theorem head_room (n : Nat) (frontier : Frontier) (stage : Stage) (rest : List Stage)
    (room : frontier.cursor+bytes n (stage::rest)≤2^64) : (next n frontier stage).cursor≤2^64 := by
  dsimp only [next,bytes] at *
  omega

theorem tail_room (n : Nat) (frontier : Frontier) (stage : Stage) (rest : List Stage)
    (room : frontier.cursor+bytes n (stage::rest)≤2^64) : (next n frontier stage).cursor+bytes n rest≤2^64 := by
  simpa only [next,bytes,Nat.add_assoc] using room

end Inference.Models.Qwen.CapacityCopiedWorkspace
