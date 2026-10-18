import host.ts.renameOrdinary.RankOriginInitialCells

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedBoot
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Starting from the real linked boot, the checked prefix and shape entry
produce one retained native/runtime invariant at the ordinary source14 cut.
The premises instantiate the original symbolic table and the branch answers
already consumed by that prefix. No post-load heap or capture invariant is
assumed. The native literals describe this reached entry only. -/
theorem initialized_shape (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (initialControl : Annotated.Tree) (initialStack : List Annotated.Tree)
        (result : St LSt) (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32741869 start C) = some (result,C') ∧
      Parametric.StateR (NumberRoles ρ ρ C' C') (InitializedShape.nativeFrame ρ C') identity
        (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) (fun _ => False)
        [] [] input.trace input.trace P.RestStream.micro0.micro0.s14 result ∧
      RetainedInventory (RetainedShapePrefix.EndNotes
        (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
          control fnRole thisRole saved caller) caller (NativeSeed.roles 22582).shape.valueRoles)
        ρ ρ C' C' identity (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))
        P.RestStream.micro0.micro0.s14 result ∧
      Inst ρ (numberServer P.RestStream.micro0.micro0.S14) C' ∧
      InitialCells.Seeds (RankShapeRetained.EntryNotes (InitialRetained.notes initialControl initialStack)
        control fnRole thisRole saved caller) := by
  obtain ⟨C',prefixRun,tab,_,_⟩ := InitialClosure.source_initialization ρ C table answers
  obtain ⟨initialControl,initialStack,result,control,fnRole,thisRole,saved,caller,run,related,inventory,inst⟩ :=
    InitializedShape.enter_and_shape ρ C' tab
  refine ⟨C',initialControl,initialStack,result,control,fnRole,thisRole,saved,caller,?_,related,inventory,inst,
    InitialCells.entry_seeds initialControl initialStack control fnRole thisRole saved caller⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none =>
    simp only [boot,Option.bind_none] at prefixRun
    cases prefixRun
  | some start =>
    simp only [boot,Option.bind_some] at prefixRun ⊢
    exact runC_join P.F (m:=32741797) (n:=72) prefixRun run

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedBoot
