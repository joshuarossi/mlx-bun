import host.load.run.full.cached.Choice5
import host.load.run.full.FirstValues
import host.load.ProgramEquality
import host.load.ProgramMatchCommand
import host.mlx.KernelSources
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-- The complete terminal source graph is a shared proof representation of
all five forwards. No extra forward execution or cache state is introduced. -/
noncomputable def terminalGraph (table : List F64) : Nat → Option (RNode Int InKey) :=
  ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx

load_program_matches terminal_load_matches : code, code.cert, P.s3573.ffi.mlx

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (env : Env InKey) (table : List F64)

/-- The terminal graph retains exactly the checkpoint-derived parameter
values fixed before assigning native readback values. -/
theorem terminal_parameter_value (leaves : Leaves code env.weights) (t : Tensor)
    (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K env (terminalGraph table) t.node = some (firstValues M K env table t) := by
  have value := parameter_evaluated M K env (terminalGraph table) leaves
    (terminal_load_matches table SourceKernels.sources) t ht
  have same := parameter_values_eq M K env (terminalGraph table) (firstFfiGraph table)
    code code.cert (parameterTensors parameterChoice)
    (terminal_load_matches table SourceKernels.sources)
    (first_load_matches table SourceKernels.sources) code.covers t ht
  exact value.trans (congrArg some same)

end Host.Load.Run.Full.Cached
