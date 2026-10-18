import host.ts.RenameRuntimeDriverStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command

/- Diagnostic constructor eligibility only. Conditions within a family still
require the actual source layouts and retained inventory to pass the rule. -/
def runtimeCensusTags : Array String := #[
  "ev.Expr.0","ev.Expr.1","ev.Expr.10","ev.Expr.12","ev.Expr.13","ev.Expr.14","ev.Expr.15",
  "ev.Expr.18","ev.Expr.19","ev.Expr.20","ev.Expr.22","ev.Expr.23","ev.Expr.24",
  "ret.ExprF.1","ret.ExprF.2","ret.CallF.0","ret.CallF.5","ret.CallF.6","ret.CallF.8",
  "ret.StmtF.0","ret.StmtF.1","ret.StmtF.4","ret.StmtF.6","ret.FnF.0","abr.1",
  "bind.Pat.0.Mode.0","ex.Stmt.0","ex.Stmt.1","ex.Stmt.2","ex.Stmt.5","ex.Stmt.6",
  "ex.Stmt.9","ex.Stmt.11","ex.Stmt.12","ex.Stmt.15","ex.Stmt.16","ex.Stmt.17","ex.Stmt.19"]

/-- Probe imported source snapshots without running the source interpreter to
choose new states. Each selected frontend is checked in a temporary environment;
the probe reports only diagnostic readiness, not an execution theorem. -/
elab "host_runtime_probe " f:term ", " base:ident " from " start:num " probe_steps " limit:num : command => do
  let some fText := f.raw.reprint | throwError "host_runtime_probe: cannot print Ffi argument"
  let start := start.getNat
  let limit := limit.getNat
  let base := base.getId.toString
  let mut checked : Nat := 0
  let mut failure : Option (Nat × String) := none
  for index in List.range limit do
    let index := start+index
    let saved : Command.State ← get
    let probeName := "RuntimeProbe" ++ toString index
    let mut issue : Option String := none
    try
      Parametric.Driver.emit s!"host_runtime_step {fText}, {base}.s{index} using {base}.S{index} to {base}.s{index+1} using {base}.S{index+1} as {probeName}"
    catch exception => issue := some (← exception.toMessageData.toString)
    if (← get).messages.hasErrors && issue.isNone then
      for message in (← get).messages.toList do
        if message.severity == .error && issue.isNone then issue := some (← message.data.toString)
    let generated := (← getCurrNamespace) ++ Name.mkSimple probeName ++ `runtime_transport
    if !(← getEnv).contains generated && issue.isNone then issue := some "no checked transport declaration was generated"
    set saved
    if let some reason := issue then
      failure := some (index,reason)
      break
    checked := checked+1
  match failure with
  | some (index,reason) => logInfo m!"Runtime source probe: {checked} checked frontend instances; first unsupported source index {index}: {reason}"
  | none => logInfo m!"Runtime source probe: all {checked} selected frontend instances checked; retained entry premises remain to be discharged"

/-- Summarize the saved whole-route census without executing the source again.
Counts describe constructor-family eligibility, including guarded subcases. -/
elab "host_runtime_census " file:str : command => do
  let contents ← IO.FS.readFile file.getString
  let .ok json := Json.parse contents | throwError "host_runtime_census: invalid JSON"
  let .ok entries := json.getObjValAs? (Array Json) "cases" | throwError "host_runtime_census: missing cases"
  let .ok fuel := json.getObjValAs? Nat "fuel" | throwError "host_runtime_census: missing fuel"
  let mut eligibleTags : Nat := 0
  let mut eligibleSteps : Nat := 0
  let mut missing : Option (Nat × String) := none
  for entry in entries do
    let .ok tag := entry.getObjValAs? String "case" | throwError "host_runtime_census: invalid case tag"
    let .ok count := entry.getObjValAs? Nat "count" | throwError "host_runtime_census: invalid case count"
    let .ok first := entry.getObjValAs? Nat "first" | throwError "host_runtime_census: invalid first index"
    if runtimeCensusTags.contains tag then
      eligibleTags := eligibleTags+1
      eligibleSteps := eligibleSteps+count
    else if missing.isNone || first < missing.get!.1 then missing := some (first,tag)
  logInfo m!"Runtime census diagnostic: {eligibleTags}/{entries.size} constructor tags eligible; {eligibleSteps}/{fuel} occurrences in those families (guarded subcases included; not proved coverage)"
  if let some (index,tag) := missing then logInfo m!"Earliest unregistered constructor family: source index {index}, {tag}"

end Host.Ts.Owned.Annotated.Driver
