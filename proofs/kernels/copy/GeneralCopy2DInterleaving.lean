import kernels.copy.GeneralCopy2DSemantics

namespace Inference.Kernels.Copy.GeneralCopy2DInterleaving
open Contracts.Mlx GeneralCopy2DSemantics
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

-- Each invocation has one current-memory load followed by one store. Other
-- invocations may run between them. Coherent aligned word actions, host
-- argument binding, dispatch completion and compiler lowering are external.
inductive Phase where
  | unread
  | loaded : BitVec 16 → Phase
  | done
  deriving DecidableEq

structure Machine where
  phase : Label → Phase
  memory : HalfMemory.Bytes

def update (state : Machine) (thread : Label) (phase : Phase) : Label → Phase :=
  fun other => if other=thread then phase else state.phase other

inductive Event where
  | load : Label → Event
  | store : Label → Event
  deriving DecidableEq

inductive Step (layout : Copy2D.Layout) : Machine → Event → Machine → Prop where
  | load (ready : before.phase thread=.unread) :
      Step layout before (.load thread)
        ⟨update before thread (.loaded (HalfMemory.load before.memory (2*(Copy2DMemory.operation layout thread).source))),before.memory⟩
  | store (ready : before.phase thread=.loaded value) :
      Step layout before (.store thread)
        ⟨update before thread .done,HalfMemory.store before.memory (2*(Copy2DMemory.operation layout thread).destination) value⟩

inductive Executes (layout : Copy2D.Layout) : Machine → List Event → Machine → Prop where
  | nil (state) : Executes layout state [] state
  | cons : Step layout before action middle →
      Executes layout middle events after → Executes layout before (action::events) after

def initial (memory : HalfMemory.Bytes) : Machine := ⟨fun _ => .unread,memory⟩
def Completed (state : Machine) : Prop := ∀ thread, state.phase thread=.done
def Separate (layout : Copy2D.Layout) : Prop := ∀ reader writer : Label,
  (Copy2DMemory.operation layout reader).source≠(Copy2DMemory.operation layout writer).destination

theorem no_alias (separate : Separate layout) :
    CopyExecution.NoAlias (Copy2DMemory.programs layout 4 256).flatten :=
  Copy2DMemory.no_alias layout separate

theorem destination_unique (bounds : Bounds layout) (a b : Label)
    (same : (Copy2DMemory.operation layout a).destination=(Copy2DMemory.operation layout b).destination) : a=b :=
  Copy2D.destination_unique layout.destinationRow bounds.rowRoom a b (Nat.add_left_cancel same)

theorem load_store (memory : HalfMemory.Bytes) (address : Nat) (value : BitVec 16) :
    HalfMemory.load (HalfMemory.store memory address value) address=value := by
  simp only [HalfMemory.load,HalfMemory.store,
    ite_eq_left (show address≤address+1 ∧ address+1<address+2 by omega),
    ite_eq_left (show address≤address+0 ∧ address+0<address+2 by omega),Nat.add_sub_cancel_left]
  exact HalfMemory.join_bytes value

structure Invariant (layout : Copy2D.Layout) (before : HalfMemory.Bytes) (state : Machine) : Prop where
  registers : ∀ thread value, state.phase thread=.loaded value →
    value=HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source)
  stored : ∀ thread, state.phase thread=.done →
    HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).destination)=
      HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source)
  frame : ∀ word, (∀ thread : Label, (Copy2DMemory.operation layout thread).destination≠word) →
    HalfMemory.load state.memory (2*word)=HalfMemory.load before (2*word)

theorem initial_invariant (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Invariant layout memory (initial memory) where
  registers := by intro thread value impossible; cases impossible
  stored := by intro thread impossible; cases impossible
  frame := by intros; rfl

theorem Invariant.source_read (separate : Separate layout)
    (invariant : Invariant layout before state) (thread : Label) :
    HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source)=
      HalfMemory.load before (2*(Copy2DMemory.operation layout thread).source) :=
  invariant.frame _ (fun writer => Ne.symm (separate thread writer))

theorem step_invariant (bounds : Bounds layout) (separate : Separate layout)
    (invariant : Invariant layout before state) (step : Step layout state action after) :
    Invariant layout before after := by
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

theorem executes_invariant (bounds : Bounds layout) (separate : Separate layout)
    (execution : Executes layout state events after)
    (invariant : Invariant layout before state) : Invariant layout before after := by
  induction execution with
  | nil => exact invariant
  | cons step rest ih => exact ih (step_invariant bounds separate invariant step)

theorem trace_eq (bounds : Bounds layout) (separate : Separate layout)
    (trace : Copy2DMemory.Trace layout 4 256)
    (execution : Executes layout (initial trace.before) events after) (completed : Completed after) :
    after.memory=trace.memory := by
  have invariant := executes_invariant bounds separate execution (initial_invariant layout trace.before)
  have words : HalfMemory.view after.memory=HalfMemory.view trace.memory := by
    funext word
    change HalfMemory.load after.memory (2*word)=HalfMemory.load trace.memory (2*word)
    by_cases inside : ∃ thread : Label, (Copy2DMemory.operation layout thread).destination=word
    · obtain ⟨thread,rfl⟩ := inside
      have stored := invariant.stored thread (completed thread)
      have copied := Copy2DMemory.read_correct layout bounds.sourceAligned bounds.destinationAligned
        bounds.rowRoom trace (no_alias separate) thread
      rw [destination_word_address bounds thread,source_word_address bounds thread] at stored
      rw [destination_word_address bounds thread]
      exact stored.trans copied.symm
    · have outside : ∀ thread : Label, (Copy2DMemory.operation layout thread).destination≠word :=
        fun thread same => inside ⟨thread,same⟩
      rw [Copy2DMemory.memory_equal layout bounds.sourceAligned bounds.destinationAligned bounds.rowRoom trace (no_alias separate)]
      exact (invariant.frame word outside).trans
        ((Copy2DMemory.toCopy layout bounds.sourceAligned bounds.destinationAligned bounds.rowRoom trace).frame word outside).symm
  calc
    after.memory=HalfMemory.encode (HalfMemory.view after.memory) := (HalfMemory.encode_view _).symm
    _=HalfMemory.encode (HalfMemory.view trace.memory) := congrArg HalfMemory.encode words
    _=trace.memory := HalfMemory.encode_view _

theorem Executes.append {first second : List Event}
    (left : Executes layout start first middle) (right : Executes layout middle second finish) :
    Executes layout start (first++second) finish := by
  induction left with
  | nil => exact right
  | cons step tail ih => exact .cons step (ih right)

def loadThread (layout : Copy2D.Layout) (state : Machine) (thread : Label) : Machine :=
  ⟨update state thread (.loaded (HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source))),state.memory⟩

def finishThread (layout : Copy2D.Layout) (state : Machine) (thread : Label) : Machine :=
  let loaded := loadThread layout state thread
  ⟨update loaded thread .done,HalfMemory.store state.memory (2*(Copy2DMemory.operation layout thread).destination)
    (HalfMemory.load state.memory (2*(Copy2DMemory.operation layout thread).source))⟩

def threadEvents (thread : Label) : List Event := [.load thread,.store thread]

theorem finishThread_phase (thread other : Label) (state : Machine) :
    (finishThread layout state thread).phase other=if other=thread then .done else state.phase other := by
  by_cases same : other=thread <;> simp [finishThread,loadThread,update,same]

theorem finishThread_exec (thread : Label) (state : Machine) (ready : state.phase thread=.unread) :
    Executes layout state (threadEvents thread) (finishThread layout state thread) :=
  .cons (.load ready) (.cons (.store (by simp [update])) (.nil _))

def drain (layout : Copy2D.Layout) : List Label → Machine → Machine
  | [], state => state
  | thread::rest, state => drain layout rest (finishThread layout state thread)

theorem drain_phase (threads : List Label) (state : Machine) (thread : Label) :
    (drain layout threads state).phase thread=if thread∈threads then .done else state.phase thread := by
  induction threads generalizing state with
  | nil => simp [drain]
  | cons first rest ih =>
    rw [drain,ih,finishThread_phase]
    by_cases inRest : thread∈rest <;> by_cases same : thread=first <;> simp [inRest,same]

theorem drain_exec (threads : List Label) (state : Machine) (distinct : threads.Nodup)
    (ready : ∀ thread∈threads, state.phase thread=.unread) :
    Executes layout state (threads.flatMap threadEvents) (drain layout threads state) := by
  induction threads generalizing state with
  | nil => exact .nil _
  | cons first rest ih =>
    have firstAbsent := (List.nodup_cons.mp distinct).1
    exact (finishThread_exec first state (ready first List.mem_cons_self)).append
      (ih _ (List.nodup_cons.mp distinct).2 (by
        intro thread present
        rw [finishThread_phase,ite_eq_right (show thread≠first by intro same; subst thread; exact firstAbsent present)]
        exact ready thread (List.mem_cons_of_mem _ present)))

def canonicalAfter (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) : Machine :=
  drain layout (Copy2D.labels 4 256) (initial memory)

theorem canonical_execution (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Executes layout (initial memory) ((Copy2D.labels 4 256).flatMap threadEvents) (canonicalAfter layout memory) :=
  drain_exec _ _ ((List.nodup_finRange 4).product (List.nodup_finRange 256)) (by intros; rfl)

theorem canonical_completed (layout : Copy2D.Layout) (memory : HalfMemory.Bytes) :
    Completed (canonicalAfter layout memory) := by
  intro thread
  unfold canonicalAfter
  rw [drain_phase,ite_eq_left (show thread∈Copy2D.labels 4 256 from
    List.mem_product.mpr ⟨List.mem_finRange _,List.mem_finRange _⟩)]

theorem canonical_refines (bounds : Bounds layout) (separate : Separate layout) (trace : Copy2DMemory.Trace layout 4 256) :
    (canonicalAfter layout trace.before).memory=trace.memory :=
  trace_eq bounds separate trace (canonical_execution layout trace.before) (canonical_completed layout trace.before)

end Inference.Kernels.Copy.GeneralCopy2DInterleaving
