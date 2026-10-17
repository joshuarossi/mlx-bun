import models.qwen.DecodeCacheGeometry
import models.qwen.Qwen38TrellisM1Max

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxCacheFootprint
open Contracts.Mlx DecodeStage DecodeChain

-- Sum the extents of actual cache regions. Pairwise separation is established
-- by the constructed executions; this excludes weights, workspace, local
-- memory, allocator overhead, and old buffers retained by the native runtime.
def regionBytes (regions : List DecodeCacheGeometry.Region) : Nat := (regions.map Prod.snd).sum

def stageBytes : Stage → Nat → Nat
  | .delta _, _ => 3207168
  | .attention _, tokens => 2*State.KvRegions.bytes tokens

def bytes : List Stage → Nat → Nat
  | [], _ => 0
  | stage::rest, tokens => stageBytes stage tokens+bytes rest tokens

theorem stage_regions (stage : Stage) (cache : Cache stage tokens) (stored : DecodeFrame.StageStorage stage cache) :
    regionBytes (DecodeCacheGeometry.stageRegions stage cache stored)=stageBytes stage tokens := by
  cases stage <;> simp [regionBytes,DecodeCacheGeometry.stageRegions,stageBytes,two_mul]

theorem actual_regions (stages : List Stage) (cache : Caches stages tokens) (memory : ByteMemory.Bytes)
    (stored : DecodeFrame.Storage stages cache memory) :
    regionBytes (DecodeCacheGeometry.regions stages cache memory stored)=bytes stages tokens := by
  induction stages with
  | nil => rfl
  | cons stage rest ih =>
    change regionBytes (DecodeCacheGeometry.stageRegions stage cache.1 stored.1.storage ++
      DecodeCacheGeometry.regions rest cache.2 memory stored.2)=_
    have append (first second : List DecodeCacheGeometry.Region) :
        regionBytes (first++second)=regionBytes first+regionBytes second := by simp [regionBytes]
    rw [append,stage_regions,ih]
    rfl

theorem counts (stages : List Stage) (tokens : Nat) :
    bytes stages tokens=
      (stages.filter (fun stage => !Qwen38TrellisM1Max.isAttention stage)).length*3207168+
      (stages.filter Qwen38TrellisM1Max.isAttention).length*(2*State.KvRegions.bytes tokens) := by
  induction stages with
  | nil => simp [bytes]
  | cons stage rest ih =>
    cases stage <;>
      simp only [bytes,stageBytes,ih,List.filter_cons,Qwen38TrellisM1Max.isAttention,
        Bool.not_false,Bool.not_true,ite_true,Bool.false_eq_true,ite_false,List.length_cons,Nat.add_mul,Nat.one_mul] <;> omega

theorem graph_bytes (graph : Qwen38TrellisM1Max.Graph) (tokens : Nat) :
    bytes graph.stages tokens=153944064+65536*State.KvAllocation.capacity tokens := by
  rw [counts,graph.delta_count,graph.attention_count]
  simp only [State.KvRegions.bytes]
  omega

theorem graph_bound (graph : Qwen38TrellisM1Max.Graph) (tokens : Nat) (supported : tokens≤262144) :
    bytes graph.stages tokens≤17333813248 := by
  rw [graph_bytes]
  have := State.KvAllocation.supported_capacity tokens supported
  omega

theorem actual_graph_bound (graph : Qwen38TrellisM1Max.Graph) (tokens : Nat)
    (cache : Caches graph.stages tokens) (memory : ByteMemory.Bytes)
    (stored : DecodeFrame.Storage graph.stages cache memory) (supported : tokens≤262144) :
    regionBytes (DecodeCacheGeometry.regions graph.stages cache memory stored)≤17333813248 := by
  rw [actual_regions]
  exact graph_bound graph tokens supported

theorem initial_bytes (graph : Qwen38TrellisM1Max.Graph) : bytes graph.stages 0=153944064 := by
  rw [graph_bytes,State.KvAllocation.capacity_zero]

theorem first_token_bytes (graph : Qwen38TrellisM1Max.Graph) : bytes graph.stages 1=170721280 := by
  rw [graph_bytes]
  rfl

end Inference.Models.Qwen.Qwen38TrellisM1MaxCacheFootprint
