import kernels.attention.RopeDevice
import contracts.mlx.Copy2DMemory

namespace Inference.Kernels.Attention.RopeSharedMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := ArrayStorage.BF

-- The partial-RoPE host branch copies the complete head, then aliases the
-- kernel input to its output. This module starts at that copied allocation.
structure Trace (base : Nat) (values : Fin 64 → BitVec 16) where
  before : ByteMemory.Bytes
  aligned : base % 2 = 0
  localTrace : RopeDevice.Trace values
  attached : localTrace.before = MemoryRegions.view before base

def Trace.schedule (t : Trace base values) : List HalfMemory.Store :=
  t.localTrace.schedule.map (MemoryRegions.shift16 base)
def Trace.memory (t : Trace base values) : ByteMemory.Bytes := HalfMemory.execute t.schedule t.before

theorem Trace.legal (t : Trace base values) :
    ThreadgroupWrites.Executes ((RopeDevice.programs values).map (List.map (MemoryRegions.shift16 base)))
      t.schedule (t.localTrace.remaining.map (List.map (MemoryRegions.shift16 base))) :=
  ArrayRelocation.map_execution _ t.localTrace.execution

theorem Trace.inside (t : Trace base values) : MemoryRegions.Inside16 base 128 t.schedule := by
  apply MemoryRegions.shift16_inside _ _ base t.aligned
  intro store member
  obtain ⟨lane, half, rfl⟩ := RopeDevice.member values store
    ((ThreadgroupWrites.completed_schedule t.localTrace.execution t.localTrace.completed).mem_iff.mp member)
  have bound := (RopeDevice.index lane half).isLt
  dsimp [RopeDevice.entry]
  omega

theorem Trace.view (t : Trace base values) : MemoryRegions.view t.memory base=t.localTrace.memory := by
  unfold Trace.memory Trace.schedule
  rw [MemoryRegions.execute16_view _ _ _ t.aligned, ← t.attached]
  rfl

theorem Trace.read (t : Trace base values) (i : Fin 64) :
    HalfMemory.load t.memory (base+2*i.val)=values i := by
  rw [← MemoryRegions.load16_view, t.view]
  exact t.localTrace.read_correct i

theorem Trace.frame (t : Trace base values) (address : Nat) (outside : address<base ∨ base+128≤address) :
    t.memory address=t.before address := MemoryRegions.execute16_frame _ _ t.inside outside

theorem Trace.unchanged (t : Trace base values) (i : Fin 256) (outside : 64 ≤ i.val) :
    HalfMemory.load t.memory (base+2*i.val)=HalfMemory.load t.before (base+2*i.val) := by
  simp only [HalfMemory.load]
  rw [t.frame _ (Or.inr (by omega)), t.frame _ (Or.inr (by omega))]

-- Inputs are two actual heap loads captured before either paired store.
def capture (memory : ByteMemory.Bytes) (base : Nat) (theta : Fin 32 → Float32)
    (lane : Fin 32) : Rope.Inputs :=
  ⟨Model.ofBits (HalfMemory.load memory (base+2*lane.val)),
   Model.ofBits (HalfMemory.load memory (base+2*(lane.val+32))), theta lane⟩

theorem capture_stable (stores : List HalfMemory.Store) (memory : ByteMemory.Bytes)
    (base : Nat) (aligned : base%2=0) (theta : Fin 32 → Float32) (lane : Fin 32)
    (separate : ∀ store ∈ stores, store.word≠base/2+lane.val ∧ store.word≠base/2+lane.val+32) :
    capture (HalfMemory.execute stores memory) base theta lane=capture memory base theta lane := by
  have first := CopyExecution.source_stable stores memory (base/2+lane.val)
    (fun store member => (separate store member).1.symm)
  have second := CopyExecution.source_stable stores memory (base/2+lane.val+32)
    (fun store member => (separate store member).2.symm)
  rw [show 2*(base/2+lane.val)=base+2*lane.val by omega] at first
  rw [show 2*(base/2+lane.val+32)=base+2*(lane.val+32) by omega] at second
  simp only [capture, first, second]

theorem capture_attached (source : ArrayStorage.BFBuffer x) (theta : Fin 32 → Float32) (lane : Fin 32) :
    capture source.bytes source.base theta lane=Rope.headInputs x theta lane := by
  unfold capture Rope.headInputs
  have first := source.read_correct (Rope.pairFirst lane)
  have second := source.read_correct (Rope.pairSecond lane)
  change (Model.ofBits (HalfMemory.load source.bytes (source.base+2*lane.val)) : BF)=x (Rope.pairFirst lane) at first
  change (Model.ofBits (HalfMemory.load source.bytes (source.base+2*(lane.val+32))) : BF)=x (Rope.pairSecond lane) at second
  rw [first, second]

-- A lane may capture after any number of stores by other lanes. Its own
-- two operands are still the pre-update values; no cross-lane barrier is needed.
theorem other_lane_stores (base : Nat) (values : Fin 64 → BitVec 16)
    (lane other : Fin 32) (different : lane≠other) (half : Fin 2) :
    (MemoryRegions.shift16 base (RopeDevice.entry values other half)).word≠base/2+lane.val ∧
    (MemoryRegions.shift16 base (RopeDevice.entry values other half)).word≠base/2+lane.val+32 := by
  have hl := lane.isLt
  have ho := other.isLt
  have hh := half.isLt
  have diff : lane.val≠other.val := fun same => different (Fin.ext same)
  dsimp [MemoryRegions.shift16, RopeDevice.entry, RopeDevice.index]
  constructor <;> omega

theorem capture_after_other_lanes (source : ArrayStorage.BFBuffer x) (theta : Fin 32 → Float32)
    (lane : Fin 32) (values : Fin 64 → BitVec 16) (stores : List HalfMemory.Store)
    (owned : ∀ store ∈ stores, ∃ other half, lane≠other ∧
      store=MemoryRegions.shift16 source.base (RopeDevice.entry values other half)) :
    capture (HalfMemory.execute stores source.bytes) source.base theta lane=Rope.headInputs x theta lane := by
  rw [capture_stable stores source.bytes source.base source.aligned theta lane]
  · exact capture_attached source theta lane
  · intro store member
    obtain ⟨other, half, different, rfl⟩ := owned store member
    exact other_lane_stores source.base values lane other different half

def pairedStores (p : Rope.Platform) (base : Nat) (lane : Fin 32) (input : Rope.Inputs) : List HalfMemory.Store :=
  [⟨base/2+lane.val, ArrayStorage.bits (Rope.value p input false)⟩,
   ⟨base/2+lane.val+32, ArrayStorage.bits (Rope.value p input true)⟩]

theorem pairedStores_original (p : Rope.Platform) (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (lane : Fin 32) :
    pairedStores p source.base lane (capture source.bytes source.base theta lane)=
      ((List.finRange 2).map (RopeDevice.entry (RopeDevice.rotated p source theta) lane)).map
        (MemoryRegions.shift16 source.base) := by
  rw [capture_attached]
  have readback : source.read=x := funext source.read_correct
  simp only [List.finRange_succ, List.finRange_zero, List.map_nil, List.map_cons]
  simp only [RopeDevice.entry, MemoryRegions.shift16]
  rw [show (Fin.succ (0 : Fin 1) : Fin 2) = 1 by decide]
  rw [RopeDevice.rotated_first, RopeDevice.rotated_second, readback]
  rfl

def copyLayout (source destination : Nat) : Copy2D.Layout := ⟨source, 256, 1, destination, 256⟩

def copiedBuffer {x : Fin 256 → BF} (source : ArrayStorage.BFBuffer x) (destination : Nat)
    (aligned : destination%2=0) (bounded : destination+512≤2^64)
    (copy : Copy2DMemory.Trace (copyLayout source.base destination) 1 256)
    (before : copy.before=source.bytes)
    (separate : CopyExecution.NoAlias (Copy2DMemory.programs (copyLayout source.base destination) 1 256).flatten) :
    ArrayStorage.BFBuffer x where
  bytes := copy.memory
  base := destination
  aligned := aligned
  bounded := bounded
  attached := by
    intro i
    have result := Copy2DMemory.read_correct (copyLayout source.base destination) source.aligned aligned
      (by simp [copyLayout]) copy separate ((0 : Fin 1),i)
    simp only [copyLayout, Copy2D.destination, Copy2D.sourceAddress, Fin.val_zero, Nat.zero_mul,
      Nat.add_zero, Nat.mul_one, before] at result
    exact result.trans (source.attached i)

structure Execution (p : Rope.Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) where
  copied : ArrayStorage.BFBuffer x
  rotation : Trace copied.base (fun i => ArrayStorage.bits (Rope.head p x theta ⟨i.val, by have := i.isLt; omega⟩))
  input : rotation.before=copied.bytes

theorem Execution.raw_read (e : Execution p x theta) (i : Fin 256) :
    HalfMemory.load e.rotation.memory (e.copied.base+2*i.val)=ArrayStorage.bits (Rope.head p x theta i) := by
  by_cases h : i.val<64
  · exact e.rotation.read ⟨i.val,h⟩
  · rw [e.rotation.unchanged i (by omega), e.input, e.copied.attached,
      Rope.unchanged p x theta i (by omega)]

def Execution.buffer (e : Execution p x theta) : ArrayStorage.BFBuffer (Rope.head p x theta) where
  bytes := e.rotation.memory
  base := e.copied.base
  aligned := e.copied.aligned
  bounded := e.copied.bounded
  attached := e.raw_read

theorem Execution.output_eq (e : Execution p x theta) : e.buffer.read=Rope.head p x theta :=
  funext e.buffer.read_correct

end Inference.Kernels.Attention.RopeSharedMemory
