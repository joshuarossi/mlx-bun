import contracts.mlx.ReadBeforeOverwrite
import contracts.mlx.RmsScratch
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.RmsHeadReads
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- A width-256 RMS head uses 64 threads, each capturing four coordinates.
-- Each head may overwrite its own row after its reduction barrier. Heads
-- remain independent; the machine does not require a device-wide barrier.
abbrev Registers := Fin 4 → BitVec 16
abbrev Machine (heads : Nat) := ReadBeforeOverwrite.State heads 64 Registers

def layout (heads base : Nat) : ReadBeforeOverwrite.Layout heads where
  base head := base+head.val*512
  size := 512
  separate := by
    intro first second different
    have distinct : first.val≠second.val := fun same => different (Fin.ext same)
    unfold MemoryRegions.Disjoint
    omega

def coordinate (thread : Fin 64) (offset : Fin 4) : Fin 256 :=
  ⟨thread.val*4+offset.val, by have := thread.isLt; have := offset.isLt; omega⟩

def read (base : Nat) (memory : ByteMemory.Bytes) (head : Fin heads) (thread : Fin 64) : Registers :=
  fun offset => HalfMemory.load memory ((layout heads base).base head+2*(coordinate thread offset).val)

theorem read_local (heads base : Nat) : ReadBeforeOverwrite.Local (layout heads base) (read base) := by
  intro first second head same thread
  funext offset
  exact ArrayFrame.half_congr second first ((layout heads base).base head) 512 (2*(coordinate thread offset).val) same
    (by have := (coordinate thread offset).isLt; omega)

theorem native_address (base : Nat) (head : Fin heads) (thread : Fin 64) (offset : Fin 4) :
    (layout heads base).base head+2*(coordinate thread offset).val=
      base+2*(head.val*256+thread.val*4+offset.val) := by
  dsimp only [layout, coordinate]
  omega

structure Input (values : Fin heads → Fin 256 → ArrayStorage.BF) (base : Nat) where
  memory : ByteMemory.Bytes
  rows : ∀ head, ArrayStorage.BFBuffer (values head)
  shared : ∀ head, (rows head).bytes=memory
  addresses : ∀ head, (rows head).base=(layout heads base).base head

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF}

theorem Input.read_correct (input : Input values base) (head : Fin heads) (thread : Fin 64) (offset : Fin 4) :
    read base input.memory head thread offset=ArrayStorage.bits (values head (coordinate thread offset)) := by
  unfold read
  rw [← input.addresses head, ← input.shared head]
  exact (input.rows head).attached _

structure Trace (heads base : Nat) where
  before : ByteMemory.Bytes
  events : List (ReadBeforeOverwrite.Event heads 64)
  after : Machine heads
  execution : ReadBeforeOverwrite.Executes (layout heads base) (read base) (ReadBeforeOverwrite.initial before) events after
  ready : ∀ head, ReadBeforeOverwrite.Ready after head

def Trace.canonical (heads base : Nat) (before : ByteMemory.Bytes) : Trace heads base :=
  ⟨before, (ReadBeforeOverwrite.allReaders heads 64).map (fun reader => .capture reader.1 reader.2),
    ReadBeforeOverwrite.captureMany (read base) (ReadBeforeOverwrite.allReaders heads 64) (ReadBeforeOverwrite.initial before),
    ReadBeforeOverwrite.canonical, ReadBeforeOverwrite.canonical_ready⟩

def reader (i : Fin 256) : Fin 64 := ⟨i.val/4, by have := i.isLt; omega⟩
def offset (i : Fin 256) : Fin 4 := ⟨i.val%4, Nat.mod_lt _ (by decide)⟩

theorem coordinate_inverse (i : Fin 256) : coordinate (reader i) (offset i)=i := by
  apply Fin.ext
  dsimp only [coordinate, reader, offset]
  omega

def Trace.capturedRows (trace : Trace heads base) (head : Fin heads) (i : Fin 256) : ArrayStorage.BF :=
  Model.ofBits (((trace.after.registers head (reader i)).getD (fun _ => 0)) (offset i))

theorem Trace.captured (trace : Trace heads base) (head : Fin heads) (thread : Fin 64) (registers : Registers)
    (captured : trace.after.registers head thread=some registers) : registers=read base trace.before head thread :=
  ReadBeforeOverwrite.captured_original (read_local heads base) trace.execution head thread registers captured

theorem Trace.rows_eq (trace : Trace heads base) (input : Input values base)
    (initial : trace.before=input.memory) : trace.capturedRows=values := by
  funext head i
  unfold Trace.capturedRows
  cases captured : trace.after.registers head (reader i) with
  | none => exact False.elim (trace.ready head (reader i) captured)
  | some registers =>
    have same := trace.captured head (reader i) registers captured
    simp only [Option.getD_some]
    rw [same, initial, input.read_correct, coordinate_inverse]
    rfl

theorem Trace.memory (trace : Trace heads base) :
    trace.after.memory=HalfMemory.execute (trace.events.filterMap ReadBeforeOverwrite.storeProjection) trace.before :=
  ReadBeforeOverwrite.memory trace.execution

theorem group_separate {region size : Nat} (separate : MemoryRegions.Disjoint base (512*heads) region size)
    (head : Fin heads) : MemoryRegions.Disjoint ((layout heads base).base head) 512 region size := by
  have := head.isLt
  dsimp only [layout]
  rcases separate with left|right <;> unfold MemoryRegions.Disjoint <;> omega

theorem Trace.other_region (trace : Trace heads base) {region size : Nat}
    (separate : MemoryRegions.Disjoint base (512*heads) region size) (offset : Nat) (bound : offset<size) :
    trace.after.memory (region+offset)=trace.before (region+offset) :=
  ReadBeforeOverwrite.frame trace.execution (group_separate separate) offset bound

end Inference.Kernels.RmsHeadReads
