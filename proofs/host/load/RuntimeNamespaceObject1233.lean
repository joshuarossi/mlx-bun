import host.load.RuntimeNamespacedDecodeCuts1220
import host.ts.RenameRuntimeDriverNamespaceObject
import host.ts.RenameRetainedChain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.NamespaceObject
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_namespace_object P.F, From1220.s13 using (From1220.S13.substitute LoopVariables.oracleVariables)
  to From1220.s14 using (From1220.S14.substitute LoopVariables.oracleVariables) as SliceDynamic1233

host_retained_theorem export_object := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ SliceDynamic1233.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' SliceDynamic1233.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live SliceDynamic1233.input s)
    (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (stackNotes : notes.runtime.stack = headNote::tailNotes) => by
  host_retained_chain P.F, [SliceDynamic1233.retained_transport] using h, inventory, inst
host_assert_retained_schema export_object, 1
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema export_object, 2

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_namespace_object P.F, From1220.s13 using (From1220.S13.substitute LoopVariables.oracleVariables) to {From1220.s14 with ctl := .ret (.obj 2821)} using (From1220.S14.substitute LoopVariables.oracleVariables) as WrongObject"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect namespace object result was not rejected by the kernel"
end Host.Load.Run.Full.Ordinary.NamespacedDecode.NamespaceObject
