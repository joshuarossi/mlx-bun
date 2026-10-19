import host.ts.renameOrdinary.RankOriginInitializedCallback
import host.load.RuntimeMapArrayBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedHandleArray
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- These aliases name the notes and live set in the already checked source
batch's conclusion. No source or target state is selected here. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``RetainedMapArrayBatch.shape_to_handle_array
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected retained batch endpoint"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing retained batch inventory"
      let retained ← inventory body
      for (name,index) in [(`endNotes,1),(`endLive,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)

/-- The actual boot-reached initializer executes through the first source
handle array. Both handle notes are classified from initialized private fields
and existing native arrays/producers, then preserved by the checked source
path; neither is supplied as a new entry premise. -/
theorem initialized_handle_array (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742078 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C') (InitializedShape.nativeFrame ρ C') identity
        (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro2.s23 result ∧
      RetainedInventory (endNotes (RankShapeRetained.EntryNotes
        (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller) caller)
        ρ ρ C' C' identity (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
        P.RestStream.micro0.micro2.s23 result ∧
      Inst ρ (numberServer P.RestStream.micro0.micro2.S23) C' := by
  obtain ⟨C',initialControl,initialStack,s14,control,fnRole,thisRole,saved,caller,run14,h14,inventory14,inst14,seeds⟩ :=
    InitializedBoot.initialized_shape ρ C table answers
  have next14 : s14.next = 3126664 := by
    have fresh := h14.heap.fresh 0
    change P.RestStream.micro0.micro0.s14.next = s14.next at fresh
    exact fresh.symm.trans InitializedCallback.source14_next
  have budget : s14.next+64 ≤ 2^64 := by rw [next14]; decide +kernel
  have geometry : (NativeSeed.roles 22582).shape.valueRoles =
      [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))] :=
    by host_kernel_rfl
  rw [geometry] at inventory14
  have streamEntry := seeds.streamEntry
  rw [← RetainedParameterBatch.default_stream_handle] at streamEntry
  have firstHandle : (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
      control fnRole thisRole saved caller).privates.owners RetainedGetterBlocks.First130.sourceOwner =
      some ⟨RetainedGetterBlocks.First130.sourceBrand,RetainedGetterBlocks.First130.sourceHandleName,.handle 25732⟩ :=
    seeds.firstHandle
  have secondHandle : (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
      control fnRole thisRole saved caller).privates.owners RetainedGetterBlocks.Second187.sourceOwner =
      some ⟨RetainedGetterBlocks.Second187.sourceBrand,RetainedGetterBlocks.Second187.sourceHandleName,.handle 29363⟩ :=
    seeds.secondHandle
  obtain ⟨result,run209,h223,inventory223,inst223⟩ := RetainedMapArrayBatch.shape_to_handle_array
    (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller)
    caller ρ ρ C' C' identity (InitializedShape.nativeFrame ρ C')
    (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) (fun _ => False)
    [] [] input.trace input.trace s14 inst14 h14 inventory14 budget
    (InitializedCallback.source14_grow _ InitializedShape.initial_array) rfl
    seeds.exportEntry seeds.namespaceEntry seeds.firstEntry seeds.secondEntry
    (InitializedCallback.source14_grow _ InitializedCallback.initial_function) rfl
    (InitializedCallback.source14_grow _ InitializedShape.initial_global) rfl streamEntry firstHandle secondHandle
  refine ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,result,?_,h223,inventory223,inst223⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none =>
    simp only [boot,Option.bind_none] at run14
    cases run14
  | some start =>
    simp only [boot,Option.bind_some] at run14 ⊢
    exact runC_join P.F (m:=32741869) (n:=209) run14 run209

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedHandleArray
