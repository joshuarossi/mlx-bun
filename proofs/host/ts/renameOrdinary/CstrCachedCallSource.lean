import host.ts.RenameRetainedCstrCachedCallFrontend
import host.ts.renameOrdinary.CstrCachedReturnCuts
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CstrCachedCallSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_cstr_cached_call P.F, CstrCachedStates.Body.s0 using CstrCachedStates.Body.S0
  to CstrCachedStates.Return.s4 using CstrCachedStates.Return.S4 as Source8275

host_retained_theorem cached_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Source8275.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Source8275.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source8275.input s)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.str Source8275.sourceKey])
    (budget : s.next+4 ≤ 2^64) => by
  host_retained_chain P.F, [Source8275.retained_transport] using h, inventory, inst
host_assert_retained_schema cached_call, 29

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema cached_call, 30

noncomputable def changedFunction : St LSt := Source8275.input.setObj Source8275.sourceAddress
  {Source8275.sourceClosure with kind := .fn (.closure
    (.mk (some chars!"cstr") [.id chars!"s"] none (.block []) false false []) Source8275.sourceEnv false .undef)}

open Lean Elab Command in
run_cmd do
  for (name,input,endpoint) in [
      ("WrongEndpoint","Source8275.input","Source8275.input"),
      ("WrongResult","Source8275.input","{Source8275.output with ctl := .ret .undef}"),
      ("ChangedFunction","changedFunction","Source8275.output")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_cstr_cached_call P.F, ({input}) using CstrCachedStates.Body.S0 to ({endpoint}) using CstrCachedStates.Return.S4 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect cached cstr source/body/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.CstrCachedCallSource
