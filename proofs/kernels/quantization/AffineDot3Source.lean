import kernels.quantization.AffineDot3Syntax
import kernels.quantization.AffineDot4Source

namespace Inference.Kernels.Quantization.AffineDot3Source
open Contracts.Mlx ArithmeticFold AffineDot3Syntax
set_option maxRecDepth 10000

structure Memory where
  packed : ByteMemory.Bytes
  packedBase : Nat
  scaled : Nat → Float32
  scaledBase : Nat

def bytes (memory : Memory) (index : Fin 3) : BitVec 8 := memory.packed (memory.packedBase+index.val)
def input (memory : Memory) (index : Fin 8) : Float32 := memory.scaled (memory.scaledBase+index.val)

def readInput (memory : Memory) (source : Input) : Option Float32 :=
  if source.array≠"x_thread" ∨ ¬source.index<8 then none else
    some (match source.factor with
      | none => memory.scaled (memory.scaledBase+source.index)
      | some (mantissa,scale) => FlushToZero.mul (memory.scaled (memory.scaledBase+source.index))
          (Trellis.CodebookBitsSemantics.decimalFloat mantissa scale))

theorem read_input (memory : Memory) (index : Fin 8) (factor : Option (Nat × Nat)) :
    readInput memory ⟨"x_thread",index.val,factor⟩=some (match factor with
      | none => input memory index
      | some (mantissa,scale) => FlushToZero.mul (input memory index)
          (Trellis.CodebookBitsSemantics.decimalFloat mantissa scale)) := by
  simp only [readInput,index.isLt,ne_eq,not_true_eq_false,or_self,ite_false,input]

theorem decimal_256 : Trellis.CodebookBitsSemantics.decimalFloat 2560 1=(256:Float32) := by decide +kernel

theorem input_value (memory : Memory) (i : Fin 10) :
    readInput memory (statement i).input=some
      (if AffineDot.crossed3 i then FlushToZero.mul (input memory (AffineDot.coordinate3 i)) 256
       else input memory (AffineDot.coordinate3 i)) := by
  unfold statement
  rw [read_input]
  cases crossing : AffineDot.crossed3 i <;> simp only [Bool.false_eq_true,ite_false,ite_true,decimal_256]

def lift (memory : Memory) (source : Statement) : Option Float32 :=
  if source.packed≠"w" ∨ ¬source.index<3 ∨ ¬source.mask<2^31 then none else
    AffineDot4Source.liftValue ((memory.packed (memory.packedBase+source.index)).toNat &&& source.mask)

theorem mask_value (memory : Memory) (i : Fin 10) :
    (bytes memory (AffineDot.byte3 i)).toNat &&& ((2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i))=
      AffineDot.mask3 (bytes memory) i := by
  have bound : (2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i)<256 := by fin_cases i <;> decide
  simp only [AffineDot.mask3,AffinePacking.mask8,BitVec.toNat_and,BitVec.toNat_ofNat,Nat.mod_eq_of_lt bound]

theorem lift_value (memory : Memory) (i : Fin 10) :
    lift memory (statement i)=some (AffineLift.value (AffineDot.mask3 (bytes memory) i)) := by
  have maskBound : (2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i)<2^31 := by fin_cases i <;> decide
  have range : (bytes memory (AffineDot.byte3 i)).toNat &&&
      ((2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i))<2^32 := by
    have : (bytes memory (AffineDot.byte3 i)).toNat &&&
        ((2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i))≤(bytes memory (AffineDot.byte3 i)).toNat := Nat.and_le_left
    have := (bytes memory (AffineDot.byte3 i)).isLt
    omega
  simp only [lift,statement,(AffineDot.byte3 i).isLt,maskBound,ne_eq,not_true_eq_false,or_self,ite_false]
  change AffineDot4Source.liftValue ((bytes memory (AffineDot.byte3 i)).toNat &&&
    ((2^(AffineDot.width3 i)-1)*2^(AffineDot.shift3 i)))=_
  rw [AffineDot4Source.liftValue_checked _ range,mask_value]

-- A contraction choice applies to each separate +=: statement `i` is site `i`.
-- The two crossing fields first multiply their input by the parsed 256.0f in a separately rounded op.
def execute (contracted : Bool) (memory : Memory) (accumulator : Float32) (source : Statement) : Option Float32 := do
  if source.target≠"accum" then none else do
    let coefficient ←lift memory source
    let value ←readInput memory source.input
    pure (maddFloat contracted coefficient value accumulator)

-- A statement and its site.
def executeAt (contracted : Nat → Bool) (memory : Memory) (accumulator : Float32) (source : Statement × Nat) :
    Option Float32 :=
  execute (contracted source.2) memory accumulator source.1

theorem statement_value (contracted : Bool) (memory : Memory) (accumulator : Float32) (i : Fin 10) :
    execute contracted memory accumulator (statement i)=some
      (maddFloat contracted (AffineLift.value (AffineDot.mask3 (bytes memory) i))
        (if AffineDot.crossed3 i then FlushToZero.mul (input memory (AffineDot.coordinate3 i)) 256
         else input memory (AffineDot.coordinate3 i)) accumulator) := by
  unfold execute
  simp only [show (statement i).target="accum" from rfl,ne_eq,not_true_eq_false,ite_false]
  rw [lift_value,input_value]
  rfl

attribute [local irreducible] execute parse

theorem fold_statements (contracted : Nat → Bool) (memory : Memory) (indices : List (Fin 10)) (accumulator : Float32) :
    (indices.map (fun i => (statement i,i.val))).foldlM (executeAt contracted memory) accumulator=some
      (indices.foldl (fun acc i => maddFloat (contracted i.val) (AffineLift.value (AffineDot.mask3 (bytes memory) i))
        (if AffineDot.crossed3 i then FlushToZero.mul (input memory (AffineDot.coordinate3 i)) 256
         else input memory (AffineDot.coordinate3 i)) acc) accumulator) := by
  induction indices generalizing accumulator with
  | nil => rfl
  | cons i rest ih =>
    simp only [List.map_cons,List.foldlM_cons,List.foldl_cons,executeAt,statement_value]
    exact ih _

theorem body_sites : body.zipIdx=(List.finRange 10).map (fun i => (statement i,i.val)) := by decide +kernel

theorem body_execution (contracted : Nat → Bool) (memory : Memory) (accumulator : Float32) :
    body.zipIdx.foldlM (executeAt contracted memory) accumulator=some
      (AffineDot.source3 contracted (bytes memory) (input memory) accumulator) := by
  rw [body_sites]
  unfold AffineDot.source3
  exact fold_statements contracted memory (List.finRange 10) accumulator

theorem parsed_bind {α : Type} (f : List Statement → Option α) :
    (parse sourceBody).bind f=f body := by rw [parsed_body,Option.bind_some]

def executeSource (contracted : Nat → Bool) (memory : Memory) (accumulator : Float32) : Option Float32 :=
  (parse sourceBody).bind (fun statements => statements.zipIdx.foldlM (executeAt contracted memory) accumulator)

theorem execution (contracted : Nat → Bool) (memory : Memory) (accumulator : Float32) :
    executeSource contracted memory accumulator=some (AffineDot.source3 contracted (bytes memory) (input memory) accumulator) := by
  rw [executeSource,parsed_bind]
  exact body_execution contracted memory accumulator

theorem read_bounds (memory : Memory) (byte : Fin 3) (coordinate : Fin 8)
    (packedRoom : memory.packedBase+3≤2^64) (scaledRoom : memory.scaledBase+8≤2^64) :
    memory.packedBase≤memory.packedBase+byte.val ∧ memory.packedBase+byte.val<2^64 ∧
    memory.scaledBase≤memory.scaledBase+coordinate.val ∧ memory.scaledBase+coordinate.val<2^64 := by
  have := byte.isLt; have := coordinate.isLt
  omega

end Inference.Kernels.Quantization.AffineDot3Source
