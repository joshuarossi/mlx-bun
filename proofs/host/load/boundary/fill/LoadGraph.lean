import host.load.boundary.fill.Parameters
import host.load.run.full.FirstValues
import host.load.ProgramEquality
import host.load.ProgramMatchCommand
import host.mlx.KernelSources
namespace Host.Load.Run.Full.Fill64
open Host.Ts Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-- The actual boundary fragment retains the checkpoint load program. -/
noncomputable def parameterGraph (table : List F64) : Nat → Option (RNode Int InKey) :=
  ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources s1491.ffi.mlx

load_program_matches load_matches : code, code.cert, s1491.ffi.mlx

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (env : Env InKey) (table : List F64)

/-- The boundary graph retains exactly the checkpoint-derived parameter
values fixed before assigning native readback values. -/
theorem parameter_value (leaves : Leaves code env.weights) (t : Tensor)
    (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K env (parameterGraph table) t.node = some (firstValues M K env table t) := by
  have value := parameter_evaluated M K env (parameterGraph table) leaves
    (load_matches table SourceKernels.sources) t ht
  have same := parameter_values_eq M K env (parameterGraph table) (firstFfiGraph table)
    code code.cert (parameterTensors parameterChoice)
    (load_matches table SourceKernels.sources)
    (first_load_matches table SourceKernels.sources) code.covers t ht
  exact value.trans (congrArg some same)

end Host.Load.Run.Full.Fill64
