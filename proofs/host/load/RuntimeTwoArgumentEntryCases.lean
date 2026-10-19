import host.ts.RenameRetainedTwoArgumentEntryFrontend
import host.ts.RenameRetainedChain
import host.ts.ast.mlx.Ffi
import host.mlx.OrdinaryVectorStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.TwoArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_two_argument_entry Host.Load.Run.Full.P.F, Host.Load.Run.Full.P.RestStream.micro0.micro2.s67 using Host.Load.Run.Full.P.RestStream.micro0.micro2.S67
  to Host.Load.Run.Full.P.RestStream.micro0.micro2.s73 using Host.Load.Run.Full.P.RestStream.micro0.micro2.S73 as OutArray267

theorem source_function : OutArray267.sourceFunction = Host.Ts.Sources.Mlx.Ffi.ast_n54 := by host_kernel_rfl

host_retained_theorem out_array_267 := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Host.Load.Run.Full.P.F.S → Host.Load.Run.Full.P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.Run.Full.P.F.S)
    (inst : Inst ν₀ OutArray267.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' OutArray267.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live OutArray267.input s)
    (firstRole secondRole fnRole thisRole : Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole [firstRole,secondRole])
    (bound : s.next+4+(blockNames OutArray267.sourceBody).length ≤ 2^64) => by
  host_retained_chain Host.Load.Run.Full.P.F, [OutArray267.retained_transport] using h, inventory, inst
host_assert_retained_schema out_array_267, 6
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema out_array_267, 7

open Lean Elab Command in
run_cmd do
  for claim in [
      "host_retained_two_argument_entry Host.Load.Run.Full.P.F, Host.Load.Run.Full.P.RestStream.micro0.micro2.s67 using Host.Load.Run.Full.P.RestStream.micro0.micro2.S67 to Host.Load.Run.Full.P.RestStream.micro0.micro2.s74 using Host.Load.Run.Full.P.RestStream.micro0.micro2.S74 as RejectEndpoint274",
      "theorem swapped_role : OutArray267.output.heap.get (OutArray267.input.next+1) = some (.cell (some OutArray267.sourceSecond)) := by host_kernel_rfl",
      "theorem mutated_body : OutArray267.sourceObject.kind = .fn (.closure (twoParameterFunction OutArray267.sourceName OutArray267.firstName OutArray267.secondName []) OutArray267.sourceEnv false .undef) := by host_kernel_rfl"] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "actual two-argument negative was not rejected by the kernel: {claim}"

end Host.Load.Run.Full.Ordinary.TwoArgumentEntry
