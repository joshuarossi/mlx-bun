import layers.DeltaHeads
import kernels.delta.GatedInputs
import contracts.mlx.CopyContiguous

namespace Inference.Layers.DeltaHeadsDevice
open Contracts.Mlx Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF

structure Storage (input : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) where
  input : ArrayStorage.BFBuffer input
  qScale : ArrayStorage.BFBuffer qScale
  kScale : ArrayStorage.BFBuffer kScale

@[irreducible] def produced (p : SiluRmsHeads.Platform) (width eps : Float32) (storage : Storage input qScale kScale) :
    DeltaHeads.Output 1 BF where
  q _ head := SiluRmsHeads.sourceNormalized p (fun i => storage.input.read (DeltaHeads.channel (DeltaHeads.qHead head) i)) storage.qScale.read width eps
  k _ head := SiluRmsHeads.sourceNormalized p (fun i => storage.input.read (DeltaHeads.channel (DeltaHeads.kHead head) i)) storage.kScale.read width eps
  v _ head i := SiluRmsHeads.activate p (storage.input.read (DeltaHeads.channel (DeltaHeads.vHead head) i))

theorem produced_eq (p : SiluRmsHeads.Platform) (width eps : Float32) (storage : Storage input qScale kScale) :
    produced p width eps storage=DeltaHeads.forward p (fun _ => input) qScale kScale width eps := by
  have qRead : storage.qScale.read=qScale := funext storage.qScale.read_correct
  have kRead : storage.kScale.read=kScale := funext storage.kScale.read_correct
  have source_eq : ∀ x w, SiluRmsHeads.sourceNormalized p x w width eps=SiluRmsHeads.normalized p x w width eps :=
    fun x w => funext (SiluRmsHeads.normalized_execution p x w width eps)
  unfold produced DeltaHeads.forward DeltaHeads.slice
  simp only [ArrayStorage.BFBuffer.read_correct, qRead, kRead, source_eq]

-- The Q, K and V head ranges are disjoint threadgroups. Each thread
-- writes four words to exactly one of the three separate allocations.
structure Execution (p : SiluRmsHeads.Platform) (width eps : Float32) (input : Fin 10240 → BF) (qScale kScale : Fin 128 → BF) where
  storage : Storage input qScale kScale
  qStores : CopyContiguous.Trace 0 (blocks := 512) (fun i => ArrayStorage.bits (GatedInputs.flatten ((produced p width eps storage).q 0) i))
  kStores : CopyContiguous.Trace 0 (blocks := 512) (fun i => ArrayStorage.bits (GatedInputs.flatten ((produced p width eps storage).k 0) i))
  vStores : CopyContiguous.Trace 0 (blocks := 1536) (fun i => ArrayStorage.bits (GatedInputs.flatten ((produced p width eps storage).v 0) i))

def Execution.fromStorage (p : SiluRmsHeads.Platform) (width eps : Float32) (input : Fin 10240 → BF) (qScale kScale : Fin 128 → BF)
    (storage : Storage input qScale kScale) : Execution p width eps input qScale kScale :=
  ⟨storage, CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide),
    CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide), CopyContiguous.Trace.canonical 0 _ (fun _ => 0) (by decide)⟩

variable {p : SiluRmsHeads.Platform} {width eps : Float32} {input : Fin 10240 → BF} {qScale kScale : Fin 128 → BF}

def Execution.qBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((produced p width eps execution.storage).q 0)) :=
  ⟨execution.qStores.memory, 0, by decide, by decide, execution.qStores.read_correct⟩
def Execution.kBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((produced p width eps execution.storage).k 0)) :=
  ⟨execution.kStores.memory, 0, by decide, by decide, execution.kStores.read_correct⟩
def Execution.vBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten ((produced p width eps execution.storage).v 0)) :=
  ⟨execution.vStores.memory, 0, by decide, by decide, execution.vStores.read_correct⟩

def Execution.output (execution : Execution p width eps input qScale kScale) : DeltaHeads.Output 1 BF where
  q _ head i := execution.qBuffer.read (GatedInputs.index head i)
  k _ head i := execution.kBuffer.read (GatedInputs.index head i)
  v _ head i := execution.vBuffer.read (GatedInputs.index head i)

theorem Execution.output_eq (execution : Execution p width eps input qScale kScale) :
    execution.output=DeltaHeads.forward p (fun _ => input) qScale kScale width eps := by
  unfold Execution.output
  simp only [ArrayStorage.BFBuffer.read_correct, GatedInputs.flatten_index, produced_eq]
  rfl

private def readBuffer {values : Fin heads → Fin 128 → BF} (buffer : ArrayStorage.BFBuffer (GatedInputs.flatten values)) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (fun head i => buffer.read (GatedInputs.index head i))) where
  bytes := buffer.bytes
  base := buffer.base
  aligned := buffer.aligned
  bounded := buffer.bounded
  attached := by
    intro i
    change HalfMemory.load buffer.bytes (buffer.base+2*i.val)=
      HalfMemory.load buffer.bytes (buffer.base+2*(i.val/128*128+i.val%128))
    congr 1
    omega

def Execution.queryBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (execution.output.q 0)) := readBuffer execution.qBuffer
def Execution.keyBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (execution.output.k 0)) := readBuffer execution.kBuffer
def Execution.valueBuffer (execution : Execution p width eps input qScale kScale) :
    ArrayStorage.BFBuffer (GatedInputs.flatten (execution.output.v 0)) := readBuffer execution.vBuffer

theorem Execution.query_bytes (execution : Execution p width eps input qScale kScale) : execution.queryBuffer.bytes=execution.qStores.memory := rfl
theorem Execution.key_bytes (execution : Execution p width eps input qScale kScale) : execution.keyBuffer.bytes=execution.kStores.memory := rfl
theorem Execution.value_bytes (execution : Execution p width eps input qScale kScale) : execution.valueBuffer.bytes=execution.vStores.memory := rfl

theorem head_routes (q k : Fin 16) (v : Fin 48) :
    (DeltaHeads.qHead q).val<16 ∧ 16 ≤ (DeltaHeads.kHead k).val ∧ (DeltaHeads.kHead k).val<32 ∧
      32 ≤ (DeltaHeads.vHead v).val ∧ (DeltaHeads.vHead v).val<80 := by
  have := q.isLt; have := k.isLt; have := v.isLt
  dsimp [DeltaHeads.qHead, DeltaHeads.kHead, DeltaHeads.vHead]
  omega

theorem thread_store (head : Fin heads) (lane : Fin 32) (i : Fin 4) :
    (head.val*32+lane.val)*4+i.val=head.val*128+(Gated.laneIndex lane i).val := by
  dsimp [Gated.laneIndex]
  omega

theorem launch : 32*(2*16+48)=2560 ∧ 16*128=2048 ∧ 48*128=6144 := by decide

end Inference.Layers.DeltaHeadsDevice
