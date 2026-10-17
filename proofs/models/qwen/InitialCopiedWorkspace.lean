import models.qwen.CopiedAttentionEntryAllocation
import models.qwen.CopiedAttentionInitialReadAllocation
import models.qwen.CopiedAttentionTailArena
import models.qwen.ResidualMlpAllocation
namespace Inference.Models.Qwen.InitialCopiedWorkspace
open Contracts.Mlx Layers DecodeStage Kernels.Attention
open ResidualDeltaHighWater (Frontier)
set_option maxRecDepth 10000

-- This is the monotone proof frontier for the actual copied first-token
-- constructors. It is not a physical peak-memory or reuse claim.
def stageBytes : Stage → Nat
  | .delta _ => ResidualDeltaAllocation.bytes
  | .attention layer => CopiedAttentionEntryAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes+
      CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix 1+ResidualMlpAllocation.bytes

def bytes : List Stage → Nat
  | [] => 0
  | stage::rest => stageBytes stage+bytes rest

theorem stage_aligned (stage : Stage) : stageBytes stage%16=0 := by
  cases stage <;> simp only [stageBytes,CopiedAttentionEntryAllocation.bytes,CopiedAttentionInitialReadAllocation.bytes,
    CopiedAttentionTailArena.bytes,SdpaWorkspace.bytes,AttentionTailAllocation.bytes,ResidualMlpAllocation.bytes,
    ResidualDeltaAllocation.bytes,State.KvRegions.bytes,State.KvAllocation.capacity]; omega

theorem bytes_aligned (stages : List Stage) : bytes stages%16=0 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => simp only [bytes,Nat.add_mod,stage_aligned,ih,Nat.zero_add,Nat.zero_mod]

def next (frontier : Frontier) (stage : Stage) : Frontier where
  cursor := frontier.cursor+stageBytes stage
  aligned := by rw [Nat.add_mod,frontier.aligned,stage_aligned]

theorem next_cursor (frontier : Frontier) (stage : Stage) :
    (next frontier stage).cursor=frontier.cursor+stageBytes stage := rfl

theorem head_room (frontier : Frontier) (stage : Stage) (rest : List Stage)
    (room : frontier.cursor+bytes (stage::rest)≤2^64) : (next frontier stage).cursor≤2^64 := by
  dsimp only [next,bytes] at *
  omega

theorem tail_room (frontier : Frontier) (stage : Stage) (rest : List Stage)
    (room : frontier.cursor+bytes (stage::rest)≤2^64) : (next frontier stage).cursor+bytes rest≤2^64 := by
  simpa only [next,bytes,Nat.add_assoc] using room
end Inference.Models.Qwen.InitialCopiedWorkspace
