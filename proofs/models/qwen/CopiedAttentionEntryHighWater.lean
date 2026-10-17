import models.qwen.CopiedAttentionEntryAllocation
namespace Inference.Models.Qwen.CopiedAttentionEntryHighWater
open Contracts.Mlx Layers
set_option maxRecDepth 10000

def Before (cursor base size : Nat) : Prop := base+size≤cursor

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  (source : ArrayStorage.BFBuffer input) (parameters : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (cursor : Nat) (aligned : cursor%16=0) (room : cursor+CopiedAttentionEntryAllocation.bytes≤2^64)
  (sourceBelow : Before cursor source.base 10240) (parametersBelow : parameters.Protected (Before cursor))

def workspace : CopiedAttentionEntryAllocation.Workspace source parameters where
  base := cursor
  aligned := by omega
  bounded := room
  sourceSeparate := Or.inr sourceBelow
  parametersSeparate := parameters.protected_mono (fun _ _ below => Or.inr below) parametersBelow

def next : Nat := cursor+CopiedAttentionEntryAllocation.bytes

include aligned in
theorem next_aligned : (next cursor)%16=0 := by
  unfold next CopiedAttentionEntryAllocation.bytes
  omega

include room in
theorem next_bounded : next cursor≤2^64 := room

theorem below_next {base size : Nat} (below : Before cursor base size) : Before (next cursor) base size := by
  unfold Before next at *
  omega

theorem frame {base size : Nat} (below : Before cursor base size) (offset : Nat) (bound : offset<size) :
    CopiedAttentionEntryAllocation.memory (workspace source parameters cursor aligned room sourceBelow parametersBelow) (base+offset)=
      source.bytes (base+offset) :=
  CopiedAttentionEntryAllocation.other_region _ (Or.inr below) offset bound

theorem retained_parameters :
    (CopiedAttentionEntryAllocation.parametersAfter (workspace source parameters cursor aligned room sourceBelow parametersBelow)).Protected (Before (next cursor)) :=
  (CopiedAttentionEntryAllocation.parameters_protected _ _).mpr
    (parameters.protected_mono (fun _ _ below => below_next cursor below) parametersBelow)

theorem normalized_base :
    (NormalizationMemory.forwardBuffer (CopiedAttentionEntryAllocation.normal
      (workspace source parameters cursor aligned room sourceBelow parametersBelow))).base=cursor :=
  CopiedAttentionEntryAllocation.normal_base _

end Inference.Models.Qwen.CopiedAttentionEntryHighWater
