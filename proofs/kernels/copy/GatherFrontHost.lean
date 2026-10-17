import kernels.copy.GatherFrontSource

namespace Inference.Kernels.Copy.GatherFrontHost

-- Reviewed translation of the front-gather branch in Gather::eval_gpu.
-- A native descriptor/argument attachment is still required; this record
-- does not infer row-contiguity from tensor contents.
structure Input where
  sourceElements : Nat
  outputElements : Nat
  indexElements : Nat
  indices : Nat
  axis : Nat
  sourceContiguous : Bool
  indexContiguous : Bool
  sliceSize : Nat
  sourceStride : Nat
  elementBytes : Nat
  deriving DecidableEq

structure Launch where
  wide : Bool
  workPerThread : Nat
  gridX : Nat
  gridY : Nat
  stride : Nat
  sourceRows : Nat
  deriving DecidableEq

def select (input : Input) (rows : Nat) : Option Launch :=
  if input.outputElements=0 then none
  else if input.sourceContiguous && input.indices==1 && input.axis==0 && input.indexContiguous &&
      input.sliceSize==input.sourceStride then
    let n := if input.sliceSize>8 ∧ input.elementBytes<4 then 2 else 1
    some ⟨(input.indices>0 && input.indexElements>2147483647) || input.sourceElements>2147483647 ||
      input.outputElements>2147483647,n,(input.sliceSize+n-1)/n,input.indexElements,input.sliceSize,rows⟩
  else none

def packed : Input := ⟨248320*640,640,1,1,0,true,true,640,640,4⟩
def parameter : Input := ⟨248320*80,80,1,1,0,true,true,80,80,2⟩

theorem packed_selected : select packed 248320=some ⟨false,1,640,1,640,248320⟩ := by decide
theorem parameter_selected : select parameter 248320=some ⟨false,2,40,1,80,248320⟩ := by decide

theorem packed_sizes : packed.sourceElements=158924800 ∧ packed.outputElements=640 ∧
    packed.sourceElements*packed.elementBytes=635699200 := by decide
theorem parameter_sizes : parameter.sourceElements=19865600 ∧ parameter.outputElements=80 ∧
    parameter.sourceElements*parameter.elementBytes=39731200 := by decide

-- Host buffer slots are source=0, token IDs=1, output=2, stride=3, rows=4.
-- Integer bounds include the selected signed LocT even when IDs are uint32.
theorem packed_locT (token : Fin 248320) (thread : Fin 640) :
    640*token.val+thread.val≤2147483647 ∧ thread.val<640 := by
  have := token.isLt
  have := thread.isLt
  omega

theorem parameter_locT (token : Fin 248320) (thread : Fin 40) (coordinate : Fin 2) :
    80*token.val+(2*thread.val+coordinate.val)≤2147483647 ∧ 2*thread.val+coordinate.val<80 := by
  have := token.isLt
  have := thread.isLt
  have := coordinate.isLt
  omega

end Inference.Kernels.Copy.GatherFrontHost
