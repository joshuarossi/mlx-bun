import kernels.quantization.MlxQmvDot4Syntax
import kernels.quantization.MlxQmv
import kernels.quantization.AffineDot
import contracts.mlx.HalfMemory

namespace Inference.Kernels.Quantization.MlxQmvDot4Source
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open MlxQmvDot4Syntax
set_option maxRecDepth 10000

-- Signed source subscript arithmetic fails outside int32. For the selected
-- four visits every operation is proved in range before a memory address forms.
def signed (value : Int) : Option Int :=
  if -(2^31)≤value ∧ value<2^31 then some value else none
def evaluateIndex (iteration : Fin 4) : Index → Option Int
  | .variable name => if name="i" then some iteration.val else none
  | .literal .signed n => signed n
  | .add left right => do signed ((←evaluateIndex iteration left)+(←evaluateIndex iteration right))
  | .multiply left right => do signed ((←evaluateIndex iteration left)*(←evaluateIndex iteration right))
  | _ => none

theorem index_value : ∀ iteration offset : Fin 4,
    evaluateIndex iteration (index offset)=some (4*iteration.val+offset.val:Int) := by decide +kernel
theorem variable_value (iteration : Fin 4) :
    evaluateIndex iteration (.variable "i")=some (iteration.val:Int) := by simp [evaluateIndex]

structure Memory where
  packed : HalfMemory.Bytes
  packedBase : Nat
  scaled : Nat → Float32
  scaledBase : Nat

def word (memory : Memory) (iteration : Fin 4) : BitVec 16 :=
  HalfMemory.load memory.packed (memory.packedBase+2*iteration.val)
def input (memory : Memory) (iteration offset : Fin 4) : Float32 :=
  memory.scaled (memory.scaledBase+4*iteration.val+offset.val)

-- Additions within an expression: the `+` of `left + right` is contraction site
-- `additions left` (the parsed sum is left-associated; its products hold no additions).
def additions : Expr → Nat
  | .multiply left right => additions left+additions right
  | .add left right => additions left+additions right+1
  | _ => 0

-- Each site's flag selects the same explicit arithmetic lowering as the model:
-- `x * y + z` contracts the left product, else `z + x * y` the right one.
-- Compiler selection of that lowering remains a boundary.
-- Both lowerings preserve the parsed left-associated order and uint16 loads.
def evaluate (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) : Expr → Option Float32
  | .input array index => do
      if array≠"x_thread" then none else do
        let position ←evaluateIndex iteration index
        if 0≤position ∧ position<16 then some (memory.scaled (memory.scaledBase+position.toNat)) else none
  | .masked array index mask => do
      if array≠"ws" ∨ ¬mask<2^31 then none else do
        let position ←evaluateIndex iteration index
        if 0≤position ∧ position<4 then do
          let bits := HalfMemory.load memory.packed (memory.packedBase+2*position.toNat)
          some (MlxQmv.integer (bits.toNat &&& mask))
        else none
  | .multiply left right => do
      pure (FlushToZero.mul (←evaluate contracted memory iteration left) (←evaluate contracted memory iteration right))
  | .add (.multiply a b) right => do
      let a' ←evaluate contracted memory iteration a
      let b' ←evaluate contracted memory iteration b
      let rest ←evaluate contracted memory iteration right
      pure (maddLeftFloat (contracted (additions a+additions b)) a' b' rest)
  | .add left (.multiply a b) => do
      let previous ←evaluate contracted memory iteration left
      let a ←evaluate contracted memory iteration a
      let b ←evaluate contracted memory iteration b
      pure (maddFloat (contracted (additions left)) a b previous)
  | .add left right => do
      pure (FlushToZero.add (←evaluate contracted memory iteration left) (←evaluate contracted memory iteration right))

theorem input_value (contracted : Nat → Bool) (memory : Memory) (iteration offset : Fin 4) :
    evaluate contracted memory iteration (.input "x_thread" (index offset))=some (input memory iteration offset) := by
  have safe : 0≤(4*iteration.val+offset.val:Int) ∧ (4*iteration.val+offset.val:Int)<16 := by
    have := iteration.isLt; have := offset.isLt; omega
  rw [evaluate,index_value]
  simp only [ne_eq,not_true_eq_false,ite_false,bind,Option.bind]
  rw [ite_eq_left safe]
  have converted : (4*iteration.val+offset.val:Int).toNat=4*iteration.val+offset.val := by omega
  simp only [converted,input,Nat.add_assoc]

theorem mask_value (bits : BitVec 16) (offset : Fin 4) :
    bits.toNat &&& (15*2^(4*offset.val))=AffineDot.mask4 bits offset := by
  have bound : 15*2^(4*offset.val)<65536 := by fin_cases offset <;> decide
  simp only [AffineDot.mask4,AffinePacking.mask16,BitVec.toNat_and,BitVec.toNat_ofNat,Nat.mod_eq_of_lt bound]

theorem lift_value (contracted : Nat → Bool) (memory : Memory) (iteration offset : Fin 4) :
    evaluate contracted memory iteration (.masked "ws" (.variable "i") (15*2^(4*offset.val)))=
      some (AffineLift.value (AffineDot.mask4 (word memory iteration) offset)) := by
  have maskBound : 15*2^(4*offset.val)<2^31 := by fin_cases offset <;> decide
  have safe : 0≤(iteration.val:Int) ∧ (iteration.val:Int)<4 := by have := iteration.isLt; omega
  rw [evaluate,variable_value]
  simp only [ne_eq,not_true_eq_false,maskBound,not_true_eq_false,or_self,ite_false,bind,Option.bind]
  rw [ite_eq_left safe]
  simp only [Int.toNat_natCast]
  change some (MlxQmv.integer ((word memory iteration).toNat &&& (15*2^(4*offset.val))))=_
  rw [mask_value,MlxQmv.integer_mask4]

def execute (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) (accumulator : Float32)
    (statement : Statement) : Option Float32 := do
  if statement.target≠"accum" then none else
    pure (FlushToZero.add accumulator (←evaluate contracted memory iteration statement.value))

def executeSource (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) (accumulator : Float32) : Option Float32 :=
  (parse sourceBody).bind (execute contracted memory iteration accumulator)

theorem product_value (contracted : Nat → Bool) (memory : Memory) (iteration offset : Fin 4) :
    evaluate contracted memory iteration (product offset)=some
      (FlushToZero.mul (input memory iteration offset) (AffineLift.value (AffineDot.mask4 (word memory iteration) offset))) := by
  rw [product,evaluate,input_value,lift_value]
  rfl

theorem pair_value (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) :
    evaluate contracted memory iteration (.add (product 0) (product 1))=some
      (maddLeftFloat (contracted 0) (input memory iteration 0) (AffineLift.value (AffineDot.mask4 (word memory iteration) 0))
        (FlushToZero.mul (input memory iteration 1) (AffineLift.value (AffineDot.mask4 (word memory iteration) 1)))) := by
  rw [product,evaluate,input_value,lift_value,product_value]
  rfl

theorem add_product_value (contracted : Nat → Bool) (memory : Memory) (iteration offset : Fin 4)
    (left right : Expr) (previous : Float32) (first : evaluate contracted memory iteration (.add left right)=some previous) :
    evaluate contracted memory iteration (.add (.add left right) (product offset))=some
      (maddFloat (contracted (additions (.add left right))) (input memory iteration offset)
        (AffineLift.value (AffineDot.mask4 (word memory iteration) offset)) previous) := by
  rw [product,evaluate,first,input_value,lift_value]
  · rfl
  · exact fun _ _ h => Expr.noConfusion h

theorem body_value (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) :
    evaluate contracted memory iteration body.value=some
      (maddFloat (contracted 2) (input memory iteration 3) (AffineLift.value (AffineDot.mask4 (word memory iteration) 3))
        (maddFloat (contracted 1) (input memory iteration 2) (AffineLift.value (AffineDot.mask4 (word memory iteration) 2))
          (maddLeftFloat (contracted 0) (input memory iteration 0) (AffineLift.value (AffineDot.mask4 (word memory iteration) 0))
            (FlushToZero.mul (input memory iteration 1) (AffineLift.value (AffineDot.mask4 (word memory iteration) 1)))))) :=
  add_product_value contracted memory iteration 3 _ _ _
    (add_product_value contracted memory iteration 2 _ _ _ (pair_value contracted memory iteration))

attribute [local irreducible] evaluate parse

theorem execution (contracted : Nat → Bool) (memory : Memory) (iteration : Fin 4) (accumulator : Float32) :
    executeSource contracted memory iteration accumulator=some
      (MlxQmv.source4 contracted (word memory iteration) (input memory iteration) accumulator) := by
  rw [executeSource,parsed_body,Option.bind_some]
  unfold execute
  simp only [show body.target="accum" from rfl,ne_eq,not_true_eq_false,ite_false]
  rw [body_value]
  simp only [MlxQmv.source4, MlxQmv.integer_mask4]
  rfl

-- These are bounds on the actual byte/word addresses used above, not a claim
-- that a native descriptor has been attached to these logical memories.
theorem read_bounds (memory : Memory) (iteration offset : Fin 4)
    (aligned : memory.packedBase%2=0) (packedRoom : memory.packedBase+8≤2^64)
    (scaledRoom : memory.scaledBase+16≤2^64) :
    (memory.packedBase+2*iteration.val)%2=0 ∧
    memory.packedBase≤memory.packedBase+2*iteration.val ∧
    memory.packedBase+2*iteration.val+2≤2^64 ∧
    memory.scaledBase≤memory.scaledBase+4*iteration.val+offset.val ∧
    memory.scaledBase+4*iteration.val+offset.val<2^64 := by
  have := iteration.isLt
  have := offset.isLt
  omega

end Inference.Kernels.Quantization.MlxQmvDot4Source
