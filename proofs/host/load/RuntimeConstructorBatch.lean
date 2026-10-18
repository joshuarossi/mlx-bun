import host.ts.renameOrdinary.RuntimeConstructorCases
import host.ts.renameOrdinary.RuntimePrivateFieldsCases
import host.ts.renameOrdinary.RuntimePrivateAssignCases
import host.load.RuntimePrefix
import host.ts.RenameRetainedChain
import host.ts.RenameRuntimeBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RetainedConstructorBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_step P.F, P.RestStream.micro0.micro3.s74 using P.RestStream.micro0.micro3.S74
  to P.RestStream.micro0.micro3.s75 using P.RestStream.micro0.micro3.S75 as Disposed374
host_source_step P.F, P.RestStream.micro0.micro3.s76 using P.RestStream.micro0.micro3.S76
  to P.RestStream.micro0.micro3.s77 using P.RestStream.micro0.micro3.S77 as Token376
host_source_step P.F, P.RestStream.micro0.micro3.s78 using P.RestStream.micro0.micro3.S78
  to P.RestStream.micro0.micro3.s79 using P.RestStream.micro0.micro3.S79 as Pins378

/- The saved constructor argument meanings flow through every field and into
parameter binding. Initial private fields use their evaluated source roles;
none is chosen from a future receiver read. -/
host_retained_theorem class_to_body := fun (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro3.S72) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro3.s72 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro3.s72 s)
    (fnRole : Annotated.Value) (argRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = constructNote fnRole argRoles)
    (budget : s.next+16 ≤ 2^64)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto) => by
  have objectAfterClass : BaseClassLive live RetainedConstructors.Class372.input.next aObjectProto :=
    Or.inl (Or.inl objectLive)
  host_retained_chain P.F, [RetainedConstructors.Class372.retained_transport,
    RetainedPrivateFields.Fields373.retained_transport,Disposed374.retained_transport,
    RetainedPrivateFields.Disposed375.retained_transport,Token376.retained_transport,
    RetainedPrivateFields.Token377.retained_transport,Pins378.retained_transport,
    RetainedPrivateFields.Pins379.retained_transport,RetainedConstructors.Body380.retained_transport]
    using h, inventory, inst

host_assert_retained_schema class_to_body, 9


host_source_step P.F, P.RestStream.micro0.micro3.s81 using P.RestStream.micro0.micro3.S81
  to P.RestStream.micro0.micro3.s82 using P.RestStream.micro0.micro3.S82 as Step381
host_source_step P.F, P.RestStream.micro0.micro3.s82 using P.RestStream.micro0.micro3.S82
  to P.RestStream.micro0.micro3.s83 using P.RestStream.micro0.micro3.S83 as Step382
host_source_step P.F, P.RestStream.micro0.micro3.s83 using P.RestStream.micro0.micro3.S83
  to P.RestStream.micro0.micro3.s84 using P.RestStream.micro0.micro3.S84 as Step383
host_source_step P.F, P.RestStream.micro0.micro3.s84 using P.RestStream.micro0.micro3.S84
  to P.RestStream.micro0.micro3.s85 using P.RestStream.micro0.micro3.S85 as Step384
host_source_step P.F, P.RestStream.micro0.micro3.s85 using P.RestStream.micro0.micro3.S85
  to P.RestStream.micro0.micro3.s86 using P.RestStream.micro0.micro3.S86 as Step385
host_source_step P.F, P.RestStream.micro0.micro3.s87 using P.RestStream.micro0.micro3.S87
  to P.RestStream.micro0.micro3.s88 using P.RestStream.micro0.micro3.S88 as Step387
host_source_step P.F, P.RestStream.micro0.micro3.s89 using P.RestStream.micro0.micro3.S89
  to P.RestStream.micro0.micro3.s90 using P.RestStream.micro0.micro3.S90 as Step389

host_retained_theorem class_to_handle := fun (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro3.S72) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro3.s72 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro3.s72 s)
    (fnRole : Annotated.Value) (argRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = constructNote fnRole argRoles)
    (budget : s.next+16 ≤ 2^64)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto) => by
  have earlier := class_to_body notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
    fnRole argRoles controlNote budget objectLive objectFixed
  have post := Classical.choose_spec earlier
  have run9 := post.1
  have h381 := post.2.1
  have inv381 := post.2.2.1
  have inst381 := post.2.2.2
  have objectAfterBody : ConstructorBodyLive
      (LiveAfter (BaseClassLive live RetainedConstructors.Class372.input.next) Token376.input.next)
      RetainedConstructors.Body380.input.next RetainedConstructors.Body380.sourceFunction aObjectProto :=
    CellsLive.grow _ _ _ _ (Or.inl (Or.inl (Or.inl (Or.inl objectLive))))
  host_retained_chain_after P.F, [Step381.retained_transport,Step382.retained_transport,Step383.retained_transport,Step384.retained_transport,Step385.retained_transport,RetainedPrivateAssign.Entry386.retained_transport,Step387.retained_transport,RetainedPrivateAssign.Receiver388.retained_transport,Step389.retained_transport,RetainedPrivateAssign.Store390.retained_transport] using h381, inv381, inst381
    continuing_run run9 initial_relation h
host_assert_retained_schema class_to_handle, 19

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``class_to_handle
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected retained constructor endpoint"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing retained constructor inventory"
      let retained ← inventory body
      for (name,index) in [(`handleNotes,1),(`handleLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

theorem stored_argument_note (notes : RetainedNotes) (role : Annotated.Value) :
    (handleNotes notes [role]).privates.owners RetainedConstructors.Class372.input.next =
      some ⟨RetainedPrivateAssign.Entry386.sourceBrand,RetainedPrivateAssign.Entry386.sourceName,role⟩ := by
  rfl

theorem stored_native_handle {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live : Nat → Prop} {source result : St P.F.S} {handle : Nat}
    (inventory : RetainedInventory (handleNotes notes [.handle handle]) ν₀ ν C₀ C R live source result) :
    PrivateData result (R.a RetainedConstructors.Class372.input.next)
      (R.a RetainedPrivateAssign.Entry386.sourceBrand) RetainedPrivateAssign.Entry386.sourceName
      (.big (Int.ofNat (R.handle handle))) := by
  obtain ⟨value,field,meaning⟩ := inventory.privates.target _ _ (stored_argument_note notes (.handle handle))
  cases meaning
  exact field

end Host.Load.Run.Full.Ordinary.RetainedConstructorBatch
