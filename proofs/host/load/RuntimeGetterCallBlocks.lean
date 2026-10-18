import host.ts.RenameRetainedGetterCallFrontend
import host.ts.RenameRetainedChain
import host.ts.renameOrdinary.MapBodyStates
import host.mlx.OrdinaryVectorStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedGetterCalls
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_getter_call P.F, P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26
  to P.RestStream.micro0.micro1.s43 using P.RestStream.micro0.micro1.S43 as First126
host_retained_getter_call P.F, P.RestStream.micro0.micro1.s83 using P.RestStream.micro0.micro1.S83
  to P.RestStream.micro0.micro2.s0 using P.RestStream.micro0.micro2.S0 as Second183

host_retained_theorem first_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First126.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First126.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First126.input s)
    (role : Annotated.Value)
    (controlNote : notes.runtime.control = callNote (.obj First126.sourceGetter) (.obj First126.sourceOwner) [])
    (fieldNote : notes.privates.owners First126.sourceOwner = some ⟨First126.sourceBrand,First126.sourceHandleName,role⟩)
    (budget : s.next+2 ≤ 2^64) => by
  host_retained_chain P.F, [First126.retained_transport] using h, inventory, inst
host_assert_retained_schema first_call, 17

host_retained_theorem second_call := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Second183.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Second183.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Second183.input s)
    (role : Annotated.Value)
    (controlNote : notes.runtime.control = callNote (.obj Second183.sourceGetter) (.obj Second183.sourceOwner) [])
    (fieldNote : notes.privates.owners Second183.sourceOwner = some ⟨Second183.sourceBrand,Second183.sourceHandleName,role⟩)
    (budget : s.next+2 ≤ 2^64) => by
  host_retained_chain P.F, [Second183.retained_transport] using h, inventory, inst
host_assert_retained_schema second_call, 17

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema first_call, 18

open Lean Elab Command in
run_cmd do
  for (name,endpoint) in [("WrongEndpoint","P.RestStream.micro0.micro1.s44"),
      ("WrongResult","{P.RestStream.micro0.micro1.s43 with ctl := .ret .undef}")] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit s!"host_retained_getter_call P.F, P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 to {endpoint} using P.RestStream.micro0.micro1.S43 as {name}"
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect getter call endpoint/result was not rejected by the kernel"

end Host.Load.Run.Full.Ordinary.RetainedGetterCalls

