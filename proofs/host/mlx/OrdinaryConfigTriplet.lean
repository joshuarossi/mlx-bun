import host.mlx.NativeConfigTripletFrontend
import host.mlx.OrdinaryConfigTripletStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigTripletCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_configTriplet P.F, ConfigTripletStates.gridEntry.1 using ConfigTripletStates.gridEntry.2
  to ConfigTripletStates.gridAfter.1 using ConfigTripletStates.gridAfter.2 as Grid4794
host_retained_configTriplet P.F, ConfigTripletStates.groupEntry.1 using ConfigTripletStates.groupEntry.2
  to ConfigTripletStates.groupAfter.1 using ConfigTripletStates.groupAfter.2 as Group4827

theorem grid_operation : Grid4794.sourceOp = .grid := by host_kernel_rfl
theorem group_operation : Group4827.sourceOp = .group := by host_kernel_rfl
theorem grid_handle : Grid4794.sourceHandle = 29386 := by host_kernel_rfl
theorem group_handle : Group4827.sourceHandle = 29386 := by host_kernel_rfl
theorem grid_dimensions : [Grid4794.sourceX,Grid4794.sourceY,Grid4794.sourceZ] =
    [F64.ofNat 32,F64.ofNat 128,F64.ofNat 48] := by host_kernel_rfl
theorem group_dimensions : [Group4827.sourceX,Group4827.sourceY,Group4827.sourceZ] =
    [F64.ofNat 32,F64.ofNat 4,F64.ofNat 1] := by host_kernel_rfl

host_retained_theorem selected_grid := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Grid4794.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Grid4794.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Grid4794.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Grid4794.sourceTypes) (handleLive : H Grid4794.sourceHandle)
    (configRole : Config) (objectRole : objects Grid4794.sourceHandle = .config configRole)
    (fnRole thisRole : Annotated.Value) (ex ey ez : SymE)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle Grid4794.sourceHandle,.literal ex,.literal ey,.literal ez])
    (targetBound : R.handle Grid4794.sourceHandle < 2^64) => by
  host_retained_chain P.F, [Grid4794.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_grid, 1

host_retained_theorem selected_group := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Group4827.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Group4827.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Group4827.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Group4827.sourceTypes) (handleLive : H Group4827.sourceHandle)
    (configRole : Config) (objectRole : objects Group4827.sourceHandle = .config configRole)
    (fnRole thisRole : Annotated.Value) (ex ey ez : SymE)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle Group4827.sourceHandle,.literal ex,.literal ey,.literal ez])
    (targetBound : R.handle Group4827.sourceHandle < 2^64) => by
  host_retained_chain P.F, [Group4827.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_group, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_grid, 2

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_group, 2

open Lean Elab Command in
run_cmd do
  for (name,input,output,server,next) in [
      ("WrongGridEndpoint","Grid4794.input","Grid4794.input","ConfigTripletStates.gridEntry.2","ConfigTripletStates.gridAfter.2"),
      ("WrongGroupEndpoint","Group4827.input","Group4827.input","ConfigTripletStates.groupEntry.2","ConfigTripletStates.groupAfter.2"),
      ("WrongGridResult","Grid4794.input","{Grid4794.output with ctl := .ret .undef}","ConfigTripletStates.gridEntry.2","ConfigTripletStates.gridAfter.2")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configTriplet P.F, {input} using {server} to ({output}) using {next} as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration triplet endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigTripletCases
