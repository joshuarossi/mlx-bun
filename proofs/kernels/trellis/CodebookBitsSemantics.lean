import kernels.trellis.CodebookBitsSyntax
import kernels.trellis.CodebookIntegerSemantics
namespace Inference.Kernels.Trellis.CodebookBitsSemantics
open CodebookBitsSyntax
namespace FP
export Codebook.FloatingPoint (lifted reciprocal unrefined)
end FP
set_option maxRecDepth 10000
-- Selected typed expression semantics. Binary32 operations are separately
-- rounded; this does not prove Metal frontend contraction/fast-math behavior.
inductive Value where
  | signed : Int → Value
  | unsigned : UInt32 → Value
  | floating : Float32 → Value
abbrev Environment := String → Option Value
def set (env : Environment) (name : String) (value : Value) : Environment :=
  fun other => if other=name then some value else env other

def decimalFloat (mantissa scale : Nat) : Float32 :=
  Float32.ofModel (Float32.Model.ofScientific mantissa (-(scale:Int)))

def evaluate (env : Environment) : Expr → Option Value
  | .variable name => env name
  | .integer unsigned n =>
      if unsigned then if n<2^32 then some (.unsigned (UInt32.ofNat n)) else none
      else if n<2^31 then some (.signed (Int.ofNat n)) else none
  | .floating m scale => some (.floating (decimalFloat m scale))
  | .add left right => do
      match ←evaluate env left,←evaluate env right with
      | .signed a,.signed b => if CodebookIntegerSemantics.representable (a+b) then pure (.signed (a+b)) else none
      | _,_ => none
  | .toUInt expression => do
      match ←evaluate env expression with
      | .signed a => if 0≤a ∧ a<2^32 then pure (.unsigned (UInt32.ofInt a)) else none
      | _ => none
  | .bitOr left right => do
      match ←evaluate env left,←evaluate env right with
      | .unsigned a,.unsigned b => pure (.unsigned (a ||| b))
      | _,_ => none
  | .reinterpretFloat expression => do
      match ←evaluate env expression with
      | .unsigned bits => pure (.floating (Float32.ofBits bits))
      | _ => none
  | .subtract left right => do
      match ←evaluate env left,←evaluate env right with
      | .floating a,.floating b => pure (.floating (a-b))
      | _,_ => none
  | .multiply left right => do
      match ←evaluate env left,←evaluate env right with
      | .floating a,.floating b => pure (.floating (a*b))
      | _,_ => none
  | .divide left right => do
      match ←evaluate env left,←evaluate env right with
      | .floating a,.floating b => pure (.floating (a/b))
      | _,_ => none

def execute : List Stmt → Environment → Option Float32
  | [],_ => none
  | .constantFloat name expression::rest,env => do
      match ←evaluate env expression with
      | .floating value => execute rest (set env name (.floating value))
      | _ => none
  | [.returnValue expression],env => do
      match ←evaluate env expression with
      | .floating value => pure value
      | _ => none
  | .returnValue _::_::_,_ => none

def initial (y : Int) : Environment := fun name => if name="y" then some (.signed y) else none
def liftBits (y : Int) : Float32 := Float32.ofBits (0x4b000000 ||| UInt32.ofInt (y+510))
def afterLift (y : Int) : Environment := set (initial y) "lifted" (.floating (liftBits y))

theorem decimal_one : decimalFloat 10 1=(1:Float32) := by decide +kernel
theorem decimal_offset : decimalFloat 83891180 1=(8389118:Float32) := by decide +kernel
theorem decimal_divisor : decimalFloat 147800537109375 12=Codebook.FloatingPoint.divisor := by decide +kernel

theorem evaluate_lift (y : Int) (range : -510≤y ∧ y≤510) :
    evaluate (initial y) liftExpression=some (.floating (liftBits y)) := by
  have signed : CodebookIntegerSemantics.representable (y+510) := by
    unfold CodebookIntegerSemantics.representable; omega
  have unsigned : 0≤y+510 ∧ y+510<2^32 := by omega
  have upper : y+510<4294967296 := by omega
  simp [liftExpression,evaluate,initial,signed,unsigned,liftBits,upper]

theorem evaluate_result (y : Int) : evaluate (afterLift y) resultExpression=
    some (.floating (FP.lifted y * FP.reciprocal)) := by
  simp only [resultExpression,evaluate,afterLift,set,ite_eq_left,
    decimal_one,decimal_offset,decimal_divisor]
  rfl

theorem execute_constant (env : Environment) (name : String) (expression : Expr)
    (value : Float32) (tail : List Stmt) (evaluated : evaluate env expression=some (.floating value)) :
    execute (.constantFloat name expression::tail) env=execute tail (set env name (.floating value)) := by
  simp only [execute,evaluated]
  rfl
theorem execute_return (env : Environment) (expression : Expr) (value : Float32)
    (evaluated : evaluate env expression=some (.floating value)) :
    execute [.returnValue expression] env=some value := by
  simp only [execute,evaluated]
  rfl

theorem execution (y : Int) (range : -510≤y ∧ y≤510) :
    execute body (initial y)=some (FP.lifted y * FP.reciprocal) := by
  exact (execute_constant (initial y) "lifted" liftExpression (liftBits y)
    [.returnValue resultExpression] (evaluate_lift y range)).trans
    (execute_return (afterLift y) resultExpression _ (evaluate_result y))

private theorem bits_injective (a b : Float32) (h : a.toBits=b.toBits) : a=b := by
  cases a with
  | ofModel a =>
    cases b with
    | ofModel b =>
      cases a with
      | mk ab av =>
        cases b with
        | mk bb bv =>
          change ab=bb at h
          cases h
          rfl

-- The existing finite exhaustive binary32 theorem supplies equality to the
-- mathematical integer conversion, not a premise asserting the desired output.
theorem lifted_eq (y : Int) (range : -510≤y ∧ y≤510) : FP.lifted y=Float32.ofInt y := by
  let i : Fin 1021 := ⟨(y+510).toNat,by omega⟩
  have index : (i.val:Int)-510=y := by simp only [i]; omega
  apply bits_injective
  have result := Codebook.FloatingPoint.lifted_correct i
  rw [index] at result
  exact result

theorem parsed_execution (y : Int) (range : -510≤y ∧ y≤510) :
    ((parseBody sourceBody).bind (fun actual => execute actual (initial y)))=some (FP.unrefined y) := by
  rw [parsed_body,Option.bind_some,execution y range,lifted_eq y range]
  rfl

theorem finite (y : Int) (range : -510≤y ∧ y≤510) : (FP.unrefined y).isFinite=true := by
  let i : Fin 1021 := ⟨(y+510).toNat,by omega⟩
  have index : (i.val:Int)-510=y := by simp only [i]; omega
  have result := (Codebook.FloatingPoint.unrefined_accuracy i).2.2
  rw [index] at result
  exact result

theorem any_execution (y : Int) (range : -510≤y ∧ y≤510) (actual : List Stmt)
    (value : Float32) (parsed : parseBody sourceBody=some actual)
    (executed : execute actual (initial y)=some value) :
    value=FP.unrefined y ∧ value.isFinite=true := by
  have result := parsed_execution y range
  rw [parsed,Option.bind_some,executed] at result
  have equality : value=FP.unrefined y := Option.some.inj result
  exact ⟨equality,equality ▸ finite y range⟩

theorem state_execution (state : BitVec 32) :
    ((parseBody sourceBody).bind (fun actual => execute actual (initial (Codebook.implementation state))))=
      some (FP.unrefined (Codebook.specification state)) := by
  rw [parsed_execution _ (Codebook.range state),Codebook.correct]
theorem joined_source_execution (state : BitVec 32) :
    (((CodebookIntegerSyntax.parseBody CodebookIntegerSyntax.sourceBody).bind
      (fun actual => CodebookIntegerSemantics.execute actual (CodebookIntegerSemantics.initial state))).bind
      (fun y => (parseBody sourceBody).bind (fun actual => execute actual (initial y))))=
      some (FP.unrefined (Codebook.specification state)) := by
  rw [CodebookIntegerSemantics.parsed_execution,Option.bind_some]
  exact parsed_execution _ (by rw [←Codebook.correct]; exact Codebook.range state)

end Inference.Kernels.Trellis.CodebookBitsSemantics
