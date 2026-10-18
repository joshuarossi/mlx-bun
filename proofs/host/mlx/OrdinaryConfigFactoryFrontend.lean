import host.mlx.NativeConfigFactoryFrontend
import host.mlx.OrdinaryConfigFactoryStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigFactoryCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_configNew P.F, ConfigFactoryStates.entry.1 using ConfigFactoryStates.entry.2
  to ConfigFactoryStates.after.1 using ConfigFactoryStates.after.2 as Source4584

theorem created_handle : Source4584.input.ffi.mlx.next = 29386 := by host_kernel_rfl

host_retained_theorem selected_constructor := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source4584.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Source4584.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source4584.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Source4584.sourceTypes) (targetBound : s.ffi.mlx.next < 2^64) => by
  host_retained_chain P.F, [Source4584.retained_transport] using h, inventory, inst

host_assert_retained_schema selected_constructor, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_constructor, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source4584.input"),
      ("WrongResult","{Source4584.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configNew P.F, Source4584.input using ConfigFactoryStates.entry.2 to ({endpoint}) using ConfigFactoryStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration constructor endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigFactoryCases
