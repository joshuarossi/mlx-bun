import kernels.quantization.AffineInput4Source
import kernels.quantization.AffineDot4FunctionSource
namespace Inference.Kernels.Quantization.AffineScratch4Source
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Copy.ScalarCopySyntax (Tokens accept)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open AffineInput4Syntax (number)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
structure Program where
  inputWidth : Nat
  start : Nat
  bound : Nat
  outputWidth : Nat
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if Copy.ScalarCopySyntax.wordChar c then do
      pure (String.ofList (c::rest.takeWhile Copy.ScalarCopySyntax.wordChar)::(←lexAux fuel (rest.dropWhile Copy.ScalarCopySyntax.wordChar)))
    else if ['(',')','[',']',';','=','+','*','<','>',','].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none
def tokenize (source : String) := lexAux (source.length+1) source.toList

def parse (source : String) : Option Program := do
  let rest ←tokenize source
  let rest ←acceptMany ["ss","[","c","]","=","mlxq_load_vector","<","T",",","BITS",">","(","x","+","c","*"] rest
  let (inputWidth,rest) ←number rest
  let rest ←acceptMany [",","t",")",";","for","(","int","j","="] rest
  let (start,rest) ←number rest
  let rest ←acceptMany [";","j","<"] rest
  let (bound,rest) ←number rest
  let rest ←acceptMany [";","j","+","+",")","xs","[","c","*"] rest
  let (outputWidth,rest) ←number rest
  let rest ←acceptMany ["+","j","]","=","t","[","j","]",";"] rest
  if rest=[] then some ⟨inputWidth,start,bound,outputWidth⟩ else none

-- The loader call and publication loop are bound together. The caller supplies
-- the current 16-cell input slice; selecting that global slice is a boundary.
def sourcePublish : String := "ss[c] = mlxq_load_vector<T, BITS>(x + c * 16, t);\n    for (int j = 0; j < 16; j++) xs[c * 16 + j] = t[j];"
def body : Program := ⟨16,0,16,16⟩
theorem parsed_publish : parse sourcePublish=some body := by decide +kernel
attribute [local irreducible] parse AffineInput4Syntax.parse

def copies (base : Nat) (cells : Nat → Float32) : List (MemoryCells.Store Float32) :=
  (List.finRange 16).map (fun j => ⟨base+j.val,cells j.val⟩)

theorem copied (base : Nat) (cells before : Nat → Float32) (j : Fin 16) :
    MemoryCells.execute (copies base cells) before (base+j.val)=cells j.val := by
  apply MemoryCells.written_value
  · intro store member equal
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp member
    have same : i=j := Fin.ext (by simpa using equal)
    subst i
    rfl
  · exact ⟨⟨base+j.val,cells j.val⟩,List.mem_map.mpr ⟨j,List.mem_finRange j,rfl⟩,rfl⟩

structure Scratch where
  xs : Nat → Float32
  ss : Nat → Float32

def publish (p : AffineTile.Platform) (bytes : HalfMemory.Bytes) (inputBase chunk : Nat)
    (privateBefore : Nat → Float32) (before : Scratch) : Option Scratch := do
  let program ←parse sourcePublish
  if program.inputWidth≠16 ∨ program.start≠0 ∨ program.bound≠16 then none else do
    let (sum,cells) ←AffineInput4Source.execute p.divide bytes inputBase privateBefore
    pure ⟨MemoryCells.execute (copies (chunk*program.outputWidth) cells) before.xs,
      MemoryCells.write before.ss ⟨chunk,sum⟩⟩

def dotMemory (packed : HalfMemory.Bytes) (packedBase chunk : Nat) (scratch : Scratch) : AffineDot4Source.Memory :=
  ⟨packed,packedBase,scratch.xs,chunk*16⟩

-- This constructs the actual scaled memory used by the dot source. Prepared
-- cell equality is a conclusion of parsed private and shared writes.
theorem published (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (chunk : Nat) (privateBefore : Nat → Float32) (before : Scratch) :
    ∃ after, publish p buffer.bytes buffer.base chunk privateBefore before=some after ∧
      after.ss chunk=AffineInput.summed x AffineInput.groups4 ∧
      ∀ packed packedBase i j,
        AffineDot4Source.input (dotMemory packed packedBase chunk after) i j=AffineTile.prepared4 p x i j := by
  obtain ⟨cells,run,prepared⟩ := AffineInput4Source.execution p buffer privateBefore
  refine ⟨⟨MemoryCells.execute (copies (chunk*16) cells) before.xs,
    MemoryCells.write before.ss ⟨chunk,AffineInput.summed x AffineInput.groups4⟩⟩,?_,?_,?_⟩
  · simp only [publish,parsed_publish]
    change (do let (sum,cells) ←AffineInput4Source.execute p.divide buffer.bytes buffer.base privateBefore
               pure (⟨MemoryCells.execute (copies (chunk*16) cells) before.xs,MemoryCells.write before.ss ⟨chunk,sum⟩⟩ : Scratch))=_
    rw [run]
    rfl
  · simp only [MemoryCells.write,ite_true]
  · intro packed packedBase i j
    have cell := copied (chunk*16) cells before.xs (AffineInput.index4 i j)
    have preparedCell := prepared i j
    have index : (AffineInput.index4 i j).val=4*i.val+j.val := by simp [AffineInput.index4,Nat.mul_comm]
    rw [index] at cell
    simpa only [AffineDot4Source.input,dotMemory,Nat.add_assoc] using cell.trans preparedCell
theorem tile_execution (p : AffineTile.Platform) {x : Fin 16 → AffineInput.BF}
    (buffer : ArrayStorage.BFBuffer x) (chunk : Nat) (privateBefore : Nat → Float32) (before : Scratch)
    (packed : HalfMemory.Bytes) (packedBase : Nat) (scale bias : AffineTile.BF)
    (aligned : packedBase%2=0) (bounded : packedBase+8≤2^64)
    (finite : AffineTile.Finite4 p x (fun i => HalfMemory.load packed (packedBase+2*i.val)) scale bias) :
    ∃ after, publish p buffer.bytes buffer.base chunk privateBefore before=some after ∧
      AffineDot4FunctionSource.Execution p.contracted p.tailContracted (dotMemory packed packedBase chunk after)
        (BFloat16.widen scale) (after.ss chunk) (BFloat16.widen bias)
        (AffineTile.value4 p x (fun i => HalfMemory.load packed (packedBase+2*i.val)) scale bias) := by
  obtain ⟨after,run,sum,cells⟩ := published p buffer chunk privateBefore before
  refine ⟨after,run,?_⟩
  rw [sum]
  exact AffineDot4FunctionSource.tile_execution p x (dotMemory packed packedBase chunk after)
    scale bias aligned bounded (cells packed packedBase) finite

end Inference.Kernels.Quantization.AffineScratch4Source
