import kernels.copy.ScalarCopySemantics
import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Copy.ScalarCopyBodySemantics
set_option maxRecDepth 100000
open Contracts.Mlx ScalarCopySyntax ScalarCopySemantics
attribute [local irreducible] run List.finRange

-- A syntax-directed interpretation of this restricted syntax. Arithmetic is uint32
-- arithmetic. The only signed local reached in the selected specialization is
-- i=0,1; its conversion/increment agrees with these operations without overflow.
abbrev Environment := String → Option Nat

def update (env : Environment) (name : String) (value : Nat) : Environment :=
  fun key => if key=name then some value else env key

def number (env : Environment) : Expr → Option Nat
  | .var name => env name
  | .nat value => some value
  | .add left right => do pure (((← number env left)+(← number env right))%2^32)
  | .mul left right => do pure (((← number env left)*(← number env right))%2^32)
  | _ => none

def condition (env : Environment) : Expr → Option Bool
  | .lt left right => do pure ((← number env left)<(← number env right))
  | .gt left right => do pure ((← number env left)>(← number env right))
  | .land left right => do
      if ← condition env left then condition env right else pure false
  | _ => none

def scalar (env : Environment) (memory : HalfMemory.Bytes) (source : Nat) : Expr → Option (BitVec 16)
  | .index "src" index => do pure (HalfMemory.load memory (source+2*(← number env index)))
  | .cast "U" value => scalar env memory source value
  | _ => none

structure Machine where
  env : Environment
  memory : HalfMemory.Bytes
  issued : List HalfMemory.Store

def write (destination : Nat) (state : Machine) (index : Nat) (value : BitVec 16) : Machine :=
  let event : HalfMemory.Store := ⟨destination/2+index,value⟩
  {state with memory := HalfMemory.execute [event] state.memory, issued := state.issued++[event]}

mutual
  inductive Statements (source destination : Nat) : List Stmt → Machine → Machine → Prop where
    | nil (state) : Statements source destination [] state state
    | cons : Statement source destination head before middle →
        Statements source destination tail middle after →
        Statements source destination (head::tail) before after
  inductive Statement (source destination : Nat) : Stmt → Machine → Machine → Prop where
    | mulAssign (evaluated : number before.env (.mul (.var name) rhs)=some value) :
        Statement source destination (.mulAssign name rhs) before {before with env := update before.env name value}
    | assign (aligned : destination%2=0) (atIndex : number before.env index=some indexValue)
        (loaded : scalar before.env before.memory source rhs=some value) :
        Statement source destination (.assign (.index "dst" index) rhs) before (write destination before indexValue value)
    | ifTrue (tested : condition before.env test=some true)
        (branch : Statements source destination yes before after) :
        Statement source destination (.ifElse test yes no) before after
    | ifFalse (tested : condition before.env test=some false)
        (branch : Statements source destination no before after) :
        Statement source destination (.ifElse test yes no) before after
    | forLoop (initialized : number before.env initial=some value)
        (iterations : Loop source destination name test loopBody {before with env := update before.env name value} after) :
        Statement source destination (.forLoop name initial test loopBody) before after
  inductive Loop (source destination : Nat) : String → Expr → List Stmt → Machine → Machine → Prop where
    | done (tested : condition before.env test=some false) :
        Loop source destination name test loopBody before before
    | next (tested : condition before.env test=some true)
        (iteration : Statements source destination loopBody before middle)
        (localValue : middle.env name=some value)
        (rest : Loop source destination name test loopBody {middle with env := update middle.env name ((value+1)%2^32)} after) :
        Loop source destination name test loopBody before after
end

theorem statements_deterministic (first : Statements source destination code before after)
    (second : Statements source destination code before other) : after=other := by
  induction first using Statements.rec
    (motive_2 := fun code before after _ => ∀ other, Statement source destination code before other → after=other)
    (motive_3 := fun name test code before after _ => ∀ other, Loop source destination name test code before other → after=other)
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
  | assign aligned index loaded =>
    rename_i other second
    cases second with
    | assign _ otherIndex otherLoaded =>
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

def initial (memory : HalfMemory.Bytes) (thread : Fin count) : Machine :=
  { env := fun name => if name="index" then some thread.val else
      if name="N" then some 1 else if name="size" then some count else none
    memory := memory
    issued := [] }

def final (source destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin count) : Machine :=
  { env := update (update (update (initial memory thread).env "index" thread.val) "i" 0) "i" 1
    memory := HalfMemory.execute [event source destination memory thread] memory
    issued := [event source destination memory thread] }

-- Every rule evaluates expressions against its CURRENT heap, including the
-- scalar RHS of the actual native assignment. Both loop tests are derived.
theorem write_pointer (destination : Nat) (aligned : destination%2=0) (state : Machine)
    (index : Nat) (value : BitVec 16) :
    (write destination state index value).memory=HalfMemory.store state.memory (destination+2*index) value := by
  dsimp only [write, HalfMemory.execute]
  rw [show 2*(destination/2+index)=destination+2*index by omega]

theorem body_execution (source destination : Nat) (aligned : destination%2=0) (memory : HalfMemory.Bytes) (thread : Fin count) :
    Statements source destination body (initial memory thread) (final source destination memory thread) := by
  have small : thread.val<4294967296 := by have := (index_arithmetic thread).1; omega
  let s1 : Machine := {(initial memory thread) with env := update (initial memory thread).env "index" thread.val}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := write destination s2 thread.val (HalfMemory.load memory source)
  let s4 : Machine := {s3 with env := update s3.env "i" ((0+1)%2^32)}
  have first : Statement source destination (.mulAssign "index" (.var "N")) (initial memory thread) s1 :=
    .mulAssign (by simp [number, initial, Nat.mod_eq_of_lt small])
  have copied : Statements source destination [ScalarCopySyntax.write] s2 s3 := by
    refine .cons (.assign (indexValue:=thread.val) (value:=HalfMemory.load memory source) aligned ?_ ?_) (.nil _)
    · simp [number, s2, s1, update, Nat.mod_eq_of_lt small]
    · simp [scalar, number, s2, s1, initial]
  have doneLoop : Loop source destination "i" (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write] s4 s4 :=
    .done (by
      simp [condition, number, s4, s3, s2, s1, write, update, initial])
  have fullLoop : Loop source destination "i" (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write] s2 s4 :=
    .next (by simp [condition, number, s2, s1, update, initial]) copied
      (by simp [s3, s2, write, update]) doneLoop
  have forStatement : Statement source destination
      (.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write]) s1 s4 :=
    .forLoop rfl fullLoop
  have conditional : Statement source destination
      (.ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
      [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [ScalarCopySyntax.write]]
      [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write]]) s1 s4 :=
    .ifFalse (by simp [condition, number, s1, update, initial]) (.cons forStatement (.nil _))
  exact .cons first (.cons conditional (.nil _))

-- Every thread in the concrete dynamic launch has a derivation of the full AST.
inductive Launch (source destination : Nat) : List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (memory) : Launch source destination [] memory memory
  | next (bodyExecution : Statements source destination body (initial memory thread) state)
      (rest : Launch source destination threads state.memory after) :
      Launch source destination (thread::threads) memory after

theorem launch_refines (source destination : Nat) (aligned : destination%2=0) (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    Launch source destination threads memory (run source destination threads memory) := by
  induction threads generalizing memory with
  | nil => rw [run]; exact .nil _
  | cons thread rest ih =>
      rw [run]
      exact .next (body_execution source destination aligned memory thread) (ih _)

theorem parsed_execution (source destination : Nat) (aligned : destination%2=0) (memory : HalfMemory.Bytes) (thread : Fin count) :
    ∃ statements, parseBody sourceBody=some statements ∧
      Statements source destination statements (initial memory thread) (final source destination memory thread) :=
  ⟨body, parsed_body, body_execution source destination aligned memory thread⟩

theorem body_unique (aligned : destination%2=0)
    (execution : Statements source destination body (initial memory thread) after) :
    after=final source destination memory thread :=
  statements_deterministic execution (body_execution source destination aligned memory thread)

theorem parsed_unique (aligned : destination%2=0)
    (parsed : parseBody sourceBody=some statements)
    (execution : Statements source destination statements (initial memory thread) after) :
    after=final source destination memory thread := by
  have same := Option.some.inj (parsed.symm.trans parsed_body)
  subst statements
  exact body_unique aligned execution

theorem launch_eq_run (aligned : destination%2=0)
    (execution : Launch source destination threads before after) :
    after=run source destination threads before := by
  induction execution with
  | nil => rw [run]
  | next bodyExecution rest ih =>
      have same := body_unique aligned bodyExecution
      cases same
      rw [run]
      exact ih

theorem canonical_execution_refines (allocation : Allocation source destination)
    (execution : Launch source destination (List.finRange count) before after) :
    after=(trace allocation before).memory :=
  (launch_eq_run allocation.destinationAligned execution).trans (canonical_refines allocation before)

theorem execution_read (allocation : Allocation source destination)
    (execution : Launch source destination threads before after)
    (completed : threads.Perm (List.finRange count)) (thread : Fin count) :
    HalfMemory.load after (destination+2*thread.val)=HalfMemory.load before source := by
  rw [launch_eq_run allocation.destinationAligned execution]
  exact permutation_read allocation threads completed before thread

theorem execution_frame (allocation : Allocation source destination)
    (execution : Launch source destination threads before after)
    (separate : MemoryRegions.Disjoint destination (2*count) other size)
    (offset : Nat) (bound : offset<size) : after (other+offset)=before (other+offset) := by
  rw [launch_eq_run allocation.destinationAligned execution]
  exact frame allocation threads before separate offset bound

theorem execution_scalar_retained (allocation : Allocation source destination)
    (execution : Launch source destination threads before after) :
    HalfMemory.load after source=HalfMemory.load before source := by
  rw [launch_eq_run allocation.destinationAligned execution]
  exact scalar_retained allocation threads before

def outputBuffer {value : ArrayStorage.BF} (source : ArrayStorage.BFBuffer (fun _ : Fin 1 => value))
    (allocation : Allocation source.base destination) :
    ArrayStorage.BFBuffer (fun _ : Fin count => value) where
  bytes := run source.base destination (List.finRange count) source.bytes
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := by
    intro thread
    exact (canonical_read allocation source.bytes thread).trans (by
      simpa only [Nat.mul_zero, Nat.add_zero] using source.attached ⟨0,by omega⟩)

theorem outputBuffer_launch {value : ArrayStorage.BF} (source : ArrayStorage.BFBuffer (fun _ : Fin 1 => value))
    (allocation : Allocation source.base destination) :
    Launch source.base destination (List.finRange count) source.bytes (outputBuffer source allocation).bytes :=
  launch_refines _ _ allocation.destinationAligned _ _

def sourceAfter {value : ArrayStorage.BF} (source : ArrayStorage.BFBuffer (fun _ : Fin 1 => value))
    (allocation : Allocation source.base destination) : ArrayStorage.BFBuffer (fun _ : Fin 1 => value) :=
  ArrayFrame.bf source (run source.base destination (List.finRange count) source.bytes) (frame allocation _ source.bytes allocation.fresh)

end Inference.Kernels.Copy.ScalarCopyBodySemantics
