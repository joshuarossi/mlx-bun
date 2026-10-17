import kernels.trellis.GateRowSource
namespace Inference.Kernels.Trellis.GateStoreSource
open Contracts.Mlx Contracts.Mlx.M1Max PackedArrayMaterialization GateTailSource
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Arbitrary selected float operations preserve the casts and statement order.
-- standard/flushing select the existing two explicit scalar tail contracts.
def floatTail (ops : FloatOperations) (expPrecise : Float32 → Float32) (gate up : Float32) : BF :=
  let g:=BFloat16.cast gate
  let u:=BFloat16.cast up
  let sigmoid:=BFloat16.cast (ops.divide 1 (ops.add 1 (expPrecise (-g))))
  let silu:=BFloat16.cast (ops.multiply g sigmoid)
  BFloat16.narrow (ops.multiply silu u)

theorem run_float (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (gate up : Float32) :
    run ops expPrecise expAbs 0 gate up=some (floatTail ops expPrecise gate up) := by
  unfold run
  rw [GateTailSyntax.parsed]
  rfl

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def values (input : GateInput kg ku) (reduce : DownExecution.SimdReduction) (ops : FloatOperations)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) (row : Nat) : BF :=
  let pair:=projectionValues (activation:=activation) input row reduce
  if split then GateUpSplitTail.tail expAbs (BFloat16.narrow pair.1) (BFloat16.narrow pair.2)
  else floatTail ops expPrecise pair.1 pair.2

theorem output_value (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (row : Nat) (bound : row<17408) (load : ThreadgroupLoad) (hardware : LoadContract load)
    (reduce : DownExecution.SimdReduction) (ops : FloatOperations)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    output input actual row load reduce ops expPrecise expAbs (if split then 1 else 0)=some
      (values (activation:=activation) input reduce ops expPrecise expAbs split row) := by
  rw [output_from_original input actual row bound load hardware reduce]
  cases split with
  | false => exact run_float ops expPrecise expAbs _ _
  | true => exact split_tail ops expPrecise expAbs _ _

-- Existing destination bytes are supplied as before, independently of the
-- read-only input and packed-weight heaps. Every emitted half-store is the
-- exact final BF16 payload; no new numerical narrowing occurs while storing.
def thread (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (base group thread : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) : Option (List HalfMemory.Store) := do
  let active ←GateRowSource.writer (thread%32)
  if active then
    let rows ←GateRowSource.rows group (thread/32)
    rows.mapM (fun row => do
      let value ←output input actual row load reduce ops expPrecise expAbs (if split then 1 else 0)
      pure ⟨base/2+row,value.bits⟩)
  else pure []

theorem mapM_exact {α β : Type} (items : List α) (first : α → Option β) (second : α → β)
    (success : ∀ item ∈ items, first item=some (second item)) : items.mapM first=some (items.map second) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,List.map_cons]
    rw [success item (by simp)]
    rw [ih (fun i member => success i (by simp [member]))]
    rfl

attribute [local irreducible] output GateRowSource.writer GateRowSource.rows

theorem thread_eq (input : GateInput kg ku) (actual : GateInputSource.Execution source tableBase inputBase)
    (base group index : Nat) (groupBound : group<160) (threadBound : index<1024)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    thread input actual base group index load reduce ops expPrecise expAbs split=some
      (GateUpOutput.threadStores base (values (activation:=activation) input reduce ops expPrecise expAbs split) group index) := by
  unfold thread
  rw [GateRowSource.writer_selected ⟨index%32,Nat.mod_lt _ (by decide)⟩]
  by_cases active : index%32=0
  · simp only [active,decide_true]
    rw [GateRowSource.rows_selected group (index/32) groupBound (by omega)]
    change (GateRowSource.expected group (index/32)).mapM _=_
    rw [mapM_exact (GateRowSource.expected group (index/32)) _
      (fun row => (⟨base/2+row,(values (activation:=activation) input reduce ops expPrecise expAbs split row).bits⟩ : HalfMemory.Store)) (by
        intro row member
        obtain ⟨iteration,iterationBound,valid,equal⟩:=GateRowSource.row_member group (index/32) row member
        have bound : row<17408 := by omega
        rw [output_value input actual row bound load hardware reduce ops expPrecise expAbs split]
        rfl)]
    simp only [GateRowSource.expected,GateUpOutput.threadStores,active,ite_true,List.map_map]
    rfl
  · simp [active,GateUpOutput.threadStores]

def programs (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) : List (List HalfMemory.Store) :=
  ((List.range 160).product (List.range 1024)).map (fun pair =>
    (thread input (actual pair.1) base pair.1 pair.2 load reduce ops expPrecise expAbs split).getD [])

theorem programs_eq (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    programs input actual base load reduce ops expPrecise expAbs split=GateUpOutput.programs base
      (values (activation:=activation) input reduce ops expPrecise expAbs split) := by
  unfold programs GateUpOutput.programs
  apply List.map_congr_left
  intro pair member
  obtain ⟨groupBound,threadBound⟩:=List.mem_product.mp member
  rw [thread_eq input (actual pair.1) base pair.1 pair.2 (List.mem_range.mp groupBound)
    (List.mem_range.mp threadBound) load hardware reduce ops expPrecise expAbs split]
  rfl

theorem programs_separated (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (load : ThreadgroupLoad) (hardware : LoadContract load) (reduce : DownExecution.SimdReduction)
    (ops : FloatOperations) (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    WriteOwnership.Separated MemoryCells.Store.word (programs input actual base load reduce ops expPrecise expAbs split) := by
  rw [programs_eq input actual base load hardware]
  exact GateUpOutput.separated _ _

structure Execution (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction) (ops : FloatOperations)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) where
  before : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  bounded : base+34816≤2^64
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs input actual base load reduce ops expPrecise expAbs split) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def canonical (input : GateInput kg ku) (actual : Nat → GateInputSource.Execution source tableBase inputBase)
    (base : Nat) (aligned : base%2=0) (bounded : base+34816≤2^64) (before : HalfMemory.Bytes)
    (load : ThreadgroupLoad) (reduce : DownExecution.SimdReduction) (ops : FloatOperations)
    (expPrecise : Float32 → Float32) (expAbs : BF → BF) (split : Bool) :
    Execution input actual load reduce ops expPrecise expAbs split :=
  let threads:=programs input actual base load reduce ops expPrecise expAbs split
  ⟨before,base,aligned,bounded,threads.flatten,List.replicate threads.length [],
    ThreadgroupWrites.canonical threads,ThreadgroupWrites.canonical_barrier threads⟩

variable {input : GateInput kg ku} {actual : Nat → GateInputSource.Execution source tableBase inputBase}
  {load : ThreadgroupLoad} {reduce : DownExecution.SimdReduction} {ops : FloatOperations}
  {expPrecise : Float32 → Float32} {expAbs : BF → BF} {split : Bool}

def Execution.existing (state : Execution input actual load reduce ops expPrecise expAbs split) (hardware : LoadContract load) :
    GateUpOutput.Trace (values (activation:=activation) input reduce ops expPrecise expAbs split) where
  before:=state.before
  base:=state.base
  aligned:=state.aligned
  bounded:=state.bounded
  schedule:=state.schedule
  remaining:=state.remaining
  execution:=by rw [←programs_eq input actual state.base load hardware]; exact state.execution
  completed:=state.completed

def Execution.memory (state : Execution input actual load reduce ops expPrecise expAbs split) : HalfMemory.Bytes :=
  HalfMemory.execute state.schedule state.before

theorem Execution.bits_stored (state : Execution input actual load reduce ops expPrecise expAbs split)
    (hardware : LoadContract load) (row : Nat) (bound : row<17408) :
    HalfMemory.load state.memory (state.base+2*row)=
      (values (activation:=activation) input reduce ops expPrecise expAbs split row).bits := by
  unfold Execution.memory
  rw [HalfMemory.execute_load _ _ _ (by have := state.aligned; omega),
    show (state.base+2*row)/2=state.base/2+row by have := state.aligned; omega]
  exact GateUpOutput.stored (HalfMemory.view state.before) state.base _ state.schedule state.remaining
    (state.existing hardware).execution state.completed row bound

theorem Execution.current_bytes (state : Execution input actual load reduce ops expPrecise expAbs split)
    (hardware : LoadContract load) (row offset : Nat) (rowBound : row<17408) (offsetBound : offset<2) :
    state.memory (state.base+2*row+offset)=HalfMemory.byte
      (values (activation:=activation) input reduce ops expPrecise expAbs split row).bits offset := by
  rw [←HalfMemory.byte_load state.memory (state.base+2*row) offset offsetBound,state.bits_stored hardware row rowBound]

theorem Execution.read_correct (state : Execution input actual load reduce ops expPrecise expAbs split)
    (hardware : LoadContract load) (row : Nat) (bound : row<17408) :
    BFloat16.widen (Model.ofBits (HalfMemory.load state.memory (state.base+2*row)))=
      BFloat16.widen (values (activation:=activation) input reduce ops expPrecise expAbs split row) := by
  rw [state.bits_stored hardware row bound]
  rfl

theorem Execution.region_inside (state : Execution input actual load reduce ops expPrecise expAbs split)
    (hardware : LoadContract load) : MemoryRegions.Inside16 state.base 34816 state.schedule := by
  intro store member
  have generated := (ThreadgroupWrites.completed_schedule (state.existing hardware).execution state.completed).mem_iff.mp member
  obtain ⟨threadProgram,programMember,inThread⟩:=List.mem_flatten.mp generated
  obtain ⟨⟨group,index⟩,launched,equal⟩:=List.mem_map.mp programMember
  subst threadProgram
  obtain ⟨active,iteration,iterationBound,rowBound,same⟩:=GateUpOutput.thread_member state.base
    (values (activation:=activation) input reduce ops expPrecise expAbs split) group index store inThread
  subst store
  have aligned:=state.aligned
  change state.base≤2*(state.base/2+GateUpCodebook.row group (index/32) iteration) ∧
    2*(state.base/2+GateUpCodebook.row group (index/32) iteration)+2≤state.base+34816
  omega

theorem Execution.frame (state : Execution input actual load reduce ops expPrecise expAbs split)
    (hardware : LoadContract load) (address : Nat) (outside : address<state.base ∨ state.base+34816≤address) :
    state.memory address=state.before address :=
  MemoryRegions.execute16_frame state.schedule state.before (state.region_inside hardware) outside

theorem Execution.read_bounds (state : Execution input actual load reduce ops expPrecise expAbs split)
    (row : Nat) (bound : row<17408) :
    (state.base+2*row)%2=0 ∧ state.base≤state.base+2*row ∧ state.base+2*row+2≤2^64 := by
  have :=state.aligned
  have :=state.bounded
  omega
end Inference.Kernels.Trellis.GateStoreSource
