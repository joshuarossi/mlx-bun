import kernels.normalization.ResidualRmsCellSyntax
import kernels.ResidualRmsMemory

namespace Inference.Kernels.Normalization.ResidualRmsCellSemantics
open Contracts.Mlx ResidualRmsCellSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def count : Nat := 5120
abbrev BF := ArrayStorage.BF

inductive Value where
  | uint : Nat → Value
  | floating : Float32 → Value
  | bfloat : BF → Value
abbrev Environment := String → Option Value

def set (env : Environment) (name : String) (value : Value) : Environment :=
  fun other => if other=name then some value else env other

-- Explicit logical conversion and arithmetic machine: BF16 -> binary32 widen,
-- flushed binary32 addition/multiply/FMA, nearest-even BF16 narrowing. Metal
-- cast/builtin/compiler conformance is separate. No promotion is invented.
def evaluate (left right : Nat) (env : Environment) (memory : HalfMemory.Bytes) : Expr → Option Value
  | .var name => env name
  | .index name index => do
    match ←evaluate left right env memory index with
    | .uint atIndex =>
      if name="x" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (left+2*atIndex))))
      else if name="update" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (right+2*atIndex)))) else none
    | _ => none
  | .cast typeName expression => do
    match typeName,←evaluate left right env memory expression with
    | "uint",.uint n => pure (.uint (n%2^32))
    | "float",.bfloat value => pure (.floating (BFloat16.widen value))
    | "T",.floating value => pure (.bfloat (BFloat16.narrow value))
    | _,_ => none
  | .add lhs rhs => do
    match ←evaluate left right env memory lhs,←evaluate left right env memory rhs with
    | .uint x,.uint y => pure (.uint ((x+y)%2^32))
    | .floating x,.floating y => pure (.floating (FlushToZero.add x y))
    | _,_ => none
  | .mul lhs rhs => do
    match ←evaluate left right env memory lhs,←evaluate left right env memory rhs with
    | .uint x,.uint y => pure (.uint ((x*y)%2^32))
    | .floating x,.floating y => pure (.floating (FlushToZero.mul x y))
    | _,_ => none

structure Machine where
  env : Environment
  memory : HalfMemory.Bytes

def typed (typeName : String) (value : Value) : Bool :=
  match typeName,value with
  | "uint",.uint _ => true
  | "float",.floating _ => true
  | "T",.bfloat _ => true
  | _,_ => false

-- The chosen compiler contraction mode affects only this source += product.
-- It is an explicit input, with no reassociation across different cells.
def increment (contracted : Bool) (left right : Nat) (state : Machine) (acc : Float32) (expression : Expr) : Option Float32 := do
  if contracted then
    match expression with
    | .mul lhs rhs =>
      match ←evaluate left right state.env state.memory lhs,←evaluate left right state.env state.memory rhs with
      | .floating x,.floating y => pure (FlushToZero.fma x y acc)
      | _,_ => none
    | _ => none
  else
    match ←evaluate left right state.env state.memory expression with
    | .floating value => pure (FlushToZero.add acc value)
    | _ => none

def instruction (contracted : Bool) (left right destination : Nat) (statement : Stmt) (state : Machine) : Option Machine := do
  match statement with
  | .constant typeName name expression =>
    let value ←evaluate left right state.env state.memory expression
    if typed typeName value then pure {state with env:=set state.env name value} else none
  | .store name index expression =>
    match name,←evaluate left right state.env state.memory index,←evaluate left right state.env state.memory expression with
    | "residual",.uint index,.bfloat value =>
      pure {state with memory:=HalfMemory.store state.memory (destination+2*index) (ArrayStorage.bits value)}
    | _,_,_ => none
  | .addAssign name expression =>
    match state.env name with
    | some (.floating acc) =>
      let value ←increment contracted left right state acc expression
      pure {state with env:=set state.env name (.floating value)}
    | _ => none

def execute (contracted : Bool) (left right destination : Nat) : List Stmt → Machine → Option Machine
  | [],state => some state
  | head::tail,state => do
    let next ←instruction contracted left right destination head state
    execute contracted left right destination tail next

def initialEnv (col : Fin count) (acc : Float32) : Environment := fun name =>
  if name="row" then some (.uint 0) else if name="D" then some (.uint count)
  else if name="col" then some (.uint col.val) else if name="acc" then some (.floating acc) else none

def initial (col : Fin count) (acc : Float32) (memory : HalfMemory.Bytes) : Machine := ⟨initialEnv col acc,memory⟩

def residual (left right : Nat) (memory : HalfMemory.Bytes) (col : Fin count) : BF :=
  ResidualRmsNorm.residual (Model.ofBits (HalfMemory.load memory (left+2*col.val)))
    (Model.ofBits (HalfMemory.load memory (right+2*col.val)))

def step (contracted : Bool) (value : BF) (acc : Float32) : Float32 :=
  let v:=BFloat16.widen value
  if contracted then FlushToZero.fma v v acc else FlushToZero.add acc (FlushToZero.mul v v)

def finalState (contracted : Bool) (left right destination : Nat) (col : Fin count) (acc : Float32) (memory : HalfMemory.Bytes) : Machine :=
  let value:=residual left right memory col
  ⟨set (set (set (set (initialEnv col acc) "index" (.uint col.val)) "value" (.bfloat value))
    "v" (.floating (BFloat16.widen value))) "acc" (.floating (step contracted value acc)),
    HalfMemory.store memory (destination+2*col.val) (ArrayStorage.bits value)⟩

theorem execution (contracted : Bool) (left right destination : Nat) (col : Fin count) (acc : Float32) (memory : HalfMemory.Bytes) :
    execute contracted left right destination body (initial col acc memory)=
      some (finalState contracted left right destination col acc memory) := by
  have small : col.val<4294967296 := by have := col.isLt; dsimp [count] at *; omega
  cases contracted <;>
    simp [execute,instruction,increment,evaluate,body,initial,initialEnv,set,typed,finalState,residual,step,
      ResidualRmsNorm.residual,ResidualRmsNorm.added,count,Nat.mod_eq_of_lt small]

theorem any_execution (contracted : Bool) (left right destination : Nat) (col : Fin count) (acc : Float32)
    (memory : HalfMemory.Bytes) (after : Machine)
    (actual : execute contracted left right destination body (initial col acc memory)=some after) :
    after=finalState contracted left right destination col acc memory :=
  Option.some.inj (actual.symm.trans (execution contracted left right destination col acc memory))

theorem parsed_execution (contracted : Bool) (left right destination : Nat) (col : Fin count) (acc : Float32)
    (memory : HalfMemory.Bytes) {parsed : List Stmt} (source : parseBody sourceBody=some parsed) (after : Machine)
    (actual : execute contracted left right destination parsed (initial col acc memory)=some after) :
    after=finalState contracted left right destination col acc memory := by
  have equal : parsed=body := Option.some.inj (source.symm.trans parsed_body)
  subst parsed
  exact any_execution contracted left right destination col acc memory after actual

end Inference.Kernels.Normalization.ResidualRmsCellSemantics
