import host.mlx.NativeUnaryFrontend
import host.mlx.OrdinarySigmoidCut
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.UnarySource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_unary P.F, SigmoidCall.input using P.RestStream.micro0.micro33.S28
  to SigmoidCall.output using P.RestStream.micro0.micro33.S29 as Source3328

theorem source_symbol : Source3328.symbol = chars!"mlx_sigmoid" := by host_kernel_rfl
theorem source_input_producer : Source3328.producer = 22585 := by host_kernel_rfl
theorem source_output_producer : Source3328.input.ffi.mlx.nnext = 22594 := by host_kernel_rfl
theorem source_output_handle : Source3328.input.ffi.mlx.next = 29381 := by host_kernel_rfl

host_retained_theorem selected_sigmoid := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source3328.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' Source3328.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source3328.input s)
    (policy : ProducerAnnotations roots H N roles objects)
    (signatureFrame : ¬ framed Source3328.types) (handleLive : H Source3328.handle)
    (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.ptr (.js Source3328.out) 0,.handle Source3328.handle,.handle Source3328.stream])
    (slotNote : notes.buffers.owners Source3328.out = some (handleSlotNotes 0)) => by
  host_retained_chain P.F, [Source3328.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_sigmoid, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_sigmoid, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","SigmoidCall.input"),
      ("WrongResult","{SigmoidCall.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_unary P.F, SigmoidCall.input using P.RestStream.micro0.micro33.S28 to ({endpoint}) using P.RestStream.micro0.micro33.S29 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect unary endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.UnarySource
