import kernels.copy.GeneralCopy2DWideInterleaving

namespace Inference.Kernels.Copy.GeneralCopy2DWideSourceRefinement
open Contracts.Mlx GeneralCopy2DSyntax GeneralCopy2DWideSemantics
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange
variable {width : Nat}

-- Complete body execution with fresh per-invocation local environments.
-- The list order is arbitrary; a launch must contain each grid label once.
inductive Bodies (width : Nat) (layout : Copy2D.Layout) (code : List Stmt) :
    List (Label 4 width) → ByteMemory.Bytes → ByteMemory.Bytes → Prop where
  | nil (memory) : Bodies width layout code [] memory memory
  | cons (executed : execute layout thread code ⟨environment,before⟩=some output)
      (rest : Bodies width layout code threads output.memory after) :
      Bodies width layout code (thread::threads) before after

def run (layout : Copy2D.Layout) : List (Label 4 width) → ByteMemory.Bytes → ByteMemory.Bytes
  | [], before => before
  | thread::threads, before => run layout threads (afterBody layout thread ⟨fun _ => 0,before⟩).memory

theorem run_bodies (bounds : Bounds layout 4 width) (threads : List (Label 4 width)) (before : ByteMemory.Bytes) :
    Bodies (width:=width) layout body threads before (run layout threads before) := by
  induction threads generalizing before with
  | nil => exact .nil _
  | cons thread threads ih => exact .cons (body_execution bounds thread _) (ih _)

theorem bodies_eq (bounds : Bounds layout 4 width) (execution : Bodies (width:=width) layout body threads before after) :
    after=run layout threads before := by
  induction execution with
  | nil => rfl
  | @cons thread environment before output threads after executed rest ih =>
    have equal := Option.some.inj ((body_execution bounds thread ⟨environment,before⟩).symm.trans executed)
    cases equal
    exact ih

theorem thread_memory (bounds : Bounds layout 4 width) (thread : (Label 4 width)) (state : (GeneralCopy2DWideInterleaving.Machine width)) :
    (GeneralCopy2DWideInterleaving.finishThread layout state thread).memory=
      (afterBody layout thread ⟨fun _ => 0,state.memory⟩).memory := by
  simp only [GeneralCopy2DWideInterleaving.finishThread,afterBody,
    destination_word_address bounds,source_word_address bounds]

theorem drain_memory (bounds : Bounds layout 4 width) (threads : List (Label 4 width)) (state : (GeneralCopy2DWideInterleaving.Machine width)) :
    (GeneralCopy2DWideInterleaving.drain layout threads state).memory=run layout threads state.memory := by
  induction threads generalizing state with
  | nil => rfl
  | cons thread threads ih =>
    rw [GeneralCopy2DWideInterleaving.drain,ih,thread_memory bounds,run]

structure Launch (layout : Copy2D.Layout) (before after : ByteMemory.Bytes) where
  order : List (Label 4 width)
  permutation : order.Perm (Copy2D.labels 4 width)
  execution : Bodies (width:=width) layout body order before after

def canonicalLaunch (bounds : Bounds layout 4 width) (before : ByteMemory.Bytes) :
    Launch (width:=width) layout before (run layout (Copy2D.labels 4 width) before) :=
  ⟨Copy2D.labels 4 width,List.Perm.refl _,run_bodies bounds _ before⟩

theorem launch_eq (bounds : Bounds layout 4 width) (separate : GeneralCopy2DWideInterleaving.Separate (width:=width) layout)
    (trace : Copy2DMemory.Trace layout 4 width) (launch : Launch (width:=width) layout trace.before after) :
    after=trace.memory := by
  have distinct := launch.permutation.nodup_iff.mpr
    ((List.nodup_finRange 4).product (List.nodup_finRange width))
  have execution := GeneralCopy2DWideInterleaving.drain_exec (layout:=layout) launch.order
    (GeneralCopy2DWideInterleaving.initial (width:=width) trace.before) distinct (by intros; rfl)
  have completed : GeneralCopy2DWideInterleaving.Completed
      (GeneralCopy2DWideInterleaving.drain layout launch.order (GeneralCopy2DWideInterleaving.initial (width:=width) trace.before)) := by
    intro thread
    rw [GeneralCopy2DWideInterleaving.drain_phase]
    apply ite_eq_left
    exact launch.permutation.mem_iff.mpr (List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩)
  exact (bodies_eq bounds launch.execution).trans
    ((drain_memory bounds launch.order (GeneralCopy2DWideInterleaving.initial (width:=width) trace.before)).symm.trans
      (GeneralCopy2DWideInterleaving.trace_eq bounds separate trace execution completed))

theorem parsed_bodies (bounds : Bounds layout 4 width) (before : ByteMemory.Bytes) :
    ∃ code, parseBody sourceBody=some code ∧
      Bodies (width:=width) layout code (Copy2D.labels 4 width) before (run layout (Copy2D.labels 4 width) before) :=
  ⟨body,parsed_body,run_bodies bounds _ before⟩

-- An isolated parsed body and its two event actions agree on the exact heap.
-- This is not an assumption that a device load/store pair runs atomically.
theorem parsed_thread_events (bounds : Bounds layout 4 width) (thread : (Label 4 width))
    (state : (GeneralCopy2DWideInterleaving.Machine width)) (ready : state.phase thread=.unread) :
    ((parseBody sourceBody).bind (fun code => execute layout thread code ⟨fun _ => 0,state.memory⟩))=
      some (afterBody layout thread ⟨fun _ => 0,state.memory⟩) ∧
    GeneralCopy2DWideInterleaving.Executes (width:=width) layout state (GeneralCopy2DWideInterleaving.threadEvents thread)
      (GeneralCopy2DWideInterleaving.finishThread layout state thread) ∧
    (GeneralCopy2DWideInterleaving.finishThread layout state thread).memory=
      (afterBody layout thread ⟨fun _ => 0,state.memory⟩).memory :=
  ⟨parsed_execution bounds thread _,GeneralCopy2DWideInterleaving.finishThread_exec thread state ready,
    thread_memory bounds thread state⟩

theorem body_events_eq (bounds : Bounds layout 4 width) (before : ByteMemory.Bytes) :
    run layout (Copy2D.labels 4 width) before=(GeneralCopy2DWideInterleaving.canonicalAfter (width:=width) layout before).memory :=
  (drain_memory bounds _ (GeneralCopy2DWideInterleaving.initial (width:=width) before)).symm

structure Checked (layout : Copy2D.Layout) (before : ByteMemory.Bytes) where
  bodyAfter : ByteMemory.Bytes
  bodyLaunch : Launch (width:=width) layout before bodyAfter
  events : List (GeneralCopy2DWideInterleaving.Event width)
  eventAfter : (GeneralCopy2DWideInterleaving.Machine width)
  eventExecution : GeneralCopy2DWideInterleaving.Executes (width:=width) layout (GeneralCopy2DWideInterleaving.initial (width:=width) before) events eventAfter
  completed : GeneralCopy2DWideInterleaving.Completed eventAfter
  agreement : bodyAfter=eventAfter.memory

def canonical (bounds : Bounds layout 4 width) (before : ByteMemory.Bytes) : Checked (width:=width) layout before where
  bodyAfter := run layout (Copy2D.labels 4 width) before
  bodyLaunch := canonicalLaunch bounds before
  events := (Copy2D.labels 4 width).flatMap GeneralCopy2DWideInterleaving.threadEvents
  eventAfter := GeneralCopy2DWideInterleaving.canonicalAfter (width:=width) layout before
  eventExecution := GeneralCopy2DWideInterleaving.canonical_execution layout before
  completed := GeneralCopy2DWideInterleaving.canonical_completed layout before
  agreement := body_events_eq bounds before

theorem checked_eq (bounds : Bounds layout 4 width) (separate : GeneralCopy2DWideInterleaving.Separate (width:=width) layout)
    (trace : Copy2DMemory.Trace layout 4 width) (checked : Checked (width:=width) layout trace.before) :
    checked.bodyAfter=trace.memory ∧ checked.eventAfter.memory=trace.memory :=
  ⟨launch_eq bounds separate trace checked.bodyLaunch,
    GeneralCopy2DWideInterleaving.trace_eq bounds separate trace checked.eventExecution checked.completed⟩

def from_events (bounds : Bounds layout 4 width) (separate : GeneralCopy2DWideInterleaving.Separate (width:=width) layout)
    (before : ByteMemory.Bytes)
    (execution : GeneralCopy2DWideInterleaving.Executes (width:=width) layout (GeneralCopy2DWideInterleaving.initial (width:=width) before) events after)
    (completed : GeneralCopy2DWideInterleaving.Completed after) : Checked (width:=width) layout before := by
  let trace : Copy2DMemory.Trace layout 4 width := CopyExecution.Trace.canonical _ before
  exact ⟨run layout (Copy2D.labels 4 width) before,canonicalLaunch bounds before,events,after,execution,completed,
    (launch_eq bounds separate trace (canonicalLaunch bounds before)).trans
      (GeneralCopy2DWideInterleaving.trace_eq bounds separate trace execution completed).symm⟩

end Inference.Kernels.Copy.GeneralCopy2DWideSourceRefinement
