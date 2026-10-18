import host.load.run.full.FirstValues
import host.load.ProgramEquality
set_option Elab.async false

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval Host.Ts

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey)

/-- The checkpoint-derived parameter is independent of every numeric-server
entry used later by token readback and loop arithmetic. -/
theorem firstValues_table_eq (table table' : List F64) (t : Tensor)
    (ht : t ∈ parameterTensors parameterChoice) :
    firstValues M K env table t = firstValues M K env table' t :=
  parameter_values_eq M K env (firstFfiGraph table) (firstFfiGraph table')
    code code.cert (parameterTensors parameterChoice)
    (first_load_matches table SourceKernels.sources)
    (first_load_matches table' SourceKernels.sources) code.covers t ht

end Host.Load.Run.Full
