import kernels.RmsHeadStores
import kernels.RmsNormMemory

namespace Inference.Kernels.RmsHeadsMemory
open Contracts.Mlx
set_option maxRecDepth 10000

structure Input (values : Fin heads → Fin 256 → ArrayStorage.BF) (weight : Fin 256 → ArrayStorage.BF) (base : Nat) where
  source : RmsHeadReads.Input values base
  weight : ArrayStorage.BFBuffer weight
  shared : weight.bytes=source.memory

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}

def sourceValues (input : Input values weight base) (head : Fin heads) (i : Fin 256) : Float32 :=
  BFloat16.widen ((input.source.rows head).read i)

def produced (input : Input values weight base) (factor : Fin heads → Float32) (head : Fin heads) (i : Fin 256) : ArrayStorage.BF :=
  RmsNormMemory.operation (factor head) ((input.source.rows head).read i) (input.weight.read i)

theorem sourceValues_eq (input : Input values weight base) (head : Fin heads) :
    sourceValues input head=fun i => BFloat16.widen (values head i) := by
  funext i
  unfold sourceValues
  rw [ArrayStorage.BFBuffer.read_correct]

attribute [local irreducible] sourceValues produced RmsScratch.Trace.factor

-- Input rows are donated in place. Scratch remains threadgroup-local;
-- global writes from independent heads may interleave after each head's
-- capture/reduction barrier. Weight reads use the preserved global heap.
structure Execution (input : Input values weight base) (p : RmsNorm.Platform) (width eps : Float32) where
  dispatch : p.groups=2
  geometry : RmsHeadStores.Geometry heads base
  scratch : ∀ head, RmsScratch.Trace p (sourceValues input head)
  inverse : ∀ head, FloatArrayWrites.Trace 0 (fun _ : Fin 1 => (scratch head).factor width eps)
  factor : Fin heads → Float32
  factorRead : ∀ head, factor head=(inverse head).buffer.read 0
  reads : RmsHeadReads.Trace heads base
  initial : reads.before=input.source.memory
  stores : RmsHeadStores.Trace geometry (produced input factor)
  storeInitial : stores.before=reads.before
  storeSchedule : reads.events.filterMap ReadBeforeOverwrite.storeProjection=stores.schedule
  weightSeparate : MemoryRegions.Disjoint base (512*heads) input.weight.base 512

variable {input : Input values weight base} {p : RmsNorm.Platform} {width eps : Float32}

def fromScratch (input : Input values weight base) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) (geometry : RmsHeadStores.Geometry heads base)
    (scratch : ∀ head, RmsScratch.Trace p (sourceValues input head))
    (inverse : ∀ head, FloatArrayWrites.Trace 0 (fun _ : Fin 1 => (scratch head).factor width eps))
    (weightSeparate : MemoryRegions.Disjoint base (512*heads) input.weight.base 512) : Execution input p width eps :=
  let factor := fun head => (inverse head).buffer.read 0
  let stores := MultiOutputWrites.canonical (geometry.layout (produced input factor)) input.source.memory
  ⟨dispatch, geometry, scratch, inverse, factor, fun _ => rfl, RmsHeadStores.readTrace stores, rfl,
    stores, rfl, RmsHeadStores.readTrace_stores stores, weightSeparate⟩

def canonical (input : Input values weight base) (p : RmsNorm.Platform) (width eps : Float32)
    (dispatch : p.groups=2) (geometry : RmsHeadStores.Geometry heads base)
    (weightSeparate : MemoryRegions.Disjoint base (512*heads) input.weight.base 512) : Execution input p width eps :=
  let scratch := fun head => RmsScratch.Trace.canonical p (sourceValues input head)
  fromScratch input p width eps dispatch geometry scratch
    (fun head => FloatArrayWrites.Trace.canonical (fun _ : Fin 1 => (scratch head).factor width eps) (by decide)) weightSeparate

theorem Execution.captured_input (execution : Execution input p width eps) : execution.reads.capturedRows=values :=
  execution.reads.rows_eq input.source execution.initial

theorem Execution.factor_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    execution.factor head=RmsNorm.inverse p (fun i => BFloat16.widen (values head i)) width eps before scratchBase := by
  rw [execution.factorRead, ArrayStorage.FloatBuffer.read_correct, (execution.scratch head).factor_eq width eps before scratchBase,
    sourceValues_eq]

theorem Execution.produced_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    produced input execution.factor head=RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase := by
  funext i
  unfold produced
  rw [ArrayStorage.BFBuffer.read_correct, ArrayStorage.BFBuffer.read_correct, execution.factor_eq head before scratchBase]
  unfold RmsNormMemory.operation
  rfl

def Execution.buffer (execution : Execution input p width eps) (head : Fin heads) :
    ArrayStorage.BFBuffer (produced input execution.factor head) := RmsHeadStores.buffer execution.stores head

def Execution.output (execution : Execution input p width eps) (head : Fin heads) : Fin 256 → ArrayStorage.BF :=
  (execution.buffer head).read

theorem Execution.output_eq (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    execution.output head=RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase :=
  (funext (execution.buffer head).read_correct).trans (execution.produced_eq head before scratchBase)

def Execution.forwardBuffer (execution : Execution input p width eps) (head : Fin heads) (before : M1Max.WordMemory) (scratchBase : Nat) :
    ArrayStorage.BFBuffer (RmsNorm.value p (fun i => BFloat16.widen (values head i)) weight width eps before scratchBase) :=
  ArrayViews.reindex (execution.produced_eq head before scratchBase) (execution.buffer head)

theorem Execution.memory (execution : Execution input p width eps) : execution.reads.after.memory=execution.stores.memory := by
  rw [execution.reads.memory, execution.storeSchedule]
  unfold MultiOutputWrites.Trace.memory
  rw [execution.storeInitial]

theorem Execution.other_region (execution : Execution input p width eps) {region size : Nat}
    (separate : MemoryRegions.Disjoint base (512*heads) region size) (offset : Nat) (bound : offset<size) :
    execution.stores.memory (region+offset)=input.source.memory (region+offset) :=
  (RmsHeadStores.other_region execution.stores separate offset bound).trans (congrFun (execution.storeInitial.trans execution.initial) _)

def Execution.weightsAfter (execution : Execution input p width eps) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf input.weight execution.stores.memory
    (fun offset bound => (execution.other_region execution.weightSeparate offset bound).trans (congrFun input.shared _).symm)

def Execution.intermediateWeights (execution : Execution input p width eps)
    {after : RmsHeadReads.Machine heads} {events : List (ReadBeforeOverwrite.Event heads 64)}
    (run : ReadBeforeOverwrite.Executes (RmsHeadReads.layout heads base) (RmsHeadReads.read base)
      (ReadBeforeOverwrite.initial input.source.memory) events after) : ArrayStorage.BFBuffer weight :=
  ArrayFrame.bf input.weight after.memory
    (fun offset bound => (ReadBeforeOverwrite.frame run (RmsHeadReads.group_separate execution.weightSeparate) offset bound).trans
      (congrFun input.shared _).symm)

theorem Execution.intermediate_capture (execution : Execution input p width eps)
    {after : RmsHeadReads.Machine heads} {events : List (ReadBeforeOverwrite.Event heads 64)}
    (run : ReadBeforeOverwrite.Executes (RmsHeadReads.layout heads base) (RmsHeadReads.read base)
      (ReadBeforeOverwrite.initial input.source.memory) events after)
    (head : Fin heads) (thread : Fin 64) (registers : RmsHeadReads.Registers)
    (captured : after.registers head thread=some registers) (offset : Fin 4) :
    registers offset=ArrayStorage.bits (values head (RmsHeadReads.coordinate thread offset)) := by
  rw [ReadBeforeOverwrite.captured_original (RmsHeadReads.read_local heads base) run head thread registers captured]
  exact input.source.read_correct head thread offset

end Inference.Kernels.RmsHeadsMemory
