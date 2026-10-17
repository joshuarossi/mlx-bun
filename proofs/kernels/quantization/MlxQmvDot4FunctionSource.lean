import kernels.quantization.MlxQmvDot4FunctionSyntax
import kernels.quantization.MlxQmvDot4LoopSource
import kernels.quantization.AffineTile
import contracts.mlx.Float32AdditionCommutative

namespace Inference.Kernels.Quantization.MlxQmvDot4FunctionSource
open Contracts.Mlx ArithmeticFold MlxQmvDot4FunctionSyntax
open Trellis.GateTailSyntax (Expr)
set_option maxRecDepth 10000
attribute [local irreducible] parseInitializer parsePointer parseReturn

def start (statement : Initializer) : Option Float32 :=
  if statement.name="accum" then match statement.value with
    | .integer n => some (Float32.ofInt n)
    | _ => none
  else none
def startSource : Option Float32 := (parseInitializer sourceInitializer).bind start
theorem start_zero : startSource=some 0 := by rw [startSource,parsed_initializer]; rfl

-- Reinterpretation retains the original byte heap and byte address. Alignment
-- and all four uint16 loads are checked before this memory view is attached.
def attach (memory : MlxQmvDot4Source.Memory) (statement : Pointer) : Option MlxQmvDot4Source.Memory :=
  if statement.name="ws" ∧ statement.source="w" ∧ memory.packedBase%2=0 ∧ memory.packedBase+8≤2^64
  then some memory else none
def attachSource (memory : MlxQmvDot4Source.Memory) : Option MlxQmvDot4Source.Memory :=
  (parsePointer sourcePointer).bind (attach memory)
theorem attach_current (memory : MlxQmvDot4Source.Memory)
    (aligned : memory.packedBase%2=0) (bounded : memory.packedBase+8≤2^64) :
    attachSource memory=some memory := by
  simp [attachSource,parsed_pointer,attach,pointer,aligned]
  omega

def environment (scale accum sum bias : Float32) (name : String) : Option Float32 :=
  if name="scale" then some scale else if name="accum" then some accum
  else if name="sum" then some sum else if name="bias" then some bias else none

-- This lowering is explicit: contract the left product with the addition, or
-- preserve both products and the source's left/right addition order.
def evaluate (contracted : Bool) (bindings : String → Option Float32) : Expr → Option Float32
  | .variable name => bindings name
  | .multiply left right => do pure (FlushToZero.mul (←evaluate contracted bindings left) (←evaluate contracted bindings right))
  | .add (.multiply a b) right => do
      let a ←evaluate contracted bindings a
      let b ←evaluate contracted bindings b
      let c ←evaluate contracted bindings right
      pure (if contracted then FlushToZero.fma a b c else FlushToZero.add (FlushToZero.mul a b) c)
  | .add left right => do pure (FlushToZero.add (←evaluate contracted bindings left) (←evaluate contracted bindings right))
  | _ => none

def returned (contracted : Bool) (scale accum sum bias : Float32) : Option Float32 :=
  (parseReturn sourceReturn).bind (evaluate contracted (environment scale accum sum bias))

attribute [local irreducible] evaluate

theorem parsed_return_bind {α : Type} (f : Expr → Option α) :
    (parseReturn sourceReturn).bind f=f returnValue := by
  rw [parsed_return,Option.bind_some]

theorem variable_value (contracted : Bool) (bindings : String → Option Float32) (name : String) :
    evaluate contracted bindings (.variable name)=bindings name := by rw [evaluate]

theorem multiply_value (contracted : Bool) (bindings : String → Option Float32)
    (left right : Expr) (a b : Float32)
    (first : evaluate contracted bindings left=some a) (second : evaluate contracted bindings right=some b) :
    evaluate contracted bindings (.multiply left right)=some (FlushToZero.mul a b) := by
  rw [evaluate,first,second]
  rfl

theorem add_product_value (contracted : Bool) (bindings : String → Option Float32)
    (left middle right : Expr) (a b c : Float32)
    (first : evaluate contracted bindings left=some a) (second : evaluate contracted bindings middle=some b)
    (third : evaluate contracted bindings right=some c) :
    evaluate contracted bindings (.add (.multiply left middle) right)=some
      (if contracted then FlushToZero.fma a b c else FlushToZero.add (FlushToZero.mul a b) c) := by
  rw [evaluate,first,second,third]
  rfl

theorem return_order (contracted : Bool) (scale accum sum bias : Float32) :
    returned contracted scale accum sum bias=some
      (if contracted then FlushToZero.fma scale accum (FlushToZero.mul sum bias)
       else FlushToZero.add (FlushToZero.mul scale accum) (FlushToZero.mul sum bias)) := by
  rw [returned,parsed_return_bind]
  apply add_product_value
  · rw [variable_value]; rfl
  · rw [variable_value]; rfl
  · apply multiply_value
    · rw [variable_value]; rfl
    · rw [variable_value]; rfl

attribute [local irreducible] returned

theorem return_model (contracted : Bool) (scale accum sum bias : Float32)
    (finite : Arithmetic.Finite (AffineTile.tailBind scale accum sum bias) (AffineTile.tailExpr contracted)) :
    returned contracted scale accum sum bias=some (maddFloat contracted scale accum (FlushToZero.mul sum bias)) := by
  rw [return_order]
  cases contracted with
  | true => simp only [maddFloat,ite_true]
  | false =>
    simp only [maddFloat,Bool.false_eq_true,ite_false]
    have left := Arithmetic.finite_evaluate (AffineTile.tailBind scale accum sum bias)
      (.mul (.input 0) (.input 1)) finite.2.1
    have right := Arithmetic.finite_evaluate (AffineTile.tailBind scale accum sum bias)
      (.mul (.input 2) (.input 3)) finite.1
    simp only [Arithmetic.evaluate,AffineTile.tailBind] at left right
    exact congrArg some (Float32AdditionCommutative.flushed _ _ left right)

structure Execution (contracted tailContracted : Bool) (memory : MlxQmvDot4Source.Memory)
    (scale sum bias result : Float32) : Prop where
  initial : startSource=some 0
  pointer : attachSource memory=some memory
  loop : MlxQmvDot4LoopSource.Runs MlxQmvDot4LoopSource.header contracted memory
    MlxQmvDot4LoopSource.header.initial 0 [0,1,2,3] (MlxQmvDot4LoopSource.result contracted memory 0)
  finish : returned tailContracted scale (MlxQmvDot4LoopSource.result contracted memory 0) sum bias=some result

theorem execution (contracted tailContracted : Bool) (memory : MlxQmvDot4Source.Memory)
    (scale sum bias : Float32) (aligned : memory.packedBase%2=0) (bounded : memory.packedBase+8≤2^64)
    (finite : Arithmetic.Finite
      (AffineTile.tailBind scale (MlxQmvDot4LoopSource.result contracted memory 0) sum bias)
      (AffineTile.tailExpr tailContracted)) :
    Execution contracted tailContracted memory scale sum bias
      (maddFloat tailContracted scale (MlxQmvDot4LoopSource.result contracted memory 0) (FlushToZero.mul sum bias)) :=
  ⟨start_zero,attach_current memory aligned bounded,MlxQmvDot4LoopSource.execution contracted memory 0,
    return_model tailContracted scale _ sum bias finite⟩

-- The join requires the actual input cells to contain the prepared values;
-- it never takes equality of the computed result as a premise. Producing and
-- attaching the native threadgroup scratch remains a separate source bridge.
theorem dot_eq (p : AffineTile.Platform) (x : Fin 16 → AffineTile.BF) (memory : MlxQmvDot4Source.Memory)
    (prepared : ∀ chunk offset, MlxQmvDot4Source.input memory chunk offset=AffineTile.prepared4 p x chunk offset) :
    MlxQmvDot4LoopSource.result p.contracted memory 0=AffineTile.dot4 p x (MlxQmvDot4Source.word memory) := by
  have inputs : MlxQmvDot4Source.input memory=AffineTile.prepared4 p x :=
    funext (fun chunk => funext (prepared chunk))
  simp only [MlxQmvDot4LoopSource.result,MlxQmvDot4LoopSource.step,
    AffineTile.dot4,AffineTile.step4,inputs,MlxQmv.source4_eq]

theorem tile_execution (p : AffineTile.Platform) (x : Fin 16 → AffineTile.BF)
    (memory : MlxQmvDot4Source.Memory) (scale bias : AffineTile.BF)
    (aligned : memory.packedBase%2=0) (bounded : memory.packedBase+8≤2^64)
    (prepared : ∀ chunk offset, MlxQmvDot4Source.input memory chunk offset=AffineTile.prepared4 p x chunk offset)
    (finite : AffineTile.Finite4 p x (MlxQmvDot4Source.word memory) scale bias) :
    Execution p.contracted p.tailContracted memory (BFloat16.widen scale)
      (AffineInput.summed x AffineInput.groups4) (BFloat16.widen bias)
      (AffineTile.value4 p x (MlxQmvDot4Source.word memory) scale bias) := by
  have dot := dot_eq p x memory prepared
  have tail := finite.tail
  rw [←dot] at tail
  have run := execution p.contracted p.tailContracted memory (BFloat16.widen scale)
    (AffineInput.summed x AffineInput.groups4) (BFloat16.widen bias) aligned bounded tail
  simpa only [dot,AffineTile.value4,AffineTile.combine] using run

end Inference.Kernels.Quantization.MlxQmvDot4FunctionSource
