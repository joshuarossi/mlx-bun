import host.load.run.full.FirstLoad
import host.load.run.full.FirstPrompt
import host.load.run.full.InputValues
import host.mlx.GraphStability
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

noncomputable def firstValues : TensorValues :=
  headerValues (contents M K env (firstFfiGraph table))

noncomputable def firstStepEnv : FfiEval.Env InKey :=
  stepEnvWithIds env.weights (weights (firstValues M K env table)) (promptIds 9707) initialHandles

/-- Changing the expected input interpretation does not change the actual
FFI nodes: their leaves are checkpoint loads and source data, not expected
input placeholders. -/
theorem first_parameter_value (leaves : Leaves code env.weights) (t : Tensor)
    (ht : t ∈ parameterTensors parameterChoice) :
    evalR M K (firstStepEnv M K env table) (firstFfiGraph table) t.node =
      some (firstValues M K env table t) := by
  have stable := evalFfi_inputs M K (firstStepEnv M K env table) env rfl
    (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources firstChoice.graph t.node
  apply stable.trans
  exact parameter_evaluated M K env (firstFfiGraph table) leaves
    (first_load_matches table SourceKernels.sources) t ht

/-- Parameter preprocessing, empty caches, and prompt bytes discharge the
input-value premise for any certificate with the checked source carriers. -/
theorem first_input_values (leaves : Leaves code env.weights)
    (E : List (RNode Int InKey)) (cert : List Nat)
    (hc : inputCarriersMatch E cert firstInputs = true) :
    InputsHeld M K (firstStepEnv M K env table) (firstFfiGraph table) E cert := by
  apply inputsHeld_initial M K parameterChoice promptCarrier (firstValues M K env table)
    (firstStepEnv M K env table) (firstFfiGraph table) E cert empty_input_caches
  · exact first_parameter_value M K env table leaves
  · exact initial_input_values (firstValues M K env table) (promptIds 9707)
  · exact prompt_value M K (firstStepEnv M K env table) table
  · exact hc

end Host.Load.Run.Full
