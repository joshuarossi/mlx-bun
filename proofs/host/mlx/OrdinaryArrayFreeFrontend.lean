import host.mlx.NativeArrayFreeFrontend
import host.mlx.OrdinaryArrayFreeCut
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.ArrayFreeCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_arrayFree P.F, ArrayFreeCall.input using P.RestStream.micro0.micro19.S78
  to ArrayFreeCall.output using P.RestStream.micro0.micro19.S79 as Source1978

theorem selected_handle : Source1978.handle = 29372 := by host_kernel_rfl

host_retained_theorem selected_disposal := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source1978.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Source1978.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source1978.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Source1978.types) (handleLive : H Source1978.handle)
    (targetBound : s.ffi.mlx.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (note : notes.runtime.control = callNote fnRole thisRole [.handle Source1978.handle]) => by
  host_retained_chain P.F, [Source1978.retained_transport] using h, inventory, inst

host_assert_retained_schema selected_disposal, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_disposal, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source1978.input"),
      ("WrongResult","{Source1978.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_arrayFree P.F, Source1978.input using P.RestStream.micro0.micro19.S78 to ({endpoint}) using P.RestStream.micro0.micro19.S79 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect array-free endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ArrayFreeCases
