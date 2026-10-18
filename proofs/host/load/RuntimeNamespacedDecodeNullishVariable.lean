import host.load.RuntimeNamespacedDecodeNullish
import host.ts.RenameRuntimeDriverNullishVariable
import host.ts.RenameRetainedChain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
host_retained_nullish_variable P.F, Region1100.s79 using
  (Region1100.S79.substitute LoopVariables.oracleVariables) to Region1100.s80 using
  (Region1100.S80.substitute LoopVariables.oracleVariables) as NullishRead1179
host_retained_theorem existing_nullish := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ NullishRead1179.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1100.s79 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region1100.s79 s) => by
  host_retained_chain P.F, [NullishRead1179.retained_transport,Nullish1180.retained_transport] using h, inventory, inst
host_assert_retained_schema existing_nullish, 2

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema existing_nullish, 3

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_nullish_variable P.F, Region1100.s79 using (Region1100.S79.substitute LoopVariables.oracleVariables) to Region1100.s81 using (Region1100.S81.substitute LoopVariables.oracleVariables) as SkippedFrame"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "skipping original assignment frame was not rejected by kernel"
end Host.Load.Run.Full.Ordinary.NamespacedDecode
