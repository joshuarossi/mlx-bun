import host.mlx.NativeConfigFreeFrontend
import host.mlx.OrdinaryConfigFreeStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigFreeCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_configFree P.F, ConfigFreeStates.entry.1 using ConfigFreeStates.entry.2
  to ConfigFreeStates.after.1 using ConfigFreeStates.after.2 as Source6103

theorem selected_handle : Source6103.handle = 29386 := by host_kernel_rfl

host_retained_theorem selected_disposal := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → LSt → LSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source6103.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Source6103.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source6103.input s)
    (signatureFrame : ¬ framed Source6103.types) (fnRole thisRole : Annotated.Value)
    (note : notes.runtime.control = callNote fnRole thisRole [.handle Source6103.handle]) => by
  host_retained_chain P.F, [Source6103.retained_transport] using h, inventory, inst

host_assert_retained_schema selected_disposal, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_disposal, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source6103.input"),
      ("WrongResult","{Source6103.output with ctl := .ret (.bool true)}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configFree P.F, Source6103.input using ConfigFreeStates.entry.2 to ({endpoint}) using ConfigFreeStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration disposal endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigFreeCases
