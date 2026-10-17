import contracts.mlx.ByteMemory

import kernels.trellis.GateInputSyntax
import kernels.trellis.PackedArraySemantics
import kernels.trellis.GateUpBarrier
namespace Inference.Kernels.Trellis.GateInputSemantics
open Contracts.Mlx GateInputSyntax
set_option maxRecDepth 10000

structure Action where
  destination : Nat
  source : Nat
  deriving DecidableEq, Repr

def env (code : Loop) (counter : BitVec 32) : PackedArraySemantics.State := ⟨[
  (code.counter,.unsigned counter),("C",.signed 5120),("THREADS",.signed 1024),("N_RUNS",.unsigned 160)],[],[]⟩
def uint (code : Loop) (counter : BitVec 32) (value : PackedArraySyntax.Expr) : Option (BitVec 32) := do
  match ←PackedArraySemantics.evaluate 16 (env code counter) value with
  | .unsigned value => some value
  | _ => none

def bindings (code : Loop) : Prop := code.builtin="thread_position_in_threadgroup" ∧ code.component="x" ∧
  code.test=code.counter ∧ code.step=code.counter ∧ code.target="xs" ∧ code.input="x"
instance (code : Loop) : Decidable (bindings code) := inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

def run : Nat → Loop → BitVec 32 → Option (List Action)
  | 0,_,_ => none
  | fuel+1,code,counter => do
    if bindings code then
      let limit ←uint code counter code.bound
      if counter.toNat<limit.toNat then
        let destination ←uint code counter code.targetIndex
        let source ←uint code counter code.sourceIndex
        let increment ←uint code counter code.increment
        pure (⟨destination.toNat,source.toNat⟩::(←run fuel code (counter+increment)))
      else some []
    else none

def actions (thread : Nat) : Option (List Action) := do
  let code ←parseLoop loopSource
  run 2 code (BitVec.ofNat 32 thread)

theorem run_selected : ∀ thread : Fin 1024,
    run 2 loopAST (BitVec.ofNat 32 thread.val)=some (if thread.val<640 then [⟨thread.val,GateUpCodebook.stagedChunk thread.val⟩] else []) := by
  decide +kernel

theorem selected (thread : Fin 1024) : actions thread.val=some
    (if thread.val<640 then [⟨thread.val,GateUpCodebook.stagedChunk thread.val⟩] else []) := by
  unfold actions
  rw [parsed_loop]
  exact run_selected thread

-- The global input address space is immutable during these threadgroup writes.
-- A physical coherent uint4 load is modeled by these four little-endian words;
-- alignment, width, compiler and instruction correspondence remain external.
def loadQuad (memory : ByteMemory.Bytes) (base index word : Nat) : BitVec 32 :=
  ByteMemory.load32 memory (base+16*index+4*word)

def stores (memory : ByteMemory.Bytes) (sourceBase inputBase : Nat) (action : Action) : List GateUpBarrier.Store :=
  (List.range 4).map (fun word => ⟨inputBase/4+4*action.destination+word,loadQuad memory sourceBase action.source word⟩)

def threadProgram (memory : ByteMemory.Bytes) (sourceBase inputBase thread : Nat) : Option (List GateUpBarrier.Store) := do
  pure ((←actions thread).flatMap (stores memory sourceBase inputBase))

inductive Word where
  | read : Nat → Word
  | left : Word → Nat → Word
  | right : Word → Nat → Word
  | bitAnd : Word → BitVec 32 → Word
  deriving DecidableEq, Repr

def Word.evaluate (chunk : Nat → BitVec 32) : Word → BitVec 32
  | .read index => chunk index
  | .left value count => value.evaluate chunk <<< count
  | .right value count => value.evaluate chunk >>> count
  | .bitAnd value mask => value.evaluate chunk &&& mask
inductive Value where
  | uint : BitVec 32 → Value
  | word : Word → Value
  deriving DecidableEq, Repr

def integer (p : Nat) : CodebookWindowSyntax.Expr → Option Value
  | .variable name => if name="p" then some (.uint (BitVec.ofNat 32 p)) else none
  | .literal .signed n => if n<2^31 then some (.uint (BitVec.ofNat 32 n)) else none
  | .literal .unsigned n => if n<2^32 then some (.uint (BitVec.ofNat 32 n)) else none
  | .index name index => do
    if name="chunk" then
      match ←integer p index with
      | .uint value => if value.toNat<4 then some (.word (.read value.toNat)) else none
      | _ => none
    else none
  | .bitAnd left right => do
    match ←integer p left,←integer p right with
    | .uint a,.uint b => some (.uint (a &&& b))
    | .word a,.uint b => some (.word (.bitAnd a b))
    | _,_ => none
  | .shiftLeft left right => do
    match ←integer p left,←integer p right with
    | .uint a,.uint b => if b.toNat<32 then some (.uint (a <<< b.toNat)) else none
    | .word a,.uint b => if b.toNat<32 then some (.word (.left a b.toNat)) else none
    | _,_ => none
  | .shiftRight left right => do
    match ←integer p left,←integer p right with
    | .uint a,.uint b => if b.toNat<32 then some (.uint (a >>> b.toNat)) else none
    | .word a,.uint b => if b.toNat<32 then some (.word (.right a b.toNat)) else none
    | _,_ => none
  | _ => none

def unpackWord (code : Unpack) (p : Nat) : Option Word := do
  if code.target="xv" then
    match ←integer p code.condition with
    | .uint test =>
      match ←integer p (if test=0 then code.no else code.yes) with
      | .word value => some value
      | _ => none
    | _ => none
  else none

def unpack (p : Nat) : Option Word := do unpackWord (←parseUnpack unpackSource) p

theorem run_unpack : ∀ p : Fin 8, unpackWord unpackAST p.val=some
    (if p.val%2=1 then .bitAnd (.read (p.val/2)) 0xffff0000#32 else .left (.read (p.val/2)) 16) := by
  decide +kernel

theorem selected_unpack (p : Fin 8) : unpack p.val=some
    (if p.val%2=1 then .bitAnd (.read (p.val/2)) 0xffff0000#32 else .left (.read (p.val/2)) 16) := by
  unfold unpack
  rw [parsed_unpack]
  exact run_unpack p

def unpackValue (chunk : Nat → BitVec 32) (p : Nat) : Option Float32 :=
  (unpack p).map (fun value => GateUpExecution.asFloat (value.evaluate chunk))

theorem unpack_value (chunk : Nat → BitVec 32) (p : Nat) (bound : p<8) :
    unpackValue chunk p=some (GateUpExecution.asFloat
      (if p%2=1 then chunk (p/2) &&& 0xffff0000#32 else chunk (p/2) <<< 16)) := by
  unfold unpackValue
  rw [selected_unpack ⟨p,bound⟩]
  split <;> rfl
end Inference.Kernels.Trellis.GateInputSemantics
