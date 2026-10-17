import kernels.attention.MlxOutputGateUnaryLoop

namespace Inference.Kernels.Attention.MlxOutputGateBinaryLoop
open Contracts.Mlx MlxOutputGateSource
open Normalization.MlxRmsLoopSyntax (acceptAll)
set_option maxRecDepth 10000

inductive Program where | vectors deriving DecidableEq, Repr

def parse (source : String) : Option Program := do
  let ts ←MlxOutputGateUnaryLoop.lex (source.length+1) source.toList
  let rest ←acceptAll ["index","*","=","N",";","if","(","N",">","1","&","&","index","+","N",">","size",")","{",
    "for","(","int","i","=","0",";","index","+","i","<","size",";","+","+","i",")","{",
    "c","[","index","+","i","]","=","Op","(",")","(","a","[","index","+","i","]",",","b","[","index","+","i","]",")",";","}","}",
    "else","{","for","(","int","i","=","0",";","i","<","N",";","+","+","i",")","{",
    "c","[","index","+","i","]","=","Op","(",")","(","a","[","index","+","i","]",",","b","[","index","+","i","]",")",";","}","}"] ts
  if rest=[] then some .vectors else none

def sourceBody : String := r#"index *= N;
  if (N > 1 && index + N > size) {
    for (int i = 0; index + i < size; ++i) {
      c[index + i] = Op()(a[index + i], b[index + i]);
    }
  } else {
    for (int i = 0; i < N; ++i) {
      c[index + i] = Op()(a[index + i], b[index + i]);
    }
  }"#

theorem parsed : parse sourceBody=some .vectors := by decide +kernel

def visits (_ : Program) (size width thread : Nat) : List Nat :=
  MlxOutputGateUnaryLoop.visits .vector size width thread

theorem selected_visits (thread : Fin 6144) :
    visits .vectors 6144 (MlxOutputGateUnaryLoop.hostWidth 2 6144) thread.val=[thread.val] :=
  MlxOutputGateUnaryLoop.selected_visits thread

def store (memory : ByteMemory.Bytes) (sourceBase activationBase outputBase index : Nat) : Option HalfMemory.Store := do
  let value ←parsedMultiply
    (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (HalfMemory.load memory (2*(sourceBase+index))))
    (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits (HalfMemory.load memory (2*(activationBase+index))))
  pure ⟨outputBase+index,ArrayStorage.bits value⟩

theorem store_current {x gate : OutputGateDevice.Heads} {input : OutputGateMemory.Input x gate} {p : OutputGate.Platform}
    (activation : OutputGateMemory.Activation input p) (sourceBase outputBase : Nat)
    (contiguous : ∀ head, (input.storage.source head).base=2*(sourceBase+head.val*256))
    (memory : ByteMemory.Bytes) (thread : Fin 6144) :
    store memory sourceBase activation.base outputBase thread.val=
      some (ElementwiseMemory.store (OutputGateMemory.multiplyKernel activation outputBase) memory thread) := by
  unfold store
  rw [parsed_multiply_value]
  simp only [pure,Bind.bind,Option.bind]
  simp only [ElementwiseMemory.store,ElementwiseMemory.result,OutputGateMemory.multiplyKernel]
  rw [show input.sourceAddress thread=sourceBase+thread.val from
    OutputGateMemory.head_address input.storage.source sourceBase contiguous thread]
  rfl

end Inference.Kernels.Attention.MlxOutputGateBinaryLoop
