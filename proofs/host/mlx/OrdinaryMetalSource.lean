import host.mlx.NativeMetalFrontend
import host.mlx.OrdinaryMetalCut
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.MetalSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_metal P.F, MetalCall.input using P.RestStream.micro0.micro57.S60
  to MetalCall.output using P.RestStream.micro0.micro57.S61 as Source5760

theorem source_kernel_handle : Source5760.kernel = 18215 := by host_kernel_rfl
theorem source_output_slot : Source5760.slot = 29388 := by host_kernel_rfl
theorem source_output_ids :
    (MetalFamilyHost.result Source5760.input.ffi Source5760.kernel Source5760.sourceInputs Source5760.sourceConfig).2 =
      [22603,22604] := by host_kernel_rfl

host_retained_theorem selected_application := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source5760.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' Source5760.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source5760.input s)
    (policy : ProducerAnnotations roots H N roles objects)
    (signatureFrame : ¬ framed Source5760.types)
    (kernelLive : H Source5760.kernel) (inputsLive : H Source5760.inputs)
    (configLive : H Source5760.config) (slotLive : H Source5760.slot)
    (configRole : Config) (objectRole : objects Source5760.config = .config configRole)
    (targetNodes : s.ffi.mlx.nnext + configRole.outs.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      ((MetalFamilyHost.arguments Source5760.out Source5760.kernel Source5760.inputs Source5760.config Source5760.stream).map FixedArgument.role))
    (slotNote : notes.buffers.owners Source5760.out = some (handleSlotNotes Source5760.slot)) => by
  host_retained_chain P.F, [Source5760.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_application, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_application, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","MetalCall.input"),
      ("WrongResult","{MetalCall.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_metal P.F, MetalCall.input using P.RestStream.micro0.micro57.S60 to ({endpoint}) using P.RestStream.micro0.micro57.S61 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect Metal application endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.MetalSource
