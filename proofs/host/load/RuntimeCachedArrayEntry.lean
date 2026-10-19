import host.load.RuntimeCachedArrayEntryPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedArrayEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_theorem retained_prefix := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Allocation.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (metadata : NativeCaptureNote) (fnRole : Annotated.Value)
    (controlNote : notes.runtime.control = constructNote fnRole [.literal (.lit Allocation.countLiteral)])
    (selected : notes.captures.owners Allocation.address = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit Allocation.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit Allocation.protoLiteral)))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live Allocation.protoIndex) (protoFixed : R.a Allocation.protoIndex = Allocation.protoIndex)
    (countNote : notes.runtime.cells.cells countCell = some (.literal (.lit countLiteral)))
    (budget : s.next+4 ≤ 2^64) => by
  host_retained_plan_chain P.F, Plan using state, inventory, inst
host_assert_retained_schema retained_prefix, 40

-- Name the exact deterministic notes/live set exported by the checked chain.
-- Reject an extraction that still depends on a reached target or proof premise.
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let pre ← getCurrNamespace
  let checked := mkConst (pre ++ `retained_prefix)
  forallTelescope (← inferType checked) fun args conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do throwError "expected retained existential"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let rec findInventory (type : Lean.Expr) : MetaM Lean.Expr := do
        let type ← whnf type
        if type.getAppFn.isConstOf ``RetainedInventory then return type
        unless type.isAppOfArity ``And 2 do throwError "missing retained inventory"
        let saved ← saveState
        try findInventory type.getAppArgs[0]!
        catch _ => saved.restore; findInventory type.getAppArgs[1]!
      let inventory ← findInventory (mkApp conclusion.getAppArgs[1]! result)
      for (tag,value,parameter) in [("resultNotes",inventory.getAppArgs[1]!,args[0]!),
          ("resultLive",inventory.getAppArgs[7]!,args[7]!)] do
        let value ← instantiateMVars (← mkLambdaFVars #[parameter] value)
        if value.hasFVar || value.hasMVar then throwError "retained output depends on an unavailable parameter"
        Host.Ts.Owned.Parametric.Driver.addData (pre ++ Name.mkSimple tag) value

/-- Exactly the host-only interval 2447→2487. The native array allocation is
still the next control; arbitrary caller data and the entry native state remain. -/
theorem retained_to_array_new
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Allocation.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro24.s47 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro24.s47 s)
    (metadata : NativeCaptureNote) (fnRole : Annotated.Value)
    (controlNote : notes.runtime.control = constructNote fnRole [.literal (.lit Allocation.countLiteral)])
    (selected : notes.captures.owners Allocation.address = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit Allocation.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit Allocation.protoLiteral)))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live Allocation.protoIndex) (protoFixed : R.a Allocation.protoIndex = Allocation.protoIndex)
    (countNote : notes.runtime.cells.cells countCell = some (.literal (.lit countLiteral)))
    (budget : s.next+4 ≤ 2^64) :
    ∃ result, runC P.F 40 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (resultLive live) framed before after old old'
        P.RestStream.micro0.micro24.s87 result ∧
      RetainedInventory (resultNotes notes) ν₀ ν C₀ C R (resultLive live) P.RestStream.micro0.micro24.s87 result ∧
      Inst ν₀ From2477.Cut.S10 C₀ ∧ result.ffi = s.ffi := by
  let stableFR : Ren → P.F.S → P.F.S → Prop :=
    fun ren source target => FR ren source target ∧ source = Region.s0.ffi ∧ target = s.ffi
  have stable : Parametric.StateR (NumberRoles ν₀ ν C₀ C) stableFR R live framed before after old old' Region.s0 s :=
    {state with native := ⟨state.native,rfl,rfl⟩}
  obtain ⟨result,run,post,retained,nextInst⟩ := retained_prefix notes ν₀ ν C₀ C R stableFR live framed
    before after old old' s inst stable inventory metadata fnRole controlNote selected codeNote protoNote
    bufferProtoLive bufferProtoFixed protoLive protoFixed countNote budget
  have endpoint : Region.s40 = P.RestStream.micro0.micro24.s87 := cut_2487
  have related : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (resultLive live) framed before after old old' Region.s40 result :=
    {post with native := post.native.1}
  exact ⟨result,run,endpoint ▸ related,endpoint ▸ retained,nextInst,post.native.2.2⟩
host_assert_retained_schema retained_to_array_new, 40

/-- The no-argument call roles are derived by the checked chain. -/
theorem result_control (notes : RetainedNotes) :
    (resultNotes notes).runtime.control = callNote (.obj 4630) (.obj 4817) [] := by
  host_kernel_rfl

end Host.Load.Run.Full.Ordinary.CachedArrayEntry
