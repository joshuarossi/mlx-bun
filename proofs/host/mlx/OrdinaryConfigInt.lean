import host.mlx.NativeConfigIntFrontend
import host.mlx.OrdinaryConfigIntStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigIntCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_configInt P.F, ConfigIntStates.entry.1 using ConfigIntStates.entry.2
  to ConfigIntStates.after.1 using ConfigIntStates.after.2 as Source5029

theorem source_handle : Source5029.sourceHandle = 29386 := by host_kernel_rfl
theorem source_argument : Source5029.sourceValue = F64.ofNat 128 := by host_kernel_rfl

host_retained_theorem selected_setter := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source5029.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Source5029.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source5029.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Source5029.sourceTypes) (handleLive : H Source5029.sourceHandle)
    (configRole : Config) (objectRole : objects Source5029.sourceHandle = .config configRole)
    (fnRole thisRole : Annotated.Value) (meaning : SymE)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [.handle Source5029.sourceHandle,.ptr (.js Source5029.sourceBuffer) 0,.literal meaning])
    (targetBound : R.handle Source5029.sourceHandle < 2^64) => by
  host_retained_chain P.F, [Source5029.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_setter, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_setter, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source5029.input"),
      ("WrongResult","{Source5029.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configInt P.F, Source5029.input using ConfigIntStates.entry.2 to ({endpoint}) using ConfigIntStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration setter endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigIntCases
