import kernels.quantization.AffineDequantizeSource
import layers.QuantizedEmbeddingGatherSource
import Mathlib.Data.List.OfFn

namespace Inference.Layers.QuantizedEmbeddingDequantizeSource
open Contracts.Mlx Kernels.Quantization QuantizedEmbeddingMemory
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
attribute [local irreducible] List.finRange AffineDequantize.value AffineDequantizeSource.arithmetic

variable {layer : QuantizedEmbedding.Layer} {token : Fin 248320}
variable (run : Execution layer token)

theorem current_value (memory : ByteMemory.Bytes) (thread : Fin 2560) (i : Fin 2) :
    AffineDequantizeSource.outputValue layer.contracted run.regions.packed run.regions.scales run.regions.biases memory thread.val i=
      dequantize layer run.regions memory (AffineDequantizeSource.coordinate thread i) := by
  obtain ⟨byte,coordinate,group⟩ := AffineDequantizeSource.coordinates thread i
  unfold AffineDequantizeSource.outputValue dequantize
  rw [byte,coordinate,group,AffineDequantizeSource.arithmetic_eq]

def programs (base : Nat) (values : Fin 5120 → BitVec 16) : List (List HalfMemory.Store) :=
  (List.finRange 2560).map (fun thread =>
    [HalfArrayWrites.entry base values (AffineDequantizeSource.coordinate thread 0),
      HalfArrayWrites.entry base values (AffineDequantizeSource.coordinate thread 1)])

private theorem flatten_singles {α β : Type} (items : List α) (f : α → β) :
    (items.map (fun i => [f i])).flatten=items.map f := by
  induction items with
  | nil => rfl
  | cons a rest ih => simp only [List.map_cons,List.flatten_cons,List.singleton_append,ih]

private theorem ofFn_two {α : Type} (f : Fin 2 → α) : List.ofFn f=[f 0,f 1] := by
  rw [List.ofFn_succ,List.ofFn_succ,List.ofFn_zero]
  rfl

theorem programs_flatten (base : Nat) (values : Fin 5120 → BitVec 16) :
    (programs base values).flatten=(HalfArrayWrites.programs base values).flatten := by
  rw [HalfArrayWrites.programs,flatten_singles]
  unfold programs List.finRange
  rw [List.map_ofFn,List.map_ofFn]
  have grouped := List.ofFn_mul (m:=2560) (n:=2) (HalfArrayWrites.entry base values)
  simp only [ofFn_two] at grouped
  exact grouped.symm

def threadSource (memory : ByteMemory.Bytes) (thread : Fin 2560) :=
  AffineDequantizeSource.execute layer.contracted run.regions.packed run.regions.scales run.regions.biases
    run.regions.output memory 2560 thread.val 0

theorem thread_prefix (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 run.regions.output 10240 stores) (thread : Fin 2560) :
    threadSource run (HalfMemory.execute stores run.p3.memory) thread=
      some [HalfArrayWrites.entry run.regions.output (fun i => ArrayStorage.bits (run.produced i))
          (AffineDequantizeSource.coordinate thread 0),
        HalfArrayWrites.entry run.regions.output (fun i => ArrayStorage.bits (run.produced i))
          (AffineDequantizeSource.coordinate thread 1)] := by
  unfold threadSource
  rw [AffineDequantizeSource.execution]
  simp only [Nat.mul_zero,Nat.add_zero]
  rw [current_value,current_value,run.during_dequantize stores inside,run.during_dequantize stores inside]
  rfl

private theorem map_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ i, f i=some (g i)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons a rest ih => simp only [List.mapM_cons,same,ih,List.map_cons]; rfl

theorem programs_prefix (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 run.regions.output 10240 stores) :
    (List.finRange 2560).mapM (threadSource run (HalfMemory.execute stores run.p3.memory))=
      some (programs run.regions.output (fun i => ArrayStorage.bits (run.produced i))) :=
  map_some _ _ _ (thread_prefix run stores inside)

theorem native_schedule :
    ThreadgroupWrites.Executes (programs run.regions.output (fun i => ArrayStorage.bits (run.produced i)))
      run.output.schedule (List.replicate 2560 []) := by
  have same : run.output.schedule=(programs run.regions.output (fun i => ArrayStorage.bits (run.produced i))).flatten :=
    (programs_flatten _ _).symm
  rw [same]
  simpa only [programs,List.length_map,List.length_finRange] using
    ThreadgroupWrites.canonical (programs run.regions.output (fun i => ArrayStorage.bits (run.produced i)))

theorem output_read (i : Fin 5120) :
    run.outputBuffer.read i=layer.forward token i := by
  exact (run.outputBuffer.read_correct i).trans (congrFun run.output_eq i)

end Inference.Layers.QuantizedEmbeddingDequantizeSource
