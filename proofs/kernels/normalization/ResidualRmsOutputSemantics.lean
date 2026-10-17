import kernels.normalization.ResidualRmsOutputSyntax
import kernels.normalization.ResidualRmsCellSemantics

namespace Inference.Kernels.Normalization.ResidualRmsOutputSemantics
open Contracts.Mlx ResidualRmsOutputSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ResidualRmsCellSemantics (count BF Value Environment Machine set initialEnv)
set_option maxRecDepth 10000

def evaluate (residual weight : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (env : Environment) (memory : HalfMemory.Bytes) : Expr → Option Value
  | .var name => env name
  | .zero => some (.uint 0)
  | .index name index => do
    match ←evaluate residual weight inverse inverseBase env memory index with
    | .uint atIndex =>
      if name="residual" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (residual+2*atIndex))))
      else if name="weight" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (weight+2*atIndex))))
      else if name="inv" then pure (.floating (inverse (inverseBase+atIndex))) else none
    | _ => none
  | .cast typeName expression => do
    match typeName,←evaluate residual weight inverse inverseBase env memory expression with
    | "uint",.uint n => pure (.uint (n%2^32))
    | "float",.bfloat value => pure (.floating (BFloat16.widen value))
    | "T",.floating value => pure (.bfloat (BFloat16.narrow value))
    | _,_ => none
  | .add lhs rhs => do
    match ←evaluate residual weight inverse inverseBase env memory lhs,←evaluate residual weight inverse inverseBase env memory rhs with
    | .uint x,.uint y => pure (.uint ((x+y)%2^32))
    | _,_ => none
  | .mul lhs rhs => do
    match ←evaluate residual weight inverse inverseBase env memory lhs,←evaluate residual weight inverse inverseBase env memory rhs with
    | .uint x,.uint y => pure (.uint ((x*y)%2^32))
    | .floating x,.floating y => pure (.floating (FlushToZero.mul x y))
    | .bfloat x,.bfloat y => pure (.bfloat (BFloat16Arithmetic.mul x y))
    | _,_ => none

def instruction (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (statement : Stmt) (state : Machine) : Option Machine := do
  match statement with
  | .constant typeName name expression =>
    let value ←evaluate residual weight inverse inverseBase state.env state.memory expression
    if ResidualRmsCellSemantics.typed typeName value then pure {state with env:=set state.env name value} else none
  | .store name index expression =>
    match name,←evaluate residual weight inverse inverseBase state.env state.memory index,
        ←evaluate residual weight inverse inverseBase state.env state.memory expression with
    | "normalized",.uint atIndex,.bfloat value =>
      pure {state with memory:=HalfMemory.store state.memory (destination+2*atIndex) (ArrayStorage.bits value)}
    | _,_,_ => none

def execute (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat) : List Stmt → Machine → Option Machine
  | [],state => some state
  | statement::rest,state => do
    let next ←instruction residual weight destination inverse inverseBase statement state
    execute residual weight destination inverse inverseBase rest next

def value (residual weight : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) : BF :=
  ResidualRmsMemory.operation (inverse inverseBase)
    (Model.ofBits (HalfMemory.load memory (residual+2*col.val)))
    (Model.ofBits (HalfMemory.load memory (weight+2*col.val)))

def finalState (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) : Machine :=
  ⟨set (initialEnv col 0) "index" (.uint col.val),
    HalfMemory.store memory (destination+2*col.val) (ArrayStorage.bits (value residual weight inverse inverseBase col memory))⟩

theorem execution (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) :
    execute residual weight destination inverse inverseBase body ⟨initialEnv col 0,memory⟩=
      some (finalState residual weight destination inverse inverseBase col memory) := by
  have small : col.val<4294967296 := by have := col.isLt; dsimp [count] at *; omega
  simp [execute,instruction,evaluate,body,initialEnv,ResidualRmsCellSemantics.set,ResidualRmsCellSemantics.typed,
    finalState,value,ResidualRmsMemory.operation,count,Nat.mod_eq_of_lt small]

def executeSource (source : String) (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) : Option Machine := do
  let parsed ←parseBody source
  execute residual weight destination inverse inverseBase parsed ⟨initialEnv col 0,memory⟩

theorem source_execution (residual weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (col : Fin count) (memory : HalfMemory.Bytes) :
    executeSource sourceBody residual weight destination inverse inverseBase col memory=
      some (finalState residual weight destination inverse inverseBase col memory) := by
  unfold executeSource
  rw [parsed_body]
  exact execution _ _ _ _ _ _ _

end Inference.Kernels.Normalization.ResidualRmsOutputSemantics
