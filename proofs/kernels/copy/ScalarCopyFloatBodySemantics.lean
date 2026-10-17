import kernels.copy.ScalarCopyFloatSemantics
import kernels.copy.ScalarCopyBodySemantics

namespace Inference.Kernels.Copy.ScalarCopyFloatBodySemantics
open Contracts.Mlx ScalarCopySyntax ScalarCopyFloatSemantics
set_option maxRecDepth 10000
attribute [local irreducible] run List.finRange

-- Selected float->float identity cast; raw32loads/stores preserve bits.
-- Arithmetic reuses the uint32 expression interpreter. Signed loop locals
-- reach only0,1,2; their increments and mixed unsigned additions are bounded.
-- Kernel signature/template selection, host bindings, compiler and hardware
-- memory semantics remain explicit external boundaries.
abbrev Environment := ScalarCopyBodySemantics.Environment
abbrev update := ScalarCopyBodySemantics.update
abbrev number := ScalarCopyBodySemantics.number
abbrev condition := ScalarCopyBodySemantics.condition

def scalar (env : Environment) (memory : ByteMemory.Bytes) (source : Nat) : Expr → Option (BitVec 32)
  | .index "src" index => do pure (ByteMemory.load32 memory (source+4*(← number env index)))
  | .cast "U" value => scalar env memory source value
  | _ => none

structure Machine where
  env : Environment
  memory : ByteMemory.Bytes
  issued : List ByteMemory.Store

def write (destination : Nat) (state : Machine) (index : Nat) (value : BitVec 32) : Machine :=
  let event : ByteMemory.Store := ⟨destination/4+index,value⟩
  {state with memory := ByteMemory.execute [event] state.memory, issued := state.issued++[event]}

mutual
  inductive Statements (source destination : Nat) : List Stmt → Machine → Machine → Prop where
    | nil (state) : Statements source destination [] state state
    | cons : Statement source destination head before middle →
        Statements source destination tail middle after →
        Statements source destination (head::tail) before after
  inductive Statement (source destination : Nat) : Stmt → Machine → Machine → Prop where
    | mulAssign (evaluated : number before.env (.mul (.var name) rhs)=some value) :
        Statement source destination (.mulAssign name rhs) before {before with env := update before.env name value}
    | assign (aligned : destination%4=0) (atIndex : number before.env exprIndex=some indexValue)
        (loaded : scalar before.env before.memory source rhs=some value) :
        Statement source destination (.assign (.index "dst" exprIndex) rhs) before (write destination before indexValue value)
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


def initial (memory : ByteMemory.Bytes) (thread : Fin threadCount) : Machine :=
  { env := fun name => if name="index" then some thread.val else
      if name="N" then some 2 else if name="size" then some count else none
    memory := memory
    issued := [] }

def final (source destination : Nat) (memory : ByteMemory.Bytes) (thread : Fin threadCount) : Machine :=
  let s1 : Machine := {(initial memory thread) with env := update (initial memory thread).env "index" (2*thread.val)}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := write destination s2 (2*thread.val) (ByteMemory.load32 s2.memory source)
  let s4 : Machine := {s3 with env := update s3.env "i" 1}
  let s5 := write destination s4 (2*thread.val+1) (ByteMemory.load32 s4.memory source)
  {s5 with env := update s5.env "i" 2}

theorem body_execution (source destination : Nat) (aligned : destination%4=0)
    (memory : ByteMemory.Bytes) (thread : Fin threadCount) :
    Statements source destination body (initial memory thread) (final source destination memory thread) := by
  have bounded := native_index thread
  have small0 : 2*thread.val<2^32 := by omega
  have small1 : 2*thread.val+1<2^32 := by omega
  have small2 : 2*thread.val+2<2^32 := bounded.2
  have noTail : ¬2*thread.val+2>count := by omega
  let s1 : Machine := {(initial memory thread) with env := update (initial memory thread).env "index" (2*thread.val)}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := write destination s2 (2*thread.val) (ByteMemory.load32 s2.memory source)
  let s4 : Machine := {s3 with env := update s3.env "i" 1}
  let s5 := write destination s4 (2*thread.val+1) (ByteMemory.load32 s4.memory source)
  let s6 : Machine := {s5 with env := update s5.env "i" 2}
  have first : Statement source destination (.mulAssign "index" (.var "N")) (initial memory thread) s1 :=
    .mulAssign (by simp [number,ScalarCopyBodySemantics.number,initial,Nat.mul_comm]; omega)
  have copied0 : Statements source destination [ScalarCopySyntax.write] s2 s3 := by
    refine .cons (.assign (indexValue:=2*thread.val) (value:=ByteMemory.load32 s2.memory source) aligned ?_ ?_) (.nil _)
    · simp [number,ScalarCopyBodySemantics.number,s2,s1,update,ScalarCopyBodySemantics.update]; omega
    · simp [scalar,number,ScalarCopyBodySemantics.number,s2,s1,initial]
  have copied1 : Statements source destination [ScalarCopySyntax.write] s4 s5 := by
    refine .cons (.assign (indexValue:=2*thread.val+1) (value:=ByteMemory.load32 s4.memory source) aligned ?_ ?_) (.nil _)
    · simp [number,ScalarCopyBodySemantics.number,s4,s3,s2,s1,write,update,ScalarCopyBodySemantics.update]; omega
    · simp [scalar,number,ScalarCopyBodySemantics.number,s4,s3,s2,s1,write,initial]
  have stop : Loop source destination "i" (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write] s6 s6 :=
    .done (by simp [condition,ScalarCopyBodySemantics.condition,ScalarCopyBodySemantics.number,
      s6,s5,s4,s3,s2,s1,write,update,ScalarCopyBodySemantics.update,initial])
  have second : Loop source destination "i" (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write] s4 s6 :=
    .next (value:=1) (by simp [condition,ScalarCopyBodySemantics.condition,ScalarCopyBodySemantics.number,
      s4,s3,s2,s1,write,update,ScalarCopyBodySemantics.update,initial]) copied1
      (by simp [s5,s4,write,update,ScalarCopyBodySemantics.update]) stop
  have both : Loop source destination "i" (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write] s2 s6 :=
    .next (value:=0) (by simp [condition,ScalarCopyBodySemantics.condition,ScalarCopyBodySemantics.number,
      s2,s1,update,ScalarCopyBodySemantics.update,initial]) copied0
      (by simp [s3,s2,write,update,ScalarCopyBodySemantics.update]) second
  have forStatement : Statement source destination
      (.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write]) s1 s6 :=
    .forLoop rfl both
  have conditional : Statement source destination
      (.ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
      [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [ScalarCopySyntax.write]]
      [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [ScalarCopySyntax.write]]) s1 s6 :=
    .ifFalse (by simp [condition,ScalarCopyBodySemantics.condition,ScalarCopyBodySemantics.number,
      s1,update,ScalarCopyBodySemantics.update,initial]; omega) (.cons forStatement (.nil _))
  exact .cons first (.cons conditional (.nil _))

theorem final_memory (source destination : Nat) (memory : ByteMemory.Bytes) (thread : Fin threadCount) :
    (final source destination memory thread).memory=run source destination [index thread 0,index thread 1] memory := by
  dsimp [final,write,initial]
  rw [run,run,run]
  rfl



theorem body_unique (aligned : destination%4=0)
    (execution : Statements source destination body (initial memory thread) after) :
    after=final source destination memory thread :=
  statements_deterministic execution (body_execution source destination aligned memory thread)

theorem parsed_unique (aligned : destination%4=0) (parsed : parseBody sourceBody=some statements)
    (execution : Statements source destination statements (initial memory thread) after) :
    after=final source destination memory thread := by
  have same := Option.some.inj (parsed.symm.trans parsed_body)
  subst statements
  exact body_unique aligned execution

inductive Launch (source destination : Nat) : List (Fin threadCount) → ByteMemory.Bytes → ByteMemory.Bytes → Prop where
  | nil (memory) : Launch source destination [] memory memory
  | next (bodyExecution : Statements source destination body (initial memory thread) state)
      (rest : Launch source destination threads state.memory after) :
      Launch source destination (thread::threads) memory after

theorem launch_refines (source destination : Nat) (aligned : destination%4=0)
    (threads : List (Fin threadCount)) (memory : ByteMemory.Bytes) :
    Launch source destination threads memory (run source destination (indices threads) memory) := by
  induction threads generalizing memory with
  | nil => rw [indices, List.flatMap_nil,run]; exact .nil _
  | cons thread rest ih =>
    rw [indices,List.flatMap_cons,run_append,←final_memory]
    exact .next (body_execution source destination aligned memory thread) (ih _)

theorem launch_eq_run (aligned : destination%4=0)
    (execution : Launch source destination threads before after) :
    after=run source destination (indices threads) before := by
  induction execution with
  | nil => rw [indices,List.flatMap_nil,run]
  | next bodyExecution rest ih =>
    have same := body_unique aligned bodyExecution
    cases same
    rw [indices,List.flatMap_cons,run_append,←final_memory]
    exact ih

theorem execution_raw_read (allocation : Allocation source destination)
    (execution : Launch source destination threads before after)
    (completed : threads.Perm (List.finRange threadCount)) (i : Fin count) :
    ByteMemory.load32 after (destination+4*i.val)=ByteMemory.load32 before source := by
  rw [launch_eq_run allocation.destinationAligned execution]
  exact completed_read allocation (indices threads) (indices_covered threads completed) before i

theorem execution_frame (allocation : Allocation source destination)
    (execution : Launch source destination threads before after)
    (separate : MemoryRegions.Disjoint destination (4*count) other size) (offset : Nat) (bound : offset<size) :
    after (other+offset)=before (other+offset) := by
  rw [launch_eq_run allocation.destinationAligned execution]
  exact frame allocation (indices threads) before separate offset bound

-- The raw scalar attachment refers to the INITIAL executing heap. This is not
-- a desired output premise, nor an inferred raw-bit identity for arbitrary NaNs.
theorem execution_refines (allocation : Allocation source destination)
    (execution : Launch source destination threads before after)
    (completed : threads.Perm (List.finRange threadCount)) (value : Float32)
    (raw : ByteMemory.load32 before source=FloatMemory.bits value) :
    parseBody sourceBody=some body ∧ after=(floatTrace allocation before value).memory :=
  ⟨parsed_body,(launch_eq_run allocation.destinationAligned execution).trans
    (float_refines allocation threads completed before value raw)⟩

theorem write_pointer (destination : Nat) (aligned : destination%4=0) (state : Machine)
    (atIndex : Nat) (value : BitVec 32) :
    (write destination state atIndex value).memory=ByteMemory.store32 state.memory (destination+4*atIndex) value := by
  dsimp only [write,ByteMemory.execute]
  rw [show 4*(destination/4+atIndex)=destination+4*atIndex by omega]

-- The signed int loop variable takes exactly0,1,2 with no signed overflow.
theorem signed_local (i : Nat) (reached : i≤2) : i<2^31 ∧ i+1<2^31 := by omega

section Attached
variable {value : Float32} (sourceBuffer : ArrayStorage.FloatBuffer (fun _ : Fin 1 => value))
    (allocation : Allocation sourceBuffer.base destination)
    (raw : ByteMemory.load32 sourceBuffer.bytes sourceBuffer.base=FloatMemory.bits value)

def outputBuffer : ArrayStorage.FloatBuffer (fun _ : Fin count => value) where
  bytes := run sourceBuffer.base destination (indices (List.finRange threadCount)) sourceBuffer.bytes
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := by
    intro i
    unfold FloatMemory.load
    rw [completed_read allocation _ (indices_covered _ (List.Perm.refl _)) sourceBuffer.bytes i,raw,FloatMemory.decode_bits]

theorem outputBuffer_launch :
    Launch sourceBuffer.base destination (List.finRange threadCount) sourceBuffer.bytes (outputBuffer sourceBuffer allocation raw).bytes :=
  launch_refines _ _ allocation.destinationAligned _ _

def sourceAfter : ArrayStorage.FloatBuffer (fun _ : Fin 1 => value) :=
  ArrayFrame.fp sourceBuffer (outputBuffer sourceBuffer allocation raw).bytes
    (frame allocation _ sourceBuffer.bytes allocation.fresh)

theorem source_output_shared : (sourceAfter sourceBuffer allocation raw).bytes=(outputBuffer sourceBuffer allocation raw).bytes := rfl

end Attached
end Inference.Kernels.Copy.ScalarCopyFloatBodySemantics
