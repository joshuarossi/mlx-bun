import models.qwen.CopiedTokenFinishSafety
import models.qwen.FinalProjectionStorageLineage

namespace Inference.Models.Qwen.CopiedTokenFinishRequest
open Contracts.Mlx Layers TokenInference Kernels.Attention FinalProjectionSamplerAllocation
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  TokenAutoregressiveMemoryConstruction.Entry.source TokenAutoregressiveMemoryConstruction.Entry.storage

private theorem protected_addresses (p : AffineVerifyLinear.Projection steps rows)
    (first second : AffineDevice.Storage p) (same : AffineStorageLineage.addresses p first=AffineStorageLineage.addresses p second)
    (property : Nat → Nat → Prop) :
    AffineMemoryFrames.Protected p first property ↔ AffineMemoryFrames.Protected p second property := by
  cases p <;> simp only [AffineStorageLineage.addresses,Prod.mk.injEq] at same <;>
    dsimp [AffineMemoryFrames.Protected] <;> rw [same.1,same.2.1,same.2.2]

namespace Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : InitialCopiedTokenConstruction.BodyPlan embedding angle)

def request (cursor : Nat) (aligned : cursor%16=0) (room : cursor+bytes≤2^64)
    (source : Before cursor body.hiddenBuffer.base 10240) (parameters : original.Protected (Before cursor)) :
    Request body.finalStorage where
  cursor := cursor
  aligned := aligned
  room := room
  source := by rw [body.final_source]; exact source
  norm := by rw [body.final_norm_base]; exact parameters.2.2.2.2.1
  weights := (protected_addresses p.graph.output body.finalStorage.outputWeights original.graph.output
    (FinalProjectionStorageLineage.initial_addresses body) (Before cursor)).mpr parameters.2.2.2.2.2

theorem cursor_eq (cursor : Nat) (aligned : cursor%16=0) (room : cursor+bytes≤2^64)
    (source : Before cursor body.hiddenBuffer.base 10240) (parameters : original.Protected (Before cursor)) :
    (request body cursor aligned room source parameters).cursor=cursor := rfl
end Initial

namespace Capacity
variable {p : Pipeline} {n : Nat} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  {embedding : TokenParameterConstruction.EmbeddingPlan original} {angle : RopeAngles.Inputs}
  (body : CapacityCopiedTokenConstruction.BodyPlan embedding angle)

def request (cursor : Nat) (aligned : cursor%16=0) (room : cursor+bytes≤2^64)
    (source : Before cursor body.hiddenBuffer.base 10240) (parameters : original.Protected (Before cursor)) :
    Request body.finalStorage where
  cursor := cursor
  aligned := aligned
  room := room
  source := by rw [body.final_source]; exact source
  norm := by rw [body.final_norm_base]; exact parameters.2.2.2.2.1
  weights := (protected_addresses p.graph.output body.finalStorage.outputWeights original.graph.output
    (FinalProjectionStorageLineage.capacity_addresses body) (Before cursor)).mpr parameters.2.2.2.2.2

theorem cursor_eq (cursor : Nat) (aligned : cursor%16=0) (room : cursor+bytes≤2^64)
    (source : Before cursor body.hiddenBuffer.base 10240) (parameters : original.Protected (Before cursor)) :
    (request body cursor aligned room source parameters).cursor=cursor := rfl
end Capacity

end Inference.Models.Qwen.CopiedTokenFinishRequest
