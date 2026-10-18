import host.ts.renameOrdinary.RankOriginInitializedCacheVector
import host.load.RuntimeNamespacedVectorCompatibility
import host.load.RuntimeVectorOracleCompatibility
import host.ts.RenameLiteralCaptureSubstitution
import host.ts.renameOrdinary.RankOriginInitializedVectorPrelude

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConcatEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open RetainedVectorOracleBatch

theorem source_bound : P.RestStream.micro0.micro2.s50.next+32 ≤ 2^64 := by decide +kernel
theorem native_frame : P.RestStream.micro0.micro3.s36.ffi = P.RestStream.micro0.micro2.s50.ffi := by host_kernel_rfl

theorem vector_live_eq : InitializedCache.finalLive = InitializedVector.finalLive := rfl

theorem constructor_selected (ic : Annotated.Tree) (is : List Annotated.Tree)
    (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
    (caller : List Annotated.Tree) :
    (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller).captures.owners 95 =
      some InitializedHandleBuffer.constructorMetadata := by
  change (InitializedCache.entryNotes ic is).captures.owners 95 = some InitializedHandleBuffer.constructorMetadata
  have selected := InitializedCache.array_constructor_selected ic is
  simpa only [InitializedCache.arrayConstructorMetadata,InitializedHandleBuffer.constructorMetadata,literalNativeNote_subst]
    using selected

theorem ready_offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
      control fnRole thisRole saved caller) caller).publicFields.fields owner chars!"offset" =
      some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  InitializedCache.entry_offset_selected ic is owner selected

/-- The real initialized vector reaches the concat entry while retaining all
cache offset notes, symbolic capacity roles and current producer ownership.
Oracle variables use the substituted server throughout the original prefix. -/
theorem initialized_concat_entry (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value)
        (saved : Annotated.Tree) (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742191 start C) = some (result,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C')
        (VectorHost.NativeRelation (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
          InitializedCache.entryRoles NativeSeed.boundary InitializedCache.finalObjects InitializedCache.finalHandles NativeSeed.nodes [] InitializedCache.hostRelation)
        identity (readyLive InitializedCache.finalLive) (fun _ => False) [] [] input.trace input.trace
          P.RestStream.micro0.micro3.s36 result ∧
      RetainedInventory (readyNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is)
        control fnRole thisRole saved caller) caller)
        (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C'
        identity (readyLive InitializedCache.finalLive) P.RestStream.micro0.micro3.s36 result ∧
      ProducerAnnotations ObjectSeed.roots InitializedCache.finalHandles NativeSeed.nodes InitializedCache.entryRoles InitializedCache.finalObjects ∧
      ProducerSupport ObjectSeed.roots InitializedCache.finalHandles NativeSeed.nodes P.RestStream.micro0.micro3.s36.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (InitializedCache.loop limit))
        (numberServer (P.RestStream.micro0.micro3.S36.substitute LoopVariables.oracleVariables)) C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s250,run250,h250,inventory250,policy,support,inst250⟩ :=
    InitializedCache.initialized_vector ρ C limit table answers
  have fresh := h250.heap.fresh 0
  have counter : P.RestStream.micro0.micro2.s50.next = s250.next := by
    simpa only [Nat.add_zero,identity,id_eq] using fresh
  have budget : s250.next+32 ≤ 2^64 := counter ▸ source_bound
  have intrinsic (a : Nat) (small : a < 100) : InitializedCache.finalLive a := by
    rw [vector_live_eq]
    exact InitializedVectorPrelude.vector_live_grow a (by rw [InitialRetained.live,InitialClosure.source_address_limit]; omega)
  have retained : RetainedInventory
      (entryNotes (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller)
      (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit))
      C' C' identity InitializedCache.finalLive P.RestStream.micro0.micro2.s50 s250 := by
    simpa only [entry_notes_eq,NamespacedVectorEntryBatch.final_notes_eq] using inventory250
  obtain ⟨result,run86,h336,inventory336,inst336⟩ := vector_to_concat
    (RankShapeRetained.EntryNotes (InitializedCache.entryNotes ic is) control fnRole thisRole saved caller) caller
    (LoopVariables.valuation ρ (InitializedCache.loop limit)) (LoopVariables.valuation ρ (InitializedCache.loop limit)) C' C' identity
    InitializedCache.entryRoles NativeSeed.boundary InitializedCache.finalObjects InitializedCache.finalHandles NativeSeed.nodes [] InitializedCache.hostRelation
    InitializedCache.finalLive (fun _ => False) [] [] input.trace input.trace s250 inst250 h250 retained budget
    (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl (intrinsic _ (by decide +kernel)) rfl
    (intrinsic _ (by decide +kernel)) rfl (fun impossible => impossible) (intrinsic _ (by decide +kernel)) rfl
    (constructor_selected ic is control fnRole thisRole saved caller) (intrinsic _ (by decide +kernel)) rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,h336,inventory336,policy,?_,inst336⟩
  · cases boot : bootL Route.cx Decode.world 2000 with
    | none => simp only [boot,Option.bind_none] at run250; cases run250
    | some start =>
      simp only [boot,Option.bind_some] at run250 ⊢
      exact runC_join P.F (m:=32742105) (n:=86) run250 run86
  · simpa only [native_frame] using support

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCacheConcatEntry
