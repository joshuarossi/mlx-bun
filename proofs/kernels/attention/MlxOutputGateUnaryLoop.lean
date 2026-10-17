import kernels.attention.MlxOutputGateMemory
import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Attention.MlxOutputGateUnaryLoop
open Contracts.Mlx MlxOutputGateSyntax MlxOutputGateSource
open Copy.ScalarCopySyntax (Tokens)
open Normalization.MlxRmsLoopSyntax (word acceptAll)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lex fuel rest
    else if word c then do pure (String.ofList (c::rest.takeWhile word)::(←lex fuel (rest.dropWhile word)))
    else if ['(',')','[',']','{','}',';','=','+','*','<','>','&',','].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

inductive Program where | vector deriving DecidableEq, Repr

def parse (source : String) : Option Program := do
  let ts ←lex (source.length+1) source.toList
  let rest ←acceptAll ["index","*","=","N",";","if","(","N",">","1","&","&","index","+","N",">","size",")","{",
    "for","(","int","i","=","0",";","index","+","i","<","size",";","+","+","i",")","{",
    "out","[","index","+","i","]","=","static_cast","<","U",">","(","Op","(",")","(","in","[","index","+","i","]",")",")",";","}","}",
    "else","{","for","(","int","i","=","0",";","i","<","N",";","+","+","i",")","{",
    "out","[","index","+","i","]","=","static_cast","<","U",">","(","Op","(",")","(","in","[","index","+","i","]",")",")",";","}","}"] ts
  if rest=[] then some .vector else none

def sourceBody : String := r#"index *= N;
  if (N > 1 && index + N > size) {
    for (int i = 0; index + i < size; ++i) {
      out[index + i] = static_cast<U>(Op()(in[index + i]));
    }
  } else {
    for (int i = 0; i < N; ++i) {
      out[index + i] = static_cast<U>(Op()(in[index + i]));
    }
  }"#

theorem parsed : parse sourceBody=some .vector := by decide +kernel

def visits (_ : Program) (size width thread : Nat) : List Nat :=
  let start := thread*width
  let count := if width>1 ∧ start+width>size then size-start else width
  (List.range count).map (start+·)

-- The selected contiguous 6144-element gate takes unary_v's N=1
-- specialization: host size is below the 65536 work-per-thread threshold.
def hostWidth (bytes size : Nat) : Nat := if size<65536 then 1 else max 1 (8/bytes)
theorem selected_width : hostWidth 2 6144=1 := by decide

theorem selected_visits (thread : Fin 6144) : visits .vector 6144 (hostWidth 2 6144) thread.val=[thread.val] := by
  simp [visits,selected_width]

theorem selected_range (thread : Fin 6144) (offset : Nat)
    (member : offset ∈ visits .vector 6144 (hostWidth 2 6144) thread.val) : offset<6144 := by
  rw [selected_visits] at member
  simp only [List.mem_singleton] at member
  subst offset
  exact thread.isLt

theorem gate_pointer {x gate : OutputGateDevice.Heads} (input : OutputGateMemory.Input x gate)
    (base : Nat) (contiguous : ∀ head, (input.storage.gate head).base=2*(base+head.val*256)) (thread : Fin 6144) :
    input.gateAddress thread=base+thread.val :=
  OutputGateMemory.head_address input.storage.gate base contiguous thread

-- U=T=BF16 makes the final cast an identity. This selected source store
-- reads its own current heap cell and applies the parsed scalar operation.
def store (p : OutputGate.Platform) (memory : ByteMemory.Bytes) (inputBase outputBase index : Nat) : Option HalfMemory.Store := do
  let value ←parsedSigmoid p (FloatLib.Floats.Formats.BinaryInterchange.Model.ofBits
    (HalfMemory.load memory (2*(inputBase+index))))
  pure ⟨outputBase+index,ArrayStorage.bits value⟩

theorem store_current {x gate : OutputGateDevice.Heads} (input : OutputGateMemory.Input x gate)
    (p : OutputGate.Platform) (inputBase outputBase : Nat)
    (contiguous : ∀ head, (input.storage.gate head).base=2*(inputBase+head.val*256))
    (memory : ByteMemory.Bytes) (thread : Fin 6144) :
    store p memory inputBase outputBase thread.val=
      some (ElementwiseMemory.store (OutputGateMemory.sigmoidKernel input p outputBase) memory thread) := by
  unfold store
  rw [parsed_sigmoid_value]
  simp only [pure,Bind.bind,Option.bind]
  simp only [ElementwiseMemory.store,ElementwiseMemory.result,OutputGateMemory.sigmoidKernel]
  rw [gate_pointer input inputBase contiguous]

end Inference.Kernels.Attention.MlxOutputGateUnaryLoop
