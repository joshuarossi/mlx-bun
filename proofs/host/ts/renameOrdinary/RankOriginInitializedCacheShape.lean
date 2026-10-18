import host.ts.renameOrdinary.RankOriginInitializedCacheEntry
import host.ts.renameOrdinary.RankNamespacedShape

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
open CacheEntry

noncomputable def nativeFrame (ρ : Nat → F64) (limit : Nat) (C : CSrv) : Ren → LSt → LSt → Prop :=
  StateNativeRelation LSt.mlx (fun _ _ _ => True)
    (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C C
    entryRoles entryObjects NativeSeed.boundary NativeSeed.handles NativeSeed.nodes []
noncomputable def constructorMetadata : NativeCaptureNote :=
  InitialRetained.constructorMetadata.mapRoles (Value.subst LoopVariables.oracleVariables)

theorem entry_rank_absent (ic : Annotated.Tree) (is : List Annotated.Tree) :
    (entryNotes ic is).runtime.cells.cells Variable5.address = none := by
  change (InitialRetained.cells.cells Variable5.address).map (Value.subst LoopVariables.oracleVariables) = none
  rw [InitialRetained.rank_absent]
  rfl

theorem entry_pointer_absent (ic : Annotated.Tree) (is : List Annotated.Tree) :
    (entryNotes ic is).runtime.cells.cells PointerBinding48.sourceAddress = none := by
  change (InitialRetained.cells.cells PointerBinding48.sourceAddress).map (Value.subst LoopVariables.oracleVariables) = none
  rw [InitialRetained.pointer_absent]
  rfl

theorem entry_constructor (ic : Annotated.Tree) (is : List Annotated.Tree) :
    (entryNotes ic is).captures.owners 90 = some constructorMetadata := by
  change (InitialRetained.captures.owners 90).map
    (fun note => note.mapRoles (Value.subst LoopVariables.oracleVariables)) = some constructorMetadata
  rw [InitialRetained.constructor_selected]
  rfl

theorem constructor_code : constructorMetadata.roles 0 = some (.literal (.lit (F64.ofNat 4))) := rfl
theorem constructor_proto : constructorMetadata.roles 1 = some (.literal (.lit (F64.ofNat 21))) := rfl

theorem hidden_shape : (entryRoles 22582).shape.valueRoles =
    [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))] := by
  have held : NativeSeed.nodes 22582 := by
    change 22582 < NativeSeed.native.nnext
    rw [NativeSeed.source_nnext]
    decide +kernel
  rw [entry_role_other 22582 producers_not_hidden,ObjectSeed.roles_live 22582 held]
  rfl

noncomputable def shapeNotes (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree) : RetainedNotes :=
  RetainedShapePrefix.EndNotes (RankShapeRetained.EntryNotes (entryNotes ic is)
    control fnRole thisRole saved caller) caller (entryRoles 22582).shape.valueRoles

theorem shape_offsets (ic : Annotated.Tree) (is : List Annotated.Tree) (control : Annotated.Tree)
    (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree) (caller : List Annotated.Tree)
    (owner : Nat) (selected : owner ∈ cacheOwners) :
    (shapeNotes ic is control fnRole thisRole saved caller).publicFields.fields owner chars!"offset" =
      some (.literal (offsetMeaning LoopVariables.cacheIndex owner)) :=
  entry_offset_selected ic is owner selected

/-- The reached cache inventory executes the original 58-step rank prefix
and the 14 namespaced shape steps. Its literal offset provenance and symbolic
capacity meanings survive all six inventories and the strong native frame. -/
theorem initialized_shape (ρ : Nat → F64) (C : CSrv) (limit : Nat)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ (C' : CSrv) (ic : Annotated.Tree) (is : List Annotated.Tree)
        (control : Annotated.Tree) (fnRole thisRole : Annotated.Value) (saved : Annotated.Tree)
        (caller : List Annotated.Tree) (result : St LSt),
      ((bootL Route.cx Decode.world 2000).bind fun start => runC P.F 32741869 start C) = some (result,C') ∧
      Parametric.StateR
        (NumberRoles (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C')
        (nativeFrame ρ limit C') identity (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live))
        (fun _ => False) [] [] input.trace input.trace P.RestStream.micro0.micro0.s14 result ∧
      RetainedInventory (shapeNotes ic is control fnRole thisRole saved caller)
        (LoopVariables.valuation ρ (loop limit)) (LoopVariables.valuation ρ (loop limit)) C' C'
        identity (RetainedShapePrefix.EndLive (GetterLive InitialRetained.live)) P.RestStream.micro0.micro0.s14 result ∧
      ProducerAnnotations ObjectSeed.roots NativeSeed.handles NativeSeed.nodes entryRoles entryObjects ∧
      ProducerSupport ObjectSeed.roots NativeSeed.handles NativeSeed.nodes P.RestStream.micro0.micro0.s14.ffi.mlx ∧
      Inst (LoopVariables.valuation ρ (loop limit)) NamespacedPrefix.Source13.nextServer C' := by
  obtain ⟨C',ic,is,bootRun,state,inventory,policy,_,inst⟩ := initialized_entry ρ C limit table answers
  let ν := LoopVariables.valuation ρ (loop limit)
  obtain ⟨result,control,fnRole,thisRole,saved,caller,run,post,retained,inst14⟩ :=
    RankNamespacedShape.enter_and_shape (nativeFrame ρ limit C') identity ν ν C' C'
      InitialRetained.live (fun _ => False) [] [] input.trace input.trace input state inst
      (entryNotes ic is) inventory (entry_rank_absent ic is) (entry_pointer_absent ic is)
      constructorMetadata (entry_constructor ic is) constructor_code constructor_proto
      entryRoles (ObjectRel entryObjects ν ν C' C' identity) NativeSeed.boundary NativeSeed.handles NativeSeed.nodes []
      state.native.1 (fun impossible => impossible) (fun impossible => impossible) NativeSeed.handle_live
      (InitializedShape.initial_argument ν C') InitializedShape.initial_private_handle
      (by rw [Host.Mlx.Ffi.Annotated.Initial.identity_handle]; rfl)
      InitializedShape.allocation_bound InitializedShape.initial_global rfl
      InitializedShape.initial_array_buffer rfl InitializedShape.initial_typed rfl InitializedShape.initial_array rfl
  refine ⟨C',ic,is,control,fnRole,thisRole,saved,caller,result,?_,post,retained,policy,policy.source post.native.1,inst14⟩
  cases boot : bootL Route.cx Decode.world 2000 with
  | none => simp only [boot,Option.bind_none] at bootRun; cases bootRun
  | some start =>
    simp only [boot,Option.bind_some] at bootRun ⊢
    exact runC_join P.F (m:=32741797) (n:=72) bootRun run

end Host.Load.Run.Full.Ordinary.RankOrigin.InitializedCache
