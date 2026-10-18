import host.mlx.NativeConfigOutputFrontend
import host.mlx.OrdinaryConfigOutputStates
import host.ts.RenameRetainedChain

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.ConfigOutputCases
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

host_retained_configOutput P.F, ConfigOutputStates.entry.1 using ConfigOutputStates.entry.2
  to ConfigOutputStates.after.1 using ConfigOutputStates.after.2 as Source4694

theorem source_rank : Source4694.sourceIntegers.length = 4 := by host_kernel_rfl
theorem source_dtype : Source4694.sourceDtype = 12 := by host_kernel_rfl

host_retained_theorem selected_output := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (roots H N : Nat → Prop) (tail : List NumV) (host : Host.Load.HostSt → Host.Load.HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (inst : Inst ν₀ Source4694.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' Source4694.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Source4694.input s)
    (policy : ProducerAnnotations roots H N nodes objects)
    (signatureFrame : ¬ framed Source4694.sourceTypes) (handleLive : H Source4694.sourceHandle)
    (configRole : Config) (objectRole : objects Source4694.sourceHandle = .config configRole)
    (expressions : List SymE) (integers : List Int)
    (sourceDimensions : LiteralDimensions ν₀ (expressions.map Dimension.literal) Source4694.sourceIntegers)
    (targetDimensions : LiteralDimensions ν (expressions.map Dimension.literal) integers)
    (fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole
      [.handle Source4694.sourceHandle,.ptr (.js Source4694.sourceBuffer) 0,
        .ordinaryBig (Int.ofNat Source4694.sourceIntegers.length),.literal (.lit Source4694.sourceValue)])
    (selected : notes.buffers.owners Source4694.sourceBuffer = some (literalShapeByteNotes expressions))
    (targetBound : R.handle Source4694.sourceHandle < 2^64) => by
  host_retained_chain P.F, [Source4694.retained_transport] using h, inventory, inst

host_assert_retained_schema selected_output, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema selected_output, 2

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","Source4694.input"),
      ("WrongResult","{Source4694.output with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_configOutput P.F, Source4694.input using ConfigOutputStates.entry.2 to ({endpoint}) using ConfigOutputStates.after.2 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect configuration output endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.ConfigOutputCases
