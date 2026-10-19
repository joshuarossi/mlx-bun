import host.load.RuntimePostCachedReturn

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- These are facts of the current source entry, not desired target facts. They
check the provenance of each additional entry annotation required by the host
prefix. The cached-call adapter supplies the zero-status and output-slot roles. -/
theorem entry_pointer_value : cellValueAt From2383.s0 3126903 = .ptr (.js 3126924) 0 := by host_kernel_rfl
theorem entry_vector_value : cellValueAt From2383.s0 3126901 = .big 29376 := by host_kernel_rfl
theorem entry_buffer_kind : (From2383.s0.obj? 3126924).map Host.Ts.Obj.kind = some (.buf (cellParts .u64 (.big 29377) 8 0)) := by host_kernel_rfl
theorem entry_status_value : From2383.s0.ctl = .ret (.num zeroN) := by host_kernel_rfl

theorem exact_interval_length :
    BeforeFree.sourceSteps + 1 + BeforeSize.sourceSteps + 1 + AfterSize.sourceSteps = 64 := by decide +kernel

theorem final_server : AfterSize.Block17.nextServer =
    numberServer ((P.RestStream.micro0.micro24.S47).substitute LoopVariables.oracleVariables) := by host_kernel_rfl

host_assert_retained_schema retained_run64, 64
host_assert_retained_schema retained_through_vector_size, 64

/- Inspect the exported proposition, including the original entry/exit and
all six inventories, rather than accepting compilation as a statement check. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  for name in [``retained_run64,``retained_through_vector_size] do
    let info ← getConstInfo name
    forallTelescope info.type fun arguments conclusion => do
      let mut incoming? : Option Lean.Expr := none
      for argument in arguments do
        if (← inferType argument).getAppFn.isConstOf ``Parametric.StateR then
          incoming? := some argument
      let some incoming := incoming? | throwError "missing arbitrary entry relation"
      let incomingType ← inferType incoming
      let entry := incomingType.getAppArgs[incomingType.getAppArgs.size-2]!
      unless ← isDefEq entry (mkConst ``P.RestStream.micro0.micro23.s83) do
        throwError "wrong original entry: {entry}"
      let conclusion ← whnf conclusion
      unless conclusion.isAppOfArity ``Exists 2 do throwError "missing existential reached state"
      lambdaTelescope conclusion.getAppArgs[1]! fun _ body => do
        let rec find (p : Lean.Expr) (head : Lean.Name) : MetaM Lean.Expr := do
          if p.getAppFn.isConstOf head then return p
          if p.isAppOfArity ``And 2 then
            try find p.getAppArgs[0]! head catch _ => find p.getAppArgs[1]! head
          else throwError "missing {head}"
        let state ← find body ``Parametric.StateR
        let inventory ← find body ``RetainedInventory
        for field in [state,inventory] do
          let endpoint := field.getAppArgs[field.getAppArgs.size-2]!
          unless ← isDefEq endpoint (mkConst ``P.RestStream.micro0.micro24.s47) do
            throwError "wrong original endpoint: {endpoint}"
        let inst ← find body ``Inst
        unless ← isDefEq inst.getAppArgs[1]! (mkConst ``AfterSize.Block17.nextServer) do
          throwError "wrong final namespaced numeric server"
        if name == ``retained_through_vector_size then
          unless state.getUsedConstants.contains ``releasedHandles do
            throwError "native relation did not remove the released vector"
          let _ ← find body ``Host.Mlx.Ffi.Annotated.ProducerAnnotations
          let _ ← find body ``Host.Mlx.Ffi.NativeRoles.ProducerSupport
  logInfo "Post-cached statement and original endpoints checked"

/- Every rejected command restores the complete command state, including its
kernel environment and messages. Check the intended diagnostic, not any error. -/
open Lean Elab Command in
run_cmd do
  for claim in [
      "host_assert_retained_schema retained_through_vector_size, 63",
      "host_assert_retained_schema retained_through_vector_size, 65",
      "theorem WrongFinalBefore : From2429.s18 = P.RestStream.micro0.micro24.s46 := by host_kernel_rfl",
      "theorem WrongFinalAfter : From2429.s18 = P.RestStream.micro0.micro24.s48 := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    let mut seen := ""
    try
      Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      let text ← exception.toMessageData.toString
      seen := text
      rejected := (text.splitOn "retained batch schema: target run has the wrong step count").length > 1
        || (text.splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      let text ← message.data.toString
      seen := seen ++ text
      if (text.splitOn "retained batch schema: target run has the wrong step count").length > 1
          || (text.splitOn "(kernel) declaration type mismatch").length > 1 then
        rejected := true
    set saved
    unless rejected do throwError "post-cached negative did not reach the intended rejection: {claim}\n{seen}"
  let scopeName ← getCurrNamespace
  for name in [scopeName ++ `WrongFinalBefore,scopeName ++ `WrongFinalAfter] do
    if (← getEnv).contains name then throwError "negative command leaked a declaration"
  logInfo "Post-cached wrong counts/endpoints rejected with complete rollback"

end Host.Load.Run.Full.Ordinary.PostCachedReturn
