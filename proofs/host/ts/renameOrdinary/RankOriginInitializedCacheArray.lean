import host.ts.renameOrdinary.RankOriginInitializedCacheCells
import host.load.RuntimeNamespacedMapNotes

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def arrayNotes (notes : RetainedNotes) (caller : List Annotated.Tree) : RetainedNotes :=
  NamespacedMap.arrayNotes notes caller
noncomputable def arrayLiveSet (live : Nat → Prop) : Nat → Prop := NamespacedMap.arrayLiveSet live

theorem array_publics (notes : RetainedNotes) (caller : List Annotated.Tree) :
    (arrayNotes notes caller).publicFields = notes.publicFields := rfl

theorem array_offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ CacheEntry.cacheOwners) :
    (arrayNotes (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller).publicFields.fields
      owner chars!"offset" = some (.literal (CacheEntry.offsetMeaning LoopVariables.cacheIndex owner)) :=
  entry_offset_selected ic is owner selected

theorem initialized_array (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
        (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32742078 start C) = some (result,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
        (nativeFrame ρ limit C') identity (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)))
        (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro2.s23 result ∧
      RetainedInventory (arrayNotes (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller)
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
        identity (arrayLiveSet (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))) P.RestStream.micro0.micro2.s23 result ∧
      Host.Mlx.Ffi.Annotated.ProducerAnnotations ObjectSeed.roots NativeSeed.handles NativeSeed.nodes entryRoles entryObjects ∧
      Host.Mlx.Ffi.NativeRoles.ProducerSupport ObjectSeed.roots NativeSeed.handles NativeSeed.nodes P.RestStream.micro0.micro2.s23.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit)) NamespacedMap.Plan203.Block222.nextServer C' := by
  obtain ⟨C',ic,is,control,fnRole,thisRole,saved,caller,s14,bootRun,h14,inventory14,policy,_,inst14⟩ :=
    initialized_shape ρ C limit table answers
  let ν := LoopVariables.valuation ρ (loop limit)
  have seeds := entry_seeds ic is control fnRole thisRole saved caller
  have next14 : s14.next = 3126664 := by
    have fresh := h14.heap.fresh 0
    change P.RestStream.micro0.micro0.s14.next = s14.next at fresh
    exact fresh.symm.trans InitializedCallback.source14_next
  have budget : s14.next+64 ≤ 2^64 := by rw [next14]; decide +kernel
  change RetainedInventory (RetainedShapePrefix.EndNotes
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller
      (entryRoles 22582).shape.valueRoles) ν ν C' C' identity
    (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) P.RestStream.micro0.micro0.s14 s14 at inventory14
  rw [hidden_shape] at inventory14
  have streamEntry := seeds.streamEntry
  rw [← RetainedParameterBatch.default_stream_handle] at streamEntry
  obtain ⟨result,run209,post,retained,inst223⟩ := NamespacedMap.through223
    (RankShapeRetained.EntryNotes (entryNotes ic is) control fnRole thisRole saved caller) caller
    ν ν C' C' identity (nativeFrame ρ limit C') (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))
    (fun _ => False) [] [] input.trace input.trace s14 inst14 h14 inventory14 budget
    (InitializedCallback.source14_grow _ InitializedShape.initial_array) rfl
    seeds.exportEntry seeds.namespaceEntry seeds.firstEntry seeds.secondEntry
    (InitializedCallback.source14_grow _ InitializedCallback.initial_function) rfl
    (InitializedCallback.source14_grow _ InitializedShape.initial_global) rfl streamEntry seeds.firstHandle seeds.secondHandle
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,policy.source post.native.1,inst223⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at bootRun; cases bootRun
  | some start =>
    simp only [boot,Option.bind_some] at bootRun ⊢
    exact runC_join P.F (m:=32741869) (n:=209) bootRun run209

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
