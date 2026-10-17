import kernels.binary.BinaryVvSyntax
import kernels.binary.BFloatAddSource
import kernels.copy.ScalarCopyBodySemantics

namespace Inference.Kernels.Binary.BinaryVvBody
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Copy.ScalarCopySyntax (Expr)
open Copy.ScalarCopyBodySemantics (Environment update number condition)
open BinaryVvSyntax (Stmt body sourceBody parseBody parsed_body write)
set_option maxRecDepth 10000

def count : Nat := 5120

def scalar (left right : Nat) (env : Environment) (memory : HalfMemory.Bytes) : Expr → Option (BitVec 16)
  | .index "a" index => do pure (HalfMemory.load memory (left+2*(←number env index)))
  | .index "b" index => do pure (HalfMemory.load memory (right+2*(←number env index)))
  | _ => none

structure Machine where
  env : Environment
  memory : HalfMemory.Bytes

def call (left right : Nat) (env : Environment) (memory : HalfMemory.Bytes) (lhs rhs : Expr) : Option (BitVec 16) := do
  let a ←scalar left right env memory lhs
  let b ←scalar left right env memory rhs
  pure (ArrayStorage.bits (BFloatAddSource.operation (Model.ofBits a) (Model.ofBits b)))

def writeCell (destination : Nat) (state : Machine) (index : Nat) (value : BitVec 16) : Machine :=
  {state with memory:=HalfMemory.store state.memory (destination+2*index) value}

mutual
  inductive Statements (left right destination : Nat) : List Stmt → Machine → Machine → Prop where
    | nil (state) : Statements left right destination [] state state
    | cons : Statement left right destination head before middle →
        Statements left right destination tail middle after →
        Statements left right destination (head::tail) before after
  inductive Statement (left right destination : Nat) : Stmt → Machine → Machine → Prop where
    | mulAssign (evaluated : number before.env (.mul (.var name) rhs)=some value) :
        Statement left right destination (.mulAssign name rhs) before {before with env := update before.env name value}
    | store (atIndex : number before.env index=some indexValue)
        (loaded : call left right before.env before.memory lhs rhs=some value) :
        Statement left right destination (.store (.index "c" index) "Op" lhs rhs) before (writeCell destination before indexValue value)
    | ifTrue (tested : condition before.env test=some true)
        (branch : Statements left right destination yes before after) :
        Statement left right destination (.ifElse test yes no) before after
    | ifFalse (tested : condition before.env test=some false)
        (branch : Statements left right destination no before after) :
        Statement left right destination (.ifElse test yes no) before after
    | forLoop (initialized : number before.env initial=some value)
        (iterations : Loop left right destination name test loopBody {before with env := update before.env name value} after) :
        Statement left right destination (.forLoop name initial test loopBody) before after
  inductive Loop (left right destination : Nat) : String → Expr → List Stmt → Machine → Machine → Prop where
    | done (tested : condition before.env test=some false) :
        Loop left right destination name test loopBody before before
    | next (tested : condition before.env test=some true)
        (iteration : Statements left right destination loopBody before middle)
        (localValue : middle.env name=some value)
        (rest : Loop left right destination name test loopBody {middle with env := update middle.env name ((value+1)%2^32)} after) :
        Loop left right destination name test loopBody before after
end

theorem statements_deterministic (first : Statements left right destination code before after)
    (second : Statements left right destination code before other) : after=other := by
  induction first using Statements.rec
    (motive_2 := fun code before after _ => ∀ other, Statement left right destination code before other → after=other)
    (motive_3 := fun name test code before after _ => ∀ other, Loop left right destination name test code before other → after=other)
    generalizing other with
  | nil => cases second; rfl
  | cons head tail ihHead ihTail =>
    cases second with
    | cons otherHead otherTail =>
      have same := ihHead _ otherHead
      cases same
      exact ihTail otherTail
  | mulAssign evaluated =>
    rename_i other second
    cases second with
    | mulAssign otherEvaluated =>
      have same := Option.some.inj (evaluated.symm.trans otherEvaluated)
      cases same
      rfl
  | store index loaded =>
    rename_i other second
    cases second with
    | store otherIndex otherLoaded =>
      have sameIndex := Option.some.inj (index.symm.trans otherIndex)
      have sameValue := Option.some.inj (loaded.symm.trans otherLoaded)
      cases sameIndex
      cases sameValue
      rfl
  | ifTrue tested branch ih =>
    rename_i other second
    cases second with
    | ifTrue _ otherBranch => exact ih otherBranch
    | ifFalse otherTested _ => have impossible := tested.symm.trans otherTested; cases impossible
  | ifFalse tested branch ih =>
    rename_i other second
    cases second with
    | ifTrue otherTested _ => have impossible := tested.symm.trans otherTested; cases impossible
    | ifFalse _ otherBranch => exact ih otherBranch
  | forLoop initialized iterations ih =>
    rename_i other second
    cases second with
    | forLoop otherInitialized otherIterations =>
      have same := Option.some.inj (initialized.symm.trans otherInitialized)
      cases same
      exact ih _ otherIterations
  | done tested =>
    rename_i other second
    cases second with
    | done => rfl
    | next otherTested _ _ _ => have impossible := tested.symm.trans otherTested; cases impossible
  | next tested iteration localValue rest ihIteration ihRest =>
    rename_i other second
    cases second with
    | done otherTested => have impossible := tested.symm.trans otherTested; cases impossible
    | next _ otherIteration otherLocalValue otherRest =>
      have same := ihIteration otherIteration
      cases same
      have sameValue := Option.some.inj (localValue.symm.trans otherLocalValue)
      cases sameValue
      exact ihRest _ otherRest

def environment (thread : Fin count) : Environment := fun name =>
  if name="index" then some thread.val else if name="N" then some 1 else if name="size" then some count else none

def initial (thread : Fin count) (memory : HalfMemory.Bytes) : Machine := ⟨environment thread,memory⟩
def value (left right : Nat) (memory : HalfMemory.Bytes) (thread : Fin count) : BitVec 16 :=
  ArrayStorage.bits (BFloatAddSource.operation
    (Model.ofBits (HalfMemory.load memory (left+2*thread.val)))
    (Model.ofBits (HalfMemory.load memory (right+2*thread.val))))

def finalState (left right destination : Nat) (thread : Fin count) (memory : HalfMemory.Bytes) : Machine :=
  ⟨update (update (update (environment thread) "index" thread.val) "i" 0) "i" 1,
    HalfMemory.store memory (destination+2*thread.val) (value left right memory thread)⟩

theorem body_execution (left right destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin count) :
    Statements left right destination body (initial thread memory) (finalState left right destination thread memory) := by
  have small : thread.val<4294967296 := by have := thread.isLt; dsimp [count] at *; omega
  let s1 : Machine := {(initial thread memory) with env := update (initial thread memory).env "index" thread.val}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := writeCell destination s2 thread.val (value left right memory thread)
  let s4 : Machine := {s3 with env := update s3.env "i" ((0+1)%2^32)}
  have first : Statement left right destination (.mulAssign "index" (.var "N")) (initial thread memory) s1 :=
    .mulAssign (by simp [number, initial, environment, Nat.mod_eq_of_lt small])
  have copied : Statements left right destination [BinaryVvSyntax.write] s2 s3 := by
    refine .cons (.store (indexValue:=thread.val) (value:=value left right memory thread) ?_ ?_) (.nil _)
    · simp [number, s2, s1, update, Nat.mod_eq_of_lt small]
    · simp [call, scalar, value, number, s2, s1, initial, update, Nat.mod_eq_of_lt small]
  have doneLoop : Loop left right destination "i" (.lt (.var "i") (.var "N")) [BinaryVvSyntax.write] s4 s4 :=
    .done (by
      simp [condition, number, s4, s3, s2, s1, writeCell, update, initial, environment])
  have fullLoop : Loop left right destination "i" (.lt (.var "i") (.var "N")) [BinaryVvSyntax.write] s2 s4 :=
    .next (by simp [condition, number, s2, s1, update, initial, environment]) copied
      (by simp [s3, s2, writeCell, update]) doneLoop
  have forStatement : Statement left right destination
      (.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [BinaryVvSyntax.write]) s1 s4 :=
    .forLoop rfl fullLoop
  have conditional : Statement left right destination
      (.ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
      [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [BinaryVvSyntax.write]]
      [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [BinaryVvSyntax.write]]) s1 s4 :=
    .ifFalse (by simp [condition, number, s1, update, initial, environment]) (.cons forStatement (.nil _))
  simpa only [show ((0+1)%2^32:Nat)=1 by decide, body, finalState, s4, s3, s2, s1, initial, writeCell] using Statements.cons first (Statements.cons conditional (Statements.nil _))


theorem any_execution (left right destination : Nat) (thread : Fin count) (memory : HalfMemory.Bytes) (after : Machine)
    (executed : Statements left right destination body (initial thread memory) after) :
    after=finalState left right destination thread memory :=
  statements_deterministic executed (body_execution left right destination memory thread)

theorem parsed_execution (left right destination : Nat) (thread : Fin count) (memory : HalfMemory.Bytes) (after : Machine)
    {parsed : List Stmt} (source : parseBody sourceBody=some parsed)
    (executed : Statements left right destination parsed (initial thread memory) after) :
    after.memory=HalfMemory.store memory (destination+2*thread.val) (value left right memory thread) := by
  have equal : parsed=body := Option.some.inj (source.symm.trans parsed_body)
  subst parsed
  rw [any_execution left right destination thread memory after executed]
  rfl

theorem index_arithmetic (thread : Fin count) :
    thread.val<2^32 ∧ (thread.val*1)%2^32=thread.val ∧ (thread.val+0)%2^32=thread.val ∧
      (0:Nat)+1<2^31 ∧ (1:Nat)<2^31 := by
  have := thread.isLt
  dsimp [count] at *
  omega

def run (left right destination : Nat) : List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes
  | [], memory => memory
  | thread::rest, memory => run left right destination rest
      (HalfMemory.store memory (destination+2*thread.val) (value left right memory thread))

inductive Launch (left right destination : Nat) : List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (memory) : Launch left right destination [] memory memory
  | next (execution : Statements left right destination body (initial thread memory) state)
      (rest : Launch left right destination threads state.memory after) :
      Launch left right destination (thread::threads) memory after

theorem launch (left right destination : Nat) (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    Launch left right destination threads memory (run left right destination threads memory) := by
  induction threads generalizing memory with
  | nil => exact .nil _
  | cons thread rest ih => exact .next (body_execution left right destination memory thread) (ih _)

theorem launch_eq_run (execution : Launch left right destination threads before after) :
    after=run left right destination threads before := by
  induction execution with
  | nil => rfl
  | @next thread memory state threads after executed rest ih =>
    rw [any_execution left right destination thread memory state executed] at ih
    exact ih

theorem parsed_scalar_call (x y : BitVec 16) :
    BFloatAddSource.Evaluates (BFloatAddSource.environment (Model.ofBits x) (Model.ofBits y))
      BFloatAddSource.body.result
      (BFloatAddSource.operation (Model.ofBits x) (Model.ofBits y)) :=
  BFloatAddSource.execution _ _

theorem parsed_sources : BinaryVvSyntax.parseBody BinaryVvSyntax.sourceBody=some BinaryVvSyntax.body ∧
    BFloatAddSource.parseBody BFloatAddSource.sourceBody=some BFloatAddSource.body :=
  ⟨BinaryVvSyntax.parsed_body,BFloatAddSource.parsed_body⟩

end Inference.Kernels.Binary.BinaryVvBody
