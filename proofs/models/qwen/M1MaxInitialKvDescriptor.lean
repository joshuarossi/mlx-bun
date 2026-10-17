import models.qwen.M1MaxSingleTokenEntry
import models.qwen.AttentionInitialWorkspaceConstruction
import models.qwen.KvInitialKernelMemory
import kernels.copy.GeneralCopy2DHostDispatch

namespace Inference.Models.Qwen.M1MaxInitialKvDescriptor
open Contracts.Mlx State Kernels.Attention Kernels.Copy
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

-- A descriptor of the CONSTRUCTED memory, not an assertion about metadata
-- extracted from an MLX array object. In particular allocation/active logical
-- sizes are not substituted for native data_size or donation eligibility.
structure Plane where
  memory : ByteMemory.Bytes
  base : Nat
  aligned : base%2=0
  capacity : Nat
  length : Nat
  room : length≤capacity
  bounded : base+2*(4*capacity*256)≤2^64

def Plane.shape (plane : Plane) : List Nat := [1,4,plane.capacity,256]
def Plane.activeShape (plane : Plane) : List Nat := [1,4,plane.length,256]
def Plane.strides (plane : Plane) : List Nat := [4*plane.capacity*256,plane.capacity*256,256,1]
def Plane.address (plane : Plane) (head : Fin 4) (time : Nat) (i : Fin 256) : Nat :=
  plane.base+2*((head.val*plane.capacity+time)*256+i.val)

def keys {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) : Plane where
  memory := storage.memory
  base := storage.layout.keyBase
  aligned := storage.layout.keyAligned
  capacity := KvAllocation.capacity n
  length := n
  room := (KvAllocation.capacity_bounds n).1
  bounded := storage.layout.keyBound

def values {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) : Plane where
  memory := storage.memory
  base := storage.layout.valueBase
  aligned := storage.layout.valueAligned
  capacity := KvAllocation.capacity n
  length := n
  room := (KvAllocation.capacity_bounds n).1
  bounded := storage.layout.valueBound

theorem key_read {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache)
    (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load (keys storage).memory ((keys storage).address head time.val i)=KvBytes.bits (cache.keys head time i) :=
  storage.keys head time i

theorem value_read {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache)
    (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load (values storage).memory ((values storage).address head time.val i)=KvBytes.bits (cache.values head time i) :=
  storage.values head time i

theorem address_bounds (plane : Plane) (head : Fin 4) (time : Fin plane.length) (i : Fin 256) :
    plane.base≤plane.address head time.val i ∧ plane.address head time.val i+2≤plane.base+2*(4*plane.capacity*256) := by
  have bound := Kv.address_bounds plane.capacity head time.val i (time.isLt.trans_le plane.room)
  change (head.val*plane.capacity+time.val)*256+i.val<4*plane.capacity*256 at bound
  dsimp [Plane.address]
  omega

variable {layer : ResidualAttention.Layer} {original : Fin 5120 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF 0}
    {source : ResidualAttentionStorageConstruction.Source layer cache original}
    (workspace : AttentionInitialWorkspaceConstruction.Workspace source) (angle : RopeAngles.Inputs)
    (keyCopied valueCopied : Bool)

def keyPlane := keys (workspace.read angle keyCopied valueCopied).input.cache
def valuePlane := values (workspace.read angle keyCopied valueCopied).input.cache

theorem planes_shared : (keyPlane workspace angle keyCopied valueCopied).memory=
    (valuePlane workspace angle keyCopied valueCopied).memory := rfl

theorem planes_shape :
    (keyPlane workspace angle keyCopied valueCopied).shape=M1MaxSingleTokenEntry.initialZeroShape ∧
    (valuePlane workspace angle keyCopied valueCopied).shape=M1MaxSingleTokenEntry.initialZeroShape := ⟨rfl,rfl⟩

theorem storage_active {cache : Kv.Cache Kv.BF 1} (storage : KvRegions.Storage cache) :
    (keys storage).activeShape=[1,4,1,256] ∧
    (values storage).activeShape=[1,4,1,256] ∧
    (keys storage).strides=[262144,65536,256,1] ∧
    (values storage).strides=[262144,65536,256,1] := by
  norm_num [keys,values,Plane.activeShape,Plane.strides,KvAllocation.capacity]

theorem planes_active :
    (keyPlane workspace angle keyCopied valueCopied).activeShape=[1,4,1,256] ∧
    (valuePlane workspace angle keyCopied valueCopied).activeShape=[1,4,1,256] ∧
    (keyPlane workspace angle keyCopied valueCopied).strides=[262144,65536,256,1] ∧
    (valuePlane workspace angle keyCopied valueCopied).strides=[262144,65536,256,1] :=
  storage_active (workspace.read angle keyCopied valueCopied).input.cache

-- The prefix is a view on the full slab; it keeps the 65536-word head stride.
-- No independently encoded or compacted heap is introduced.
theorem active_layout (head : Fin 4) (i : Fin 256) :
    (keyPlane workspace angle keyCopied valueCopied).address head 0 i=
      (workspace.read angle keyCopied valueCopied).input.cache.layout.keyBase+2*(head.val*65536+i.val) ∧
    (valuePlane workspace angle keyCopied valueCopied).address head 0 i=
      (workspace.read angle keyCopied valueCopied).input.cache.layout.valueBase+2*(head.val*65536+i.val) := by
  constructor <;> dsimp [keyPlane,valuePlane,keys,values,Plane.address,KvAllocation.capacity] <;> omega

theorem active_key_read (head : Fin 4) (i : Fin 256) :
    HalfMemory.load (keyPlane workspace angle keyCopied valueCopied).memory
      ((keyPlane workspace angle keyCopied valueCopied).address head 0 i)=
      KvBytes.bits ((layer.mixer.heads (layer.inputNorm.forward original) angle).key head i) := by
  exact (key_read (workspace.read angle keyCopied valueCopied).input.cache head ⟨0,by decide⟩ i).trans
    (congrArg KvBytes.bits (Kv.append_keys_new _ _ _ head i))

theorem active_value_read (head : Fin 4) (i : Fin 256) :
    HalfMemory.load (valuePlane workspace angle keyCopied valueCopied).memory
      ((valuePlane workspace angle keyCopied valueCopied).address head 0 i)=
      KvBytes.bits ((layer.mixer.heads (layer.inputNorm.forward original) angle).value head i) := by
  exact (value_read (workspace.read angle keyCopied valueCopied).input.cache head ⟨0,by decide⟩ i).trans
    (congrArg KvBytes.bits (Kv.append_values_new _ _ _ head i))

-- The descriptor heap is exactly the completed parsed/event GG2 value-row
-- kernel heap, after key preservation/update and value preservation.
theorem completed_kernel_heap :
    (KvInitialKernelMemory.prefixValueChecked (workspace.read angle keyCopied valueCopied)).eventAfter.memory=
      (keyPlane workspace angle keyCopied valueCopied).memory ∧
    (KvInitialKernelMemory.prefixValueChecked (workspace.read angle keyCopied valueCopied)).eventAfter.memory=
      (valuePlane workspace angle keyCopied valueCopied).memory :=
  ⟨KvInitialKernelMemory.prefix_value_heap _,KvInitialKernelMemory.prefix_value_heap _⟩

-- Native runtime SourceDescriptor and pointer extraction remain explicit
-- inputs to host binding. They concern source allocation metadata, not any
-- desired output or completed execution.
theorem key_dispatch (descriptor : KvRowDispatchGeometry.SourceDescriptor (workspace.front angle).keySource)
    (batchStride timeStride : Nat) (batchSmall : batchStride<2^63) (timeSmall : timeStride<2^63) :
    KvRowDispatchGeometry.Selection (workspace.front angle).keySource descriptor batchStride timeStride 256 0 :=
  KvRowDispatchGeometry.selected _ descriptor _ _ _ _ batchSmall timeSmall (by decide) (by decide) (by decide)

theorem value_dispatch (descriptor : KvRowDispatchGeometry.SourceDescriptor (workspace.front angle).valueSource)
    (batchStride timeStride : Nat) (batchSmall : batchStride<2^63) (timeSmall : timeStride<2^63) :
    KvRowDispatchGeometry.Selection (workspace.front angle).valueSource descriptor batchStride timeStride 256 0 :=
  KvRowDispatchGeometry.selected _ descriptor _ _ _ _ batchSmall timeSmall (by decide) (by decide) (by decide)

-- Exact address identity between the selected GG2 row write and each active
-- descriptor coordinate. This identifies a view on the written slab, not a
-- second compact buffer.
theorem row_address {next : KvBytes.Row} (source : KvCopy.Source next) (plane : Plane)
    (capacity : plane.capacity=256) (label : KvBytes.Label) :
    (KvCopy.layout source plane.base 256 0).destinationBase+
      2*Copy2D.destination (KvCopy.layout source plane.base 256 0).destinationRow label=
      plane.address label.1 0 label.2 := by
  rw [(KvRowDispatchGeometry.layout_addresses source plane.base 256 0 label).2]
  dsimp [Plane.address]
  rw [capacity]
  ring

theorem key_row_address (label : KvBytes.Label) :
    (KvCopy.layout (workspace.front angle).keySource (keyPlane workspace angle keyCopied valueCopied).base 256 0).destinationBase+
      2*Copy2D.destination (KvCopy.layout (workspace.front angle).keySource
        (keyPlane workspace angle keyCopied valueCopied).base 256 0).destinationRow label=
      (keyPlane workspace angle keyCopied valueCopied).address label.1 0 label.2 :=
  row_address _ _ rfl label

theorem value_row_address (label : KvBytes.Label) :
    (KvCopy.layout (workspace.front angle).valueSource (valuePlane workspace angle keyCopied valueCopied).base 256 0).destinationBase+
      2*Copy2D.destination (KvCopy.layout (workspace.front angle).valueSource
        (valuePlane workspace angle keyCopied valueCopied).base 256 0).destinationRow label=
      (valuePlane workspace angle keyCopied valueCopied).address label.1 0 label.2 :=
  row_address _ _ rfl label

variable (request : M1MaxSingleTokenEntry.Request) (domain : M1MaxSingleTokenEntry.Domain request)

theorem host_to_planes (domain : M1MaxSingleTokenEntry.Domain request) :
    M1MaxSingleTokenEntry.appendBranch M1MaxSingleTokenEntry.newKv 0 request.promptTokens=.initial ∧
    (keyPlane workspace angle keyCopied valueCopied).shape=
      [request.sequences,4,M1MaxSingleTokenEntry.zeroTokens request.promptTokens,256] ∧
    (keyPlane workspace angle keyCopied valueCopied).activeShape=[request.sequences,4,request.promptTokens,256] ∧
    (valuePlane workspace angle keyCopied valueCopied).shape=(keyPlane workspace angle keyCopied valueCopied).shape ∧
    (valuePlane workspace angle keyCopied valueCopied).activeShape=(keyPlane workspace angle keyCopied valueCopied).activeShape := by
  rw [domain.promptTokens,domain.sequences]
  exact ⟨M1MaxSingleTokenEntry.initial_branch 0,rfl,rfl,rfl,rfl⟩

end Inference.Models.Qwen.M1MaxInitialKvDescriptor
