import kernels.attention.SdpaMemory
import contracts.mlx.ReadBeforeOverwrite

namespace Inference.Kernels.Attention.SdpaQueryMemory
open Contracts.Mlx State
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Registers := Fin 8 → BitVec 16
abbrev Machine := ReadBeforeOverwrite.State 24 1024 Registers

def layout (base : Nat) : ReadBeforeOverwrite.Layout 24 where
  base head := base+head.val*512
  size := 512
  separate := by
    intro first second different
    have distinct : first.val≠second.val := fun same => different (Fin.ext same)
    unfold MemoryRegions.Disjoint
    omega

def lane (thread : Fin 1024) : Fin 32 := ⟨thread.val%32, Nat.mod_lt _ (by decide)⟩
def read (base : Nat) (memory : ByteMemory.Bytes) (head : Fin 24) (thread : Fin 1024) : Registers :=
  fun offset => HalfMemory.load memory ((layout base).base head+2*(SdpaLayout.coordinate (lane thread) offset).val)

theorem read_local (base : Nat) : ReadBeforeOverwrite.Local (layout base) (read base) := by
  intro first second head same thread
  funext offset
  exact ArrayFrame.half_congr second first ((layout base).base head) 512
    (2*(SdpaLayout.coordinate (lane thread) offset).val) same
    (by have := (SdpaLayout.coordinate (lane thread) offset).isLt; omega)

theorem native_address (base : Nat) (head : Fin 24) (thread : Fin 1024) (offset : Fin 8) :
    (layout base).base head+2*(SdpaLayout.coordinate (lane thread) offset).val=
      base+2*(head.val*256+(thread.val%32)*8+offset.val) := by
  dsimp only [layout, SdpaLayout.coordinate, lane]
  omega

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}

theorem input_read (input : SdpaMemory.Input query cache) (base : Nat)
    (heads : ∀ head, (input.query head).base=(layout base).base head)
    (head : Fin 24) (thread : Fin 1024) (offset : Fin 8) :
    read base input.cache.memory head thread offset=ArrayStorage.bits (query head (SdpaLayout.coordinate (lane thread) offset)) := by
  unfold read
  rw [← heads head, ← input.shared head]
  exact (input.query head).attached _

-- Events permit other heads' stores between individual query loads. A
-- head's own writes require all 1024 readers to have captured their eight
-- coordinates; the source kernel's threadgroup barriers provide this order.
structure Trace (base : Nat) where
  before : ByteMemory.Bytes
  events : List (ReadBeforeOverwrite.Event 24 1024)
  after : Machine
  execution : ReadBeforeOverwrite.Executes (layout base) (read base) (ReadBeforeOverwrite.initial before) events after
  ready : ∀ head, ReadBeforeOverwrite.Ready after head

def Trace.canonical (base : Nat) (before : ByteMemory.Bytes) : Trace base :=
  ⟨before, (ReadBeforeOverwrite.allReaders 24 1024).map (fun reader => .capture reader.1 reader.2),
    ReadBeforeOverwrite.captureMany (read base) (ReadBeforeOverwrite.allReaders 24 1024) (ReadBeforeOverwrite.initial before),
    ReadBeforeOverwrite.canonical, ReadBeforeOverwrite.canonical_ready⟩

def reader (i : Fin 256) : Fin 1024 := ⟨i.val/8, by have := i.isLt; omega⟩
def offset (i : Fin 256) : Fin 8 := ⟨i.val%8, Nat.mod_lt _ (by decide)⟩

theorem coordinate_inverse (i : Fin 256) : SdpaLayout.coordinate (lane (reader i)) (offset i)=i := by
  apply Fin.ext
  dsimp only [SdpaLayout.coordinate, lane, reader, offset]
  have := i.isLt
  omega

variable {base : Nat}

def Trace.capturedQuery (trace : Trace base) (head : Fin 24) (i : Fin 256) : ArrayStorage.BF :=
  Model.ofBits (((trace.after.registers head (reader i)).getD (fun _ => 0)) (offset i))

theorem Trace.captured (trace : Trace base) (head : Fin 24) (thread : Fin 1024) (values : Registers)
    (captured : trace.after.registers head thread=some values) : values=read base trace.before head thread :=
  ReadBeforeOverwrite.captured_original (read_local base) trace.execution head thread values captured

theorem Trace.query_eq (trace : Trace base) (input : SdpaMemory.Input query cache)
    (initial : trace.before=input.cache.memory) (heads : ∀ head, (input.query head).base=(layout base).base head) : trace.capturedQuery=query := by
  funext head i
  unfold Trace.capturedQuery
  cases captured : trace.after.registers head (reader i) with
  | none => exact False.elim (trace.ready head (reader i) captured)
  | some values =>
    have same := trace.captured head (reader i) values captured
    simp only [Option.getD_some]
    rw [same, initial, input_read input base heads, coordinate_inverse]
    rfl

theorem Trace.memory (trace : Trace base) :
    trace.after.memory=HalfMemory.execute (trace.events.filterMap ReadBeforeOverwrite.storeProjection) trace.before :=
  ReadBeforeOverwrite.memory trace.execution

end Inference.Kernels.Attention.SdpaQueryMemory
