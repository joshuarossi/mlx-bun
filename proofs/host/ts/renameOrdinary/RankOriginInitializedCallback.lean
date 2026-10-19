import host.ts.renameOrdinary.RankOriginInitializedBoot
import host.load.RuntimeConcatBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCallback
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- Name the reached note/live data from the already checked batch schema.
This selects no machine state and adds no execution claim. -/
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``RetainedConcatBatch.shape_to_callback
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

theorem source14_next : P.RestStream.micro0.micro0.s14.next = 3126664 := by host_kernel_rfl

theorem source14_grow (a : Nat) (alive : InitialRetained.live a) :
    RetainedShapePrefix.EndLive (GetterLive InitialRetained.live) a :=
  Or.inl (Or.inl (Or.inl (ClosureLive.grow InitialRetained.live EnterGetter28.input.next
    EnterGetter28.sourceArrow EnterGetter28.sourceHome EnterGetter28.sourceFunction a alive)))

theorem initial_function : InitialRetained.live aFunctionProto := by
  rw [InitialRetained.live,InitialClosure.source_address_limit]; decide +kernel

/-- The real boot initialization hands all retained families to the actual
source64 callback-entry cut. All stream, structural-cell, intrinsic and
allocation premises of the checked fifty-step batch are discharged here. -/
theorem initialized_callback (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32741919 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C') (InitializedShape.nativeFrame ρ C') identity
        (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro0.s64 result ∧
      RetainedInventory (endNotes (RankShapeRetained.EntryNotes
        (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller) caller)
        ρ ρ C' C' identity (endLive (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
        P.RestStream.micro0.micro0.s64 result ∧
      Inst ρ (numberServer P.RestStream.micro0.micro0.S64) C' := by
  obtain ⟨C',initialControl,initialStack,s14,control,fnRole,thisRole,saved,caller,run14,h14,inventory14,inst14,seeds⟩ :=
    InitializedBoot.initialized_shape ρ C table answers
  have next14 : s14.next = 3126664 := by
    have fresh := h14.heap.fresh 0
    change P.RestStream.micro0.micro0.s14.next = s14.next at fresh
    exact fresh.symm.trans source14_next
  have budget : s14.next+64 ≤ 2^64 := by rw [next14]; decide +kernel
  have geometry : (NativeSeed.roles 22582).shape.valueRoles =
      [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))] :=
    by host_kernel_rfl
  rw [geometry] at inventory14
  have streamEntry := seeds.streamEntry
  rw [← RetainedParameterBatch.default_stream_handle] at streamEntry
  obtain ⟨result,run50,h64,inventory64,inst64⟩ := RetainedConcatBatch.shape_to_callback
    (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack) control fnRole thisRole saved caller)
    caller ρ ρ C' C' identity (InitializedShape.nativeFrame ρ C')
    (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) (fun _ => False)
    [] [] input.trace input.trace s14 inst14 h14 inventory14 budget
    (source14_grow _ InitializedShape.initial_array) rfl
    seeds.exportEntry seeds.namespaceEntry seeds.firstEntry seeds.secondEntry
    (source14_grow _ initial_function) rfl (source14_grow _ InitializedShape.initial_global) rfl streamEntry
  refine ⟨C',initialControl,initialStack,control,fnRole,thisRole,saved,caller,result,?_,h64,inventory64,inst64⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none =>
    simp only [boot,Option.bind_none] at run14
    cases run14
  | some start =>
    simp only [boot,Option.bind_some] at run14 ⊢
    exact runC_join P.F (m:=32741869) (n:=50) run14 run50

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCallback
