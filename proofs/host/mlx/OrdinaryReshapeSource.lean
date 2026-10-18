import host.mlx.NativeReshapeFrontend
import host.mlx.OrdinaryReshapeStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ReshapeSource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_reshape P.F, ReshapeStates.entry.1 using ReshapeStates.entry.2
  to ReshapeStates.after.1 using ReshapeStates.after.2 as Source7501

theorem input_dimensions : Source7501.inputSizes = [1,1,48,128] := by host_kernel_rfl
theorem output_dimensions : Source7501.request = [1,1,6144] := by host_kernel_rfl

host_retained_theorem selected_reshape := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source7501.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' Source7501.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source7501.input s)
    (policy : ProducerAnnotations roots H N roles objects)
    (signatureFrame : ¬ framed Source7501.types) (handleLive : H Source7501.handle)
    (closedInput : closedLiteralShape (roles Source7501.producer).shape = true)
    (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
    (fnRole thisRole countRole : Annotated.Value) (countSchema : FixedIntegerRole countRole (Int.ofNat Source7501.request.length))
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.ptr (.js Source7501.out) 0,.handle Source7501.handle,.ptr (.js Source7501.shapeBuffer) 0,countRole,.handle Source7501.stream])
    (slotNote : notes.buffers.owners Source7501.out = some (handleSlotNotes 0))
    (expressions : List SymE) (shapeNote : notes.buffers.owners Source7501.shapeBuffer = some (literalShapeByteNotes expressions))
    (closedShape : expressions.all SymE.closed = true) => by
  host_retained_chain P.F, [Source7501.retained_transport] using h, inventory, inst
host_assert_retained_schema selected_reshape, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_reshape, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source7501.input"),
      ("WrongResult","{Source7501.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_reshape P.F, Source7501.input using ReshapeStates.entry.2 to ({endpoint}) using ReshapeStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect reshape endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ReshapeSource
