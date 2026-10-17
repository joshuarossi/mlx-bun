import kernels.copy.GatherFrontSource
import layers.QuantizedEmbeddingMemory

namespace Inference.Layers.QuantizedEmbeddingGatherSource
open Contracts.Mlx Kernels.Copy QuantizedEmbeddingMemory
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange WordArrayWrites.programs

variable {layer : QuantizedEmbedding.Layer} {token : Fin 248320}
variable (run : Execution layer token)

def packedThread (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) (thread : Fin 640) :=
  GatherFrontSource.execute unsigned 1 640 248320 heap.memory run.tokenBuffer.base thread.val 0
    (fun index => ByteMemory.load32 heap.memory (run.storage.packedBase+4*index))
    (fun index value => (⟨run.regions.packed/4+index,value⟩ : ByteMemory.Store))

def parameterThread (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes)
    (source destination : Nat) (thread : Fin 40) :=
  GatherFrontSource.execute unsigned 2 80 248320 heap.memory run.tokenBuffer.base thread.val 0
    (fun index => HalfMemory.load heap.memory (source+2*index))
    (fun index value => (⟨destination/2+index,value⟩ : HalfMemory.Store))

private theorem parameter_read {values : Fin 248320 → Fin 80 → ArrayStorage.BF}
    (buffer : ArrayStorage.BFBuffer (RowStorage.flatten values)) (row : Fin 248320) (i : Fin 80) :
    HalfMemory.load buffer.bytes (buffer.base+2*(row.val*80+i.val))=ArrayStorage.bits (values row i) := by
  have result := buffer.attached (RowStorage.index row i)
  rw [RowStorage.index_value,RowStorage.flatten_index] at result
  exact result

theorem packed_thread (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) (thread : Fin 640) :
    packedThread run unsigned heap thread=
      some [WordArrayWrites.entry run.regions.packed run.packedValues thread] := by
  have source := GatherFrontSource.packed_thread unsigned (run.tokenAt heap) thread
    (fun index => ByteMemory.load32 heap.memory (run.storage.packedBase+4*index))
    (fun index value => (⟨run.regions.packed/4+index,value⟩ : ByteMemory.Store))
  change packedThread run unsigned heap thread=_ at source
  rw [source,run.packedValues_eq]
  have read := (run.storageAt heap).attached token thread
  change ByteMemory.load32 heap.memory (run.storage.packedBase+4*(token.val*640+thread.val))=_ at read
  rw [read]
  rfl

theorem scales_thread (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) (thread : Fin 40) :
    parameterThread run unsigned heap run.storage.scales.base run.regions.scales thread=
      some [HalfArrayWrites.entry run.regions.scales (fun i => ArrayStorage.bits (run.scaleValues i))
          ⟨2*thread.val,by have := thread.isLt; omega⟩,
        HalfArrayWrites.entry run.regions.scales (fun i => ArrayStorage.bits (run.scaleValues i))
          ⟨2*thread.val+1,by have := thread.isLt; omega⟩] := by
  have source := GatherFrontSource.parameter_thread unsigned (run.tokenAt heap) thread
    (fun index => HalfMemory.load heap.memory (run.storage.scales.base+2*index))
    (fun index value => (⟨run.regions.scales/2+index,value⟩ : HalfMemory.Store))
  change parameterThread run unsigned heap run.storage.scales.base run.regions.scales thread=_ at source
  rw [source,run.scaleValues_eq]
  have first := parameter_read (run.storageAt heap).scales token ⟨2*thread.val,by have := thread.isLt; omega⟩
  have second := parameter_read (run.storageAt heap).scales token ⟨2*thread.val+1,by have := thread.isLt; omega⟩
  change HalfMemory.load heap.memory (run.storage.scales.base+2*(token.val*80+2*thread.val))=_ at first
  change HalfMemory.load heap.memory (run.storage.scales.base+2*(token.val*80+(2*thread.val+1)))=_ at second
  rw [first,second]
  rfl

theorem biases_thread (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) (thread : Fin 40) :
    parameterThread run unsigned heap run.storage.biases.base run.regions.biases thread=
      some [HalfArrayWrites.entry run.regions.biases (fun i => ArrayStorage.bits (run.biasValues i))
          ⟨2*thread.val,by have := thread.isLt; omega⟩,
        HalfArrayWrites.entry run.regions.biases (fun i => ArrayStorage.bits (run.biasValues i))
          ⟨2*thread.val+1,by have := thread.isLt; omega⟩] := by
  have source := GatherFrontSource.parameter_thread unsigned (run.tokenAt heap) thread
    (fun index => HalfMemory.load heap.memory (run.storage.biases.base+2*index))
    (fun index value => (⟨run.regions.biases/2+index,value⟩ : HalfMemory.Store))
  change parameterThread run unsigned heap run.storage.biases.base run.regions.biases thread=_ at source
  rw [source,run.biasValues_eq]
  have first := parameter_read (run.storageAt heap).biases token ⟨2*thread.val,by have := thread.isLt; omega⟩
  have second := parameter_read (run.storageAt heap).biases token ⟨2*thread.val+1,by have := thread.isLt; omega⟩
  change HalfMemory.load heap.memory (run.storage.biases.base+2*(token.val*80+2*thread.val))=_ at first
  change HalfMemory.load heap.memory (run.storage.biases.base+2*(token.val*80+(2*thread.val+1)))=_ at second
  rw [first,second]
  rfl

private theorem map_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ i, f i=some (g i)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons a rest ih => simp only [List.mapM_cons,same,ih,List.map_cons]; rfl

theorem packed_programs (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) :
    (List.finRange 640).mapM (packedThread run unsigned heap)=
      some (WordArrayWrites.programs run.regions.packed run.packedValues) := by
  unfold WordArrayWrites.programs
  exact map_some _ _ _ (packed_thread run unsigned heap)

theorem scales_programs (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) :
    (List.finRange 40).mapM (parameterThread run unsigned heap run.storage.scales.base run.regions.scales)=
      some (parameterPrograms run.regions.scales (fun i => ArrayStorage.bits (run.scaleValues i))) := by
  exact map_some _ _ _ (scales_thread run unsigned heap)

theorem biases_programs (unsigned : Bool) (heap : Prefix run.regions run.tokenBuffer.bytes) :
    (List.finRange 40).mapM (parameterThread run unsigned heap run.storage.biases.base run.regions.biases)=
      some (parameterPrograms run.regions.biases (fun i => ArrayStorage.bits (run.biasValues i))) := by
  exact map_some _ _ _ (biases_thread run unsigned heap)

-- The prefix includes any subset of the existing copy's stores, so these
-- source-program equalities retain current-heap reads throughout that copy.
theorem packed_prefix (unsigned : Bool) (stores : List ByteMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ run.packed.schedule) :
    (List.finRange 640).mapM (packedThread run unsigned (run.duringPacked stores subset))=
      some (WordArrayWrites.programs run.regions.packed run.packedValues) :=
  packed_programs run unsigned _

theorem scales_prefix (unsigned : Bool) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ run.scales.schedule) :
    (List.finRange 40).mapM (parameterThread run unsigned (run.duringScales stores subset)
      run.storage.scales.base run.regions.scales)=
      some (parameterPrograms run.regions.scales (fun i => ArrayStorage.bits (run.scaleValues i))) :=
  scales_programs run unsigned _

theorem biases_prefix (unsigned : Bool) (stores : List HalfMemory.Store)
    (subset : ∀ store ∈ stores, store ∈ run.biases.schedule) :
    (List.finRange 40).mapM (parameterThread run unsigned (run.duringBiases stores subset)
      run.storage.biases.base run.regions.biases)=
      some (parameterPrograms run.regions.biases (fun i => ArrayStorage.bits (run.biasValues i))) :=
  biases_programs run unsigned _

end Inference.Layers.QuantizedEmbeddingGatherSource
