import host.ts.RenameRuntimeRetain
import host.ts.RenameRuntimeDriverTest
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.RuntimeDriver

/- The source allocates a fresh numeric reference and the target folds to a
literal. All six retained inventories follow their independent table extensions. -/
host_retain_runtime Reference.runtime_transport using
  (PureRuntimeCase.arithmetic h Reference.kind Reference.sourceLeft Reference.sourceRight
    Reference.sourceTail Reference.source_control Reference.source_stack)
  as retained_reference

/-- error: host_retain_runtime: expected a paired PureRuntimeCase proof -/
#guard_msgs in
host_retain_runtime Reference.runtime_transport using True.intro as rejected_effect

open Lean Elab Command in
run_cmd do
  if (← getEnv).contains ((← getCurrNamespace) ++ `rejected_effect) then
    throwError "rejected effect proof produced a retained theorem"

end Host.Ts.Owned.Annotated.Tests.RuntimeDriver
