import kernels.trellis.CodebookIntegerSyntax
import kernels.trellis.Codebook

namespace Inference.Kernels.Trellis.CodebookIntegerSemantics
open CodebookIntegerSyntax
set_option maxRecDepth 10000

-- Checked semantics of the selected source subset. uint operations wrap32;
-- signed literals/casts/subtraction must be representable, and a shift count
-- must be in[0,31]. Unsupported operand types fail rather than invent effects.
-- This does not assert C++ frontend, Metal compiler or hardware conformance.
inductive Value where
  | unsigned : BitVec 32 → Value
  | signed : Int → Value
  deriving DecidableEq, Repr

abbrev Environment := String → Option Value

def set (env : Environment) (name : String) (value : Value) : Environment :=
  fun other => if other=name then some value else env other

def representable (value : Int) : Prop := -(2^31)≤value ∧ value<2^31
instance (value : Int) : Decidable (representable value) := by unfold representable; infer_instance

def evaluate (env : Environment) : Expr → Option Value
  | .variable name => env name
  | .literal .unsigned n => if n<2^32 then some (.unsigned (BitVec.ofNat 32 n)) else none
  | .literal .signed n => if n<2^31 then some (.signed (Int.ofNat n)) else none
  | .add left right => do
      match ←evaluate env left,←evaluate env right with
      | .unsigned a,.unsigned b => pure (.unsigned (a+b))
      | _,_ => none
  | .multiply left right => do
      match ←evaluate env left,←evaluate env right with
      | .unsigned a,.unsigned b => pure (.unsigned (a*b))
      | _,_ => none
  | .bitAnd left right => do
      match ←evaluate env left,←evaluate env right with
      | .unsigned a,.unsigned b => pure (.unsigned (a &&& b))
      | _,_ => none
  | .shiftRight left right => do
      match ←evaluate env left,←evaluate env right with
      | .unsigned a,.signed b => if 0≤b ∧ b<32 then pure (.unsigned (a >>> b.toNat)) else none
      | _,_ => none
  | .castInt expression => do
      match ←evaluate env expression with
      | .unsigned a => if a.toNat<2^31 then pure (.signed a.toInt) else none
      | _ => none
  | .subtract left right => do
      match ←evaluate env left,←evaluate env right with
      | .signed a,.signed b => if representable (a-b) then pure (.signed (a-b)) else none
      | _,_ => none

def execute : List Stmt → Environment → Option Int
  | [], _ => none
  | .constantUInt name expression::rest,env => do
      match ←evaluate env expression with
      | .unsigned value => execute rest (set env name (.unsigned value))
      | _ => none
  | [.returnValue expression],env => do
      match ←evaluate env expression with
      | .signed value => pure value
      | _ => none
  | .returnValue _::_::_,_ => none

def initial (state : BitVec 32) : Environment :=
  fun name => if name="s" then some (.unsigned state) else none

def mixExpression : Expr := .add (.multiply (.variable "s") (.literal .unsigned 34038481)) (.literal .unsigned 76625530)
def pairsExpression : Expr := .add (.bitAnd (.variable "x") (.literal .unsigned 16711935))
  (.bitAnd (.shiftRight (.variable "x") (.literal .signed 8)) (.literal .unsigned 16711935))
def packedExpression : Expr := .add (.bitAnd (.variable "p") (.literal .unsigned 65535))
  (.shiftRight (.variable "p") (.literal .signed 16))
def resultExpression : Expr := .subtract (.castInt packedExpression) (.literal .signed 510)

def pairs (state : BitVec 32) : BitVec 32 :=
  let x := Codebook.mix state
  (x &&& 0x00FF00FF)+(x >>> 8 &&& 0x00FF00FF)
def afterX (state : BitVec 32) : Environment := set (initial state) "x" (.unsigned (Codebook.mix state))
def afterP (state : BitVec 32) : Environment := set (afterX state) "p" (.unsigned (pairs state))

theorem afterX_eq (state : BitVec 32) : afterX state=set (initial state) "x" (.unsigned (Codebook.mix state)) := rfl
theorem afterP_eq (state : BitVec 32) : afterP state=set (afterX state) "p" (.unsigned (pairs state)) := rfl

theorem body_shape : body=[.constantUInt "x" mixExpression,.constantUInt "p" pairsExpression,.returnValue resultExpression] := rfl

theorem evaluate_mix (state : BitVec 32) : evaluate (initial state) mixExpression=some (.unsigned (Codebook.mix state)) := rfl

theorem evaluate_pairs (state : BitVec 32) : evaluate (afterX state) pairsExpression=some (.unsigned (pairs state)) := rfl

theorem evaluate_packed (state : BitVec 32) :
    evaluate (afterP state) packedExpression=some (.unsigned (Codebook.packedSum (Codebook.mix state))) := rfl

theorem evaluate_cast (env : Environment) (expression : Expr) (value : BitVec 32)
    (evaluated : evaluate env expression=some (.unsigned value)) (safe : value.toNat<2^31) :
    evaluate env (.castInt expression)=some (.signed value.toInt) := by
  simp only [evaluate,evaluated,bind,pure,Option.bind_some,ite_eq_left safe]

theorem evaluate_subtract (env : Environment) (left right : Expr) (a b : Int)
    (first : evaluate env left=some (.signed a)) (second : evaluate env right=some (.signed b))
    (safe : representable (a-b)) : evaluate env (.subtract left right)=some (.signed (a-b)) := by
  simp only [evaluate,first,second,bind,pure,Option.bind_some,ite_eq_left safe]

theorem execute_constant (env : Environment) (name : String) (expression : Expr) (rest : List Stmt) (word : BitVec 32)
    (evaluated : evaluate env expression=some (.unsigned word)) :
    execute (.constantUInt name expression::rest) env=execute rest (set env name (.unsigned word)) := by
  simp only [execute,evaluated,bind,Option.bind_some]

theorem execute_return (env : Environment) (expression : Expr) (value : Int)
    (evaluated : evaluate env expression=some (.signed value)) :
    execute [.returnValue expression] env=some value := by
  simp only [execute,evaluated,bind,pure,Option.bind_some]

attribute [local irreducible] Codebook.mix Codebook.packedSum pairs

-- The existing arithmetic theorem bounds every unsigned packed sum before the
-- source's int cast, then bounds the signed subtraction. No overflow premise
-- is supplied by a caller, even when the initial multiply/add wrap.
theorem cast_safe (state : BitVec 32) :
    (Codebook.packedSum (Codebook.mix state)).toNat<2^31 ∧
    (Codebook.packedSum (Codebook.mix state)).toInt=
      Int.ofNat (Codebook.packedSum (Codebook.mix state)).toNat := by
  have packed := Codebook.packedSum_bound (Codebook.mix state)
  change (Codebook.packedSum (Codebook.mix state)).toNat≤1020 at packed
  constructor
  · omega
  · rw [BitVec.toInt_eq_toNat_cond,ite_eq_left (by omega)]
    rfl

theorem subtraction_safe (state : BitVec 32) : representable (Codebook.implementation state) := by
  have := Codebook.range state
  unfold representable
  omega

theorem evaluate_result (state : BitVec 32) :
    evaluate (afterP state) resultExpression=some (.signed (Codebook.implementation state)) := by
  apply evaluate_subtract
  · exact evaluate_cast _ _ _ (evaluate_packed state) (cast_safe state).1
  · rfl
  · exact subtraction_safe state

attribute [local irreducible] execute evaluate initial afterX afterP mixExpression pairsExpression packedExpression resultExpression

theorem execution (state : BitVec 32) :
    execute body (initial state)=some (Codebook.implementation state) := by
  rw [body_shape]
  have first : execute [.constantUInt "x" mixExpression,.constantUInt "p" pairsExpression,.returnValue resultExpression] (initial state)=
      execute [.constantUInt "p" pairsExpression,.returnValue resultExpression] (afterX state) :=
    (execute_constant (initial state) "x" mixExpression [.constantUInt "p" pairsExpression,.returnValue resultExpression] _ (evaluate_mix state)).trans
      (congrArg (execute [.constantUInt "p" pairsExpression,.returnValue resultExpression]) (afterX_eq state).symm)
  have second : execute [.constantUInt "p" pairsExpression,.returnValue resultExpression] (afterX state)=
      execute [.returnValue resultExpression] (afterP state) :=
    (execute_constant (afterX state) "p" pairsExpression [.returnValue resultExpression] _ (evaluate_pairs state)).trans
      (congrArg (execute [.returnValue resultExpression]) (afterP_eq state).symm)
  exact first.trans (second.trans (execute_return _ _ _ (evaluate_result state)))

-- Every parsed-body execution returns the proved mathematical byte sum. The
-- result is derived, not accepted as a desired arithmetic-value premise.
theorem parsed_execution (state : BitVec 32) :
    ((parseBody sourceBody).bind (fun code => execute code (initial state)))=
      some (Codebook.specification state) := by
  rw [parsed_body,Option.bind_some,execution,Codebook.correct]

theorem any_execution (state : BitVec 32) (code : List Stmt) (value : Int)
    (parsed : parseBody sourceBody=some code) (executed : execute code (initial state)=some value) :
    value=Codebook.specification state ∧ -510≤value ∧ value≤510 := by
  have same := Option.some.inj (parsed.symm.trans parsed_body)
  subst code
  have valueEq := Option.some.inj (executed.symm.trans (execution state))
  subst value
  exact ⟨Codebook.correct state,(Codebook.range state).1,(Codebook.range state).2⟩

theorem selected_lut_state (index : Fin 4096) :
    ((parseBody sourceBody).bind (fun code => execute code (initial (BitVec.ofNat 32 index.val))))=
      some (Codebook.specification (BitVec.ofNat 32 index.val)) := parsed_execution _

end Inference.Kernels.Trellis.CodebookIntegerSemantics
