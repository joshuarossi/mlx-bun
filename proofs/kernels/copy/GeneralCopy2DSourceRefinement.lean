import kernels.copy.GeneralCopy2DInterleaving

namespace Inference.Kernels.Copy.GeneralCopy2DSourceRefinement
open Contracts.Mlx GeneralCopy2DSyntax GeneralCopy2DSemantics
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

-- Complete body execution with fresh per-invocation local environments.
-- The list order is arbitrary; a launch must contain each grid label once.
inductive Bodies (layout : Copy2D.Layout) (code : List Stmt) :
    List Label → ByteMemory.Bytes → ByteMemory.Bytes → Prop where
  | nil (memory) : Bodies layout code [] memory memory
  | cons (executed : execute layout thread code ⟨environment,before⟩=some output)
      (rest : Bodies layout code threads output.memory after) :
      Bodies layout code (thread::threads) before after

def run (layout : Copy2D.Layout) : List Label → ByteMemory.Bytes → ByteMemory.Bytes
  | [], before => before
  | thread::threads, before => run layout threads (afterBody layout thread ⟨fun _ => 0,before⟩).memory

theorem run_bodies (bounds : Bounds layout) (threads : List Label) (before : ByteMemory.Bytes) :
    Bodies layout body threads before (run layout threads before) := by
  induction threads generalizing before with
  | nil => exact .nil _
  | cons thread threads ih => exact .cons (body_execution bounds thread _) (ih _)

theorem bodies_eq (bounds : Bounds layout) (execution : Bodies layout body threads before after) :
    after=run layout threads before := by
  induction execution with
  | nil => rfl
  | @cons thread environment before output threads after executed rest ih =>
    have equal := Option.some.inj ((body_execution bounds thread ⟨environment,before⟩).symm.trans executed)
    cases equal
    exact ih

theorem thread_memory (bounds : Bounds layout) (thread : Label) (state : GeneralCopy2DInterleaving.Machine) :
    (GeneralCopy2DInterleaving.finishThread layout state thread).memory=
      (afterBody layout thread ⟨fun _ => 0,state.memory⟩).memory := by
  simp only [GeneralCopy2DInterleaving.finishThread,afterBody,
    destination_word_address bounds,source_word_address bounds]

theorem drain_memory (bounds : Bounds layout) (threads : List Label) (state : GeneralCopy2DInterleaving.Machine) :
    (GeneralCopy2DInterleaving.drain layout threads state).memory=run layout threads state.memory := by
  induction threads generalizing state with
  | nil => rfl
  | cons thread threads ih =>
    rw [GeneralCopy2DInterleaving.drain,ih,thread_memory bounds,run]

structure Launch (layout : Copy2D.Layout) (before after : ByteMemory.Bytes) where
  order : List Label
  permutation : order.Perm (Copy2D.labels 4 256)
  execution : Bodies layout body order before after

def canonicalLaunch (bounds : Bounds layout) (before : ByteMemory.Bytes) :
    Launch layout before (run layout (Copy2D.labels 4 256) before) :=
  ⟨Copy2D.labels 4 256,List.Perm.refl _,run_bodies bounds _ before⟩

theorem launch_eq (bounds : Bounds layout) (separate : GeneralCopy2DInterleaving.Separate layout)
    (trace : Copy2DMemory.Trace layout 4 256) (launch : Launch layout trace.before after) :
    after=trace.memory := by
  have distinct := launch.permutation.nodup_iff.mpr
    ((List.nodup_finRange 4).product (List.nodup_finRange 256))
  have execution := GeneralCopy2DInterleaving.drain_exec (layout:=layout) launch.order
    (GeneralCopy2DInterleaving.initial trace.before) distinct (by intros; rfl)
  have completed : GeneralCopy2DInterleaving.Completed
      (GeneralCopy2DInterleaving.drain layout launch.order (GeneralCopy2DInterleaving.initial trace.before)) := by
    intro thread
    rw [GeneralCopy2DInterleaving.drain_phase]
    apply ite_eq_left
    exact launch.permutation.mem_iff.mpr (List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩)
  exact (bodies_eq bounds launch.execution).trans
    ((drain_memory bounds launch.order (GeneralCopy2DInterleaving.initial trace.before)).symm.trans
      (GeneralCopy2DInterleaving.trace_eq bounds separate trace execution completed))

theorem parsed_bodies (bounds : Bounds layout) (before : ByteMemory.Bytes) :
    ∃ code, parseBody sourceBody=some code ∧
      Bodies layout code (Copy2D.labels 4 256) before (run layout (Copy2D.labels 4 256) before) :=
  ⟨body,parsed_body,run_bodies bounds _ before⟩

-- An isolated parsed body and its two event actions agree on the exact heap.
-- This is not an assumption that a device load/store pair runs atomically.
theorem parsed_thread_events (bounds : Bounds layout) (thread : Label)
    (state : GeneralCopy2DInterleaving.Machine) (ready : state.phase thread=.unread) :
    ((parseBody sourceBody).bind (fun code => execute layout thread code ⟨fun _ => 0,state.memory⟩))=
      some (afterBody layout thread ⟨fun _ => 0,state.memory⟩) ∧
    GeneralCopy2DInterleaving.Executes layout state (GeneralCopy2DInterleaving.threadEvents thread)
      (GeneralCopy2DInterleaving.finishThread layout state thread) ∧
    (GeneralCopy2DInterleaving.finishThread layout state thread).memory=
      (afterBody layout thread ⟨fun _ => 0,state.memory⟩).memory :=
  ⟨parsed_execution bounds thread _,GeneralCopy2DInterleaving.finishThread_exec thread state ready,
    thread_memory bounds thread state⟩

theorem body_events_eq (bounds : Bounds layout) (before : ByteMemory.Bytes) :
    run layout (Copy2D.labels 4 256) before=(GeneralCopy2DInterleaving.canonicalAfter layout before).memory :=
  (drain_memory bounds _ (GeneralCopy2DInterleaving.initial before)).symm

structure Checked (layout : Copy2D.Layout) (before : ByteMemory.Bytes) where
  bodyAfter : ByteMemory.Bytes
  bodyLaunch : Launch layout before bodyAfter
  events : List GeneralCopy2DInterleaving.Event
  eventAfter : GeneralCopy2DInterleaving.Machine
  eventExecution : GeneralCopy2DInterleaving.Executes layout (GeneralCopy2DInterleaving.initial before) events eventAfter
  completed : GeneralCopy2DInterleaving.Completed eventAfter
  agreement : bodyAfter=eventAfter.memory

def canonical (bounds : Bounds layout) (before : ByteMemory.Bytes) : Checked layout before where
  bodyAfter := run layout (Copy2D.labels 4 256) before
  bodyLaunch := canonicalLaunch bounds before
  events := (Copy2D.labels 4 256).flatMap GeneralCopy2DInterleaving.threadEvents
  eventAfter := GeneralCopy2DInterleaving.canonicalAfter layout before
  eventExecution := GeneralCopy2DInterleaving.canonical_execution layout before
  completed := GeneralCopy2DInterleaving.canonical_completed layout before
  agreement := body_events_eq bounds before

theorem checked_eq (bounds : Bounds layout) (separate : GeneralCopy2DInterleaving.Separate layout)
    (trace : Copy2DMemory.Trace layout 4 256) (checked : Checked layout trace.before) :
    checked.bodyAfter=trace.memory ∧ checked.eventAfter.memory=trace.memory :=
  ⟨launch_eq bounds separate trace checked.bodyLaunch,
    GeneralCopy2DInterleaving.trace_eq bounds separate trace checked.eventExecution checked.completed⟩

def from_events (bounds : Bounds layout) (separate : GeneralCopy2DInterleaving.Separate layout)
    (before : ByteMemory.Bytes)
    (execution : GeneralCopy2DInterleaving.Executes layout (GeneralCopy2DInterleaving.initial before) events after)
    (completed : GeneralCopy2DInterleaving.Completed after) : Checked layout before := by
  let trace : Copy2DMemory.Trace layout 4 256 := CopyExecution.Trace.canonical _ before
  exact ⟨run layout (Copy2D.labels 4 256) before,canonicalLaunch bounds before,events,after,execution,completed,
    (launch_eq bounds separate trace (canonicalLaunch bounds before)).trans
      (GeneralCopy2DInterleaving.trace_eq bounds separate trace execution completed).symm⟩

end Inference.Kernels.Copy.GeneralCopy2DSourceRefinement
