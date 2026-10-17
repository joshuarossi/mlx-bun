import models.qwen.DecodeStorage
import models.qwen.InitialState
import contracts.mlx.CopyFloatContiguous

namespace Inference.Models.Qwen.InitialStorage
open Contracts.Mlx DecodeStage Kernels.Delta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- zeros -> Full -> copy_s in the pinned MLX sources. The absent SSM slots
-- request 30720 BF16 history elements and 786432 FP32 state elements.
-- The scalar's exact positive-zero representation is an explicit input
-- attachment; these traces prove every destination store and subsequent load.
def historyZero : Fin 1 → ArrayStorage.BF := fun _ => Model.zero FloatFormat.bfloat16 false
def recurrentZero : Fin 1 → Float32 := fun _ => 0

structure DeltaTrace where
  historyScalar : ArrayStorage.BFBuffer historyZero
  recurrentScalar : ArrayStorage.FloatBuffer recurrentZero
  history : HalfArrayWrites.Trace 0 (fun _ : Fin 30720 =>
    HalfMemory.load historyScalar.bytes historyScalar.base)
  recurrent : CopyFloatContiguous.Trace 0 (fun _ : Fin (2*393216) =>
    FloatMemory.load recurrentScalar.bytes recurrentScalar.base)

def DeltaTrace.fromBefore (historyBefore : HalfMemory.Bytes) (stateBefore : ByteMemory.Bytes) : DeltaTrace :=
  let historyScalar := ArrayStorage.BFBuffer.canonical historyZero (by decide)
  let recurrentScalar := ArrayStorage.FloatBuffer.canonical recurrentZero (by decide)
  let values := fun _ : Fin 30720 => HalfMemory.load historyScalar.bytes historyScalar.base
  let programs := HalfArrayWrites.programs 0 values
  let history : HalfArrayWrites.Trace 0 values :=
    ⟨historyBefore, by decide, by decide, programs.flatten, List.replicate programs.length [],
      ThreadgroupWrites.canonical programs, ThreadgroupWrites.canonical_barrier programs⟩
  ⟨historyScalar, recurrentScalar, history,
    CopyFloatContiguous.Trace.canonical 0 _ stateBefore (by decide)⟩

theorem DeltaTrace.history_read (trace : DeltaTrace) (i : Fin 30720) :
    HalfMemory.load trace.history.memory (2*i.val)=ArrayStorage.bits (historyZero 0) := by
  have source := trace.historyScalar.attached (0 : Fin 1)
  simpa only [Fin.val_zero, Nat.mul_zero, Nat.add_zero, Nat.zero_add] using
    (trace.history.read_correct i).trans source

theorem DeltaTrace.recurrent_read (trace : DeltaTrace) (i : Fin 786432) :
    FloatMemory.load trace.recurrent.memory (4*i.val)=0 := by
  have source := trace.recurrentScalar.attached (0 : Fin 1)
  simpa only [Fin.val_zero, Nat.mul_zero, Nat.add_zero, Nat.zero_add, recurrentZero] using
    (trace.recurrent.read_correct i).trans source

def DeltaTrace.storage (trace : DeltaTrace) : DeltaDevice.Storage InitialState.delta where
  history := {
    bytes := trace.history.memory
    base := 0
    aligned := by decide
    bounded := by decide
    attached := by
      intro i
      simpa only [Nat.zero_add, State.ConvolutionStorage.flatten, InitialState.delta, historyZero] using trace.history_read i }
  recurrent := {
    bytes := trace.recurrent.memory
    base := 0
    aligned := by decide
    bounded := by decide
    attached := by
      intro head row key
      let i : Fin 786432 := ⟨GatedStores.stateIndex head row key, by
        have := head.isLt; have := row.isLt; have := key.isLt
        dsimp [GatedStores.stateIndex]
        omega⟩
      simpa only [Nat.zero_add, i, InitialState.delta] using trace.recurrent_read i }

theorem DeltaTrace.history_bytes (trace : DeltaTrace) : trace.storage.history.bytes=trace.history.memory := rfl
theorem DeltaTrace.recurrent_bytes (trace : DeltaTrace) : trace.storage.recurrent.bytes=trace.recurrent.memory := rfl

theorem DeltaTrace.history_independent (a b : DeltaTrace) (i : Fin 30720) :
    HalfMemory.load a.history.memory (2*i.val)=HalfMemory.load b.history.memory (2*i.val) := by
  rw [a.history_read, b.history_read]
theorem DeltaTrace.recurrent_independent (a b : DeltaTrace) (i : Fin 786432) :
    FloatMemory.load a.recurrent.memory (4*i.val)=FloatMemory.load b.recurrent.memory (4*i.val) := by
  rw [a.recurrent_read, b.recurrent_read]

-- Empty KV has no readable positions and no allocation to initialize yet.
-- Its first append is covered by KvAllocation/KvDevice's allocation trace.
def emptyKv (keys values : HalfMemory.Bytes) : State.KvAllocation.Storage (InitialState.emptyKv ArrayStorage.BF) where
  keys := keys
  values := values
  keysAttached := by intro _ time; exact Fin.elim0 time
  valuesAttached := by intro _ time; exact Fin.elim0 time

def StageTrace : Stage → Type
  | .delta _ => DeltaTrace
  | .attention _ => HalfMemory.Bytes × HalfMemory.Bytes

def StageTrace.storage : (stage : Stage) → StageTrace stage → DecodeStorage.StageStorage stage (InitialState.stage stage)
  | .delta _, trace => DeltaTrace.storage trace
  | .attention _, trace => emptyKv trace.1 trace.2

def Trace : List Stage → Type
  | [] => PUnit
  | stage::rest => StageTrace stage × Trace rest

def Trace.storage : (stages : List Stage) → Trace stages → DecodeStorage.Storage stages (InitialState.caches stages)
  | [], _ => ⟨⟩
  | stage::rest, trace => ⟨StageTrace.storage stage trace.1, Trace.storage rest trace.2⟩

def Trace.fromBefore (before : Nat → HalfMemory.Bytes) : (stages : List Stage) → Nat → Trace stages
  | [], _ => ⟨⟩
  | .delta _::rest, offset => ⟨DeltaTrace.fromBefore (before offset) (before (offset+1)), Trace.fromBefore before rest (offset+2)⟩
  | .attention _::rest, offset => ⟨⟨before offset, before (offset+1)⟩, Trace.fromBefore before rest (offset+2)⟩

-- get_work_per_thread(dtype,size): below 2^16 use one element, otherwise
-- max(1,8/sizeof(dtype)); both selected kernels use uint indexing.
theorem dispatch :
    30720 < 2^16 ∧ ¬786432 < 2^16 ∧ max 1 (8/4 : Nat)=2 ∧
    (786432+2-1)/2=393216 ∧ 30720 < 2^32 ∧ 786432 < 2^32 := by decide

end Inference.Models.Qwen.InitialStorage
