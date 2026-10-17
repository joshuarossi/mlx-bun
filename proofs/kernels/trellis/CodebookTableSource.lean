import kernels.trellis.CodebookTableSyntax
import kernels.trellis.CodebookBitsSemantics
import kernels.trellis.CodebookBarrier
import kernels.trellis.GateUpBarrier
namespace Inference.Kernels.Trellis.CodebookTableSource
open Contracts.Mlx Contracts.Mlx.M1Max CodebookTableSyntax
set_option maxRecDepth 10000

-- Explicit selected template environment: L=12; THREADS is the actual selected
-- group width. This is a restricted loop semantics, not a Metal frontend.
def bindings (code : Loop) : Prop :=
  code.counterName="i" ∧ code.initialBuiltin="thread_position_in_threadgroup" ∧
  code.initialComponent="x" ∧ code.testVariable=code.counterName ∧
  code.boundParameter="L" ∧ code.stepVariable=code.counterName ∧ code.stepParameter="THREADS" ∧
  code.table="codebook" ∧ code.subscript=code.counterName ∧ code.argument=code.counterName
instance (code : Loop) : Decidable (bindings code) := by unfold bindings; infer_instance

def limit (code : Loop) : Nat := ((BitVec.ofNat 32 code.boundBase) <<< 12).toNat

def invoke (outer inner : String) (index : BitVec 32) : Option Float32 :=
  if outer="trellis_unrefined_bits_y" ∧ inner="trellis_y" then
    ((CodebookIntegerSyntax.parseBody CodebookIntegerSyntax.sourceBody).bind
      (fun actual => CodebookIntegerSemantics.execute actual (CodebookIntegerSemantics.initial index))).bind
      (fun y => (CodebookBitsSyntax.parseBody CodebookBitsSyntax.sourceBody).bind
        (fun actual => CodebookBitsSemantics.execute actual (CodebookBitsSemantics.initial y)))
  else none

-- Current counter and increment are uint32. The parsed RHS produces float32;
-- assignment to threadgroup float stores that same binary32 value unchanged.
def step (code : Loop) (base threads counter : Nat) : Option (Memory.Store × Nat) :=
  if bindings code ∧ counter<limit code then do
    let value ← invoke code.outerFunction code.innerFunction (BitVec.ofNat 32 counter)
    pure (⟨base/4+counter,value⟩,(counter+threads)%2^32)
  else none

inductive Runs (code : Loop) (base threads : Nat) : Nat → List Memory.Store → Prop where
  | stop (counter : Nat) (bound : limit code≤counter) : Runs code base threads counter []
  | next {counter after : Nat} {store : Memory.Store} {tail : List Memory.Store}
      (issued : step code base threads counter=some (store,after))
      (rest : Runs code base threads after tail) : Runs code base threads counter (store::tail)

theorem selected_bindings : bindings loop := by decide
theorem selected_limit : limit loop=4096 := rfl

theorem invoke_correct (index : BitVec 32) :
    invoke loop.outerFunction loop.innerFunction index=some (CodebookLoad.codeValue index) := by
  have source := CodebookBitsSemantics.joined_source_execution index
  have correct := CodebookLoad.codeValue_correct index
  change CodebookLoad.codeValue index=Codebook.FloatingPoint.unrefined (Codebook.specification index) at correct
  rw [←correct] at source
  exact source

theorem native_arithmetic (threads thread iteration : Nat) (width : threads=256 ∨ threads=1024)
    (lane : thread<threads) (active : iteration<4096/threads) :
    thread+threads*iteration<4096 ∧
    thread+threads*iteration+threads<2^32 ∧
    (thread+threads*iteration+threads)%2^32=thread+threads*(iteration+1) := by
  rcases width with rfl | rfl <;> omega

theorem step_entry (base threads thread iteration : Nat) (width : threads=256 ∨ threads=1024)
    (lane : thread<threads) (active : iteration<4096/threads) :
    step loop base threads (thread+threads*iteration)=
      some (CodebookInitialization.entry base threads thread iteration,thread+threads*(iteration+1)) := by
  have arithmetic := native_arithmetic threads thread iteration width lane active
  simp only [step,selected_bindings,selected_limit,arithmetic.1,and_self,ite_true,invoke_correct]
  rw [show (thread+threads*iteration+threads)%2^32=thread+threads*(iteration+1) from arithmetic.2.2]
  rfl

def expansion (base threads thread : Nat) : Nat → Nat → List Memory.Store
  | 0,_ => []
  | remaining+1,iteration => CodebookInitialization.entry base threads thread iteration::
      expansion base threads thread remaining (iteration+1)

theorem expansion_runs (base threads thread remaining iteration : Nat)
    (width : threads=256 ∨ threads=1024) (lane : thread<threads)
    (finish : iteration+remaining=4096/threads) :
    Runs loop base threads (thread+threads*iteration) (expansion base threads thread remaining iteration) := by
  induction remaining generalizing iteration with
  | zero =>
    apply Runs.stop
    rw [selected_limit]
    rcases width with rfl | rfl <;> omega
  | succ remaining ih =>
    exact Runs.next (step_entry base threads thread iteration width lane (by omega))
      (ih (iteration+1) (by omega))

theorem expansion_list (base threads thread remaining iteration : Nat) :
    expansion base threads thread remaining iteration=
      (List.range' iteration remaining).map (CodebookInitialization.entry base threads thread) := by
  induction remaining generalizing iteration with
  | zero => rfl
  | succ remaining ih =>
    simp only [expansion,List.range'_succ,List.map_cons]
    rw [ih (iteration+1)]

theorem source_program (base threads thread : Nat) (width : threads=256 ∨ threads=1024) (lane : thread<threads) :
    Runs loop base threads thread
      ((List.range (4096/threads)).map (CodebookInitialization.entry base threads thread)) := by
  have source := expansion_runs base threads thread (4096/threads) 0 width lane (by omega)
  rw [expansion_list,List.range'_eq_map_range,List.map_map] at source
  simpa only [Nat.mul_zero,Nat.add_zero,Nat.zero_add,Function.comp_def] using source

-- Every original table thread program now has a source execution. No final
-- table entry, numerical result or caller-supplied helper result is assumed.
theorem step_none_of_finished (code : Loop) (base threads counter : Nat) (finished : limit code≤counter) :
    step code base threads counter=none := by
  unfold step
  rw [ite_eq_right (by omega)]

theorem runs_unique {code : Loop} {base threads counter : Nat} {left right : List Memory.Store}
    (first : Runs code base threads counter left) (second : Runs code base threads counter right) : left=right := by
  induction first generalizing right with
  | stop counter bound =>
    cases second with
    | stop => rfl
    | next issued rest => rw [step_none_of_finished code base threads counter bound] at issued; contradiction
  | @next counter after store tail issued rest ih =>
    cases second with
    | stop _ bound => rw [step_none_of_finished code base threads counter bound] at issued; contradiction
    | @next _ after' store' tail' issued' rest' =>
      have same := Option.some.inj (issued.symm.trans issued')
      cases same
      exact congrArg (store::·) (ih rest')

theorem parsed_program (actual : Loop) (parsed : parse sourceLoop=some actual)
    (base threads thread : Nat) (width : threads=256 ∨ threads=1024) (lane : thread<threads)
    (program : List Memory.Store) (execution : Runs actual base threads thread program) :
    program=(List.range (4096/threads)).map (CodebookInitialization.entry base threads thread) := by
  have same := Option.some.inj (parsed.symm.trans parsed_loop)
  subst actual
  exact runs_unique execution (source_program base threads thread width lane)

theorem programs_from_source (base threads : Nat) (width : threads=256 ∨ threads=1024) :
    ∀ thread, thread<threads → ∃ program,
      program ∈ CodebookBarrier.programs base threads ∧ Runs loop base threads thread program := by
  intro thread lane
  exact ⟨_,List.mem_map.mpr ⟨thread,List.mem_range.mpr lane,rfl⟩,source_program base threads thread width lane⟩

theorem owners (threads index : Nat) (width : threads=256 ∨ threads=1024) (valid : index<4096) :
    index%threads<threads ∧ index/threads<4096/threads ∧ index%threads+threads*(index/threads)=index :=
  CodebookLoad.initialization_owners index threads valid width

theorem unique_owner (base threads t₁ t₂ i₁ i₂ : Nat) (width : threads=256 ∨ threads=1024)
    (lane₁ : t₁<threads) (lane₂ : t₂<threads)
    (same : (CodebookInitialization.entry base threads t₁ i₁).word=
      (CodebookInitialization.entry base threads t₂ i₂).word) : t₁=t₂ ∧ i₁=i₂ :=
  CodebookInitialization.address_injective base threads t₁ t₂ i₁ i₂ width lane₁ lane₂ same

structure Completed (base threads : Nat) where
  schedule : List Memory.Store
  remaining : List (List Memory.Store)
  execution : ThreadgroupWrites.Executes (CodebookBarrier.programs base threads) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

def canonical (base threads : Nat) : Completed base threads :=
  ⟨(CodebookBarrier.programs base threads).flatten,
    List.replicate (CodebookBarrier.programs base threads).length [],
    ThreadgroupWrites.canonical _,ThreadgroupWrites.canonical_barrier _⟩

theorem initialized (before : WordMemory) (base threads : Nat) (width : threads=256 ∨ threads=1024)
    (completed : Completed base threads) :
    CodebookLoad.Initialized (Memory.execute completed.schedule before) base :=
  CodebookBarrier.initialized before base threads width completed.schedule completed.remaining
    completed.execution completed.barrier

theorem frame (before : WordMemory) (base threads word : Nat) (width : threads=256 ∨ threads=1024)
    (completed : Completed base threads) (outside : word<base/4 ∨ base/4+4096≤word) :
    Memory.execute completed.schedule before word=before word :=
  CodebookBarrier.frame before base threads word width completed.schedule completed.remaining
    completed.execution completed.barrier outside

-- Gate/up stages uint4 activation words after this float table loop. This
-- theorem attaches the parsed RHS to its existing raw-word table stores; the
-- independently proved GateUpBarrier handles those disjoint activation writes.
theorem gate_raw_entry (base thread iteration : Nat) :
    (invoke loop.outerFunction loop.innerFunction (BitVec.ofNat 32 (thread+1024*iteration))).map
      (fun value => (value.toBits.toBitVec))=
      some (GateUpBarrier.codeEntry base thread iteration).value := by
  rw [invoke_correct]
  rfl
-- This interface accepts actual parsed-loop executions and a completed finite
-- scheduler. The old manually translated program list is DERIVED by uniqueness.
structure ParsedCompleted (base threads : Nat) where
  code : Loop
  parsed : parse sourceLoop=some code
  threadProgram : Nat → List Memory.Store
  source : ∀ thread, thread<threads → Runs code base threads thread (threadProgram thread)
  schedule : List Memory.Store
  remaining : List (List Memory.Store)
  execution : ThreadgroupWrites.Executes ((List.range threads).map threadProgram) schedule remaining
  barrier : ThreadgroupWrites.AtBarrier remaining

theorem parsed_programs_eq (base threads : Nat) (width : threads=256 ∨ threads=1024)
    (completed : ParsedCompleted base threads) :
    (List.range threads).map completed.threadProgram=CodebookBarrier.programs base threads := by
  apply List.map_congr_left
  intro thread member
  exact parsed_program completed.code completed.parsed base threads thread width (List.mem_range.mp member)
    _ (completed.source thread (List.mem_range.mp member))

def parsedCanonical (base threads : Nat) (width : threads=256 ∨ threads=1024) : ParsedCompleted base threads where
  code := loop
  parsed := parsed_loop
  threadProgram := fun thread => (List.range (4096/threads)).map (CodebookInitialization.entry base threads thread)
  source := fun thread lane => source_program base threads thread width lane
  schedule := (CodebookBarrier.programs base threads).flatten
  remaining := List.replicate (CodebookBarrier.programs base threads).length []
  execution := ThreadgroupWrites.canonical _
  barrier := ThreadgroupWrites.canonical_barrier _

theorem parsed_initialized (before : WordMemory) (base threads : Nat) (width : threads=256 ∨ threads=1024)
    (completed : ParsedCompleted base threads) :
    CodebookLoad.Initialized (Memory.execute completed.schedule before) base := by
  have execution := completed.execution
  rw [parsed_programs_eq base threads width completed] at execution
  exact CodebookBarrier.initialized before base threads width completed.schedule completed.remaining execution completed.barrier

theorem parsed_frame (before : WordMemory) (base threads word : Nat) (width : threads=256 ∨ threads=1024)
    (completed : ParsedCompleted base threads) (outside : word<base/4 ∨ base/4+4096≤word) :
    Memory.execute completed.schedule before word=before word := by
  have execution := completed.execution
  rw [parsed_programs_eq base threads width completed] at execution
  exact CodebookBarrier.frame before base threads word width completed.schedule completed.remaining execution completed.barrier outside

theorem physical_address (base index : Nat) (aligned : base%4=0) :
    4*(base/4+index)=base+4*index := by omega

theorem parsed_read (load : ThreadgroupLoad) (hardware : LoadContract load)
    (before : WordMemory) (base threads : Nat) (width : threads=256 ∨ threads=1024)
    (completed : ParsedCompleted base threads) (aligned : base%4=0) (bounded : base+16384≤2^64)
    (words : Nat → BitVec 32) (offset : Nat) :
    CodebookLoad.read load (Memory.execute completed.schedule before) base words offset=
      CodebookLoad.mathematicalCode (Codebook.CodebookWindow.byteOffset words offset >>> 2) :=
  CodebookLoad.read_correct load hardware _ base aligned bounded
    (parsed_initialized before base threads width completed) words offset

theorem parsed_entry_finite (before : WordMemory) (base threads index : Nat)
    (width : threads=256 ∨ threads=1024) (completed : ParsedCompleted base threads) (valid : index<4096) :
    ((Memory.execute completed.schedule before) (base/4+index)).isFinite=true := by
  rw [parsed_initialized before base threads width completed index valid,CodebookLoad.codeValue_correct]
  exact CodebookBitsSemantics.finite _ (by rw [←Codebook.correct]; exact Codebook.range _)

end Inference.Kernels.Trellis.CodebookTableSource
