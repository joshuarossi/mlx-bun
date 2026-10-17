import kernels.quantization.AffineOutputSyntax
import kernels.quantization.MlxQmvMemory
namespace Inference.Kernels.Quantization.AffineOutputSource
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open AffineOutputSyntax
open Trellis.GateRowSyntax (Expr)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] parseRow parseLoop parseProjection parseStore parseConfig
  CopyContiguous.programs

-- The uint builtin promotes the arithmetic before assignment to signed int.
def evaluate (rows simds : Nat) (blockY : BitVec 32) (simd : Fin 16) : Expr → Option (BitVec 32)
  | .variable name => if name="R" then some (BitVec.ofNat 32 rows) else if name="S" then some (BitVec.ofNat 32 simds)
      else if name="sg" then some (BitVec.ofNat 32 simd.val) else none
  | .builtin name component => if name="threadgroup_position_in_grid" ∧ component="y" then some blockY else none
  | .add left right => do pure ((←evaluate rows simds blockY simd left)+(←evaluate rows simds blockY simd right))
  | .multiply left right => do pure ((←evaluate rows simds blockY simd left)*(←evaluate rows simds blockY simd right))
  | _ => none

def rowBase (blockY : BitVec 32) (simd : Fin 16) : Option Int := do
  let (rows,simds) ←parseConfig configSource
  let constant ←parseRow rowSource
  if constant.target≠"row0" then none else do
    let value ←evaluate rows simds blockY simd constant.value
    if value.toNat<2^31 then some value.toNat else none

def block (group : Fin groups) : BitVec 32 := BitVec.ofNat 32 (group.val/16)
def simd (group : Fin groups) : Fin 16 := ⟨group.val%16,by omega⟩

theorem row_base (limit : groups≤62080) (group : Fin groups) :
    rowBase (block group) (simd group)=some (4*group.val:Int) := by
  have bounded := group.isLt
  have a : group.val/16<2^32 := by omega
  have b : group.val/16*16<2^32 := by omega
  have c : group.val/16*16+group.val%16<2^32 := by omega
  have d : (group.val/16*16+group.val%16)*4<2^32 := by omega
  have signed : group.val*4<2^31 := by omega
  have same : group.val/16*16+group.val%16=group.val := by omega
  simp [rowBase,parsed_config,parsed_row,row,evaluate,block,simd,BitVec.toNat_add,BitVec.toNat_mul,
    BitVec.toNat_ofNat,Nat.mul_comm]
  omega

def visits : Nat → Nat → Nat → Option (List (Fin 4))
  | 0,current,bound => if current<bound then none else some []
  | fuel+1,current,bound => if current<bound then
      if h : current<4 then do pure (⟨current,h⟩::(←visits fuel (current+1) bound)) else none
    else some []
def loopVisits : Option (List (Fin 4)) := do
  let (rows,_) ←parseConfig configSource
  let header ←parseLoop loopSource
  if header.counter≠"r" ∨ header.condition≠"r" ∨ header.increment≠"r" ∨ header.bound≠"R" then none
  else visits 4 header.initial rows

theorem loop_visits : loopVisits=some (List.finRange 4) := by
  simp only [loopVisits,parsed_config,parsed_loop]
  decide +kernel

-- result[r] is an explicit source register boundary. The specialization below
-- supplies original laneValue/tiles4; outer K accumulation is not parsed here.
def project (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (group : Fin groups) (offset : Fin 4) : Option Float32 := do
  let field ←parseProjection projectionSource
  if field.target="v" ∧ field.reduce="simd_sum" ∧ field.array="result" ∧ field.index="r" then
    some (p.reduce (registers (CopyContiguous.index group offset))) else none

def values (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32) (row : Fin (4*groups)) : BitVec 16 :=
  ArrayStorage.bits (BFloat16.narrow (p.reduce (registers row)))

def store (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (group : Fin groups) (lane : Fin 32) (offset : Fin 4) : Option (List HalfMemory.Store) := do
  let row0 ←rowBase (block group) (simd group)
  let value ←project p registers group offset
  let field ←parseStore storeSource
  if field.lane≠"lane" ∨ field.target≠"y" ∨ field.base≠"row0" ∨ field.offset≠"r" ∨ field.cast≠"T" ∨ field.value≠"v" then none
  else if lane.val=field.selected then
    if 0≤row0+(offset.val:Int) ∧ row0+(offset.val:Int)<2^31 then
      some [⟨base/2+(row0+(offset.val:Int)).toNat,ArrayStorage.bits (BFloat16.narrow value)⟩]
    else none
  else some []

theorem source_store (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (limit : groups≤62080) (group : Fin groups) (lane : Fin 32) (offset : Fin 4) :
    store p registers base group lane offset=some (if lane.val=0 then
      [CopyContiguous.entry base (values p registers) group offset] else []) := by
  have g := group.isLt; have r := offset.isLt
  have safe : 0≤(4*group.val:Int)+offset.val ∧ (4*group.val:Int)+offset.val<2^31 := by omega
  have index : ((4*group.val:Int)+offset.val).toNat=(CopyContiguous.index group offset).val := by
    dsimp [CopyContiguous.index]; omega
  simp only [store,row_base limit,project,parsed_projection,parsed_store,projection,AffineOutputSyntax.store]
  simp only [and_self,ite_true,ne_eq,not_true_eq_false,or_self,ite_false,bind,Option.bind]
  rw [ite_eq_left safe,index]
  by_cases writer : lane.val=0
  all_goals simp [writer,CopyContiguous.entry,values]

theorem unique_writer (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (limit : groups≤62080) (group : Fin groups) (offset : Fin 4) (lane : Fin 32) (notzero : lane.val≠0) :
    store p registers base group lane offset=some [] := by rw [source_store p registers base limit]; simp [notzero]

def threadProgram (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (group : Fin groups) : Option (List HalfMemory.Store) := do
  let offsets ←loopVisits
  let writes ←offsets.mapM (store p registers base group 0)
  pure writes.flatten

private theorem mapM_some {α β : Type} (items : List α) (f : α → Option β) (g : α → β)
    (same : ∀ item∈items, f item=some (g item)) : items.mapM f=some (items.map g) := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [List.mapM_cons,same item (by simp),List.map_cons]
    rw [ih (fun value member => same value (by simp [member]))]
    rfl

theorem source_thread (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (limit : groups≤62080) (group : Fin groups) :
    threadProgram p registers base group=some (CopyContiguous.threadStores base (values p registers) group) := by
  unfold threadProgram
  rw [loop_visits]
  have writes := mapM_some (List.finRange 4) (store p registers base group 0)
    (fun offset => [CopyContiguous.entry base (values p registers) group offset])
    (fun offset _ => source_store p registers base limit group 0 offset)
  change Option.bind ((List.finRange 4).mapM (store p registers base group 0)) (fun writes => some writes.flatten)=_
  rw [writes]
  simp [CopyContiguous.threadStores]
  rfl

def programs (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32) (base : Nat) :
    Option (List (List HalfMemory.Store)) := (List.finRange groups).mapM (threadProgram p registers base)

theorem source_programs (p : AffineRow.Platform) (registers : Fin (4*groups) → Fin 32 → Float32)
    (base : Nat) (limit : groups≤62080) :
    programs p registers base=some (CopyContiguous.programs base (values p registers)) := by
  unfold programs
  rw [CopyContiguous.programs]
  exact mapM_some _ _ _ (fun group _ => source_thread p registers base limit group)

variable {p : AffineRow.Platform} {input : Fin (steps*512) → ArrayStorage.BF} {buffers : AffineLoads.Buffers}
  (projection : MlxQmvMemory.Execution .four p input buffers groups)

def originalRegisters (row : Fin (4*groups)) : Fin 32 → Float32 :=
  AffineRow.laneValue (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row))

theorem original_values : values p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers))=
    fun row => ArrayStorage.bits (MlxQmvDevice.produced .four p projection.source buffers row) := by
  funext row
  apply congrArg ArrayStorage.bits
  change AffineRow.output p (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row))=MlxQmvDevice.produced .four p projection.source buffers row
  unfold MlxQmvDevice.produced
  exact (AffineLoads.forward4_input p input projection.source buffers row).symm

theorem selected_programs (limit : groups≤62080) :
    programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
      some (CopyContiguous.programs (blocks:=groups) projection.base
        (fun row => ArrayStorage.bits (MlxQmvDevice.produced .four p projection.source buffers row))) := by
  rw [source_programs p _ _ limit,original_values projection]

structure Certificate : Prop where
  sourcePrograms : programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=
      some (CopyContiguous.programs (blocks:=groups) projection.base
        (fun row => ArrayStorage.bits (MlxQmvDevice.produced .four p projection.source buffers row)))
  execution : ∃ writes, programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=some writes ∧
    ThreadgroupWrites.Executes writes projection.stores.schedule projection.stores.remaining
  completed : ThreadgroupWrites.AtBarrier projection.stores.remaining
  storeBounds : ∀ row : Fin (4*groups), (projection.base+2*row.val)%2=0 ∧ projection.base+2*row.val+2≤2^64
  sameHeap : projection.stores.memory=HalfMemory.execute projection.stores.schedule projection.source.bytes
  readback : ∀ row : Fin (4*groups), HalfMemory.load projection.stores.memory (projection.base+2*row.val)=
    ArrayStorage.bits (AffineRow.output p (AffineRow.tiles4 p input (AffineLoads.weights4 buffers row)))

theorem checked_output (limit : groups≤62080) : Certificate projection := by
  refine ⟨selected_programs projection limit,⟨_,selected_programs projection limit,projection.stores.execution⟩,
    projection.stores.completed,projection.stores.read_bounds projection.bounded,projection.memory,?_⟩
  intro row
  rw [projection.stores.read_correct]
  apply congrArg ArrayStorage.bits
  unfold MlxQmvDevice.produced
  exact AffineLoads.forward4_input p input projection.source buffers row

theorem separated_writers (limit : groups≤62080) :
    ∃ writes, programs p (originalRegisters (groups:=groups) (p:=p) (input:=input) (buffers:=buffers)) projection.base=some writes ∧
      WriteOwnership.Separated MemoryCells.Store.word writes := by
  exact ⟨_,selected_programs projection limit,CopyContiguous.separated _ _⟩

theorem outside (separate : MemoryRegions.Disjoint projection.base (2*(4*groups)) base size)
    (offset : Nat) (bound : offset<size) : projection.stores.memory (base+offset)=projection.source.bytes (base+offset) :=
  projection.other_region separate offset bound

end Inference.Kernels.Quantization.AffineOutputSource
