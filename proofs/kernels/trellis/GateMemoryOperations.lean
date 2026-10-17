import kernels.trellis.GateWeightOperations
namespace Inference.Kernels.Trellis.GateMemoryOperations
open Contracts.Mlx Contracts.Mlx.M1Max Models.Qwen PackedArrayMaterialization
set_option maxRecDepth 10000

structure Operations where
  mul : Float32 → Float32 → Float32
  fma : GateFmaOperations.Fma

def standard : Operations := ⟨(·*·),Float32.fma⟩
def flushing : Operations := ⟨FlushToZero.mul,FlushToZero.fma⟩

variable {activation : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer activation}
  {tableBase inputBase : Nat}

def memoryStep (ops : Operations) (input : GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (load : ThreadgroupLoad) (acc : GateAccumulateSource.Dual) : Option GateAccumulateSource.Dual :=
  (GateWeightOperations.weight ops.mul input row run (q*8+p) false load (GateWeightSource.tableMemory actual) tableBase).bind (fun gate =>
    (GateWeightOperations.weight ops.mul input row run (q*8+p) true load (GateWeightSource.tableMemory actual) tableBase).bind (fun up =>
      (GateInputSource.readValue actual.memory inputBase q run p).bind (fun value =>
        GateFmaOperations.step ops.fma (q*8+p) gate up value acc)))

theorem memory_step (ops : Operations) (input : GateInput kg ku)
    (actual : GateInputSource.Execution source tableBase inputBase)
    (row run q p : Nat) (rowBound : row<17408) (runBound : run<160) (qBound : q<4) (pBound : p<8)
    (load : ThreadgroupLoad) (hardware : LoadContract load) (acc : GateAccumulateSource.Dual) :
    memoryStep ops input actual row run q p load acc=some
      (GateFmaOperations.accumulate ops.fma (q*8+p)
        (GateWeightOperations.value ops.mul input row run (q*8+p) false)
        (GateUpExecution.widen (ArrayStorage.bfWords activation (run*32+q*8+p))) acc.1,
       GateFmaOperations.accumulate ops.fma (q*8+p)
        (GateWeightOperations.value ops.mul input row run (q*8+p) true)
        (GateUpExecution.widen (ArrayStorage.bfWords activation (run*32+q*8+p))) acc.2) := by
  rw [memoryStep,GateWeightOperations.weight_initialized ops.mul input row run (q*8+p) false
    rowBound runBound (by omega) load hardware (GateWeightSource.tableMemory actual) tableBase
    (GateWeightSource.table_initialized actual) actual.tableAligned actual.tableBounded,Option.bind_some]
  rw [GateWeightOperations.weight_initialized ops.mul input row run (q*8+p) true
    rowBound runBound (by omega) load hardware (GateWeightSource.tableMemory actual) tableBase
    (GateWeightSource.table_initialized actual) actual.tableAligned actual.tableBounded,Option.bind_some]
  rw [actual.read_original run q p runBound qBound pBound,Option.bind_some]
  exact GateFmaOperations.step_correct ops.fma (q*8+p) (by omega) _ _ _ acc

end Inference.Kernels.Trellis.GateMemoryOperations
