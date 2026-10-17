import kernels.copy.GeneralCopy2DWideSemantics

namespace Inference.Kernels.Copy.GeneralCopy2DWideInterleaving
open Contracts.Mlx GeneralCopy2DWideSemantics
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange
variable {width : Nat}

-- Each invocation has one current-memory load followed by one store. Other
-- invocations may run between them. Coherent aligned word actions, host
-- argument binding, dispatch completion and compiler lowering are external.
inductive Phase where
  | unread
  | loaded : BitVec 16 → Phase
  | done
  deriving DecidableEq

structure Machine (width : Nat) where
  phase : (Label 4 width) → Phase
  memory : HalfMemory.Bytes

def update (state : (Machine width)) (thread : (Label 4 width)) (phase : Phase) : (Label 4 width) → Phase :=
  fun other => if other=thread then phase else state.phase other

inductive Event (width : Nat) where
  | load : (Label 4 width) → (Event width)
  | store : (Label 4 width) → (Event width)
  deriving DecidableEq

inductive Step (width : Nat) (layout : Copy2D.Layout) : (Machine width) → (Event width) → (Machine width) → Prop where
  | load (ready : before.phase thread=.unread) :
      Step width layout before (.load thread)
        ⟨update before thread (.loaded (HalfMemory.load before.memory (2*(Copy2DMemory.operation layout thread).source))),before.memory⟩
  | store (ready : before.phase thread=.loaded value) :
      Step width layout before (.store thread)
        ⟨update before thread .done,HalfMemory.store before.memory (2*(Copy2DMemory.operation layout thread).destination) value⟩

inductive Executes (width : Nat) (layout : Copy2D.Layout) : (Machine width) → List (Event width) → (Machine width) → Prop where
  | nil (state) : Executes width layout state [] state
  | cons : Step (width:=width) layout before action middle →
      Executes width layout middle events after → Executes width layout before (action::events) after

def initial (memory : HalfMemory.Bytes) : (Machine width) := ⟨fun _ => .unread,memory⟩
def Completed (state : (Machine width)) : Prop := ∀ thread, state.phase thread=.done
def Separate (layout : Copy2D.Layout) : Prop := ∀ reader writer : (Label 4 width),
  (Copy2DMemory.operation layout reader).source≠(Copy2DMemory.operation layout writer).destination

theorem no_alias (separate : Separate (width:=width) layout) :
    CopyExecution.NoAlias (Copy2DMemory.programs layout 4 width).flatten :=
  Copy2DMemory.no_alias layout separate

theorem destination_unique (bounds : Bounds layout 4 width) (a b : (Label 4 width))
    (same : (Copy2DMemory.operation layout a).destination=(Copy2DMemory.operation layout b).destination) : a=b :=
  Copy2D.destination_unique layout.destinationRow bounds.rowRoom a b (Nat.add_left_cancel same)

theorem load_store (memory : HalfMemory.Bytes) (address : Nat) (value : BitVec 16) :
    HalfMemory.load (HalfMemory.store memory address value) address=value := by
  simp only [HalfMemory.load,HalfMemory.store,
    ite_eq_left (show address≤address+1 ∧ address+1<address+2 by omega),
    ite_eq_left (show address≤address+0 ∧ address+0<address+2 by omega),Nat.add_sub_cancel_left]
  exact HalfMemory.join_bytes value

structure Invariant (layout : Copy2D.Layout) (before : HalfMemory.Bytes) (state : (Machine width)) : Prop where
  registers : ∀ thread value, state.phase thread=.loaded value →
    value=HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source)
  stored : ∀ thread, state.phase thread=.done →
    HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).destination)=
      HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source)
  frame : ∀ word, (∀ thread : (Label 4 width), (Copy2DMemory.operation layout thread).destination≠word) →
    HalfMemory.load state.memory (2*word)=HalfMemory.load before (2*word)

theorem initial_invariant (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Invariant (width:=width) layout memory (initial (width:=width) memory) where
  registers := by intro thread value impossible; cases impossible
  stored := by intro thread impossible; cases impossible
  frame := by intros; rfl

theorem Invariant.source_read (separate : Separate (width:=width) layout)
    (invariant : Invariant (width:=width) layout before state) (thread : (Label 4 width)) :
    HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source)=
      HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source) :=
  invariant.frame _ (fun writer => Ne.symm (separate thread writer))

theorem step_invariant (bounds : Bounds layout 4 width) (separate : Separate (width:=width) layout)
    (invariant : Invariant (width:=width) layout before state) (step : Step (width:=width) layout state action after) :
    Invariant (width:=width) layout before after := by
  cases step with
  | @load thread ready =>
    refine ⟨?_,?_,invariant.frame⟩
    · intro other value loaded
      by_cases same : other=thread
      · subst other
        have equal := Phase.loaded.inj (show Phase.loaded (HalfMemory.load state.memory
          (2*(Copy2DMemory.operation layout thread).source))=.loaded value by
            simpa only [update,ite_true] using loaded)
        exact equal.symm.trans (invariant.source_read separate thread)
      · exact invariant.registers other value (by simpa only [update,ite_eq_right same] using loaded)
    · intro other done
      by_cases same : other=thread
      · subst other; simp only [update,ite_true] at done; cases done
      · exact invariant.stored other (by simpa only [update,ite_eq_right same] using done)
  | @store thread value ready =>
    refine ⟨?_,?_,?_⟩
    · intro other loadedValue loaded
      by_cases same : other=thread
      · subst other; simp only [update,ite_true] at loaded; cases loaded
      · exact invariant.registers other loadedValue (by simpa only [update,ite_eq_right same] using loaded)
    · intro other done
      by_cases same : other=thread
      · subst other
        exact (load_store state.memory _ value).trans (invariant.registers thread value ready)
      · have different : (Copy2DMemory.operation layout other).destination≠
            (Copy2DMemory.operation layout thread).destination := fun equal =>
          same (destination_unique bounds other thread equal)
        exact (CopyExecution.load_store_other state.memory _ _ value different).trans
          (invariant.stored other (by simpa only [update,ite_eq_right same] using done))
    · intro word outside
      exact (CopyExecution.load_store_other state.memory _ _ value (Ne.symm (outside thread))).trans
        (invariant.frame word outside)

theorem executes_invariant (bounds : Bounds layout 4 width) (separate : Separate (width:=width) layout)
    (execution : Executes (width:=width) layout state events after)
    (invariant : Invariant (width:=width) layout before state) : Invariant (width:=width) layout before after := by
  induction execution with
  | nil => exact invariant
  | cons step rest ih => exact ih (step_invariant bounds separate invariant step)

theorem trace_eq (bounds : Bounds layout 4 width) (separate : Separate (width:=width) layout)
    (trace : Copy2DMemory.Trace layout 4 width)
    (execution : Executes (width:=width) layout (initial (width:=width) trace.before) events after) (completed : Completed after) :
    after.memory=trace.memory := by
  have invariant := executes_invariant bounds separate execution (initial_invariant layout trace.before)
  have words : HalfMemory.view after.memory=HalfMemory.view trace.memory := by
    funext word
    change HalfMemory.load after.memory (2*word)=HalfMemory.load trace.memory (2*word)
    by_cases inside : ∃ thread : (Label 4 width), (Copy2DMemory.operation layout thread).destination=word
    · obtain ⟨thread,rfl⟩ := inside
      have stored := invariant.stored thread (completed thread)
      have copied := Copy2DMemory.read_correct layout bounds.sourceAligned bounds.destinationAligned
        bounds.rowRoom trace (no_alias separate) thread
      rw [destination_word_address bounds thread,source_word_address bounds thread] at stored
      rw [destination_word_address bounds thread]
      exact stored.trans copied.symm
    · have outside : ∀ thread : (Label 4 width), (Copy2DMemory.operation layout thread).destination≠word :=
        fun thread same => inside ⟨thread,same⟩
      rw [Copy2DMemory.memory_equal layout bounds.sourceAligned bounds.destinationAligned bounds.rowRoom trace (no_alias separate)]
      exact (invariant.frame word outside).trans
        ((Copy2DMemory.toCopy layout bounds.sourceAligned bounds.destinationAligned bounds.rowRoom trace).frame word outside).symm
  calc
    after.memory=HalfMemory.encode (HalfMemory.view after.memory) := (HalfMemory.encode_view _).symm
    _=HalfMemory.encode (HalfMemory.view trace.memory) := congrArg HalfMemory.encode words
    _=trace.memory := HalfMemory.encode_view _

theorem Executes.append {first second : List (Event width)}
    (left : Executes (width:=width) layout start first middle) (right : Executes (width:=width) layout middle second finish) :
    Executes (width:=width) layout start (first++second) finish := by
  induction left with
  | nil => exact right
  | cons step tail ih => exact .cons step (ih right)

def loadThread (layout : Copy2D.Layout) (state : (Machine width)) (thread : (Label 4 width)) : (Machine width) :=
  ⟨update state thread (.loaded (HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source))),state.memory⟩

def finishThread (layout : Copy2D.Layout) (state : (Machine width)) (thread : (Label 4 width)) : (Machine width) :=
  let loaded := loadThread layout state thread
  ⟨update loaded thread .done,HalfMemory.store state.memory (2*(Copy2DMemory.operation layout thread).destination)
    (HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source))⟩

def threadEvents (thread : (Label 4 width)) : List (Event width) := [.load thread,.store thread]

theorem finishThread_phase (thread other : (Label 4 width)) (state : (Machine width)) :
    (finishThread layout state thread).phase other=if other=thread then .done else state.phase other := by
  by_cases same : other=thread <;> simp [finishThread,loadThread,update,same]

theorem finishThread_exec (thread : (Label 4 width)) (state : (Machine width)) (ready : state.phase thread=.unread) :
    Executes (width:=width) layout state (threadEvents thread) (finishThread layout state thread) :=
  .cons (.load ready) (.cons (.store (by simp [update])) (.nil _))

def drain (layout : Copy2D.Layout) : List (Label 4 width) → (Machine width) → (Machine width)
  | [], state => state
  | thread::rest, state => drain layout rest (finishThread layout state thread)

theorem drain_phase (threads : List (Label 4 width)) (state : (Machine width)) (thread : (Label 4 width)) :
    (drain layout threads state).phase thread=if thread∈threads then .done else state.phase thread := by
  induction threads generalizing state with
  | nil => simp [drain]
  | cons first rest ih =>
    rw [drain,ih,finishThread_phase]
    by_cases inRest : thread∈rest <;> by_cases same : thread=first <;> simp [inRest,same]

theorem drain_exec (threads : List (Label 4 width)) (state : (Machine width)) (distinct : threads.Nodup)
    (ready : ∀ thread∈threads, state.phase thread=.unread) :
    Executes (width:=width) layout state (threads.flatMap threadEvents) (drain layout threads state) := by
  induction threads generalizing state with
  | nil => exact .nil _
  | cons first rest ih =>
    have firstAbsent := (List.nodup_cons.mp distinct).1
    exact (finishThread_exec first state (ready first List.mem_cons_self)).append
      (ih _ (List.nodup_cons.mp distinct).2 (by
        intro thread present
        rw [finishThread_phase,ite_eq_right (show thread≠first by intro same; subst thread; exact firstAbsent present)]
        exact ready thread (List.mem_cons_of_mem _ present)))

def canonicalAfter (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) : (Machine width) :=
  drain layout (Copy2D.labels 4 width) (initial (width:=width) memory)

theorem canonical_execution (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Executes (width:=width) layout (initial (width:=width) memory) ((Copy2D.labels 4 width).flatMap threadEvents) (canonicalAfter layout memory) :=
  drain_exec _ _ ((List.nodup_finRange 4).product (List.nodup_finRange width)) (by intros; rfl)

theorem canonical_completed (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Completed (width:=width) (canonicalAfter (width:=width) layout memory) := by
  intro thread
  unfold canonicalAfter
  rw [drain_phase,ite_eq_left (show thread∈Copy2D.labels 4 width from
    List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩)]

theorem canonical_refines (bounds : Bounds layout 4 width) (separate : Separate (width:=width) layout) (trace : Copy2DMemory.Trace layout 4 width) :
    (canonicalAfter (width:=width) layout trace.before).memory=trace.memory :=
  trace_eq bounds separate trace (canonical_execution layout trace.before) (canonical_completed layout trace.before)

end Inference.Kernels.Copy.GeneralCopy2DWideInterleaving
