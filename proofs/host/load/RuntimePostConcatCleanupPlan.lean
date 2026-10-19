import host.load.RuntimePostConcatCleanupUnary
import host.ts.RenameRuntimeDriverPrivateOther
import host.ts.RenameStateValuationRebase
import host.ts.RenameLoopVariableNamespace
import host.load.RuntimeBlockPlan
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- The disposed-flag store is one original step. Private-other keeps every
differently named annotation on that wrapper, including its current handle. -/
host_retained_private_store_other P.F, Region.s55 using (Region.S55.substitute LoopVariables.oracleVariables)
  to Region.s56 using (Region.S56.substitute LoopVariables.oracleVariables) as DisposedStore

namespace DisposedStore

noncomputable def handleAt (s : St P.F.S) : Option Val :=
  (s.obj? sourceAddress).bind fun object =>
    match findPriv sourceBrand chars!"handle" object.priv with
    | some (.data value _ _) => some value
    | _ => none

theorem source_flag : sourceName = chars!"disposed" := by host_kernel_rfl
theorem source_value : sourceValue = .bool true := by host_kernel_rfl
theorem source_owner : sourceAddress = 2978923 := by host_kernel_rfl
theorem handle_before : handleAt input = some (.big (Int.ofNat 25732)) := by host_kernel_rfl
theorem handle_after : handleAt output = some (.big (Int.ofNat 25732)) := by host_kernel_rfl
theorem native_preserved : output.ffi = input.ffi := by host_kernel_rfl
theorem counter_preserved : output.next = input.next := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_flag : sourceName = chars!\"handle\" := by host_kernel_rfl",
      "theorem wrong_value : sourceValue = .bool false := by host_kernel_rfl",
      "theorem wrong_handle : handleAt output = some (.big 29372) := by host_kernel_rfl",
      "host_retained_private_store_other P.F, Region.s55 using (Region.S55.substitute LoopVariables.oracleVariables) to Region.s57 using (Region.S57.substitute LoopVariables.oracleVariables) as WrongEndpoint"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "disposed-store negative did not reach the intended kernel rejection: {claim}"

end DisposedStore

-- Local rules cover logical not at 23 and 27, and the null if-test at 32.
-- Summaries cannot cross those steps.
host_source_linear_plan_subst P.F, Region from 0 plan_steps 23
  substitute LoopVariables.oracleVariables as Before
host_source_linear_plan_subst P.F, Region from 24 plan_steps 3
  substitute LoopVariables.oracleVariables as Mid
host_source_linear_plan_subst P.F, Region from 28 plan_steps 4
  substitute LoopVariables.oracleVariables as AfterA
host_source_linear_plan_subst P.F, Region from 33 plan_steps 44
  substitute LoopVariables.oracleVariables as AfterB

theorem segment_lengths :
    Before.sourceSteps = 23 ∧ Mid.sourceSteps = 3 ∧ AfterA.sourceSteps = 4 ∧ AfterB.sourceSteps = 44 := by
  decide +kernel

/-- Steps before the empty dispose call, then that call, then the body through
the handle argument. The disposed-flag write keeps the current handle note. -/
noncomputable def ToCall.rules :=
  Before.rules ++ [``UnaryEntry.retained_transport] ++ Mid.rules ++ [``UnaryObject.retained_transport]
    ++ AfterA.rules ++ [``NullIf.retained_transport]
    ++ (AfterB.rules.zip AfterB.starts).filterMap fun entry => if entry.2 < 41 then some entry.1 else none

noncomputable def DisposeCall.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry => if entry.2 = 41 then some entry.1 else none

noncomputable def AfterDispose.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if entry.2 ≤ 41 then none
    else some (if entry.2 = 55 then ``DisposedStore.retained_transport else entry.1)

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let beforePairs ← do
    let starts ← unsafe evalConst (List Nat) ``Before.starts
    let spans ← unsafe evalConst (List Nat) ``Before.spans
    pure (starts.zip spans)
  let midPairs ← do
    let starts ← unsafe evalConst (List Nat) ``Mid.starts
    let spans ← unsafe evalConst (List Nat) ``Mid.spans
    pure (starts.zip spans)
  let earlyPairs ← do
    let starts ← unsafe evalConst (List Nat) ``AfterA.starts
    let spans ← unsafe evalConst (List Nat) ``AfterA.spans
    pure (starts.zip spans)
  let lateStarts ← unsafe evalConst (List Nat) ``AfterB.starts
  let lateSpans ← unsafe evalConst (List Nat) ``AfterB.spans
  let late := lateStarts.zip lateSpans
  logInfo m!"before={beforePairs} mid={midPairs} early={earlyPairs} late={late}"
  unless late.any (fun pair => pair.1 = 41 && pair.2 = 1) do
    throwError "dispose call was absorbed into another source block: {late}"
  unless late.any (fun pair => pair.1 = 55 && pair.2 = 1) do
    throwError "disposed-flag store was absorbed into another source block: {late}"

theorem transport_steps :
    Before.spans.sum + 1 + Mid.spans.sum + 1 + AfterA.spans.sum + 1 + AfterB.spans.sum = 77 := by
  decide +kernel

theorem dispose_call_is_one_step :
    ((AfterB.spans.zip AfterB.starts).filterMap fun entry =>
      if entry.2 = 41 then some entry.1 else none) = [1] := by
  decide +kernel

theorem disposed_store_is_one_step :
    ((AfterB.spans.zip AfterB.starts).filterMap fun entry =>
      if entry.2 = 55 then some entry.1 else none) = [1] := by
  decide +kernel

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
