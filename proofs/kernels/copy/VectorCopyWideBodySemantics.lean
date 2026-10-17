import kernels.copy.VectorCopyWideSemantics
import kernels.copy.ScalarCopyBodySemantics
import kernels.copy.VectorCopySyntax

namespace Inference.Kernels.Copy.VectorCopyWideBodySemantics
open Contracts.Mlx VectorCopyWideSemantics
open VectorCopySyntax (body parseBody sourceBody parsed_body)
open ScalarCopyBodySemantics (Machine Statements Statement Loop number condition scalar update write statements_deterministic)
set_option maxRecDepth 10000
variable {blocks : Nat}
local notation "count" => (4*blocks)
local notation "threadCount" => blocks
attribute [local irreducible] VectorCopyWideSemantics.run List.finRange

-- Reuse the syntax-directed BF16 interpreter, including actual CURRENT-heap
-- src[index+i] reads, rather than introducing an N4-specific AST semantics.
def initial (memory : HalfMemory.Bytes) (thread : Fin threadCount) : Machine :=
  { env := fun name => if name="index" then some thread.val else
      if name="N" then some 4 else if name="size" then some count else none
    memory := memory
    issued := [] }

def final (source destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin threadCount) : Machine :=
  let s1 : Machine := {(initial (blocks:=blocks) memory thread) with env := update (initial (blocks:=blocks) memory thread).env "index" (4*thread.val)}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := write destination s2 (4*thread.val) (HalfMemory.load s2.memory (source+2*(4*thread.val)))
  let s4 : Machine := {s3 with env := update s3.env "i" 1}
  let s5 := write destination s4 (4*thread.val+1) (HalfMemory.load s4.memory (source+2*(4*thread.val+1)))
  let s6 : Machine := {s5 with env := update s5.env "i" 2}
  let s7 := write destination s6 (4*thread.val+2) (HalfMemory.load s6.memory (source+2*(4*thread.val+2)))
  let s8 : Machine := {s7 with env := update s7.env "i" 3}
  let s9 := write destination s8 (4*thread.val+3) (HalfMemory.load s8.memory (source+2*(4*thread.val+3)))
  let s10 : Machine := {s9 with env := update s9.env "i" 4}
  s10

theorem body_execution (small : 4*blocks<2^32) (source destination : Nat) (aligned : destination%2=0)
    (memory : HalfMemory.Bytes) (thread : Fin threadCount) :
    Statements source destination body (initial (blocks:=blocks) memory thread) (final source destination memory thread) := by
  have bounded : thread.val*4+4≤count := by have := thread.isLt; omega
  have small0 : 4*thread.val<2^32 := by omega
  have small1 : 4*thread.val+1<2^32 := by omega
  have small2 : 4*thread.val+2<2^32 := by omega
  have small3 : 4*thread.val+3<2^32 := by omega
  have small4 : 4*thread.val+4<2^32 := by omega
  let s1 : Machine := {(initial (blocks:=blocks) memory thread) with env := update (initial (blocks:=blocks) memory thread).env "index" (4*thread.val)}
  let s2 : Machine := {s1 with env := update s1.env "i" 0}
  let s3 := write destination s2 (4*thread.val) (HalfMemory.load s2.memory (source+2*(4*thread.val)))
  let s4 : Machine := {s3 with env := update s3.env "i" 1}
  let s5 := write destination s4 (4*thread.val+1) (HalfMemory.load s4.memory (source+2*(4*thread.val+1)))
  let s6 : Machine := {s5 with env := update s5.env "i" 2}
  let s7 := write destination s6 (4*thread.val+2) (HalfMemory.load s6.memory (source+2*(4*thread.val+2)))
  let s8 : Machine := {s7 with env := update s7.env "i" 3}
  let s9 := write destination s8 (4*thread.val+3) (HalfMemory.load s8.memory (source+2*(4*thread.val+3)))
  let s10 : Machine := {s9 with env := update s9.env "i" 4}
  have first : Statement source destination (.mulAssign "index" (.var "N")) (initial (blocks:=blocks) memory thread) s1 :=
    .mulAssign (by simp [number,initial,Nat.mul_comm]; omega)
  have copied0 : Statements source destination [VectorCopySyntax.write] s2 s3 := by
    refine .cons (.assign (indexValue:=4*thread.val) (value:=HalfMemory.load s2.memory (source+2*(4*thread.val))) aligned ?_ ?_) (.nil _)
    · simp [number,s2,s1,update]; omega
    · simp [scalar,number,s2,s1,initial,update]
      congr 1
      omega
  have copied1 : Statements source destination [VectorCopySyntax.write] s4 s5 := by
    refine .cons (.assign (indexValue:=4*thread.val+1) (value:=HalfMemory.load s4.memory (source+2*(4*thread.val+1))) aligned ?_ ?_) (.nil _)
    · simp [number,s4,s3,s2,s1,write,update]; omega
    · simp [scalar,number,s4,s3,s2,s1,write,initial,update]
      congr 1
      omega
  have copied2 : Statements source destination [VectorCopySyntax.write] s6 s7 := by
    refine .cons (.assign (indexValue:=4*thread.val+2) (value:=HalfMemory.load s6.memory (source+2*(4*thread.val+2))) aligned ?_ ?_) (.nil _)
    · simp [number,s6,s5,s4,s3,s2,s1,write,update]; omega
    · simp [scalar,number,s6,s5,s4,s3,s2,s1,write,initial,update]
      congr 1
      omega
  have copied3 : Statements source destination [VectorCopySyntax.write] s8 s9 := by
    refine .cons (.assign (indexValue:=4*thread.val+3) (value:=HalfMemory.load s8.memory (source+2*(4*thread.val+3))) aligned ?_ ?_) (.nil _)
    · simp [number,s8,s7,s6,s5,s4,s3,s2,s1,write,update]; omega
    · simp [scalar,number,s8,s7,s6,s5,s4,s3,s2,s1,write,initial,update]
      congr 1
      omega
  have stop : Loop source destination "i" (.lt (.var "i") (.var "N")) [VectorCopySyntax.write] s10 s10 :=
    .done (by simp [condition,number,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,write,update,initial])
  have loop3 : Loop source destination "i" (.lt (.var "i") (.var "N")) [VectorCopySyntax.write] s8 s10 :=
    .next (value:=3) (by simp [condition,number,s8,s7,s6,s5,s4,s3,s2,s1,write,update,initial]) copied3
      (by simp [s9,s8,s7,s6,s5,s4,s3,s2,s1,write,update]) stop
  have loop2 : Loop source destination "i" (.lt (.var "i") (.var "N")) [VectorCopySyntax.write] s6 s10 :=
    .next (value:=2) (by simp [condition,number,s6,s5,s4,s3,s2,s1,write,update,initial]) copied2
      (by simp [s7,s6,s5,s4,s3,s2,s1,write,update]) loop3
  have loop1 : Loop source destination "i" (.lt (.var "i") (.var "N")) [VectorCopySyntax.write] s4 s10 :=
    .next (value:=1) (by simp [condition,number,s4,s3,s2,s1,write,update,initial]) copied1
      (by simp [s5,s4,s3,s2,s1,write,update]) loop2
  have loop0 : Loop source destination "i" (.lt (.var "i") (.var "N")) [VectorCopySyntax.write] s2 s10 :=
    .next (value:=0) (by simp [condition,number,s2,s1,update,initial]) copied0
      (by simp [s3,s2,s1,write,update]) loop1
  have forStatement : Statement source destination
      (.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [VectorCopySyntax.write]) s1 s10 :=
    .forLoop rfl loop0
  have conditional : Statement source destination
      (.ifElse (.land (.gt (.var "N") (.nat 1)) (.gt (.add (.var "index") (.var "N")) (.var "size")))
      [.forLoop "i" (.nat 0) (.lt (.add (.var "index") (.var "i")) (.var "size")) [VectorCopySyntax.write]]
      [.forLoop "i" (.nat 0) (.lt (.var "i") (.var "N")) [VectorCopySyntax.write]]) s1 s10 :=
    .ifFalse (by simp [condition,number,s1,update,initial]; omega) (.cons forStatement (.nil _))
  exact .cons first (.cons conditional (.nil _))

theorem final_memory (source destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin threadCount) :
    (final source destination memory thread).memory=
      run source destination [index thread 0,index thread 1,index thread 2,index thread 3] memory := by
  dsimp [final,write,initial]
  rw [run,run,run,run,run]
  rfl

theorem body_unique (small : 4*blocks<2^32) (aligned : destination%2=0)
    (execution : Statements source destination body (initial (blocks:=blocks) memory thread) after) :
    after=final source destination memory thread :=
  statements_deterministic execution (body_execution small source destination aligned memory thread)

theorem parsed_unique (small : 4*blocks<2^32) (aligned : destination%2=0) (parsed : parseBody sourceBody=some statements)
    (execution : Statements source destination statements (initial (blocks:=blocks) memory thread) after) :
    after=final source destination memory thread := by
  have same := Option.some.inj (parsed.symm.trans parsed_body)
  subst statements
  exact body_unique small aligned execution

inductive Launch (source destination : Nat) : List (Fin threadCount) → HalfMemory.Bytes → HalfMemory.Bytes → Prop where
  | nil (memory) : Launch source destination [] memory memory
  | next (bodyExecution : Statements source destination body (initial (blocks:=blocks) memory thread) state)
      (rest : Launch source destination threads state.memory after) :
      Launch source destination (thread::threads) memory after

theorem four_offsets : List.finRange 4=[0,1,2,3] := by simp only [List.finRange_succ,List.finRange_zero]; rfl

theorem run_append (source destination : Nat) (first second : List (Fin count)) (memory : HalfMemory.Bytes) :
    run source destination (first++second) memory=run source destination second (run source destination first memory) := by
  induction first generalizing memory with
  | nil => rw [List.nil_append,run]
  | cons first rest ih => simpa only [List.cons_append,run] using ih _

theorem launch_refines (small : 4*blocks<2^32) (source destination : Nat) (aligned : destination%2=0)
    (threads : List (Fin threadCount)) (memory : HalfMemory.Bytes) :
    Launch (blocks:=blocks) source destination threads memory (run source destination (indices threads) memory) := by
  induction threads generalizing memory with
  | nil => rw [indices,List.flatMap_nil,run]; exact .nil _
  | cons thread rest ih =>
    rw [indices,List.flatMap_cons,four_offsets,List.map_cons,List.map_cons,List.map_cons,List.map_cons,List.map_nil,run_append,←final_memory]
    exact .next (body_execution small source destination aligned memory thread) (by simpa only [indices,four_offsets] using ih _)

theorem launch_eq_run (small : 4*blocks<2^32) (aligned : destination%2=0)
    (execution : Launch (blocks:=blocks) source destination threads before after) :
    after=run source destination (indices threads) before := by
  induction execution with
  | nil => rw [indices,List.flatMap_nil,run]
  | next bodyExecution rest ih =>
    have same := body_unique small aligned bodyExecution
    cases same
    rw [indices,List.flatMap_cons,four_offsets,List.map_cons,List.map_cons,List.map_cons,List.map_cons,List.map_nil,run_append,←final_memory]
    simpa only [indices,four_offsets] using ih

theorem execution_read (small : 4*blocks<2^32) (allocation : Allocation (blocks:=blocks) source destination)
    (execution : Launch (blocks:=blocks) source destination threads before after)
    (completed : threads.Perm (List.finRange threadCount)) (i : Fin count) :
    HalfMemory.load after (destination+2*i.val)=HalfMemory.load before (source+2*i.val) := by
  rw [launch_eq_run small allocation.destinationAligned execution]
  exact completed_read allocation (indices threads)
    (indices_covered threads completed) before i

theorem execution_frame (small : 4*blocks<2^32) (allocation : Allocation (blocks:=blocks) source destination)
    (execution : Launch (blocks:=blocks) source destination threads before after)
    (separate : MemoryRegions.Disjoint destination (2*count) other size) (offset : Nat) (bound : offset<size) :
    after (other+offset)=before (other+offset) := by
  rw [launch_eq_run small allocation.destinationAligned execution]
  exact frame allocation (indices threads) before separate offset bound

theorem execution_refines (small : 4*blocks<2^32) (allocation : Allocation (blocks:=blocks) source destination)
    (execution : Launch (blocks:=blocks) source destination threads before after)
    (completed : threads.Perm (List.finRange threadCount)) :
    parseBody sourceBody=some body ∧ after=(VectorCopyWideSemantics.copyTrace allocation before).memory :=
  ⟨parsed_body,(launch_eq_run small allocation.destinationAligned execution).trans
    (threads_refine allocation threads completed before)⟩

theorem execution_trace_eq (small : 4*blocks<2^32) (allocation : Allocation (blocks:=blocks) source destination)
    (execution : Launch (blocks:=blocks) source destination threads before after) (completed : threads.Perm (List.finRange threadCount))
    (copied : CopyContiguous.Trace destination (CopyContiguous.vectorValues (blocks:=threadCount) before source))
    (initial : copied.before=before) : after=copied.memory :=
  ((execution_refines small allocation execution completed).2).trans (copyTrace_eq allocation before copied initial)

end Inference.Kernels.Copy.VectorCopyWideBodySemantics
