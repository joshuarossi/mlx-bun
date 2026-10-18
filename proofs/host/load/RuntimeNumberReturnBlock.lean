import host.load.RuntimeNamespacedDecodeCuts1220
import host.mlx.NativeNumberReturnFrontend
import host.ts.RenameRetainedChain
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode.NumberReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_number_return P.F, From1220.s0 using (From1220.S0.substitute LoopVariables.oracleVariables)
  to From1220.s6 using (From1220.S6.substitute LoopVariables.oracleVariables) as Rank1220

host_retained_theorem rank_return := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Rank1220.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Rank1220.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Rank1220.input s)
    (meaning : SymE) (role fnRole thisRole : Annotated.Value) (schema : IntegerNumberRole role meaning)
    (retNote blockNote scopeNote boundaryNote : Annotated.Tree) (callerNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = argumentFrameNote false 0 fnRole thisRole [] [] Rank1220.sourceArgEnv ::
      retNote::blockNote::scopeNote::boundaryNote::callerNotes) => by
  host_retained_chain P.F, [Rank1220.retained_transport] using h, inventory, inst
host_assert_retained_schema rank_return, 6

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema rank_return, 7

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","From1220.s5"),
      ("WrongResult","{From1220.s6 with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_number_return P.F, From1220.s0 using (From1220.S0.substitute LoopVariables.oracleVariables) to {endpoint} using (From1220.S6.substitute LoopVariables.oracleVariables) as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect Number-return endpoint/result was not rejected by the kernel"
end Host.Load.Run.Full.Ordinary.NamespacedDecode.NumberReturn
