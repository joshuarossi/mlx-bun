import host.mlx.NativeConfigDtypeFrontend
import host.mlx.OrdinaryConfigDtypeStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigDtypeCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_configDtype P.F, ConfigDtypeStates.entry.1 using ConfigDtypeStates.entry.2
  to ConfigDtypeStates.after.1 using ConfigDtypeStates.after.2 as Source4903

theorem source_handle : Source4903.sourceHandle = 29386 := by host_kernel_rfl
theorem source_argument : Source4903.sourceValue = F64.ofNat 12 := by host_kernel_rfl

host_retained_theorem selected_dtype := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source4903.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Source4903.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source4903.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Source4903.sourceTypes) (handleLive : H Source4903.sourceHandle)
    (configRole : Config) (objectRole : objects Source4903.sourceHandle = .config configRole)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle Source4903.sourceHandle,.ptr (.js Source4903.sourceBuffer) 0,.literal (.lit Source4903.sourceValue)])
    (targetBound : R.handle Source4903.sourceHandle < 2^64) => by
  host_retained_chain P.F, [Source4903.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_dtype, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_dtype, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source4903.input"),
      ("WrongResult","{Source4903.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configDtype P.F, Source4903.input using ConfigDtypeStates.entry.2 to ({endpoint}) using ConfigDtypeStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration dtype endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigDtypeCases
