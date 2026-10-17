import kernels.normalization.MlxRmsPointerSource

namespace Inference.Kernels.Normalization.MlxRmsHostSelection
open Contracts.Mlx
set_option maxRecDepth 10000

-- Reviewed translation of RMSNorm::eval_gpu's metadata decisions, not a C++
-- frontend proof. Native array metadata extraction, pipeline lookup and command
-- submission remain boundaries. No fixed value for the device's thread limit
-- is inferred merely from the M1 Max model name.
def reads : Nat := 4
def loopedLimit : Nat := 4096
def simdWidth : Nat := 32

structure Metadata where
  lastExtent : Nat
  dataSize : Nat
  rank : Nat
  contiguous : Bool
  lastStride : Nat
  previousStride : Nat
  previousExtent : Nat
  donatable : Bool
  weightRank : Nat
  weightStride : Nat

structure KernelLimit where
  threads : Nat
  positive : 0<threads
  bounded : threads≤1024
  wholeSimds : threads%32=0

inductive Allocation where
  | donated | fresh | contiguousCopy
  deriving DecidableEq, Repr

def noCopy (metadata : Metadata) : Bool :=
  metadata.contiguous && metadata.lastStride==1 &&
    (metadata.rank≤1 || metadata.previousStride==0 ||
      metadata.previousStride==metadata.lastExtent || metadata.previousExtent==1)

def allocation (metadata : Metadata) : Allocation :=
  if noCopy metadata then if metadata.donatable then .donated else .fresh else .contiguousCopy

structure Launch where
  axis : Nat
  rows : Nat
  looped : Bool
  weightStride : Nat
  groupThreads : Nat
  gridThreads : Nat
  allocation : Allocation
  deriving DecidableEq, Repr

-- axis_size is uint32; the selected data_size/axis_size quotient is representable
-- as the native signed int n_rows. Unrepresentable inputs are outside this model.
-- Only the no-copy route is selected here. A contiguous copy can change the
-- data extent and needs a separate binding of its newly constructed metadata.
def select (metadata : Metadata) (kernel : KernelLimit) : Option Launch :=
  if noCopy metadata then do
    let axis := metadata.lastExtent%2^32
    if axis=0 then none else do
      let rows := metadata.dataSize/axis
      if rows<2^31 then
        let looped := decide (loopedLimit<axis)
        let threads := if looped then kernel.threads else
          simdWidth*((((axis+reads-1)/reads)+simdWidth-1)/simdWidth)
        if threads≤kernel.threads then
          some ⟨axis,rows,looped,
            if metadata.weightRank=1 then metadata.weightStride%2^32 else 0,
            threads,rows*threads,allocation metadata⟩
        else none
      else none
  else none

def singleToken (donatable : Bool) : Metadata :=
  ⟨5120,5120,2,true,1,5120,1,donatable,1,1⟩

theorem single_no_copy (donatable : Bool) : noCopy (singleToken donatable)=true := rfl

theorem single_allocation (donatable : Bool) :
    allocation (singleToken donatable)=if donatable then .donated else .fresh := by
  cases donatable <;> rfl

theorem single_launch (donatable : Bool) (kernel : KernelLimit) :
    select (singleToken donatable) kernel=some
      ⟨5120,1,true,1,kernel.threads,kernel.threads,if donatable then .donated else .fresh⟩ := by
  cases donatable <;> simp [select,singleToken,loopedLimit,allocation,noCopy]

def groups (kernel : KernelLimit) : Nat := kernel.threads/32

theorem groups_exact (kernel : KernelLimit) : groups kernel*32=kernel.threads := by
  have := Nat.mod_add_div kernel.threads 32
  rw [kernel.wholeSimds] at this
  unfold groups
  omega

theorem groups_positive (kernel : KernelLimit) : 0<groups kernel := by
  have := groups_exact kernel
  have := kernel.positive
  omega

theorem groups_bounded (kernel : KernelLimit) : groups kernel≤32 := by
  have := groups_exact kernel
  have := kernel.bounded
  omega

-- Kernel group ids for this grid are row zero. The looped kernel's w_stride
-- and N_READS inputs are derived from the selected metadata/constants.
theorem single_arguments (donatable : Bool) (kernel : KernelLimit) (launch : Launch)
    (selected : select (singleToken donatable) kernel=some launch) :
    launch.axis=5120 ∧ launch.rows=1 ∧ launch.looped=true ∧ launch.weightStride=1 ∧
      launch.gridThreads=kernel.threads ∧ launch.groupThreads=kernel.threads ∧
      (∀ row : Fin launch.rows, row.val=0) ∧ reads=4 := by
  rw [single_launch] at selected
  cases Option.some.inj selected
  exact ⟨rfl,rfl,rfl,rfl,rfl,rfl,fun row => by have bound : row.val<1 := row.isLt; omega,rfl⟩

theorem selected_groups (platform : RmsNorm.Platform) (kernel : KernelLimit)
    (nativeThreadCount : platform.groups*32=kernel.threads) :
    platform.groups=groups kernel := by
  have := groups_exact kernel
  omega

-- Once the native metadata has been attached to the logical single-token
-- buffers, dispatch supplies the exact row/weight-stride specialization used
-- by the parsed pointer/body proof. No execution-result premise is needed.
theorem dispatched_cell {values weights : Fin 5120 → ArrayStorage.BF}
    (input : BinaryMemory.Input values weights) {factor : Float32}
    (existing : BinaryMemory.Execution input (RmsNormMemory.operation factor))
    (kernel : KernelLimit) (donatable : Bool) (launch : Launch)
    (selected : select (singleToken donatable) kernel=some launch)
    (inverse : M1Max.WordMemory) (inverseBase : Nat) (col : Fin 5120) (before : HalfMemory.Bytes) :
    launch.rows=1 ∧ launch.weightStride=1 ∧ launch.groupThreads=kernel.threads ∧
      MlxRmsPointerSource.executeCell input existing kernel.threads kernel.positive inverse inverseBase col before=
        some (MlxRmsOutputMemory.cell kernel.threads kernel.positive input.lhs.base input.rhs.base
          (2*existing.base) inverse inverseBase col before) := by
  have arguments := single_arguments donatable kernel launch selected
  exact ⟨arguments.2.1,arguments.2.2.2.1,arguments.2.2.2.2.2.1,
    MlxRmsPointerSource.execution_cell input existing kernel.threads kernel.positive (by decide) inverse inverseBase col before⟩

end Inference.Kernels.Normalization.MlxRmsHostSelection
