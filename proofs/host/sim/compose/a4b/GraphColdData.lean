import host.sim.compose.a4b.GraphColdCandidateNodes
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Load _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

/-! Existing chooseD supplies untrusted carriers. No proof uses its evaluation. -/
set_option interpreter.prefer_native false in
ffi_value_literal choice.cert : (chooseD candidateNodes fullExpected.1 candidateInputs N0).toOption.getD []
set_option interpreter.prefer_native false in
ffi_value_literal choice.message : match chooseD candidateNodes fullExpected.1 candidateInputs N0 with
  | .ok _ => "all4020 carriers selected"
  | .error e => e
#reduce choice.message
set_option interpreter.prefer_native false in
ffi_value_literal choice.inputs : (fullExpected.1.zip choice.cert).filterMap fun (n,c) =>
  match n.prim with | .input key => some (key,c) | _ => none
set_option interpreter.prefer_native false in
ffi_value_literal choice.outputs : candidateOutputs

def insT : InKey → Option Nat := inputsOf choice.inputs
kernel_rfl candidate_length : choice.cert.length = 4020
end Host.Ts.Sim.Compose.ColdGraph
