import host.mlx.NativeBinaryFrontend
import host.mlx.OrdinaryBinaryStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.BinarySource
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_binary P.F, BinaryStates.addEntry.1 using BinaryStates.addEntry.2
  to BinaryStates.addAfter.1 using BinaryStates.addAfter.2 as Source15873
host_retained_binary P.F, BinaryStates.multiplyEntry.1 using BinaryStates.multiplyEntry.2
  to BinaryStates.multiplyAfter.1 using BinaryStates.multiplyAfter.2 as Source52226

theorem add_symbol : Source15873.symbol = chars!"mlx_add" := by host_kernel_rfl
theorem multiply_symbol : Source52226.symbol = chars!"mlx_multiply" := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for (name,source) in [("selected_add","Source15873"),("selected_multiply","Source52226")] do
    Parametric.Driver.emit s!"host_retained_theorem {name} := fun
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
      (roots H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
      (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
      (inst : Inst ν₀ {source}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
        R live framed before after old old' {source}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {source}.input s)
      (policy : ProducerAnnotations roots H N roles objects)
      (signatureFrame : ¬ framed {source}.types) (handlesLive : listSupport H [{source}.hx,{source}.hy])
      (output : Shape) (layout : BinaryLayout (roles {source}.x).shape (roles {source}.y).shape output)
      (targetNodes : s.ffi.mlx.nnext < 2^64) (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64)
      (fnRole thisRole : Annotated.Value)
      (controlNote : notes.runtime.control = callNote fnRole thisRole
        [.ptr (.js {source}.out) 0,.handle {source}.hx,.handle {source}.hy,.handle {source}.stream])
      (slotNote : notes.buffers.owners {source}.out = some (handleSlotNotes 0)) => by
      host_retained_chain P.F, [{source}.retained_transport] using h, inventory, inst"
host_assert_retained_schema selected_add, 1
host_assert_retained_schema selected_multiply, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_add, 2
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_multiply, 2

open Lean Elab Command in
run_cmd do
  for (name,source,initial,next,endpoint) in [
      ("WrongAddEndpoint","Source15873","BinaryStates.addEntry.2","BinaryStates.addAfter.2","Source15873.input"),
      ("WrongMultiplyEndpoint","Source52226","BinaryStates.multiplyEntry.2","BinaryStates.multiplyAfter.2","Source52226.input"),
      ("WrongResult","Source15873","BinaryStates.addEntry.2","BinaryStates.addAfter.2","{Source15873.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_binary P.F, {source}.input using {initial} to ({endpoint}) using {next} as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect binary endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.BinarySource
