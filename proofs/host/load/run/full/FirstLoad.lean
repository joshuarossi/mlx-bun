import host.load.ProgramMatchCommand
import host.load.run.full.FirstGraph
import host.load.run.full.Parameters

namespace Host.Load.Run.Full
open Host.Ts Host.Load Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

/- Every checkpoint load and preprocessing node has the same carrier after
the first actual decode. The original valid program and its leaf assumptions
are reused; each matching obligation is checked independently. -/
load_program_matches first_load_matches : code, code.cert, firstChoice.graph

theorem first_load_matches_source (table : List F64) (sources : KernelSources) :
    Matches (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) sources P.s2974.ffi.mlx)
      (code.map Program.Node.erase) code.cert = true := by
  rw [first_graph_matches]
  exact first_load_matches table sources

theorem first_parameter_tensors : parameterTensors firstChoice = parameterTensors parameterChoice := by
  unfold parameterTensors
  rw [first_parameters_preserved]

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey) (table : List F64) (sources : KernelSources)

/-- Derived parameters are evaluated from the same checkpoint leaves in the
first-yield source graph. No per-node tensor contents are assumed. -/
theorem parameter_evaluated_first (leaves : Leaves code env.weights) (t : Tensor)
    (ht : t ∈ parameterTensors firstChoice) :
    evalR M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) sources firstChoice.graph) t.node =
      some (headerValues (contents M K env
        (ffiGraph (concrete (CSrv.val ⟨table⟩)) sources firstChoice.graph)) t) := by
  exact parameter_evaluated M K env _ leaves (first_load_matches table sources) t
    (by simpa only [first_parameter_tensors] using ht)

end Host.Load.Run.Full
